class_name CameraConfig
extends Resource
## Parâmetros da câmera orbital externa.

@export_group("Orbit")
## Distância da câmera até o eixo central do cilindro.
@export var camera_distance: float = 24.0
## Altura da câmera acima dos pés do personagem.
@export var camera_height: float = 5.0
## Deslocamento angular fixo (graus) em relação ao personagem.
@export_range(-180.0, 180.0) var camera_angle: float = 0.0
## Altura do ponto observado acima dos pés do personagem.
@export var camera_vertical_offset: float = 3.0
## Distância mínima entre a câmera e a trajetória do personagem (evita atravessar pilar/plataformas).
@export var min_clearance: float = 5.0

@export_group("Lens")
@export_range(20.0, 120.0) var camera_fov: float = 50.0
## Se verdadeiro, o FOV é horizontal (recomendado para retrato: o pilar sempre cabe na largura).
@export var fov_is_horizontal: bool = true
@export var far_distance: float = 300.0

@export_group("Smoothing")
## Suavização do acompanhamento vertical (maior = mais rápido).
@export var camera_smoothing: float = 5.0
## Suavização da rotação orbital (maior = mais rápido).
@export var rotation_smoothing: float = 8.0

@export_group("Manual Rotation")
## Velocidade de rotação por teclas, em graus por segundo.
@export var camera_rotation_speed: float = 120.0
## Graus girados ao arrastar o dedo pela largura inteira da tela.
@export var drag_degrees_per_screen: float = 240.0
## Segundos sem rotação manual antes de voltar para trás do personagem. 0 desativa.
@export var auto_recenter_delay: float = 2.5
@export var recenter_speed: float = 2.0

@export_group("Look Ahead")
## Quanto a velocidade de subida desloca a câmera para cima.
@export var vertical_lookahead_factor: float = 0.15
@export var max_vertical_lookahead: float = 2.5
