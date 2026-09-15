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
## Seed do mapa gerado (estações com generated_map).
var generation_seed: int = 1
## Distribuição medida x configurada do tema ativo (estações com generated_map).
var generation_report: PackedStringArray = []

var _platforms: Array[Platform] = []
var _objects: Array[GameplayObject] = []


func get_active_platforms() -> Array[Platform]:
	return _platforms


func get_active_objects() -> Array[GameplayObject]:
	return _objects


## Recria tudo, restaurando os estados iniciais. `station` = null monta o layout padrão.
func build(layout: TestRoomLayout, station: ObjectTestStation = null) -> void:
	clear()
	generation_report = PackedStringArray()
	var theme := active_theme
	if station and station.generated_map:
		_build_generated(layout, station)
		return
	if layout.floor_platform and (station == null or station.use_floor):
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


## Trecho procedural com o gerador real e a distribuição do tema ativo, na geometria da sala.
func _build_generated(layout: TestRoomLayout, station: ObjectTestStation) -> void:
	if station.generation_config == null or active_config == null:
		return
	var world := station.generation_config.duplicate() as WorldGenerationConfig
	world.pillar_radius = layout.pillar_radius
	world.player_surface_offset = layout.player_surface_offset
	world.platform_embed_depth = layout.platform_embed_depth
	var generator := LevelGenerator.new()
	generator.config = world
	generator.movement = active_config.movement_config
	var distribution := active_theme.platform_distribution if active_theme else null
	generator.reset(generation_seed, distribution)
	for i in maxi(station.generated_chunks, 1):
		for data in generator.generate_next_chunk().platforms:
			var object := PlatformFactory.create_object(data, default_platform_scene, active_theme, self, {}, _configure.bind(null))
			object.show_debug = debug_draw_enabled
			_objects.append(object)
			_platforms.append_array(object.get_platforms())
	generation_report = build_distribution_report(generator, distribution, generation_seed + 1, station.report_chunks)
	generator.free()


## Gera `chunks` chunks só em dados e compara as escolhas com os pesos configurados.
static func build_distribution_report(generator: LevelGenerator, distribution: PlatformDistribution, report_seed: int, chunks: int) -> PackedStringArray:
	var lines := PackedStringArray()
	if distribution == null:
		lines.append("Tema sem distribuição: só plataformas comuns")
		return lines
	generator.reset(report_seed, distribution)
	for i in chunks:
		generator.generate_next_chunk()
	var total := 0
	for key in generator.selection_counts:
		total += int(generator.selection_counts[key])
	lines.append("DISTRIBUIÇÃO (%d escolhas)" % total)
	lines.append("Comum %.1f%% (cfg %.1f%%)" % [_percent(generator, LevelGenerator.COMMON_KEY, total), distribution.get_expected_share(null) * 100.0])
	for entry in distribution.get_entries():
		var marker := "★ " if entry == distribution.characteristic else ""
		lines.append("%s%s %.1f%% (cfg %.1f%%)" % [marker, entry.rule.display_name, _percent(generator, entry.rule.get_selection_key(), total), distribution.get_expected_share(entry) * 100.0])
	return lines


static func _percent(generator: LevelGenerator, key: StringName, total: int) -> float:
	return 100.0 * int(generator.selection_counts.get(key, 0)) / maxf(total, 1.0)


func _configure(object: GameplayObject, placement: ObjectPlacement) -> void:
	if placement:
		object.flip = placement.flip
	var section := object.get_settings_section()
	if active_config and not section.is_empty():
		var section_config := active_config.get_section(section)
		if section_config:
			object.set_config(section_config)
