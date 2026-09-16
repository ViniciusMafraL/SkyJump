class_name UiFeedback
extends RefCounted
## Feedback sutil de interação: escala leve no hover, "aperto" ao pressionar e pop ao selecionar.
## Só visual: não altera sinais nem o estado dos botões.

const HOVER_SCALE := 1.03
const PRESS_SCALE := 0.94
const META_ATTACHED := &"_ui_feedback"
const META_TWEEN := &"_ui_feedback_tween"


static func attach(button: BaseButton, hover_scale: float = HOVER_SCALE, press_scale: float = PRESS_SCALE) -> void:
	if button.has_meta(META_ATTACHED):
		return
	button.set_meta(META_ATTACHED, true)
	var center_pivot := func() -> void: button.pivot_offset = button.size * 0.5
	button.resized.connect(center_pivot)
	center_pivot.call()
	button.mouse_entered.connect(func() -> void:
		if not button.disabled:
			_scale_to(button, hover_scale, 0.12))
	button.mouse_exited.connect(func() -> void: _scale_to(button, 1.0, 0.12))
	button.button_down.connect(func() -> void: _scale_to(button, press_scale, 0.06))
	button.button_up.connect(func() -> void:
		_scale_to(button, hover_scale if button.is_hovered() and not button.disabled else 1.0, 0.18, true))


## Aplica o feedback em todos os botões descendentes de `root`.
static func attach_all(root: Node) -> void:
	for child in root.find_children("*", "BaseButton", true, false):
		attach(child as BaseButton)


## Pop curto (ex.: dia selecionado no calendário).
static func pop(control: Control, peak: float = 1.12) -> void:
	control.pivot_offset = control.size * 0.5
	var tween := _new_tween(control)
	control.scale = Vector2.ONE * peak
	tween.tween_property(control, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func _scale_to(control: Control, target: float, duration: float, bounce: bool = false) -> void:
	if not control.is_inside_tree():
		return
	var tween := _new_tween(control)
	var step := tween.tween_property(control, "scale", Vector2.ONE * target, duration)
	if bounce:
		step.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


static func _new_tween(control: Control) -> Tween:
	if control.has_meta(META_TWEEN):
		var previous := control.get_meta(META_TWEEN) as Tween
		if previous and previous.is_valid():
			previous.kill()
	var tween := control.create_tween()
	control.set_meta(META_TWEEN, tween)
	return tween
