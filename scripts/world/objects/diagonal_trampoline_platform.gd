class_name DiagonalTrampolinePlatform
extends Platform
## TRAMPOLIM DIAGONAL: lança o personagem para cima e para o lado.
## A direção vem da orientação do próprio objeto (config.launch_direction + flip),
## nunca de eixos globais: funciona em qualquer posição do cilindro.

@export var config: DiagonalTrampolineConfig

@export_group("Visual")
@export var pad_color: Color = Color(1.0, 0.55, 0.85)
@export var arrow_color: Color = Color(1.0, 0.95, 0.4)

var _ready_at_msec: int = 0

@onready var _pad: MeshInstance3D = $Visual/Pad
@onready var _arrow: MeshInstance3D = $Visual/Arrow


func get_settings_section() -> StringName:
	return &"diagonal_trampoline"


## (x = velocidade tangencial do personagem, y = vertical).
func get_launch_vector() -> Vector2:
	return local_direction(config.get_local_launch()) if config else Vector2.ZERO


func reset() -> void:
	_ready_at_msec = 0
	_update_visual()


func get_state_name() -> String:
	var launch := get_launch_vector()
	return "lança (%+.1f, %.1f)" % [launch.x, launch.y]


func on_player_landed(player: PlayerController) -> void:
	if config == null:
		return
	var now := Time.get_ticks_msec()
	if now < _ready_at_msec:
		return
	_ready_at_msec = now + roundi(config.cooldown * 1000.0)
	var launch := get_launch_vector()
	player.launch(launch.y, launch.x, &"diagonal_trampoline")
	visual.play_bounce()
	play_sound(Sound.LAUNCH)


func trigger_debug(player: PlayerController) -> void:
	if player.current_platform == self:
		_ready_at_msec = 0
		on_player_landed(player)


func _on_setup() -> void:
	super._on_setup()
	_update_visual()


func _on_theme_applied() -> void:
	super._on_theme_applied()
	_update_visual()


## Pad inclinado e seta apontando para a direção real do lançamento.
## Local +Z = esquerda da tela, então uma direção tangencial positiva (direita) é -Z.
func _update_visual() -> void:
	if config == null or data == null:
		return
	var launch := get_launch_vector()
	var side := signf(launch.x)
	_pad.scale = Vector3(data.depth * 0.8, 1.0, data.width * 0.8)
	_pad.position = Vector3(0.0, 0.12, 0.0)
	_pad.rotation = Vector3(-side * deg_to_rad(config.pad_tilt_degrees), 0.0, 0.0)
	_pad.material_override = theme_secondary_material(pad_color)
	var direction := launch.normalized()
	var length := 0.6 + launch.length() * 0.04
	_arrow.scale = Vector3(1.0, length, 1.0)
	_arrow.rotation = Vector3(atan2(-direction.x, direction.y), 0.0, 0.0)
	_arrow.position = Vector3(0.0, 0.25, 0.0) + Vector3(0.0, direction.y, -direction.x) * length * 0.5
	_arrow.material_override = _material(arrow_color)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color * 0.25
	return material


func _draw_debug(draw: ObjectDebugDraw) -> void:
	var launch := get_launch_vector()
	var gravity := GameplayObject.debug_movement.gravity if GameplayObject.debug_movement else 32.0
	draw.launch_arc(current_angle, current_height, current_radius, launch, GameplayObject.debug_movement, Color.YELLOW, 2.0 * launch.y / gravity)
