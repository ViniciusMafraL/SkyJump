class_name ThemeConfig
extends Resource
## Lista de temas por região de altura.

## Temas ordenados por start_height crescente.
@export var themes: Array[ThemeData] = []


func get_theme_for_height(height_m: float) -> ThemeData:
	var result: ThemeData = null
	for theme in themes:
		if theme == null:
			continue
		if result == null or height_m >= theme.start_height:
			result = theme
	return result
