@tool
class_name UiGlyph
extends Control
## Ícones simples da UI que não têm arquivo de arte (setas, fechar, cadeado, pausa, play), desenhados
## por vetor no estilo dos mockups: preenchimento chapado com contorno preto arredondado.
## Estrela, bronze, prata e chama usam os PNGs de art/icons (UiIcons).

enum Glyph { ARROW_LEFT, ARROW_RIGHT, CLOSE, LOCK, PAUSE, PLAY }

@export var glyph: Glyph = Glyph.ARROW_RIGHT:
	set(value):
		glyph = value
		queue_redraw()
@export var fill_color: Color = SkyJumpColors.WHITE:
	set(value):
		fill_color = value
		queue_redraw()
## Transparente = sem contorno.
@export var outline_color: Color = SkyJumpColors.BLACK:
	set(value):
		outline_color = value
		queue_redraw()
## Espessura do contorno em fração do lado do ícone.
@export_range(0.0, 0.25, 0.005) var outline_ratio: float = 0.07:
	set(value):
		outline_ratio = value
		queue_redraw()


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	draw_glyph(self, glyph, Rect2(Vector2.ZERO, size), fill_color, outline_color, outline_ratio)


func set_colors(fill: Color, outline: Color) -> void:
	fill_color = fill
	outline_color = outline


## Cria um glyph que ocupa o botão inteiro com margem (setas/fechar em GlyphButton).
static func fill_button(button: Button, which: Glyph, margin: float = 12.0) -> UiGlyph:
	var icon := UiGlyph.new()
	icon.glyph = which
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = margin
	icon.offset_top = margin
	icon.offset_right = -margin
	icon.offset_bottom = -margin
	button.add_child(icon)
	return icon


static func draw_glyph(canvas: CanvasItem, which: Glyph, rect: Rect2, fill: Color, outline: Color, ratio: float = 0.07) -> void:
	var side := minf(rect.size.x, rect.size.y)
	if side <= 0.0:
		return
	var box := Rect2(rect.get_center() - Vector2(side, side) * 0.5, Vector2(side, side))
	var line := maxf(side * ratio, 1.0)
	var at := func(x: float, y: float) -> Vector2: return box.position + Vector2(x, y) * side
	match which:
		Glyph.ARROW_LEFT:
			_triangle(canvas, PackedVector2Array([at.call(0.78, 0.14), at.call(0.78, 0.86), at.call(0.16, 0.5)]), fill, outline, line)
		Glyph.ARROW_RIGHT, Glyph.PLAY:
			_triangle(canvas, PackedVector2Array([at.call(0.22, 0.14), at.call(0.84, 0.5), at.call(0.22, 0.86)]), fill, outline, line)
		Glyph.CLOSE:
			var stroke := side * 0.16
			for segment in [[at.call(0.2, 0.2), at.call(0.8, 0.8)], [at.call(0.8, 0.2), at.call(0.2, 0.8)]]:
				_stroke(canvas, segment[0], segment[1], stroke + line * 2.0, outline)
			for segment in [[at.call(0.2, 0.2), at.call(0.8, 0.8)], [at.call(0.8, 0.2), at.call(0.2, 0.8)]]:
				_stroke(canvas, segment[0], segment[1], stroke, fill)
		Glyph.PAUSE:
			_rounded_rect(canvas, Rect2(at.call(0.2, 0.14), Vector2(0.22, 0.72) * side), fill, outline, line)
			_rounded_rect(canvas, Rect2(at.call(0.58, 0.14), Vector2(0.22, 0.72) * side), fill, outline, line)
		Glyph.LOCK:
			var shackle_center: Vector2 = at.call(0.5, 0.42)
			var radius := side * 0.2
			canvas.draw_arc(shackle_center, radius, PI, TAU, 20, outline, side * 0.12 + line * 2.0, true)
			canvas.draw_arc(shackle_center, radius, PI, TAU, 20, fill, side * 0.12, true)
			_rounded_rect(canvas, Rect2(at.call(0.18, 0.42), Vector2(0.64, 0.46) * side), fill, outline, line)


static func _triangle(canvas: CanvasItem, points: PackedVector2Array, fill: Color, outline: Color, line: float) -> void:
	if outline.a > 0.0:
		var closed := points.duplicate()
		closed.append(points[0])
		canvas.draw_polyline(closed, outline, line * 2.0, true)
		for point in points:
			canvas.draw_circle(point, line, outline, true, -1.0, true)
	canvas.draw_colored_polygon(points, fill)


static func _stroke(canvas: CanvasItem, from: Vector2, to: Vector2, width: float, color: Color) -> void:
	if color.a <= 0.0:
		return
	canvas.draw_line(from, to, color, width, true)
	canvas.draw_circle(from, width * 0.5, color, true, -1.0, true)
	canvas.draw_circle(to, width * 0.5, color, true, -1.0, true)


static func _rounded_rect(canvas: CanvasItem, rect: Rect2, fill: Color, outline: Color, line: float) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.set_corner_radius_all(int(minf(rect.size.x, rect.size.y) * 0.3))
	if outline.a > 0.0:
		box.border_color = outline
		box.set_border_width_all(int(ceilf(line)))
		box.expand_margin_left = line
		box.expand_margin_right = line
		box.expand_margin_top = line
		box.expand_margin_bottom = line
	box.anti_aliasing = true
	box.draw(canvas.get_canvas_item(), rect)
