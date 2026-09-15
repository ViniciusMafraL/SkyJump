class_name TntPlatform
extends Platform
## PLATAFORMA TNT: ao ser tocada acende o pavio; após `fuse_time` explode e lança o personagem
## que estiver no raio (para cima e para longe do centro), usando a gravidade existente.
## READY -> FUSE -> (COOLDOWN | DESTROYED -> RESPAWNING) -> READY

enum TntState { READY, FUSE, COOLDOWN, DESTROYED, RESPAWNING }

@export var config: TNTConfig

@export_group("Visual")
@export var body_color: Color = Color(0.85, 0.18, 0.15)
@export var flash_color: Color = Color(1.0, 0.95, 0.6)
@export var cooldown_color: Color = Color(0.35, 0.12, 0.1)
@export var respawn_animation_time: float = 0.35
@export var blast_duration: float = 0.35

var tnt_state: TntState = TntState.READY
var explosions: int = 0

var _timer: float = 0.0
var _player: PlayerController
var _mesh_scale: Vector3 = Vector3.ONE
var _material := StandardMaterial3D.new()
var _blast_material := StandardMaterial3D.new()
var _blast_time: float = -1.0

@onready var _mesh: MeshInstance3D = $Visual/Mesh
@onready var _label: Label3D = $Visual/Countdown
@onready var _fuse: CPUParticles3D = $Visual/Fuse
@onready var _light: OmniLight3D = $Visual/Light
@onready var _blast: MeshInstance3D = $Visual/Blast
@onready var _burst: CPUParticles3D = $Visual/Burst


func get_settings_section() -> StringName:
	return &"tnt"


func reset() -> void:
	explosions = 0
	_blast_time = -1.0
	_enter(TntState.READY)
	_update_visual()


func get_state_name() -> String:
	return "%s %.2fs explosões %d" % [TntState.keys()[tnt_state], maxf(_timer, 0.0), explosions]


func on_player_landed(player: PlayerController) -> void:
	_player = player
	ignite()


func ignite() -> void:
	if tnt_state != TntState.READY:
		return
	_enter(TntState.FUSE)
	play_sound(Sound.ACTIVATION)


## Primeira chamada acende; a segunda explode imediatamente.
func trigger_debug(player: PlayerController) -> void:
	_player = player
	if tnt_state == TntState.READY:
		ignite()
	elif tnt_state == TntState.FUSE:
		_explode()


func _physics_process(delta: float) -> void:
	if config:
		_timer -= delta
		match tnt_state:
			TntState.FUSE:
				if _timer <= 0.0:
					_explode()
			TntState.COOLDOWN:
				if _timer <= 0.0:
					_enter(TntState.READY)
			TntState.DESTROYED:
				if config.respawn and _timer <= 0.0:
					_enter(TntState.RESPAWNING)
			TntState.RESPAWNING:
				if _timer <= 0.0:
					_enter(TntState.READY)
		_update_visual()
		_update_blast(delta)
	super._physics_process(delta)


func _explode() -> void:
	explosions += 1
	play_sound(Sound.EXPLOSION)
	_blast_time = 0.0
	_burst.restart()
	if _player and is_instance_valid(_player) and not _player.is_captured():
		var relative := CylinderSpace.player_offset(current_angle, current_height, _player)
		var distance := relative.length()
		if distance <= config.explosion_radius:
			var strength := config.explosion_force * (1.0 - config.falloff * distance / maxf(config.explosion_radius, 0.001))
			var side := signf(relative.x) if absf(relative.x) > 0.15 else _player.get_facing()
			_player.launch(config.vertical_force * strength, config.horizontal_force * strength * side, &"tnt")
	_enter(TntState.DESTROYED if config.destroy_after_use else TntState.COOLDOWN)


func _enter(new_state: TntState) -> void:
	tnt_state = new_state
	_timer = 0.0
	match new_state:
		TntState.READY:
			_solid = true
		TntState.FUSE:
			_timer = config.fuse_time if config else 2.0
		TntState.COOLDOWN:
			_solid = true
			_timer = config.cooldown if config else 1.0
		TntState.DESTROYED:
			_solid = false
			_timer = config.respawn_time if config else 3.0
			play_sound(Sound.BREAK)
		TntState.RESPAWNING:
			_solid = false
			_timer = respawn_animation_time


func _on_setup() -> void:
	super._on_setup()
	_mesh_scale = _mesh.scale
	_mesh.material_override = _material
	_material.emission_enabled = true
	_label.position = Vector3(data.depth * 0.5 + 0.1, 0.9, 0.0)
	_fuse.position = Vector3(0.0, 0.15, 0.0)
	_light.position = Vector3(data.depth * 0.5, 0.6, 0.0)
	_blast_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_blast_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_blast.material_override = _blast_material
	_blast.visible = false


## Pisca cada vez mais rápido durante a contagem, com número, faíscas e luz.
func _update_visual() -> void:
	if _mesh == null:
		return
	var fusing := tnt_state == TntState.FUSE
	var color := body_color
	var flash := 0.0
	if fusing:
		var fuse_time := maxf(config.fuse_time, 0.001)
		var progress := clampf(1.0 - _timer / fuse_time, 0.0, 1.0)
		var frequency := lerpf(2.0, 14.0, progress)
		flash = 1.0 if sin((fuse_time - _timer) * TAU * frequency) > 0.0 else 0.0
		color = body_color.lerp(flash_color, flash * 0.8)
		_label.text = "%.1f" % maxf(_timer, 0.0)
	elif tnt_state == TntState.COOLDOWN:
		color = cooldown_color
	_material.albedo_color = color
	_material.emission = color * (0.2 + flash * 0.8)
	_label.visible = fusing
	_fuse.emitting = fusing
	_light.light_energy = (1.0 + flash * 3.0) if fusing else 0.0
	var mesh_factor := 1.0
	match tnt_state:
		TntState.DESTROYED:
			mesh_factor = 0.0
		TntState.RESPAWNING:
			mesh_factor = clampf(1.0 - _timer / maxf(respawn_animation_time, 0.001), 0.0, 1.0)
	_mesh.visible = mesh_factor > 0.0
	_mesh.scale = _mesh_scale * maxf(mesh_factor, 0.001)


func _update_blast(delta: float) -> void:
	if _blast_time < 0.0:
		_blast.visible = false
		return
	_blast_time += delta
	var t := _blast_time / maxf(blast_duration, 0.001)
	if t >= 1.0:
		_blast_time = -1.0
		_blast.visible = false
		return
	_blast.visible = true
	# O nó Visual pode estar achatado pelo quique: a esfera usa o raio real da explosão.
	_blast.scale = Vector3.ONE * lerpf(0.3, config.explosion_radius * 2.0, t)
	_blast_material.albedo_color = Color(flash_color, 0.6 * (1.0 - t))


func _draw_debug(draw: ObjectDebugDraw) -> void:
	if config == null:
		return
	draw.surface_circle(current_angle, current_height, current_radius + data.depth * 0.5, config.explosion_radius, Color.ORANGE_RED, 32)
	var launch := Vector2(config.horizontal_force, config.vertical_force) * config.explosion_force
	var gravity := GameplayObject.debug_movement.gravity if GameplayObject.debug_movement else 32.0
	for side in [1.0, -1.0]:
		var side_launch := Vector2(launch.x * side, launch.y)
		draw.launch_arc(current_angle, current_height, current_radius + data.depth * 0.5, side_launch, GameplayObject.debug_movement, Color.YELLOW, 2.0 * launch.y / gravity)
