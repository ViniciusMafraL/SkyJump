class_name TouchDragArea
extends Control
## Região da tela que converte arrastes horizontais em rotação de câmera.
## Toques iniciados sobre `excluded_controls` visíveis (ex.: botões virtuais) são ignorados.

var excluded_controls: Array[Control] = []

var _touch_index: int = -1
var _accumulated_drag: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed and _touch_index == -1 and _accepts_touch_at(touch.position):
			_touch_index = touch.index
		elif not touch.pressed and touch.index == _touch_index:
			_touch_index = -1
	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _touch_index:
			_accumulated_drag += drag.relative.x / get_viewport_rect().size.x


func consume_drag() -> float:
	var drag := _accumulated_drag
	_accumulated_drag = 0.0
	return drag


func _accepts_touch_at(point: Vector2) -> bool:
	if not is_visible_in_tree() or not get_global_rect().has_point(point):
		return false
	for control in excluded_controls:
		if control.is_visible_in_tree() and control.get_global_rect().has_point(point):
			return false
	return true
