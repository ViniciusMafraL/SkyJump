class_name TrampolinePlatform
extends Platform
## Plataforma IMPULSORA / TRAMPOLIM: lança o personagem ao aterrissar.
## Lê TrampolineConfig a cada lançamento, então alterações valem no próximo salto.

@export var config: TrampolineConfig

var _ready_at_msec: int = 0


func setup(platform_data: PlatformData, theme: ThemeData) -> void:
	super.setup(platform_data, theme)
	_ready_at_msec = 0


func on_player_landed(player: PlayerController) -> void:
	if config == null:
		return
	var now := Time.get_ticks_msec()
	if now < _ready_at_msec:
		return
	_ready_at_msec = now + roundi(config.trampoline_cooldown * 1000.0)
	var vertical_speed := config.trampoline_force + player.last_impact_speed * config.trampoline_bounce_multiplier
	player.launch(vertical_speed, config.trampoline_horizontal_force * player.get_facing())
	visual.play_bounce()
