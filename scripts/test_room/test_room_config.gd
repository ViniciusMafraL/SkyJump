class_name TestRoomConfig
extends Resource
## Reúne as configurações de gameplay controláveis pela sala de testes.
## Por padrão aponta para os mesmos .tres usados pelo jogo principal.

## Seções endereçáveis por caminho "<seção>.<propriedade>" (ex.: "movement.jump_force").
const SECTIONS := [&"movement", &"trampoline", &"camera", &"item", &"ability"]

@export var movement_config: PlayerMovementConfig
@export var trampoline_config: TrampolineConfig
@export var camera_config: CameraConfig
@export var item_config: ItemConfig
@export var ability_config: AbilityConfig


func get_section(section: StringName) -> Resource:
	return get(String(section) + "_config")


## Cópia independente de cada seção (alterar a cópia não afeta os .tres originais).
func make_copy() -> TestRoomConfig:
	var copy := TestRoomConfig.new()
	for section in SECTIONS:
		var source := get_section(section)
		copy.set(String(section) + "_config", source.duplicate() if source else null)
	return copy


## Copia valores seção a seção, preservando as referências deste objeto.
func copy_values_from(other: TestRoomConfig) -> void:
	for section in SECTIONS:
		var target := get_section(section)
		var source := other.get_section(section)
		if target and source:
			ConfigValues.copy_values(source, target)
