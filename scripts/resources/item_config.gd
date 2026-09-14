class_name ItemConfig
extends Resource
## Feature flags de itens. Nenhum item está implementado ainda: esta é só a infraestrutura
## que os sistemas de itens futuros devem consultar.

enum Category { MOVEMENT, DEFENSIVE, MOBILITY, SPECIAL }

@export var items_enabled: bool = false
## Bits na ordem de Category.
@export_flags("Movimento", "Defensivos", "Mobilidade", "Especiais") var enabled_categories: int = 0


func is_category_enabled(category: Category) -> bool:
	return items_enabled and (enabled_categories & (1 << category)) != 0
