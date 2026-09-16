class_name LevelGenerator
extends Node
## Gera dados de chunks (sem criar nós), em sequência e de forma determinística pela seed.
## A cada passo: 1) escolhe o TIPO pela distribuição do tema (comum x especiais, por peso);
## 2) decide a POSIÇÃO: comuns usam o alcance do salto; especiais delegam à PlacementRule do tipo.
## A continuidade entre passos, seções e chunks vem da âncora (de onde o jogador parte).

const COMMON_KEY := &"common"
const MAX_FOOTPRINTS := 80
const PLACEMENT_ATTEMPTS := 4
## Folga vertical mínima entre um anel de checkpoint e a plataforma logo abaixo dele.
const CHECKPOINT_CLEARANCE := 1.2

@export var config: WorldGenerationConfig
## Usado para limitar distâncias ao que o personagem consegue alcançar.
@export var movement: PlayerMovementConfig

var rng := RandomNumberGenerator.new()
## Distribuição do tema ativo. null = somente plataformas comuns.
var distribution: PlatformDistribution
## Escolhas desde o reset: COMMON_KEY ou o id da regra especial (balanceamento e testes).
var selection_counts: Dictionary = {}
## Sequência das escolhas desde o reset.
var selection_history: Array[StringName] = []
## Alturas (unidades do mundo, crescentes) dos anéis de checkpoint. Vazio = sem checkpoints (modo
## normal). Definida por quem usa o gerador (Desafio Diário); o reset não a limpa.
var checkpoint_heights: PackedFloat32Array = PackedFloat32Array()

var _world_seed: int = 0
var _next_chunk_index: int = 0
var _anchor: GenerationAnchor
var _direction: float = 1.0
var _lock_direction: bool = false
var _commons_since_special: int = 0
var _footprints: Array[GenerationFootprint] = []
var _unique_id: int = 0
var _next_checkpoint: int = 0


func reset(world_seed: int, platform_distribution: PlatformDistribution = null) -> void:
	assert(config and config.chunk_config and config.difficulty and config.start_platform, "WorldGenerationConfig incompleto")
	assert(movement, "LevelGenerator precisa de PlayerMovementConfig")
	_world_seed = world_seed
	distribution = platform_distribution
	_next_chunk_index = 0
	_anchor = null
	_direction = 1.0
	_lock_direction = false
	_commons_since_special = 0
	_footprints.clear()
	selection_counts.clear()
	selection_history.clear()
	_unique_id = 0
	_next_checkpoint = 0


func get_next_chunk_index() -> int:
	return _next_chunk_index


func generate_next_chunk() -> LevelChunkData:
	var chunk := LevelChunkData.new()
	chunk.index = _next_chunk_index
	chunk.start_height = chunk.index * config.chunk_config.chunk_height
	chunk.end_height = chunk.start_height + config.chunk_config.chunk_height
	chunk.chunk_seed = hash(Vector2i(_world_seed, chunk.index))
	chunk.difficulty = config.difficulty.evaluate(config.to_meters(chunk.start_height))
	rng.seed = chunk.chunk_seed
	_next_chunk_index += 1

	var first_chunk := _anchor == null
	if first_chunk:
		_add_start_platform(chunk)
	match _try_place_checkpoint(chunk):
		PlacementRule.Result.CHUNK_END:
			return chunk
		PlacementRule.Result.FAILED:
			# O anel de checkpoint já serve de descanso; sem ele, a plataforma de início de chunk.
			if not first_chunk and config.chunk_start_platform:
				_try_add_common(chunk, config.chunk_start_platform, false)

	while _try_next(chunk):
		pass
	return chunk


## Chunk sem preenchimento automático, para montar seções específicas (testes e ferramentas).
func begin_manual_chunk(height_span: float) -> LevelChunkData:
	var chunk := LevelChunkData.new()
	chunk.index = _next_chunk_index
	chunk.start_height = chunk.index * config.chunk_config.chunk_height
	chunk.end_height = chunk.start_height + height_span
	chunk.chunk_seed = hash(Vector2i(_world_seed, chunk.index))
	chunk.difficulty = config.difficulty.evaluate(config.to_meters(chunk.start_height))
	rng.seed = chunk.chunk_seed
	_next_chunk_index += 1
	if _anchor == null:
		_add_start_platform(chunk)
	return chunk


func add_common_step(chunk: LevelChunkData) -> bool:
	return _try_add_common(chunk, pick_common_config(config.to_meters(_anchor.height)), true)


## Coloca a seção de uma regra a partir da âncora atual (usado pelo sorteio, testes e ferramentas).
func place_rule(rule: PlacementRule, chunk: LevelChunkData) -> PlacementRule.Result:
	var result := rule.place(self, chunk)
	if result == PlacementRule.Result.PLACED:
		_commons_since_special = 0
		_count(rule.get_selection_key())
	return result


# ---------------------------------------------------------------- API para as regras

func get_anchor() -> GenerationAnchor:
	return _anchor


## Sentido da subida: +1 = ângulo crescente (esquerda da tela), -1 = direita.
func get_direction() -> float:
	return _direction


## Força o sentido da subida (ex.: depois de quicar num pilar) e evita a próxima inversão aleatória.
func set_direction(value: float) -> void:
	if not is_zero_approx(value):
		_direction = signf(value)
	_lock_direction = true


## Objetos direcionais apontam o "lado direito" deles para o sentido da subida.
func flip_for_progression() -> bool:
	return _direction > 0.0


func get_orbit_radius() -> float:
	return config.get_player_orbit_radius()


## Altura de pulo usada pela geração (com a margem de segurança).
func get_safe_jump_height() -> float:
	return movement.get_max_jump_height() * config.reachability_margin


## Altura do próximo anel de checkpoint ainda não gerado (NAN se não houver).
func get_pending_checkpoint_height() -> float:
	return checkpoint_heights[_next_checkpoint] if _next_checkpoint < checkpoint_heights.size() else NAN


func make_platform(platform_config: PlatformConfig, size_multiplier: float = 1.0) -> PlatformData:
	var data := PlatformData.new()
	data.config = platform_config
	data.platform_type = platform_config.platform_type
	data.width = maxf(platform_config.width * size_multiplier, platform_config.min_width)
	data.depth = platform_config.depth
	data.radius = PlatformFactory.radius_for(config.pillar_radius, data.depth, config.platform_embed_depth)
	if absf(config.get_player_orbit_radius() - data.radius) > data.depth * 0.5:
		push_warning("Plataforma '%s' não alcança a trajetória do jogador; aumente depth." % platform_config.id)
	return data


## Ângulo a `tangent_offset` (positivo = direita da tela) de `base_angle`, na trajetória do jogador.
func angle_from(base_angle: float, tangent_offset: float) -> float:
	return CylinderSpace.angle_at(base_angle, tangent_offset, get_orbit_radius())


func clamp_launch(launch: Vector2) -> Vector2:
	return Vector2(
		clampf(launch.x, -movement.max_launch_tangential_speed, movement.max_launch_tangential_speed),
		clampf(launch.y, -movement.fall_speed_limit, movement.max_launch_vertical_speed))


## Deslocamento tangencial onde um lançamento pousa `height_gap` acima do ponto de saída. NAN se inalcançável.
func landing_offset(launch: Vector2, height_gap: float) -> float:
	return JumpReach.launch_landing_offset(movement, clamp_launch(launch), height_gap)


## Posiciona `data` como próximo passo alcançável a partir da âncora (altura e ângulo).
## Retorna false quando o passo pertenceria ao próximo chunk.
func place_step(data: PlatformData, chunk: LevelChunkData) -> bool:
	var origin := _anchor
	data.height = maxf(origin.height + _roll_vertical_gap(origin, chunk.difficulty), chunk.start_height)
	data.height = _clear_below_checkpoint(origin.height, data.height)
	if data.height >= chunk.end_height:
		return false
	var vertical_gap := data.height - origin.height
	if _lock_direction:
		_lock_direction = false
	elif rng.randf() < config.direction_change_chance:
		_direction = -_direction
	var step := _roll_angular_step(origin, data.width, vertical_gap, chunk.difficulty)
	data.angle = wrapf(origin.angle + _direction * step, 0.0, TAU)
	return true


func is_free(footprints: Array) -> bool:
	var radius := get_orbit_radius()
	for candidate: GenerationFootprint in footprints:
		for placed in _footprints:
			if candidate.overlaps(placed, radius):
				return false
	return true


## Adiciona a plataforma ao chunk e registra os volumes ocupados (padrão: o da própria plataforma).
func commit(chunk: LevelChunkData, data: PlatformData, footprints: Array = []) -> void:
	chunk.platforms.append(data)
	if footprints.is_empty():
		_footprints.append(GenerationFootprint.for_platform(data))
	else:
		for footprint: GenerationFootprint in footprints:
			_footprints.append(footprint)
	while _footprints.size() > MAX_FOOTPRINTS:
		_footprints.remove_at(0)


func set_anchor(data: PlatformData, launch_speed: float = -1.0) -> void:
	set_anchor_at(data.angle, data.height, data.width, launch_speed)


func set_anchor_at(anchor_angle: float, anchor_height: float, anchor_width: float, launch_speed: float = -1.0) -> void:
	_anchor = GenerationAnchor.at(anchor_angle, anchor_height, anchor_width, launch_speed if launch_speed > 0.0 else movement.jump_force)


## Id único na tentativa (ex.: pares de portais).
func next_unique_id() -> int:
	_unique_id += 1
	return _unique_id


func pick_common_config(height_m: float) -> PlatformConfig:
	var candidates: Array[PlatformConfig] = []
	var total_weight := 0.0
	for platform_config in config.platform_configs:
		if platform_config == null or platform_config.weight <= 0.0 or not platform_config.is_available_at(height_m):
			continue
		candidates.append(platform_config)
		total_weight += platform_config.weight
	if candidates.is_empty():
		return config.start_platform
	var roll := rng.randf() * total_weight
	for candidate in candidates:
		roll -= candidate.weight
		if roll <= 0.0:
			return candidate
	return candidates[candidates.size() - 1]


# ---------------------------------------------------------------- Interno

func _try_next(chunk: LevelChunkData) -> bool:
	match _try_place_checkpoint(chunk):
		PlacementRule.Result.PLACED:
			return true
		PlacementRule.Result.CHUNK_END:
			return false
	var entry := _pick_special_entry()
	if entry:
		match place_rule(entry.rule, chunk):
			PlacementRule.Result.PLACED:
				return true
			PlacementRule.Result.CHUNK_END:
				return false
	return _try_add_common(chunk, pick_common_config(config.to_meters(_anchor.height)), true)


func _pick_special_entry() -> SpecialPlatformEntry:
	if distribution == null or _is_near_checkpoint() or _commons_since_special < distribution.min_common_between_specials:
		return null
	return distribution.pick(rng, config.to_meters(_anchor.height))


func _add_start_platform(chunk: LevelChunkData) -> void:
	var data := make_platform(config.start_platform)
	data.height = chunk.start_height
	data.angle = wrapf(deg_to_rad(config.start_angle_degrees), 0.0, TAU)
	commit(chunk, data)
	set_anchor(data)


## Passo do caminho principal com uma plataforma comum. Retorna false quando pertenceria ao próximo chunk.
func _try_add_common(chunk: LevelChunkData, platform_config: PlatformConfig, counted: bool) -> bool:
	var origin := _anchor
	var data := make_platform(platform_config, chunk.difficulty.platform_size_multiplier)
	for attempt in PLACEMENT_ATTEMPTS:
		if not place_step(data, chunk):
			return false
		if is_free([GenerationFootprint.for_platform(data)]):
			break
	# O caminho principal nunca é interrompido: sem espaço ideal, o último sorteio é mantido.
	commit(chunk, data)
	set_anchor(data)
	if counted:
		_commons_since_special += 1
		_count(COMMON_KEY)
	if not _is_near_checkpoint() and rng.randf() < chunk.difficulty.branch_platform_chance:
		_try_add_branch(chunk, origin)
	return true


## Plataforma lateral opcional, alcançável a partir da mesma origem que o passo principal.
func _try_add_branch(chunk: LevelChunkData, origin: GenerationAnchor) -> void:
	var data := make_platform(pick_common_config(config.to_meters(origin.height)), chunk.difficulty.platform_size_multiplier)
	data.height = maxf(origin.height + _roll_vertical_gap(origin, chunk.difficulty), chunk.start_height)
	if data.height >= chunk.end_height:
		return
	var step := _roll_angular_step(origin, data.width, data.height - origin.height, chunk.difficulty)
	data.angle = wrapf(origin.angle - _direction * step, 0.0, TAU)
	if not is_free([GenerationFootprint.for_platform(data)]):
		return
	commit(chunk, data)
	# O próximo passo principal segue na mesma direção para não sobrepor a plataforma lateral.
	_lock_direction = true


## Saindo de um lançamento forçado (trampolim), a distância usa a altura do lançamento.
func _roll_vertical_gap(origin: GenerationAnchor, difficulty: DifficultyTier) -> float:
	if origin.launch_speed > movement.jump_force:
		var boost_height := JumpReach.apex_height(movement, origin.launch_speed) * config.reachability_margin
		return rng.randf_range(boost_height * config.boost_min_gap_fraction, boost_height)
	var reachable := get_safe_jump_height()
	var high := minf(config.maximum_vertical_distance * difficulty.vertical_distance_multiplier, reachable)
	var low := minf(config.minimum_vertical_distance * difficulty.vertical_distance_multiplier, high)
	return rng.randf_range(low, high)


## Passo angular (radianos) respeitando alcance do salto, visibilidade da câmera e sobreposição.
func _roll_angular_step(origin: GenerationAnchor, width: float, vertical_gap: float, difficulty: DifficultyTier) -> float:
	var orbit_radius := get_orbit_radius()
	var reach := JumpReach.horizontal_reach(movement, vertical_gap, origin.launch_speed) * config.reachability_margin
	if config.maximum_horizontal_jump_distance > 0.0:
		reach = minf(reach, config.maximum_horizontal_jump_distance)
	var half_widths := (origin.width + width) * 0.5

	var max_step := deg_to_rad(config.maximum_angular_distance) * difficulty.angular_distance_multiplier
	max_step = minf(max_step, (half_widths + reach) / orbit_radius)
	max_step = minf(max_step, deg_to_rad(config.maximum_visible_angular_distance))

	var min_step := deg_to_rad(config.minimum_angular_distance) * difficulty.angular_distance_multiplier
	min_step = maxf(min_step, (half_widths + config.minimum_edge_gap) / orbit_radius)
	min_step = minf(min_step, max_step)
	return rng.randf_range(min_step, max_step)


## Anel de checkpoint (volta inteira no cilindro) quando o próximo checkpoint cabe no alcance da âncora.
## Como ocupa todos os ângulos, basta estar no máximo um salto acima para ser alcançável.
func _try_place_checkpoint(chunk: LevelChunkData) -> PlacementRule.Result:
	var target := get_pending_checkpoint_height()
	if is_nan(target) or _anchor == null or config.checkpoint_platform == null:
		return PlacementRule.Result.FAILED
	var height := target
	if _anchor.height > target - CHECKPOINT_CLEARANCE:
		# Salvaguarda (não deveria acontecer): a âncora chegou ao checkpoint; o anel entra logo acima dela.
		push_warning("Checkpoint %d gerado acima da altura prevista (âncora %.2f)" % [_next_checkpoint, _anchor.height])
		height = _anchor.height + CHECKPOINT_CLEARANCE
	elif target - _anchor.height > _anchor_reach_height():
		return PlacementRule.Result.FAILED
	if height >= chunk.end_height:
		return PlacementRule.Result.CHUNK_END
	var data := make_platform(config.checkpoint_platform)
	data.height = maxf(height, chunk.start_height)
	data.angle = _anchor.angle
	data.object_properties = {"checkpoint_index": _next_checkpoint}
	data.hints = {"checkpoint_index": _next_checkpoint, "anchor_height": _anchor.height, "anchor_launch_speed": _anchor.launch_speed}
	commit(chunk, data, [GenerationFootprint.box(data.angle, PI * get_orbit_radius(), data.height - 0.3, data.height + 0.3)])
	# O próximo passo parte do anel com distâncias de uma plataforma comum.
	set_anchor_at(data.angle, data.height, config.start_platform.width)
	_next_checkpoint += 1
	return PlacementRule.Result.PLACED


## Perto do próximo checkpoint só entram passos comuns (especiais podem subir além do anel).
func _is_near_checkpoint() -> bool:
	var target := get_pending_checkpoint_height()
	return not is_nan(target) and _anchor != null and target - _anchor.height <= config.checkpoint_special_clearance


func _anchor_reach_height() -> float:
	if _anchor.launch_speed > movement.jump_force:
		return JumpReach.apex_height(movement, _anchor.launch_speed) * config.reachability_margin
	return get_safe_jump_height()


## Um passo que pararia colado embaixo do próximo anel desce para deixar a folga. Só acontece com o
## anel ainda fora do alcance da âncora, então o passo continua alcançável.
func _clear_below_checkpoint(origin_height: float, height: float) -> float:
	var target := get_pending_checkpoint_height()
	if is_nan(target) or origin_height >= target or height <= target - CHECKPOINT_CLEARANCE:
		return height
	return maxf(target - CHECKPOINT_CLEARANCE, origin_height)


func _count(key: StringName) -> void:
	selection_counts[key] = int(selection_counts.get(key, 0)) + 1
	selection_history.append(key)
