class_name TestRoomConfig
extends Resource
## Reúne as configurações de gameplay controláveis pela sala de testes.
## Por padrão aponta para os mesmos .tres usados pelo jogo principal.

## Seções endereçáveis por caminho "<seção>.<propriedade>" (ex.: "movement.jump_force").
const SECTIONS := [
	&"movement", &"trampoline", &"camera", &"item", &"ability",
	&"moving", &"diagonal_trampoline", &"wall", &"bubble", &"sliding", &"stair",
	&"tube", &"vine", &"portal", &"tnt", &"cannon",
]
## Seções de objetos especiais: o painel só mostra a do objeto selecionado na sala.
const OBJECT_SECTIONS := [
	&"moving", &"diagonal_trampoline", &"wall", &"bubble", &"sliding", &"stair",
	&"tube", &"vine", &"portal", &"tnt", &"cannon",
]

@export var movement_config: PlayerMovementConfig
@export var trampoline_config: TrampolineConfig
@export var camera_config: CameraConfig
@export var item_config: ItemConfig
@export var ability_config: AbilityConfig

@export_group("Objects")
@export var moving_config: MovingPlatformConfig
@export var diagonal_trampoline_config: DiagonalTrampolineConfig
@export var wall_config: WallConfig
@export var bubble_config: BubblePlatformConfig
@export var sliding_config: SlidingPlatformConfig
@export var stair_config: StairConfig
@export var tube_config: TubeConfig
@export var vine_config: VineConfig
@export var portal_config: PortalConfig
@export var tnt_config: TNTConfig
@export var cannon_config: CannonConfig


func get_section(section: StringName) -> Resource:
	var property := String(section) + "_config"
	return get(property) if property in self else null


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
