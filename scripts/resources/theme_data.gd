class_name ThemeData
extends Resource
## Tema visual de uma região da torre. Apenas apresentação: nenhum dado de gameplay.
## No protótipo contém somente cores placeholder; materiais, céu, música etc. entram aqui depois.

@export var display_name: String = "Inicial"
## Altura (metros) a partir da qual o tema é aplicado.
@export var start_height: float = 0.0

@export_group("Platforms")
@export var platform_color: Color = Color(0.35, 0.72, 0.45)
## Cor por tipo (valor de PlatformType.Type -> Color). Tipos ausentes usam platform_color.
@export var platform_type_colors: Dictionary = {}

@export_group("Sky")
@export var sky_top_color: Color = Color(0.25, 0.45, 0.8)
@export var sky_horizon_color: Color = Color(0.72, 0.82, 0.93)


func get_platform_color(type: int) -> Color:
	return platform_type_colors.get(type, platform_color)
