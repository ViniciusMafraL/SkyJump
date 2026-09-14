class_name DifficultyTier
extends Resource
## Um ponto da curva de dificuldade.

@export var label: String = "Fácil"
## Altura (metros) em que este nível passa a valer integralmente.
@export var start_height: float = 0.0
@export var platform_size_multiplier: float = 1.0
@export var vertical_distance_multiplier: float = 1.0
@export var angular_distance_multiplier: float = 1.0
## Chance de gerar uma plataforma lateral extra, oferecendo escolha de rota.
@export_range(0.0, 1.0) var branch_platform_chance: float = 0.3


func interpolated(to: DifficultyTier, weight: float) -> DifficultyTier:
	var result := DifficultyTier.new()
	result.label = label if weight < 0.5 else to.label
	result.start_height = lerpf(start_height, to.start_height, weight)
	result.platform_size_multiplier = lerpf(platform_size_multiplier, to.platform_size_multiplier, weight)
	result.vertical_distance_multiplier = lerpf(vertical_distance_multiplier, to.vertical_distance_multiplier, weight)
	result.angular_distance_multiplier = lerpf(angular_distance_multiplier, to.angular_distance_multiplier, weight)
	result.branch_platform_chance = lerpf(branch_platform_chance, to.branch_platform_chance, weight)
	return result
