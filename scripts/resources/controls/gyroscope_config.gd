class_name GyroscopeConfig
extends Resource
## Controle por inclinação do aparelho.
## Processamento: Calibração -> Sensibilidade -> Zona morta -> Suavização -> move_axis.

@export_range(0.1, 5.0) var gyro_sensitivity: float = 1.0
## Fração da inclinação máxima ignorada, para evitar movimentos involuntários.
@export_range(0.0, 0.9) var gyro_dead_zone: float = 0.1
## Velocidade da suavização (maior = responde mais rápido). 0 = sem suavização.
@export var gyro_smoothing: float = 12.0
## Inclinação (graus) a partir da posição neutra que produz o movimento máximo.
@export_range(5.0, 80.0) var max_tilt_degrees: float = 25.0
@export var invert: bool = false
## Inclinação (graus) registrada pela calibração como posição neutra.
@export var neutral_orientation: float = 0.0
## Ao ativar o método, usa a posição atual do aparelho como neutra (o jogador pode recalibrar).
@export var auto_calibrate_on_activate: bool = true
@export var show_indicator: bool = true

@export_group("Desktop Simulation")
## Sem sensor (PC), A/D simulam a inclinação do aparelho.
@export var simulate_on_desktop: bool = true
## Velocidade (graus/s) da inclinação simulada.
@export var simulated_tilt_speed: float = 90.0
