class_name AbilityConfig
extends Resource
## Feature flags de habilidades. Nenhuma habilidade está implementada ainda: esta é só a
## infraestrutura que as habilidades futuras devem consultar antes de ativar.

enum Ability { DASH, DOUBLE_JUMP, AIR_DASH, WALL_JUMP, GRAPPLING_HOOK, SHIELD }

@export var abilities_enabled: bool = false
## Bits na ordem de Ability.
@export_flags("Dash", "Double Jump", "Air Dash", "Wall Jump", "Grappling Hook", "Shield") var allowed_abilities: int = 0


func is_ability_enabled(ability: Ability) -> bool:
	return abilities_enabled and (allowed_abilities & (1 << ability)) != 0
