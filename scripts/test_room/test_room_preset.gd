class_name TestRoomPreset
extends Resource
## Preset de teste: apenas os valores que diferem do padrão.
## Chaves no formato "<seção>.<propriedade>", ex.: {"movement.gravity": 16.0}.

@export var display_name: String = "Default"
@export var overrides: Dictionary = {}
