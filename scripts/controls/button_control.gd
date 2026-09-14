class_name ButtonControl
extends ControlScheme
## Método 3: botões esquerda/direita com movimento contínuo e botão de pulo manual.
## O botão só gera o comando; o PlayerController decide se o salto é válido (chão, cooldown).

var _jump_requested: bool = false


func activate() -> void:
	super.activate()
	var ui := _ui()
	if not ui.jump_pressed.is_connected(_on_jump_pressed):
		ui.jump_pressed.connect(_on_jump_pressed)
	ui.apply_config(manager.config.button_config)
	ui.visible = true


func deactivate() -> void:
	super.deactivate()
	_ui().visible = false


func clear_state() -> void:
	_jump_requested = false


func collect(state: PlayerInputState, _delta: float) -> void:
	var ui := _ui()
	state.move_axis = (1.0 if ui.is_right_held() else 0.0) - (1.0 if ui.is_left_held() else 0.0)
	state.jump_held = ui.is_jump_held()
	if _jump_requested:
		state.jump_pressed = true
		_jump_requested = false


func uses_auto_jump() -> bool:
	return false


func get_debug_lines() -> PackedStringArray:
	return PackedStringArray(["JUMP: %s" % ("PRESSED" if _ui().is_jump_held() else "READY")])


## Um comando por toque: segurar o botão não repete o pulo.
func _on_jump_pressed() -> void:
	if is_active:
		_jump_requested = true


func _ui() -> ButtonControlUI:
	return manager.controls_ui.button_ui
