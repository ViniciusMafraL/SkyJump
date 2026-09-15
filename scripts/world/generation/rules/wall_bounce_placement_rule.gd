class_name WallBouncePlacementRule
extends PlacementRule
## Plataforma-parede com um único pilar. O jogador pula da âncora em direção ao pilar, quica na face
## e é lançado de volta, mais alto, pousando na plataforma seguinte do lado de onde veio:
##
##   ___     |
##           |
##   ____    |
##
## O pouso fica acima do alcance do pulo normal (o pilar é necessário) e a subida continua para
## longe do pilar. A trajetória do quique usa a mesma física do WallPlatform (WallConfig).

@export var wall_config: WallConfig
@export var landing_platform: PlatformConfig
## Distância da borda da âncora até a face do pilar.
@export var min_face_distance: float = 0.8
@export var max_face_distance: float = 1.6
## Altura prevista do contato com o pilar acima da âncora (pulando em direção a ele).
@export var contact_height: float = 1.8
## Altura do pouso acima da âncora.
@export var min_rise: float = 3.2
@export var max_rise: float = 4.4
## Quanto o pilar começa abaixo do topo da âncora.
@export var wall_below: float = 1.0


func place(generator: LevelGenerator, chunk: LevelChunkData) -> Result:
	var anchor := generator.get_anchor()
	if anchor.height >= chunk.end_height:
		return Result.CHUNK_END
	var radius := generator.get_orbit_radius()
	var direction := generator.get_direction()
	var thickness := wall_config.wall_thickness

	var wall := generator.make_platform(platform_config)
	wall.width = thickness
	wall.height = anchor.height - wall_below
	var center_distance := anchor.width * 0.5 + generator.rng.randf_range(min_face_distance, max_face_distance) + thickness * 0.5
	wall.angle = wrapf(anchor.angle + direction * center_distance / radius, 0.0, TAU)

	# O quique lança para longe da face: do lado da âncora, tangente positiva quando direction > 0.
	var bounce := Vector2.from_angle(deg_to_rad(wall_config.jump_angle_degrees)) * wall_config.jump_force
	var launch := generator.clamp_launch(Vector2(bounce.x * direction, bounce.y))
	var apex := JumpReach.apex_height(generator.movement, launch.y)
	var rise := generator.rng.randf_range(min_rise, maxf(min_rise, minf(max_rise, contact_height + apex * 0.85)))
	var offset := generator.landing_offset(launch, rise - contact_height)
	if is_nan(offset):
		return Result.FAILED
	var contact_angle := wrapf(wall.angle - direction * (thickness * 0.5 + generator.movement.foot_radius) / radius, 0.0, TAU)
	var landing := generator.make_platform(landing_platform, chunk.difficulty.platform_size_multiplier)
	landing.height = anchor.height + rise
	landing.angle = generator.angle_from(contact_angle, offset)

	var footprints := [
		GenerationFootprint.box(wall.angle, thickness * 0.5, wall.height, wall.height + wall_config.wall_height),
		GenerationFootprint.for_platform(landing),
	]
	if not generator.is_free(footprints):
		return Result.FAILED
	landing.hints = {"wall_bounce": wall}
	generator.commit(chunk, wall, [footprints[0]])
	generator.commit(chunk, landing, [footprints[1]])
	generator.set_anchor(landing)
	# A subida segue para longe do pilar.
	generator.set_direction(-direction)
	return Result.PLACED
