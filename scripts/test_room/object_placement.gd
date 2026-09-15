class_name ObjectPlacement
extends PlatformPlacement
## Objeto especial posicionado manualmente (sala de testes). Aceita qualquer cena de
## GameplayObject indicada no scene_override do PlatformConfig.

## Espelha a direção local do objeto.
@export var flip: bool = false
## Propriedades aplicadas à instância antes do setup (ex.: {"portal_id": &"A"}).
@export var properties: Dictionary = {}
