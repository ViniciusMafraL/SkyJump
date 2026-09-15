// Fundo de tema: gradiente vertical entre BASE_COLOR (embaixo) e TOP_COLOR (em cima).
// Aplicado ao semicilindro de fundo (ThemeBackground). As cores vêm do ThemeData do tema ativo.
// Unshaded e sem neblina: a cor exibida é exatamente a configurada no tema.
shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, shadows_disabled;

// Cor inferior do cenário.
uniform vec3 base_color : source_color = vec3(1.0);
// Cor superior do cenário.
uniform vec3 top_color : source_color = vec3(0.5);
// Faixa da altura do semicilindro (0 = base, 1 = topo) onde acontece a transição.
uniform float gradient_start : hint_range(0.0, 1.0, 0.01) = 0.2;
uniform float gradient_end : hint_range(0.0, 1.0, 0.01) = 0.8;
// Curva da transição (1 = linear antes da suavização).
uniform float gradient_power : hint_range(0.1, 4.0, 0.05) = 1.0;

void fragment() {
	// UV.y do semicilindro: 0 na base, 1 no topo.
	float t = clamp((UV.y - gradient_start) / max(gradient_end - gradient_start, 0.0001), 0.0, 1.0);
	t = smoothstep(0.0, 1.0, pow(t, gradient_power));
	ALBEDO = mix(base_color, top_color, t);
}
