class_name GyroscopeControl
extends ControlScheme
## Método 2: inclinar o celular para a direita/esquerda move o personagem. Pulo automático.
## Usa o vetor de gravidade do sistema, que o Android/iOS calculam fundindo giroscópio e
## acelerômetro: dá a inclinação absoluta sem o desvio acumulado da velocidade angular crua.
## Sem sensor de gravidade usa o acelerômetro; sem nenhum sensor (PC), A/D simulam a inclinação.

enum SensorSource { NONE, GRAVITY, ACCELEROMETER }

## Inclinação bruta (graus) lida no último frame.
var raw_tilt: float = 0.0
## Valor final após calibração, sensibilidade, zona morta e suavização (-1..1).
var processed_value: float = 0.0

var _simulated_tilt: float = 0.0
var _pending_auto_calibration: bool = false


func activate() -> void:
	super.activate()
	_pending_auto_calibration = _config().auto_calibrate_on_activate
	manager.controls_ui.set_gyro_indicator_visible(_config().show_indicator)


func deactivate() -> void:
	super.deactivate()
	manager.controls_ui.set_gyro_indicator_visible(false)


func clear_state() -> void:
	processed_value = 0.0
	_simulated_tilt = 0.0


func collect(state: PlayerInputState, delta: float) -> void:
	var config := _config()
	raw_tilt = read_raw_tilt(delta)
	if _pending_auto_calibration and get_sensor_source() != SensorSource.NONE:
		_pending_auto_calibration = false
		config.neutral_orientation = raw_tilt
	var target := GyroscopeControl.process_tilt(raw_tilt, config)
	if config.gyro_smoothing > 0.0:
		processed_value = lerpf(processed_value, target, 1.0 - exp(-config.gyro_smoothing * delta))
	else:
		processed_value = target
	if is_zero_approx(target) and absf(processed_value) < 0.01:
		processed_value = 0.0
	state.move_axis = processed_value
	manager.controls_ui.set_gyro_indicator_value(processed_value)


## Calibração -> Sensibilidade -> Zona morta. Retorna -1..1.
static func process_tilt(raw_degrees: float, config: GyroscopeConfig) -> float:
	var normalized := (raw_degrees - config.neutral_orientation) / config.max_tilt_degrees * config.gyro_sensitivity
	if config.invert:
		normalized = -normalized
	var magnitude := absf(normalized)
	if magnitude <= config.gyro_dead_zone:
		return 0.0
	# Reescala para o movimento começar do zero logo após a zona morta.
	return signf(normalized) * minf((magnitude - config.gyro_dead_zone) / (1.0 - config.gyro_dead_zone), 1.0)


## Inclinação lateral (graus): positivo = lado direito da tela para baixo.
## A Godot já entrega os sensores alinhados à orientação da tela, então basta o eixo X.
## Funciona com o celular em pé ou inclinado para trás, pois usa só o componente lateral.
static func tilt_from_gravity(gravity: Vector3) -> float:
	var length := gravity.length()
	if is_zero_approx(length):
		return 0.0
	return rad_to_deg(asin(clampf(gravity.x / length, -1.0, 1.0)))


## Qual sensor do aparelho está fornecendo a inclinação.
func get_sensor_source() -> SensorSource:
	if not Input.get_gravity().is_zero_approx():
		return SensorSource.GRAVITY
	if not Input.get_accelerometer().is_zero_approx():
		return SensorSource.ACCELEROMETER
	return SensorSource.NONE


func has_sensor() -> bool:
	return get_sensor_source() != SensorSource.NONE


func has_gyroscope() -> bool:
	return not Input.get_gyroscope().is_zero_approx()


func is_simulating() -> bool:
	return not has_sensor() and _config().simulate_on_desktop


func read_raw_tilt(delta: float) -> float:
	match get_sensor_source():
		SensorSource.GRAVITY:
			return tilt_from_gravity(Input.get_gravity())
		SensorSource.ACCELEROMETER:
			return tilt_from_gravity(Input.get_accelerometer())
	var config := _config()
	if not config.simulate_on_desktop:
		return config.neutral_orientation
	var key_axis := 0.0
	if manager.config.keyboard_fallback_enabled:
		key_axis = Input.get_axis(manager.move_left_action, manager.move_right_action)
	# Inclinação "física" simulada: absoluta, como a de um aparelho real (independe da calibração).
	_simulated_tilt = move_toward(_simulated_tilt, key_axis * config.max_tilt_degrees, config.simulated_tilt_speed * delta)
	return _simulated_tilt


## Registra a inclinação atual como posição neutra. Retorna false se não houver sensor real.
func calibrate() -> bool:
	_pending_auto_calibration = false
	_config().neutral_orientation = read_raw_tilt(0.0)
	processed_value = 0.0
	return has_sensor()


func get_sensor_description() -> String:
	match get_sensor_source():
		SensorSource.GRAVITY:
			return "Gravidade (giroscópio + acelerômetro)" if has_gyroscope() else "Gravidade"
		SensorSource.ACCELEROMETER:
			return "Acelerômetro"
	return "Nenhum sensor: simulação por teclado (A/D)"


func merges_keyboard_movement() -> bool:
	# Na simulação, A/D já representam a inclinação.
	return not is_simulating()


func get_debug_lines() -> PackedStringArray:
	return PackedStringArray([
		"SENSOR: %s" % get_sensor_description(),
		"GYROSCOPE: %s" % ("DETECTED" if has_gyroscope() else "NOT DETECTED"),
		"GYRO RAW: %.1f°  NEUTRO: %.1f°" % [raw_tilt, _config().neutral_orientation],
		"GYRO VALUE: %.2f" % processed_value,
	])


func _config() -> GyroscopeConfig:
	return manager.config.gyroscope_config
