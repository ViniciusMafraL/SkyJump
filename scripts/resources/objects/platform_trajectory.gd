class_name PlatformTrajectory
extends Resource
## Trajetória de uma plataforma móvel no espaço desenrolado do cilindro
## (x = direita da tela, y = altura), relativa à posição inicial do objeto.
## Novas trajetórias (circular, curva, etc.) estendem esta classe.


func get_length() -> float:
	return 0.0


## Offset em `distance` unidades ao longo do caminho (0..get_length()).
func sample(_distance: float) -> Vector2:
	return Vector2.ZERO
