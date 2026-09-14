class_name TouchInvisibleControl
extends ControlScheme
## Método 1: tocar na metade esquerda/direita da tela move o personagem. Pulo automático.
## Toques sobre botões da interface são consumidos pela GUI e não chegam a este método.

## Índice do toque -> lado (-1 ou 1), em ordem de chegada (o último vale).
var _touch_sides: Dictionary = {}
var _idle_time: float = 0.0


func activate() -> void:
	super.activate()
	set_process_unhandled_input(true)
	_idle_time = 0.0
	var ui := _ui()
	ui.visible = true
	ui.apply_config(_config())
	if _config().control_hint_enabled:
		ui.show_hint(_config().control_hint_timeout)


func deactivate() -> void:
	super.deactivate()
	set_process_unhandled_input(false)
	var ui := _ui()
	ui.hide_hint(true)
	ui.visible = false


func clear_state() -> void:
	_touch_sides.clear()


func collect(state: PlayerInputState, delta: float) -> void:
	var config := _config()
	if not _touch_sides.is_empty():
		state.move_axis = float(_touch_sides.values().back()) * config.touch_sensitivity
		_idle_time = 0.0
		return
	# Sem toque por um tempo: mostra a dica "< >" novamente.
	if config.control_hint_enabled and config.control_hint_repeat_delay > 0.0 and not _ui().is_hint_visible():
		_idle_time += delta
		if _idle_time >= config.control_hint_repeat_delay:
			_idle_time = 0.0
			_ui().show_hint(config.control_hint_timeout)


func get_side_for_position(x: float) -> float:
	return -1.0 if x < get_viewport().get_visible_rect().size.x * _config().split_ratio else 1.0


func get_debug_lines() -> PackedStringArray:
	return PackedStringArray(["TOUCHES: %d" % _touch_sides.size()])


func _unhandled_input(event: InputEvent) -> void:
	if not is_active or not manager.controls_ui.is_visible_in_tree():
		return
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_register_touch(touch.index, get_side_for_position(touch.position.x))
		else:
			_touch_sides.erase(touch.index)
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if _touch_sides.has(drag.index):
			var side := get_side_for_position(drag.position.x)
			if side != _touch_sides[drag.index]:
				_register_touch(drag.index, side)


func _register_touch(index: int, side: float) -> void:
	# Reinserir coloca o toque como o mais recente.
	_touch_sides.erase(index)
	_touch_sides[index] = side
	_ui().hide_hint(false)
	if _config().feedback_enabled:
		_ui().flash_side(side)


func _config() -> TouchControlConfig:
	return manager.config.touch_config


func _ui() -> TouchControlUI:
	return manager.controls_ui.touch_ui
