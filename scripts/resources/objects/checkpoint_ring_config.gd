class_name CheckpointRingConfig
extends Resource
## Aparência da plataforma de checkpoint do Desafio Diário: anel em volta do cilindro inteiro,
## em xadrez de `light_color` com a cor da medalha do checkpoint.

@export_group("Shape")
@export var thickness: float = 0.5
## Casas do xadrez ao redor do cilindro (par, para o padrão fechar a volta).
@export_range(8, 128, 2) var segments: int = 36
## Casas do xadrez na profundidade (do cilindro para fora).
@export_range(1, 4) var rows: int = 2

@export_group("Colors")
@export var light_color: Color = SkyJumpColors.WHITE
## Cor de cada checkpoint, na ordem: bronze, prata (cinza) e estrela (vermelho).
@export var medal_colors: Array[Color] = [SkyJumpColors.BRONZE, SkyJumpColors.SILVER, SkyJumpColors.RED]


func get_medal_color(index: int) -> Color:
	if medal_colors.is_empty():
		return SkyJumpColors.RED
	return medal_colors[clampi(index, 0, medal_colors.size() - 1)]
