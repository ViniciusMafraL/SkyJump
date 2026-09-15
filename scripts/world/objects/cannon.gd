class_name Cannon
extends GameplayObject
## CANHÃO MÓVEL: o personagem entra pela boca, fica preso (IN_CANNON) enquanto uma seta oscila
## entre min_angle e max_angle. Confirmar (pulo, ou toque na tela nos modos automáticos) dispara
## na direção da mira, respeitando a orientação do canhão; depois a gravidade existente segue.
## Ângulos: 0 = para cima do canhão, positivo = direita do objeto.

enum CannonState { IDLE, AIMING, COOLDOWN }

@export var config: CannonConfig

@export_group("Shape")
## Altura da boca (onde o personagem fica) acima da base.
@export var mouth_height: float = 1.1

@export_group("Visual")
@export var body_color: Color = Color(0.3, 0.32, 0.4)
@export var arrow_color: Color = Color(1.0, 0.85, 0.2)
@export var recoil_duration: float = 0.2

var cannon_state: CannonState = CannonState.IDLE
## Mira atual em graus.
var aim_angle: float = 0.0
## Ângulo usado no último disparo.
var last_fire_angle: float = 0.0

var _aim_direction: float = 1.0
var _aim_time: float = 0.0
var _player: PlayerController
var _ready_at_msec: int = 0
var _armed: bool = true
var _recoil: float = 0.0

@onready var _barrel_pivot: Node3D = $Visual/BarrelPivot
@onready var _arrow_pivot: Node3D = $Visual/ArrowPivot
@onready var _base: MeshInstance3D = $Visual/Base
@onready var _barrel: MeshInstance3D = $Visual/BarrelPivot/Barrel


func get_settings_section() -> StringName:
	return &"cannon"


func wants_player_updates() -> bool:
	return config != null


func get_mouth_offset() -> Vector2:
	return Vector2(0.0, mouth_height)


## Vetor de lançamento (x = tangencial do personagem, y = vertical) para um ângulo de mira.
func get_launch_vector(angle_degrees: float) -> Vector2:
	var radians := deg_to_rad(angle_degrees)
	return local_direction(Vector2(sin(radians), cos(radians)) * config.launch_force)


func reset() -> void:
	if _player and is_instance_valid(_player) and _player.get_capture_owner() == self:
		_player.release(0.0, 0.0, &"cannon")
	_player = null
	cannon_state = CannonState.IDLE
	aim_angle = 0.0
	_aim_time = 0.0
	_ready_at_msec = 0
	_armed = true
	_recoil = 0.0
	_update_visual()


func get_state_name() -> String:
	return "%s mira %+.0f°" % [CannonState.keys()[cannon_state], aim_angle]


func trigger_debug(player: PlayerController) -> void:
	if cannon_state == CannonState.AIMING and player == _player:
		fire(player)
	elif cannon_state != CannonState.AIMING and not player.is_captured():
		enter(player)


func update_player(player: PlayerController, delta: float) -> void:
	if cannon_state == CannonState.AIMING:
		if player != _player:
			return
		_update_aim(delta)
		_place_player(player)
		_aim_time += delta
		var confirmed := _aim_time >= config.confirm_delay and player.is_confirm_pressed()
		var timed_out := config.max_aim_time > 0.0 and _aim_time >= config.max_aim_time
		if confirmed or timed_out:
			fire(player)
		return
	var inside := CylinderSpace.player_offset(current_angle, current_height, player).distance_to(get_mouth_offset()) <= config.capture_radius
	if not inside and (not config.rearm_requires_landing or player.is_grounded()):
		_armed = true
	cannon_state = CannonState.COOLDOWN if Time.get_ticks_msec() < _ready_at_msec else CannonState.IDLE
	if inside and _armed and cannon_state == CannonState.IDLE and not player.is_captured():
		enter(player)


func enter(player: PlayerController) -> void:
	if not player.capture(self, PlayerController.Mode.IN_CANNON):
		return
	_player = player
	cannon_state = CannonState.AIMING
	aim_angle = config.min_angle
	_aim_direction = 1.0
	_aim_time = 0.0
	_place_player(player)
	play_sound(Sound.ACTIVATION)


## CAPTURAR ÂNGULO -> CALCULAR VETOR -> LIBERAR -> IMPULSO.
func fire(player: PlayerController) -> void:
	last_fire_angle = aim_angle
	var launch := get_launch_vector(aim_angle)
	_player = null
	_armed = false
	cannon_state = CannonState.COOLDOWN
	_ready_at_msec = Time.get_ticks_msec() + roundi(config.entry_cooldown * 1000.0)
	_recoil = recoil_duration
	player.release(launch.y, launch.x, &"cannon")
	play_sound(Sound.LAUNCH)


func _update_aim(delta: float) -> void:
	if config.max_angle <= config.min_angle:
		aim_angle = config.min_angle
		return
	aim_angle += _aim_direction * config.aim_speed * delta
	if aim_angle >= config.max_angle:
		aim_angle = config.max_angle
		_aim_direction = -1.0
	elif aim_angle <= config.min_angle:
		aim_angle = config.min_angle
		_aim_direction = 1.0


func _place_player(player: PlayerController) -> void:
	var mouth := local_direction(get_mouth_offset())
	player.set_cylindrical_position(CylinderSpace.angle_at(current_angle, mouth.x, player.orbit_radius), current_height + mouth.y - CylinderSpace.PLAYER_CENTER_HEIGHT)


func _on_setup() -> void:
	var base_material := StandardMaterial3D.new()
	base_material.albedo_color = _theme_color(body_color)
	_base.material_override = base_material
	_barrel.material_override = base_material
	var arrow_material := StandardMaterial3D.new()
	arrow_material.albedo_color = arrow_color
	arrow_material.emission_enabled = true
	arrow_material.emission = arrow_color * 0.5
	for child in _arrow_pivot.get_children():
		(child as MeshInstance3D).material_override = arrow_material
	_arrow_pivot.position = Vector3(0.6, mouth_height, 0.0)
	_update_visual()


func _physics_process(delta: float) -> void:
	_recoil = maxf(_recoil - delta, 0.0)
	_update_visual()
	super._physics_process(delta)


## Cano e seta apontam para a mira (local -Z = direita da tela).
func _update_visual() -> void:
	if _barrel_pivot == null or config == null:
		return
	var direction := get_launch_vector(aim_angle).normalized()
	var rotation_x := atan2(-direction.x, direction.y)
	_barrel_pivot.rotation = Vector3(rotation_x, 0.0, 0.0)
	_barrel_pivot.scale = Vector3.ONE * (1.0 - 0.15 * (_recoil / maxf(recoil_duration, 0.001)))
	_arrow_pivot.rotation = Vector3(rotation_x, 0.0, 0.0)
	_arrow_pivot.visible = cannon_state == CannonState.AIMING


func _draw_debug(draw: ObjectDebugDraw) -> void:
	if config == null:
		return
	var radius := current_radius
	var mouth := CylinderSpace.surface_point(current_angle, current_height, radius, get_mouth_offset())
	for limit in [config.min_angle, config.max_angle]:
		var limit_direction := get_launch_vector(limit).normalized()
		draw.line(mouth, CylinderSpace.surface_point(current_angle, current_height, radius, get_mouth_offset() + limit_direction * 2.0), Color.GRAY)
	var launch := get_launch_vector(aim_angle)
	draw.arrow(mouth, CylinderSpace.surface_point(current_angle, current_height, radius, get_mouth_offset() + launch.normalized() * 2.0), Color.ORANGE)
	var gravity := GameplayObject.debug_movement.gravity if GameplayObject.debug_movement else 32.0
	draw.launch_arc(current_angle, current_height + mouth_height, radius, launch, GameplayObject.debug_movement, Color.YELLOW, maxf(2.0 * launch.y / gravity, 0.8))
	draw.surface_circle(current_angle, current_height + mouth_height, radius, config.capture_radius, Color.GREEN if _armed else Color.RED)
