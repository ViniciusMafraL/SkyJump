class_name RecordMarker
extends ProgressBarMarker
## Recorde pessoal: seta laranja à esquerda da linha. Quando o recorde está acima da faixa visível,
## fica preso no topo apontando para cima (o valor aparece no texto RECORDE abaixo da barra).

var above: bool = false


func set_above(is_above: bool) -> void:
	above = is_above


func _draw() -> void:
	var size_px := config.record_marker_size
	var color := config.record_color
	if config.record_icon_texture:
		draw_texture_rect(config.record_icon_texture, Rect2(Vector2(-4.0 - size_px * 1.5, -size_px * 0.75), Vector2.ONE * size_px * 1.5), false, color)
		return
	var shape: PackedVector2Array
	if above:
		var center_x := -4.0 - size_px * 0.7
		shape = PackedVector2Array([Vector2(center_x, -size_px), Vector2(center_x + size_px * 0.7, 0.0), Vector2(center_x - size_px * 0.7, 0.0)])
	else:
		shape = PackedVector2Array([Vector2(-4.0, 0.0), Vector2(-4.0 - size_px, -size_px * 0.6), Vector2(-4.0 - size_px, size_px * 0.6)])
		draw_line(Vector2(-4.0, 0.0), Vector2(10.0, 0.0), color, 3.0, true)
	var outline := shape.duplicate()
	outline.append(shape[0])
	draw_colored_polygon(shape, color)
	draw_polyline(outline, config.outline_color, 2.0, true)
