class_name ButtonControlUI
extends Control
## Visual dos botões na parte inferior da tela: [<] à esquerda, [PULAR] no centro, [>] à direita.

signal jump_pressed

@onready var _left: VirtualButton = $LeftButton
@onready var _jump: VirtualButton = $JumpButton
@onready var _right: VirtualButton = $RightButton


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_jump.pressed_down.connect(jump_pressed.emit)


func apply_config(config: ButtonControlConfig) -> void:
	_place(_left, 0.0, config.button_size, config.screen_margin)
	_place(_jump, 0.5, config.jump_button_size, config.screen_margin)
	_place(_right, 1.0, config.button_size, config.screen_margin)
	for button: VirtualButton in [_left, _jump, _right]:
		button.set_opacity(config.button_opacity, config.pressed_opacity)


func get_buttons() -> Array[Control]:
	var buttons: Array[Control] = [_left, _jump, _right]
	return buttons


func is_left_held() -> bool:
	return _left.is_held()


func is_right_held() -> bool:
	return _right.is_held()


func is_jump_held() -> bool:
	return _jump.is_held()


## Ancora o botão na base da tela: anchor_x 0 = esquerda, 0.5 = centro, 1 = direita.
func _place(button: Control, anchor_x: float, button_size: float, margin: float) -> void:
	button.anchor_left = anchor_x
	button.anchor_right = anchor_x
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	var left := -button_size * 0.5
	if anchor_x <= 0.0:
		left = margin
	elif anchor_x >= 1.0:
		left = -margin - button_size
	button.offset_left = left
	button.offset_right = left + button_size
	button.offset_top = -margin - button_size
	button.offset_bottom = -margin
