class_name Hud
extends CanvasLayer
## Interface do protótipo. Apenas reage a sinais dos sistemas; não contém lógica de gameplay.
## A altura é exibida pela barra lateral de progressão (ProgressHUD).

@export var game_manager: GameManager
@export var score_manager: ScoreManager
@export var control_manager: ControlManager
@export var progression_manager: ProgressionManager
@export var fall_flash_color: Color = Color(1.0, 0.25, 0.2, 0.4)
@export var fall_flash_duration: float = 0.6
@export var best_text: String = "Best: %s"

var _flash_tween: Tween

@onready var _controls_ui: Control = %ControlsUI
@onready var _progress_hud: ProgressHUD = %ProgressHUD
@onready var _pause_button: Button = %PauseButton
@onready var _fall_flash: ColorRect = %FallFlash
@onready var _pause_panel: Control = %PausePanel
@onready var _resume_button: Button = %ResumeButton
@onready var _pause_restart_button: Button = %PauseRestartButton
@onready var _controls_button: Button = %ControlsButton
@onready var _test_room_button: Button = %TestRoomButton
@onready var _pause_menu_button: Button = %PauseMenuButton
@onready var _game_over_menu_button: Button = %GameOverMenuButton
@onready var _control_settings_panel: ControlSettingsPanel = %ControlSettingsPanel
@onready var _game_over_panel: Control = %GameOverPanel
@onready var _result_height_label: Label = %ResultHeightLabel
@onready var _new_record_label: Label = %NewRecordLabel
@onready var _result_best_label: Label = %ResultBestLabel
@onready var _restart_button: Button = %RestartButton


func _ready() -> void:
	UiGlyph.fill_button(_pause_button, UiGlyph.Glyph.PAUSE, 22.0)
	_new_record_label.add_theme_color_override(&"font_color", SkyJumpColors.YELLOW)
	UiFeedback.attach_all(self)
	game_manager.state_changed.connect(_on_state_changed)
	game_manager.run_finished.connect(_on_run_finished)
	_progress_hud.setup(progression_manager)
	_pause_button.pressed.connect(game_manager.toggle_pause)
	_resume_button.pressed.connect(game_manager.toggle_pause)
	_pause_restart_button.pressed.connect(game_manager.request_restart)
	_restart_button.pressed.connect(game_manager.request_restart)
	_controls_button.pressed.connect(_open_control_settings)
	_test_room_button.pressed.connect(game_manager.open_test_room)
	_test_room_button.visible = OS.is_debug_build()
	_pause_menu_button.pressed.connect(game_manager.return_to_menu)
	_game_over_menu_button.pressed.connect(game_manager.return_to_menu)
	_control_settings_panel.setup(control_manager)
	_control_settings_panel.close_requested.connect(_close_control_settings)
	_pause_panel.visible = false
	_control_settings_panel.visible = false
	_game_over_panel.visible = false
	_fall_flash.color = Color(fall_flash_color, 0.0)


func _on_state_changed(new_state: GameManager.State, _previous_state: GameManager.State) -> void:
	var playing := new_state == GameManager.State.PLAYING
	_controls_ui.visible = playing
	_pause_button.visible = playing
	_pause_panel.visible = new_state == GameManager.State.PAUSED
	_control_settings_panel.visible = false
	_game_over_panel.visible = new_state == GameManager.State.GAME_OVER
	_progress_hud.visible = new_state != GameManager.State.GAME_OVER
	match new_state:
		GameManager.State.FALLING:
			_play_fall_flash()
		GameManager.State.RESTARTING:
			_clear_fall_flash()


func _on_run_finished(run_height: float, best_height: float, is_new_record: bool) -> void:
	_result_height_label.text = HeightFormat.meters(run_height)
	_new_record_label.visible = is_new_record
	_result_best_label.text = best_text % HeightFormat.meters(best_height)


## Textos dos botões da tela de fim de partida (ex.: Desafio Diário: continuar do checkpoint / calendário).
func set_game_over_actions(restart_text: String, menu_text: String) -> void:
	_restart_button.text = restart_text
	_game_over_menu_button.text = menu_text


func _open_control_settings() -> void:
	_pause_panel.visible = false
	_control_settings_panel.visible = true


func _close_control_settings() -> void:
	_control_settings_panel.visible = false
	_pause_panel.visible = game_manager.state == GameManager.State.PAUSED


func _play_fall_flash() -> void:
	_clear_fall_flash()
	_fall_flash.color = fall_flash_color
	_flash_tween = create_tween()
	_flash_tween.tween_property(_fall_flash, "color:a", 0.0, fall_flash_duration)


func _clear_fall_flash() -> void:
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_fall_flash.color = Color(fall_flash_color, 0.0)
