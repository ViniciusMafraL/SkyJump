class_name ProgressHUD
extends Control
## Barra lateral de progressão por altitude. Só VISUALIZA os dados do ProgressionManager
## (altura atual, metas, recorde) e a skin atual; não calcula gameplay nem salva nada.

const DEBUG_STEPS := {&"Minus100": -100.0, &"Plus100": 100.0, &"Plus500": 500.0, &"Plus1000": 1000.0}
## Mensagens aguardando exibição (meta e recorde podem acontecer no mesmo instante).
const MAX_QUEUED_FEEDBACK := 2

@export var config: ProgressBarConfig
## Botões de simulação de altitude (só aparecem em builds de debug).
@export var show_debug_controls: bool = true
@export var milestone_feedback_text: String = "Goal %s!"
@export var new_record_text: String = "New record!"
@export var record_label_text: String = "BEST\n%s"

var progression: ProgressionManager

var _milestone_markers: Dictionary = {}
var _milestone_layer: Control
var _player_marker: PlayerProgressMarker
var _record_marker: RecordMarker
var _feedback_tween: Tween
var _feedback_queue: Array[Array] = []

@onready var _bar: VerticalProgressBar = %Bar
@onready var _record_label: Label = %RecordLabel
@onready var _feedback_label: Label = %FeedbackLabel
@onready var _debug_toggle: Button = %DebugToggle
@onready var _debug_panel: Control = %DebugPanel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.config = config
	_milestone_layer = Control.new()
	_milestone_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bar.add_child(_milestone_layer)
	_record_marker = RecordMarker.new()
	_record_marker.setup(config)
	_bar.add_child(_record_marker)
	_player_marker = PlayerProgressMarker.new()
	_player_marker.setup(config)
	_bar.add_child(_player_marker)
	_style_labels()
	_feedback_label.modulate.a = 0.0
	get_viewport().size_changed.connect(_apply_layout)
	SkinManager.skin_selected.connect(func(_skin: PlayerSkin) -> void: _apply_skin())
	_setup_debug()
	_apply_skin()
	_apply_layout()


func setup(manager: ProgressionManager) -> void:
	progression = manager
	progression.milestone_reached.connect(_on_milestone_reached)
	progression.milestone_changed.connect(_on_milestone_changed)
	progression.new_record.connect(_on_new_record)
	progression.run_reset.connect(_on_run_reset)
	_on_run_reset()


func get_player_marker() -> PlayerProgressMarker:
	return _player_marker


func get_record_marker() -> RecordMarker:
	return _record_marker


func get_bar() -> VerticalProgressBar:
	return _bar


func get_milestone_marker(height: float) -> MilestoneMarker:
	return _milestone_markers.get(height) as MilestoneMarker


func get_feedback_text() -> String:
	return _feedback_label.text


func get_queued_feedback_count() -> int:
	return _feedback_queue.size()


func _process(delta: float) -> void:
	if progression == null:
		return
	_update_targets()
	for marker in _all_markers():
		marker.advance(delta)
		marker.position = Vector2(_bar.line_x(), _bar.y_for_ratio(marker.display_ratio))
	_bar.set_fill_ratio(_player_marker.display_ratio)
	_record_label.text = record_label_text % HeightFormat.meters(progression.personal_best_height)


func _update_targets() -> void:
	_player_marker.set_target(_bar.ratio_for_height(progression.current_height))
	_player_marker.set_height(progression.current_height, progression.is_simulating)
	var best := progression.personal_best_height
	_record_marker.visible = best > 0.0
	_record_marker.set_target(_bar.ratio_for_height(best))
	_record_marker.set_above(_bar.is_above_range(best))
	for marker: MilestoneMarker in _milestone_markers.values():
		marker.set_target(_bar.ratio_for_height(marker.height_m))


func _all_markers() -> Array[ProgressBarMarker]:
	var markers: Array[ProgressBarMarker] = [_record_marker, _player_marker]
	for marker: MilestoneMarker in _milestone_markers.values():
		markers.append(marker)
	return markers


func _rebuild_milestones(snap: bool) -> void:
	_bar.set_milestones(progression.previous_milestone, progression.current_milestone, progression.milestones_reached)
	var visible_heights := _bar.get_visible_milestones()
	for height in _milestone_markers.keys():
		if not height in visible_heights:
			var old_marker: MilestoneMarker = _milestone_markers[height]
			_milestone_markers.erase(height)
			if snap:
				old_marker.queue_free()
			else:
				old_marker.dismiss()
	for height in visible_heights:
		var marker := _milestone_markers.get(height) as MilestoneMarker
		if marker == null:
			marker = MilestoneMarker.new()
			marker.setup(config)
			marker.height_m = height
			var data := progression.config.find_milestone_data(height)
			marker.caption = data.display_name if data else ""
			_milestone_layer.add_child(marker)
			_milestone_markers[height] = marker
			marker.set_target(_bar.ratio_for_height(height), true)
			if not snap:
				marker.appear()
		marker.set_state(height < progression.current_milestone, is_equal_approx(height, progression.current_milestone))
	if snap:
		_update_targets()
		for marker in _all_markers():
			marker.snap()


func _on_run_reset() -> void:
	_rebuild_milestones(true)
	_feedback_queue.clear()
	if _feedback_tween and _feedback_tween.is_valid():
		_feedback_tween.kill()
	_feedback_label.modulate.a = 0.0


func _on_milestone_reached(height: float, _index: int, data: MilestoneData) -> void:
	var marker := get_milestone_marker(height)
	if marker:
		marker.celebrate()
	var text := HeightFormat.meters(height)
	if data and not data.display_name.is_empty():
		text = "%s - %s" % [text, data.display_name]
	_show_feedback(milestone_feedback_text % text, config.milestone_color)


func _on_milestone_changed(_previous: float, _current: float) -> void:
	_rebuild_milestones(false)


func _on_new_record(_height: float) -> void:
	_show_feedback(new_record_text, config.record_color)


## Enfileira a mensagem; mensagens antigas são descartadas se muitas chegarem juntas.
func _show_feedback(text: String, color: Color) -> void:
	_feedback_queue.append([text, color])
	while _feedback_queue.size() > MAX_QUEUED_FEEDBACK:
		_feedback_queue.pop_front()
	if not (_feedback_tween and _feedback_tween.is_valid()):
		_play_next_feedback()


func _play_next_feedback() -> void:
	if _feedback_queue.is_empty():
		return
	var item: Array = _feedback_queue.pop_front()
	_feedback_label.text = item[0]
	_feedback_label.add_theme_color_override("font_color", item[1])
	_feedback_label.pivot_offset = _feedback_label.size * 0.5
	_feedback_label.modulate.a = 0.0
	_feedback_label.scale = Vector2.ONE * 0.8
	_feedback_tween = create_tween()
	_feedback_tween.tween_property(_feedback_label, "modulate:a", 1.0, 0.15)
	_feedback_tween.parallel().tween_property(_feedback_label, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_interval(config.feedback_duration)
	_feedback_tween.tween_property(_feedback_label, "modulate:a", 0.0, 0.35)
	_feedback_tween.tween_callback(_play_next_feedback)


## Skin atual -> marcador do jogador (ícone da skin quando houver; senão a cor da bola).
func _apply_skin() -> void:
	var skin := SkinManager.get_current_skin()
	var skin_icon: Texture2D = config.player_icon_texture
	if skin_icon == null and skin:
		skin_icon = skin.preview_icon
	_player_marker.set_skin_visual(skin.get_marker_color() if skin else Color.WHITE, skin_icon)


func _apply_layout() -> void:
	var view_size := get_viewport_rect().size
	var margins := SafeAreaMargins.compute(view_size, config.max_safe_margin_ratio)
	var top := margins[1] + config.bar_top_offset
	# Espaço abaixo da barra para o "0 m" e o texto RECORDE, sem invadir os botões de controle.
	var label_space := config.milestone_icon_size + 8.0 + config.small_font_size * 2.6
	var max_height := view_size.y - margins[3] - config.bottom_reserved_height - label_space - top
	_bar.position = Vector2(margins[0] + config.bar_margin, top)
	_bar.size = Vector2(config.bar_width, maxf(minf(view_size.y * config.bar_height_ratio, max_height), 160.0))
	_record_label.position = Vector2(_bar.position.x, _bar.position.y + _bar.size.y + config.milestone_icon_size + 8.0)
	_record_label.size = Vector2(280.0, 0.0)
	_feedback_label.position = Vector2(0.0, margins[1] + config.feedback_top_offset)
	_feedback_label.size = Vector2(view_size.x, 60.0)
	_debug_toggle.position = Vector2(view_size.x - margins[2] - _debug_toggle.size.x - 20.0, margins[1] + 20.0)
	_debug_panel.position = Vector2(view_size.x - margins[2] - _debug_panel.size.x - 20.0, _debug_toggle.position.y + _debug_toggle.size.y + 10.0)


func _style_labels() -> void:
	for label in [_record_label, _feedback_label]:
		if config.font:
			label.add_theme_font_override("font", config.font)
		label.add_theme_color_override("font_color", config.text_color)
		label.add_theme_color_override("font_outline_color", config.outline_color)
		label.add_theme_constant_override("outline_size", config.outline_size + 2)
	_record_label.add_theme_font_size_override("font_size", config.small_font_size)
	_feedback_label.add_theme_font_size_override("font_size", config.feedback_font_size)


func _setup_debug() -> void:
	var enabled := OS.is_debug_build() and show_debug_controls
	_debug_toggle.visible = enabled
	_debug_panel.visible = false
	if not enabled:
		return
	_debug_toggle.toggled.connect(func(pressed: bool) -> void: _debug_panel.visible = pressed)
	for child in _debug_panel.get_children():
		if child is Button:
			child.pressed.connect(_on_debug_button.bind(child.name))


func _on_debug_button(button_name: StringName) -> void:
	if progression == null:
		return
	if DEBUG_STEPS.has(button_name):
		progression.debug_add_height(DEBUG_STEPS[button_name])
	else:
		progression.debug_stop_simulation()
