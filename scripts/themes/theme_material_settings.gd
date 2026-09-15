@tool
class_name ThemeMaterialSettings
extends Resource
## Materiais e cores que um tema define para uma categoria de elementos (plataformas ou objetos
## especiais). Os elementos não guardam cores próprias: pedem o material ao tema ativo.

## Material principal (opcional). StandardMaterial3D/ORMMaterial3D recebem a cor pedida;
## ShaderMaterial recebe a cor no parâmetro `albedo_color`, se existir.
## Vazio = um StandardMaterial3D é gerado com as propriedades abaixo.
@export var material: Material:
	set(value):
		material = value
		_invalidate()

@export_group("Colors")
@export var primary_color: Color = Color.WHITE:
	set(value):
		primary_color = value
		_invalidate()
## Detalhes e acentos (setas, trilhos, partes secundárias).
@export var secondary_color: Color = Color.GRAY:
	set(value):
		secondary_color = value
		_invalidate()

@export_group("Surface")
@export_range(0.0, 1.0, 0.01) var roughness: float = 0.85:
	set(value):
		roughness = value
		_invalidate()
@export_range(0.0, 1.0, 0.01) var metallic: float = 0.0:
	set(value):
		metallic = value
		_invalidate()
@export var emission_color: Color = Color.BLACK:
	set(value):
		emission_color = value
		_invalidate()
## 0 = sem emissão.
@export_range(0.0, 8.0, 0.05) var emission_energy: float = 0.0:
	set(value):
		emission_energy = value
		_invalidate()

## Materiais já criados por cor (compartilhados entre todos os elementos do tema).
var _cache: Dictionary = {}


func get_primary_material() -> Material:
	return get_material(primary_color)


func get_secondary_material() -> Material:
	return get_material(secondary_color)


func get_material(color: Color) -> Material:
	if _cache.has(color):
		return _cache[color]
	var result: Material
	if material is BaseMaterial3D:
		var base := material.duplicate() as BaseMaterial3D
		base.albedo_color = color
		result = base
	elif material is ShaderMaterial:
		var shader_material := material.duplicate() as ShaderMaterial
		shader_material.set_shader_parameter(&"albedo_color", color)
		result = shader_material
	elif material:
		result = material
	else:
		var standard := StandardMaterial3D.new()
		standard.albedo_color = color
		standard.roughness = roughness
		standard.metallic = metallic
		if emission_energy > 0.0:
			standard.emission_enabled = true
			standard.emission = emission_color
			standard.emission_energy_multiplier = emission_energy
		result = standard
	_cache[color] = result
	return result


func _invalidate() -> void:
	_cache.clear()
	emit_changed()
