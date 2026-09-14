class_name PlatformFactory
extends RefCounted
## Ponto único de criação de plataformas. Object pooling pode ser introduzido aqui futuramente.


static func create(data: PlatformData, default_scene: PackedScene, theme: ThemeData, parent: Node) -> Platform:
	var scene := default_scene
	if data.config and data.config.scene_override:
		scene = data.config.scene_override
	var platform: Platform = scene.instantiate()
	parent.add_child(platform)
	platform.setup(data, theme)
	return platform


## Distância do centro da plataforma ao eixo, com a face interna encostada (embutida) no pilar.
static func radius_for(pillar_radius: float, depth: float, embed_depth: float) -> float:
	return pillar_radius + depth * 0.5 - embed_depth
