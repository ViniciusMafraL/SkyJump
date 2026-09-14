extends Node
## Autoload global (TransitionManager): controla o FLUXO das transições de tela.
## SAÍDA (cobre) -> TELA COBERTA (troca de cena/tela) -> ENTRADA (revela).
## Cenas e sistemas só pedem a transição; a aparência vem do TransitionConfig e do shader.

signal transition_started(config: TransitionConfig)
## A tela está totalmente coberta: momento seguro para trocar cena ou estado.
signal screen_covered(config: TransitionConfig)
signal transition_finished(config: TransitionConfig)
signal state_changed(new_state: State)

enum State { IDLE, TRANSITION_OUT, COVERED, TRANSITION_IN }

@export var settings: TransitionSettings

var state: State = State.IDLE
## Transição atual (ou a última executada).
var current_config: TransitionConfig
## Mostra na tela transição, progresso e estado. Começa com o valor de settings.debug_transitions.
var debug_transitions: bool = false:
	set(value):
		debug_transitions = value
		if is_node_ready():
			_overlay.set_debug_visible(value)
## Verdadeiro durante qualquer transição: bloqueia chamadas simultâneas e o input do jogador.
var transition_locked: bool:
	get:
		return state != State.IDLE

var _sequence_id: int = 0
var _tween: Tween
var _elapsed: float = 0.0

@onready var _overlay: TransitionOverlay = $TransitionOverlay


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	debug_transitions = settings.debug_transitions
	_overlay.set_debug_visible(debug_transitions)
	if settings.cover_on_start:
		_intro_sequence(get_event_config(TransitionEvent.GAME_START))


func _process(delta: float) -> void:
	if state != State.IDLE:
		_elapsed += delta
		_overlay.set_pattern_time(_elapsed)
	if debug_transitions:
		_overlay.set_debug_text(_debug_text())


# --- API pública -------------------------------------------------------------------------------

func is_transitioning() -> bool:
	return transition_locked


## Input do jogador e botões devem ser ignorados.
func is_input_locked() -> bool:
	return settings.lock_input and transition_locked


func get_progress() -> float:
	return _overlay.progress


func get_event_config(event: StringName) -> TransitionConfig:
	return settings.get_config(event)


## Cobre a tela (TRANSITION OUT) e permanece coberta até play_in().
## Retorna false se outra transição está em andamento. Aguarde screen_covered para agir.
func play_out(config: TransitionConfig = null) -> bool:
	if not _can_start("play_out"):
		return false
	_out_sequence(_resolve(config))
	return true


## Revela a tela (TRANSITION IN). Aceito com a tela coberta por play_out() ou sem transição
## (nesse caso começa totalmente coberta). Aguarde transition_finished.
func play_in(config: TransitionConfig = null) -> bool:
	if state != State.IDLE and state != State.COVERED:
		_refuse("play_in")
		return false
	_in_sequence(_resolve(config) if config or state == State.IDLE else current_config)
	return true


## Sequência completa na mesma cena: cobre, chama on_covered e revela.
func play(config: TransitionConfig = null, on_covered: Callable = Callable()) -> bool:
	if not _can_start("play"):
		return false
	_full_sequence(_resolve(config), on_covered)
	return true


func play_event(event: StringName, on_covered: Callable = Callable()) -> bool:
	return play(get_event_config(event), on_covered)


## Cobre a tela, carrega e troca a cena, espera a nova cena ficar pronta e revela.
func change_scene(scene_path: String, config: TransitionConfig = null) -> bool:
	if not _can_start("change_scene"):
		return false
	if not ResourceLoader.exists(scene_path):
		push_error("TransitionManager: cena não encontrada: %s" % scene_path)
		return false
	_scene_sequence(scene_path, _resolve(config))
	return true


func change_scene_with_transition(scene_path: String, config: TransitionConfig = null) -> bool:
	return change_scene(scene_path, config)


func change_scene_for_event(scene_path: String, event: StringName) -> bool:
	return change_scene(scene_path, get_event_config(event))


## Desenvolvimento: interrompe a transição atual e inicia outra.
func force_transition(config: TransitionConfig = null, on_covered: Callable = Callable()) -> void:
	cancel()
	play(config, on_covered)


## Interrompe a transição atual e libera a tela imediatamente.
func cancel() -> void:
	_sequence_id += 1
	if _tween and _tween.is_valid():
		# Conclui o tween (em vez de kill) para a sequência pendente acordar e perceber o cancelamento.
		_tween.custom_step(3600.0)
	_overlay.set_progress(0.0)
	_finish(current_config)


# --- Sequências --------------------------------------------------------------------------------

func _intro_sequence(config: TransitionConfig) -> void:
	var id := _begin(config)
	_overlay.apply_config(config, true)
	_overlay.set_progress(1.0)
	_set_state(State.COVERED)
	# Aguarda a cena principal entrar na árvore e desenhar o primeiro frame.
	if not await _wait_frames(id, settings.scene_ready_frames):
		return
	if await _animate(id, config, 0.0, config.get_in_duration(), true):
		_finish(config)


func _out_sequence(config: TransitionConfig) -> void:
	var id := _begin(config)
	if await _animate(id, config, 1.0, config.get_out_duration(), false):
		_cover(config)


func _in_sequence(config: TransitionConfig) -> void:
	var id := _sequence_id
	if state == State.IDLE:
		id = _begin(config)
		_overlay.apply_config(config, true)
		_overlay.set_progress(1.0)
		_set_state(State.COVERED)
	if not await _hold(id, config):
		return
	if await _animate(id, config, 0.0, config.get_in_duration(), true):
		_finish(config)


func _full_sequence(config: TransitionConfig, on_covered: Callable) -> void:
	var id := _begin(config)
	if not await _animate(id, config, 1.0, config.get_out_duration(), false):
		return
	_cover(config)
	if on_covered.is_valid():
		on_covered.call()
	if not await _hold(id, config):
		return
	if await _animate(id, config, 0.0, config.get_in_duration(), true):
		_finish(config)


func _scene_sequence(scene_path: String, config: TransitionConfig) -> void:
	var id := _begin(config)
	# Carrega em paralelo com a saída para a tela ficar coberta o menor tempo possível.
	var threaded := ResourceLoader.load_threaded_request(scene_path) == OK
	if not await _animate(id, config, 1.0, config.get_out_duration(), false):
		return
	_cover(config)
	var scene := await _wait_for_scene(id, scene_path, threaded)
	if id != _sequence_id:
		return
	get_tree().paused = false
	if scene:
		get_tree().change_scene_to_packed(scene)
	else:
		push_error("TransitionManager: falha ao carregar %s" % scene_path)
	if not await _wait_frames(id, settings.scene_ready_frames):
		return
	if not await _hold(id, config):
		return
	if await _animate(id, config, 0.0, config.get_in_duration(), true):
		_finish(config)


# --- Etapas ------------------------------------------------------------------------------------

func _begin(config: TransitionConfig) -> int:
	_sequence_id += 1
	current_config = config
	_elapsed = 0.0
	_overlay.set_input_blocked(settings.lock_input)
	transition_started.emit(config)
	return _sequence_id


## Anima o progresso até target. Retorna false se a sequência foi cancelada no meio.
func _animate(id: int, config: TransitionConfig, target: float, duration: float, in_phase: bool) -> bool:
	_set_state(State.TRANSITION_IN if in_phase else State.TRANSITION_OUT)
	_overlay.apply_config(config, in_phase)
	var distance := absf(target - _overlay.progress)
	if duration <= 0.0 or distance <= 0.0:
		_overlay.set_progress(target)
		return id == _sequence_id
	_tween = create_tween()
	_tween.tween_method(_overlay.set_progress, _overlay.progress, target, duration * distance) \
		.set_trans(config.get_tween_transition()).set_ease(config.get_tween_ease())
	await _tween.finished
	return id == _sequence_id


func _hold(id: int, config: TransitionConfig) -> bool:
	var hold := config.get_hold_duration()
	if hold > 0.0:
		await get_tree().create_timer(hold, true).timeout
	return id == _sequence_id


func _wait_frames(id: int, count: int) -> bool:
	for i in count:
		await get_tree().process_frame
		if id != _sequence_id:
			return false
	return id == _sequence_id


func _wait_for_scene(id: int, scene_path: String, threaded: bool) -> PackedScene:
	if threaded:
		while ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			if id != _sequence_id:
				return null
		if ResourceLoader.load_threaded_get_status(scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
			return ResourceLoader.load_threaded_get(scene_path) as PackedScene
	return load(scene_path) as PackedScene


func _cover(config: TransitionConfig) -> void:
	_set_state(State.COVERED)
	screen_covered.emit(config)


func _finish(config: TransitionConfig) -> void:
	_overlay.set_input_blocked(false)
	var was_active := state != State.IDLE
	_set_state(State.IDLE)
	if was_active:
		transition_finished.emit(config)


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(new_state)


func _can_start(caller: String) -> bool:
	if state == State.IDLE:
		return true
	_refuse(caller)
	return false


func _refuse(caller: String) -> void:
	if debug_transitions:
		print_debug("TransitionManager.%s ignorado: transição em andamento (%s)" % [caller, State.keys()[state]])


func _resolve(config: TransitionConfig) -> TransitionConfig:
	return config if config else settings.default_config


func _debug_text() -> String:
	return "Current Transition: %s\nProgress: %.2f\nState: %s" % [
		current_config.get_display_name() if current_config else "-",
		_overlay.progress,
		State.keys()[state],
	]
