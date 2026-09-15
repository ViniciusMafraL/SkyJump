class_name Platform
extends GameplayObject
## Plataforma de gameplay. A colisão é calculada em coordenadas cilíndricas e não depende do Visual.
## Tipos especiais estendem este script e sobrescrevem os métodos de interação.

@onready var collision: PlatformCollision = $Collision
@onready var visual: PlatformVisual = $Visual

var _solid: bool = true


func get_top_height() -> float:
	return current_height


## Topo no frame de física anterior. Plataformas que se movem retornam a altura antiga para a
## detecção de pouso não deixar o personagem atravessar uma plataforma subindo.
func get_previous_top_height() -> float:
	return current_height


## Verdadeiro enquanto a plataforma se desloca (o personagem entra no modo ON_MOVING_PLATFORM).
func is_moving() -> bool:
	return false


func is_solid() -> bool:
	return _solid


func contains(angle: float, radius: float, margin: float) -> bool:
	return collision.contains(angle_difference(current_angle, angle), radius, current_radius, margin)


func allows_auto_jump() -> bool:
	return data == null or data.config == null or data.config.auto_jump_enabled


func get_platforms() -> Array[Platform]:
	return [self]


func on_player_landed(_player: PlayerController) -> void:
	pass


func on_player_left(_player: PlayerController) -> void:
	pass


func _on_setup() -> void:
	_solid = true
	collision.size = Vector2(data.width, data.depth)
	visual.apply(data, _theme)


func _on_theme_applied() -> void:
	visual.apply(data, _theme)
