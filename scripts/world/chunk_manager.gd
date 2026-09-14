class_name ChunkManager
extends PlatformSource
## Mantém instanciados apenas os chunks próximos ao jogador.
## Também é a fonte das plataformas ativas para a detecção de chão.

signal chunk_loaded(chunk: LevelChunk)
signal chunk_unloaded(index: int)

@export var generator: LevelGenerator
@export var default_platform_scene: PackedScene

var _chunks: Dictionary = {}
var _active_platforms: Array[Platform] = []
var _focus_index: int = 0


## Recria o mundo. `focus_height` permite começar mais acima (checkpoints):
## os dados abaixo são gerados e descartados para manter a sequência determinística.
func reset(world_seed: int, focus_height: float = 0.0) -> void:
	for index in _chunks.keys():
		_unload_chunk(index)
	generator.reset(world_seed)
	_focus_index = _index_for_height(focus_height)
	var first_kept := _focus_index - _chunk_config().chunks_behind
	while generator.get_next_chunk_index() < first_kept:
		generator.generate_next_chunk()
	_refresh_window()


func update_focus_height(height: float) -> void:
	var index := _index_for_height(height)
	if index > _focus_index:
		_focus_index = index
		_refresh_window()


func get_active_platforms() -> Array[Platform]:
	return _active_platforms


## Altura abaixo da qual não há mais plataformas carregadas. -INF enquanto o chunk 0 existir.
func get_lowest_loaded_height() -> float:
	if _chunks.is_empty() or _chunks.has(0):
		return -INF
	var lowest: int = _chunks.keys().min()
	return lowest * _chunk_config().chunk_height


func _refresh_window() -> void:
	var config := _chunk_config()
	while generator.get_next_chunk_index() <= _focus_index + config.chunks_ahead:
		_load_chunk(generator.generate_next_chunk())
	for index in _chunks.keys():
		if index < _focus_index - config.chunks_behind:
			_unload_chunk(index)


func _load_chunk(data: LevelChunkData) -> void:
	var chunk := LevelChunk.new()
	chunk.name = "Chunk_%d" % data.index
	add_child(chunk)
	chunk.build(data, default_platform_scene)
	_chunks[data.index] = chunk
	_active_platforms.append_array(chunk.platforms)
	chunk_loaded.emit(chunk)


func _unload_chunk(index: int) -> void:
	var chunk: LevelChunk = _chunks[index]
	_chunks.erase(index)
	for platform in chunk.platforms:
		_active_platforms.erase(platform)
	remove_child(chunk)
	chunk.queue_free()
	chunk_unloaded.emit(index)


func _index_for_height(height: float) -> int:
	return maxi(floori(height / _chunk_config().chunk_height), 0)


func _chunk_config() -> ChunkConfig:
	return generator.config.chunk_config
