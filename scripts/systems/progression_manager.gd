class_name ProgressionManager
extends Node
## Progressão por altitude: meta atual, metas alcançadas, progresso até a próxima meta e recorde.
## A altura vem do ScoreManager (fonte central de altura/recorde, que salva via LocalSave).
## Não desenha nada: a ProgressHUD apenas visualiza estes dados.

signal milestone_reached(height: float, index: int, data: MilestoneData)
signal milestone_changed(previous_milestone: float, current_milestone: float)
signal new_record(height: float)
signal run_reset

@export var config: ProgressionConfig
## Fonte de altura e do recorde salvo. Vazio = só simulação (testes).
@export var score_manager: ScoreManager

## Altura atual em metros (nunca negativa). Cai quando o player cai.
var current_height: float = 0.0
## Maior altura da partida (as metas alcançadas não voltam).
var run_max_height: float = 0.0
## Recorde pessoal: nunca diminui.
var personal_best_height: float = 0.0
var previous_milestone: float = 0.0
var current_milestone: float = 0.0
var current_milestone_index: int = 0
## 0..1 entre a meta anterior e a próxima.
var progress_to_next_milestone: float = 0.0
var milestones_reached: Array[float] = []
## Altitude simulada pelo debug: não altera nem salva o recorde real.
var is_simulating: bool = false

var _best_at_run_start: float = 0.0
var _record_announced: bool = false


func _ready() -> void:
	reset_run()


func _physics_process(_delta: float) -> void:
	if is_simulating or score_manager == null:
		return
	_update_heights(score_manager.current_height, score_manager.run_height, score_manager.best_height)


## Nova partida: metas recomeçam a partir da altura inicial; o recorde vem do valor salvo.
func reset_run() -> void:
	is_simulating = false
	_record_announced = false
	current_height = maxf(score_manager.current_height, 0.0) if score_manager else 0.0
	run_max_height = maxf(score_manager.run_height, current_height) if score_manager else 0.0
	personal_best_height = score_manager.best_height if score_manager else 0.0
	_best_at_run_start = personal_best_height
	current_milestone_index = config.next_index_for_height(run_max_height)
	milestones_reached.clear()
	for i in current_milestone_index:
		milestones_reached.append(config.get_milestone_height(i))
	_update_window()
	_update_progress()
	run_reset.emit()


func get_milestone_data(index: int) -> MilestoneData:
	return config.get_milestone_data(index)


## DEBUG: simula uma altitude sem mover o player.
func debug_set_height(meters: float) -> void:
	is_simulating = true
	_update_heights(maxf(meters, 0.0), 0.0, 0.0)


func debug_add_height(delta_meters: float) -> void:
	debug_set_height(current_height + delta_meters)


## DEBUG: descarta a simulação e volta a ler a altura real.
func debug_stop_simulation() -> void:
	reset_run()


func _update_heights(height: float, run_max: float, saved_best: float) -> void:
	current_height = maxf(height, 0.0)
	run_max_height = maxf(run_max_height, maxf(run_max, current_height))
	personal_best_height = maxf(personal_best_height, maxf(saved_best, run_max_height))
	while run_max_height >= current_milestone:
		var index := current_milestone_index
		var reached := current_milestone
		milestones_reached.append(reached)
		current_milestone_index += 1
		_update_window()
		milestone_reached.emit(reached, index, config.get_milestone_data(index))
		milestone_changed.emit(previous_milestone, current_milestone)
	_update_progress()
	# Primeira partida (sem recorde anterior) não anuncia "novo recorde".
	var records_enabled := score_manager == null or score_manager.records_enabled
	if records_enabled and not _record_announced and _best_at_run_start > 0.0 and floori(run_max_height) > floori(_best_at_run_start):
		_record_announced = true
		new_record.emit(run_max_height)


func _update_window() -> void:
	previous_milestone = config.get_milestone_height(current_milestone_index - 1)
	current_milestone = config.get_milestone_height(current_milestone_index)


func _update_progress() -> void:
	var span := maxf(current_milestone - previous_milestone, 0.001)
	progress_to_next_milestone = clampf((current_height - previous_milestone) / span, 0.0, 1.0)
