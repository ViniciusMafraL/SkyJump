class_name VerticalProgressBar
extends Control
## Barra vertical como linha do tempo: a faixa atual (meta anterior -> próxima meta) ocupa a parte
## de cima; as metas já alcançadas ficam comprimidas na parte de baixo. Converte altura em proporção.

var config: ProgressBarConfig

var _previous: float = 0.0
var _next: float = 1000.0
## Alturas da zona passada, da base até a meta anterior (vazio = nenhuma meta alcançada).
var _past_points: Array[float] = []
var _truncated: bool = false
var _fill_ratio: float = 0.0
var _background: StyleBoxFlat


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_milestones(previous: float, next: float, reached: Array[float]) -> void:
	_previous = previous
	_next = next
	_past_points.clear()
	_truncated = false
	if reached.is_empty():
		return
	var shown := mini(reached.size(), config.max_past_milestones_shown)
	var first := reached.size() - shown
	_truncated = first > 0
	_past_points.append(reached[first - 1] if _truncated else 0.0)
	for i in range(first, reached.size()):
		_past_points.append(reached[i])


## Metas que têm estrela na barra: as alcançadas visíveis e a próxima.
func get_visible_milestones() -> Array[float]:
	var result: Array[float] = []
	for i in range(1, _past_points.size()):
		result.append(_past_points[i])
	result.append(_next)
	return result


func ratio_for_height(height: float) -> float:
	if _past_points.is_empty():
		return clampf(height / maxf(_next, 0.001), 0.0, 1.0)
	var past := config.past_zone_fraction
	if height >= _previous:
		return past + (1.0 - past) * clampf((height - _previous) / maxf(_next - _previous, 0.001), 0.0, 1.0)
	if height <= _past_points[0]:
		return 0.0
	var segments := _past_points.size() - 1
	for segment in segments:
		if height <= _past_points[segment + 1]:
			var span := maxf(_past_points[segment + 1] - _past_points[segment], 0.001)
			var t := (height - _past_points[segment]) / span
			return past * (float(segment) + t) / float(segments)
	return past


func is_above_range(height: float) -> bool:
	return height > _next


func line_x() -> float:
	return size.x * 0.5


func y_for_ratio(ratio: float) -> float:
	return size.y * (1.0 - ratio)


func set_fill_ratio(ratio: float) -> void:
	_fill_ratio = ratio
	queue_redraw()


func _draw() -> void:
	if config == null:
		return
	var padding := config.milestone_icon_size
	if _background == null:
		_background = StyleBoxFlat.new()
	_background.bg_color = Color(config.background_color, config.background_opacity)
	_background.set_corner_radius_all(int(size.x * 0.5))
	draw_style_box(_background, Rect2(Vector2(0.0, -padding), Vector2(size.x, size.y + padding * 2.0)))

	var x := line_x()
	draw_line(Vector2(x, 0.0), Vector2(x, size.y), config.line_color, config.progress_width, true)
	draw_line(Vector2(x, size.y), Vector2(x, y_for_ratio(_fill_ratio)), config.progress_color, config.progress_width, true)

	# Base da linha do tempo: 0 m ou "..." quando metas antigas ficaram fora da barra.
	draw_line(Vector2(x - 10.0, size.y), Vector2(x + 10.0, size.y), config.text_color, 3.0, true)
	var base_text := "0 m"
	if _truncated:
		base_text = "... %s" % HeightFormat.meters(_past_points[0])
	var font := config.get_font()
	var text_position := Vector2(x + 16.0, size.y + config.small_font_size * 0.35)
	if config.outline_size > 0:
		draw_string_outline(font, text_position, base_text, HORIZONTAL_ALIGNMENT_LEFT, -1, config.small_font_size, config.outline_size, config.outline_color)
	draw_string(font, text_position, base_text, HORIZONTAL_ALIGNMENT_LEFT, -1, config.small_font_size, Color(config.text_color, 0.75))
