class_name ObjectDebugDraw
extends MeshInstance3D
## Linhas de debug em coordenadas do mundo (vetores, trajetórias, raios). Ferramenta de desenvolvimento.

var _mesh := ImmediateMesh.new()
var _points := PackedVector3Array()
var _colors := PackedColorArray()


func _init() -> void:
	top_level = true
	mesh = _mesh
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.vertex_color_use_as_albedo = true
	material.no_depth_test = true
	material.render_priority = 10
	material_override = material


func clear() -> void:
	_points.clear()
	_colors.clear()


func line(a: Vector3, b: Vector3, color: Color) -> void:
	_points.append(a)
	_points.append(b)
	_colors.append(color)
	_colors.append(color)


func polyline(points: PackedVector3Array, color: Color) -> void:
	for i in range(1, points.size()):
		line(points[i - 1], points[i], color)


func arrow(from: Vector3, to: Vector3, color: Color) -> void:
	line(from, to, color)
	var direction := to - from
	var length := direction.length()
	if length < 0.01:
		return
	direction /= length
	var side := direction.cross(to.normalized() if not to.is_zero_approx() else Vector3.RIGHT)
	if side.length() < 0.01:
		side = direction.cross(Vector3.UP)
	side = side.normalized() * minf(length * 0.25, 0.35)
	var back := to - direction * minf(length * 0.3, 0.5)
	line(to, back + side, color)
	line(to, back - side, color)


## Círculo desenhado sobre a superfície do cilindro (raio no espaço desenrolado).
func surface_circle(angle: float, height: float, radius: float, circle_radius: float, color: Color, segments: int = 24) -> void:
	var points := PackedVector3Array()
	for i in segments + 1:
		var offset := Vector2.from_angle(TAU * i / segments) * circle_radius
		points.append(CylinderSpace.surface_point(angle, height, radius, offset))
	polyline(points, color)


## Parábola de um lançamento usando a gravidade e o arrasto do momentum do personagem.
func launch_arc(angle: float, height: float, radius: float, launch: Vector2, movement: PlayerMovementConfig, color: Color, duration: float = 2.0) -> void:
	if movement == null:
		return
	var points := PackedVector3Array()
	var steps := 24
	var drag := maxf(movement.launch_momentum_drag, 0.0)
	var stop_time := absf(launch.x) / drag if drag > 0.0 else INF
	for i in steps + 1:
		var t := duration * i / steps
		var y := launch.y * t - 0.5 * movement.gravity * t * t
		var t_h := minf(t, stop_time)
		var x := signf(launch.x) * (absf(launch.x) * t_h - 0.5 * drag * t_h * t_h)
		points.append(CylinderSpace.surface_point(angle, height, radius, Vector2(x, y)))
	polyline(points, color)


func commit() -> void:
	_mesh.clear_surfaces()
	if _points.is_empty():
		return
	_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for i in _points.size():
		_mesh.surface_set_color(_colors[i])
		_mesh.surface_add_vertex(_points[i])
	_mesh.surface_end()
