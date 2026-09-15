extends Node
## Autoload DailyChallenge (Daily Manager): ponto central do Desafio Diário.
## Compõe partes independentes: data (DailyDateManager), seed e rotação de temas (DailySeed,
## ThemeRotation), save (DailySaveStore), estrelas (StarWallet) e sequência (StreakTracker).
## Não gera mapas nem controla a partida: a cena de gameplay lê a sessão ativa (DailyRunController).

signal stars_changed(total: int, delta: int, reason: StringName)
## Progresso de um Daily mudou (início, checkpoint, conclusão, reset).
signal daily_updated(date_key: String)
signal day_changed(today: DailyDate)
signal streak_changed(current: int, best: int)
signal streak_milestone_reached(days: int)

const DAY_CHECK_INTERVAL := 1.0

@export var config: DailyConfig
## Arquivo de save (padrão: o save local do jogador). Os testes usam um arquivo próprio.
@export var save_path: String = LocalSave.SAVE_PATH

var dates := DailyDateManager.new()
var store := DailySaveStore.new()
var wallet: StarWallet
## Daily sendo jogado (lido pela cena de gameplay). null = partida normal.
var active_session: DailyInfo
## Estrelas de login ganhas e ainda não mostradas (o menu exibe o feedback).
var pending_login_reward: int = 0

var _open_calendar_on_menu: bool = false
var _theme_ids: Array[StringName] = []
var _theme_names: PackedStringArray = []
var _today_key: String = ""
var _day_check_timer: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cache_themes()
	wallet = StarWallet.new(store, config.login_reward_stars, config.checkpoint_reward_stars)
	wallet.stars_changed.connect(func(total: int, delta: int, reason: StringName) -> void: stars_changed.emit(total, delta, reason))
	use_save_path(save_path)


## Carrega (ou cria) o save e processa a estrela de login do dia (primeira execução inclusive).
func use_save_path(path: String) -> void:
	save_path = path
	store.save_path = path
	store.load_data()
	active_session = null
	pending_login_reward = 0
	_today_key = get_today().to_key()
	process_daily_login()
	refresh_streak()


func _process(delta: float) -> void:
	_day_check_timer -= delta
	if _day_check_timer <= 0.0:
		_day_check_timer = DAY_CHECK_INTERVAL
		check_day_change()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_RESUMED:
		check_day_change()


# ---------------------------------------------------------------- Datas e Dailies

func get_today() -> DailyDate:
	return dates.get_today()


func get_current_daily() -> DailyInfo:
	return get_daily(get_today())


func get_previous_daily() -> DailyInfo:
	return get_daily(get_today().add_days(-1))


func get_next_daily() -> DailyInfo:
	return get_daily(get_today().add_days(1))


func get_daily(date: DailyDate) -> DailyInfo:
	var info := DailyInfo.new()
	info.date = date
	info.seed = DailySeed.get_daily_seed(date, config.seed_salt)
	info.theme_index = ThemeRotation.get_theme_index(date, _theme_ids.size(), config.seed_salt)
	if info.theme_index >= 0:
		info.theme_id = _theme_ids[info.theme_index]
		info.theme_name = _theme_names[info.theme_index]
		info.theme_scene = config.theme_library.get_scene(info.theme_index)
	info.progress = store.get_progress(date.to_key())
	info.state = _state_for(date, info.progress, info.seed)
	return info


func get_daily_state(date: DailyDate) -> DailyState.State:
	return get_daily(date).state


func get_daily_progress(date: DailyDate) -> DailyProgress:
	return store.get_progress(date.to_key())


func is_completed(date: DailyDate) -> bool:
	return get_daily_state(date) == DailyState.State.COMPLETED


func can_play(date: DailyDate) -> bool:
	return date != null and DailyState.is_playable(get_daily_state(date))


func get_theme_count() -> int:
	return _theme_ids.size()


func get_checkpoint_distances() -> PackedFloat32Array:
	return config.get_checkpoint_distances()


# ---------------------------------------------------------------- Sessão

## Inicia (ou continua) um Daily jogável e o torna a sessão ativa. Dias futuros, encerrados ou
## concluídos são recusados aqui, independentemente da interface.
func start_daily(date: DailyDate) -> DailyInfo:
	if date == null:
		return null
	var info := get_daily(date)
	if not DailyState.is_playable(info.state):
		return null
	var progress := store.ensure_progress(date.to_key(), info.seed, info.theme_id)
	if not progress.started:
		progress.started = true
	info.progress = progress
	info.state = _state_for(date, progress, info.seed)
	progress.state = info.state
	store.save_history()
	active_session = info
	daily_updated.emit(date.to_key())
	return info


## Continua um Daily já iniciado (IN_PROGRESS).
func continue_daily(date: DailyDate) -> DailyInfo:
	if get_daily_state(date) != DailyState.State.IN_PROGRESS:
		return null
	return start_daily(date)


func clear_session() -> void:
	active_session = null


## Registra o checkpoint `index` (0..2) da sessão ativa, com o ponto de retomada.
## Retorna false se não houver sessão ou se o checkpoint já tinha sido coletado (sem nova estrela).
func register_checkpoint(index: int, resume_height: float, resume_angle: float) -> bool:
	if active_session == null or active_session.progress == null:
		return false
	var progress := active_session.progress
	if not wallet.claim_checkpoint_reward(progress, index):
		return false
	progress.resume_height = resume_height
	progress.resume_angle = resume_angle
	active_session.state = _state_for(active_session.date, progress, active_session.seed)
	progress.state = active_session.state
	store.save_history()
	refresh_streak()
	daily_updated.emit(progress.date_key)
	return true


## Maior altura (metros) do Daily ativo.
func update_record(meters: float) -> void:
	if active_session == null or active_session.progress == null or meters <= active_session.progress.record:
		return
	active_session.progress.record = meters
	store.save_history()


## A volta ao menu abre o calendário (fim de uma partida do Daily).
func request_calendar_on_menu() -> void:
	_open_calendar_on_menu = true


func consume_calendar_request() -> bool:
	var requested := _open_calendar_on_menu
	_open_calendar_on_menu = false
	return requested


# ---------------------------------------------------------------- Estrelas e sequência

func get_stars() -> int:
	return wallet.get_stars()


## Vector2i(atual, melhor).
func get_streak() -> Vector2i:
	return Vector2i(store.current_streak, store.best_streak)


## Estrela de login da data atual (uma vez por data). Retorna as estrelas concedidas.
func process_daily_login() -> int:
	if not wallet.claim_daily_login(get_today()):
		return 0
	pending_login_reward += wallet.login_reward
	return wallet.login_reward


func consume_pending_login_reward() -> int:
	var amount := pending_login_reward
	pending_login_reward = 0
	return amount


func refresh_streak() -> void:
	var rule := config.streak_rule if config.streak_rule else StreakRule.new()
	var current := StreakTracker.current_streak(store.history, get_today(), rule)
	var best := maxi(store.best_streak, maxi(current, StreakTracker.longest_streak(store.history, rule)))
	if current == store.current_streak and best == store.best_streak:
		return
	var previous := store.current_streak
	store.current_streak = current
	store.best_streak = best
	store.save_player()
	for milestone in config.streak_milestones:
		if previous < milestone and current >= milestone:
			streak_milestone_reached.emit(milestone)
	streak_changed.emit(current, best)


## Detecta a virada do dia (meia-noite local ou data simulada). Nunca apaga progresso.
func check_day_change() -> bool:
	var key := get_today().to_key()
	if key == _today_key:
		return false
	_today_key = key
	process_daily_login()
	refresh_streak()
	day_changed.emit(get_today())
	return true


# ---------------------------------------------------------------- Debug (somente builds de debug)

func is_debug_available() -> bool:
	return OS.is_debug_build()


func debug_set_date(date: DailyDate) -> bool:
	if not dates.set_simulated_date(date):
		return false
	check_day_change()
	return true


func debug_advance_days(amount: int) -> bool:
	return debug_set_date(get_today().add_days(amount))


func debug_advance_months(amount: int) -> bool:
	return debug_set_date(get_today().add_months(amount))


func debug_use_real_date() -> void:
	if not is_debug_available():
		return
	dates.clear_simulated_date()
	check_day_change()


## Coleta o próximo checkpoint de um Daily jogável sem jogar (testar estrelas, conclusão e sequência).
func debug_collect_next_checkpoint(date: DailyDate) -> bool:
	if not is_debug_available():
		return false
	var previous_session := active_session
	var info := start_daily(date)
	var collected := false
	if info:
		for i in DailyProgress.CHECKPOINT_COUNT:
			if not info.progress.has_checkpoint(i):
				collected = register_checkpoint(i, 0.0, 0.0)
				break
	active_session = previous_session
	return collected


func debug_reset_daily(date: DailyDate) -> void:
	if not is_debug_available():
		return
	store.remove_progress(date.to_key())
	refresh_streak()
	daily_updated.emit(date.to_key())


func debug_reset_all() -> void:
	if not is_debug_available():
		return
	store.clear()
	active_session = null
	refresh_streak()
	stars_changed.emit(0, 0, StarWallet.REASON_DEBUG)
	daily_updated.emit("")


# ---------------------------------------------------------------- Interno

func _state_for(date: DailyDate, progress: DailyProgress, daily_seed: int) -> DailyState.State:
	if get_today().days_until(date) > 0:
		return DailyState.State.FUTURE
	if progress and progress.seed != daily_seed:
		return DailyState.State.INVALIDATED
	if progress and progress.completed:
		return DailyState.State.COMPLETED
	if progress and progress.started:
		return DailyState.State.IN_PROGRESS
	if get_today().days_until(date) == 0:
		return DailyState.State.AVAILABLE
	return DailyState.State.ENDED


func _cache_themes() -> void:
	_theme_ids.clear()
	_theme_names = PackedStringArray()
	if config == null or config.theme_library == null:
		return
	for scene in config.theme_library.themes:
		var theme := scene.instantiate() as LevelTheme if scene else null
		var data := theme.theme_data if theme else null
		_theme_ids.append(data.id if data else &"")
		_theme_names.append(data.display_name if data else "?")
		if theme:
			theme.free()
