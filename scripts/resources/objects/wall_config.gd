class_name WallConfig
extends Resource
## Parâmetros da PLATAFORMA-PAREDE.

enum JumpDirection { AWAY_FROM_WALL, OBJECT_RIGHT, OBJECT_LEFT }

@export_group("Shape")
@export var wall_height: float = 7.0
## Espessura ao longo da circunferência.
@export var wall_thickness: float = 0.6
## Altura do corpo do personagem considerada no contato com a parede.
@export var body_height: float = 0.7

@export_group("Support")
## Tempo (s) grudado na parede antes do salto automático. Apertar pulo antecipa.
@export var support_time: float = 0.3
## Velocidade máxima de queda enquanto grudado.
@export var slide_speed: float = 1.5

@export_group("Jump")
## Velocidade total do salto na parede.
@export var jump_force: float = 17.0
## Ângulo do salto acima da horizontal (graus).
@export_range(0.0, 90.0, 1.0) var jump_angle_degrees: float = 62.0
@export var jump_direction: JumpDirection = JumpDirection.AWAY_FROM_WALL
## Tempo (s) em que esta parede não pode ser agarrada de novo após um salto.
@export var cooldown: float = 0.35
