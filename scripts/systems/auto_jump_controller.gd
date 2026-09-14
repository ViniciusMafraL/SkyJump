class_name AutoJumpController
extends Node
## Pulo automático como sistema independente: verifica as condições e apenas solicita o salto
## pela camada de input. Não altera a física do personagem.

@export var player: PlayerController
@export var control_manager: ControlManager
## Só começa a pular sozinho depois do primeiro comando do jogador em cada tentativa.
@export var wait_for_first_input: bool = true

var _armed: bool = false
var _grounded_time: float = 0.0


func _ready() -> void:
	player.spawned.connect(reset)
	reset()


func reset() -> void:
	_armed = not wait_for_first_input
	_grounded_time = 0.0


func is_armed() -> bool:
	return _armed


func _physics_process(delta: float) -> void:
	if not control_manager.uses_auto_jump():
		_grounded_time = 0.0
		return
	if not _armed:
		_armed = control_manager.get_player_input_state().has_activity()
		if not _armed:
			return
	if not _can_auto_jump():
		_grounded_time = 0.0
		return
	_grounded_time += delta
	if _grounded_time >= control_manager.config.auto_jump_delay:
		_grounded_time = 0.0
		control_manager.request_jump()


func _can_auto_jump() -> bool:
	if not player.is_grounded() or not player.are_controls_enabled():
		return false
	var platform := player.current_platform
	return platform == null or not is_instance_valid(platform) or platform.allows_auto_jump()
