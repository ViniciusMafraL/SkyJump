class_name BubblePlatformConfig
extends Resource
## Parâmetros da PLATAFORMA BOLHA / TEMPORÁRIA.

@export_group("Timing")
## Tempo (s) entre o toque e o início do aviso.
@export var activation_time: float = 0.4
## Duração (s) do aviso antes de desaparecer.
@export var disappear_delay: float = 0.8
## Tempo (s) desaparecida antes de reaparecer.
@export var respawn_time: float = 2.5
## Duração (s) da animação de reaparecimento.
@export var respawn_animation_time: float = 0.3

@export_group("Gameplay")
## Quantas vezes pode estourar. 0 = ilimitado.
@export var max_uses: int = 0
## Reaparece sozinha. Desligado = só volta com reset().
@export var auto_respawn: bool = true

@export_group("Visual")
@export var blink_speed: float = 12.0
