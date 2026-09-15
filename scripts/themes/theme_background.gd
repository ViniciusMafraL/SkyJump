@tool
class_name ThemeBackground
extends MeshInstance3D
## Fundo do nível: SEMICILINDRO 3D (seção aberta de um cilindro) centrado no eixo do pilar,
## sempre do lado oposto à câmera. Gira junto com a câmera ao redor do eixo e acompanha a
## altura dela, então funciona como uma parede curva que nunca mostra as extremidades.
## As cores do gradiente vêm do ThemeData do tema (nada de cor configurada aqui).

const SHADER := preload("res://art/shaders/theme_background.gdshader")

@export_group("Shape")
## Distância do eixo do pilar até a parede curva (bem além das plataformas).
@export var radius: float = 70.0:
	set(value):
		radius = maxf(value, 1.0)
		_rebuild_mesh()
@export var height: float = 220.0:
	set(value):
		height = maxf(value, 1.0)
		_rebuild_mesh()
## Abertura da seção do cilindro. 180 = metade da superfície.
@export_range(60.0, 300.0, 1.0) var arc_degrees: float = 180.0:
	set(value):
		arc_degrees = value
		_rebuild_mesh()
@export_range(8, 256, 1) var segments: int = 72:
	set(value):
		segments = value
		_rebuild_mesh()

@export_group("Follow")
## Acompanha a câmera ativa (horizontalmente ao redor do eixo e na altura).
@export var follow_camera: bool = true
## Deslocamento vertical do centro do fundo em relação à câmera.
@export var vertical_offset: float = 0.0

var _material := ShaderMaterial.new()


func _ready() -> void:
	_material.shader = SHADER
	material_override = _material
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	_rebuild_mesh()


func apply_theme(data: ThemeData) -> void:
	if data == null:
		return
	_material.set_shader_parameter(&"base_color", data.base_color)
	_material.set_shader_parameter(&"top_color", data.top_color)
	_material.set_shader_parameter(&"gradient_start", data.gradient_start)
	_material.set_shader_parameter(&"gradient_end", data.gradient_end)
	_material.set_shader_parameter(&"gradient_power", data.gradient_power)


func get_background_material() -> ShaderMaterial:
	return _material


## Direção horizontal (mundo) para onde aponta o centro do arco.
func get_center_direction() -> Vector3:
	var direction := global_basis.x
	direction.y = 0.0
	return direction.normalized()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or not follow_camera:
		return
	var camera := get_viewport().get_camera_3d()
	if camera:
		follow(camera.get_global_transform_interpolated().origin)


## Coloca o centro do arco do lado oposto à câmera, na altura dela.
func follow(camera_position: Vector3) -> void:
	var horizontal := Vector2(camera_position.x, camera_position.z)
	var camera_angle := horizontal.angle() if horizontal.length() > 0.001 else 0.0
	global_transform = Transform3D(Basis(Vector3.UP, -(camera_angle + PI)), Vector3(0.0, camera_position.y + vertical_offset, 0.0))


## Superfície interna do arco, centrada no eixo local +X. UV.y = 0 na base, 1 no topo.
func _rebuild_mesh() -> void:
	if not is_inside_tree():
		return
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var half_arc := deg_to_rad(arc_degrees) * 0.5
	var half_height := height * 0.5
	for i in segments + 1:
		var t := float(i) / segments
		var angle := lerpf(-half_arc, half_arc, t)
		var direction := Vector3(cos(angle), 0.0, sin(angle))
		for v in [0.0, 1.0]:
			tool.set_normal(-direction)
			tool.set_uv(Vector2(t, v))
			tool.add_vertex(direction * radius + Vector3(0.0, lerpf(-half_height, half_height, v), 0.0))
	for i in segments:
		var bottom := i * 2
		tool.add_index(bottom)
		tool.add_index(bottom + 1)
		tool.add_index(bottom + 2)
		tool.add_index(bottom + 1)
		tool.add_index(bottom + 3)
		tool.add_index(bottom + 2)
	mesh = tool.commit()
