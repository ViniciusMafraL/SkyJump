class_name GameManager
extends Node
## Fluxo geral da partida: COMEÇAR -> SUBIR -> CAIR -> RESULTADO -> TENTAR NOVAMENTE.
## Também faz a ligação inicial entre os sistemas (composition root).

signal state_changed(new_state: State, previous_state: State)
signal run_finished(run_height: float, best_height: float, is_new_record: bool)
## Objetivo da partida alcançado (ex.: 3º checkpoint do Desafio Diário).
signal run_completed

enum State { MENU, PLAYING, PAUSED, FALLING, GAME_OVER, RESTARTING, COMPLETED }

@export var rules: GameRulesConfig
@export var world_config: WorldGenerationConfig
@export var player: PlayerController
@export var camera_rig: CameraRig
@export var chunk_manager: ChunkManager
@export var theme_controller: ThemeController
@export var score_manager: ScoreManager
@export var progression_manager: ProgressionManager
@export var checkpoint_manager: CheckpointManager
@export var input_controller: InputController
@export_file("*.tscn") var test_room_scene_path: String = "res://scenes/test_room/test_room.tscn"
@export_file("*.tscn") var menu_scene_path: String = "res://scenes/ui/main_menu.tscn"

var state: State = State.MENU
## Partida definida por outro modo (seed, tema e ponto de partida). null = partida normal.
var run_override: RunOverride

var _fall_timer: float = 0.0
var _run_new_record: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	camera_rig.setup(world_config.get_player_orbit_radius())
	player.set_platform_source(chunk_manager)
	start_run.call_deferred()


func start_run() -> void:
	_set_state(State.RESTARTING)
	get_tree().paused = false

	var override := run_override
	var checkpoint := checkpoint_manager.get_restart_checkpoint() if override == null else null
	var world_seed: int = override.world_seed if override else (checkpoint.world_seed if checkpoint else _roll_world_seed())
	var spawn_height: float = override.spawn_height if override else (checkpoint.height if checkpoint else 0.0)
	var spawn_angle: float = override.spawn_angle if override else (checkpoint.angle if checkpoint else deg_to_rad(world_config.start_angle_degrees))

	# Tema antes de gerar o mundo (materiais e distribuição de plataformas): o do modo especial, ou
	# sorteado a cada tentativa. Recomeçando de um checkpoint o tema é mantido (mesma seed, mesmo mundo).
	if theme_controller:
		if override and override.theme_scene:
			theme_controller.apply_theme(override.theme_scene)
		elif override == null and checkpoint == null:
			theme_controller.apply_random_theme()
	score_manager.records_enabled = override == null or override.records_enabled
	chunk_manager.reset(world_seed, spawn_height)
	player.spawn(spawn_angle, spawn_height, world_config.get_player_orbit_radius())
	score_manager.reset_run(spawn_height)
	if progression_manager:
		progression_manager.reset_run()
	checkpoint_manager.begin_run(world_seed, checkpoint)
	camera_rig.set_follow_enabled(true)
	camera_rig.snap_to_target()
	_set_state(State.PLAYING)


func request_restart() -> void:
	if state in [State.GAME_OVER, State.PAUSED]:
		TransitionManager.play_event(TransitionEvent.RESTART, start_run)


func return_to_menu() -> void:
	if state == State.PAUSED:
		# Guarda o recorde alcançado na tentativa abandonada.
		score_manager.finish_run()
	TransitionManager.change_scene_for_event(menu_scene_path, TransitionEvent.BACK_TO_MENU)


## Ferramenta de desenvolvimento: abre a sala de testes de gameplay.
func open_test_room() -> void:
	TransitionManager.change_scene_for_event(test_room_scene_path, TransitionEvent.OPEN_TEST_ROOM)


func toggle_pause() -> void:
	if TransitionManager.is_input_locked():
		return
	if state == State.PLAYING:
		get_tree().paused = true
		_set_state(State.PAUSED)
	elif state == State.PAUSED:
		get_tree().paused = false
		_set_state(State.PLAYING)


func _process(_delta: float) -> void:
	if input_controller and input_controller.is_pause_just_pressed():
		toggle_pause()


func _physics_process(delta: float) -> void:
	match state:
		State.PLAYING:
			chunk_manager.update_focus_height(player.height)
			if player.height < _get_death_height():
				_begin_falling()
		State.FALLING:
			if _fall_timer > 0.0:
				_fall_timer -= delta
				# A transição de morte começa antes para a tela ficar coberta ao fim da queda.
				if _fall_timer <= TransitionManager.get_event_config(TransitionEvent.DEATH).get_out_duration():
					_fall_timer = 0.0
					_end_run_with_transition()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED and state == State.PLAYING:
		toggle_pause()


func _get_death_height() -> float:
	var death_height := rules.death_height_threshold
	if rules.max_fall_distance > 0.0:
		death_height = maxf(death_height, score_manager.max_height - rules.max_fall_distance)
	return maxf(death_height, chunk_manager.get_lowest_loaded_height())


## PLAYER MORRE -> calcula e salva o recorde -> queda -> transição de morte -> GAME OVER.
func _begin_falling() -> void:
	_run_new_record = score_manager.finish_run()
	_fall_timer = rules.game_over_delay
	player.set_controls_enabled(false)
	player.play_defeat_effect()
	camera_rig.set_follow_enabled(false)
	_set_state(State.FALLING)


func _end_run_with_transition() -> void:
	if not TransitionManager.play_event(TransitionEvent.DEATH, _finish_run):
		_finish_run()


func _finish_run() -> void:
	player.disable()
	_set_state(State.GAME_OVER)
	run_finished.emit(score_manager.run_height, score_manager.best_height, _run_new_record)


## Objetivo alcançado: encerra a partida sem queda (ex.: Desafio Diário concluído).
func complete_run() -> void:
	if state != State.PLAYING:
		return
	score_manager.finish_run()
	player.disable()
	camera_rig.set_follow_enabled(false)
	_set_state(State.COMPLETED)
	run_completed.emit()


func _roll_world_seed() -> int:
	return randi() if world_config.randomize_seed_each_run else world_config.world_seed


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	var previous := state
	state = new_state
	state_changed.emit(new_state, previous)
