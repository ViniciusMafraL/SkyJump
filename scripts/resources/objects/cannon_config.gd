class_name CannonConfig
extends Resource
## Parâmetros do CANHÃO MÓVEL. Ângulos em graus a partir da vertical do canhão:
## negativo = esquerda do objeto, positivo = direita.

@export_group("Aim")
@export_range(-90.0, 90.0, 1.0) var min_angle: float = -60.0
@export_range(-90.0, 90.0, 1.0) var max_angle: float = 60.0
## Velocidade da seta (graus/s), oscilando entre os limites.
@export var aim_speed: float = 90.0

@export_group("Launch")
@export var launch_force: float = 26.0
## Dispara sozinho após este tempo (s) mirando. 0 = nunca (espera a confirmação).
@export var max_aim_time: float = 4.0
## Ignora confirmações logo após entrar (evita disparo acidental).
@export var confirm_delay: float = 0.15

@export_group("Gameplay")
## Distância da boca do canhão que captura o personagem.
@export var capture_radius: float = 1.0
## Tempo (s) antes de aceitar o personagem de novo.
@export var entry_cooldown: float = 0.8
## Após disparar, só aceita o personagem de novo depois que ele sair do raio e pousar.
## Evita loop infinito de tiro para cima + auto-disparo.
@export var rearm_requires_landing: bool = true
