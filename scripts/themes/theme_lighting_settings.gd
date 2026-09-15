@tool
class_name ThemeLightingSettings
extends Resource
## Iluminação própria de um tema. Estrutura base: sol, ambiente e neblina.
## Luzes específicas de um bioma (ex.: brilho de lava) entram depois como filhos do nó
## Lighting da Theme Scene, sem mudar esta estrutura.

@export_group("Sun")
@export var sun_color: Color = Color.WHITE
@export_range(0.0, 8.0, 0.05) var sun_energy: float = 1.0
## Desligado = mantém a direção do sol da cena de gameplay.
@export var override_sun_direction: bool = false
@export var sun_rotation_degrees: Vector3 = Vector3(-40.0, 30.0, 0.0)

@export_group("Ambient")
## Ambiente tingido pelas cores do fundo (céu com BASE_COLOR/TOP_COLOR).
@export var ambient_from_background: bool = true
## Usada quando ambient_from_background está desligado.
@export var ambient_color: Color = Color(0.6, 0.6, 0.6)
@export_range(0.0, 4.0, 0.05) var ambient_energy: float = 0.8

@export_group("Fog")
@export var fog_enabled: bool = true
@export_range(0.0, 0.1, 0.0005) var fog_density: float = 0.006
## Neblina com a BASE_COLOR do fundo.
@export var fog_color_from_background: bool = true
@export var fog_color: Color = Color.WHITE
