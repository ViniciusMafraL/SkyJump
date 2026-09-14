class_name DifficultyConfig
extends Resource
## Curva de dificuldade por altura.

## Níveis ordenados por start_height crescente.
@export var tiers: Array[DifficultyTier] = []
## Se verdadeiro, os valores são interpolados entre níveis vizinhos (curva contínua).
@export var interpolate_between_tiers: bool = true


## O resultado pode ser um Resource compartilhado: não modificar.
func evaluate(height_m: float) -> DifficultyTier:
	if tiers.is_empty():
		return DifficultyTier.new()
	if height_m <= tiers[0].start_height:
		return tiers[0]
	for i in range(tiers.size() - 1):
		var current := tiers[i]
		var next := tiers[i + 1]
		if height_m >= next.start_height:
			continue
		if not interpolate_between_tiers:
			return current
		var span := next.start_height - current.start_height
		var weight := 1.0 if span <= 0.0 else (height_m - current.start_height) / span
		return current.interpolated(next, weight)
	return tiers[tiers.size() - 1]
