class_name VirtualButton
extends Control
## Botão touch com multitoque. Não conhece ações de gameplay: apenas informa se está pressionado.
## Arrastar o dedo para fora solta o botão; arrastar para dentro pressiona.

signal pressed_down
signal released

@export var pressed_modulate: Color = Color(1.0, 1.0, 1.0, 0.95)
@export var released_modulate: Color = Color(1.0, 1.0, 1.0, 0.55)

var _touch_index: int = -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh_modulate()


func is_held() -> bool:
	return _touch_index != -1


func set_opacity(released_alpha: float, pressed_alpha: float) -> void:
	released_modulate.a = released_alpha
	pressed_modulate.a = pressed_alpha
	_refresh_modulate()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _touch_index == -1 and _is_inside(touch.position):
			_press(touch.index)
		elif not touch.pressed and touch.index == _touch_index:
			_release()
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		var inside := _is_inside(drag.position)
		if drag.index == _touch_index and not inside:
			_release()
		elif _touch_index == -1 and inside:
			_press(drag.index)


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and not is_visible_in_tree():
		_release()
	elif what == NOTIFICATION_EXIT_TREE:
		_release()


func _is_inside(point: Vector2) -> bool:
	return is_visible_in_tree() and get_global_rect().has_point(point)


func _press(index: int) -> void:
	_touch_index = index
	_refresh_modulate()
	pressed_down.emit()


func _release() -> void:
	if _touch_index == -1:
		return
	_touch_index = -1
	_refresh_modulate()
	released.emit()


func _refresh_modulate() -> void:
	modulate = pressed_modulate if is_held() else released_modulate
