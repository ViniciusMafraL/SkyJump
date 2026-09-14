class_name GameRulesConfig
extends Resource
## Regras gerais da partida.

@export_group("Death")
## Altura absoluta (unidades do mundo) abaixo da qual a tentativa termina.
@export var death_height_threshold: float = -8.0
## Queda máxima (unidades do mundo) abaixo da maior altura da tentativa. 0 = desativado.
@export var max_fall_distance: float = 30.0
## Duração do estado FALLING antes de mostrar o resultado.
@export var game_over_delay: float = 1.2

@export_group("Checkpoints")
## Quando ativo, "Tentar novamente" recomeça do último checkpoint alcançado.
@export var checkpoints_enabled: bool = false
## Distância (metros) entre checkpoints.
@export var checkpoint_interval: float = 100.0
