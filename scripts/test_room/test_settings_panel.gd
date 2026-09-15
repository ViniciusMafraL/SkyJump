class_name TestSettingsPanel
extends Control
## Painel modular: as linhas são montadas a partir de um TestSettingsSchema.
## A UI apenas altera dados no TestSettingsManager; não aplica nada nos sistemas.

signal close_requested

const SAVE_DEFAULTS_TEXT := "SALVAR COMO PADRÃO DO JOGO"
const SAVE_CONFIRM_TEXT := "CONFIRMAR: SOBRESCREVER config/*.tres"

@export var schema: TestSettingsSchema
@export var section_title_color: Color = Color(1.0, 0.82, 0.35)
@export var hint_color: Color = Color(0.75, 0.78, 0.85)

var _settings: TestSettingsManager
var _refreshers: Array[Callable] = []
var _refreshing: bool = false
var _save_confirm_pending: bool = false
var _object_section: StringName = &""

@onready var _rows: VBoxContainer = %Rows
@onready var _preset_option: OptionButton = %PresetOption
@onready var _load_preset_button: Button = %LoadPresetButton
@onready var _auto_apply_check: CheckBox = %AutoApplyCheck
@onready var _status_label: Label = %StatusLabel
@onready var _apply_button: Button = %ApplyButton
@onready var _reset_button: Button = %ResetButton
@onready var _save_defaults_button: Button = %SaveDefaultsButton
@onready var _close_button: Button = %CloseButton


func setup(settings: TestSettingsManager) -> void:
	_settings = settings
	_build_presets()
	_build_rows()
	_auto_apply_check.button_pressed = settings.apply_on_change
	_auto_apply_check.toggled.connect(func(pressed: bool) -> void: _settings.apply_on_change = pressed)
	_apply_button.pressed.connect(_settings.apply)
	_reset_button.pressed.connect(_settings.reset_to_defaults)
	_load_preset_button.pressed.connect(func() -> void: _settings.load_preset(_preset_option.selected))
	_save_defaults_button.pressed.connect(_on_save_defaults_pressed)
	_save_defaults_button.disabled = not settings.can_save_game_defaults()
	_close_button.pressed.connect(close_requested.emit)
	visibility_changed.connect(_cancel_save_confirmation)
	settings.draft_changed.connect(_refresh)
	_refresh()


func _build_presets() -> void:
	_preset_option.clear()
	for preset in _settings.presets:
		_preset_option.add_item(preset.display_name)
	_load_preset_button.disabled = _settings.presets.is_empty()


## Mostra apenas os parâmetros da seção de objeto indicada (vazio = nenhum objeto).
func set_object_section(section: StringName) -> void:
	if section == _object_section:
		return
	_object_section = section
	if _settings == null:
		return
	for child in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	_refreshers.clear()
	_build_rows()
	_refresh()


func _build_rows() -> void:
	var current_title := ""
	for definition in schema.settings:
		if definition == null:
			continue
		var section := definition.get_section()
		if section in TestRoomConfig.OBJECT_SECTIONS and section != _object_section:
			continue
		if definition.section_title != current_title:
			current_title = definition.section_title
			_add_section_header(current_title)
		match definition.kind:
			SettingDefinition.Kind.NUMBER:
				_add_number_row(definition)
			SettingDefinition.Kind.TOGGLE:
				_add_toggle_row(definition)
			SettingDefinition.Kind.FLAGS:
				_add_flags_row(definition)
			SettingDefinition.Kind.ENUM:
				_add_enum_row(definition)
		if not definition.hint.is_empty():
			var hint := Label.new()
			hint.text = definition.hint
			hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			hint.add_theme_color_override("font_color", hint_color)
			hint.add_theme_font_size_override("font_size", 18)
			_rows.add_child(hint)


func _add_section_header(title: String) -> void:
	_rows.add_child(HSeparator.new())
	var label := Label.new()
	label.text = title
	label.add_theme_color_override("font_color", section_title_color)
	label.add_theme_font_size_override("font_size", 28)
	_rows.add_child(label)


func _add_number_row(definition: SettingDefinition) -> void:
	var header := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = definition.label
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var spin_box := SpinBox.new()
	var slider := HSlider.new()
	for range_control: Range in [spin_box, slider]:
		range_control.min_value = definition.min_value
		range_control.max_value = definition.max_value
		range_control.step = definition.step
	spin_box.allow_greater = true
	spin_box.allow_lesser = true
	spin_box.suffix = definition.suffix
	spin_box.custom_minimum_size = Vector2(190.0, 0.0)
	slider.custom_minimum_size = Vector2(0.0, 44.0)
	slider.focus_mode = Control.FOCUS_NONE
	header.add_child(name_label)
	header.add_child(spin_box)
	_rows.add_child(header)
	_rows.add_child(slider)

	var on_changed := func(value: float) -> void: _on_control_changed(definition.path, value)
	spin_box.value_changed.connect(on_changed)
	slider.value_changed.connect(on_changed)
	var refresh := func() -> void:
		var value: float = _settings.get_value(definition.path)
		spin_box.value = value
		slider.value = value
	_refreshers.append(refresh)


func _add_toggle_row(definition: SettingDefinition) -> void:
	var toggle := CheckButton.new()
	toggle.text = definition.label
	toggle.focus_mode = Control.FOCUS_NONE
	_rows.add_child(toggle)
	toggle.toggled.connect(func(pressed: bool) -> void: _on_control_changed(definition.path, pressed))
	var refresh := func() -> void: toggle.button_pressed = bool(_settings.get_value(definition.path))
	_refreshers.append(refresh)


## Opções lidas do hint de @export_flags da propriedade, sem duplicar nomes no schema.
func _add_flags_row(definition: SettingDefinition) -> void:
	var title := Label.new()
	title.text = definition.label
	_rows.add_child(title)
	var flow := HFlowContainer.new()
	_rows.add_child(flow)
	var flag_names: PackedStringArray = str(_settings.get_property_info(definition.path).get("hint_string", "")).split(",", false)
	var boxes: Array[CheckBox] = []
	for i in flag_names.size():
		var box := CheckBox.new()
		box.text = flag_names[i].get_slice(":", 0)
		box.focus_mode = Control.FOCUS_NONE
		flow.add_child(box)
		boxes.append(box)
		box.toggled.connect(_on_flag_toggled.bind(definition.path, 1 << i))
	var refresh := func() -> void:
		var mask := int(_settings.get_value(definition.path))
		for i in boxes.size():
			boxes[i].button_pressed = (mask & (1 << i)) != 0
	_refreshers.append(refresh)


## Opções lidas do hint do @export de enum ("NOME:valor,...").
func _add_enum_row(definition: SettingDefinition) -> void:
	var row := HBoxContainer.new()
	var name_label := Label.new()
	name_label.text = definition.label
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var option := OptionButton.new()
	option.focus_mode = Control.FOCUS_NONE
	option.custom_minimum_size = Vector2(240.0, 52.0)
	var entries: PackedStringArray = str(_settings.get_property_info(definition.path).get("hint_string", "")).split(",", false)
	for i in entries.size():
		var parts := entries[i].split(":")
		var value := int(parts[1]) if parts.size() > 1 else i
		option.add_item(parts[0].strip_edges().to_upper(), value)
	row.add_child(name_label)
	row.add_child(option)
	_rows.add_child(row)
	option.item_selected.connect(func(index: int) -> void: _on_control_changed(definition.path, option.get_item_id(index)))
	var refresh := func() -> void: option.select(option.get_item_index(int(_settings.get_value(definition.path))))
	_refreshers.append(refresh)


func _on_control_changed(path: String, value: Variant) -> void:
	if not _refreshing:
		_settings.set_value(path, value)


func _on_flag_toggled(pressed: bool, path: String, bit: int) -> void:
	if _refreshing:
		return
	var mask := int(_settings.get_value(path))
	mask = (mask | bit) if pressed else (mask & ~bit)
	_settings.set_value(path, mask)


func _refresh() -> void:
	_refreshing = true
	for refresher in _refreshers:
		refresher.call()
	_refreshing = false
	_apply_button.disabled = not _settings.has_pending_changes
	_status_label.text = "Alterações ainda não aplicadas" if _settings.has_pending_changes else "Valores em uso no teste"


func _on_save_defaults_pressed() -> void:
	if not _save_confirm_pending:
		_save_confirm_pending = true
		_save_defaults_button.text = SAVE_CONFIRM_TEXT
		return
	_cancel_save_confirmation()
	var error := _settings.save_active_as_game_defaults()
	if error != OK:
		_status_label.text = "Falha ao salvar: %s" % error_string(error)
	elif _settings.last_saved_paths.is_empty():
		_status_label.text = "Nada a salvar: valores ativos iguais aos padrões"
	else:
		_status_label.text = "Salvo: %s" % ", ".join(_settings.last_saved_paths)


func _cancel_save_confirmation() -> void:
	_save_confirm_pending = false
	_save_defaults_button.text = SAVE_DEFAULTS_TEXT
