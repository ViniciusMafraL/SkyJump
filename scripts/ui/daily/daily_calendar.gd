class_name DailyCalendar
extends Control
## Tela do Desafio Diário (Day) no estilo agenda: mês com os dias, estado e medalhas de cada dia,
## sequência, data e tema do dia selecionado e o botão Play / Continue.
## A estrutura visual fica na cena; este script só preenche os dados e pede ações ao DailyChallenge.
## A troca de cena fica com o menu (sinal play_requested).

signal close_requested
signal play_requested(date: DailyDate)

const MONTH_NAMES := ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
const WEEKDAY_NAMES := ["SEG", "TER", "QUA", "QUI", "SEX", "SÁB", "DOM"]

## Altura mínima da célula; as linhas crescem com o espaço livre da tela.
@export var cell_height: float = 80.0
@export var medal_icon_size: float = 52.0
## Fonte menor no botão durante a contagem regressiva ("Available in 2d 07:20:45").
@export var countdown_font_size: int = 36
@export var theme_text: String = "Theme: %s"
@export var hidden_theme_text: String = "Theme: ???"
## Alfa das medalhas ainda não coletadas.
@export_range(0.0, 1.0, 0.01) var missing_medal_alpha: float = 0.25

var _view_month: DailyDate
var _selected: DailyDate
var _countdown_timer: float = 0.0
var _medal_textures: Array[Texture2D] = []
var _medal_icons: Array[TextureRect] = []
var _debug_panel: PanelContainer
var _debug_date_label: Label

@onready var _month_label: Label = %MonthLabel
@onready var _year_label: Label = %YearLabel
@onready var _prev_button: Button = %PreviousButton
@onready var _next_button: Button = %NextButton
@onready var _close_button: Button = %CloseButton
@onready var _dev_button: Button = %DevButton
@onready var _weekday_row: HBoxContainer = %WeekdayRow
@onready var _grid: GridContainer = %Grid
@onready var _date_label: Label = %DateLabel
@onready var _theme_label: Label = %ThemeLabel
@onready var _medal_row: HBoxContainer = %MedalRow
@onready var _action_button: Button = %ActionButton


func _ready() -> void:
	UiGlyph.fill_button(_prev_button, UiGlyph.Glyph.ARROW_LEFT, 18.0)
	UiGlyph.fill_button(_next_button, UiGlyph.Glyph.ARROW_RIGHT, 18.0)
	UiGlyph.fill_button(_close_button, UiGlyph.Glyph.CLOSE, 18.0)
	_prev_button.pressed.connect(show_previous_month)
	_next_button.pressed.connect(show_next_month)
	_close_button.pressed.connect(close_requested.emit)
	_action_button.pressed.connect(_on_action_pressed)
	# O texto nunca alarga o botão (e o papel) além da tela.
	_action_button.clip_text = true
	_action_button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_build_weekdays()
	_build_medals()
	_dev_button.visible = DailyChallenge.is_debug_available()
	if _dev_button.visible:
		_debug_panel = _build_debug_panel()
		add_child(_debug_panel)
		_dev_button.pressed.connect(func() -> void:
			_debug_panel.visible = not _debug_panel.visible
			_refresh_debug())
	UiFeedback.attach_all(self)
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
	if _view_month == null:
		return
	_month_label.text = MONTH_NAMES[_view_month.month - 1]
	_year_label.text = str(_view_month.year)
	_set_arrow_enabled(_prev_button, _can_view(_view_month.add_months(-1)))
	_set_arrow_enabled(_next_button, _can_view(_view_month.add_months(1)))
	_rebuild_grid()
	_refresh_detail()
	_refresh_debug()


func select_date(date: DailyDate) -> void:
	if date == null:
		return
	_selected = date
	if date.year != _view_month.year or date.month != _view_month.month:
		_view_month = date.first_of_month()
		refresh()
		return
	var today := DailyChallenge.get_today()
	for cell in get_cells():
		var is_selected := cell.get_date().equals(date)
		cell.set_data(cell.info, cell.get_date().equals(today), is_selected)
		if is_selected and cell.is_inside_tree():
			UiFeedback.pop(cell, 1.08)
	_refresh_detail()
	_refresh_debug()


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
		if child is DailyDayCell and not child.is_queued_for_deletion():
			cells.append(child)
	return cells


func get_action_button() -> Button:
	return _action_button


## "15 September | Theme: Jungle"
func get_detail_text() -> String:
	return "%s | %s" % [_date_label.text, _theme_label.text]


static func format_countdown(seconds: int) -> String:
	var days := floori(seconds / 86400.0)
	var rest := seconds - days * 86400
	var clock := "%02d:%02d:%02d" % [floori(rest / 3600.0), floori((rest % 3600) / 60.0), rest % 60]
	return "%dd %s" % [days, clock] if days > 0 else clock


func _process(delta: float) -> void:
	if not visible or _selected == null:
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
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_grid.add_child(spacer)
	for day in DailyDate.days_in_month(_view_month.year, _view_month.month):
		var date := DailyDate.create(_view_month.year, _view_month.month, day + 1)
		var cell := DailyDayCell.new()
		cell.custom_minimum_size = Vector2(0.0, cell_height)
		cell.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cell.medal_icons = _medal_textures
		cell.set_data(DailyChallenge.get_daily(date), date.equals(today), date.equals(_selected))
		cell.pressed.connect(select_date)
		_grid.add_child(cell)


func _refresh_detail() -> void:
	var info := DailyChallenge.get_daily(_selected)
	_date_label.text = "%d %s" % [_selected.day, MONTH_NAMES[_selected.month - 1]]
	_theme_label.text = hidden_theme_text if info.state == DailyState.State.FUTURE else theme_text % info.theme_name
	for i in _medal_icons.size():
		var collected := info.progress != null and info.progress.has_checkpoint(i)
		_medal_icons[i].modulate = Color.WHITE if collected else Color(1.0, 1.0, 1.0, missing_medal_alpha)
	_action_button.disabled = not DailyState.is_playable(info.state)
	_action_button.text = _action_text(info)
	if info.state == DailyState.State.FUTURE:
		_action_button.add_theme_font_size_override(&"font_size", countdown_font_size)
	else:
		_action_button.remove_theme_font_size_override(&"font_size")


func _action_text(info: DailyInfo) -> String:
	match info.state:
		DailyState.State.AVAILABLE:
			return "Play"
		DailyState.State.IN_PROGRESS:
			return "Continue"
		DailyState.State.COMPLETED:
			return "Completed"
		DailyState.State.FUTURE:
			return "Available in %s" % format_countdown(DailyChallenge.dates.seconds_until(info.date))
		DailyState.State.ENDED:
			return "Ended"
	return "Unavailable"


func _on_action_pressed() -> void:
	if DailyChallenge.can_play(_selected):
		play_requested.emit(_selected)


func _set_arrow_enabled(button: Button, enabled: bool) -> void:
	button.disabled = not enabled
	button.modulate.a = 1.0 if enabled else 0.3


# ---------------------------------------------------------------- Partes montadas por código

func _build_weekdays() -> void:
	for weekday_name: String in WEEKDAY_NAMES:
		var label := Label.new()
		label.theme_type_variation = &"InkCaption"
		label.text = weekday_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_weekday_row.add_child(label)


## Uma medalha por checkpoint, na moeda que ele concede (bronze, prata, estrela).
func _build_medals() -> void:
	for i in DailyProgress.CHECKPOINT_COUNT:
		var texture := UiIcons.for_currency(DailyChallenge.get_checkpoint_currency(i))
		_medal_textures.append(texture)
		var icon := UiIcons.make_icon(texture, medal_icon_size)
		_medal_icons.append(icon)
		_medal_row.add_child(icon)


func _build_debug_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.visible = false
	panel.theme_type_variation = &"CardPanel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -320.0
	panel.offset_right = 320.0
	panel.offset_top = -360.0
	panel.offset_bottom = 360.0
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	var margin := MarginContainer.new()
	for side in [&"margin_left", &"margin_right", &"margin_top", &"margin_bottom"]:
		margin.add_theme_constant_override(side, 18)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override(&"separation", 10)
	margin.add_child(box)
	var title := Label.new()
	title.theme_type_variation = &"Heading"
	title.text = "Date debug"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	_debug_date_label = Label.new()
	_debug_date_label.theme_type_variation = &"Caption"
	_debug_date_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_debug_date_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(_debug_date_label)
	var buttons := GridContainer.new()
	buttons.columns = 2
	buttons.add_theme_constant_override(&"h_separation", 8)
	buttons.add_theme_constant_override(&"v_separation", 8)
	box.add_child(buttons)
	var actions := [
		["-1 day", func() -> void: DailyChallenge.debug_advance_days(-1)],
		["+1 day", func() -> void: DailyChallenge.debug_advance_days(1)],
		["+7 days", func() -> void: DailyChallenge.debug_advance_days(7)],
		["+1 month", func() -> void: DailyChallenge.debug_advance_months(1)],
		["+1 year", func() -> void: DailyChallenge.debug_advance_months(12)],
		["Real date", func() -> void: DailyChallenge.debug_use_real_date()],
		["+ Checkpoint", func() -> void: DailyChallenge.debug_collect_next_checkpoint(_selected)],
		["Reset day", func() -> void: DailyChallenge.debug_reset_daily(_selected)],
		["Reset all", func() -> void: DailyChallenge.debug_reset_all()],
		["Close", func() -> void: _debug_panel.visible = false],
	]
	for action in actions:
		var button := Button.new()
		button.text = action[0]
		button.theme_type_variation = &"ButtonSmall"
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0.0, 64.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
	_debug_date_label.text = "Today: %s %s(week %d-W%02d)\nSelected: %s  seed %d  theme %s  state %s\nBronze %d  Silver %d  Stars %d  streak %d / best %d" % [
		today.to_key(), "SIMULATED " if DailyChallenge.dates.is_simulating() else "", week.x, week.y,
		_selected.to_key(), info.seed, info.theme_name, DailyState.name_of(info.state),
		DailyChallenge.get_currency(CurrencyWallet.Currency.BRONZE), DailyChallenge.get_currency(CurrencyWallet.Currency.SILVER),
		DailyChallenge.get_stars(), DailyChallenge.get_streak().x, DailyChallenge.get_streak().y]
