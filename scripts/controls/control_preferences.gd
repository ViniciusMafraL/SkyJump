class_name ControlPreferences
extends RefCounted
## Salva localmente só as escolhas do jogador que diferem do ControlConfig.tres,
## para que mudanças futuras nos padrões continuem valendo para o resto.

const SAVE_SECTION := "controls"


static func load_into(config: ControlConfig) -> void:
	var values := LocalSave.load_section(SAVE_SECTION)
	for key: String in values:
		var target := _resolve_target(config, key)
		var property := key.get_slice(".", 1) if key.contains(".") else key
		if target and not ConfigValues.find_property(target, property).is_empty():
			target.set(property, values[key])


static func save(config: ControlConfig, defaults: ControlConfig) -> void:
	var values := {}
	_collect_differences(config, defaults, "", values)
	for section in ControlConfig.SECTIONS:
		_collect_differences(config.get_section(section), defaults.get_section(section), String(section) + ".", values)
	LocalSave.save_section(SAVE_SECTION, values)


static func _collect_differences(current: Resource, defaults: Resource, prefix: String, values: Dictionary) -> void:
	if current == null or defaults == null:
		return
	for property in current.get_property_list():
		var usage: int = property.usage
		if not (usage & PROPERTY_USAGE_SCRIPT_VARIABLE and usage & PROPERTY_USAGE_STORAGE):
			continue
		var value: Variant = current.get(property.name)
		if typeof(value) == TYPE_OBJECT or value == defaults.get(property.name):
			continue
		values[prefix + property.name] = value


static func _resolve_target(config: ControlConfig, key: String) -> Resource:
	if key.contains("."):
		return config.get_section(StringName(key.get_slice(".", 0)))
	return config
