class_name JumpMetrics
extends Node
## Mede cada salto real (pico, tempo no ar, distância) para comparar com os valores teóricos.

@export var player: PlayerController

var last_takeoff_kind: String = "-"
## Altura máxima acima do ponto de partida.
var last_peak_height: float = 0.0
var last_air_time: float = 0.0
## Distância percorrida ao longo da circunferência.
var last_distance: float = 0.0
var last_height_change: float = 0.0
## Voltas ao redor do cilindro desde o último reset (com sinal).
var turns: float = 0.0

var _airborne: bool = false
var _kind: String = ""
var _takeoff_height: float = 0.0
var _peak: float = 0.0
var _air_time: float = 0.0
var _distance: float = 0.0
var _previous_angle: float = 0.0


func _ready() -> void:
	player.jumped.connect(_begin_air.bind("Pulo"))
	player.launched.connect(func(_speed: float) -> void: _begin_air("Trampolim"))
	player.left_ground.connect(_begin_air.bind("Queda"))
	player.landed.connect(_on_landed)


func reset() -> void:
	_airborne = false
	last_takeoff_kind = "-"
	last_peak_height = 0.0
	last_air_time = 0.0
	last_distance = 0.0
	last_height_change = 0.0
	turns = 0.0
	_previous_angle = player.angle


func _physics_process(delta: float) -> void:
	var step := angle_difference(_previous_angle, player.angle)
	_previous_angle = player.angle
	turns += step / TAU
	if not _airborne:
		return
	_air_time += delta
	_distance += absf(step) * player.orbit_radius
	_peak = maxf(_peak, player.height)


func _begin_air(kind: String) -> void:
	_airborne = true
	_kind = kind
	_takeoff_height = player.height
	_peak = player.height
	_air_time = 0.0
	_distance = 0.0


func _on_landed(_platform: Platform) -> void:
	if not _airborne:
		return
	_airborne = false
	last_takeoff_kind = _kind
	last_peak_height = _peak - _takeoff_height
	last_air_time = _air_time
	last_distance = _distance
	last_height_change = player.height - _takeoff_height
