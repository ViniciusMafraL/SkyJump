class_name MainMenu
extends Control
## Menu principal. Só pede as trocas de cena/tela ao TransitionManager; não conhece o shader.
## Mostra as moedas e a sequência do Desafio Diário e abre o calendário do modo (Day).

@export var control_manager: ControlManager
@export_file("*.tscn") var gameplay_scene_path: String = "res://scenes/main.tscn"
@export_file("*.tscn") var test_room_scene_path: String = "res://scenes/test_room/test_room.tscn"
@export_file("*.tscn") var transition_test_scene_path: String = "res://scenes/transitions/transition_test.tscn"
@export var best_text: String = "Best %s"
@export var login_reward_caption: String = "Daily reward"
## Texto da versão; %s = application/config/version (project.godot).
@export var version_text: String = "v%s"
@export var develop_version_suffix: String = " dev"
## Espera a transição de entrada antes de mostrar a estrela de login.
@export var login_feedback_delay: float = 0.7

@onready var _background: ColorRect = %Background
@onready var _main_screen: Control = %MainScreen
@onready var _settings_screen: ControlSettingsPanel = %ControlSettingsPanel
@onready var _calendar_screen: DailyCalendar = %CalendarScreen
@onready var _login_feedback: StarRewardFeedback = %LoginFeedback
@onready var _best_label: Label = %BestLabel
@onready var _play_button: Button = %PlayButton
@onready var _daily_button: Button = %DailyButton
@onready var _settings_button: Button = %SettingsButton
@onready var _test_room_button: Button = %TestRoomButton
@onready var _transition_test_button: Button = %TransitionTestButton
@onready var _version_label: Label = %VersionLabel


func _ready() -> void:
	# Voltar ao menu encerra qualquer sessão do Desafio Diário.
	DailyChallenge.clear_session()
	_background.color = SkyJumpColors.BLUE
	_best_label.text = best_text % HeightFormat.meters(LocalSave.load_best_height())
	_version_label.text = _version_string()
	_settings_screen.setup(control_manager)
	_play_button.pressed.connect(_on_play_pressed)
	_daily_button.pressed.connect(_change_screen.bind(_calendar_screen))
	_calendar_screen.close_requested.connect(_change_screen.bind(_main_screen))
	_calendar_screen.play_requested.connect(_on_daily_play_requested)
	_settings_button.pressed.connect(_change_screen.bind(_settings_screen))
	_settings_screen.close_requested.connect(_change_screen.bind(_main_screen))
	_test_room_button.pressed.connect(_on_test_room_pressed)
	_transition_test_button.pressed.connect(_on_transition_test_pressed)
	_transition_test_button.visible = OS.is_debug_build()
	UiFeedback.attach_all(_main_screen)
	DailyChallenge.stars_changed.connect(_on_stars_changed)
	_show_screen(_calendar_screen if DailyChallenge.consume_calendar_request() else _main_screen)
	_show_pending_login_reward()


func _on_play_pressed() -> void:
	DailyChallenge.clear_session()
	TransitionManager.change_scene_for_event(gameplay_scene_path, TransitionEvent.PLAY)


func _on_daily_play_requested(date: DailyDate) -> void:
	if DailyChallenge.start_daily(date) == null:
		return
	TransitionManager.change_scene_for_event(gameplay_scene_path, TransitionEvent.PLAY)


func _on_test_room_pressed() -> void:
	TransitionManager.change_scene_for_event(test_room_scene_path, TransitionEvent.OPEN_TEST_ROOM)


func _on_transition_test_pressed() -> void:
	TransitionManager.change_scene_for_event(transition_test_scene_path, TransitionEvent.SCREEN_CHANGE)


## Estrela de login do dia (ganha ao abrir o jogo ou na virada do dia com o menu aberto).
func _show_pending_login_reward() -> void:
	if DailyChallenge.pending_login_reward <= 0:
		return
	await get_tree().create_timer(login_feedback_delay).timeout
	if not is_inside_tree():
		return
	var amount := DailyChallenge.consume_pending_login_reward()
	if amount > 0:
		_login_feedback.show_reward(amount, login_reward_caption, UiIcons.STAR)


func _on_stars_changed(_total: int, _delta: int, reason: StringName) -> void:
	if reason == CurrencyWallet.REASON_LOGIN:
		_show_pending_login_reward()


func _version_string() -> String:
	var text := version_text % ProjectSettings.get_setting("application/config/version", "0")
	if OS.has_feature("develop"):
		text += develop_version_suffix
	return text


## Troca de tela dentro do menu: a tela é trocada enquanto está coberta.
func _change_screen(screen: Control) -> void:
	TransitionManager.play_event(TransitionEvent.SCREEN_CHANGE, _show_screen.bind(screen))


func _show_screen(screen: Control) -> void:
	_main_screen.visible = screen == _main_screen
	_settings_screen.visible = screen == _settings_screen
	_calendar_screen.visible = screen == _calendar_screen
