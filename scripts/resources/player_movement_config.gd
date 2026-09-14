class_name PlayerMovementConfig
extends Resource
## Parâmetros de movimento e pulo do personagem.
## Também é lido pelo gerador procedural para garantir que toda plataforma seja alcançável.

@export_group("Horizontal")
## Velocidade máxima ao redor do cilindro, em unidades de arco por segundo.
@export var horizontal_speed: float = 7.0
@export var ground_acceleration: float = 45.0
@export var ground_deceleration: float = 60.0
## Fração da aceleração disponível no ar (0 = sem controle aéreo, 1 = igual ao chão).
@export_range(0.0, 1.0) var air_control: float = 0.75

@export_group("Jump")
@export var jump_force: float = 14.0
@export var gravity: float = 32.0
@export var fall_speed_limit: float = 40.0
@export var jump_cooldown: float = 0.1
## Tempo após sair da borda em que o pulo ainda é aceito.
@export var coyote_time: float = 0.1
## Tempo em que um toque de pulo antecipado fica guardado antes de aterrissar.
@export var jump_buffer_time: float = 0.12

@export_group("Collision")
## Tolerância lateral dos pés ao verificar se o personagem está sobre uma plataforma.
@export var foot_radius: float = 0.3


## Altura do pulo derivada de jump_force e gravity (h = F² / 2g).
## Não é salva: alterar este valor recalcula jump_force mantendo a gravidade.
var jump_height: float:
	get:
		return get_max_jump_height()
	set(value):
		jump_force = sqrt(2.0 * gravity * maxf(value, 0.0))


func get_max_jump_height() -> float:
	return jump_force * jump_force / (2.0 * gravity)
