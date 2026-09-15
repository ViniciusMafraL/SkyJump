class_name TrampolineConfig
extends Resource
## Parâmetros do trampolim comum (impulso vertical).

## Velocidade vertical aplicada ao pousar (intensidade NORMAL).
@export var trampoline_force: float = 22.0
## Impulso extra ao longo da circunferência, na direção em que o personagem está virado.
@export var trampoline_horizontal_force: float = 0.0
## Tempo (s) após um lançamento em que o trampolim não lança de novo.
@export var trampoline_cooldown: float = 0.2
## Fração da velocidade de queda somada ao lançamento (0 = sempre a mesma força).
@export var trampoline_bounce_multiplier: float = 0.0

@export_group("Intensidade")
## Multiplicador da força para cada intensidade (TrampolinePlatform.Intensity).
@export var low_multiplier: float = 0.7
@export var normal_multiplier: float = 1.0
@export var high_multiplier: float = 1.4
@export var extreme_multiplier: float = 1.9


func get_launch_height(gravity: float) -> float:
	return trampoline_force * trampoline_force / (2.0 * gravity)


## Índices: 0 LOW, 1 NORMAL, 2 HIGH, 3 EXTREME. Outros valores = NORMAL.
func get_intensity_multiplier(intensity: int) -> float:
	match intensity:
		0:
			return low_multiplier
		2:
			return high_multiplier
		3:
			return extreme_multiplier
	return normal_multiplier
