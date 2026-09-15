class_name LevelGenerator
extends Node
## Gera dados de chunks (sem criar nós), em sequência e de forma determinística pela seed.
## A continuidade entre chunks vem da última plataforma gerada.

@export var config: WorldGenerationConfig
## Usado para limitar distâncias ao que o personagem consegue alcançar.
@export var movement: PlayerMovementConfig

var _world_seed: int = 0
var _next_chunk_index: int = 0
var _last_platform: PlatformData
var _direction: float = 1.0
var _lock_direction: bool = false
var _rng := RandomNumberGenerator.new()


func reset(world_seed: int) -> void:
	assert(config and config.chunk_config and config.difficulty and config.start_platform, "WorldGenerationConfig incompleto")
	assert(movement, "LevelGenerator precisa de PlayerMovementConfig")
	_world_seed = world_seed
	_next_chunk_index = 0
	_last_platform = null
	_direction = 1.0
	_lock_direction = false


func get_next_chunk_index() -> int:
	return _next_chunk_index


func generate_next_chunk() -> LevelChunkData:
	var chunk := LevelChunkData.new()
	chunk.index = _next_chunk_index
	chunk.start_height = chunk.index * config.chunk_config.chunk_height
	chunk.end_height = chunk.start_height + config.chunk_config.chunk_height
	chunk.chunk_seed = hash(Vector2i(_world_seed, chunk.index))
	var start_meters := config.to_meters(chunk.start_height)
	chunk.difficulty = config.difficulty.evaluate(start_meters)
	chunk.theme = config.theme_config.get_theme_for_height(start_meters) if config.theme_config else null
	_rng.seed = chunk.chunk_seed
	_next_chunk_index += 1

	if _last_platform == null:
		_add_start_platform(chunk)
	elif config.chunk_start_platform:
		_try_add_step(chunk, config.chunk_start_platform)

	while _try_add_step(chunk, _pick_platform_config(config.to_meters(_last_platform.height))):
		pass
	return chunk


func _add_start_platform(chunk: LevelChunkData) -> void:
	var data := _make_platform(config.start_platform, 1.0)
	data.height = chunk.start_height
	data.angle = wrapf(deg_to_rad(config.start_angle_degrees), 0.0, TAU)
	chunk.platforms.append(data)
	_last_platform = data


## Gera a próxima plataforma do caminho principal. Retorna false quando ela pertenceria ao próximo chunk.
func _try_add_step(chunk: LevelChunkData, platform_config: PlatformConfig) -> bool:
	var previous := _last_platform
	var data := _make_platform(platform_config, chunk.difficulty.platform_size_multiplier)
	data.height = _roll_height_above(previous, chunk)
	if data.height >= chunk.end_height:
		return false
	var vertical_gap := data.height - previous.height

	if _lock_direction:
		_lock_direction = false
	elif _rng.randf() < config.direction_change_chance:
		_direction = -_direction
	var step := _roll_angular_step(previous, data, vertical_gap, chunk.difficulty)
	data.angle = wrapf(previous.angle + _direction * step, 0.0, TAU)
	chunk.platforms.append(data)
	_last_platform = data

	if _rng.randf() < chunk.difficulty.branch_platform_chance:
		_try_add_branch(chunk, previous)
	return true


## Plataforma lateral opcional, alcançável a partir da mesma plataforma que o passo principal.
func _try_add_branch(chunk: LevelChunkData, origin: PlatformData) -> void:
	var branch_config := _pick_platform_config(config.to_meters(origin.height))
	var data := _make_platform(branch_config, chunk.difficulty.platform_size_multiplier)
	data.height = _roll_height_above(origin, chunk)
	if data.height >= chunk.end_height:
		return
	var vertical_gap := data.height - origin.height
	var step := _roll_angular_step(origin, data, vertical_gap, chunk.difficulty)
	data.angle = wrapf(origin.angle - _direction * step, 0.0, TAU)
	chunk.platforms.append(data)
	# O próximo passo principal segue na mesma direção para não sobrepor a plataforma lateral.
	_lock_direction = true


## Velocidade vertical com que o jogador sai da plataforma: pulo normal ou força do trampolim.
func _launch_speed_for(platform: PlatformData) -> float:
	if _is_launcher(platform):
		return maxf(config.trampoline_config.trampoline_force, movement.jump_force)
	return movement.jump_force


func _is_launcher(platform: PlatformData) -> bool:
	return platform.platform_type == PlatformType.Type.TRAMPOLINE and config.trampoline_config != null


func _make_platform(platform_config: PlatformConfig, size_multiplier: float) -> PlatformData:
	var data := PlatformData.new()
	data.config = platform_config
	data.platform_type = platform_config.platform_type
	data.width = maxf(platform_config.width * size_multiplier, platform_config.min_width)
	data.depth = platform_config.depth
	data.radius = PlatformFactory.radius_for(config.pillar_radius, data.depth, config.platform_embed_depth)
	if absf(config.get_player_orbit_radius() - data.radius) > data.depth * 0.5:
		push_warning("Plataforma '%s' não alcança a trajetória do jogador; aumente depth." % platform_config.id)
	return data


## A primeira plataforma de um chunk nunca fica abaixo do início dele. O ajuste é seguro:
## o sorteio que a empurrou para este chunk já tinha distância maior ou igual.
func _roll_height_above(origin: PlatformData, chunk: LevelChunkData) -> float:
	return maxf(origin.height + _roll_vertical_gap(origin, chunk.difficulty), chunk.start_height)


## Saindo de um trampolim, a distância usa a altura do lançamento: a plataforma seguinte
## fica bem mais alta, virando um atalho de escalada que continua alcançável.
func _roll_vertical_gap(origin: PlatformData, difficulty: DifficultyTier) -> float:
	var launch_speed := _launch_speed_for(origin)
	if launch_speed > movement.jump_force:
		var boost_height := launch_speed * launch_speed / (2.0 * movement.gravity) * config.reachability_margin
		return _rng.randf_range(boost_height * config.boost_min_gap_fraction, boost_height)
	return _roll_normal_vertical_gap(difficulty)


func _roll_normal_vertical_gap(difficulty: DifficultyTier) -> float:
	var reachable := movement.get_max_jump_height() * config.reachability_margin
	var high := minf(config.maximum_vertical_distance * difficulty.vertical_distance_multiplier, reachable)
	var low := minf(config.minimum_vertical_distance * difficulty.vertical_distance_multiplier, high)
	return _rng.randf_range(low, high)


## Passo angular (radianos) respeitando alcance do salto, visibilidade da câmera e sobreposição.
func _roll_angular_step(from: PlatformData, to: PlatformData, vertical_gap: float, difficulty: DifficultyTier) -> float:
	var orbit_radius := config.get_player_orbit_radius()
	var reach := JumpReach.horizontal_reach(movement, vertical_gap, _launch_speed_for(from)) * config.reachability_margin
	if config.maximum_horizontal_jump_distance > 0.0:
		reach = minf(reach, config.maximum_horizontal_jump_distance)
	var half_widths := (from.width + to.width) * 0.5

	var max_step := deg_to_rad(config.maximum_angular_distance) * difficulty.angular_distance_multiplier
	max_step = minf(max_step, (half_widths + reach) / orbit_radius)
	max_step = minf(max_step, deg_to_rad(config.maximum_visible_angular_distance))

	var min_step := deg_to_rad(config.minimum_angular_distance) * difficulty.angular_distance_multiplier
	min_step = maxf(min_step, (half_widths + config.minimum_edge_gap) / orbit_radius)
	min_step = minf(min_step, max_step)
	return _rng.randf_range(min_step, max_step)


func _pick_platform_config(height_m: float) -> PlatformConfig:
	var candidates: Array[PlatformConfig] = []
	var total_weight := 0.0
	# Dois trampolins seguidos criariam um salto duplo sem plataforma de descanso entre eles.
	var avoid_launcher := _last_platform != null and _is_launcher(_last_platform)
	for platform_config in config.platform_configs:
		if platform_config == null or platform_config.weight <= 0.0 or not platform_config.is_available_at(height_m):
			continue
		if avoid_launcher and platform_config.platform_type == PlatformType.Type.TRAMPOLINE:
			continue
		candidates.append(platform_config)
		total_weight += platform_config.weight
	if candidates.is_empty():
		return config.start_platform

	var roll := _rng.randf() * total_weight
	for candidate in candidates:
		roll -= candidate.weight
		if roll <= 0.0:
			return candidate
	return candidates[candidates.size() - 1]
