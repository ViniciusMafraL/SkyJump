class_name VinePlatform
extends GameplayObject
## VINHAS ESCALÁVEIS: pontos de apoio para progressão com pequenos saltos.
## Separa PONTOS JOGÁVEIS (filho Points: Platforms comuns com colisão cilíndrica) do
## VISUAL DA VINHA (filho Visual: caule e folhas placeholder). Trocar o visual não afeta a mecânica.

@export var config: VineConfig
## Cena de cada ponto de apoio (script que estende Platform).
@export var point_scene: PackedScene

@export_group("Visual")
@export var stem_color: Color = Color(0.25, 0.55, 0.2)
@export var leaf_color: Color = Color(0.4, 0.8, 0.3)
@export var stem_radius: float = 0.1

var _points: Array[Platform] = []

@onready var _points_root: Node3D = $Points
@onready var _visual_root: Node3D = $Visual


func get_settings_section() -> StringName:
	return &"vine"


func get_platforms() -> Array[Platform]:
	return _points


func get_state_name() -> String:
	if config == null:
		return ""
	return "%s %d pontos" % [VineConfig.VineDirection.keys()[config.direction], _points.size()]


func _on_setup() -> void:
	_build_points()
	_build_visual()


func _on_theme_applied() -> void:
	for point in _points:
		point.apply_theme(_theme)
	_build_visual()


func _point_radius() -> float:
	return current_radius + (config.point_depth - data.depth) * 0.5


func _build_points() -> void:
	for point in _points:
		if is_instance_valid(point):
			_points_root.remove_child(point)
			point.queue_free()
	_points.clear()
	if config == null or point_scene == null:
		return
	var radius := _point_radius()
	for i in maxi(config.point_count, 0):
		var offset := local_direction(config.get_point_offset(i))
		var point_data := PlatformData.new()
		point_data.platform_type = PlatformType.Type.VINE
		point_data.width = config.point_size
		point_data.depth = config.point_depth
		point_data.height = current_height + offset.y
		point_data.angle = CylinderSpace.angle_at(current_angle, offset.x, radius)
		point_data.radius = radius
		var point := PlatformFactory.create(point_data, point_scene, _theme, _points_root)
		point.name = "Point%d" % i
		_points.append(point)


## Caule passando pelos pontos (um pouco além do primeiro e do último) e folhas alternadas.
func _build_visual() -> void:
	for child in _visual_root.get_children():
		_visual_root.remove_child(child)
		child.queue_free()
	_visual_root.top_level = true
	_visual_root.global_transform = Transform3D.IDENTITY
	if config == null or config.point_count <= 0:
		return
	var stem_material := StandardMaterial3D.new()
	stem_material.albedo_color = theme_secondary_color(stem_color)
	var leaf_material := StandardMaterial3D.new()
	leaf_material.albedo_color = theme_primary_color(leaf_color)
	var stem_mesh := CylinderMesh.new()
	stem_mesh.top_radius = 1.0
	stem_mesh.bottom_radius = 1.0
	stem_mesh.height = 1.0
	stem_mesh.radial_segments = 8
	stem_mesh.rings = 1
	var leaf_mesh := BoxMesh.new()
	leaf_mesh.size = Vector3(0.08, 0.3, 0.45)
	# Caule atrás dos pontos (mais perto do pilar), sem atrapalhar a leitura dos apoios.
	var radius := _point_radius() - config.point_depth * 0.25
	# Offsets dos pontos, com meio espaçamento extra abaixo do primeiro e acima do último.
	var offsets: Array[Vector2] = []
	offsets.append(config.get_point_offset(0) - config.get_point_offset(1) * 0.5)
	for i in config.point_count:
		offsets.append(config.get_point_offset(i))
	offsets.append(config.get_point_offset(config.point_count - 1) + config.get_point_offset(1) * 0.5)
	for i in range(1, offsets.size()):
		var a := CylinderSpace.surface_point(current_angle, current_height, radius, local_direction(offsets[i - 1]))
		var b := CylinderSpace.surface_point(current_angle, current_height, radius, local_direction(offsets[i]))
		var segment := MeshInstance3D.new()
		segment.mesh = stem_mesh
		segment.material_override = stem_material
		_visual_root.add_child(segment)
		segment.global_transform = CylinderSpace.segment_transform(a, b, stem_radius)
		# Folha alternando de lado ao longo da tangente.
		var leaf_offset := local_direction((offsets[i - 1] + offsets[i]) * 0.5 + Vector2(0.3 if i % 2 == 0 else -0.3, 0.0))
		var leaf_angle := CylinderSpace.angle_at(current_angle, leaf_offset.x, radius)
		var leaf := MeshInstance3D.new()
		leaf.mesh = leaf_mesh
		leaf.material_override = leaf_material
		_visual_root.add_child(leaf)
		leaf.global_transform = CylinderSpace.transform_at(leaf_angle, current_height + leaf_offset.y, radius)


func _draw_debug(draw: ObjectDebugDraw) -> void:
	var points := PackedVector3Array()
	for point in _points:
		points.append(CylinderSpace.to_world(point.current_angle, point.get_top_height() + 0.1, point.current_radius + point.data.depth * 0.5))
	draw.polyline(points, Color.GREEN_YELLOW)
