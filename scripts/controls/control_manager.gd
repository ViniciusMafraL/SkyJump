class_name ControlManager
extends InputController
## Sistema central de controles: sabe qual método está ativo, coleta o input dele e entrega
## um único PlayerInputState ao PlayerController. Não contém lógica de física.
## Os métodos disponíveis são os filhos ControlScheme deste nó.

signal control_scheme_changed(scheme_id: StringName)
signal config_applied(config: ControlConfig)

@export var default_config: ControlConfig
@export var controls_ui: ControlsUI
## Salva e carrega as escolhas do jogador em user://.
@export var persist_preferences: bool = true
@export var debug_refresh_interval: float = 0.1

@export_group("Keyboard Fallback Actions")
@export var move_left_action: StringName = &"move_left"
@export var move_right_action: StringName = &"move_right"
@export var jump_action: StringName = &"jump"
@export var camera_left_action: StringName = &"camera_left"
@export var camera_right_action: StringName = &"camera_right"
@export var pause_action: StringName = &"pause"

## Configuração ativa: cópia dos padrões com as preferências salvas do jogador.
var config: ControlConfig

var _schemes: Dictionary = {}
var _current: ControlScheme
var _state := PlayerInputState.new()
var _pending_jump: bool = false
## Toque/clique em área livre da tela: confirmação de objetos (ex.: canhão) em qualquer método.
var _pending_confirm: bool = false
var _debug_time_left: float = 0.0


func _ready() -> void:
	# Coleta o input antes do PlayerController processar o frame.
	process_physics_priority = -100
	config = default_config.make_copy()
	if persist_preferences:
		ControlPreferences.load_into(config)
	for child in get_children():
		if child is ControlScheme:
			child.manager = self
			_schemes[child.scheme_id] = child
	_activate_scheme(config.selected_control_scheme)
	TransitionManager.transition_finished.connect(_on_transition_finished)


func get_player_input_state() -> PlayerInputState:
	return _state


func get_current_scheme() -> ControlScheme:
	return _current


func get_schemes() -> Array[ControlScheme]:
	var schemes: Array[ControlScheme] = []
	for scheme in _schemes.values():
		schemes.append(scheme)
	return schemes


func uses_auto_jump() -> bool:
	return config.auto_jump_enabled and _current != null and _current.uses_auto_jump()


## Solicita um pulo no próximo frame de física (usado pelo AutoJumpController).
func request_jump() -> void:
	_pending_jump = true


func set_control_scheme(scheme_id: StringName, persist: bool = true) -> void:
	config.selected_control_scheme = scheme_id
	_activate_scheme(scheme_id)
	if persist:
		save_preferences()


## Aplica novos valores (ex.: vindos do painel) e reinicializa o método selecionado.
func apply_config(values: ControlConfig, persist: bool = true) -> void:
	config.copy_values_from(values)
	_activate_scheme(config.selected_control_scheme)
	config_applied.emit(config)
	if persist:
		save_preferences()


func save_preferences() -> void:
	if persist_preferences:
		ControlPreferences.save(config, default_config)


## Registra a inclinação atual como posição neutra. Retorna false quando não há sensor real.
func calibrate_gyroscope(persist: bool = true) -> bool:
	for scheme in _schemes.values():
		if scheme is GyroscopeControl:
			var has_sensor: bool = scheme.calibrate()
			if persist:
				save_preferences()
			return has_sensor
	return false


func get_camera_rotate_axis() -> float:
	if not enabled or not config.camera_control_enabled or _is_transition_locked():
		return 0.0
	return Input.get_axis(camera_left_action, camera_right_action)


func consume_camera_drag() -> float:
	var drag := controls_ui.camera_drag_area.consume_drag() if controls_ui else 0.0
	if not enabled or not config.camera_control_enabled or _current == null or not _current.allows_camera_drag():
		return 0.0
	return 0.0 if _is_transition_locked() else drag


func is_pause_just_pressed() -> bool:
	return not _is_transition_locked() and Input.is_action_just_pressed(pause_action)


func get_debug_text() -> String:
	var lines := PackedStringArray()
	lines.append("CONTROL: %s" % (String(_current.scheme_id).to_upper() if _current else "-"))
	lines.append("MOVE: %s (%.2f)" % [_describe_axis(_state.move_axis), _state.move_axis])
	lines.append("AUTO JUMP: %s" % ("ON" if uses_auto_jump() else "OFF"))
	if _current:
		lines.append_array(_current.get_debug_lines())
	return "\n".join(lines)


func _physics_process(delta: float) -> void:
	_state.begin_frame(_current.scheme_id if _current else &"")
	if enabled and _current and not _is_transition_locked():
		_current.collect(_state, delta)
		if _is_keyboard_fallback_active():
			_merge_keyboard()
		if _pending_jump:
			_state.jump_pressed = true
		_state.confirm_pressed = _state.jump_pressed or _pending_confirm
	_pending_jump = false
	_pending_confirm = false
	_state.move_axis = clampf(_state.move_axis, -1.0, 1.0)
	_update_debug(delta)


## Toques que a interface não consumiu (não sobre botões) contam como confirmação.
func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventScreenTouch and event.pressed) \
			or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_pending_confirm = true


func _notification(what: int) -> void:
	# Toques soltos durante a pausa não chegam ao método: limpa para não "grudar" movimento.
	if what == NOTIFICATION_PAUSED and _current:
		_current.clear_state()


## Durante transições o input é ignorado; comandos acumulados nesse período são descartados.
func _is_transition_locked() -> bool:
	return TransitionManager.is_input_locked()


func _on_transition_finished(_config: TransitionConfig) -> void:
	if _current:
		_current.clear_state()


func _activate_scheme(scheme_id: StringName) -> void:
	var next: ControlScheme = _schemes.get(scheme_id)
	if next == null:
		push_warning("Método de controle desconhecido: %s" % scheme_id)
		next = _schemes.values()[0] if not _schemes.is_empty() else null
	if _current:
		_current.deactivate()
	_current = next
	_pending_jump = false
	_state.begin_frame(&"")
	if _current:
		config.selected_control_scheme = _current.scheme_id
		_current.activate()
		control_scheme_changed.emit(_current.scheme_id)
	if controls_ui:
		controls_ui.set_debug_visible(config.show_control_debug)


## Fallback de desenvolvimento: teclado no PC.
func _is_keyboard_fallback_active() -> bool:
	return config.keyboard_fallback_enabled and not OS.has_feature("mobile")


func _merge_keyboard() -> void:
	if _current.merges_keyboard_movement():
		var axis := Input.get_axis(move_left_action, move_right_action)
		if absf(axis) > absf(_state.move_axis):
			_state.move_axis = axis
	if Input.is_action_just_pressed(jump_action):
		_state.jump_pressed = true
	if Input.is_action_pressed(jump_action):
		_state.jump_held = true


func _update_debug(delta: float) -> void:
	if controls_ui == null or not config.show_control_debug:
		return
	_debug_time_left -= delta
	if _debug_time_left > 0.0:
		return
	_debug_time_left = debug_refresh_interval
	controls_ui.set_debug_text(get_debug_text())


func _describe_axis(axis: float) -> String:
	if axis < -0.01:
		return "LEFT"
	if axis > 0.01:
		return "RIGHT"
	return "NONE"
