class_name SafeAreaMargins
extends RefCounted
## Margens da área segura do aparelho (notch, câmera, bordas arredondadas) em coordenadas do viewport.

## Margens forçadas [esquerda, cima, direita, baixo] para simular um aparelho com notch no PC.
## Vazio = usa o aparelho real.
static var debug_margins: PackedFloat32Array = PackedFloat32Array()


## Retorna [esquerda, cima, direita, baixo], cada uma limitada a max_ratio do tamanho do viewport.
static func compute(viewport_size: Vector2, max_ratio: float) -> PackedFloat32Array:
	if debug_margins.size() == 4:
		return debug_margins
	var margins := PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
	# Janelas de desktop não têm notch; a área útil do monitor geraria margens falsas
	# quando a janela é maior que a tela.
	if not OS.has_feature("mobile"):
		return margins
	var window_size := Vector2(DisplayServer.window_get_size())
	var safe_rect := Rect2(DisplayServer.get_display_safe_area())
	if window_size.x <= 0.0 or window_size.y <= 0.0 or safe_rect.size.x <= 0.0:
		return margins
	var window_rect := Rect2(Vector2(DisplayServer.window_get_position()), window_size)
	var to_viewport := viewport_size / window_size
	var limit := viewport_size * max_ratio
	margins[0] = minf(maxf(safe_rect.position.x - window_rect.position.x, 0.0) * to_viewport.x, limit.x)
	margins[1] = minf(maxf(safe_rect.position.y - window_rect.position.y, 0.0) * to_viewport.y, limit.y)
	margins[2] = minf(maxf(window_rect.end.x - safe_rect.end.x, 0.0) * to_viewport.x, limit.x)
	margins[3] = minf(maxf(window_rect.end.y - safe_rect.end.y, 0.0) * to_viewport.y, limit.y)
	return margins
