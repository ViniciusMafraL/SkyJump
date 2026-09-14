class_name HapticManager
extends Node
## Camada independente de vibração (haptic feedback). Reage a eventos dos sistemas;
## nenhum botão ou controle vibra diretamente.

enum HapticEvent { LANDING, TRAMPOLINE, ERROR, NEW_RECORD, ABILITY, MILESTONE }

@export var control_manager: ControlManager
@export var player: PlayerController
## Opcionais: ausentes na sala de testes.
@export var game_manager: GameManager
@export var score_manager: ScoreManager
@export var progression_manager: ProgressionManager
## Duração (ms) por evento. 0 desativa o evento.
@export var durations: Dictionary = {
	HapticEvent.LANDING: 0,
	HapticEvent.TRAMPOLINE: 40,
	HapticEvent.ERROR: 120,
	HapticEvent.NEW_RECORD: 80,
	HapticEvent.ABILITY: 30,
	HapticEvent.MILESTONE: 60,
}


func _ready() -> void:
	if player:
		player.landed.connect(func(_platform: Platform) -> void: play(HapticEvent.LANDING))
		player.launched.connect(func(_speed: float) -> void: play(HapticEvent.TRAMPOLINE))
	if game_manager:
		game_manager.state_changed.connect(_on_game_state_changed)
	if score_manager:
		score_manager.new_record_reached.connect(func(_meters: float) -> void: play(HapticEvent.NEW_RECORD))
	if progression_manager:
		progression_manager.milestone_reached.connect(func(_height: float, _index: int, _data: MilestoneData) -> void: play(HapticEvent.MILESTONE))


func play(event: HapticEvent) -> void:
	if control_manager and not control_manager.config.haptics_enabled:
		return
	var duration := int(durations.get(event, 0))
	if duration > 0 and OS.has_feature("mobile"):
		Input.vibrate_handheld(duration)


func _on_game_state_changed(new_state: GameManager.State, _previous_state: GameManager.State) -> void:
	if new_state == GameManager.State.FALLING:
		play(HapticEvent.ERROR)
