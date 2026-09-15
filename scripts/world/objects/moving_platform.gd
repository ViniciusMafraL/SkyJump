class_name MovingPlatform
extends Platform
## PLATAFORMA MÓVEL: percorre uma trajetória (horizontal, vertical, diagonal ou própria)
## com aceleração, desaceleração, espera, ping-pong e loop.
## O personagem é carregado pelo sistema existente (acompanha ângulo e altura da plataforma).
## Move-se antes do personagem em cada frame de física, para ele nunca ficar para trás.

enum Phase { WAITING, MOVING, STOPPED }

@export var config: MovingPlatformConfig

@export_group("Visual")
## Marcadores fixos mostrando o caminho (início, fim e trilho).
@export var show_track: bool = true
@export var track_color: Color = Color(1.0, 1.0, 1.0, 0.45)

var phase: Phase = Phase.WAITING

var _trajectory: PlatformTrajectory
var _base_angle: float = 0.0
var _base_height: float = 0.0
var _distance: float = 0.0
var _speed: float = 0.0
var _direction: float = 1.0
var _wait_timer: float = 0.0
var _previous_top: float = 0.0
var _track: Node3D


func _ready() -> void:
	process_physics_priority = -10


func get_settings_section() -> StringName:
	return &"moving"


func is_moving() -> bool:
	return phase == Phase.MOVING


func get_previous_top_height() -> float:
	return _previous_top


## Posição ao longo da trajetória (0 = início).
func get_travel_distance() -> float:
	return _distance


func reset() -> void:
	_distance = 0.0
	_speed = 0.0
	_direction = 1.0
	_start_wait()
	_apply_offset()
	_previous_top = current_height
	reset_physics_interpolation()


func get_state_name() -> String:
	var length := _trajectory.get_length() if _trajectory else 0.0
	return "%s %.1f/%.1f" % [Phase.keys()[phase], _distance, length]


func trigger_debug(_player: PlayerController) -> void:
	if phase == Phase.STOPPED:
		reset()
	phase = Phase.MOVING


func _on_setup() -> void:
	super._on_setup()
	_base_angle = data.angle
	_base_height = data.height
	_trajectory = config.build_trajectory() if config else LinearTrajectory.new()
	_build_track()


func _on_theme_applied() -> void:
	super._on_theme_applied()
	_build_track()


func _physics_process(delta: float) -> void:
	_previous_top = current_height
	if config and _trajectory:
		match phase:
			Phase.WAITING:
				_wait_timer -= delta
				if _wait_timer <= 0.0:
					phase = Phase.MOVING
			Phase.MOVING:
				_advance(delta)
		_apply_offset()
	super._physics_process(delta)


## Perfil trapezoidal: acelera até `speed` e freia a tempo de parar no destino.
func _advance(delta: float) -> void:
	var length := _trajectory.get_length()
	var remaining := length - _distance if _direction > 0.0 else _distance
	var target_speed := config.speed
	if config.deceleration > 0.0:
		target_speed = minf(target_speed, maxf(sqrt(2.0 * config.deceleration * remaining), config.speed * 0.1))
	if config.acceleration > 0.0 and _speed < target_speed:
		_speed = minf(_speed + config.acceleration * delta, target_speed)
	else:
		_speed = target_speed
	var step := _speed * delta
	if step >= remaining:
		_distance = length if _direction > 0.0 else 0.0
		_speed = 0.0
		_on_arrived()
	else:
		_distance += step * _direction


func _on_arrived() -> void:
	if _direction > 0.0:
		if config.ping_pong:
			_direction = -1.0
			_start_wait()
		elif config.loop:
			# Recomeça da posição inicial (o personagem em cima acompanha).
			_distance = 0.0
			_start_wait()
		else:
			phase = Phase.STOPPED
	elif config.loop:
		_direction = 1.0
		_start_wait()
	else:
		phase = Phase.STOPPED


func _start_wait() -> void:
	phase = Phase.WAITING
	_wait_timer = config.wait_time if config else 0.0


func _apply_offset() -> void:
	var offset := local_direction(_trajectory.sample(_distance)) if _trajectory else Vector2.ZERO
	current_angle = CylinderSpace.angle_at(_base_angle, offset.x, current_radius)
	current_height = _base_height + offset.y
	_sync_transform()


func _build_track() -> void:
	if _track:
		_track.queue_free()
		_track = null
	if not show_track or _trajectory == null:
		return
	_track = Node3D.new()
	_track.top_level = true
	add_child(_track)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(theme_secondary_color(track_color), track_color.a)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var dot := SphereMesh.new()
	dot.radius = 0.08
	dot.height = 0.16
	var endpoint := SphereMesh.new()
	endpoint.radius = 0.22
	endpoint.height = 0.44
	var length := _trajectory.get_length()
	var count := maxi(ceili(length / 0.5), 1)
	for i in count + 1:
		var marker := MeshInstance3D.new()
		marker.mesh = endpoint if i == 0 or i == count else dot
		marker.material_override = material
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var offset := local_direction(_trajectory.sample(length * i / count))
		var top := CylinderSpace.surface_point(_base_angle, _base_height, current_radius + data.depth * 0.5, offset)
		_track.add_child(marker)
		marker.global_position = top
	_track.global_transform = Transform3D.IDENTITY


func _draw_debug(draw: ObjectDebugDraw) -> void:
	if _trajectory == null:
		return
	var points := PackedVector3Array()
	var length := _trajectory.get_length()
	for i in 17:
		points.append(CylinderSpace.surface_point(_base_angle, _base_height, current_radius, local_direction(_trajectory.sample(length * i / 16.0))))
	draw.polyline(points, Color.CYAN)
	var here := CylinderSpace.surface_point(_base_angle, _base_height, current_radius, local_direction(_trajectory.sample(_distance)))
	var ahead := CylinderSpace.surface_point(_base_angle, _base_height, current_radius, local_direction(_trajectory.sample(_distance + _direction * 1.0)))
	draw.arrow(here + Vector3.UP * 0.3, ahead + Vector3.UP * 0.3, Color.WHITE)
