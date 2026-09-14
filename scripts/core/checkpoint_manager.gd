class_name CheckpointManager
extends Node
## Registra checkpoints ao aterrissar a cada `checkpoint_interval` metros.
## Desativado por padrão (GameRulesConfig.checkpoints_enabled).

signal checkpoint_reached(checkpoint: CheckpointData)

@export var rules: GameRulesConfig
@export var player: PlayerController
@export var world_config: WorldGenerationConfig

var last_checkpoint: CheckpointData

var _world_seed: int = 0
var _next_checkpoint_height: float = 0.0


func _ready() -> void:
	player.landed.connect(_on_player_landed)


func begin_run(world_seed: int, from_checkpoint: CheckpointData) -> void:
	_world_seed = world_seed
	var start_meters := world_config.to_meters(from_checkpoint.height) if from_checkpoint else 0.0
	_next_checkpoint_height = start_meters + rules.checkpoint_interval


func get_restart_checkpoint() -> CheckpointData:
	return last_checkpoint if rules.checkpoints_enabled else null


func clear() -> void:
	last_checkpoint = null


func _on_player_landed(platform: Platform) -> void:
	if not rules.checkpoints_enabled:
		return
	var meters := world_config.to_meters(platform.get_top_height())
	if meters < _next_checkpoint_height:
		return
	var checkpoint := CheckpointData.new()
	checkpoint.world_seed = _world_seed
	checkpoint.height = platform.get_top_height()
	checkpoint.angle = platform.current_angle
	last_checkpoint = checkpoint
	_next_checkpoint_height = meters + rules.checkpoint_interval
	checkpoint_reached.emit(checkpoint)
