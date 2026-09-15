class_name StairPlacementRule
extends PlacementRule
## Plataforma escada: o primeiro degrau é o passo alcançável; a escada sobe no sentido da subida e a
## próxima plataforma parte do último degrau. A posição dos degraus replica StairPlatform.

@export var stair_config: StairConfig


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var data := generator.make_platform(platform_config)
	var step_radius := data.radius + (stair_config.step_depth - data.depth) * 0.5
	var object_width := data.width
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		data.width = stair_config.step_width
		if not generator.place_step(data, chunk):
			return Result.CHUNK_END
		var flip := generator.flip_for_progression()
		var side := object_sign(flip)
		var first := stair_config.get_step_offset(0)
		var base_angle := CylinderSpace.angle_at(data.angle, -first.x * side, step_radius)
		var base_height := data.height - first.y
		var footprints := []
		var last_angle := data.angle
		var last_height := data.height
		for i in maxi(stair_config.step_count, 1):
			var offset := stair_config.get_step_offset(i)
			last_angle = CylinderSpace.angle_at(base_angle, offset.x * side, step_radius)
			last_height = base_height + offset.y
			footprints.append(GenerationFootprint.box(last_angle, stair_config.step_width * 0.5, last_height - 0.3, last_height + 0.3))
		if not generator.is_free(footprints):
			continue
		data.angle = base_angle
		data.height = base_height
		data.width = object_width
		data.flip = flip
		generator.commit(chunk, data, footprints)
		generator.set_anchor_at(last_angle, last_height, stair_config.step_width)
		return Result.PLACED
	data.width = object_width
	return Result.FAILED
