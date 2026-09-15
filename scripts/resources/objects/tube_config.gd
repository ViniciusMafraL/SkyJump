class_name TubeConfig
extends Resource
## Parâmetros do TUBO TRANSPORTADOR.
## Pontos da curva: x = direita do objeto, y = altura (z é ignorado). A curva é "enrolada" no cilindro.

@export_group("Trajectory")
## Trajetória do tubo. Vazio = usa a curva do nó Path3D da cena.
@export var path_curve: Curve3D
## Velocidade de transporte (unidades/s).
@export var speed: float = 12.0

@export_group("Exit")
## Velocidade de saída quando não preserva a velocidade do tubo.
@export var exit_force: float = 12.0
## Direção de saída (graus: 0 = direita do objeto, 90 = cima).
@export_range(-180.0, 180.0, 1.0) var exit_direction_degrees: float = 80.0
## Sai na direção final da curva com a velocidade do transporte.
@export var preserve_velocity: bool = false

@export_group("Gameplay")
## Distância da entrada que captura o personagem.
@export var capture_radius: float = 0.9
## Tempo (s) antes de o tubo aceitar o personagem de novo.
@export var entry_cooldown: float = 0.6

@export_group("Visual")
@export var tube_radius: float = 0.5
