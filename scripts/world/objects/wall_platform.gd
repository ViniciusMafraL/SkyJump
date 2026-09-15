class_name WallPlatform
extends GameplayObject
## PLATAFORMA-PAREDE: pilar vertical que bloqueia a passagem lateral. No ar, ao encostar na face,
## o personagem quica na hora para longe do pilar, subindo (support_time = 0). Com support_time > 0
## ele gruda, escorrega e salta ao fim do apoio (apertar pulo antecipa).
## Tudo é calculado no espaço do cilindro (offset tangencial em relação ao centro da parede).

@export var config: WallConfig

@export_group("Visual")
@export var wall_color: Color = Color(0.55, 0.5, 0.62)
@export var arrow_color: Color = Color(1.0, 0.85, 0.3)

var _stuck_player: PlayerController
## +1 = personagem na face direita da parede, -1 = face esquerda.
var _stick_side: float = 0.0
var _stick_time: float = 0.0
var _ready_at_msec: int = 0

@onready var _mesh: MeshInstance3D = $Visual/Mesh
@onready var _arrow_right: MeshInstance3D = $Visual/ArrowRight
@onready var _arrow_left: MeshInstance3D = $Visual/ArrowLeft


func get_settings_section() -> StringName:
	return &"wall"


func blocks_player() -> bool:
	return config != null


func wants_player_updates() -> bool:
	return _stuck_player != null


func reset() -> void:
	_release_stuck()
	_ready_at_msec = 0
	_stick_time = 0.0
	_update_visual()


func get_state_name() -> String:
	if _stuck_player:
		return "GRUDADO %.2fs" % _stick_time
	return "COOLDOWN" if Time.get_ticks_msec() < _ready_at_msec else "PRONTA"


func trigger_debug(player: PlayerController) -> void:
	if _stuck_player == player:
		_wall_jump(player)


func get_contact_distance(player: PlayerController) -> float:
	return config.wall_thickness * 0.5 + player.movement.foot_radius


func constrain_player_angle(player: PlayerController, from_angle: float, to_angle: float) -> float:
	if not _overlaps_height(player):
		return to_angle
	var from_offset := CylinderSpace.tangent_offset(current_angle, from_angle, player.orbit_radius)
	# Do outro lado do cilindro a parede não interessa.
	if absf(from_offset) > player.orbit_radius * PI * 0.5:
		return to_angle
	var to_offset := CylinderSpace.tangent_offset(current_angle, to_angle, player.orbit_radius)
	var contact := get_contact_distance(player)
	var side := signf(from_offset) if not is_zero_approx(from_offset) else signf(to_offset)
	if is_zero_approx(side):
		side = 1.0
	if absf(to_offset) >= contact and signf(to_offset) == side:
		return to_angle
	_on_blocked(player, side)
	return CylinderSpace.angle_at(current_angle, side * contact, player.orbit_radius)


func update_player(player: PlayerController, delta: float) -> void:
	if player != _stuck_player:
		return
	var offset := CylinderSpace.tangent_offset(current_angle, player.angle, player.orbit_radius)
	if player.is_grounded() or player.is_captured() or player.mode != PlayerController.Mode.ON_WALL \
			or not _overlaps_height(player) or absf(offset) > get_contact_distance(player) + 0.05:
		_release_stuck()
		return
	player.set_cylindrical_position(CylinderSpace.angle_at(current_angle, _stick_side * get_contact_distance(player), player.orbit_radius), player.height)
	player.tangential_speed = 0.0
	player.launch_tangential_speed = 0.0
	player.vertical_velocity = maxf(player.vertical_velocity, -config.slide_speed)
	_stick_time += delta
	if player.is_jump_buffered() or _stick_time >= config.support_time:
		_wall_jump(player)


## Direção do salto no espaço do personagem (x = tangencial, y = vertical), para uma face.
func get_jump_vector(side: float) -> Vector2:
	var direction_sign := side
	match config.jump_direction:
		WallConfig.JumpDirection.OBJECT_RIGHT:
			direction_sign = get_object_sign()
		WallConfig.JumpDirection.OBJECT_LEFT:
			direction_sign = -get_object_sign()
	var direction := Vector2.from_angle(deg_to_rad(config.jump_angle_degrees))
	return Vector2(direction.x * direction_sign, direction.y) * config.jump_force


func _overlaps_height(player: PlayerController) -> bool:
	return player.height < current_height + config.wall_height and player.height + config.body_height > current_height


func _on_blocked(player: PlayerController, side: float) -> void:
	# Remove apenas a velocidade em direção à parede.
	if player.tangential_speed * side < 0.0:
		player.tangential_speed = 0.0
	if player.launch_tangential_speed * side < 0.0:
		player.launch_tangential_speed = 0.0
	if player.is_grounded() or _stuck_player != null or player.mode == PlayerController.Mode.ON_WALL:
		return
	if Time.get_ticks_msec() < _ready_at_msec:
		return
	if config.support_time <= 0.0:
		_bounce(player, side)
		return
	_stuck_player = player
	_stick_side = side
	_stick_time = 0.0
	player.set_mode(PlayerController.Mode.ON_WALL)
	play_sound(Sound.ACTIVATION)


func _wall_jump(player: PlayerController) -> void:
	_bounce(player, _stick_side)


## Lança o personagem para longe da face `side`. A velocidade de corrida contra o pilar é descartada.
func _bounce(player: PlayerController, side: float) -> void:
	var jump := get_jump_vector(side)
	player.consume_jump_buffer()
	_release_stuck()
	_ready_at_msec = Time.get_ticks_msec() + roundi(config.cooldown * 1000.0)
	player.launch(jump.y, jump.x, &"wall", true)
	play_sound(Sound.LAUNCH)


func _release_stuck() -> void:
	if _stuck_player and is_instance_valid(_stuck_player) and _stuck_player.mode == PlayerController.Mode.ON_WALL:
		_stuck_player.set_mode(PlayerController.Mode.NORMAL)
	_stuck_player = null


func _on_setup() -> void:
	_update_visual()


func _on_theme_applied() -> void:
	_update_visual()


## Local: X radial, Y altura, Z = esquerda da tela.
func _update_visual() -> void:
	if config == null or data == null or _mesh == null:
		return
	_mesh.scale = Vector3(data.depth, config.wall_height, config.wall_thickness)
	_mesh.position = Vector3(0.0, config.wall_height * 0.5, 0.0)
	_mesh.material_override = theme_primary_material(wall_color)
	var arrow_height := minf(config.wall_height * 0.5, 2.0)
	for pair in [[_arrow_right, 1.0], [_arrow_left, -1.0]]:
		var arrow: MeshInstance3D = pair[0]
		var side: float = pair[1]
		var jump := get_jump_vector(side * get_object_sign()).normalized()
		arrow.rotation = Vector3(atan2(-jump.x, jump.y), 0.0, 0.0)
		arrow.position = Vector3(data.depth * 0.5 + 0.05, arrow_height, -side * get_object_sign() * (config.wall_thickness * 0.5 + 0.35))
		arrow.material_override = theme_secondary_material(arrow_color)


func _draw_debug(draw: ObjectDebugDraw) -> void:
	if config == null:
		return
	var radius := current_radius + data.depth * 0.5
	for side in [1.0, -1.0]:
		var face := Vector2(side * config.wall_thickness * 0.5 + side * 0.4, 1.5)
		var face_world := CylinderSpace.surface_point(current_angle, current_height, radius, face)
		var jump := get_jump_vector(side)
		var gravity := GameplayObject.debug_movement.gravity if GameplayObject.debug_movement else 32.0
		draw.launch_arc(CylinderSpace.angle_at(current_angle, face.x, radius), current_height + face.y, radius, jump, GameplayObject.debug_movement, Color.YELLOW, 2.0 * jump.y / gravity)
		draw.arrow(face_world, CylinderSpace.surface_point(current_angle, current_height, radius, face + jump.normalized() * 1.2), Color.ORANGE)
