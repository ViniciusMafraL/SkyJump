class_name TouchControlUI
extends Control
## Visual do toque invisível: dica "< >" temporária e brilho breve no lado tocado.

@export var hint_fade_duration: float = 0.25
@export var feedback_duration: float = 0.3

var _feedback_opacity: float = 0.12
var _hint_tween: Tween
var _feedback_tweens: Dictionary = {}

@onready var _hint: Control = $Hint
@onready var _left_feedback: ColorRect = $LeftFeedback
@onready var _right_feedback: ColorRect = $RightFeedback


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hint.visible = false
	_hint.modulate.a = 0.0
	_left_feedback.color.a = 0.0
	_right_feedback.color.a = 0.0


func apply_config(config: TouchControlConfig) -> void:
	_feedback_opacity = config.feedback_opacity
	_left_feedback.anchor_right = config.split_ratio
	_right_feedback.anchor_left = config.split_ratio


func show_hint(duration: float) -> void:
	_kill_hint_tween()
	_hint.visible = true
	_hint_tween = create_tween()
	_hint_tween.tween_property(_hint, "modulate:a", 1.0, hint_fade_duration)
	_hint_tween.tween_interval(maxf(duration, 0.0))
	_hint_tween.tween_property(_hint, "modulate:a", 0.0, hint_fade_duration)
	_hint_tween.tween_callback(_hint.hide)


func hide_hint(immediate: bool) -> void:
	if not _hint.visible:
		return
	_kill_hint_tween()
	if immediate:
		_hint.modulate.a = 0.0
		_hint.hide()
		return
	_hint_tween = create_tween()
	_hint_tween.tween_property(_hint, "modulate:a", 0.0, hint_fade_duration)
	_hint_tween.tween_callback(_hint.hide)


func is_hint_visible() -> bool:
	return _hint.visible


func flash_side(side: float) -> void:
	var rect := _left_feedback if side < 0.0 else _right_feedback
	var previous: Tween = _feedback_tweens.get(rect)
	if previous and previous.is_valid():
		previous.kill()
	rect.color.a = _feedback_opacity
	var tween := create_tween()
	tween.tween_property(rect, "color:a", 0.0, feedback_duration)
	_feedback_tweens[rect] = tween


func _kill_hint_tween() -> void:
	if _hint_tween and _hint_tween.is_valid():
		_hint_tween.kill()
