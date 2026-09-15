class_name CannonPlacementRule
extends PlacementRule
## Canhão móvel: entrada pequena (passo alcançável) com o canhão no centro; a plataforma de pouso
## (larga) fica onde um disparo com um ângulo sorteado, voltado para a subida, desce. O jogador ainda
## pode corrigir no ar; o ângulo alvo fica em `hints` para testes e depuração.

@export var cannon_config: CannonConfig
@export var entry_platform: PlatformConfig
@export var landing_platform: PlatformConfig
## Entrada estreita: parado em qualquer ponto dela, o jogador fica dentro do raio de captura da boca.
@export var entry_width: float = 1.0
## Altura da boca do canhão gerado (aplicada em Cannon.mouth_height).
@export var mouth_height: float = 0.6
## Faixa do ângulo alvo (graus a partir da vertical, para o sentido da subida).
@export var min_target_angle: float = 15.0
@export var max_target_angle: float = 35.0
## Altura do pouso como fração da altura máxima do disparo.
@export_range(0.1, 1.0, 0.05) var min_height_fraction: float = 0.3
@export_range(0.1, 1.0, 0.05) var max_height_fraction: float = 0.7
## Deslocamento máximo ao redor do cilindro até o pouso.
@export var max_distance: float = 11.0


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var entry := generator.make_platform(entry_platform)
	entry.width = entry_width
	for attempt in LevelGenerator.PLACEMENT_ATTEMPTS:
		if not generator.place_step(entry, chunk):
			return Result.CHUNK_END
		var flip := generator.flip_for_progression()
		var side := object_sign(flip)
		var aim := clampf(generator.rng.randf_range(min_target_angle, max_target_angle), cannon_config.min_angle, cannon_config.max_angle)
		var radians := deg_to_rad(aim)
		var launch := generator.clamp_launch(Vector2(sin(radians) * side, cos(radians)) * cannon_config.launch_force)
		var apex := JumpReach.apex_height(generator.movement, launch.y)
		var gap := generator.rng.randf_range(apex * min_height_fraction, apex * max_height_fraction)
		var offset := generator.landing_offset(launch, gap)
		if is_nan(offset) or absf(offset) > max_distance:
			continue
		var cannon := generator.make_platform(platform_config)
		cannon.angle = entry.angle
		cannon.height = entry.height
		cannon.flip = flip
		cannon.object_properties = {"mouth_height": mouth_height}
		var landing := generator.make_platform(landing_platform, chunk.difficulty.platform_size_multiplier)
		landing.height = entry.height + mouth_height - CylinderSpace.PLAYER_CENTER_HEIGHT + gap
		landing.angle = generator.angle_from(entry.angle, offset)
		var footprints := [
			GenerationFootprint.for_platform(entry),
			GenerationFootprint.box(cannon.angle, 0.8, entry.height, entry.height + mouth_height + 0.9),
			GenerationFootprint.for_platform(landing),
		]
		if not generator.is_free(footprints):
			continue
		cannon.hints = {"aim": aim, "entry": entry, "landing": landing}
		generator.commit(chunk, entry, [footprints[0]])
		generator.commit(chunk, cannon, [footprints[1]])
		generator.commit(chunk, landing, [footprints[2]])
		generator.set_anchor(landing)
		return Result.PLACED
	return Result.FAILED
