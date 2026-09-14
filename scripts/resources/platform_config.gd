class_name PlatformConfig
extends Resource
## Parâmetros de gameplay de um tipo de plataforma. Nada visual aqui.

@export var id: StringName = &"normal"
@export var platform_type: PlatformType.Type = PlatformType.Type.NORMAL
## Largura ao longo da circunferência (unidades do mundo).
@export var width: float = 3.0
## Profundidade radial (unidades do mundo).
@export var depth: float = 3.0
## Largura mínima após aplicar o multiplicador de dificuldade.
@export var min_width: float = 1.2
## Peso relativo no sorteio do gerador. 0 = nunca sorteada.
@export var weight: float = 1.0
## Altura mínima (metros) para aparecer.
@export var minimum_height: float = 0.0
## Altura máxima (metros) para aparecer. Negativo = sem limite.
@export var maximum_height: float = -1.0
## Se falso, o pulo automático não dispara sobre esta plataforma.
@export var auto_jump_enabled: bool = true
## Cena de gameplay alternativa (script que estende Platform). Vazio = cena padrão.
@export var scene_override: PackedScene


func is_available_at(height_m: float) -> bool:
	return height_m >= minimum_height and (maximum_height < 0.0 or height_m <= maximum_height)
