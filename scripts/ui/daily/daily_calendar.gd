class_name DailyCalendar
extends Control
## Tela do Desafio Diário no estilo agenda: mês com os dias, estado e estrelas dos checkpoints de
## cada dia, detalhes do dia selecionado e o botão JOGAR / CONTINUAR. Só consulta e pede ações ao
## DailyChallenge; a troca de cena fica com o menu (sinal play_requested).

signal close_requested
signal play_requested(date: DailyDate)

const MONTH_NAMES := ["JANEIRO", "FEVEREIRO", "MARÇO", "ABRIL", "MAIO", "JUNHO", "JULHO", "AGOSTO", "SETEMBRO", "OUTUBRO", "NOVEMBRO", "DEZEMBRO"]
const WEEKDAY_NAMES := ["SEG", "TER", "QUA", "QUI", "SEX", "SÁB", "DOM"]
const STATE_TEXTS := {
	DailyState.State.FUTURE: "BLOQUEADO",
	DailyState.State.AVAILABLE: "DISPONÍVEL",
	DailyState.State.IN_PROGRESS: "EM ANDAMENTO",
	DailyState.State.COMPLETED: "CONCLUÍDO",
	DailyState.State.RECORD: "RECORDE",
	DailyState.State.ENDED: "ENCERRADO",
	DailyState.State.INVALIDATED: "INDISPONÍVEL",
}

@export_group("Colors")
@export var paper_color: Color = Color(0.96, 0.96, 0.95)
@export var header_color: Color = Color(0.8, 0.1, 0.1)
@export var header_shadow_color: Color = Color(0.55, 0.05, 0.07)
@export var ring_color: Color = Color(0.2, 0.62, 0.7)
@export var ring_hole_color: Color = Color(0.14, 0.14, 0.17)
@export var ink_color: Color = Color(0.36, 0.38, 0.41)
@export var faded_ink_color: Color = Color(0.84, 0.86, 0.88)
@export var grid_line_color: Color = Color(0.76, 0.83, 0.86)
@export var accent_color: Color = Color(0.85, 0.12, 0.12)
@export var star_color: Color = Color(1.0, 0.78, 0.15)
@export var empty_star_color: Color = Color(0.84, 0.87, 0.9)
@export var star_outline_color: Color = Color(0.25, 0.22, 0.2)
@export var completed_cell_color: Color = Color(1.0, 0.95, 0.78)
@export var selected_cell_color: Color = Color(0.86, 0.93, 1.0)

@export_group("Layout")
@export var header_height: float = 250.0
@export var cell_height: float = 104.0
@export var side_margin: float = 24.0

var _view_month: DailyDate
var _selected: DailyDate
var _countdown_timer: float = 0.0

var _header: Control
var _month_label: Label
var _year_label: Label
var _prev_button: Button
var _next_button: Button
var _close_button: Button
var _grid: GridContainer
var _date_label: Label
var _theme_label: Label
var _state_label: Label
var _action_button: Button
var _detail_stars: Array[PixelIcon] = []
var _debug_panel: PanelContainer
var _debug_date_label: Label


func _ready() -> void:
	_build()
	DailyChallenge.daily_updated.connect(func(_date_key: String) -> void: refresh())
	DailyChallenge.day_changed.connect(func(_today: DailyDate) -> void: open())
	visibility_changed.connect(func() -> void:
		if visible:
			open())
	open()


## Mostra o mês atual com o dia de hoje selecionado.
func open() -> void:
	var today := DailyChallenge.get_today()
	_view_month = today.first_of_month()
	_selected = today
	refresh()


func refresh() -> void:
	if _grid == null or _view_month == null:
		return
	_month_label.text = MONTH_NAMES[_view_month.month - 1]
	_year_label.text = str(_view_month.year)
	_set_button_enabled(_prev_button, _can_view(_view_month.add_months(-1)))
	_set_button_enabled(_next_button, _can_view(_view_month.add_months(1)))
	_rebuild_grid()
	_refresh_detail()
	_refresh_debug()


func select_date(date: DailyDate) -> void:
	_selected = date
	refresh()


func show_previous_month() -> void:
	_change_month(-1)


func show_next_month() -> void:
	_change_month(1)


func get_view_month() -> DailyDate:
	return _view_month


func get_selected_date() -> DailyDate:
	return _selected


func get_cells() -> Array[DailyDayCell]:
	var cells: Array[DailyDayCell] = []
	for child in _grid.get_children():
		if child is DailyDayCell:
			cells.append(child)
	return cells


func get_action_button() -> Button:
	return _action_button


static func format_countdown(seconds: int) -> String:
	var days := floori(seconds / 86400.0)
	var rest := seconds - days * 86400
	var clock := "%02d:%02d:%02d" % [floori(rest / 3600.0), floori((rest % 3600) / 60.0), rest % 60]
	return "%dD %s" % [days, clock] if days > 0 else clock


func _process(delta: float) -> void:
	if not visible or _selected == null or _action_button == null:
		return
	_countdown_timer -= delta
	if _countdown_timer > 0.0:
		return
	_countdown_timer = 0.5
	var info := DailyChallenge.get_daily(_selected)
	if info.state == DailyState.State.FUTURE:
		_action_button.text = _action_text(info)


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"ui_cancel"):
		close_requested.emit()
		get_viewport().set_input_as_handled()


func _change_month(amount: int) -> void:
	var target := _view_month.add_months(amount)
	if not _can_view(target):
		return
	_view_month = target
	var today := DailyChallenge.get_today()
	_selected = today if today.year == target.year and today.month == target.month else target
	refresh()


## Meses visíveis: do mês atual até `months_back` meses atrás (dias futuros ficam bloqueados).
func _can_view(month_start: DailyDate) -> bool:
	var today := DailyChallenge.get_today()
	var difference := (month_start.year - today.year) * 12 + month_start.month - today.month
	return difference <= 0 and difference >= -DailyChallenge.config.months_back


func _rebuild_grid() -> void:
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	var today := DailyChallenge.get_today()
	for i in _view_month.weekday():
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(0.0, cell_height)
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_grid.add_child(spacer)
	for day in DailyDate.days_in_month(_view_month.year, _view_month.month):
		var date := DailyDate.create(_view_month.year, _view_month.month, day + 1)
		var cell := DailyDayCell.new()
		cell.custom_minimum_size = Vector2(0.0, cell_height)
		cell.ink_color = ink_color
		cell.faded_ink_color = faded_ink_color
		cell.grid_line_color = grid_line_color
		cell.accent_color = accent_color
		cell.star_color = star_color
		cell.empty_star_color = empty_star_color
		cell.outline_color = star_outline_color
		cell.completed_cell_color = completed_cell_color
		cell.selected_cell_color = selected_cell_color
		cell.set_data(DailyChallenge.get_daily(date), date.equals(today), date.equals(_selected))
		cell.pressed.connect(select_date)
		_grid.add_child(cell)


func _refresh_detail() -> void:
	var info := DailyChallenge.get_daily(_selected)
	_date_label.text = "%d DE %s" % [_selected.day, MONTH_NAMES[_selected.month - 1]]
	var future := info.state == DailyState.State.FUTURE
	_theme_label.text = "TEMA: ???" if future else "TEMA: %s" % info.theme_name.to_upper()
	var collected := info.get_collected_count()
	for i in _detail_stars.size():
		if i < collected:
			_detail_stars[i].set_colors(star_color, star_outline_color)
		else:
			_detail_stars[i].set_colors(empty_star_color, grid_line_color)
	_state_label.text = STATE_TEXTS.get(info.state, "")
	_action_button.disabled = not DailyState.is_playable(info.state)
	_action_button.text = _action_text(info)


func _action_text(info: DailyInfo) -> String:
	match info.state:
		DailyState.State.AVAILABLE:
			return "JOGAR"
		DailyState.State.IN_PROGRESS:
			return "CONTINUAR"
		DailyState.State.COMPLETED:
			return "CONCLUÍDO"
		DailyState.State.FUTURE:
			return "DISPONÍVEL EM %s" % format_countdown(DailyChallenge.dates.seconds_until(info.date))
		DailyState.State.ENDED:
			return "ENCERRADO"
	return "INDISPONÍVEL"


func _on_action_pressed() -> void:
	if DailyChallenge.can_play(_selected):
		play_requested.emit(_selected)


# ---------------------------------------------------------------- Construção da interface

func _build() -> void:
	var background := ColorRect.new()
	background.color = paper_color
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var safe := SafeAreaOffsets.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)
	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override(&"separation", 12)
	safe.add_child(layout)
	layout.add_child(_build_header())
	layout.add_child(_margin(_build_weekdays()))
	_grid = GridContainer.new()
	_grid.columns = 7
	_grid.add_theme_constant_override(&"h_separation", 0)
	_grid.add_theme_constant_override(&"v_separation", 0)
	layout.add_child(_margin(_grid))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layout.add_child(spacer)
	layout.add_child(_margin(_build_detail(), 28.0))
	_debug_panel = _build_debug_panel()
	add_child(_debug_panel)


func _build_header() -> Control:
	_header = Control.new()
	_header.custom_minimum_size = Vector2(0.0, header_height)
	_header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_header.draw.connect(_draw_header)
	_header.resized.connect(_header.queue_redraw)

	_close_button = _icon_button(PixelIcon.Icon.CLOSE)
	_close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_close_button.offset_left = -112.0
	_close_button.offset_right = -24.0
	_close_button.offset_top = 44.0
	_close_button.offset_bottom = 116.0
	_close_button.pressed.connect(close_requested.emit)
	_header.add_child(_close_button)

	if DailyChallenge.is_debug_available():
		var debug_button := Button.new()
		debug_button.text = "DEV"
		debug_button.focus_mode = Control.FOCUS_NONE
		debug_button.add_theme_font_size_override(&"font_size", 24)
		debug_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
		debug_button.offset_left = 24.0
		debug_button.offset_right = 124.0
		debug_button.offset_top = 44.0
		debug_button.offset_bottom = 116.0
		debug_button.pressed.connect(func() -> void:
			_debug_panel.visible = not _debug_panel.visible
			_refresh_debug())
		_header.add_child(debug_button)

	var month_row := HBoxContainer.new()
	month_row.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	month_row.offset_left = side_margin
	month_row.offset_right = -side_margin
	month_row.offset_top = -134.0
	month_row.offset_bottom = -18.0
	month_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_header.add_child(month_row)
	_prev_button = _icon_button(PixelIcon.Icon.ARROW_LEFT)
	_prev_button.pressed.connect(show_previous_month)
	month_row.add_child(_prev_button)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	titles.alignment = BoxContainer.ALIGNMENT_CENTER
	titles.add_theme_constant_override(&"separation", -6)
	titles.mouse_filter = Control.MOUSE_FILTER_IGNORE
	month_row.add_child(titles)
	_month_label = _label(66, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 14)
	titles.add_child(_month_label)
	_year_label = _label(26, Color(1.0, 0.86, 0.86), HORIZONTAL_ALIGNMENT_CENTER, 6)
	titles.add_child(_year_label)
	_next_button = _icon_button(PixelIcon.Icon.ARROW_RIGHT)
	_next_button.pressed.connect(show_next_month)
	month_row.add_child(_next_button)
	return _header


## Faixa vermelha da capa com as argolas da agenda.
func _draw_header() -> void:
	var width := _header.size.x
	var height := _header.size.y
	_header.draw_rect(Rect2(0.0, 36.0, width, height - 36.0), header_color)
	_header.draw_rect(Rect2(0.0, height - 10.0, width, 10.0), header_shadow_color)
	var rings := 7
	var spacing := width * 0.085
	var start := width * 0.5 - spacing * (rings - 1) * 0.5
	for i in rings:
		var x := start + spacing * i
		_header.draw_rect(Rect2(x - 22.0, 58.0, 44.0, 22.0), ring_hole_color)
		_header.draw_rect(Rect2(x - 12.0, 0.0, 24.0, 64.0), ring_color)
		_header.draw_rect(Rect2(x - 12.0, 50.0, 24.0, 14.0), ring_color.darkened(0.4))


func _build_weekdays() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for weekday_name in WEEKDAY_NAMES:
		var label := _label(26, ink_color.lerp(faded_ink_color, 0.35), HORIZONTAL_ALIGNMENT_CENTER, 0)
		label.text = weekday_name
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)
	return row


func _build_detail() -> Control:
	var panel := VBoxContainer.new()
	panel.add_theme_constant_override(&"separation", 12)
	var top := HBoxContainer.new()
	panel.add_child(top)
	_date_label = _label(40, ink_color, HORIZONTAL_ALIGNMENT_LEFT, 0)
	_date_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(_date_label)
	_theme_label = _label(28, accent_color, HORIZONTAL_ALIGNMENT_RIGHT, 0)
	top.add_child(_theme_label)

	var middle := HBoxContainer.new()
	middle.add_theme_constant_override(&"separation", 8)
	panel.add_child(middle)
	for i in DailyProgress.CHECKPOINT_COUNT:
		var star := PixelIcon.new()
		star.icon = PixelIcon.Icon.STAR
		star.custom_minimum_size = Vector2(60.0, 60.0)
		_detail_stars.append(star)
		middle.add_child(star)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	middle.add_child(gap)
	_state_label = _label(30, ink_color, HORIZONTAL_ALIGNMENT_RIGHT, 0)
	_state_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	middle.add_child(_state_label)

	_action_button = Button.new()
	_action_button.custom_minimum_size = Vector2(0.0, 104.0)
	_action_button.focus_mode = Control.FOCUS_NONE
	_action_button.add_theme_font_size_override(&"font_size", 42)
	_action_button.add_theme_color_override(&"font_color", Color.WHITE)
	_action_button.add_theme_color_override(&"font_disabled_color", Color(1.0, 1.0, 1.0, 0.85))
	_action_button.add_theme_stylebox_override(&"normal", _box_style(accent_color))
	_action_button.add_theme_stylebox_override(&"hover", _box_style(accent_color.lightened(0.12)))
	_action_button.add_theme_stylebox_override(&"pressed", _box_style(accent_color.darkened(0.2)))
	_action_button.add_theme_stylebox_override(&"disabled", _box_style(ink_color.lerp(faded_ink_color, 0.45)))
	_action_button.pressed.connect(_on_action_pressed)
	panel.add_child(_action_button)

	var bottom := HBoxContainer.new()
	panel.add_child(bottom)
	var counter := StarCounter.new()
	bottom.add_child(counter)
	var bottom_gap := Control.new()
	bottom_gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(bottom_gap)
	var streak := StreakBadge.new()
	streak.font_size = 26
	bottom.add_child(streak)
	return panel


func _build_debug_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.visible = false
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -320.0
	panel.offset_right = 320.0
	panel.offset_top = -340.0
	panel.offset_bottom = 340.0
	var style := _box_style(Color(0.08, 0.1, 0.16, 0.96))
	style.content_margin_left = 20.0
	style.content_margin_right = 20.0
	style.content_margin_top = 16.0
	style.content_margin_bottom = 16.0
	panel.add_theme_stylebox_override(&"panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 10)
	panel.add_child(box)
	var title := _label(30, Color(1.0, 0.82, 0.35), HORIZONTAL_ALIGNMENT_CENTER, 0)
	title.text = "DEBUG DE DATA"
	box.add_child(title)
	_debug_date_label = _label(22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, 0)
	_debug_date_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_debug_date_label)
	var buttons := GridContainer.new()
	buttons.columns = 2
	buttons.add_theme_constant_override(&"h_separation", 8)
	buttons.add_theme_constant_override(&"v_separation", 8)
	box.add_child(buttons)
	var actions := [
		["-1 DIA", func() -> void: DailyChallenge.debug_advance_days(-1)],
		["+1 DIA", func() -> void: DailyChallenge.debug_advance_days(1)],
		["+7 DIAS", func() -> void: DailyChallenge.debug_advance_days(7)],
		["+1 MÊS", func() -> void: DailyChallenge.debug_advance_months(1)],
		["+1 ANO", func() -> void: DailyChallenge.debug_advance_months(12)],
		["DATA REAL", func() -> void: DailyChallenge.debug_use_real_date()],
		["+ CHECKPOINT", func() -> void: DailyChallenge.debug_collect_next_checkpoint(_selected)],
		["RESET DIA", func() -> void: DailyChallenge.debug_reset_daily(_selected)],
		["RESET TUDO", func() -> void: DailyChallenge.debug_reset_all()],
		["FECHAR", func() -> void: _debug_panel.visible = false],
	]
	for action in actions:
		var button := Button.new()
		button.text = action[0]
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0.0, 64.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override(&"font_size", 24)
		var callback: Callable = action[1]
		button.pressed.connect(func() -> void:
			callback.call()
			refresh())
		buttons.add_child(button)
	return panel


func _refresh_debug() -> void:
	if _debug_date_label == null or not _debug_panel.visible:
		return
	var today := DailyChallenge.get_today()
	var info := DailyChallenge.get_daily(_selected)
	var week := today.iso_week()
	_debug_date_label.text = "Hoje: %s %s(semana %d-W%02d)\nSelecionado: %s  seed %d  tema %s  estado %s\nEstrelas %d  sequência %d / melhor %d" % [
		today.to_key(), "SIMULADO " if DailyChallenge.dates.is_simulating() else "", week.x, week.y,
		_selected.to_key(), info.seed, info.theme_name, DailyState.name_of(info.state),
		DailyChallenge.get_stars(), DailyChallenge.get_streak().x, DailyChallenge.get_streak().y]


func _icon_button(which: PixelIcon.Icon) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(88.0, 88.0)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_stylebox_override(&"normal", _box_style(Color(0.0, 0.0, 0.0, 0.22)))
	button.add_theme_stylebox_override(&"hover", _box_style(Color(0.0, 0.0, 0.0, 0.32)))
	button.add_theme_stylebox_override(&"pressed", _box_style(Color(0.0, 0.0, 0.0, 0.45)))
	button.add_theme_stylebox_override(&"disabled", _box_style(Color(0.0, 0.0, 0.0, 0.0)))
	var glyph := PixelIcon.new()
	glyph.icon = which
	glyph.set_colors(Color.WHITE, Color(0.1, 0.1, 0.12))
	glyph.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 16)
	button.add_child(glyph)
	return button


func _set_button_enabled(button: Button, enabled: bool) -> void:
	button.disabled = not enabled
	button.modulate.a = 1.0 if enabled else 0.3


func _label(font_size: int, color: Color, alignment: HorizontalAlignment, outline: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", color)
	if outline > 0:
		label.add_theme_color_override(&"font_outline_color", Color(0.25, 0.03, 0.05))
		label.add_theme_constant_override(&"outline_size", outline)
	return label


func _margin(content: Control, bottom: float = 0.0) -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override(&"margin_left", int(side_margin))
	margin.add_theme_constant_override(&"margin_right", int(side_margin))
	margin.add_theme_constant_override(&"margin_bottom", int(bottom))
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(content)
	return margin


func _box_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(14)
	return style
