class_name PlayerInputState
extends RefCounted
## Comandos abstratos entregues ao PlayerController, independentes do método de controle.

## -1 = esquerda da tela, 0 = parado, 1 = direita da tela (valores intermediários = mais lento).
var move_axis: float = 0.0
## Verdadeiro apenas no frame de física em que o pulo foi solicitado.
var jump_pressed: bool = false
var jump_held: bool = false
## Confirmação de ações de objetos (ex.: disparo do canhão): pulo ou toque em qualquer ponto da tela.
## Não gera pulo: só é lido por quem consulta este campo.
var confirm_pressed: bool = false
var control_scheme: StringName = &""


func begin_frame(scheme_id: StringName) -> void:
	move_axis = 0.0
	jump_pressed = false
	jump_held = false
	confirm_pressed = false
	control_scheme = scheme_id


func has_activity() -> bool:
	return not is_zero_approx(move_axis) or jump_pressed
