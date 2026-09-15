class_name TestPlatformSet
extends PlatformSource
## Plataformas e objetos fixos da sala de testes, montados a partir de um TestRoomLayout
## (layout padrão) ou de uma ObjectTestStation (teste individual de um objeto especial).

@export var default_platform_scene: PackedScene

## Configurações ativas da sala: cada objeto recebe a seção indicada por get_settings_section().
var active_config: TestRoomConfig
## Tema ativo da sala (materiais de plataformas e objetos).
var active_theme: ThemeData
var debug_draw_enabled: bool = false

var _platforms: Array[Platform] = []
var _objects: Array[GameplayObject] = []


func get_active_platforms() -> Array[Platform]:
	return _platforms


func get_active_objects() -> Array[GameplayObject]:
	return _objects


## Recria tudo, restaurando os estados iniciais. `station` = null monta o layout padrão.
func build(layout: TestRoomLayout, station: ObjectTestStation = null) -> void:
	clear()
	var theme := active_theme
	if layout.floor_platform:
		var floor_width := layout.get_floor_segment_width()
		for i in layout.floor_segments:
			var angle_degrees := 360.0 * i / layout.floor_segments
			_spawn(layout, theme, layout.floor_platform, layout.floor_height, angle_degrees, floor_width, null)
	var placements := station.placements if station else layout.placements
	for placement in placements:
		if placement and placement.platform_config:
			_spawn(layout, theme, placement.platform_config, placement.height, placement.angle_degrees, placement.width_override, placement)


func clear() -> void:
	for object in _objects:
		if is_instance_valid(object):
			remove_child(object)
			object.queue_free()
	_objects.clear()
	_platforms.clear()


## Troca de tema sem recriar: estados dos objetos são mantidos.
func apply_theme(theme: ThemeData) -> void:
	active_theme = theme
	for object in _objects:
		object.apply_theme(theme)


func reset_objects() -> void:
	for object in _objects:
		object.reset()


func trigger_objects(player: PlayerController) -> void:
	for object in _objects:
		object.trigger_debug(player)


func set_debug_draw(enabled: bool) -> void:
	debug_draw_enabled = enabled
	for object in _objects:
		object.show_debug = enabled


func _spawn(layout: TestRoomLayout, theme: ThemeData, platform_config: PlatformConfig, height: float, angle_degrees: float, width: float, placement: PlatformPlacement) -> void:
	var data := PlatformData.new()
	data.config = platform_config
	data.platform_type = platform_config.platform_type
	data.width = width if width > 0.0 else platform_config.width
	data.depth = platform_config.depth
	data.height = height
	data.angle = wrapf(deg_to_rad(angle_degrees), 0.0, TAU)
	data.radius = layout.get_platform_radius(data.depth)
	var object_placement := placement as ObjectPlacement
	var properties := object_placement.properties if object_placement else {}
	var object := PlatformFactory.create_object(data, default_platform_scene, theme, self, properties, _configure.bind(object_placement))
	object.show_debug = debug_draw_enabled
	_objects.append(object)
	_platforms.append_array(object.get_platforms())


func _configure(object: GameplayObject, placement: ObjectPlacement) -> void:
	if placement:
		object.flip = placement.flip
	var section := object.get_settings_section()
	if active_config and not section.is_empty():
		var section_config := active_config.get_section(section)
		if section_config:
			object.set_config(section_config)
