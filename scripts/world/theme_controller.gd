class_name ThemeController
extends Node
## Aplica o tema da altura atual aos elementos de apresentação (céu e neblina).

@export var theme_config: ThemeConfig
@export var world_environment: WorldEnvironment

var _current: ThemeData


func apply_for_height(height_m: float) -> void:
	if theme_config == null:
		return
	var theme := theme_config.get_theme_for_height(height_m)
	if theme == null or theme == _current:
		return
	_current = theme
	_apply_sky(theme)


func _apply_sky(theme: ThemeData) -> void:
	if world_environment == null or world_environment.environment == null:
		return
	var environment := world_environment.environment
	environment.fog_light_color = theme.sky_horizon_color
	if environment.sky and environment.sky.sky_material is ProceduralSkyMaterial:
		var sky_material := environment.sky.sky_material as ProceduralSkyMaterial
		sky_material.sky_top_color = theme.sky_top_color
		sky_material.sky_horizon_color = theme.sky_horizon_color
		sky_material.ground_horizon_color = theme.sky_horizon_color
