class_name TrampolinePlacementRule
extends StepPlacementRule
## Trampolim comum: passo alcançável; como o lançamento é forçado, a próxima plataforma usa a altura
## do impulso (mais alta que um pulo normal).

@export var trampoline_config: TrampolineConfig
## Intensidade usada pelo trampolim gerado (TrampolinePlatform.Intensity).
@export var intensity: int = 1


func get_launch_speed(generator: LevelGenerator) -> float:
	if trampoline_config == null:
		return generator.movement.jump_force
	var speed := trampoline_config.trampoline_force * trampoline_config.get_intensity_multiplier(intensity)
	return minf(maxf(speed, generator.movement.jump_force), generator.movement.max_launch_vertical_speed)
