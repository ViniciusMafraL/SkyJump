class_name LinearTrajectory
extends PlatformTrajectory
## Linha reta entre a posição inicial e a final (horizontal, vertical ou diagonal).

@export var start_offset: Vector2 = Vector2.ZERO
@export var end_offset: Vector2 = Vector2(4.0, 0.0)


func get_length() -> float:
	return start_offset.distance_to(end_offset)


func sample(distance: float) -> Vector2:
	var length := get_length()
	if length <= 0.0:
		return start_offset
	return start_offset.lerp(end_offset, clampf(distance / length, 0.0, 1.0))
