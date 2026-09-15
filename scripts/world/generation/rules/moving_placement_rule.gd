class_name MovingPlacementRule
extends PlacementRule
## Plataforma móvel: o início da trajetória é o passo alcançável; ela se move no sentido da subida e
## a próxima plataforma parte do fim do percurso (o jogador espera a plataforma chegar lá).

@export var moving_config: MovingPlatformConfig
## Amostras da trajetória usadas para reservar o espaço do percurso.
@export var sweep_samples: int = 6


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var data := generator.make_platform(platform_config, chunk.difficulty.platform_size_multiplier)
	var trajectory := moving_config.build_trajectory() if moving_config else LinearTrajectory.new()
	var length := trajectory.get_length()
	var start := trajectory.sample(0.0)
	var finish := trajectory.sample(length)
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		if not generator.place_step(data, chunk):
			return Result.CHUNK_END
		var flip := generator.flip_for_progression()
		var side := object_sign(flip)
		var base_angle := generator.angle_from(data.angle, -start.x * side)
		var base_height := data.height - start.y
		var footprints := []
		for i in sweep_samples + 1:
			var point := trajectory.sample(length * i / maxf(sweep_samples, 1))
			var sample_height := base_height + point.y
			footprints.append(GenerationFootprint.box(generator.angle_from(base_angle, point.x * side), data.width * 0.5, sample_height - 0.3, sample_height + 0.3))
		if not generator.is_free(footprints):
			continue
		data.angle = base_angle
		data.height = base_height
		data.flip = flip
		generator.commit(chunk, data, footprints)
		generator.set_anchor_at(generator.angle_from(base_angle, finish.x * side), base_height + finish.y, data.width)
		return Result.PLACED
	return Result.FAILED
