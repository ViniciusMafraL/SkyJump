class_name ThemePreview
extends Node3D
## Visualização de teste de uma Theme Scene executada sozinha (F6): câmera no mesmo enquadramento
## do jogo orbitando o eixo (mostra o fundo acompanhando), luz com a iluminação do tema e amostras
## dos materiais de plataformas e objetos especiais. Apenas ferramenta de desenvolvimento.
## Controles: ←/→ gira a câmera, ↑/↓ altura, Espaço liga/desliga a órbita automática.

@export var camera_config: CameraConfig = preload("res://config/camera.tres")
@export var orbit_radius: float = 7.2
@export var auto_orbit_speed: float = 20.0
@export var manual_orbit_speed: float = 90.0
@export var height_speed: float = 8.0

var _theme: LevelTheme
var _camera: Camera3D
var _angle: float = 0.0
var _height: float = 6.0
var _auto_orbit: bool = true
var _info: Label


func _ready() -> void:
	_theme = get_parent() as LevelTheme
	var data := _theme.theme_data if _theme else null
	_build_environment(data)
	_build_camera()
	_build_swatches(data)
	_build_info(data)


func _process(delta: float) -> void:
	var manual := Input.get_axis(&"ui_left", &"ui_right")
	if not is_zero_approx(manual):
		_auto_orbit = false
		_angle += deg_to_rad(manual * manual_orbit_speed) * delta
	elif _auto_orbit:
		_angle += deg_to_rad(auto_orbit_speed) * delta
	_height += Input.get_axis(&"ui_down", &"ui_up") * height_speed * delta
	if Input.is_action_just_pressed(&"ui_accept"):
		_auto_orbit = not _auto_orbit
	_update_camera()


func _build_environment(data: ThemeData) -> void:
	var sky_material := ProceduralSkyMaterial.new()
	var sky := Sky.new()
	sky.sky_material = sky_material
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40.0, 30.0, 0.0)
	sun.shadow_enabled = true
	add_child(sun)
	ThemeController.apply_lighting(data, environment, sun)


func _build_camera() -> void:
	_camera = Camera3D.new()
	_camera.fov = camera_config.camera_fov
	_camera.far = camera_config.far_distance
	_camera.keep_aspect = Camera3D.KEEP_WIDTH if camera_config.fov_is_horizontal else Camera3D.KEEP_HEIGHT
	add_child(_camera)
	_camera.make_current()
	_update_camera()


## Mesmo cálculo do CameraRig: pivô no eixo, câmera a camera_distance olhando para a trajetória.
func _update_camera() -> void:
	var distance := maxf(camera_config.camera_distance, orbit_radius + camera_config.min_clearance)
	var look_target := Vector3(orbit_radius, camera_config.camera_vertical_offset - camera_config.camera_height, 0.0)
	var local := Transform3D(Basis.IDENTITY, Vector3(distance, 0.0, 0.0)).looking_at(look_target, Vector3.UP)
	_camera.global_transform = Transform3D(Basis(Vector3.UP, -_angle), Vector3(0.0, _height, 0.0)) * local


## Amostras: espiral de plataformas (material de plataformas) e blocos com acento (objetos especiais).
func _build_swatches(data: ThemeData) -> void:
	if data == null:
		return
	var platform_box := BoxMesh.new()
	platform_box.size = Vector3(3.0, 0.5, 2.6)
	for i in 10:
		var settings := data.platform_material
		var mesh := MeshInstance3D.new()
		mesh.mesh = platform_box
		if settings:
			mesh.material_override = settings.get_secondary_material() if i % 3 == 2 else settings.get_primary_material()
		add_child(mesh)
		mesh.global_transform = CylinderSpace.transform_at(deg_to_rad(i * 36.0), i * 1.4 - 0.25, orbit_radius)
	var body := BoxMesh.new()
	body.size = Vector3(1.4, 1.4, 1.4)
	var accent := CylinderMesh.new()
	accent.top_radius = 0.0
	accent.bottom_radius = 0.4
	accent.height = 0.8
	for i in 4:
		var settings := data.special_object_material
		var holder := Node3D.new()
		add_child(holder)
		holder.global_transform = CylinderSpace.transform_at(deg_to_rad(18.0 + i * 90.0), 2.0 + i * 3.5, orbit_radius)
		var body_mesh := MeshInstance3D.new()
		body_mesh.mesh = body
		body_mesh.position = Vector3(0.0, 0.7, 0.0)
		var accent_mesh := MeshInstance3D.new()
		accent_mesh.mesh = accent
		accent_mesh.position = Vector3(0.0, 1.8, 0.0)
		if settings:
			body_mesh.material_override = settings.get_primary_material()
			accent_mesh.material_override = settings.get_secondary_material()
		holder.add_child(body_mesh)
		holder.add_child(accent_mesh)


func _build_info(data: ThemeData) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_info = Label.new()
	_info.position = Vector2(24.0, 24.0)
	_info.add_theme_font_size_override(&"font_size", 26)
	_info.add_theme_color_override(&"font_outline_color", Color.BLACK)
	_info.add_theme_constant_override(&"outline_size", 8)
	layer.add_child(_info)
	if data == null:
		_info.text = "Tema sem ThemeData"
		return
	var lines := PackedStringArray()
	lines.append("%s — %s" % [_theme.scene_file_path.get_file().get_basename(), data.display_name])
	lines.append("BASE_COLOR #%s   TOP_COLOR #%s" % [data.base_color.to_html(false).to_upper(), data.top_color.to_html(false).to_upper()])
	if data.platform_material:
		lines.append("Plataformas #%s / #%s" % [data.platform_material.primary_color.to_html(false).to_upper(), data.platform_material.secondary_color.to_html(false).to_upper()])
	if data.special_object_material:
		lines.append("Objetos especiais #%s / #%s" % [data.special_object_material.primary_color.to_html(false).to_upper(), data.special_object_material.secondary_color.to_html(false).to_upper()])
	lines.append("←/→ girar  ↑/↓ altura  Espaço: órbita")
	_info.text = "\n".join(lines)
