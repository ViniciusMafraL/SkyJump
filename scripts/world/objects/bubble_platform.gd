class_name BubblePlatform
extends Platform
## PLATAFORMA BOLHA / TEMPORÁRIA: ao ser tocada, avisa, desaparece e reaparece depois.
## IDLE -> ACTIVATED -> WARNING -> DISABLED -> RESPAWNING -> READY -> IDLE
## Enquanto DISABLED/RESPAWNING não é sólida: o personagem em cima cai pelo sistema existente.

enum BubbleState { IDLE, ACTIVATED, WARNING, DISABLED, RESPAWNING, READY }

@export var config: BubblePlatformConfig

@export_group("Visual")
@export var idle_color: Color = Color(0.45, 0.85, 1.0, 0.7)
@export var activated_color: Color = Color(1.0, 0.9, 0.35, 0.8)
@export var warning_color: Color = Color(1.0, 0.3, 0.3, 0.85)
@export var ready_color: Color = Color(1.0, 1.0, 1.0, 0.9)
## Duração (s) do brilho de READY antes de voltar a IDLE.
@export var ready_flash_time: float = 0.25

var bubble_state: BubbleState = BubbleState.IDLE
var uses: int = 0

var _timer: float = 0.0
var _mesh_scale: Vector3 = Vector3.ONE
var _material := StandardMaterial3D.new()
var _ring_material := StandardMaterial3D.new()

@onready var _mesh: MeshInstance3D = $Visual/Mesh
@onready var _ring: MeshInstance3D = $Visual/Ring


func get_settings_section() -> StringName:
	return &"bubble"


func reset() -> void:
	uses = 0
	_enter(BubbleState.IDLE)
	_update_visual()


func get_state_name() -> String:
	return "%s %.2fs usos %d" % [BubbleState.keys()[bubble_state], maxf(_timer, 0.0), uses]


## Tempo restante até desaparecer (ACTIVATED + WARNING), em fração 0..1.
func get_remaining_fraction() -> float:
	if config == null:
		return 0.0
	var total := maxf(config.activation_time + config.disappear_delay, 0.001)
	match bubble_state:
		BubbleState.ACTIVATED:
			return (_timer + config.disappear_delay) / total
		BubbleState.WARNING:
			return _timer / total
	return 1.0


func can_activate() -> bool:
	return bubble_state in [BubbleState.IDLE, BubbleState.READY]


func activate() -> void:
	if not can_activate():
		return
	uses += 1
	_enter(BubbleState.ACTIVATED)
	play_sound(Sound.ACTIVATION)


func on_player_landed(_player: PlayerController) -> void:
	activate()


func trigger_debug(_player: PlayerController) -> void:
	activate()


func _on_setup() -> void:
	super._on_setup()
	_mesh_scale = _mesh.scale
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.roughness = 0.2
	_material.metallic_specular = 0.9
	_mesh.material_override = _material
	_ring_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_ring.material_override = _ring_material


func _physics_process(delta: float) -> void:
	if config:
		_timer -= delta
		if _timer <= 0.0:
			match bubble_state:
				BubbleState.ACTIVATED:
					_enter(BubbleState.WARNING)
				BubbleState.WARNING:
					_enter(BubbleState.DISABLED)
				BubbleState.DISABLED:
					if _can_respawn():
						_enter(BubbleState.RESPAWNING)
				BubbleState.RESPAWNING:
					_enter(BubbleState.READY)
				BubbleState.READY:
					_enter(BubbleState.IDLE)
		_update_visual()
	super._physics_process(delta)


func _can_respawn() -> bool:
	return config.auto_respawn and (config.max_uses <= 0 or uses < config.max_uses)


func _enter(new_state: BubbleState) -> void:
	bubble_state = new_state
	_timer = 0.0
	match new_state:
		BubbleState.IDLE:
			_solid = true
		BubbleState.ACTIVATED:
			_timer = config.activation_time if config else 0.0
		BubbleState.WARNING:
			_timer = config.disappear_delay if config else 0.0
		BubbleState.DISABLED:
			_solid = false
			_timer = config.respawn_time if config else 0.0
			play_sound(Sound.BREAK)
		BubbleState.RESPAWNING:
			_solid = false
			_timer = config.respawn_animation_time if config else 0.0
		BubbleState.READY:
			_solid = true
			_timer = ready_flash_time


## Cor por estado, pisca no aviso, anel encolhendo = tempo restante, cresce ao reaparecer.
func _update_visual() -> void:
	if _mesh == null:
		return
	var color := idle_color
	var mesh_factor := 1.0
	match bubble_state:
		BubbleState.ACTIVATED:
			color = activated_color
		BubbleState.WARNING:
			var blink := blink_value()
			color = warning_color
			color.a *= lerpf(0.25, 1.0, blink)
		BubbleState.DISABLED:
			mesh_factor = 0.0
		BubbleState.RESPAWNING:
			var duration := maxf(config.respawn_animation_time, 0.001) if config else 1.0
			mesh_factor = clampf(1.0 - _timer / duration, 0.0, 1.0)
			color = ready_color
		BubbleState.READY:
			color = ready_color
	_material.albedo_color = color
	_mesh.visible = mesh_factor > 0.0
	_mesh.scale = _mesh_scale * maxf(mesh_factor, 0.001)
	var counting := bubble_state in [BubbleState.ACTIVATED, BubbleState.WARNING]
	_ring.visible = counting
	if counting:
		var fraction := get_remaining_fraction()
		_ring.scale = Vector3(data.depth, 1.0, data.width) * lerpf(0.15, 0.6, fraction)
		_ring.position = Vector3(0.0, 0.08, 0.0)
		_ring_material.albedo_color = warning_color.lerp(activated_color, fraction)


func blink_value() -> float:
	var speed := config.blink_speed if config else 10.0
	return 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.001 * speed * TAU * 0.5)


func _draw_debug(draw: ObjectDebugDraw) -> void:
	var radius := data.width * 0.5 * get_remaining_fraction()
	draw.surface_circle(current_angle, current_height + 0.3, current_radius + data.depth * 0.5, maxf(radius, 0.05), Color.RED if not _solid else Color.GREEN)
