class_name TrampolineConfig
extends Resource
## Parâmetros do trampolim (plataforma IMPULSORA).

## Velocidade vertical aplicada ao pousar.
@export var trampoline_force: float = 22.0
## Impulso extra ao longo da circunferência, na direção em que o personagem está virado.
@export var trampoline_horizontal_force: float = 0.0
## Tempo (s) após um lançamento em que o trampolim não lança de novo.
@export var trampoline_cooldown: float = 0.2
## Fração da velocidade de queda somada ao lançamento (0 = sempre a mesma força).
@export var trampoline_bounce_multiplier: float = 0.0


func get_launch_height(gravity: float) -> float:
	return trampoline_force * trampoline_force / (2.0 * gravity)
