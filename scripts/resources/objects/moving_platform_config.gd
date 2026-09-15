class_name MovingPlatformConfig
extends Resource
## Parâmetros da PLATAFORMA MÓVEL. Offsets: x = direita do objeto, y = altura.

enum MovementType { HORIZONTAL, VERTICAL, DIAGONAL, CUSTOM }

@export_group("Trajectory")
@export var movement_type: MovementType = MovementType.HORIZONTAL
## Distância percorrida (HORIZONTAL, VERTICAL e DIAGONAL).
@export var distance: float = 4.0
## Inclinação do movimento DIAGONAL (graus acima da horizontal).
@export_range(-90.0, 90.0, 1.0) var diagonal_angle_degrees: float = 45.0
## Posição inicial e final usadas pelo tipo CUSTOM.
@export var start_offset: Vector2 = Vector2.ZERO
@export var end_offset: Vector2 = Vector2(4.0, 2.0)
## Trajetória própria (opcional). Quando definida, substitui o tipo de movimento.
@export var trajectory: PlatformTrajectory

@export_group("Movement")
## Velocidade máxima (unidades/s).
@export var speed: float = 2.5
## Aceleração e desaceleração (unidades/s²). 0 = instantânea.
@export var acceleration: float = 5.0
@export var deceleration: float = 5.0

@export_group("Cycle")
## Ao chegar ao destino, volta pelo mesmo caminho.
@export var ping_pong: bool = true
## Repete o ciclo indefinidamente. Sem ping-pong, recomeça da posição inicial.
@export var loop: bool = true
## Espera (s) em cada extremidade.
@export var wait_time: float = 0.6


func build_trajectory() -> PlatformTrajectory:
	if trajectory:
		return trajectory
	var linear := LinearTrajectory.new()
	match movement_type:
		MovementType.HORIZONTAL:
			linear.end_offset = Vector2(distance, 0.0)
		MovementType.VERTICAL:
			linear.end_offset = Vector2(0.0, distance)
		MovementType.DIAGONAL:
			linear.end_offset = Vector2.from_angle(deg_to_rad(diagonal_angle_degrees)) * distance
		MovementType.CUSTOM:
			linear.start_offset = start_offset
			linear.end_offset = end_offset
	return linear
