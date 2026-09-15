class_name StairConfig
extends Resource
## Parâmetros da PLATAFORMA ESCADA.

enum StairType { STRAIGHT, DIAGONAL, ZIGZAG, ALTERNATING }

@export_group("Layout")
@export var stair_type: StairType = StairType.DIAGONAL
@export var step_count: int = 6
## Distância entre degraus ao longo da circunferência (DIAGONAL, ZIGZAG, ALTERNATING).
@export var horizontal_distance: float = 1.8
@export var vertical_distance: float = 1.6
## Gira o padrão da escada no plano da superfície (graus).
@export_range(-90.0, 90.0, 1.0) var rotation_degrees: float = 0.0
## Degraus por trecho antes de inverter a direção (ZIGZAG).
@export var zigzag_segment: int = 3

@export_group("Steps")
## Largura de cada degrau ao longo da circunferência.
@export var step_width: float = 1.4
## Profundidade radial (precisa alcançar a trajetória do personagem).
@export var step_depth: float = 3.0


## Offset do degrau `index` (x = direita do objeto, y = cima), antes da rotação.
func get_step_offset(index: int) -> Vector2:
	var offset := Vector2(0.0, index * vertical_distance)
	match stair_type:
		StairType.DIAGONAL:
			offset.x = index * horizontal_distance
		StairType.ZIGZAG:
			var segment := maxi(zigzag_segment, 1)
			var phase := index % (segment * 2)
			offset.x = (phase if phase <= segment else segment * 2 - phase) * horizontal_distance
		StairType.ALTERNATING:
			offset.x = (0.5 if index % 2 == 1 else -0.5) * horizontal_distance
	return offset.rotated(deg_to_rad(rotation_degrees))
