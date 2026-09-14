class_name LevelChunk
extends Node3D
## Nó de um chunk carregado: instancia as plataformas descritas em LevelChunkData.

var data: LevelChunkData
var platforms: Array[Platform] = []


func build(chunk_data: LevelChunkData, default_platform_scene: PackedScene) -> void:
	data = chunk_data
	for platform_data in data.platforms:
		platforms.append(PlatformFactory.create(platform_data, default_platform_scene, data.theme, self))
