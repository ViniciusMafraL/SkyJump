class_name TubeTransport
extends GameplayObject
## TUBO TRANSPORTADOR: captura o personagem na entrada, conduz pela curva e o solta no ExitPoint.
## A curva (Curve3D) é desenhada no espaço desenrolado (x = direita do objeto, y = altura) e
## "enrolada" no cilindro, então retas, diagonais, curvas e formato em S funcionam em qualquer ângulo.
## Durante o transporte o personagem fica no modo IN_TUBE, sem controle nem gravidade.

enum TubeState { READY, TRANSPORTING, COOLDOWN }

@export var config: TubeConfig
## Curva específica desta instância (tem prioridade sobre config.path_curve e o nó Path).
@export var path_curve_override: Curve3D

@export_group("Visual")
@export var tube_color: Color = Color(0.45, 0.8, 0.95, 0.45)
@export var entrance_color: Color = Color(0.3, 1.0, 0.5)
@export var exit_color: Color = Color(1.0, 0.6, 0.2)
## Distância entre segmentos do placeholder visual.
@export var segment_length: float = 0.4

var tube_state: TubeState = TubeState.READY

var _curve: Curve3D
var _length: float = 0.0
var _travel: float = 0.0
var _player: PlayerController
var _ready_at_msec: int = 0
var _visual_root: Node3D

@onready var _path: Path3D = $Path
@onready var _exit_point: TubeExitPoint = $ExitPoint


func get_settings_section() -> StringName:
	return &"tube"


func wants_player_updates() -> bool:
	return _length > 0.0


func get_curve() -> Curve3D:
	if path_curve_override:
		return path_curve_override
	if config and config.path_curve:
		return config.path_curve
	return _path.curve if _path else null


func get_length() -> float:
	return _length


func get_travel() -> float:
	return _travel


## Ponto da curva em `distance`, no espaço do objeto (x = direita do objeto, y = cima).
func get_local_point(distance: float) -> Vector2:
	if _curve == null or _length <= 0.0:
		return Vector2.ZERO
	var point := _curve.sample_baked(clampf(distance, 0.0, _length))
	return Vector2(point.x, point.y)


## Entrada e saída no espaço do personagem (x = tangencial, y = altura relativa ao objeto).
func get_entry_offset() -> Vector2:
	return local_direction(get_local_point(0.0))


func get_exit_offset() -> Vector2:
	return local_direction(get_local_point(_length) + _exit_point.offset)


## Velocidade de saída (x = tangencial, y = vertical).
func get_exit_velocity() -> Vector2:
	var own := _exit_point.use_own_values
	var preserve := _exit_point.preserve_velocity if own else config.preserve_velocity
	if preserve:
		var direction := (get_local_point(_length) - get_local_point(_length - 0.25)).normalized()
		return local_direction(direction * config.speed)
	var degrees := _exit_point.direction_degrees if own else config.exit_direction_degrees
	var speed := _exit_point.exit_speed if own else config.exit_force
	return local_direction(CylinderSpace.direction_from_degrees(degrees) * speed)


func reset() -> void:
	if _player and is_instance_valid(_player) and _player.get_capture_owner() == self:
		_player.release(0.0, 0.0, &"tube")
	_player = null
	_travel = 0.0
	_ready_at_msec = 0
	tube_state = TubeState.READY


func get_state_name() -> String:
	return "%s %.1f/%.1f" % [TubeState.keys()[tube_state], _travel, _length]


func trigger_debug(player: PlayerController) -> void:
	if tube_state != TubeState.READY or player.is_captured():
		return
	var entry := get_entry_offset()
	player.teleport_to(CylinderSpace.angle_at(current_angle, entry.x, player.orbit_radius), current_height + entry.y - CylinderSpace.PLAYER_CENTER_HEIGHT)
	_try_capture(player)


func update_player(player: PlayerController, delta: float) -> void:
	if tube_state == TubeState.TRANSPORTING:
		if player == _player:
			_transport(player, delta)
		return
	if Time.get_ticks_msec() < _ready_at_msec:
		tube_state = TubeState.COOLDOWN
		return
	tube_state = TubeState.READY
	if player.is_captured() or config == null:
		return
	var relative := CylinderSpace.player_offset(current_angle, current_height, player)
	if relative.distance_to(get_entry_offset()) <= config.capture_radius:
		_try_capture(player)


func _try_capture(player: PlayerController) -> void:
	if not player.capture(self, PlayerController.Mode.IN_TUBE):
		return
	_player = player
	_travel = 0.0
	tube_state = TubeState.TRANSPORTING
	play_sound(Sound.ACTIVATION)


func _transport(player: PlayerController, delta: float) -> void:
	_travel += config.speed * delta
	if _travel >= _length:
		_exit(player)
		return
	_place_player(player, local_direction(get_local_point(_travel)))


func _exit(player: PlayerController) -> void:
	_place_player(player, get_exit_offset())
	var velocity := get_exit_velocity()
	_player = null
	_travel = _length
	tube_state = TubeState.COOLDOWN
	_ready_at_msec = Time.get_ticks_msec() + roundi(config.entry_cooldown * 1000.0)
	player.release(velocity.y, velocity.x, &"tube")
	play_sound(Sound.LAUNCH)


func _place_player(player: PlayerController, offset: Vector2) -> void:
	player.set_cylindrical_position(CylinderSpace.angle_at(current_angle, offset.x, player.orbit_radius), current_height + offset.y - CylinderSpace.PLAYER_CENTER_HEIGHT)


func _on_setup() -> void:
	_curve = get_curve()
	_length = _curve.get_baked_length() if _curve else 0.0
	_build_visual()


func _surface(offset: Vector2) -> Vector3:
	return CylinderSpace.surface_point(current_angle, current_height, current_radius, offset)


## Placeholder: segmentos translúcidos ao longo da curva, anel verde na entrada e laranja na saída.
func _build_visual() -> void:
	if _visual_root:
		_visual_root.queue_free()
	_visual_root = Node3D.new()
	_visual_root.name = "Visual"
	_visual_root.top_level = true
	add_child(_visual_root)
	_visual_root.global_transform = Transform3D.IDENTITY
	if _length <= 0.0 or config == null:
		return
	var tube_material := StandardMaterial3D.new()
	tube_material.albedo_color = _theme_color(tube_color)
	tube_material.albedo_color.a = tube_color.a
	tube_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	tube_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	var segment_mesh := CylinderMesh.new()
	segment_mesh.top_radius = 1.0
	segment_mesh.bottom_radius = 1.0
	segment_mesh.height = 1.0
	segment_mesh.radial_segments = 12
	segment_mesh.rings = 1
	segment_mesh.cap_top = false
	segment_mesh.cap_bottom = false
	var count := maxi(ceili(_length / maxf(segment_length, 0.1)), 1)
	for i in count:
		var a := _surface(local_direction(get_local_point(_length * i / count)))
		var b := _surface(local_direction(get_local_point(_length * (i + 1) / count)))
		var segment := MeshInstance3D.new()
		segment.mesh = segment_mesh
		segment.material_override = tube_material
		segment.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_visual_root.add_child(segment)
		segment.global_transform = CylinderSpace.segment_transform(a, b, config.tube_radius)
	_add_marker(_surface(get_entry_offset()), entrance_color)
	_add_marker(_surface(get_exit_offset()), exit_color)


func _add_marker(world_position: Vector3, color: Color) -> void:
	var sphere := SphereMesh.new()
	sphere.radius = config.tube_radius * 1.25
	sphere.height = config.tube_radius * 2.5
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color, 0.55)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.emission_enabled = true
	material.emission = color * 0.5
	var marker := MeshInstance3D.new()
	marker.mesh = sphere
	marker.material_override = material
	marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_visual_root.add_child(marker)
	marker.global_position = world_position


func _draw_debug(draw: ObjectDebugDraw) -> void:
	if _length <= 0.0 or config == null:
		return
	var points := PackedVector3Array()
	for i in 33:
		points.append(_surface(local_direction(get_local_point(_length * i / 32.0))))
	draw.polyline(points, Color.CYAN)
	var entry := get_entry_offset()
	draw.surface_circle(current_angle, current_height, current_radius, config.capture_radius, Color.GREEN)
	draw.surface_circle(CylinderSpace.angle_at(current_angle, entry.x, current_radius), current_height + entry.y, current_radius, 0.05, Color.GREEN, 6)
	var exit := get_exit_offset()
	var velocity := get_exit_velocity()
	draw.arrow(_surface(exit), _surface(exit + velocity.normalized() * 1.5), Color.ORANGE)
	var gravity := GameplayObject.debug_movement.gravity if GameplayObject.debug_movement else 32.0
	draw.launch_arc(CylinderSpace.angle_at(current_angle, exit.x, current_radius), current_height + exit.y, current_radius, velocity, GameplayObject.debug_movement, Color.YELLOW, maxf(2.0 * velocity.y / gravity, 0.6))
