class_name SpecialPlatformEntry
extends Resource
## Uma plataforma especial disponível num tema, com seu peso na distribuição.

@export var rule: PlacementRule
## Peso relativo (a soma com a plataforma comum é normalizada).
@export var weight: float = 1.0
@export var enabled: bool = true


func is_available() -> bool:
	return enabled and rule != null and weight > 0.0
