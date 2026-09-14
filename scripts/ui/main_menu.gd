class_name MainMenu
extends Control
## Menu principal. Só pede as trocas de cena/tela ao TransitionManager; não conhece o shader.

@export var control_manager: ControlManager
@export_file("*.tscn") var gameplay_scene_path: String = "res://scenes/main.tscn"
@export_file("*.tscn") var test_room_scene_path: String = "res://scenes/test_room/test_room.tscn"
@export_file("*.tscn") var transition_test_scene_path: String = "res://scenes/transitions/transition_test.tscn"

@onready var _main_screen: Control = %MainScreen
@onready var _settings_screen: ControlSettingsPanel = %ControlSettingsPanel
@onready var _best_label: Label = %BestLabel
@onready var _play_button: Button = %PlayButton
@onready var _settings_button: Button = %SettingsButton
@onready var _test_room_button: Button = %TestRoomButton
@onready var _transition_test_button: Button = %TransitionTestButton


func _ready() -> void:
	_best_label.text = "Recorde: %s" % HeightFormat.meters(LocalSave.load_best_height())
	_settings_screen.setup(control_manager)
	_play_button.pressed.connect(_on_play_pressed)
	_settings_button.pressed.connect(_change_screen.bind(_settings_screen))
	_settings_screen.close_requested.connect(_change_screen.bind(_main_screen))
	_test_room_button.pressed.connect(_on_test_room_pressed)
	_transition_test_button.pressed.connect(_on_transition_test_pressed)
	_test_room_button.visible = OS.is_debug_build()
	_transition_test_button.visible = OS.is_debug_build()
	_show_screen(_main_screen)


func _on_play_pressed() -> void:
	TransitionManager.change_scene_for_event(gameplay_scene_path, TransitionEvent.PLAY)


func _on_test_room_pressed() -> void:
	TransitionManager.change_scene_for_event(test_room_scene_path, TransitionEvent.OPEN_TEST_ROOM)


func _on_transition_test_pressed() -> void:
	TransitionManager.change_scene_for_event(transition_test_scene_path, TransitionEvent.SCREEN_CHANGE)


## Troca de tela dentro do menu: a tela é trocada enquanto está coberta.
func _change_screen(screen: Control) -> void:
	TransitionManager.play_event(TransitionEvent.SCREEN_CHANGE, _show_screen.bind(screen))


func _show_screen(screen: Control) -> void:
	_main_screen.visible = screen == _main_screen
	_settings_screen.visible = screen == _settings_screen
