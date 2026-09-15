class_name SettingDefinition
extends Resource
## Descreve um parâmetro exibido no painel da sala de testes.
## Adicionar um parâmetro ao painel = adicionar uma entrada no schema .tres, sem código.

## ENUM lê as opções do @export da própria propriedade (sem duplicar nomes no schema).
enum Kind { NUMBER, TOGGLE, FLAGS, ENUM }

## Título da seção; entradas consecutivas com o mesmo título ficam agrupadas.
@export var section_title: String = "MOVIMENTO"
@export var label: String = ""
## "<seção>.<propriedade>". Seções: ver TestRoomConfig.SECTIONS.
## Seções de objetos (TestRoomConfig.OBJECT_SECTIONS) só aparecem com o objeto selecionado.
@export var path: String = ""
@export var kind: Kind = Kind.NUMBER
@export var min_value: float = 0.0
@export var max_value: float = 1.0
@export var step: float = 0.01
@export var suffix: String = ""
@export_multiline var hint: String = ""


func get_section() -> StringName:
	return StringName(path.get_slice(".", 0))
