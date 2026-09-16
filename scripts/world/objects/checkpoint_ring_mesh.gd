class_name CheckpointRingMesh
extends RefCounted
## Malha do anel de checkpoint (topo, fundo e bordas) com cores por vértice em xadrez.
## Centro no eixo do cilindro e topo em y = 0. Anéis iguais compartilham a malha e o material.
## O material não recebe luz (as cores da medalha não mudam com a iluminação de cada tema); o volume
## vem de tons mais escuros já gravados nas bordas e no fundo.

const SIDE_SHADE := 0.8
const INNER_SHADE := 0.68
const BOTTOM_SHADE := 0.55

static var _meshes: Dictionary = {}
static var _material: StandardMaterial3D


static func get_mesh(inner_radius: float, outer_radius: float, thickness: float, segments: int, rows: int, light: Color, dark: Color) -> ArrayMesh:
	var key := "%.3f|%.3f|%.3f|%d|%d|%s|%s" % [inner_radius, outer_radius, thickness, segments, rows, light.to_html(), dark.to_html()]
	if _meshes.has(key):
		return _meshes[key]
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var bottom := -thickness
	for segment in segments:
		var from := TAU * segment / segments
		var to := TAU * (segment + 1) / segments
		for row in rows:
			var near := lerpf(inner_radius, outer_radius, float(row) / rows)
			var far := lerpf(inner_radius, outer_radius, float(row + 1) / rows)
			var color := _checker(segment + row, light, dark)
			_quad(tool, _point(from, near, 0.0), _point(from, far, 0.0), _point(to, far, 0.0), _point(to, near, 0.0), Vector3.UP, color)
			_quad(tool, _point(from, near, bottom), _point(to, near, bottom), _point(to, far, bottom), _point(from, far, bottom), Vector3.DOWN, _shade(color, BOTTOM_SHADE))
		var outward := _point((from + to) * 0.5, 1.0, 0.0)
		# As bordas continuam o xadrez das casas vizinhas do topo.
		_quad(tool, _point(from, outer_radius, 0.0), _point(from, outer_radius, bottom), _point(to, outer_radius, bottom), _point(to, outer_radius, 0.0), outward, _shade(_checker(segment + rows, light, dark), SIDE_SHADE))
		_quad(tool, _point(from, inner_radius, 0.0), _point(to, inner_radius, 0.0), _point(to, inner_radius, bottom), _point(from, inner_radius, bottom), -outward, _shade(_checker(segment + 1, light, dark), INNER_SHADE))
	var mesh := tool.commit()
	_meshes[key] = mesh
	return mesh


static func get_material() -> StandardMaterial3D:
	if _material == null:
		_material = StandardMaterial3D.new()
		_material.vertex_color_use_as_albedo = true
		_material.vertex_color_is_srgb = true
		_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return _material


static func _checker(cell: int, light: Color, dark: Color) -> Color:
	return dark if cell % 2 == 0 else light


static func _shade(color: Color, amount: float) -> Color:
	return Color(color.r * amount, color.g * amount, color.b * amount, color.a)


static func _point(angle: float, radius: float, y: float) -> Vector3:
	return Vector3(cos(angle) * radius, y, sin(angle) * radius)


static func _quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal: Vector3, color: Color) -> void:
	tool.set_color(color)
	tool.set_normal(normal)
	for point: Vector3 in [a, b, c, a, c, d]:
		tool.add_vertex(point)
