// Transição de tela: GRADIENTE + PADRÃO + PROGRESSO.
// gradiente: quando cada ponto começa a ser coberto (0 = primeiro, 1 = último).
// padrão:    limiar dentro da célula (0 = centro da forma, coberto primeiro).
// progress:  0 = tela livre, 1 = tela totalmente coberta.
// Otimizado para mobile: no máximo 2 leituras de textura, sem loops.
shader_type canvas_item;
render_mode unshaded;

// 0 FADE, 1 DIRECTIONAL, 2 CIRCLE, 3 RADIAL, 4 PATTERN, 5 DISSOLVE (TransitionConfig.Type)
uniform int mode = 0;
uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec2 node_resolution = vec2(720.0, 1280.0);
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float width : hint_range(0.001, 1.0) = 0.2;
uniform float feathering : hint_range(0.0, 1.0) = 0.05;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform bool invert = false;
uniform vec2 direction = vec2(1.0, 0.0);
uniform vec2 center = vec2(0.5, 0.5);

uniform bool use_gradient_texture = false;
uniform bool gradient_keep_aspect = true;
uniform sampler2D gradient_texture : hint_default_black, filter_linear, repeat_disable;

uniform bool use_shape_texture = false;
uniform sampler2D shape_texture : hint_default_white, filter_linear, repeat_enable;
uniform float pattern_scale = 8.0;
uniform float pattern_rotation = 0.0;
uniform vec2 pattern_offset = vec2(0.0);
uniform vec2 pattern_scroll = vec2(0.0);
uniform float pattern_time = 0.0;

float gradient_value(vec2 uv) {
	if (use_gradient_texture) {
		vec2 g_uv = uv;
		if (gradient_keep_aspect) {
			// A textura cobre o maior lado; o menor lado usa só a parte central.
			g_uv = (uv - 0.5) * node_resolution / max(node_resolution.x, node_resolution.y) + 0.5;
		}
		return texture(gradient_texture, g_uv).r;
	}
	if (mode == 1 || mode == 4) {
		float extent = abs(direction.x) + abs(direction.y);
		return clamp(dot(uv - 0.5, direction) / max(extent, 0.0001) + 0.5, 0.0, 1.0);
	}
	if (mode == 2 || mode == 3) {
		// Distância em pixels: círculo redondo em qualquer proporção; 1 no canto mais distante.
		vec2 far_corner = max(center, 1.0 - center) * node_resolution;
		return clamp(length((uv - center) * node_resolution) / length(far_corner), 0.0, 1.0);
	}
	return 0.0;
}

float shape_value(vec2 uv) {
	// Menor lado da tela = 1 unidade: células sempre quadradas.
	vec2 p = (uv - center) * node_resolution / min(node_resolution.x, node_resolution.y);
	float c = cos(pattern_rotation);
	float s = sin(pattern_rotation);
	p = mat2(vec2(c, -s), vec2(s, c)) * p;
	p = p * pattern_scale + pattern_offset + pattern_scroll * pattern_time;
	if (use_shape_texture) {
		return texture(shape_texture, p).r;
	}
	if (mode == 5) {
		return fract(sin(dot(floor(p), vec2(12.9898, 78.233))) * 43758.5453);
	}
	return clamp(length(fract(p) - 0.5) * 1.41421356, 0.0, 1.0);
}

void fragment() {
	float alpha = progress;
	if (mode != 0) {
		float g = gradient_value(UV);
		if (invert) {
			g = 1.0 - g;
		}
		float w = max(width, 0.001);
		// Progresso local do ponto: começa em g * (1 - w) e termina w depois (sempre 1 quando progress = 1).
		float local_progress = clamp((progress - g * (1.0 - w)) / w, 0.0, 1.0);
		float threshold = mode >= 3 ? shape_value(UV) : 0.5;
		float f = max(feathering, 0.0001);
		alpha = smoothstep(threshold, threshold + f, local_progress * (1.0 + f));
	}
	COLOR = vec4(base_color.rgb, base_color.a * alpha * intensity);
}
