class_name TestRoomManager
extends Node
## Inicia a sala de testes e conecta as configurações ativas aos mesmos sistemas do jogo
## (PlayerController, CameraRig, Platform, TrampolinePlatform).

signal test_restarted

@export var settings: TestSettingsManager
@export var layout: TestRoomLayout
@export var player: PlayerController
@export var camera_rig: CameraRig
@export var platform_set: TestPlatformSet
@export var metrics: JumpMetrics
@export_file("*.tscn") var exit_scene_path: String = "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	var active := settings.active
	player.movement = active.movement_config
	camera_rig.config = active.camera_config
	platform_set.trampoline_config = active.trampoline_config
	player.set_platform_source(platform_set)
	camera_rig.setup(layout.get_player_orbit_radius())
	settings.settings_applied.connect(_on_settings_applied)
	restart_test.call_deferred()


## Reposiciona o jogador e recria as plataformas. Mantém as configurações atuais.
func restart_test() -> void:
	platform_set.build(layout)
	player.spawn(deg_to_rad(layout.spawn_angle_degrees), layout.spawn_height, layout.get_player_orbit_radius())
	camera_rig.set_follow_enabled(true)
	camera_rig.snap_to_target()
	if metrics:
		metrics.reset()
	test_restarted.emit()


func exit_to_menu() -> void:
	TransitionManager.change_scene_for_event(exit_scene_path, TransitionEvent.EXIT_TEST_ROOM)


func _physics_process(_delta: float) -> void:
	if player.state != PlayerController.State.DISABLED and player.height < layout.respawn_below_height:
		restart_test()


func _on_settings_applied(_active_config: TestRoomConfig) -> void:
	# Movimento e trampolim leem os valores a cada uso; a câmera precisa recalcular o enquadramento.
	camera_rig.setup(layout.get_player_orbit_radius())
