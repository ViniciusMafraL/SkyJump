class_name PlatformFactory
extends RefCounted
## Ponto único de criação de plataformas e objetos. Object pooling pode ser introduzido aqui futuramente.


static func create(data: PlatformData, default_scene: PackedScene, theme: ThemeData, parent: Node) -> Platform:
	return create_object(data, default_scene, theme, parent) as Platform


## Instancia qualquer GameplayObject (plataforma, escada, portal...) a partir da cena do config.
## `properties` são aplicadas antes do setup (ex.: {"intensity": 2, "portal_id": &"A"}).
## `configure` (opcional) recebe a instância antes do setup (ex.: injetar configuração ativa).
static func create_object(data: PlatformData, default_scene: PackedScene, theme: ThemeData, parent: Node, properties: Dictionary = {}, configure: Callable = Callable()) -> GameplayObject:
	var scene := default_scene
	if data.config and data.config.scene_override:
		scene = data.config.scene_override
	var object: GameplayObject = scene.instantiate()
	object.flip = data.flip
	if data.config:
		_apply_properties(object, data.config.object_properties)
	_apply_properties(object, data.object_properties)
	_apply_properties(object, properties)
	if configure.is_valid():
		configure.call(object)
	parent.add_child(object)
	object.setup(data, theme)
	return object


## Distância do centro da plataforma ao eixo, com a face interna encostada (embutida) no pilar.
static func radius_for(pillar_radius: float, depth: float, embed_depth: float) -> float:
	return pillar_radius + depth * 0.5 - embed_depth


static func _apply_properties(object: Object, properties: Dictionary) -> void:
	for key in properties:
		if StringName(key) in object:
			object.set(StringName(key), properties[key])
		else:
			push_warning("Propriedade '%s' não existe em %s" % [key, object])
