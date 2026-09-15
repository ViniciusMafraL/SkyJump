class_name VinePlacementRule
extends PlacementRule
## Vinhas: o primeiro ponto de apoio é o passo alcançável; a próxima plataforma parte do último ponto.
## A posição dos pontos replica VinePlatform (diagonais inclinam para o sentido da subida).

@export var vine_config: VineConfig


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var data := generator.make_platform(platform_config)
	var point_radius := data.radius + (vine_config.point_depth - data.depth) * 0.5
	var object_width := data.width
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		data.width = vine_config.point_size
		if not generator.place_step(data, chunk):
			return Result.CHUNK_END
		var flip := generator.flip_for_progression()
		var side := object_sign(flip)
		var footprints := []
		var last_angle := data.angle
		var last_height := data.height
		for i in maxi(vine_config.point_count, 1):
			var offset := vine_config.get_point_offset(i)
			last_angle = CylinderSpace.angle_at(data.angle, offset.x * side, point_radius)
			last_height = data.height + offset.y
			footprints.append(GenerationFootprint.box(last_angle, vine_config.point_size * 0.5, last_height - 0.3, last_height + 0.3))
		if not generator.is_free(footprints):
			continue
		data.width = object_width
		data.flip = flip
		generator.commit(chunk, data, footprints)
		generator.set_anchor_at(last_angle, last_height, vine_config.point_size)
		return Result.PLACED
	data.width = object_width
	return Result.FAILED
