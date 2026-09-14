class_name PlatformCollision
extends Node
## Colisão de gameplay: caixa tangente ao cilindro, testada em coordenadas cilíndricas.
## Plataformas são atravessáveis por baixo (one-way), como em um platformer arcade.

## x = largura tangencial, y = profundidade radial.
var size: Vector2 = Vector2.ONE


func contains(angle_offset: float, point_radius: float, platform_radius: float, margin: float) -> bool:
	if absf(angle_offset) >= PI * 0.5:
		return false
	var tangential := sin(angle_offset) * point_radius
	var radial := cos(angle_offset) * point_radius - platform_radius
	return absf(tangential) <= size.x * 0.5 + margin and absf(radial) <= size.y * 0.5 + margin
