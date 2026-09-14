class_name SkinDatabase
extends Resource
## Lista de skins disponíveis. Adicionar uma skin = incluir o .tres em `skins` pelo Inspector.

@export var skins: Array[PlayerSkin] = []
## Skin usada quando não há seleção salva ou a salva não existe mais.
@export var default_skin_id: StringName = &"classic"
## Modelo usado pelas skins sem model_scene próprio.
@export var default_model_scene: PackedScene


func get_count() -> int:
	return skins.size()


func get_skin(index: int) -> PlayerSkin:
	return skins[index] if index >= 0 and index < skins.size() else null


func find_index(skin_id: StringName) -> int:
	for i in skins.size():
		if skins[i] and skins[i].skin_id == skin_id:
			return i
	return -1


func find_skin(skin_id: StringName) -> PlayerSkin:
	return get_skin(find_index(skin_id))


func get_model_scene(skin: PlayerSkin) -> PackedScene:
	return skin.model_scene if skin and skin.model_scene else default_model_scene
