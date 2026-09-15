class_name CameraRig
extends Node3D
## Câmera orbital externa centrada no eixo do cilindro.
## CameraRig fica na origem; CameraPivot sobe com o personagem e gira ao redor do eixo Y;
## Camera3D fica a `camera_distance` do eixo, sempre fora do pilar e das plataformas.

@export var config: CameraConfig
@export var target: PlayerController
@export var input_controller: InputController

var _orbit_radius: float = 0.0
var _angle: float = 0.0
var _height: float = 0.0
var _manual_offset: float = 0.0
var _idle_time: float = 0.0
var _follow_enabled: bool = true

@onready var _pivot: Node3D = $CameraPivot
@onready var _camera: Camera3D = $CameraPivot/Camera3D


func _ready() -> void:
	if target:
		target.teleported.connect(snap_to_target)


func setup(orbit_radius: float) -> void:
	_orbit_radius = orbit_radius
	_camera.fov = config.camera_fov
	_camera.far = config.far_distance
	_camera.keep_aspect = Camera3D.KEEP_WIDTH if config.fov_is_horizontal else Camera3D.KEEP_HEIGHT
	var distance := maxf(config.camera_distance, orbit_radius + config.min_clearance)
	var look_target := Vector3(orbit_radius, config.camera_vertical_offset - config.camera_height, 0.0)
	_camera.transform = Transform3D(Basis.IDENTITY, Vector3(distance, 0.0, 0.0)).looking_at(look_target, Vector3.UP)


func snap_to_target() -> void:
	_manual_offset = 0.0
	_idle_time = 0.0
	_angle = _get_target_angle()
	_height = _get_target_height()
	_apply_pivot()
	reset_physics_interpolation()


func set_follow_enabled(enabled: bool) -> void:
	_follow_enabled = enabled


func get_camera() -> Camera3D:
	return _camera


func _physics_process(delta: float) -> void:
	if target == null:
		return
	_update_manual_rotation(delta)
	_angle = lerp_angle(_angle, _get_target_angle(), _smooth_weight(config.rotation_smoothing, delta))
	if _follow_enabled:
		_height = lerpf(_height, _get_target_height(), _smooth_weight(config.camera_smoothing, delta))
	_apply_pivot()


func _update_manual_rotation(delta: float) -> void:
	var rotation_delta := 0.0
	if input_controller:
		rotation_delta += deg_to_rad(input_controller.get_camera_rotate_axis() * config.camera_rotation_speed) * delta
		rotation_delta += deg_to_rad(input_controller.consume_camera_drag() * config.drag_degrees_per_screen)
	if not is_zero_approx(rotation_delta):
		_manual_offset = wrapf(_manual_offset + rotation_delta, -PI, PI)
		_idle_time = 0.0
		return
	_idle_time += delta
	if config.auto_recenter_delay > 0.0 and _idle_time >= config.auto_recenter_delay:
		_manual_offset = lerp_angle(_manual_offset, 0.0, _smooth_weight(config.recenter_speed, delta))


func _get_target_angle() -> float:
	return target.angle + deg_to_rad(config.camera_angle) + _manual_offset


func _get_target_height() -> float:
	# Ao subir rápido, antecipa a câmera para mostrar as plataformas acima.
	var lookahead := clampf(target.vertical_velocity * config.vertical_lookahead_factor, 0.0, config.max_vertical_lookahead)
	return target.height + config.camera_height + lookahead


func _apply_pivot() -> void:
	_pivot.position = Vector3(0.0, _height, 0.0)
	_pivot.rotation = Vector3(0.0, -_angle, 0.0)


func _smooth_weight(speed: float, delta: float) -> float:
	return 1.0 - exp(-speed * delta)
