class_name TNTConfig
extends Resource
## Parâmetros da PLATAFORMA TNT.

@export_group("Timing")
## Tempo (s) entre a ativação e a explosão.
@export var fuse_time: float = 2.0
## Tempo (s) até poder ser ativada de novo (quando não é destruída).
@export var cooldown: float = 1.0

@export_group("Explosion")
## Multiplicador geral das forças.
@export var explosion_force: float = 1.0
@export var vertical_force: float = 24.0
## Velocidade lateral, para longe do centro da TNT.
@export var horizontal_force: float = 8.0
@export var explosion_radius: float = 3.0
## Perda de força na borda do raio (0 = força total em todo o raio, 1 = zero na borda).
@export_range(0.0, 1.0, 0.05) var falloff: float = 0.35

@export_group("Lifecycle")
@export var destroy_after_use: bool = true
@export var respawn: bool = true
@export var respawn_time: float = 3.0
