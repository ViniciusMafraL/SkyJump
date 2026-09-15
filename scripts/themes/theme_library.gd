class_name ThemeLibrary
extends Resource
## Lista das Theme Scenes disponíveis. Novo tema = nova cena Theme_X.tscn adicionada aqui.

@export var themes: Array[PackedScene] = []


func get_scene(index: int) -> PackedScene:
	return themes[index] if index >= 0 and index < themes.size() else null


func find_index(scene: PackedScene) -> int:
	return themes.find(scene)


## Nomes lidos do ThemeData de cada cena (instancia sem adicionar à árvore).
func get_display_names() -> PackedStringArray:
	var names := PackedStringArray()
	for scene in themes:
		var instance := scene.instantiate() as LevelTheme if scene else null
		names.append(instance.theme_data.display_name if instance and instance.theme_data else "?")
		if instance:
			instance.free()
	return names
