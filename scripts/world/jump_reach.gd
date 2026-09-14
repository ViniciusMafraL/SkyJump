class_name JumpReach
extends RefCounted
## Cálculos de alcance do salto, usados pelo gerador para nunca criar plataformas inalcançáveis.
## `launch_speed` < 0 usa a força do pulo normal; trampolins passam a própria força.


## Tempo até aterrissar numa superfície `vertical_gap` acima do ponto de partida, já descendo.
## Retorna -1 se a altura for inalcançável.
static func time_to_land(movement: PlayerMovementConfig, vertical_gap: float, launch_speed: float = -1.0) -> float:
	var speed := movement.jump_force if launch_speed < 0.0 else launch_speed
	var discriminant := speed * speed - 2.0 * movement.gravity * vertical_gap
	if discriminant < 0.0:
		return -1.0
	return (speed + sqrt(discriminant)) / movement.gravity


## Distância horizontal (arco) alcançável num salto que termina `vertical_gap` acima.
## Conservador: assume que o jogador sai parado e acelera apenas com o controle aéreo.
static func horizontal_reach(movement: PlayerMovementConfig, vertical_gap: float, launch_speed: float = -1.0) -> float:
	var air_time := time_to_land(movement, vertical_gap, launch_speed)
	var acceleration := movement.ground_acceleration * movement.air_control
	if air_time <= 0.0 or acceleration <= 0.0:
		return 0.0
	var speed := movement.horizontal_speed
	if air_time <= speed / acceleration:
		return 0.5 * acceleration * air_time * air_time
	return speed * air_time - speed * speed / (2.0 * acceleration)
