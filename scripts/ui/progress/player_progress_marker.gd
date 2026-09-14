class_name PlayerProgressMarker
extends ProgressBarMarker
## Marcador do jogador: círculo com a cor (ou ícone) da skin atual, seta apontando para ele e altura.

var color: Color = Color.WHITE
var icon: Texture2D
var height_m: float = 0.0
var simulating: bool = false


func set_skin_visual(skin_color: Color, skin_icon: Texture2D) -> void:
	color = skin_color
	icon = skin_icon


func set_height(meters: float, is_simulating: bool) -> void:
	height_m = meters
	simulating = is_simulating


func _draw() -> void:
	var radius := config.player_icon_size * 0.5
	draw_circle(Vector2.ZERO, radius + 3.0, config.outline_color)
	if icon:
		draw_texture_rect(icon, Rect2(-Vector2.ONE * radius, Vector2.ONE * radius * 2.0), false)
	else:
		draw_circle(Vector2.ZERO, radius, color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, config.text_color, 2.0, true)

	# Seta à direita apontando para o jogador.
	var tip := Vector2(radius + 6.0, 0.0)
	var arrow := PackedVector2Array([tip, tip + Vector2(14.0, -9.0), tip + Vector2(14.0, 9.0)])
	draw_colored_polygon(arrow, config.text_color)

	var text := HeightFormat.meters(height_m)
	if simulating:
		text += " (SIM)"
	_draw_text(text, Vector2(radius + 26.0, config.font_size * 0.35), config.font_size, config.text_color)
