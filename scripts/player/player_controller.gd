class_name PlayerController
extends Node3D
## Movimento angular ao redor do cilindro, pulo e gravidade arcade.
## Recebe apenas PlayerInputState (comandos abstratos): não sabe se o jogador usa toque,
## giroscópio, botões ou teclado. Também não sabe nada sobre geração procedural.
## Objetos especiais interagem por launch() (impulsos que seguem a gravidade existente) e por
## capture()/release() (tubo, canhão, portal assumem a posição temporariamente).

signal spawned
signal jumped
## Lançamento externo (trampolins, TNT, canhão...). A origem fica em `last_launch_source`.
signal launched(vertical_speed: float)
signal landed(platform: Platform)
signal left_ground
signal state_changed(new_state: State)
signal mode_changed(new_mode: Mode)
## Reposicionamento instantâneo (portais): a câmera deve acompanhar sem suavização.
signal teleported

enum State { GROUNDED, RISING, FALLING, DISABLED }
## Situação especial em relação aos objetos, independente do estado físico.
enum Mode { NORMAL, LAUNCHED, IN_TUBE, IN_CANNON, TELEPORTING, ON_MOVING_PLATFORM, ON_WALL }

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
## Impulso lateral recebido de objetos; decai com movement.launch_momentum_drag.
var launch_tangential_speed: float = 0.0
var state: State = State.DISABLED
var mode: Mode = Mode.NORMAL
var current_platform: Platform
## Velocidade de queda no instante da última aterrissagem (positiva).
var last_impact_speed: float = 0.0
var last_launch_source: StringName = &""

var _controls_enabled: bool = false
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_cooldown_timer: float = 0.0
var _platform_last_angle: float = 0.0
var _facing: float = 1.0
var _move_axis: float = 0.0
var _confirm_pressed: bool = false
var _capture_owner: Object
var _teleport_locked_until_msec: int = 0

@onready var _ground_detector: GroundDetector = $GroundDetector
@onready var _interaction_detector: InteractionDetector = $InteractionDetector
@onready var _visual: PlayerVisual = $Visual


func spawn(spawn_angle: float, spawn_height: float, radius: float) -> void:
	angle = wrapf(spawn_angle, 0.0, TAU)
	height = spawn_height
	orbit_radius = radius
	vertical_velocity = 0.0
	tangential_speed = 0.0
	launch_tangential_speed = 0.0
	current_platform = null
	_capture_owner = null
	_teleport_locked_until_msec = 0
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_jump_cooldown_timer = 0.0
	_controls_enabled = true
	_visual.reset_visual()
	_set_mode(Mode.NORMAL)
	# Nasce em queda: aterrissa no primeiro frame sobre a plataforma abaixo.
	_set_state(State.FALLING)
	_apply_transform()
	reset_physics_interpolation()
	spawned.emit()


func set_platform_source(source: PlatformSource) -> void:
	_ground_detector.platform_source = source
	_interaction_detector.platform_source = source


## Lança o personagem sem consumir o pulo do jogador; a gravidade existente continua valendo.
## `tangential_boost` segue a convenção de tangential_speed (positivo = direita da tela) e vira
## momentum que decai aos poucos, para lançamentos diagonais não serem anulados pelo controle aéreo.
func launch(vertical_speed: float, tangential_boost: float = 0.0, source: StringName = &"trampoline") -> void:
	_detach_from_platform()
	vertical_velocity = clampf(vertical_speed, -movement.fall_speed_limit, movement.max_launch_vertical_speed)
	launch_tangential_speed = clampf(tangential_boost, -movement.max_launch_tangential_speed, movement.max_launch_tangential_speed)
	_coyote_timer = 0.0
	last_launch_source = source
	_set_state(State.RISING if vertical_velocity > 0.0 else State.FALLING)
	_set_mode(Mode.LAUNCHED)
	launched.emit(vertical_velocity)


## Um objeto assume o controle da posição (tubo, canhão, portal). Falha se outro já o fez.
func capture(owner: Object, capture_mode: Mode) -> bool:
	if is_captured() or state == State.DISABLED or not _controls_enabled:
		return false
	_detach_from_platform()
	_capture_owner = owner
	vertical_velocity = 0.0
	tangential_speed = 0.0
	launch_tangential_speed = 0.0
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0
	if state == State.GROUNDED:
		_set_state(State.FALLING)
	_set_mode(capture_mode)
	return true


## Devolve o controle aplicando a velocidade de saída.
func release(vertical_speed: float, tangential_boost: float, source: StringName) -> void:
	_capture_owner = null
	tangential_speed = 0.0
	launch(vertical_speed, tangential_boost, source)


func is_captured() -> bool:
	return _capture_owner != null


func get_capture_owner() -> Object:
	return _capture_owner


## Usado pelo objeto que capturou o personagem para conduzi-lo.
func set_cylindrical_position(new_angle: float, new_height: float) -> void:
	angle = wrapf(new_angle, 0.0, TAU)
	height = new_height
	_apply_transform()


func teleport_to(new_angle: float, new_height: float) -> void:
	set_cylindrical_position(new_angle, new_height)
	reset_physics_interpolation()
	teleported.emit()


## Bloqueio global de teleporte (proteção contra ping-pong entre portais).
func lock_teleport(seconds: float) -> void:
	_teleport_locked_until_msec = maxi(_teleport_locked_until_msec, Time.get_ticks_msec() + roundi(seconds * 1000.0))


func can_teleport() -> bool:
	return Time.get_ticks_msec() >= _teleport_locked_until_msec and not is_captured()


## Modo definido por objetos que não capturam (ex.: ON_WALL).
func set_mode(new_mode: Mode) -> void:
	_set_mode(new_mode)


## 1 = virado para a direita da tela, -1 = esquerda.
func get_facing() -> float:
	return _facing


## Eixo de movimento do frame atual (-1..1).
func get_move_axis() -> float:
	return _move_axis


## Pulo ou toque na tela neste frame (confirmação de objetos como o canhão).
func is_confirm_pressed() -> bool:
	return _confirm_pressed


func is_jump_buffered() -> bool:
	return _jump_buffer_timer > 0.0


func consume_jump_buffer() -> void:
	_jump_buffer_timer = 0.0


func set_controls_enabled(enabled: bool) -> void:
	_controls_enabled = enabled


func are_controls_enabled() -> bool:
	return _controls_enabled


func disable() -> void:
	_controls_enabled = false
	_capture_owner = null
	_set_state(State.DISABLED)


func play_defeat_effect() -> void:
	_visual.play_defeat()


func is_grounded() -> bool:
	return state == State.GROUNDED


func _physics_process(delta: float) -> void:
	if state == State.DISABLED:
		return
	var input := _read_input()
	_move_axis = input.move_axis if input else 0.0
	_confirm_pressed = input != null and input.confirm_pressed
	if _capture_owner != null and not is_instance_valid(_capture_owner):
		# O objeto foi removido (ex.: sala reconstruída): solta o personagem em queda.
		_capture_owner = null
		_set_mode(Mode.NORMAL)
	if is_captured():
		_interaction_detector.process_objects(self, delta)
		_apply_transform()
		return
	_tick_timers(delta, input)
	_update_horizontal(delta, input)
	if state == State.GROUNDED:
		_update_grounded()
	if _can_jump():
		_jump()
	if state != State.GROUNDED:
		_update_airborne(delta)
	_interaction_detector.process_objects(self, delta)
	_update_mode()
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
	var speed_scale := 1.0
	if state != State.GROUNDED:
		acceleration *= movement.air_control
	elif current_platform and is_instance_valid(current_platform):
		speed_scale = current_platform.get_input_speed_scale()
	tangential_speed = move_toward(tangential_speed, axis * movement.horizontal_speed * speed_scale, acceleration * delta)
	launch_tangential_speed = move_toward(launch_tangential_speed, 0.0, movement.launch_momentum_drag * delta)
	var total_speed := tangential_speed + launch_tangential_speed
	var new_angle := wrapf(angle - total_speed / orbit_radius * delta, 0.0, TAU)
	angle = _interaction_detector.constrain_angle(self, angle, new_angle)
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
	launch_tangential_speed = 0.0
	_coyote_timer = 0.0
	_set_state(State.GROUNDED)
	_update_mode()
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


## Modos derivados do estado físico. Modos de captura e ON_WALL são controlados pelos objetos.
func _update_mode() -> void:
	if mode in [Mode.IN_TUBE, Mode.IN_CANNON, Mode.TELEPORTING, Mode.ON_WALL]:
		return
	if state == State.GROUNDED:
		var moving := current_platform != null and is_instance_valid(current_platform) and current_platform.is_moving()
		_set_mode(Mode.ON_MOVING_PLATFORM if moving else Mode.NORMAL)
	elif mode == Mode.ON_MOVING_PLATFORM:
		_set_mode(Mode.NORMAL)


func _set_state(new_state: State) -> void:
	if state == new_state:
		return
	state = new_state
	state_changed.emit(new_state)


func _set_mode(new_mode: Mode) -> void:
	if mode == new_mode:
		return
	mode = new_mode
	mode_changed.emit(new_mode)


func _apply_transform() -> void:
	position = Vector3(cos(angle) * orbit_radius, height, sin(angle) * orbit_radius)
	rotation = Vector3(0.0, -angle, 0.0)
