class_name ThemeController
extends Node
## Aplica o tema ativo: instancia a Theme Scene (fundo), aplica a iluminação do tema no ambiente
## da cena de gameplay e avisa quem cria plataformas/objetos para usarem os materiais do tema.

signal theme_changed(theme: LevelTheme)

@export var library: ThemeLibrary
## Tema carregado ao iniciar.
@export var default_theme: PackedScene
## Onde a Theme Scene é instanciada (fica na origem, junto ao eixo do pilar).
@export var theme_parent: Node3D
@export var world_environment: WorldEnvironment
@export var sun: DirectionalLight3D

var current_theme: LevelTheme
var current_scene: PackedScene


func _ready() -> void:
	if default_theme and current_theme == null:
		apply_theme(default_theme)


func get_theme_data() -> ThemeData:
	return current_theme.theme_data if current_theme else null


func get_current_index() -> int:
	return library.find_index(current_scene) if library else -1


func apply_theme_index(index: int) -> void:
	if library:
		apply_theme(library.get_scene(index))


## Sorteia um tema da biblioteca, sem repetir o atual quando há mais de um.
func apply_random_theme() -> void:
	if library == null or library.themes.is_empty():
		return
	var count := library.themes.size()
	var index := randi() % count
	if count > 1 and index == get_current_index():
		index = (index + 1 + randi() % (count - 1)) % count
	apply_theme_index(index)


## Avança/volta na biblioteca (circular).
func cycle_theme(step: int) -> void:
	if library == null or library.themes.is_empty():
		return
	apply_theme_index(posmod(get_current_index() + step, library.themes.size()))


func apply_theme(scene: PackedScene) -> void:
	if scene == null:
		return
	var instance := scene.instantiate() as LevelTheme
	if instance == null:
		push_error("A cena de tema precisa ter LevelTheme na raiz: %s" % scene.resource_path)
		return
	if current_theme:
		if current_theme.is_inside_tree():
			current_theme.get_parent().remove_child(current_theme)
		current_theme.queue_free()
	# Os dados do tema ficam disponíveis na hora; o nó entra na árvore assim que o pai permitir
	# (durante o _ready da cena o pai ainda está montando os filhos).
	var parent: Node = theme_parent if theme_parent else self
	if parent.is_node_ready():
		parent.add_child(instance)
	else:
		_add_theme_when_ready.call_deferred(parent, instance)
	current_theme = instance
	current_scene = scene
	apply_lighting(instance.theme_data, world_environment.environment if world_environment else null, sun)
	theme_changed.emit(instance)


func _add_theme_when_ready(parent: Node, instance: LevelTheme) -> void:
	if is_instance_valid(instance) and instance == current_theme and not instance.is_inside_tree():
		parent.add_child(instance)


## Aplica a iluminação do tema a um ambiente e sol (também usado pela visualização da Theme Scene).
static func apply_lighting(data: ThemeData, environment: Environment, sun_light: DirectionalLight3D) -> void:
	if data == null or data.lighting == null:
		return
	var lighting := data.lighting
	if sun_light:
		sun_light.light_color = lighting.sun_color
		sun_light.light_energy = lighting.sun_energy
		if lighting.override_sun_direction:
			sun_light.rotation_degrees = lighting.sun_rotation_degrees
	if environment == null:
		return
	if lighting.ambient_from_background:
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		if environment.sky and environment.sky.sky_material is ProceduralSkyMaterial:
			var sky := environment.sky.sky_material as ProceduralSkyMaterial
			sky.sky_top_color = data.top_color
			sky.sky_horizon_color = data.base_color
			sky.ground_horizon_color = data.base_color
			sky.ground_bottom_color = data.base_color.darkened(0.3)
	else:
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		environment.ambient_light_color = lighting.ambient_color
	environment.ambient_light_energy = lighting.ambient_energy
	environment.fog_enabled = lighting.fog_enabled
	environment.fog_density = lighting.fog_density
	environment.fog_light_color = data.base_color if lighting.fog_color_from_background else lighting.fog_color
