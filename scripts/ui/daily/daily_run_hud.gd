class_name DailyRunHud
extends CanvasLayer
## HUD do Desafio Diário na partida: estrelas dos 3 checkpoints do dia, total de estrelas, feedback
## "+1 ⭐" ao coletar e o painel de conclusão com a sequência. Só reage a sinais.

@export var top_offset: float = 150.0
@export var side_margin: float = 24.0
@export var star_size: float = 46.0
@export var star_color: Color = Color(1.0, 0.8, 0.15)
@export var star_outline_color: Color = Color(0.12, 0.1, 0.1)
@export var empty_star_color: Color = Color(0.25, 0.27, 0.32, 0.9)
@export var empty_star_outline_color: Color = Color(0.85, 0.87, 0.9, 0.9)
@export var completed_title: String = "DESAFIO CONCLUÍDO!"
@export var calendar_text: String = "CALENDÁRIO"

var session: DailyInfo

var _stars: Array[PixelIcon] = []
var _complete_stars: Array[PixelIcon] = []
var _top_row: HBoxContainer
var _feedback: StarRewardFeedback
var _complete_panel: Control
var _complete_detail: Label
var _complete_streak: Label
var _calendar_button: Button


func _ready() -> void:
	_build()


func setup(daily: DailyInfo, game_manager: GameManager) -> void:
	session = daily
	_complete_detail.text = "%02d/%02d/%d  -  %s" % [daily.date.day, daily.date.month, daily.date.year, daily.theme_name.to_upper()]
	DailyChallenge.stars_changed.connect(_on_stars_changed)
	game_manager.state_changed.connect(_on_state_changed)
	_calendar_button.pressed.connect(game_manager.return_to_menu)
	_refresh_stars()


func get_feedback() -> StarRewardFeedback:
	return _feedback


func get_star_icons() -> Array[PixelIcon]:
	return _stars


func is_complete_panel_visible() -> bool:
	return _complete_panel.visible


func _on_stars_changed(_total: int, delta: int, reason: StringName) -> void:
	if reason != StarWallet.REASON_CHECKPOINT or session == null:
		return
	_refresh_stars()
	_feedback.show_reward(delta, "CHECKPOINT %d" % session.get_collected_count())


func _on_state_changed(new_state: GameManager.State, _previous_state: GameManager.State) -> void:
	_top_row.visible = new_state != GameManager.State.GAME_OVER and new_state != GameManager.State.COMPLETED
	_complete_panel.visible = new_state == GameManager.State.COMPLETED
	if new_state == GameManager.State.COMPLETED:
		_refresh_stars()
		var streak := DailyChallenge.get_streak().x
		_complete_streak.text = "SEQUÊNCIA: %d %s" % [streak, "DIA" if streak == 1 else "DIAS"]


func _refresh_stars() -> void:
	var collected := session.get_collected_count() if session else 0
	for icons: Array[PixelIcon] in [_stars, _complete_stars]:
		for i in icons.size():
			if i < collected:
				icons[i].set_colors(star_color, star_outline_color)
			else:
				icons[i].set_colors(empty_star_color, empty_star_outline_color)


func _build() -> void:
	var safe := SafeAreaOffsets.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)

	_top_row = HBoxContainer.new()
	# Canto superior direito, abaixo do botão ALT: a esquerda é da barra de altitude e o centro do aviso de meta.
	_top_row.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_top_row.offset_left = -480.0
	_top_row.offset_right = -side_margin
	_top_row.offset_top = top_offset
	_top_row.offset_bottom = top_offset + star_size
	_top_row.alignment = BoxContainer.ALIGNMENT_END
	_top_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_row.add_theme_constant_override(&"separation", 6)
	safe.add_child(_top_row)
	for i in DailyProgress.CHECKPOINT_COUNT:
		var star := _make_star(star_size)
		_stars.append(star)
		_top_row.add_child(star)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(20.0, 0.0)
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_row.add_child(gap)
	var counter := StarCounter.new()
	counter.icon_size = 40.0
	counter.font_size = 32
	_top_row.add_child(counter)

	_feedback = StarRewardFeedback.new()
	_feedback.vertical_anchor = 0.28
	_feedback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_child(_feedback)

	_complete_panel = Control.new()
	_complete_panel.visible = false
	_complete_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_complete_panel)
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.05, 0.1, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_complete_panel.add_child(dim)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -300.0
	box.offset_right = 300.0
	box.offset_top = -300.0
	box.offset_bottom = 300.0
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override(&"separation", 22)
	_complete_panel.add_child(box)
	box.add_child(_make_label(completed_title, 54, Color(1.0, 0.82, 0.25)))
	_complete_detail = _make_label("", 30, Color.WHITE)
	box.add_child(_complete_detail)
	var stars_row := HBoxContainer.new()
	stars_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stars_row.add_theme_constant_override(&"separation", 12)
	box.add_child(stars_row)
	for i in DailyProgress.CHECKPOINT_COUNT:
		var star := _make_star(88.0)
		_complete_stars.append(star)
		stars_row.add_child(star)
	_complete_streak = _make_label("", 34, Color(1.0, 0.6, 0.3))
	box.add_child(_complete_streak)
	_calendar_button = Button.new()
	_calendar_button.text = calendar_text
	_calendar_button.custom_minimum_size = Vector2(0.0, 100.0)
	_calendar_button.focus_mode = Control.FOCUS_NONE
	_calendar_button.add_theme_font_size_override(&"font_size", 38)
	box.add_child(_calendar_button)


func _make_star(side: float) -> PixelIcon:
	var star := PixelIcon.new()
	star.icon = PixelIcon.Icon.STAR
	star.custom_minimum_size = Vector2(side, side)
	star.set_colors(empty_star_color, empty_star_outline_color)
	return star


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", Color(0.05, 0.07, 0.12))
	label.add_theme_constant_override(&"outline_size", 10)
	return label
