class_name LevelChunk
extends Node3D
## Nó de um chunk carregado: instancia as plataformas e objetos descritos em LevelChunkData.
## Qualquer GameplayObject (plataforma, escada, tubo, portal...) pode vir do scene_override do config.

var data: LevelChunkData
## Plataformas colidíveis (inclui degraus/pontos de objetos compostos).
var platforms: Array[Platform] = []
var objects: Array[GameplayObject] = []


## `theme` = tema ativo (materiais das plataformas e objetos).
func build(chunk_data: LevelChunkData, default_platform_scene: PackedScene, theme: ThemeData) -> void:
	data = chunk_data
	for platform_data in data.platforms:
		var object := PlatformFactory.create_object(platform_data, default_platform_scene, theme, self)
		objects.append(object)
		platforms.append_array(object.get_platforms())
