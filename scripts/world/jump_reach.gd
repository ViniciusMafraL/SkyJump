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


## Altura máxima atingida por uma velocidade vertical inicial.
static func apex_height(movement: PlayerMovementConfig, vertical_speed: float) -> float:
	return vertical_speed * vertical_speed / (2.0 * movement.gravity) if vertical_speed > 0.0 else 0.0


## Tempo até pousar `height_gap` acima (negativo = abaixo) do ponto de lançamento, já descendo.
## Retorna -1 se a altura for inalcançável.
static func launch_landing_time(movement: PlayerMovementConfig, vertical_speed: float, height_gap: float) -> float:
	var discriminant := vertical_speed * vertical_speed - 2.0 * movement.gravity * height_gap
	if discriminant < 0.0:
		return -1.0
	return (vertical_speed + sqrt(discriminant)) / movement.gravity


## Distância tangencial percorrida pelo impulso lateral de um lançamento (decai com launch_momentum_drag).
static func momentum_distance(movement: PlayerMovementConfig, tangential_speed: float, time: float) -> float:
	var drag := movement.launch_momentum_drag
	if drag <= 0.0:
		return tangential_speed * time
	var moving_time := minf(time, absf(tangential_speed) / drag)
	return signf(tangential_speed) * (absf(tangential_speed) * moving_time - 0.5 * drag * moving_time * moving_time)


## Deslocamento tangencial ao pousar `height_gap` acima do ponto de um lançamento (x = tangencial,
## y = vertical), sem input do jogador. NAN se a altura for inalcançável.
static func launch_landing_offset(movement: PlayerMovementConfig, launch: Vector2, height_gap: float) -> float:
	var time := launch_landing_time(movement, launch.y, height_gap)
	return NAN if time < 0.0 else momentum_distance(movement, launch.x, time)
