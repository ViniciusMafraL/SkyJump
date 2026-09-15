class_name Portal
extends GameplayObject
## PORTAL: teleporta o personagem para o portal cujo `portal_id` é igual ao `destination_id` deste.
## Fluxo: detecta -> valida destino -> TELEPORTING (curto) -> surge no ponto de saída do destino ->
## velocidade tratada por KEEP/RESET/REDIRECT (orientada pela saída do destino) -> gameplay normal.
## Proteção contra teleporte infinito: cooldown global no personagem, cooldown dos dois portais e
## rearme só depois de sair do raio (e, por padrão, pousar).

enum PortalState { READY, TELEPORTING, COOLDOWN, NO_DESTINATION }

const GROUP := &"gameplay_portals"

@export var config: PortalConfig
@export var portal_id: StringName = &"A"
@export var destination_id: StringName = &"B"

@export_group("Exit")
## Altura do centro do portal acima da base do objeto.
@export var center_height: float = 1.0
## Ponto de saída relativo ao centro (x = direita do objeto, y = cima).
@export var exit_offset: Vector2 = Vector2.ZERO
## Orientação da saída (graus: 0 = direita do objeto, 90 = cima).
@export_range(-180.0, 180.0, 1.0) var exit_direction_degrees: float = 90.0

@export_group("Visual")
@export var portal_color: Color = Color(0.75, 0.45, 1.0)

var portal_state: PortalState = PortalState.READY

var _armed: bool = true
var _ready_at_msec: int = 0
var _player: PlayerController
var _destination: Portal
var _incoming_velocity: Vector2 = Vector2.ZERO
var _delay: float = 0.0
var _core_material := StandardMaterial3D.new()
var _ring_material := StandardMaterial3D.new()

@onready var _visual: Node3D = $Visual
@onready var _ring: MeshInstance3D = $Visual/Ring
@onready var _core: MeshInstance3D = $Visual/Core
@onready var _label: Label3D = $Visual/Label
@onready var _exit_arrow: MeshInstance3D = $Visual/ExitArrow


func _enter_tree() -> void:
	add_to_group(GROUP)


func get_settings_section() -> StringName:
	return &"portal"


func wants_player_updates() -> bool:
	return config != null


func is_armed() -> bool:
	return _armed


func is_cooling_down() -> bool:
	return Time.get_ticks_msec() < _ready_at_msec


## Centro do portal relativo à base (espaço do personagem).
func get_center_offset() -> Vector2:
	return Vector2(0.0, center_height)


func get_exit_offset() -> Vector2:
	return local_direction(Vector2(exit_offset.x, center_height + exit_offset.y))


func get_exit_direction() -> Vector2:
	return local_direction(CylinderSpace.direction_from_degrees(exit_direction_degrees))


func find_destination() -> Portal:
	if not is_inside_tree():
		return null
	for node in get_tree().get_nodes_in_group(GROUP):
		var portal := node as Portal
		if portal and portal != self and portal.portal_id == destination_id and not portal.is_queued_for_deletion():
			return portal
	return null


func compute_exit_velocity(incoming: Vector2, destination: Portal) -> Vector2:
	match config.velocity_mode:
		PortalConfig.VelocityMode.KEEP_VELOCITY:
			return incoming
		PortalConfig.VelocityMode.RESET_VELOCITY:
			return Vector2.ZERO
	var speed := clampf(incoming.length(), config.redirect_min_speed, config.redirect_max_speed)
	return destination.get_exit_direction() * speed


func reset() -> void:
	if _player and is_instance_valid(_player) and _player.get_capture_owner() == self:
		_player.release(0.0, 0.0, &"portal")
	_player = null
	_destination = null
	_armed = true
	_ready_at_msec = 0
	portal_state = PortalState.READY
	_update_visual()


func get_state_name() -> String:
	return "%s %s->%s%s" % [PortalState.keys()[portal_state], portal_id, destination_id, "" if _armed else " (desarmado)"]


func trigger_debug(player: PlayerController) -> void:
	var destination := find_destination()
	if destination and not player.is_captured():
		_begin_teleport(player, destination)


func update_player(player: PlayerController, delta: float) -> void:
	if portal_state == PortalState.TELEPORTING:
		if player == _player:
			_delay -= delta
			if _delay <= 0.0:
				_complete(player)
		return
	var inside := CylinderSpace.player_offset(current_angle, current_height, player).distance_to(get_center_offset()) <= config.trigger_radius
	if not inside and (not config.rearm_requires_landing or player.is_grounded()):
		_armed = true
	var destination := find_destination()
	portal_state = PortalState.NO_DESTINATION if destination == null else (PortalState.COOLDOWN if is_cooling_down() else PortalState.READY)
	if not inside or not _armed or portal_state != PortalState.READY or not player.can_teleport():
		return
	if _is_valid_destination(destination):
		_begin_teleport(player, destination)


func _is_valid_destination(destination: Portal) -> bool:
	return destination != null and destination != self and destination.config != null and destination.is_inside_tree() \
		and is_finite(destination.current_height) and is_finite(destination.current_angle)


func _begin_teleport(player: PlayerController, destination: Portal) -> void:
	var incoming := Vector2(player.tangential_speed + player.launch_tangential_speed, player.vertical_velocity)
	if not player.capture(self, PlayerController.Mode.TELEPORTING):
		return
	_player = player
	_destination = destination
	_incoming_velocity = incoming
	_delay = config.teleport_delay
	portal_state = PortalState.TELEPORTING
	play_sound(Sound.TELEPORT)
	if _delay <= 0.0:
		_complete(player)


func _complete(player: PlayerController) -> void:
	var destination := _destination
	_player = null
	_destination = null
	_start_cooldown()
	if destination == null or not is_instance_valid(destination):
		# Destino sumiu durante o teleporte: devolve o controle onde está.
		player.release(0.0, 0.0, &"portal")
		return
	var exit := destination.get_exit_offset()
	player.teleport_to(CylinderSpace.angle_at(destination.current_angle, exit.x, player.orbit_radius), destination.current_height + exit.y - CylinderSpace.PLAYER_CENTER_HEIGHT)
	var velocity := compute_exit_velocity(_incoming_velocity, destination)
	destination._on_arrival()
	player.lock_teleport(config.cooldown)
	player.release(velocity.y, velocity.x, &"portal")


func _on_arrival() -> void:
	_armed = false
	_start_cooldown()
	play_sound(Sound.TELEPORT)


func _start_cooldown() -> void:
	_armed = false
	_ready_at_msec = Time.get_ticks_msec() + roundi((config.cooldown if config else 0.5) * 1000.0)


func _on_setup() -> void:
	_core_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_core_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_core.material_override = _core_material
	_ring_material.emission_enabled = true
	_ring.material_override = _ring_material
	var size := config.portal_size if config else 1.0
	# Anel em pé, com o furo voltado para fora do cilindro (eixo local X).
	_ring.rotation = Vector3(0.0, 0.0, PI * 0.5)
	_ring.scale = Vector3.ONE * size
	_ring.position = Vector3(0.1, center_height, 0.0)
	_core.scale = Vector3(0.15, size * 1.7, size * 1.7)
	_core.position = Vector3(0.1, center_height, 0.0)
	_label.text = String(portal_id)
	_label.position = Vector3(0.2, center_height + size + 0.35, 0.0)
	var direction := get_exit_direction()
	_exit_arrow.rotation = Vector3(atan2(-direction.x, direction.y), 0.0, 0.0)
	_exit_arrow.position = Vector3(0.4, center_height, 0.0) + Vector3(0.0, direction.y, -direction.x) * (size + 0.2)
	_update_visual()


func _physics_process(delta: float) -> void:
	_update_visual()
	super._physics_process(delta)


## Pronto: núcleo pulsando. Cooldown/sem destino: apagado.
func _update_visual() -> void:
	if _core == null:
		return
	var active := portal_state == PortalState.READY and _armed
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.006)
	var color := portal_color
	_core_material.albedo_color = Color(color, lerpf(0.35, 0.7, pulse) if active else 0.12)
	_ring_material.albedo_color = color if active else color.darkened(0.6)
	_ring_material.emission = color * (0.8 if active else 0.05)
	if portal_state == PortalState.TELEPORTING:
		_core_material.albedo_color = Color(1.0, 1.0, 1.0, 0.9)


func _draw_debug(draw: ObjectDebugDraw) -> void:
	if config == null:
		return
	var radius := current_radius
	draw.surface_circle(current_angle, current_height + center_height, radius, config.trigger_radius, Color.GREEN if _armed else Color.RED)
	var exit := get_exit_offset()
	var exit_world := CylinderSpace.surface_point(current_angle, current_height, radius, exit)
	draw.arrow(exit_world, CylinderSpace.surface_point(current_angle, current_height, radius, exit + get_exit_direction() * 1.5), Color.ORANGE)
	var destination := find_destination()
	if destination:
		draw.line(CylinderSpace.surface_point(current_angle, current_height, radius, get_center_offset()),
			CylinderSpace.surface_point(destination.current_angle, destination.current_height, destination.current_radius, destination.get_center_offset()), Color(portal_color, 0.6))
