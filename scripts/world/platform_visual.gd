class_name PlatformVisual
extends Node3D
## PLACEHOLDER: caixa escalada. Pode ser trocada por um modelo definitivo mantendo `apply`.

@export var thickness: float = 0.5
@export var bounce_squash: float = 0.4
@export var bounce_duration: float = 0.35

## Materiais compartilhados por cor, para não criar um material por plataforma.
static var _materials: Dictionary = {}

var _bounce_tween: Tween

@onready var _mesh: MeshInstance3D = $Mesh


func apply(data: PlatformData, theme: ThemeData) -> void:
	_mesh.scale = Vector3(data.depth, thickness, data.width)
	_mesh.position = Vector3(0.0, -thickness * 0.5, 0.0)
	# Material vem do tema ativo (plataformas comuns ou objetos especiais, conforme o tipo).
	var settings := theme.get_material_settings(data.platform_type) if theme else null
	_mesh.material_override = settings.get_primary_material() if settings else _get_material(Color.WHITE)


## Feedback de impulso (trampolins).
func play_bounce() -> void:
	if _bounce_tween and _bounce_tween.is_valid():
		_bounce_tween.kill()
	scale = Vector3(1.0, bounce_squash, 1.0)
	_bounce_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_bounce_tween.tween_property(self, "scale", Vector3.ONE, bounce_duration) \
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


static func _get_material(color: Color) -> StandardMaterial3D:
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.85
		_materials[color] = material
	return _materials[color]
