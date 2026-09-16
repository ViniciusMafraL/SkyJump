class_name DailyRunHud
extends CanvasLayer
## HUD do Desafio Diário na partida: medalhas dos 3 checkpoints do dia (bronze, prata, estrela),
## moedas do jogador, feedback "+1 [moeda]" ao coletar e o painel de conclusão com a sequência.
## Só reage a sinais.

## Abaixo do aviso de meta da ProgressHUD.
@export var top_offset: float = 196.0
@export var side_margin: float = 24.0
@export var medal_size: float = 50.0
@export var completed_title: String = "Daily complete!"
@export var calendar_text: String = "Calendar"
@export var checkpoint_caption: String = "Checkpoint %d"
@export_range(0.0, 1.0, 0.01) var missing_medal_alpha: float = 0.25

var session: DailyInfo

var _medals: Array[TextureRect] = []
var _complete_medals: Array[TextureRect] = []
var _top_box: VBoxContainer
var _feedback: StarRewardFeedback
var _complete_panel: Control
var _complete_detail: Label
var _calendar_button: Button


func _ready() -> void:
	_build()


func setup(daily: DailyInfo, game_manager: GameManager) -> void:
	session = daily
	_complete_detail.text = "%02d/%02d/%d  -  %s" % [daily.date.day, daily.date.month, daily.date.year, daily.theme_name]
	DailyChallenge.currency_changed.connect(_on_currency_changed)
	game_manager.state_changed.connect(_on_state_changed)
	_calendar_button.pressed.connect(game_manager.return_to_menu)
	_refresh_medals()


func get_feedback() -> StarRewardFeedback:
	return _feedback


func get_medal_icons() -> Array[TextureRect]:
	return _medals


func is_complete_panel_visible() -> bool:
	return _complete_panel.visible


func _on_currency_changed(currency: int, _total: int, delta: int, reason: StringName) -> void:
	if reason != CurrencyWallet.REASON_CHECKPOINT or session == null:
		return
	_refresh_medals()
	_feedback.show_reward(delta, checkpoint_caption % session.get_collected_count(), UiIcons.for_currency(currency))


func _on_state_changed(new_state: GameManager.State, _previous_state: GameManager.State) -> void:
	_top_box.visible = new_state != GameManager.State.GAME_OVER and new_state != GameManager.State.COMPLETED
	_complete_panel.visible = new_state == GameManager.State.COMPLETED
	if new_state == GameManager.State.COMPLETED:
		_refresh_medals()


func _refresh_medals() -> void:
	for icons: Array[TextureRect] in [_medals, _complete_medals]:
		for i in icons.size():
			var collected := session != null and session.progress != null and session.progress.has_checkpoint(i)
			icons[i].modulate = Color.WHITE if collected else Color(1.0, 1.0, 1.0, missing_medal_alpha)


func _build() -> void:
	var safe := SafeAreaOffsets.new()
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(safe)

	# Canto superior direito, abaixo do botão ALT: a esquerda é da barra de altitude e o centro do aviso de meta.
	_top_box = VBoxContainer.new()
	_top_box.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_top_box.offset_left = -480.0
	_top_box.offset_right = -side_margin
	_top_box.offset_top = top_offset
	_top_box.offset_bottom = top_offset + medal_size * 2.4
	_top_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_top_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_box.add_theme_constant_override(&"separation", 6)
	safe.add_child(_top_box)
	var pill := PanelContainer.new()
	pill.theme_type_variation = &"PillPanel"
	pill.size_flags_horizontal = Control.SIZE_SHRINK_END
	pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_top_box.add_child(pill)
	var medal_row := HBoxContainer.new()
	medal_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	medal_row.add_theme_constant_override(&"separation", 6)
	pill.add_child(medal_row)
	for i in DailyProgress.CHECKPOINT_COUNT:
		var medal := UiIcons.make_icon(UiIcons.for_currency(DailyChallenge.get_checkpoint_currency(i)), medal_size)
		_medals.append(medal)
		medal_row.add_child(medal)
	var bar := CurrencyBar.new()
	bar.icon_size = 34.0
	bar.label_variation = &"Body"
	bar.spacing = 14
	bar.alignment = BoxContainer.ALIGNMENT_END
	bar.size_flags_horizontal = Control.SIZE_SHRINK_END
	_top_box.add_child(bar)

	_feedback = StarRewardFeedback.new()
	_feedback.vertical_anchor = 0.28
	_feedback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.add_child(_feedback)

	_complete_panel = Control.new()
	_complete_panel.visible = false
	_complete_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_complete_panel)
	var dim := ColorRect.new()
	dim.color = SkyJumpColors.DIM
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_complete_panel.add_child(dim)
	var box := VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.offset_left = -320.0
	box.offset_right = 320.0
	box.offset_top = -340.0
	box.offset_bottom = 340.0
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override(&"separation", 22)
	_complete_panel.add_child(box)
	var title := _make_label(completed_title, &"Title")
	title.add_theme_color_override(&"font_color", SkyJumpColors.YELLOW)
	box.add_child(title)
	_complete_detail = _make_label("", &"Body")
	box.add_child(_complete_detail)
	var medals_row := HBoxContainer.new()
	medals_row.alignment = BoxContainer.ALIGNMENT_CENTER
	medals_row.add_theme_constant_override(&"separation", 18)
	box.add_child(medals_row)
	for i in DailyProgress.CHECKPOINT_COUNT:
		var medal := UiIcons.make_icon(UiIcons.for_currency(DailyChallenge.get_checkpoint_currency(i)), 104.0)
		_complete_medals.append(medal)
		medals_row.add_child(medal)
	var streak := StreakBadge.new()
	streak.icon_size = 56.0
	streak.label_variation = &"Heading"
	box.add_child(streak)
	_calendar_button = Button.new()
	_calendar_button.text = calendar_text
	_calendar_button.theme_type_variation = &"ButtonYellow"
	_calendar_button.custom_minimum_size = Vector2(440.0, 100.0)
	_calendar_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_calendar_button.focus_mode = Control.FOCUS_NONE
	box.add_child(_calendar_button)
	UiFeedback.attach(_calendar_button)


func _make_label(text: String, variation: StringName) -> Label:
	var label := Label.new()
	label.text = text
	label.theme_type_variation = variation
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label
