class_name PlacementRule
extends Resource
## Regra de posicionamento de uma plataforma especial. O tipo já foi escolhido pela distribuição do
## tema; a regra decide ONDE colocar, considerando a âncora (posição do jogador), alcance do salto,
## direção da subida, colisões e as características do objeto. Também pode criar as plataformas
## auxiliares de que o objeto precisa (entrada de um tubo, pouso de um canhão...) e define a nova âncora.
## Nova plataforma especial = nova regra, sem mudar o gerador.

enum Result { PLACED, FAILED, CHUNK_END }

## Identificador usado nas estatísticas de distribuição (ex.: &"wall").
@export var id: StringName = &""
@export var display_name: String = ""
## Plataforma/objeto principal colocado por esta regra (cena, tamanho e tipo).
@export var platform_config: PlatformConfig


func get_selection_key() -> StringName:
	if not id.is_empty():
		return id
	return platform_config.id if platform_config else &""


func get_platform_type() -> PlatformType.Type:
	return platform_config.platform_type if platform_config else PlatformType.Type.NORMAL


## PLACED: seção adicionada ao chunk. FAILED: sem posição válida (o gerador usa uma plataforma comum).
## CHUNK_END: a seção começaria no próximo chunk.
func place(_generator: LevelGenerator, _chunk: LevelChunkData) -> Result:
	return Result.FAILED


## Direção tangencial (positivo = direita da tela) do "lado direito" de um objeto espelhado ou não.
static func object_sign(flip: bool) -> float:
	return -1.0 if flip else 1.0
