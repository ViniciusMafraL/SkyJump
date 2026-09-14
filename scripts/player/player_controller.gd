class_name PlayerController
extends Node3D
## Movimento angular ao redor do cilindro, pulo e gravidade arcade.
## Recebe apenas PlayerInputState (comandos abstratos): não sabe se o jogador usa toque,
## giroscópio, botões ou teclado. Também não sabe nada sobre geração procedural.

signal spawned
signal jumped
## Lançamento externo (trampolins, habilidades futuras).
signal launched(vertical_speed: float)
signal landed(platform: Platform)
signal left_ground
signal state_changed(new_state: State)

enum State { GROUNDED, RISING, FALLING, DISABLED }

@export var movement: PlayerMovementConfig
@export var input_controller: InputController

## Posição ao redor do cilindro, em radianos [0, TAU).
var angle: float = 0.0
## Altura dos pés, em unidades do mundo.
var height: float = 0.0
var orbit_radius: float = 1.0
var vertical_velocity: float = 0.0
## Velocidade ao longo da circunferência. Positivo = direita da tela (ângulo decrescente).
var tangential_speed: float = 0.0
var state: State = State.DISABLED
var current_platform: Platform
## Velocidade de queda no instante da última aterrissagem (positiva).
var last_impact_speed: float = 0.0

var _controls_enabled: bool = false
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_cooldown_timer: float = 0.0
var _platform_last_angle: float = 0.0
var _facing: float = 1.0

@onready var _ground_detector: GroundDetector = $GroundDetector
@onready var _visual: PlayerVisual = $Visual


func spawn(spawn_angle: float, spawn_height: float, radius: float) -> void:
	angle = wrapf(spawn_angle, 0.0, TAU)
	height = spawn_height
	orbit_radius = radius
	vertical_velocity = 0.0
	tangential_speed = 0.0
	current_platform = null
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_jump_cooldown_timer = 0.0
	_controls_enabled = true
	_visual.reset_visual()
	# Nasce em queda: aterrissa no primeiro frame sobre a plataforma abaixo.
	_set_state(State.FALLING)
	_apply_transform()
	reset_physics_interpolation()
	spawned.emit()


func set_platform_source(source: PlatformSource) -> void:
	_ground_detector.platform_source = source


## Lança o personagem para cima sem consumir o pulo do jogador.
## `tangential_boost` segue a convenção de tangential_speed (positivo = direita da tela).
func launch(vertical_speed: float, tangential_boost: float = 0.0) -> void:
	_detach_from_platform()
	vertical_velocity = vertical_speed
	tangential_speed += tangential_boost
	_coyote_timer = 0.0
	_set_state(State.RISING)
	launched.emit(vertical_speed)


## 1 = virado para a direita da tela, -1 = esquerda.
func get_facing() -> float:
	return _facing


func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled


func are_controls_enabled() -> bool:
	return _controls_enabled


func disable() -> void:
	_controls_enabled = false
	_set_state(State.DISABLED)


func play_defeat_effect() -> void:
	_visual.play_defeat()


func is_grounded() -> bool:
	return state == State.GROUNDED


func _physics_process(delta: float) -> void:
	if state == State.DISABLED:
		return
	var input := _read_input()
	_tick_timers(delta, input)
	_update_horizontal(delta, input)
	if state == State.GROUNDED:
		_update_grounded()
	if _can_jump():
		_jump()
	if state != State.GROUNDED:
		_update_airborne(delta)
	_apply_transform()


## Comandos do frame, ou null quando os controles estão desativados.
func _read_input() -> PlayerInputState:
	if not _controls_enabled or input_controller == null:
		return null
	return input_controller.get_player_input_state()


func _tick_timers(delta: float, input: PlayerInputState) -> void:
	_coyote_timer = maxf(_coyote_timer - delta, 0.0)
	_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)
	_jump_cooldown_timer = maxf(_jump_cooldown_timer - delta, 0.0)
	if input and input.jump_pressed:
		_jump_buffer_timer = maxf(movement.jump_buffer_time, delta)


func _update_horizontal(delta: float, input: PlayerInputState) -> void:
	var axis := input.move_axis if input else 0.0
	var acceleration := movement.ground_acceleration if not is_zero_approx(axis) else movement.ground_deceleration
	if state != State.GROUNDED:
		acceleration *= movement.air_control
	tangential_speed = move_toward(tangential_speed, axis * movement.horizontal_speed, acceleration * delta)
	angle = wrapf(angle - tangential_speed / orbit_radius * delta, 0.0, TAU)
	if not is_zero_approx(axis):
		_facing = signf(axis)
		_visual.set_facing(axis)


func _update_grounded() -> void:
	if current_platform == null or not is_instance_valid(current_platform) or not current_platform.is_solid():
		_leave_ground()
		return
	# Acompanha plataformas que se movem.
	angle = wrapf(angle + angle_difference(_platform_last_angle, current_platform.current_angle), 0.0, TAU)
	_platform_last_angle = current_platform.current_angle
	height = current_platform.get_top_height()
	if not _ground_detector.is_supported_by(current_platform, angle, orbit_radius, movement.foot_radius):
		_leave_ground()


func _update_airborne(delta: float) -> void:
	var previous_velocity := vertical_velocity
	vertical_velocity = maxf(vertical_velocity - movement.gravity * delta, -movement.fall_speed_limit)
	# Velocidade média do frame: a altura real do pulo bate com h = F² / 2g em qualquer taxa de física.
	var new_height := height + (previous_velocity + vertical_velocity) * 0.5 * delta
	if vertical_velocity <= 0.0:
		if state == State.RISING:
			_set_state(State.FALLING)
		var platform := _ground_detector.find_landing(height, new_height, angle, orbit_radius, movement.foot_radius)
		if platform:
			last_impact_speed = -vertical_velocity
			height = platform.get_top_height()
			_land_on(platform)
			return
	height = new_height


func _can_jump() -> bool:
	return _jump_buffer_timer > 0.0 and _jump_cooldown_timer <= 0.0 \
		and (state == State.GROUNDED or _coyote_timer > 0.0)


func _jump() -> void:
	_detach_from_platform()
	vertical_velocity = movement.jump_force
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	_jump_cooldown_timer = movement.jump_cooldown
	_set_state(State.RISING)
	jumped.emit()


func _land_on(platform: Platform) -> void:
	current_platform = platform
	_platform_last_angle = platform.current_angle
	vertical_velocity = 0.0
	_coyote_timer = 0.0
	_set_state(State.GROUNDED)
	# Emitido antes da reação da plataforma: um trampolim pode lançar o jogador em seguida.
	landed.emit(platform)
	platform.on_player_landed(self)


func _leave_ground() -> void:
	_detach_from_platform()
	vertical_velocity = 0.0
	_coyote_timer = movement.coyote_time
	_set_state(State.FALLING)
	left_ground.emit()


func _detach_from_platform() -> void:
	if current_platform and is_instance_valid(current_platform):
		current_platform.on_player_left(self)
	current_platform = null


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(new_state)


func _apply_transform() -> void:
	position = Vector3(cos(angle) * orbit_radius, height, sin(angle) * orbit_radius)
	rotation = Vector3(0.0, -angle, 0.0)
