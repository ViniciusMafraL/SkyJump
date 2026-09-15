class_name TubePlacementRule
extends PlacementRule
## Tubo transportador: uma plataforma de entrada pequena (passo alcançável) com a boca do tubo
## exatamente na altura do corpo do jogador; a curva sobe no sentido da subida e a plataforma de pouso
## fica onde a trajetória real de saída desce.

@export var tube_config: TubeConfig
## Curvas sorteadas (reta, diagonal, curva, S...).
@export var curves: Array[Curve3D] = []
@export var entry_platform: PlatformConfig
@export var landing_platform: PlatformConfig
## Largura máxima da entrada: pousar em qualquer ponto dela (inclusive na borda) coloca o jogador na boca do tubo.
@export var entry_max_width: float = 1.0
## Altura do pouso relativa aos pés na saída (fração da altura máxima do lançamento de saída).
@export var max_height_fraction: float = 0.6
@export var min_height_below_exit: float = 1.0


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	if curves.is_empty() or tube_config == null:
		return Result.FAILED
	var entry := generator.make_platform(entry_platform)
	entry.width = minf(entry.width, entry_max_width)
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		if not generator.place_step(entry, chunk):
			return Result.CHUNK_END
		var flip := generator.flip_for_progression()
		var side := object_sign(flip)
		var curve: Curve3D = curves[generator.rng.randi() % curves.size()]
		var length := curve.get_baked_length()
		var end_point := curve.sample_baked(length)
		var before_end := curve.sample_baked(maxf(length - 0.25, 0.0))

		var tube := generator.make_platform(platform_config)
		tube.angle = entry.angle
		tube.height = entry.height + CylinderSpace.PLAYER_CENTER_HEIGHT
		tube.flip = flip
		tube.object_properties = {"path_curve_override": curve}

		var exit_angle := generator.angle_from(tube.angle, end_point.x * side)
		var exit_feet := tube.height + end_point.y - CylinderSpace.PLAYER_CENTER_HEIGHT
		var local_launch: Vector2
		if tube_config.preserve_velocity:
			local_launch = (Vector2(end_point.x, end_point.y) - Vector2(before_end.x, before_end.y)).normalized() * tube_config.speed
		else:
			local_launch = CylinderSpace.direction_from_degrees(tube_config.exit_direction_degrees) * tube_config.exit_force
		var launch := generator.clamp_launch(Vector2(local_launch.x * side, local_launch.y))
		var apex := JumpReach.apex_height(generator.movement, launch.y)
		var gap := generator.rng.randf_range(-min_height_below_exit, maxf(apex * max_height_fraction, -min_height_below_exit + 0.1))
		var offset := generator.landing_offset(launch, gap)
		if is_nan(offset):
			continue
		var landing := generator.make_platform(landing_platform, chunk.difficulty.platform_size_multiplier)
		landing.height = exit_feet + gap
		landing.angle = generator.angle_from(exit_angle, offset)

		var footprints := [GenerationFootprint.for_platform(entry), GenerationFootprint.for_platform(landing)]
		var tube_footprints := []
		var samples := maxi(ceili(length), 2)
		for i in samples:
			var point := curve.sample_baked(length * i / samples)
			var point_height := tube.height + point.y
			tube_footprints.append(GenerationFootprint.box(generator.angle_from(tube.angle, point.x * side), tube_config.tube_radius, point_height - 0.6, point_height + 0.6))
		# A plataforma de pouso não pode atravessar o próprio tubo (a saída em si fica livre).
		var landing_clear := true
		for tube_footprint: GenerationFootprint in tube_footprints:
			if tube_footprint.top < exit_feet - 0.2 and footprints[1].overlaps(tube_footprint, generator.get_orbit_radius()):
				landing_clear = false
		if not landing_clear or not generator.is_free(footprints + tube_footprints):
			continue
		tube.hints = {"entry": entry, "landing": landing}
		generator.commit(chunk, entry, [footprints[0]])
		generator.commit(chunk, tube, tube_footprints)
		generator.commit(chunk, landing, [footprints[1]])
		generator.set_anchor(landing)
		return Result.PLACED
	return Result.FAILED
