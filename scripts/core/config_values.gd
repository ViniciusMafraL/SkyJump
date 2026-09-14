class_name ConfigValues
extends RefCounted
## Utilitários para copiar valores entre Resources de configuração sem trocar referências.


## Copia todas as variáveis exportadas (salváveis) de `from` para `to`.
## Propriedades calculadas (sem armazenamento, ex.: jump_height) são ignoradas.
## `skip_objects` preserva as referências a sub-Resources de `to`.
static func copy_values(from: Resource, to: Resource, skip_objects: bool = false) -> void:
	for property in from.get_property_list():
		var usage: int = property.usage
		if not (usage & PROPERTY_USAGE_SCRIPT_VARIABLE and usage & PROPERTY_USAGE_STORAGE):
			continue
		var value: Variant = from.get(property.name)
		if skip_objects and typeof(value) == TYPE_OBJECT:
			continue
		to.set(property.name, value)


static func differs(a: Resource, b: Resource) -> bool:
	for property in a.get_property_list():
		var usage: int = property.usage
		if usage & PROPERTY_USAGE_SCRIPT_VARIABLE and usage & PROPERTY_USAGE_STORAGE:
			if a.get(property.name) != b.get(property.name):
				return true
	return false


static func find_property(resource: Resource, property_name: StringName) -> Dictionary:
	for property in resource.get_property_list():
		if property.name == property_name:
			return property
	return {}
