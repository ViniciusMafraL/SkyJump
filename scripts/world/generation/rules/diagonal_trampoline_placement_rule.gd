class_name DiagonalTrampolinePlacementRule
extends PlacementRule
## Trampolim diagonal: o pad é um passo alcançável voltado para o sentido da subida. O lançamento é
## forçado, então a plataforma de pouso é colocada onde a trajetória real do lançamento desce.

@export var diagonal_config: DiagonalTrampolineConfig
@export var landing_platform: PlatformConfig
## Altura do pouso como fração da altura máxima do lançamento.
@export_range(0.1, 1.0, 0.05) var min_height_fraction: float = 0.35
@export_range(0.1, 1.0, 0.05) var max_height_fraction: float = 0.8


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var pad := generator.make_platform(platform_config, chunk.difficulty.platform_size_multiplier)
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		if not generator.place_step(pad, chunk):
			return Result.CHUNK_END
		pad.flip = generator.flip_for_progression()
		var local := diagonal_config.get_local_launch()
		var launch := generator.clamp_launch(Vector2(local.x * object_sign(pad.flip), local.y))
		var apex := JumpReach.apex_height(generator.movement, launch.y)
		var gap := generator.rng.randf_range(apex * min_height_fraction, apex * max_height_fraction)
		var offset := generator.landing_offset(launch, gap)
		if is_nan(offset):
			continue
		var landing := generator.make_platform(landing_platform, chunk.difficulty.platform_size_multiplier)
		landing.height = pad.height + gap
		landing.angle = generator.angle_from(pad.angle, offset)
		var footprints := [GenerationFootprint.for_platform(pad), GenerationFootprint.for_platform(landing)]
		if not generator.is_free(footprints):
			continue
		pad.hints = {"launch": launch, "landing": landing}
		generator.commit(chunk, pad, [footprints[0]])
		generator.commit(chunk, landing, [footprints[1]])
		generator.set_anchor(landing)
		return Result.PLACED
	return Result.FAILED
