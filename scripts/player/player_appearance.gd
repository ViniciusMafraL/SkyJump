class_name PlayerAppearance
extends Node3D
## Aparência do personagem: instancia o modelo da PlayerSkin, aplica material e efeitos.
## Não conhece gameplay (movimento, pulo, colisão continuam no PlayerController).
## Malhas do modelo no grupo "skin_body" recebem o material da skin.

signal skin_applied(skin: PlayerSkin)

const BODY_GROUP := &"skin_body"
const OVERLAY_RENDER_PRIORITY := 1

## Aplica a skin selecionada no SkinManager ao entrar na cena (Player da partida e da sala de testes).
@export var use_selected_skin: bool = true
## Skin fixa quando use_selected_skin = false (ex.: previews).
@export var skin: PlayerSkin
## Gameplay: desenha o personagem depois do pós-processamento de contorno (art/shaders/pixel_outline.gdshader)
## e cria cópias só-sombra, porque materiais transparentes não projetam sombra.
@export var exclude_from_post_process: bool = true

var current_skin: PlayerSkin

static var _shadow_material: StandardMaterial3D


func _ready() -> void:
	# O modelo que estiver na cena serve só para visualizar no editor; a skin substitui antes do 1º frame.
	if use_selected_skin:
		apply_skin(SkinManager.get_current_skin())
	elif skin:
		apply_skin(skin)


func apply_skin(new_skin: PlayerSkin) -> void:
	if new_skin == null:
		return
	var model_scene := SkinManager.get_model_scene(new_skin)
	if model_scene == null:
		push_warning("PlayerAppearance: skin %s sem modelo." % new_skin.skin_id)
		return
	_clear()
	var model := model_scene.instantiate() as Node3D
	model.name = "Model"
	add_child(model)
	var body_material := new_skin.get_body_material()
	var meshes := _collect_meshes(model)
	for mesh in meshes:
		if mesh.is_in_group(BODY_GROUP):
			mesh.material_override = body_material
	if exclude_from_post_process:
		for mesh in meshes:
			_exclude_mesh(mesh)
	for effect in new_skin.get_attached_effects():
		add_child(effect.instantiate())
	current_skin = new_skin
	skin_applied.emit(new_skin)


## Efeito único ao nascer (se a skin tiver). Chamado por quem controla o spawn visual.
func play_spawn_effect() -> void:
	if current_skin and current_skin.spawn_effect:
		add_child(current_skin.spawn_effect.instantiate())


func get_model() -> Node3D:
	return get_node_or_null("Model") as Node3D


func _clear() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _collect_meshes(root_node: Node) -> Array[MeshInstance3D]:
	var meshes: Array[MeshInstance3D] = []
	if root_node is MeshInstance3D:
		meshes.append(root_node)
	for child in root_node.get_children():
		meshes.append_array(_collect_meshes(child))
	return meshes


func _exclude_mesh(mesh: MeshInstance3D) -> void:
	if mesh.mesh == null or mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY:
		return
	if mesh.material_override:
		mesh.material_override = _overlay_material(mesh.material_override)
	else:
		for surface in mesh.mesh.get_surface_count():
			var material := mesh.get_active_material(surface)
			if material:
				mesh.set_surface_override_material(surface, _overlay_material(material))
	if mesh.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
		var caster := MeshInstance3D.new()
		caster.name = "%sShadow" % mesh.name
		caster.mesh = mesh.mesh
		caster.transform = mesh.transform
		caster.material_override = _get_shadow_material()
		caster.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
		mesh.add_sibling(caster)
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Cópia desenhada depois do contorno: transparente (alpha 1), grava profundidade, prioridade 1.
func _overlay_material(material: Material) -> Material:
	var copy := material.duplicate() as Material
	if copy is BaseMaterial3D:
		copy.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		copy.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	elif copy is ShaderMaterial:
		push_warning("PlayerAppearance: ShaderMaterial precisa declarar transparência e depth_draw_always no próprio shader para ficar fora do contorno.")
	copy.render_priority = OVERLAY_RENDER_PRIORITY
	return copy


static func _get_shadow_material() -> StandardMaterial3D:
	if _shadow_material == null:
		_shadow_material = StandardMaterial3D.new()
	return _shadow_material
