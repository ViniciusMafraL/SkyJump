class_name DailyRunController
extends Node
## Liga a partida ao Desafio Diário quando existe uma sessão ativa (DailyChallenge.active_session):
## seed e tema do dia (gerador e temas existentes), retomada no último checkpoint coletado, os
## 3 checkpoints com estrela e o fim da partida no último. Sem sessão ativa não faz nada.

@export var game_manager: GameManager
@export var player: PlayerController
@export var score_manager: ScoreManager
@export var progression_manager: ProgressionManager
@export var world_config: WorldGenerationConfig
@export var hud: Hud
@export var run_hud: DailyRunHud
@export var restart_text: String = "CONTINUAR DO CHECKPOINT"
@export var menu_text: String = "CALENDÁRIO"

var session: DailyInfo


func _ready() -> void:
	session = DailyChallenge.active_session
	if session == null or session.progress == null:
		if run_hud:
			run_hud.queue_free()
		return
	var progress := session.progress
	var override := RunOverride.new()
	override.world_seed = session.seed
	override.theme_scene = session.theme_scene
	override.records_enabled = false
	if progress.get_checkpoint_count() > 0:
		override.spawn_height = progress.resume_height
		override.spawn_angle = progress.resume_angle
	else:
		override.spawn_angle = deg_to_rad(world_config.start_angle_degrees)
	game_manager.run_override = override
	# As metas da barra de altitude viram os checkpoints do Daily.
	progression_manager.config = build_progression_config(DailyChallenge.get_checkpoint_distances())
	player.landed.connect(_on_player_landed)
	game_manager.state_changed.connect(_on_state_changed)
	hud.set_game_over_actions(restart_text, menu_text)
	DailyChallenge.request_calendar_on_menu()
	if run_hud:
		run_hud.setup(session, game_manager)


static func build_progression_config(distances: PackedFloat32Array) -> ProgressionConfig:
	var result := ProgressionConfig.new()
	for i in distances.size():
		var milestone := MilestoneData.new()
		milestone.height = distances[i]
		milestone.display_name = "CHECKPOINT %d" % (i + 1)
		result.milestones.append(milestone)
	if distances.size() >= 2:
		result.milestone_interval = maxf(distances[distances.size() - 1] - distances[distances.size() - 2], 1.0)
	return result


## Checkpoint = pousar numa plataforma comum (ponto de retomada seguro) na distância configurada.
func _on_player_landed(platform: Platform) -> void:
	if game_manager.state != GameManager.State.PLAYING or not ThemeData.is_basic_platform(platform.get_object_type()):
		return
	var meters := world_config.to_meters(platform.get_top_height())
	var distances := DailyChallenge.get_checkpoint_distances()
	for i in distances.size():
		if meters >= distances[i] and DailyChallenge.register_checkpoint(i, platform.get_top_height(), platform.current_angle):
			game_manager.run_override.spawn_height = platform.get_top_height()
			game_manager.run_override.spawn_angle = platform.current_angle
	if session.progress.completed:
		game_manager.complete_run()


func _on_state_changed(new_state: GameManager.State, _previous_state: GameManager.State) -> void:
	if new_state in [GameManager.State.FALLING, GameManager.State.COMPLETED]:
		DailyChallenge.update_record(score_manager.run_height)
