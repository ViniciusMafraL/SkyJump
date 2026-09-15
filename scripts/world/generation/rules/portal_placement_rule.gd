class_name PortalPlacementRule
extends PlacementRule
## Portais: entrada pequena (passo alcançável) com o portal A logo acima; o portal B fica mais alto e
## deslocado ao redor do cilindro (mudança de rota). A plataforma de pouso fica onde a velocidade de
## saída (REDIRECT, velocidade mínima) leva o jogador, fora do raio do portal B.

@export var portal_config: PortalConfig
@export var entry_platform: PlatformConfig
@export var landing_platform: PlatformConfig
## Entrada estreita: pousar em qualquer ponto dela (inclusive na borda) fica dentro do raio do portal.
@export var entry_width: float = 1.0
## Centro do portal de entrada acima da plataforma (baixo para capturar em toda a entrada).
@export var entry_center_height: float = 0.45
@export var exit_center_height: float = 1.0
## Direção de saída do portal B (graus, relativa ao objeto voltado para a subida).
@export_range(0.0, 180.0, 1.0) var exit_direction_degrees: float = 60.0
@export_group("Route")
## Deslocamento angular do destino (graus, no sentido da subida).
@export var min_route_degrees: float = 90.0
@export var max_route_degrees: float = 150.0
@export var min_rise: float = 4.0
@export var max_rise: float = 8.0
@export var entry_color: Color = Color(1.0, 0.55, 0.15)
@export var exit_color: Color = Color(0.25, 0.6, 1.0)


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var entry := generator.make_platform(entry_platform)
	entry.width = entry_width
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		if not generator.place_step(entry, chunk):
			return Result.CHUNK_END
		var flip := generator.flip_for_progression()
		var side := object_sign(flip)
		var pair := generator.next_unique_id()
		var id_a := StringName("gen_portal_%d_%d_a" % [chunk.index, pair])
		var id_b := StringName("gen_portal_%d_%d_b" % [chunk.index, pair])

		var portal_a := generator.make_platform(platform_config)
		portal_a.angle = entry.angle
		portal_a.height = entry.height
		portal_a.object_properties = {"portal_id": id_a, "destination_id": id_b, "center_height": entry_center_height, "portal_color": entry_color}

		var portal_b := generator.make_platform(platform_config)
		portal_b.angle = wrapf(entry.angle + deg_to_rad(generator.rng.randf_range(min_route_degrees, max_route_degrees)) * generator.get_direction(), 0.0, TAU)
		portal_b.height = entry.height + generator.rng.randf_range(min_rise, max_rise)
		portal_b.flip = flip
		portal_b.object_properties = {"portal_id": id_b, "destination_id": id_a, "center_height": exit_center_height, "exit_direction_degrees": exit_direction_degrees, "portal_color": exit_color}

		# O jogador entra quase parado: REDIRECT usa a velocidade mínima.
		var direction := CylinderSpace.direction_from_degrees(exit_direction_degrees)
		var launch := generator.clamp_launch(Vector2(direction.x * side, direction.y) * portal_config.redirect_min_speed)
		var exit_feet := portal_b.height + exit_center_height - CylinderSpace.PLAYER_CENTER_HEIGHT
		var landing := generator.make_platform(landing_platform, chunk.difficulty.platform_size_multiplier)
		landing.height = portal_b.height
		var offset := generator.landing_offset(launch, landing.height - exit_feet)
		if is_nan(offset):
			continue
		# Mantém o pouso fora do raio do portal de saída.
		if absf(offset) < portal_config.trigger_radius + 0.4:
			offset = signf(launch.x) * (portal_config.trigger_radius + 0.4)
		landing.angle = generator.angle_from(portal_b.angle, offset)

		var footprints := [
			GenerationFootprint.for_platform(entry),
			GenerationFootprint.box(portal_a.angle, 0.7, entry.height, entry.height + entry_center_height + 1.2),
			GenerationFootprint.box(portal_b.angle, 1.2, portal_b.height - 0.2, portal_b.height + exit_center_height + 1.2),
			GenerationFootprint.for_platform(landing),
		]
		if not generator.is_free(footprints):
			continue
		portal_a.hints = {"entry": entry, "destination": portal_b, "landing": landing}
		generator.commit(chunk, entry, [footprints[0]])
		generator.commit(chunk, portal_a, [footprints[1]])
		generator.commit(chunk, portal_b, [footprints[2]])
		generator.commit(chunk, landing, [footprints[3]])
		generator.set_anchor(landing)
		return Result.PLACED
	return Result.FAILED
