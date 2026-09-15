class_name StairPlatform
extends GameplayObject
## PLATAFORMA ESCADA: conjunto de pequenas plataformas (degraus) geradas a partir do StairConfig.
## Tipos: reta, diagonal, zigue-zague e alternada. Os degraus são Platforms comuns, então
## colisão, pouso e pulo automático usam o sistema existente.

@export var config: StairConfig
## Cena de cada degrau (script que estende Platform).
@export var step_scene: PackedScene

var _steps: Array[Platform] = []


func get_settings_section() -> StringName:
	return &"stair"


func get_platforms() -> Array[Platform]:
	return _steps


func get_state_name() -> String:
	if config == null:
		return ""
	return "%s %d degraus" % [StairConfig.StairType.keys()[config.stair_type], _steps.size()]


func _on_theme_applied() -> void:
	for step in _steps:
		step.apply_theme(_theme)


func _on_setup() -> void:
	for step in _steps:
		if is_instance_valid(step):
			remove_child(step)
			step.queue_free()
	_steps.clear()
	if config == null or step_scene == null:
		return
	# Raio ajustado para a profundidade do degrau (face interna embutida como a do objeto).
	var step_radius := current_radius + (config.step_depth - data.depth) * 0.5
	for i in maxi(config.step_count, 0):
		var offset := local_direction(config.get_step_offset(i))
		var step_data := PlatformData.new()
		# Sem PlatformConfig: o scene_override da escada recriaria a própria escada.
		step_data.config = null
		step_data.platform_type = PlatformType.Type.STAIR
		step_data.width = config.step_width
		step_data.depth = config.step_depth
		step_data.height = current_height + offset.y
		step_data.angle = CylinderSpace.angle_at(current_angle, offset.x, step_radius)
		step_data.radius = step_radius
		var step := PlatformFactory.create(step_data, step_scene, _theme, self)
		step.name = "Step%d" % i
		_steps.append(step)


func _draw_debug(draw: ObjectDebugDraw) -> void:
	var points := PackedVector3Array()
	for step in _steps:
		points.append(CylinderSpace.to_world(step.current_angle, step.get_top_height() + 0.1, step.current_radius + step.data.depth * 0.5))
	draw.polyline(points, Color.CYAN)
