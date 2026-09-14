class_name InputController
extends Node
## Interface de input consumida pelo jogo. O PlayerController recebe apenas PlayerInputState;
## CameraRig e GameManager usam os métodos de câmera e pausa.

var enabled: bool = true

var _empty_state := PlayerInputState.new()


func get_player_input_state() -> PlayerInputState:
	return _empty_state


## Rotação contínua da câmera: -1..1.
func get_camera_rotate_axis() -> float:
	return 0.0


## Arraste horizontal acumulado desde a última chamada, em frações da largura da tela.
func consume_camera_drag() -> float:
	return 0.0


func is_pause_just_pressed() -> bool:
	return false
