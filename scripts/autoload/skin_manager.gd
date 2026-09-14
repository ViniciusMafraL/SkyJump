extends Node
## Autoload global (SkinManager): skin selecionada, navegação circular, desbloqueio e salvamento local.
## Só trata de APARÊNCIA: nenhum sistema de gameplay lê este manager.
## "Foco" = skin mostrada no seletor (pode estar bloqueada); "selecionada" = a que vai para o Player.

signal skin_selected(skin: PlayerSkin)
signal focus_changed(skin: PlayerSkin, index: int)

const SAVE_SECTION := "skins"
const SELECTED_KEY := "selected_skin_id"

@export var database: SkinDatabase
## Salva a seleção em user:// (LocalSave). Desligado em testes.
@export var persist_selection: bool = true

var _selected_index: int = -1
var _focused_index: int = -1


func _ready() -> void:
	load_selection()


func get_skin_count() -> int:
	return database.get_count()


func get_skin(index: int) -> PlayerSkin:
	return database.get_skin(index)


func get_skins() -> Array[PlayerSkin]:
	return database.skins


func get_current_skin() -> PlayerSkin:
	return database.get_skin(_selected_index)


func get_current_index() -> int:
	return _selected_index


func get_focused_skin() -> PlayerSkin:
	return database.get_skin(_focused_index)


func get_focused_index() -> int:
	return _focused_index


func get_model_scene(skin: PlayerSkin) -> PackedScene:
	return database.get_model_scene(skin)


## Ponto único da regra de desbloqueio. Futuras conquistas/compras entram aqui.
func is_unlocked(skin: PlayerSkin) -> bool:
	return skin != null and skin.is_unlocked


## Seleciona pelo ID. Skins inexistentes ou bloqueadas são recusadas.
func set_skin(skin_id: StringName) -> bool:
	var index := database.find_index(skin_id)
	if index < 0 or not is_unlocked(database.get_skin(index)):
		return false
	_set_focus(index)
	_select(index)
	return true


## Avança o foco (circular). Seleciona a skin se estiver desbloqueada. Retorna a skin em foco.
func next_skin() -> PlayerSkin:
	return _step(1)


func previous_skin() -> PlayerSkin:
	return _step(-1)


## Devolve o foco à skin selecionada (ex.: ao sair do menu com uma skin bloqueada em foco).
func reset_focus() -> void:
	_set_focus(_selected_index)


func load_selection() -> void:
	var index := -1
	if persist_selection:
		var saved := LocalSave.load_section(SAVE_SECTION)
		index = database.find_index(StringName(str(saved.get(SELECTED_KEY, ""))))
	if index < 0 or not is_unlocked(database.get_skin(index)):
		index = database.find_index(database.default_skin_id)
	if index < 0 or not is_unlocked(database.get_skin(index)):
		index = _first_unlocked_index()
	_selected_index = index
	_set_focus(index)


func _step(direction: int) -> PlayerSkin:
	var count := get_skin_count()
	if count == 0:
		return null
	_set_focus(posmod(_focused_index + direction, count))
	var skin := get_focused_skin()
	if is_unlocked(skin):
		_select(_focused_index)
	return skin


func _select(index: int) -> void:
	if index == _selected_index:
		return
	_selected_index = index
	if persist_selection:
		LocalSave.save_section(SAVE_SECTION, {SELECTED_KEY: String(get_current_skin().skin_id)})
	skin_selected.emit(get_current_skin())


func _set_focus(index: int) -> void:
	if index == _focused_index:
		return
	_focused_index = index
	focus_changed.emit(get_focused_skin(), index)


func _first_unlocked_index() -> int:
	for i in get_skin_count():
		if is_unlocked(database.get_skin(i)):
			return i
	return -1
