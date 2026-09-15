class_name SlidingPlatformConfig
extends Resource
## Parâmetros da PLATAFORMA DESLIZANTE (reage à direção de movimento do personagem).

@export_group("Movement")
## Velocidade de deslize (unidades/s) enquanto o personagem empurra.
@export var movement_speed: float = 5.5
## Distância máxima a partir da posição inicial, para cada lado.
@export var maximum_distance: float = 4.0
## Velocidade de retorno à posição inicial.
@export var return_speed: float = 2.5

@export_group("Gameplay")
## Intensidade mínima do input (0..1) para ativar.
@export_range(0.0, 1.0, 0.05) var activation_threshold: float = 0.3
@export var return_to_start: bool = true
## Tempo (s) sem ativação antes de retornar.
@export var cooldown: float = 0.6
