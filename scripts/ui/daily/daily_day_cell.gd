class_name DailyDayCell
extends Control
## Um dia do calendário do Desafio Diário: número, estado (cadeado nos dias futuros), as medalhas
## coletadas no dia (bronze, prata, estrela) e o círculo vermelho no dia atual.
## Só desenha o DailyInfo recebido; a lógica de estado fica no DailyChallenge.

signal pressed(date: DailyDate)

var info: DailyInfo
var is_today: bool = false
var selected: bool = false
## Ícone de cada checkpoint, na ordem (vem do calendário).
var medal_icons: Array[Texture2D] = []


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
	# Antes do primeiro layout a célula ainda não tem tamanho.
	if info == null or size.x < 8.0 or size.y < 8.0:
		return
	var rect := Rect2(Vector2.ZERO, size)
	if selected:
		var highlight := StyleBoxFlat.new()
		highlight.bg_color = Color(SkyJumpColors.YELLOW, 0.28)
		highlight.border_color = SkyJumpColors.YELLOW
		highlight.set_border_width_all(3)
		highlight.set_corner_radius_all(10)
		highlight.anti_aliasing = true
		highlight.draw(get_canvas_item(), rect.grow(-4.0))
	draw_rect(rect, SkyJumpColors.GRID_LINE, false, 2.0)

	var font := get_theme_default_font()
	var font_size := int(minf(size.y * 0.4, size.x * 0.44))
	var number := str(info.date.day)
	var number_color := SkyJumpColors.INK
	match info.state:
		DailyState.State.FUTURE:
			number_color = SkyJumpColors.INK_FADED
		DailyState.State.ENDED, DailyState.State.INVALIDATED:
			number_color = SkyJumpColors.INK.lerp(SkyJumpColors.INK_FADED, 0.5)
	var text_size := font.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var baseline := size.y * 0.5 + font.get_ascent(font_size) * 0.5 - size.y * 0.12
	draw_string(font, Vector2((size.x - text_size.x) * 0.5, baseline), number, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, number_color)

	var icon_area := Rect2(size.x * 0.03, size.y * 0.6, size.x * 0.94, size.y * 0.32)
	if info.state == DailyState.State.FUTURE:
		var side := icon_area.size.y * 0.8
		UiGlyph.draw_glyph(self, UiGlyph.Glyph.LOCK, Rect2(icon_area.get_center() - Vector2(side, side) * 0.5, Vector2(side, side)), SkyJumpColors.INK_FADED, Color(0.0, 0.0, 0.0, 0.0))
	elif info.progress:
		_draw_medals(icon_area)

	if is_today:
		draw_arc(size * 0.5 + Vector2(0.0, 1.0), minf(size.x, size.y) * 0.46, 0.0, TAU, 48, SkyJumpColors.RED, 4.0, true)


func _draw_medals(area: Rect2) -> void:
	var count := medal_icons.size()
	if count == 0:
		return
	# Medalhas levemente sobrepostas, como as estrelas do mockup.
	var slot := minf(area.size.x / (count * 0.82 + 0.18), area.size.y)
	var step := slot * 0.82
	var start := area.get_center() - Vector2((step * (count - 1) + slot) * 0.5, slot * 0.5)
	for i in count:
		var slot_rect := Rect2(start + Vector2(step * i, 0.0), Vector2(slot, slot))
		var tint := Color.WHITE if info.progress.has_checkpoint(i) else Color(1.0, 1.0, 1.0, 0.18)
		draw_texture_rect(medal_icons[i], UiIcons.fit_rect(medal_icons[i], slot_rect), false, tint)
