class_name LocalSave
extends RefCounted
## Persistência local simples (ConfigFile em user://).

const SAVE_PATH := "user://save_data.cfg"
const RECORDS_SECTION := "records"
const BEST_HEIGHT_KEY := "best_height"


static func load_best_height() -> float:
	var file := ConfigFile.new()
	if file.load(SAVE_PATH) != OK:
		return 0.0
	return float(file.get_value(RECORDS_SECTION, BEST_HEIGHT_KEY, 0.0))


static func save_best_height(value: float) -> void:
	var file := ConfigFile.new()
	file.load(SAVE_PATH)
	file.set_value(RECORDS_SECTION, BEST_HEIGHT_KEY, value)
	_save(file)


## `path` permite saves separados (ex.: testes); o padrão é o save do jogador.
static func load_section(section: String, path: String = SAVE_PATH) -> Dictionary:
	var values := {}
	var file := ConfigFile.new()
	if file.load(path) != OK or not file.has_section(section):
		return values
	for key in file.get_section_keys(section):
		values[key] = file.get_value(section, key)
	return values


## Substitui a seção inteira, preservando as demais (ex.: recordes).
static func save_section(section: String, values: Dictionary, path: String = SAVE_PATH) -> void:
	var file := ConfigFile.new()
	file.load(path)
	if file.has_section(section):
		file.erase_section(section)
	for key in values:
		file.set_value(section, key, values[key])
	_save(file, path)


static func _save(file: ConfigFile, path: String = SAVE_PATH) -> void:
	var error := file.save(path)
	if error != OK:
		push_warning("Falha ao salvar dados locais: %s" % error_string(error))
