class_name TestRoomManager
extends Node
## Inicia a sala de testes e conecta as configurações ativas aos mesmos sistemas do jogo
## (PlayerController, CameraRig, Platform, objetos especiais).
## Também seleciona a estação de teste individual de cada objeto especial.

signal test_restarted
signal station_changed(station: ObjectTestStation)

@export var settings: TestSettingsManager
@export var layout: TestRoomLayout
@export var player: PlayerController
@export var camera_rig: CameraRig
@export var platform_set: TestPlatformSet
@export var metrics: JumpMetrics
@export_file("*.tscn") var exit_scene_path: String = "res://scenes/ui/main_menu.tscn"

## Estação atual. null = layout padrão.
var selected_station: ObjectTestStation


func _ready() -> void:
	var active := settings.active
	player.movement = active.movement_config
	camera_rig.config = active.camera_config
	platform_set.active_config = active
	GameplayObject.debug_movement = active.movement_config
	player.set_platform_source(platform_set)
	camera_rig.setup(layout.get_player_orbit_radius())
	settings.settings_applied.connect(_on_settings_applied)
	restart_test.call_deferred()


func get_stations() -> Array[ObjectTestStation]:
	return layout.stations


## -1 = layout padrão. Reinicia o teste na estação escolhida.
func select_station(index: int) -> void:
	selected_station = layout.stations[index] if index >= 0 and index < layout.stations.size() else null
	station_changed.emit(selected_station)
	restart_test()


## Reposiciona o jogador e recria as plataformas e objetos. Mantém as configurações atuais.
func restart_test() -> void:
	platform_set.build(layout, selected_station)
	var spawn_angle := selected_station.spawn_angle_degrees if selected_station else layout.spawn_angle_degrees
	var spawn_height := selected_station.spawn_height if selected_station else layout.spawn_height
	player.spawn(deg_to_rad(spawn_angle), spawn_height, layout.get_player_orbit_radius())
	camera_rig.set_follow_enabled(true)
	camera_rig.snap_to_target()
	if metrics:
		metrics.reset()
	test_restarted.emit()


## Volta todos os objetos ao estado inicial sem mover o jogador.
func reset_objects() -> void:
	platform_set.reset_objects()


func trigger_objects() -> void:
	platform_set.trigger_objects(player)


func set_debug_vectors(enabled: bool) -> void:
	platform_set.set_debug_draw(enabled)


func exit_to_menu() -> void:
	TransitionManager.change_scene_for_event(exit_scene_path, TransitionEvent.EXIT_TEST_ROOM)


func _physics_process(_delta: float) -> void:
	if player.state != PlayerController.State.DISABLED and player.height < layout.respawn_below_height:
		restart_test()


func _on_settings_applied(_active_config: TestRoomConfig) -> void:
	# Movimento e trampolim leem os valores a cada uso; a câmera precisa recalcular o enquadramento
	# e objetos com geometria gerada (escada, vinhas, tubo...) são reconstruídos.
	camera_rig.setup(layout.get_player_orbit_radius())
	platform_set.build(layout, selected_station)
