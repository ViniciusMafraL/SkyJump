class_name DiagonalTrampolineConfig
extends Resource
## Parâmetros do TRAMPOLIM DIAGONAL. A direção é relativa à orientação do objeto.

enum LaunchDirection { RIGHT, LEFT }

@export_group("Gameplay")
@export var vertical_force: float = 18.0
## Velocidade lateral inicial (vira momentum que decai com launch_momentum_drag do personagem).
@export var horizontal_force: float = 10.0
## Lado do objeto para o qual o personagem é lançado (flip do objeto espelha).
@export var launch_direction: LaunchDirection = LaunchDirection.RIGHT
@export var cooldown: float = 0.25

@export_group("Visual")
## Inclinação visual do pad na direção do lançamento.
@export_range(0.0, 60.0, 1.0) var pad_tilt_degrees: float = 25.0


## Vetor de lançamento no espaço do objeto (x = direita do objeto, y = cima).
func get_local_launch() -> Vector2:
	var side := 1.0 if launch_direction == LaunchDirection.RIGHT else -1.0
	return Vector2(horizontal_force * side, vertical_force)
