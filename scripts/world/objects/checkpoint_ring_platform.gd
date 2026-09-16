class_name CheckpointRingPlatform
extends Platform
## PLATAFORMA DE CHECKPOINT do Desafio Diário: anel sólido em volta do cilindro inteiro, em xadrez
## branco + cor da medalha do checkpoint (1º bronze, 2º prata, 3º estrela). Pousar em qualquer
## ponto conta. Só marca o local: quem registra o checkpoint é o DailyRunController.

@export var config: CheckpointRingConfig
## Índice do checkpoint (0..2), definido pelo gerador via object_properties.
@export var checkpoint_index: int = 0


func get_state_name() -> String:
	return "Checkpoint %d" % (checkpoint_index + 1)


func get_medal_color() -> Color:
	return _get_config().get_medal_color(checkpoint_index)


func get_mesh_instance() -> MeshInstance3D:
	return $Visual/Mesh


## O anel ocupa todos os ângulos: só a faixa radial importa.
func contains(_angle: float, radius: float, margin: float) -> bool:
	return absf(radius - current_radius) <= collision.size.y * 0.5 + margin


func _on_setup() -> void:
	_solid = true
	collision.size = Vector2(data.width, data.depth)
	var ring := _get_config()
	var mesh_instance := get_mesh_instance()
	mesh_instance.transform = Transform3D.IDENTITY
	mesh_instance.mesh = CheckpointRingMesh.get_mesh(maxf(current_radius - data.depth * 0.5, 0.1), current_radius + data.depth * 0.5,
		ring.thickness, ring.segments, ring.rows, ring.light_color, get_medal_color())
	mesh_instance.material_override = CheckpointRingMesh.get_material()


## As cores são da medalha, não do tema.
func _on_theme_applied() -> void:
	pass


## Centralizado no eixo do cilindro (a malha é a volta inteira).
func _sync_transform() -> void:
	var target := Transform3D(Basis.IDENTITY, Vector3(0.0, current_height, 0.0))
	if is_inside_tree():
		global_transform = target
	else:
		transform = target


func _get_config() -> CheckpointRingConfig:
	if config == null:
		config = CheckpointRingConfig.new()
	return config
