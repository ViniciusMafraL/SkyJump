class_name StepPlacementRule
extends PlacementRule
## Especial posicionada como um passo comum do caminho (bolha, TNT): alcançável a partir
## da âncora pelo pulo normal, e a próxima plataforma parte dela.

## Largura extra ocupada de cada lado (ex.: objetos que se deslocam ao redor da posição).
@export var sweep_half_width: float = 0.0


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var data := generator.make_platform(platform_config, chunk.difficulty.platform_size_multiplier)
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		if not generator.place_step(data, chunk):
			return Result.CHUNK_END
		var footprint := GenerationFootprint.for_platform(data)
		footprint.half_width += sweep_half_width
		if generator.is_free([footprint]):
			generator.commit(chunk, data, [footprint])
			generator.set_anchor(data, get_launch_speed(generator))
			return Result.PLACED
	return Result.FAILED


## Velocidade vertical com que o jogador deixa esta plataforma.
func get_launch_speed(generator: LevelGenerator) -> float:
	return generator.movement.jump_force
