class_name PlayerSkin
extends Resource
## Dados de APARÊNCIA do personagem (um .tres por skin). Nunca contém valores de gameplay:
## velocidade, pulo, gravidade e colisão continuam no PlayerMovementConfig/PlayerController.
## Nova skin = duplicar um .tres, alterar os campos e adicioná-lo ao SkinDatabase.

## Preparado para coleções/desbloqueios futuros (ainda sem regra de jogo).
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var skin_id: StringName
@export var display_name: String = ""
@export var preview_icon: Texture2D
@export var rarity: Rarity = Rarity.COMMON
## Estado de desbloqueio padrão. A regra real de desbloqueio passa pelo SkinManager.is_unlocked().
@export var is_unlocked: bool = true

@export_group("Modelo")
## Cena visual (só malhas/efeitos, sem gameplay). Vazio = modelo padrão do SkinDatabase (a bola).
## Malhas no grupo "skin_body" recebem o material da skin.
@export var model_scene: PackedScene

@export_group("Material")
## Material pronto para o corpo (StandardMaterial3D ou ShaderMaterial). Vazio = gerado pelos campos abaixo.
@export var material: Material
@export var base_color: Color = Color.WHITE
@export_range(0.0, 1.0, 0.01) var roughness: float = 0.6
@export_range(0.0, 1.0, 0.01) var metallic: float = 0.0
@export var emission_enabled: bool = false
@export var emission_color: Color = Color.BLACK
@export_range(0.0, 16.0, 0.01) var emission_energy: float = 1.0

@export_group("Preview")
@export var preview_rotation_degrees: Vector3 = Vector3.ZERO
@export_range(0.1, 5.0, 0.01) var preview_scale: float = 1.0

@export_group("Efeitos")
## Cenas instanciadas junto do modelo (partículas, rastro, aura) e efeito único ao nascer.
@export var particle_effect: PackedScene
@export var trail_effect: PackedScene
@export var aura_effect: PackedScene
@export var spawn_effect: PackedScene


func get_display_name() -> String:
	return display_name if not display_name.is_empty() else String(skin_id)


## Material do corpo: `material` quando definido; senão um StandardMaterial3D novo a partir das cores.
func get_body_material() -> Material:
	if material:
		return material
	var generated := StandardMaterial3D.new()
	generated.albedo_color = base_color
	generated.roughness = roughness
	generated.metallic = metallic
	generated.emission_enabled = emission_enabled
	generated.emission = emission_color
	generated.emission_energy_multiplier = emission_energy
	return generated


## Cor que representa a skin em interfaces (ex.: marcador da barra de altura).
func get_marker_color() -> Color:
	if material is BaseMaterial3D:
		return (material as BaseMaterial3D).albedo_color
	return base_color


func get_attached_effects() -> Array[PackedScene]:
	var effects: Array[PackedScene] = []
	for effect in [particle_effect, trail_effect, aura_effect]:
		if effect:
			effects.append(effect)
	return effects
