class_name SlidingPlatform
extends Platform
## PLATAFORMA DESLIZANTE: com o personagem em cima empurrando para um lado (acima do limiar),
## desliza nessa direção até a distância máxima. Sem ativação por `cooldown` segundos,
## para ou retorna à posição inicial. O personagem é carregado pelo sistema existente.

enum SlideState { IDLE, SLIDING, AT_LIMIT, STOPPED, RETURNING }

@export var config: SlidingPlatformConfig

@export_group("Visual")
@export var arrow_color: Color = Color(0.4, 1.0, 0.7)
@export var limit_color: Color = Color(1.0, 1.0, 1.0, 0.5)

var slide_state: SlideState = SlideState.IDLE
## Deslocamento atual ao longo da circunferência (positivo = direita da tela).
var offset: float = 0.0

var _base_angle: float = 0.0
var _rider: PlayerController
var _idle_timer: float = 0.0
var _limits: Node3D

@onready var _arrow_right: MeshInstance3D = $Visual/ArrowRight
@onready var _arrow_left: MeshInstance3D = $Visual/ArrowLeft


func _ready() -> void:
	process_physics_priority = -10


func get_settings_section() -> StringName:
	return &"sliding"


func is_moving() -> bool:
	return slide_state in [SlideState.SLIDING, SlideState.RETURNING]


## Enquanto desliza, o input empurra a plataforma em vez de fazer o personagem andar sobre ela.
## No limite, o personagem volta a andar normalmente (pode sair pela borda).
func get_input_speed_scale() -> float:
	return 0.0 if slide_state == SlideState.SLIDING else 1.0


func reset() -> void:
	offset = 0.0
	_idle_timer = 0.0
	slide_state = SlideState.IDLE
	_apply_offset()
	reset_physics_interpolation()


func get_state_name() -> String:
	return "%s %+.2f" % [SlideState.keys()[slide_state], offset]


func on_player_landed(player: PlayerController) -> void:
	_rider = player


func on_player_left(player: PlayerController) -> void:
	if _rider == player:
		_rider = null


func trigger_debug(_player: PlayerController) -> void:
	if config:
		offset = config.maximum_distance if offset <= 0.0 else -config.maximum_distance
		slide_state = SlideState.AT_LIMIT
		_idle_timer = config.cooldown
		_apply_offset()


func _on_setup() -> void:
	super._on_setup()
	_base_angle = data.angle
	var arrow_offset := data.width * 0.5 + 0.1
	_arrow_right.position = Vector3(0.0, 0.25, -arrow_offset)
	_arrow_right.rotation = Vector3(-PI * 0.5, 0.0, 0.0)
	_arrow_left.position = Vector3(0.0, 0.25, arrow_offset)
	_arrow_left.rotation = Vector3(PI * 0.5, 0.0, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = arrow_color
	material.emission_enabled = true
	material.emission = arrow_color * 0.3
	_arrow_right.material_override = material
	_arrow_left.material_override = material
	_build_limits()


func _physics_process(delta: float) -> void:
	if config:
		_update_slide(delta)
		_apply_offset()
	super._physics_process(delta)


func _update_slide(delta: float) -> void:
	var axis := 0.0
	if _rider and is_instance_valid(_rider) and _rider.current_platform == self:
		axis = _rider.get_move_axis()
	if absf(axis) >= config.activation_threshold and config.maximum_distance > 0.0:
		var target := signf(axis) * config.maximum_distance
		offset = move_toward(offset, target, config.movement_speed * delta)
		slide_state = SlideState.AT_LIMIT if is_equal_approx(offset, target) else SlideState.SLIDING
		_idle_timer = config.cooldown
		return
	_idle_timer -= delta
	if is_zero_approx(offset):
		offset = 0.0
		slide_state = SlideState.IDLE
	elif config.return_to_start and _idle_timer <= 0.0:
		offset = move_toward(offset, 0.0, config.return_speed * delta)
		slide_state = SlideState.RETURNING
	elif slide_state == SlideState.SLIDING:
		slide_state = SlideState.STOPPED


func _apply_offset() -> void:
	current_angle = CylinderSpace.angle_at(_base_angle, offset, current_radius)
	_sync_transform()


func _build_limits() -> void:
	if _limits:
		_limits.queue_free()
	_limits = Node3D.new()
	_limits.top_level = true
	add_child(_limits)
	_limits.global_transform = Transform3D.IDENTITY
	if config == null:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = limit_color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var post := CylinderMesh.new()
	post.top_radius = 0.06
	post.bottom_radius = 0.06
	post.height = 0.8
	for side in [-1.0, 1.0]:
		var edge: float = side * (config.maximum_distance + data.width * 0.5)
		var marker := MeshInstance3D.new()
		marker.mesh = post
		marker.material_override = material
		marker.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_limits.add_child(marker)
		marker.global_position = CylinderSpace.surface_point(_base_angle, current_height + 0.4, current_radius + data.depth * 0.5, Vector2(edge, 0.0))


func _draw_debug(draw: ObjectDebugDraw) -> void:
	if config == null:
		return
	var radius := current_radius + data.depth * 0.5
	var left := CylinderSpace.surface_point(_base_angle, current_height + 0.2, radius, Vector2(-config.maximum_distance, 0.0))
	var right := CylinderSpace.surface_point(_base_angle, current_height + 0.2, radius, Vector2(config.maximum_distance, 0.0))
	draw.line(left, right, Color.CYAN)
	var here := CylinderSpace.surface_point(_base_angle, current_height + 0.4, radius, Vector2(offset, 0.0))
	draw.arrow(here, CylinderSpace.surface_point(_base_angle, current_height + 0.4, radius, Vector2(offset * 0.0 + (1.0 if offset >= 0.0 else -1.0) + offset, 0.0)), Color.WHITE)
