class_name TestRoomHud
extends CanvasLayer
## Interface da sala de testes. Abre os painéis (pausando o teste), reinicia, seleciona o objeto
## em teste e mostra ferramentas de debug.

@export var room_manager: TestRoomManager
@export var settings: TestSettingsManager
@export var control_manager: ControlManager
@export var player: PlayerController
@export var metrics: JumpMetrics
@export var toggle_settings_key: Key = KEY_TAB
@export var restart_key: Key = KEY_R
## Ativa manualmente os objetos (debug).
@export var trigger_key: Key = KEY_T

@onready var _controls_ui: Control = %ControlsUI
@onready var _settings_button: Button = %SettingsButton
@onready var _controls_button: Button = %ControlsButton
@onready var _restart_button: Button = %RestartButton
@onready var _debug_button: Button = %DebugButton
@onready var _exit_button: Button = %ExitButton
@onready var _object_option: OptionButton = %ObjectOption
@onready var _trigger_button: Button = %TriggerButton
@onready var _reset_objects_button: Button = %ResetObjectsButton
@onready var _vectors_button: Button = %VectorsButton
@onready var _debug_panel: Control = %DebugPanel
@onready var _debug_overlay: TestDebugOverlay = %DebugOverlay
@onready var _settings_panel: TestSettingsPanel = %SettingsPanel
@onready var _control_settings_panel: ControlSettingsPanel = %ControlSettingsPanel


func _ready() -> void:
	_settings_panel.setup(settings)
	_control_settings_panel.setup(control_manager)
	_debug_overlay.setup(player, metrics, settings)
	_debug_overlay.set_platform_set(room_manager.platform_set)
	_settings_button.pressed.connect(open_settings)
	_controls_button.pressed.connect(open_control_settings)
	_settings_panel.close_requested.connect(close_panels)
	_control_settings_panel.close_requested.connect(close_panels)
	_restart_button.pressed.connect(room_manager.restart_test)
	_exit_button.pressed.connect(room_manager.exit_to_menu)
	_debug_button.toggled.connect(func(pressed: bool) -> void: _debug_panel.visible = pressed)
	_debug_panel.visible = _debug_button.button_pressed
	_trigger_button.pressed.connect(room_manager.trigger_objects)
	_reset_objects_button.pressed.connect(room_manager.reset_objects)
	_vectors_button.toggled.connect(room_manager.set_debug_vectors)
	_build_object_options()
	room_manager.station_changed.connect(_on_station_changed)
	close_panels()


func open_settings() -> void:
	_open_panel(_settings_panel)


func open_control_settings() -> void:
	_open_panel(_control_settings_panel)


func close_panels() -> void:
	_settings_panel.visible = false
	_control_settings_panel.visible = false
	_controls_ui.visible = true
	get_tree().paused = false


func is_panel_open() -> bool:
	return _settings_panel.visible or _control_settings_panel.visible


func _build_object_options() -> void:
	_object_option.clear()
	_object_option.add_item("OBJETO: PADRÃO")
	for station in room_manager.get_stations():
		_object_option.add_item("OBJETO: %s" % station.display_name.to_upper())
	_object_option.item_selected.connect(func(index: int) -> void: room_manager.select_station(index - 1))


func _on_station_changed(station: ObjectTestStation) -> void:
	var index := room_manager.get_stations().find(station) + 1 if station else 0
	if _object_option.selected != index:
		_object_option.select(index)
	_settings_panel.set_object_section(station.settings_section if station else &"")


func _open_panel(panel: Control) -> void:
	_settings_panel.visible = panel == _settings_panel
	_control_settings_panel.visible = panel == _control_settings_panel
	_controls_ui.visible = false
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or TransitionManager.is_input_locked():
		return
	if key.physical_keycode == toggle_settings_key:
		if is_panel_open():
			close_panels()
		else:
			open_settings()
	elif key.physical_keycode == restart_key and not is_panel_open():
		room_manager.restart_test()
	elif key.physical_keycode == trigger_key and not is_panel_open():
		room_manager.trigger_objects()
