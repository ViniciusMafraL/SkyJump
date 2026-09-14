class_name Platform
extends Node3D
## Plataforma de gameplay. A colisão é calculada em coordenadas cilíndricas e não depende do Visual.
## Tipos especiais estendem este script e sobrescrevem os métodos de interação.

@onready var collision: PlatformCollision = $Collision
@onready var visual: PlatformVisual = $Visual

var data: PlatformData
## Estado atual (pode diferir de `data` em plataformas móveis).
var current_angle: float = 0.0
var current_radius: float = 0.0

var _solid: bool = true


func setup(platform_data: PlatformData, theme: ThemeData) -> void:
	data = platform_data
	current_angle = data.angle
	current_radius = data.radius
	_solid = true
	collision.size = Vector2(data.width, data.depth)
	_sync_transform(data.height)
	visual.apply(data, theme)
	reset_physics_interpolation()


func get_top_height() -> float:
	return position.y


func is_solid() -> bool:
	return _solid


func contains(angle: float, radius: float, margin: float) -> bool:
	return collision.contains(angle_difference(current_angle, angle), radius, current_radius, margin)


func allows_auto_jump() -> bool:
	return data == null or data.config == null or data.config.auto_jump_enabled


func on_player_landed(_player: PlayerController) -> void:
	pass


func on_player_left(_player: PlayerController) -> void:
	pass


func _sync_transform(top_height: float) -> void:
	# Eixo local X aponta para fora do cilindro; eixo Z segue a tangente.
	position = Vector3(cos(current_angle) * current_radius, top_height, sin(current_angle) * current_radius)
	rotation = Vector3(0.0, -current_angle, 0.0)
