// 3D Pixel Art Outline & Highlight: pós-processamento em tela cheia (contornos e realces nas bordas).
// MIT License. Made by Leo Peltola. Adapted by ARez.
// https://godotshaders.com/shader/3d-pixel-art-outline-highlight-shader-adapted-for-in-editor-perspective/
// Inspired by https://threejs.org/examples/webgl_postprocessing_pixel.html
//
// Adaptações para o Sky Jump (renderizador Mobile, Godot 4.7):
// - hint_normal_roughness_texture só existe no Forward+: as normais são reconstruídas do DEPTH_TEXTURE.
// - Z invertido (Godot 4.3+): o quad fica no plano próximo e ignora o teste de profundidade.
// - Cada célula é amostrada no centro de um texel (filter_nearest) para reduzir o borrado.
// - O tamanho do "pixel" acompanha a resolução da tela: o visual é o mesmo em qualquer celular.
// - O efeito lê só o que foi desenhado no passe opaco. Objetos que devem ficar de fora (o personagem)
//   usam material transparente com Render Priority 1 e Depth Draw = Always: são desenhados depois
//   deste quad e não entram nas texturas de tela/profundidade, então não geram contorno nem resíduo.
//
// Parâmetros: art/shaders/pixel_outline_material.tres (Inspector > Shader Parameters).
shader_type spatial;
render_mode unshaded, fog_disabled, depth_draw_never, depth_test_disabled, cull_disabled;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_nearest;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

group_uniforms Geral;
uniform bool disable_shader = false;
// Força geral do efeito: 0 = invisível, 1 = efeito completo.
uniform float effect_strength : hint_range(0.0, 1.0, 0.01) = 1.0;
// Tamanho de cada "pixel" do contorno na altura de referência abaixo.
uniform int pixelSize : hint_range(1, 16, 1) = 4;
// Escala o tamanho do pixel pela altura real da tela (mesmo visual em telas maiores).
uniform bool scale_with_resolution = true;
// Altura de tela (px) em que pixelSize foi ajustado.
uniform float reference_height : hint_range(240.0, 4320.0, 1.0) = 800.0;
// Distância máxima (metros) em que o efeito é aplicado.
uniform float MAX_DEPTH : hint_range(0.0, 10000, 1) = 1000;

group_uniforms Contorno;
// Contorno escuro nas silhuetas (bordas de profundidade).
uniform bool shadows_enabled = true;
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform vec3 shadow_color : source_color = vec3(0.0);

group_uniforms Realce;
// Realce claro nas arestas das superfícies (mudança de normal).
uniform bool highlights_enabled = true;
uniform float highlight_strength : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec3 highlight_color : source_color = vec3(0.45);
group_uniforms;

vec3 view_position(vec2 screen_uv, mat4 inv_projection_matrix) {
	float raw_depth = texture(DEPTH_TEXTURE, screen_uv).r;
	vec4 view_space = inv_projection_matrix * vec4(screen_uv * 2.0 - 1.0, raw_depth, 1.0);
	return view_space.xyz / view_space.w;
}

// Normal em espaço de view (+Z aponta para a câmera) a partir do ponto e dos vizinhos à direita e abaixo.
vec3 normal_from(vec3 center, vec3 right, vec3 down) {
	vec3 n = cross(down - center, right - center);
	return n / max(length(n), 0.000001);
}

float normalIndicator(vec3 normalEdgeBias, vec3 baseNormal, vec3 newNormal, float depth_diff) {
	float normalDiff = dot(baseNormal - newNormal, normalEdgeBias);
	float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);
	float depthIndicator = clamp(sign(depth_diff * .25 + .0025), 0.0, 1.0);
	return (1.0 - dot(baseNormal, newNormal)) * depthIndicator * normalIndicator;
}

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	if (disable_shader || !(shadows_enabled || highlights_enabled)) {
		discard;
	}
	vec2 one_pixel = 1.0 / VIEWPORT_SIZE;
	float cell = float(pixelSize);
	if (scale_with_resolution) {
		cell = max(1.0, round(cell * VIEWPORT_SIZE.y / max(reference_height, 1.0)));
	}
	vec2 e = cell * one_pixel;
	vec2 uv = (floor(SCREEN_UV * VIEWPORT_SIZE / cell) * cell + 0.5) * one_pixel;

	vec3 p = view_position(uv, INV_PROJECTION_MATRIX);
	float depth = -p.z;
	if (depth > MAX_DEPTH) {
		discard;
	}
	vec3 pu = view_position(uv + vec2(0.0, -1.0) * e, INV_PROJECTION_MATRIX);
	vec3 pr = view_position(uv + vec2(1.0, 0.0) * e, INV_PROJECTION_MATRIX);
	vec3 pd = view_position(uv + vec2(0.0, 1.0) * e, INV_PROJECTION_MATRIX);
	vec3 pl = view_position(uv + vec2(-1.0, 0.0) * e, INV_PROJECTION_MATRIX);

	float depth_diff = 0.0;
	float neg_depth_diff = 0.0;
	if (shadows_enabled) {
		float du = -pu.z;
		float dr = -pr.z;
		float dd = -pd.z;
		float dl = -pl.z;
		depth_diff += clamp(du - depth, 0.0, 1.0);
		depth_diff += clamp(dd - depth, 0.0, 1.0);
		depth_diff += clamp(dr - depth, 0.0, 1.0);
		depth_diff += clamp(dl - depth, 0.0, 1.0);
		neg_depth_diff += depth - du;
		neg_depth_diff += depth - dd;
		neg_depth_diff += depth - dr;
		neg_depth_diff += depth - dl;
		neg_depth_diff = clamp(neg_depth_diff, 0.0, 1.0);
		neg_depth_diff = clamp(smoothstep(0.5, 0.5, neg_depth_diff) * 10.0, 0.0, 1.0);
		depth_diff = smoothstep(0.2, 0.3, depth_diff);
	}

	float normal_diff = 0.0;
	if (highlights_enabled) {
		vec3 pur = view_position(uv + vec2(1.0, -1.0) * e, INV_PROJECTION_MATRIX);
		vec3 prr = view_position(uv + vec2(2.0, 0.0) * e, INV_PROJECTION_MATRIX);
		vec3 prd = view_position(uv + vec2(1.0, 1.0) * e, INV_PROJECTION_MATRIX);
		vec3 pdd = view_position(uv + vec2(0.0, 2.0) * e, INV_PROJECTION_MATRIX);
		vec3 pld = view_position(uv + vec2(-1.0, 1.0) * e, INV_PROJECTION_MATRIX);
		vec3 normal = normal_from(p, pr, pd);
		vec3 nu = normal_from(pu, pur, p);
		vec3 nr = normal_from(pr, prr, prd);
		vec3 nd = normal_from(pd, prd, pdd);
		vec3 nl = normal_from(pl, p, pld);
		vec3 normal_edge_bias = vec3(1.0, 1.0, 1.0);
		normal_diff += normalIndicator(normal_edge_bias, normal, nu, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nr, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nd, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nl, depth_diff);
		normal_diff = smoothstep(0.2, 0.8, normal_diff);
		normal_diff = clamp(normal_diff - neg_depth_diff, 0.0, 1.0);
	}

	vec3 original_color = texture(SCREEN_TEXTURE, uv).rgb;
	vec3 final_highlight_color = mix(original_color, highlight_color, highlight_strength);
	vec3 final_shadow_color = mix(original_color, shadow_color, shadow_strength);
	vec3 final = original_color;
	if (highlights_enabled) {
		final = mix(final, final_highlight_color, normal_diff);
	}
	if (shadows_enabled) {
		final = mix(final, final_shadow_color, depth_diff);
	}
	ALBEDO = final;

	float alpha_mask = depth_diff * float(shadows_enabled) + normal_diff * float(highlights_enabled);
	ALPHA = clamp(alpha_mask * 5.0, 0.0, 1.0) * effect_strength;
}
