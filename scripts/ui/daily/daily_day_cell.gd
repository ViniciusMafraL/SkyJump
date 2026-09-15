class_name DailyDayCell
extends Control
## Um dia do calendário do Desafio Diário: número, estado (cadeado, jogar, estrelas dos checkpoints)
## e o círculo vermelho "à mão" no dia atual, como numa agenda de papel.

signal pressed(date: DailyDate)

var info: DailyInfo
var is_today: bool = false
var selected: bool = false

var ink_color: Color = Color(0.36, 0.38, 0.41)
var faded_ink_color: Color = Color(0.84, 0.86, 0.88)
var grid_line_color: Color = Color(0.76, 0.83, 0.86)
var accent_color: Color = Color(0.85, 0.12, 0.12)
var star_color: Color = Color(1.0, 0.78, 0.15)
var empty_star_color: Color = Color(0.84, 0.87, 0.9)
var outline_color: Color = Color(0.25, 0.22, 0.2)
var completed_cell_color: Color = Color(1.0, 0.95, 0.78)
var selected_cell_color: Color = Color(0.86, 0.93, 1.0)


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	size_flags_horizontal = Control.SIZE_EXPAND_FILL


func set_data(daily_info: DailyInfo, today: bool, is_selected: bool) -> void:
	info = daily_info
	is_today = today
	selected = is_selected
	queue_redraw()


func get_date() -> DailyDate:
	return info.date if info else null


func _gui_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse and mouse.button_index == MOUSE_BUTTON_LEFT and not mouse.pressed and Rect2(Vector2.ZERO, size).has_point(mouse.position):
		pressed.emit(info.date)
		accept_event()


func _draw() -> void:
	if info == null:
		return
	var rect := Rect2(Vector2.ZERO, size)
	if info.state == DailyState.State.COMPLETED:
		draw_rect(rect.grow(-2.0), completed_cell_color)
	elif selected:
		draw_rect(rect.grow(-2.0), selected_cell_color)
	draw_rect(rect, grid_line_color, false, 3.0)
	if selected:
		draw_rect(rect.grow(-5.0), accent_color.lerp(Color.WHITE, 0.45), false, 3.0)

	var font := get_theme_default_font()
	var font_size := int(minf(size.y * 0.38, size.x * 0.46))
	var number := str(info.date.day)
	var number_color := ink_color
	match info.state:
		DailyState.State.FUTURE:
			number_color = faded_ink_color
		DailyState.State.ENDED, DailyState.State.INVALIDATED:
			number_color = ink_color.lerp(faded_ink_color, 0.55)
	var text_width := font.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, Vector2((size.x - text_width) * 0.5, size.y * 0.47), number, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, number_color)

	var icon_area := Rect2(size.x * 0.06, size.y * 0.58, size.x * 0.88, size.y * 0.3)
	match info.state:
		DailyState.State.FUTURE:
			PixelIcon.draw_icon(self, PixelIcon.Icon.LOCK, _square(icon_area, 0.85), faded_ink_color, Color(0.0, 0.0, 0.0, 0.0))
		DailyState.State.AVAILABLE:
			PixelIcon.draw_icon(self, PixelIcon.Icon.PLAY, _square(icon_area, 0.9), accent_color, outline_color)
		_:
			if info.progress:
				_draw_mini_stars(icon_area)

	if is_today:
		draw_arc(size * 0.5 + Vector2(-1.5, 2.0), minf(size.x, size.y) * 0.52, deg_to_rad(-70.0), deg_to_rad(255.0), 48, accent_color, 5.0, true)


func _draw_mini_stars(area: Rect2) -> void:
	var collected := info.get_collected_count()
	var star := minf(area.size.x / 3.0, area.size.y)
	var start := area.get_center() - Vector2(star * 1.5, star * 0.5)
	for i in DailyProgress.CHECKPOINT_COUNT:
		var star_rect := Rect2(start + Vector2(star * i, 0.0), Vector2(star, star))
		if i < collected:
			PixelIcon.draw_icon(self, PixelIcon.Icon.STAR, star_rect, star_color, outline_color)
		else:
			PixelIcon.draw_icon(self, PixelIcon.Icon.STAR, star_rect, empty_star_color, Color(0.0, 0.0, 0.0, 0.0))


func _square(area: Rect2, scale_factor: float) -> Rect2:
	var side := minf(area.size.x, area.size.y) * scale_factor
	return Rect2(area.get_center() - Vector2(side, side) * 0.5, Vector2(side, side))
