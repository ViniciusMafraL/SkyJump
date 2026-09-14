class_name TestPlatformSet
extends PlatformSource
## Plataformas fixas da sala de testes, montadas a partir de um TestRoomLayout.

@export var default_platform_scene: PackedScene

## Aplicado a todos os trampolins criados (referência às configurações ativas da sala).
var trampoline_config: TrampolineConfig

var _platforms: Array[Platform] = []


func get_active_platforms() -> Array[Platform]:
	return _platforms


## Recria todas as plataformas, restaurando seus estados (ex.: recarga do trampolim).
func build(layout: TestRoomLayout) -> void:
	clear()
	var theme := layout.get_theme()
	if layout.floor_platform:
		var floor_width := layout.get_floor_segment_width()
		for i in layout.floor_segments:
			var angle_degrees := 360.0 * i / layout.floor_segments
			_spawn(layout, theme, layout.floor_platform, layout.floor_height, angle_degrees, floor_width)
	for placement in layout.placements:
		if placement and placement.platform_config:
			_spawn(layout, theme, placement.platform_config, placement.height, placement.angle_degrees, placement.width_override)


func clear() -> void:
	for platform in _platforms:
		remove_child(platform)
		platform.queue_free()
	_platforms.clear()


func _spawn(layout: TestRoomLayout, theme: ThemeData, platform_config: PlatformConfig, height: float, angle_degrees: float, width: float) -> void:
	var data := PlatformData.new()
	data.config = platform_config
	data.platform_type = platform_config.platform_type
	data.width = width if width > 0.0 else platform_config.width
	data.depth = platform_config.depth
	data.height = height
	data.angle = wrapf(deg_to_rad(angle_degrees), 0.0, TAU)
	data.radius = layout.get_platform_radius(data.depth)
	var platform := PlatformFactory.create(data, default_platform_scene, theme, self)
	if platform is TrampolinePlatform and trampoline_config:
		(platform as TrampolinePlatform).config = trampoline_config
	_platforms.append(platform)
