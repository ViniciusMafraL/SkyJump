@tool
class_name ThemeData
extends Resource
## Configuração visual de um tema de nível (identidade visual, cores, materiais e iluminação).
## Fica centralizada na Theme Scene (LevelTheme.theme_data). Não contém gameplay nem assets de bioma.

const BASIC_PLATFORM_TYPES := [
	PlatformType.Type.NORMAL, PlatformType.Type.SMALL, PlatformType.Type.LARGE, PlatformType.Type.DANGER,
]

@export var id: StringName = &""
@export var display_name: String = ""

@export_group("Background")
## BASE_COLOR: cor inferior do cenário.
@export var base_color: Color = Color.WHITE:
	set(value):
		base_color = value
		emit_changed()
## TOP_COLOR: cor superior do cenário.
@export var top_color: Color = Color.GRAY:
	set(value):
		top_color = value
		emit_changed()
## Faixa da altura do fundo onde acontece a transição (0 = base, 1 = topo).
@export_range(0.0, 1.0, 0.01) var gradient_start: float = 0.2:
	set(value):
		gradient_start = value
		emit_changed()
@export_range(0.0, 1.0, 0.01) var gradient_end: float = 0.8:
	set(value):
		gradient_end = value
		emit_changed()
@export_range(0.1, 4.0, 0.05) var gradient_power: float = 1.0:
	set(value):
		gradient_power = value
		emit_changed()

@export_group("Platforms")
## Plataformas comuns (normal, pequena, grande).
@export var platform_material: ThemeMaterialSettings

@export_group("Special Objects")
## Plataformas e objetos especiais (móvel, trampolins, parede, tubo, portal, canhão...).
@export var special_object_material: ThemeMaterialSettings

@export_group("Lighting")
@export var lighting: ThemeLightingSettings


static func is_basic_platform(type: int) -> bool:
	return type in BASIC_PLATFORM_TYPES


## Materiais que um tipo de plataforma/objeto recebe neste tema.
func get_material_settings(type: int) -> ThemeMaterialSettings:
	var basic := is_basic_platform(type)
	var preferred := platform_material if basic else special_object_material
	var other := special_object_material if basic else platform_material
	return preferred if preferred else other
