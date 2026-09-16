class_name DailyRunController
extends Node
## Liga a partida ao Desafio Diário quando existe uma sessão ativa (DailyChallenge.active_session):
## seed e tema do dia (gerador e temas existentes), anéis de checkpoint gerados nas distâncias do
## Daily, retomada no último checkpoint coletado e o fim da partida no último. Sem sessão não faz nada.

@export var game_manager: GameManager
@export var level_generator: LevelGenerator
@export var player: PlayerController
@export var score_manager: ScoreManager
@export var progression_manager: ProgressionManager
@export var world_config: WorldGenerationConfig
@export var hud: Hud
@export var run_hud: DailyRunHud
@export var restart_text: String = "Continue from checkpoint"
@export var menu_text: String = "Calendar"

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
	# Anéis de checkpoint nas distâncias do Daily (antes do start_run deferido gerar o mundo).
	level_generator.checkpoint_heights = to_world_heights(DailyChallenge.get_checkpoint_distances(), world_config)
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
		milestone.display_name = "Checkpoint %d" % (i + 1)
		result.milestones.append(milestone)
	if distances.size() >= 2:
		result.milestone_interval = maxf(distances[distances.size() - 1] - distances[distances.size() - 2], 1.0)
	return result


## Metros -> alturas do mundo.
static func to_world_heights(distances: PackedFloat32Array, config: WorldGenerationConfig) -> PackedFloat32Array:
	var heights := PackedFloat32Array()
	for meters in distances:
		heights.append(meters / config.meters_per_world_unit)
	return heights


## Checkpoint = pousar no anel de checkpoint; a retomada é no ponto do anel onde o jogador pousou.
func _on_player_landed(platform: Platform) -> void:
	var ring := platform as CheckpointRingPlatform
	if ring == null or game_manager.state != GameManager.State.PLAYING:
		return
	if DailyChallenge.register_checkpoint(ring.checkpoint_index, ring.get_top_height(), player.angle):
		game_manager.run_override.spawn_height = ring.get_top_height()
		game_manager.run_override.spawn_angle = player.angle
	if session.progress.completed:
		game_manager.complete_run()


func _on_state_changed(new_state: GameManager.State, _previous_state: GameManager.State) -> void:
	if new_state in [GameManager.State.FALLING, GameManager.State.COMPLETED]:
		DailyChallenge.update_record(score_manager.run_height)
