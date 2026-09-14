class_name TestDebugOverlay
extends Label
## Informações de debug da sala: estado atual, valores teóricos e o último salto medido.

@export var refresh_interval: float = 0.1

var _player: PlayerController
var _metrics: JumpMetrics
var _settings: TestSettingsManager
var _time_left: float = 0.0


func setup(player: PlayerController, metrics: JumpMetrics, settings: TestSettingsManager) -> void:
	_player = player
	_metrics = metrics
	_settings = settings


func _process(delta: float) -> void:
	if _player == null or not is_visible_in_tree():
		return
	_time_left -= delta
	if _time_left > 0.0:
		return
	_time_left = refresh_interval
	text = _build_text()


func _build_text() -> String:
	var movement := _player.movement
	var trampoline := _settings.active.trampoline_config
	var flat_air_time := 2.0 * movement.jump_force / movement.gravity
	var lines := PackedStringArray()
	lines.append("FPS %d   %s   Plataforma: %s" % [Engine.get_frames_per_second(), PlayerController.State.keys()[_player.state], _platform_name()])
	lines.append("Altura %.2f   Ângulo %.0f°   Voltas %.2f" % [_player.height, rad_to_deg(_player.angle), _metrics.turns])
	lines.append("Vel. vertical %.1f   Vel. tangencial %.1f" % [_player.vertical_velocity, _player.tangential_speed])
	lines.append("")
	lines.append("TEÓRICO")
	lines.append("Pulo: altura %.2f | ar %.2fs" % [movement.get_max_jump_height(), flat_air_time])
	lines.append("Alcance: parado %.2f | correndo %.2f" % [JumpReach.horizontal_reach(movement, 0.0), movement.horizontal_speed * flat_air_time])
	lines.append("Trampolim: altura %.2f" % trampoline.get_launch_height(movement.gravity))
	lines.append("")
	lines.append("ÚLTIMO SALTO (%s)" % _metrics.last_takeoff_kind)
	lines.append("Pico +%.2f | ar %.2fs | dist. %.2f | Δh %+.2f" % [_metrics.last_peak_height, _metrics.last_air_time, _metrics.last_distance, _metrics.last_height_change])
	if _settings.has_pending_changes:
		lines.append("* alterações do painel ainda não aplicadas")
	return "\n".join(lines)


func _platform_name() -> String:
	var platform := _player.current_platform
	if platform == null or not is_instance_valid(platform) or platform.data == null:
		return "-"
	return PlatformType.Type.keys()[platform.data.platform_type]
