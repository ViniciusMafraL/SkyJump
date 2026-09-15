class_name PortalConfig
extends Resource
## Parâmetros dos PORTAIS.

enum VelocityMode { KEEP_VELOCITY, RESET_VELOCITY, REDIRECT_VELOCITY }

@export_group("Gameplay")
## Distância do centro do portal que ativa o teleporte.
@export var trigger_radius: float = 0.9
@export var velocity_mode: VelocityMode = VelocityMode.REDIRECT_VELOCITY
## Limites da velocidade no modo REDIRECT_VELOCITY.
@export var redirect_min_speed: float = 10.0
@export var redirect_max_speed: float = 24.0
## Duração (s) do estado TELEPORTING antes de surgir no destino.
@export var teleport_delay: float = 0.12

@export_group("Protection")
## Tempo (s) sem poder usar nenhum portal após um teleporte.
@export var cooldown: float = 0.5
## Os dois portais usados só rearmam depois que o personagem sai do raio E pousa em algo.
## Evita o ping-pong infinito de cair de volta no portal de saída.
@export var rearm_requires_landing: bool = true

@export_group("Visual")
@export var portal_size: float = 1.1
