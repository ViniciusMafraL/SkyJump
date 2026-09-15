class_name VineConfig
extends Resource
## Parâmetros das VINHAS ESCALÁVEIS. Apenas os pontos jogáveis; o visual é separado.

enum VineDirection { VERTICAL, DIAGONAL }

@export_group("Points")
@export var point_count: int = 6
## Distância vertical entre pontos de apoio.
@export var spacing: float = 2.0
## Largura de cada ponto ao longo da circunferência.
@export var point_size: float = 1.2
## Profundidade radial (precisa alcançar a trajetória do personagem).
@export var point_depth: float = 3.0

@export_group("Shape")
@export var direction: VineDirection = VineDirection.VERTICAL
## Inclinação da vinha DIAGONAL (graus a partir da vertical, para a direita do objeto).
@export_range(-60.0, 60.0, 1.0) var inclination_degrees: float = 25.0


func get_point_offset(index: int) -> Vector2:
	var y := index * spacing
	var x := 0.0
	if direction == VineDirection.DIAGONAL:
		x = y * tan(deg_to_rad(inclination_degrees))
	return Vector2(x, y)
