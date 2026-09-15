class_name ScoreManager
extends Node
## Pontuação por altura máxima alcançada e recorde local.
## Sinais só são emitidos quando o valor exibido (metro inteiro) muda.

signal current_height_changed(meters: float)
signal run_height_changed(meters: float)
signal best_height_changed(meters: float)
signal new_record_reached(meters: float)

@export var player: PlayerController
@export var world_config: WorldGenerationConfig

## Altura atual em metros.
var current_height: float = 0.0
## Maior altura da tentativa, em unidades do mundo.
var max_height: float = 0.0
## Maior altura da tentativa em metros (a pontuação).
var run_height: float = 0.0
## Recorde local em metros.
var best_height: float = 0.0
## Desligado em modos que não contam para o recorde (ex.: Desafio Diário).
var records_enabled: bool = true

var _best_at_run_start: float = 0.0
var _tracking: bool = false
var _record_announced: bool = false


func _ready() -> void:
	best_height = LocalSave.load_best_height()


func reset_run(start_world_height: float = 0.0) -> void:
	max_height = start_world_height
	current_height = _to_display_meters(start_world_height)
	run_height = current_height
	_best_at_run_start = best_height
	_record_announced = false
	_tracking = true
	current_height_changed.emit(current_height)
	run_height_changed.emit(run_height)
	best_height_changed.emit(best_height)


func is_new_record() -> bool:
	return floori(run_height) > floori(_best_at_run_start)


## Encerra a tentativa e salva o recorde. Retorna true se houve novo recorde.
func finish_run() -> bool:
	_tracking = false
	if not records_enabled:
		return false
	if best_height > _best_at_run_start:
		LocalSave.save_best_height(best_height)
	return is_new_record()


func _physics_process(_delta: float) -> void:
	if not _tracking or player == null:
		return
	var world_height := player.height
	var meters := _to_display_meters(world_height)

	var previous_current := floori(current_height)
	current_height = meters
	if floori(current_height) != previous_current:
		current_height_changed.emit(current_height)

	if world_height <= max_height:
		return
	max_height = world_height
	var previous_run := floori(run_height)
	run_height = maxf(run_height, meters)
	if floori(run_height) != previous_run:
		run_height_changed.emit(run_height)

	if not records_enabled or run_height <= best_height:
		return
	var previous_best := floori(best_height)
	best_height = run_height
	if floori(best_height) != previous_best:
		best_height_changed.emit(best_height)
	if not _record_announced and is_new_record():
		_record_announced = true
		new_record_reached.emit(best_height)


func _to_display_meters(world_height: float) -> float:
	return maxf(world_config.to_meters(world_height), 0.0)
