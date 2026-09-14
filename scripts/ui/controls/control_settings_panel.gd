class_name ControlSettingsPanel
extends Control
## Menu CONTROLES: escolha do método e ajustes relevantes apenas ao método selecionado.
## Edita uma cópia da configuração; APLICAR entrega ao ControlManager, que salva localmente.

signal close_requested

@export var calibration_delay: float = 1.5
@export var section_title_color: Color = Color(1.0, 0.82, 0.35)

var _manager: ControlManager
var _draft: ControlConfig
var _refreshers: Array[Callable] = []
var _refreshing: bool = false
var _scheme_options: Dictionary = {}
var _scheme_sections: Dictionary = {}

@onready var _content: VBoxContainer = %Content
@onready var _status_label: Label = %StatusLabel
@onready var _apply_button: Button = %ApplyButton
@onready var _close_button: Button = %CloseButton


func setup(manager: ControlManager) -> void:
	_manager = manager
	_apply_button.pressed.connect(_on_apply_pressed)
	_close_button.pressed.connect(close_requested.emit)
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	if visible and _manager:
		_draft = _manager.config.make_copy()
		_rebuild()
		_status_label.text = ""


func _rebuild() -> void:
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	_refreshers.clear()
	_scheme_options.clear()
	_scheme_sections.clear()

	_add_section_title(_content, "MÉTODO DE CONTROLE")
	var group := ButtonGroup.new()
	for scheme in _manager.get_schemes():
		var option := CheckBox.new()
		option.text = scheme.display_name
		option.button_group = group
		option.focus_mode = Control.FOCUS_NONE
		option.custom_minimum_size.y = 56.0
		option.toggled.connect(_on_scheme_toggled.bind(scheme.scheme_id))
		_content.add_child(option)
		_scheme_options[scheme.scheme_id] = option

	for scheme in _manager.get_schemes():
		var section := _build_section_for(scheme)
		if section:
			_content.add_child(section)
			_scheme_sections[scheme.scheme_id] = section

	var general := _new_section("GERAL")
	_add_toggle(general, "Pulo automático (métodos sem botão de pulo)", "auto_jump_enabled")
	_add_toggle(general, "Girar câmera arrastando / teclas", "camera_control_enabled")
	_add_toggle(general, "Vibração", "haptics_enabled")
	_add_toggle(general, "Mostrar Debug dos Controles", "show_control_debug")
	_content.add_child(general)
	_refresh()


## Seções específicas por tipo de método. Métodos sem ajustes próprios não têm seção.
func _build_section_for(scheme: ControlScheme) -> Control:
	if scheme is TouchInvisibleControl:
		var touch := _new_section("TOQUE")
		_add_slider(touch, "Sensibilidade", "touch.touch_sensitivity", 0.1, 1.0, 0.05)
		_add_toggle(touch, "Mostrar dica < >", "touch.control_hint_enabled")
		_add_slider(touch, "Duração da dica (s)", "touch.control_hint_timeout", 0.5, 10.0, 0.5)
		_add_slider(touch, "Repetir dica após (s, 0 = nunca)", "touch.control_hint_repeat_delay", 0.0, 30.0, 1.0)
		_add_toggle(touch, "Brilho ao tocar", "touch.feedback_enabled")
		return touch
	if scheme is GyroscopeControl:
		var gyro := _new_section("GIROSCÓPIO")
		var sensor_label := Label.new()
		sensor_label.text = "Sensor: %s" % (scheme as GyroscopeControl).get_sensor_description()
		sensor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sensor_label.add_theme_font_size_override("font_size", 20)
		gyro.add_child(sensor_label)
		_add_slider(gyro, "Sensibilidade", "gyroscope.gyro_sensitivity", 0.1, 5.0, 0.05)
		_add_slider(gyro, "Zona morta", "gyroscope.gyro_dead_zone", 0.0, 0.9, 0.01)
		_add_slider(gyro, "Suavização", "gyroscope.gyro_smoothing", 0.0, 30.0, 0.5)
		_add_slider(gyro, "Inclinação máxima (°)", "gyroscope.max_tilt_degrees", 5.0, 80.0, 1.0)
		_add_toggle(gyro, "Inverter direção", "gyroscope.invert")
		_add_toggle(gyro, "Mostrar indicador de inclinação", "gyroscope.show_indicator")
		_add_calibration(gyro)
		return gyro
	if scheme is ButtonControl:
		var buttons := _new_section("BOTÕES")
		_add_slider(buttons, "Tamanho dos botões", "button.button_size", 80.0, 320.0, 5.0)
		_add_slider(buttons, "Tamanho do botão de pulo", "button.jump_button_size", 80.0, 360.0, 5.0)
		_add_slider(buttons, "Opacidade", "button.button_opacity", 0.05, 1.0, 0.05)
		return buttons
	return null


func _refresh() -> void:
	_refreshing = true
	for scheme_id in _scheme_options:
		_scheme_options[scheme_id].button_pressed = scheme_id == _draft.selected_control_scheme
	for scheme_id in _scheme_sections:
		_scheme_sections[scheme_id].visible = scheme_id == _draft.selected_control_scheme
	for refresher in _refreshers:
		refresher.call()
	_refreshing = false


func _on_scheme_toggled(pressed: bool, scheme_id: StringName) -> void:
	if pressed and not _refreshing:
		_draft.selected_control_scheme = scheme_id
		_refresh()


func _on_apply_pressed() -> void:
	_manager.apply_config(_draft)
	var scheme := _manager.get_current_scheme()
	_status_label.text = "Controles aplicados: %s" % (scheme.display_name if scheme else "-")


func _add_calibration(parent: Control) -> void:
	var button := Button.new()
	button.text = "CALIBRAR"
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = 64.0
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 20)
	button.pressed.connect(_on_calibrate_pressed.bind(button, label))
	parent.add_child(button)
	parent.add_child(label)


func _on_calibrate_pressed(button: Button, label: Label) -> void:
	button.disabled = true
	label.text = "Segure o celular na posição desejada..."
	await get_tree().create_timer(calibration_delay).timeout
	if not is_instance_valid(button):
		return
	var has_sensor := _manager.calibrate_gyroscope()
	var neutral := _manager.config.gyroscope_config.neutral_orientation
	_draft.gyroscope_config.neutral_orientation = neutral
	if has_sensor:
		label.text = "Posição neutra registrada (%.1f°)." % neutral
	else:
		label.text = "Sem sensor neste aparelho: calibrada a inclinação simulada (A/D)."
	button.disabled = false


func _new_section(title: String) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 8)
	section.add_child(HSeparator.new())
	_add_section_title(section, title)
	return section


func _add_section_title(parent: Control, title: String) -> void:
	var label := Label.new()
	label.text = title
	label.add_theme_color_override("font_color", section_title_color)
	label.add_theme_font_size_override("font_size", 28)
	parent.add_child(label)


func _add_slider(parent: Control, label_text: String, path: String, min_value: float, max_value: float, step: float) -> void:
	var header := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var value_label := Label.new()
	value_label.custom_minimum_size.x = 90.0
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(label)
	header.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = min_value
	slider.max_value = max_value
	slider.step = step
	slider.focus_mode = Control.FOCUS_NONE
	slider.custom_minimum_size.y = 44.0
	parent.add_child(header)
	parent.add_child(slider)
	slider.value_changed.connect(func(value: float) -> void:
		value_label.text = _format_number(value, step)
		if not _refreshing:
			_set_value(path, value))
	var refresh := func() -> void:
		var value: float = _get_value(path)
		slider.value = value
		value_label.text = _format_number(value, step)
	_refreshers.append(refresh)


func _add_toggle(parent: Control, label_text: String, path: String) -> void:
	var toggle := CheckButton.new()
	toggle.text = label_text
	toggle.focus_mode = Control.FOCUS_NONE
	parent.add_child(toggle)
	toggle.toggled.connect(func(pressed: bool) -> void:
		if not _refreshing:
			_set_value(path, pressed))
	var refresh := func() -> void: toggle.button_pressed = bool(_get_value(path))
	_refreshers.append(refresh)


## Caminhos: "propriedade" (raiz) ou "<seção>.<propriedade>" (touch, gyroscope, button).
func _get_value(path: String) -> Variant:
	var target := _target_for(path)
	return target.get(_property_for(path)) if target else null


func _set_value(path: String, value: Variant) -> void:
	var target := _target_for(path)
	if target:
		target.set(_property_for(path), value)


func _target_for(path: String) -> Resource:
	if path.contains("."):
		return _draft.get_section(StringName(path.get_slice(".", 0)))
	return _draft


func _property_for(path: String) -> StringName:
	return StringName(path.get_slice(".", 1) if path.contains(".") else path)


func _format_number(value: float, step: float) -> String:
	return str(roundi(value)) if step >= 1.0 else "%.2f" % value
