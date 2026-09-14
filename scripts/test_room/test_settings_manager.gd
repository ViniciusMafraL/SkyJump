class_name TestSettingsManager
extends Node
## Mantém três versões das configurações da sala:
## - default_config: os .tres padrão (os mesmos usados pelo jogo principal);
## - draft: valores sendo editados no painel;
## - active: valores em uso pelos sistemas (referências estáveis, atualizadas por cópia).

signal draft_changed
signal settings_applied(active_config: TestRoomConfig)

## Ao definir (na cena ou por código), cria as cópias ativa e de rascunho imediatamente,
## antes de qualquer _ready: UI e sistemas já encontram as configurações prontas.
@export var default_config: TestRoomConfig:
	set(value):
		default_config = value
		active = value.make_copy() if value else null
		draft = value.make_copy() if value else null
		has_pending_changes = false
@export var presets: Array[TestRoomPreset] = []
## Se verdadeiro, cada alteração no painel é aplicada imediatamente.
@export var apply_on_change: bool = false

var active: TestRoomConfig
var draft: TestRoomConfig
var has_pending_changes: bool = false
## Arquivos gravados pelo último save_active_as_game_defaults().
var last_saved_paths: PackedStringArray = []


func get_value(path: String) -> Variant:
	var section := _section_for(draft, path)
	return section.get(_property_for(path)) if section else null


func get_property_info(path: String) -> Dictionary:
	var section := _section_for(draft, path)
	return ConfigValues.find_property(section, _property_for(path)) if section else {}


func set_value(path: String, value: Variant) -> void:
	if not _set_path(draft, path, value):
		return
	_mark_draft_changed()


func apply() -> void:
	active.copy_values_from(draft)
	has_pending_changes = false
	settings_applied.emit(active)
	draft_changed.emit()


## Restaura os valores dos .tres padrão e aplica imediatamente.
func reset_to_defaults() -> void:
	draft.copy_values_from(default_config)
	apply()


func load_preset(index: int) -> void:
	if index < 0 or index >= presets.size():
		return
	var preset := presets[index]
	draft.copy_values_from(default_config)
	for path in preset.overrides:
		_set_path(draft, path, preset.overrides[path])
	_mark_draft_changed()


## res:// só é gravável quando o jogo roda a partir do editor.
func can_save_game_defaults() -> bool:
	return OS.has_feature("editor")


## Grava os valores ATIVOS nos .tres padrão do jogo (apenas seções alteradas).
func save_active_as_game_defaults() -> Error:
	last_saved_paths.clear()
	if not can_save_game_defaults():
		return ERR_UNAVAILABLE
	for section in TestRoomConfig.SECTIONS:
		var target := default_config.get_section(section)
		var source := active.get_section(section)
		if target == null or source == null or not ConfigValues.differs(source, target):
			continue
		if not target.resource_path.begins_with("res://") or target.resource_path.contains("::"):
			push_warning("Seção '%s' não é um arquivo .tres próprio; não foi salva." % section)
			continue
		ConfigValues.copy_values(source, target)
		var error := ResourceSaver.save(target)
		if error != OK:
			return error
		last_saved_paths.append(target.resource_path)
	return OK


func _mark_draft_changed() -> void:
	has_pending_changes = true
	if apply_on_change:
		apply()
	else:
		draft_changed.emit()


func _set_path(config: TestRoomConfig, path: String, value: Variant) -> bool:
	var section := _section_for(config, path)
	if section == null:
		push_warning("Caminho de configuração inválido: %s" % path)
		return false
	section.set(_property_for(path), value)
	return true


func _section_for(config: TestRoomConfig, path: String) -> Resource:
	return config.get_section(StringName(path.get_slice(".", 0)))


func _property_for(path: String) -> StringName:
	return StringName(path.get_slice(".", 1))
