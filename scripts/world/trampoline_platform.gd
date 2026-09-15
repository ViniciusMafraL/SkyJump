class_name TrampolinePlatform
extends Platform
## TRAMPOLIM comum: lança o personagem para cima ao aterrissar.
## Lê TrampolineConfig a cada lançamento, então alterações valem no próximo salto.

enum Intensity { LOW, NORMAL, HIGH, EXTREME, CUSTOM }

@export var config: TrampolineConfig

@export_group("Gameplay")
@export var intensity: Intensity = Intensity.NORMAL
## Multiplicador usado quando a intensidade é CUSTOM.
@export var custom_multiplier: float = 1.0

@export_group("Visual")
## Cores da seta por intensidade (LOW, NORMAL, HIGH, EXTREME, CUSTOM).
@export var intensity_colors: Array[Color] = [
	Color(0.55, 0.85, 1.0), Color(1.0, 0.95, 0.4), Color(1.0, 0.6, 0.2), Color(1.0, 0.25, 0.3), Color(0.8, 0.5, 1.0),
]

var _ready_at_msec: int = 0

@onready var _arrow: MeshInstance3D = get_node_or_null("Visual/Arrow")


func get_settings_section() -> StringName:
	return &"trampoline"


func get_multiplier() -> float:
	if intensity == Intensity.CUSTOM:
		return custom_multiplier
	return config.get_intensity_multiplier(intensity) if config else 1.0


func get_launch_speed(impact_speed: float = 0.0) -> float:
	if config == null:
		return 0.0
	return (config.trampoline_force + impact_speed * config.trampoline_bounce_multiplier) * get_multiplier()


func reset() -> void:
	_ready_at_msec = 0
	_update_arrow()


func get_state_name() -> String:
	return "%s x%.2f" % [Intensity.keys()[intensity], get_multiplier()]


func on_player_landed(player: PlayerController) -> void:
	if config == null:
		return
	var now := Time.get_ticks_msec()
	if now < _ready_at_msec:
		return
	_ready_at_msec = now + roundi(config.trampoline_cooldown * 1000.0)
	player.launch(get_launch_speed(player.last_impact_speed), config.trampoline_horizontal_force * player.get_facing(), &"trampoline")
	visual.play_bounce()
	play_sound(Sound.LAUNCH)


func trigger_debug(player: PlayerController) -> void:
	if player.current_platform == self:
		_ready_at_msec = 0
		on_player_landed(player)


func _update_arrow() -> void:
	if _arrow == null:
		return
	var length := 0.5 + 0.35 * get_multiplier()
	_arrow.scale = Vector3(1.0, length, 1.0)
	_arrow.position = Vector3(0.0, length * 0.5 + 0.05, 0.0)
	var material := StandardMaterial3D.new()
	material.albedo_color = intensity_colors[clampi(intensity, 0, intensity_colors.size() - 1)]
	material.emission_enabled = true
	material.emission = material.albedo_color * 0.4
	_arrow.material_override = material


func _draw_debug(draw: ObjectDebugDraw) -> void:
	var launch := Vector2(0.0, get_launch_speed())
	draw.launch_arc(current_angle, current_height, current_radius, launch, GameplayObject.debug_movement, Color.YELLOW,
		2.0 * launch.y / (GameplayObject.debug_movement.gravity if GameplayObject.debug_movement else 32.0))
