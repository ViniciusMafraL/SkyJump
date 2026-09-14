class_name PlayerVisual
extends Node3D
## Animações visuais do personagem (direção e derrota). O modelo, o material e os efeitos
## vêm da skin e ficam no filho Appearance (PlayerAppearance), que também mantém o personagem
## fora do pós-processamento de contorno.

@export var defeat_effect_duration: float = 0.8
@export var defeat_scale: float = 0.3

var _tween: Tween


## direction > 0 = direita da tela, que corresponde ao eixo local -Z do Player.
func set_facing(direction: float) -> void:
	rotation.y = 0.0 if direction > 0.0 else PI


func play_defeat() -> void:
	_kill_tween()
	_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_tween.set_parallel(true)
	_tween.tween_property(self, "scale", Vector3.ONE * defeat_scale, defeat_effect_duration)
	_tween.tween_property(self, "rotation:y", rotation.y + TAU * 2.0, defeat_effect_duration)


func reset_visual() -> void:
	_kill_tween()
	scale = Vector3.ONE
	rotation = Vector3.ZERO


func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null
