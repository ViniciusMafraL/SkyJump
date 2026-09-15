class_name TestDebugOverlay
extends Label
## Informações de debug da sala: estado atual, valores teóricos e o último salto medido.

@export var refresh_interval: float = 0.1

var _player: PlayerController
var _metrics: JumpMetrics
var _settings: TestSettingsManager
var _platform_set: TestPlatformSet
var _time_left: float = 0.0


func setup(player: PlayerController, metrics: JumpMetrics, settings: TestSettingsManager) -> void:
	_player = player
	_metrics = metrics
	_settings = settings


func set_platform_set(platform_set: TestPlatformSet) -> void:
	_platform_set = platform_set


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
	lines.append("Vel. vertical %.1f   Vel. tangencial %.1f (+%.1f impulso)" % [_player.vertical_velocity, _player.tangential_speed, _player.launch_tangential_speed])
	lines.append("Modo: %s" % PlayerController.Mode.keys()[_player.mode])
	lines.append_array(_object_lines())
	if _platform_set and not _platform_set.generation_report.is_empty():
		lines.append("")
		lines.append_array(_platform_set.generation_report)
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


## Estado dos objetos especiais da estação (até 4 linhas).
func _object_lines() -> PackedStringArray:
	var lines := PackedStringArray()
	if _platform_set == null:
		return lines
	for object in _platform_set.get_active_objects():
		var state_name := object.get_state_name()
		if state_name.is_empty():
			continue
		lines.append("%s: %s" % [PlatformType.name_of(object.get_object_type()), state_name])
		if lines.size() >= 4:
			break
	return lines


func _platform_name() -> String:
	var platform := _player.current_platform
	if platform == null or not is_instance_valid(platform) or platform.data == null:
		return "-"
	return PlatformType.name_of(platform.data.platform_type)
