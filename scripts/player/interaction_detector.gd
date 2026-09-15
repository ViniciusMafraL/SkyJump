class_name InteractionDetector
extends Node
## Liga o personagem aos objetos especiais ativos: bloqueio lateral (paredes) e atualizações
## de interação (tubos, portais, canhões...). Enquanto o personagem está preso a um objeto,
## apenas esse objeto recebe atualizações, evitando conflitos entre sistemas.

var platform_source: PlatformSource


func constrain_angle(player: PlayerController, from_angle: float, to_angle: float) -> float:
	if platform_source == null or player.is_captured():
		return to_angle
	for object in platform_source.get_active_objects():
		if is_instance_valid(object) and object.blocks_player():
			to_angle = object.constrain_player_angle(player, from_angle, to_angle)
	return to_angle


func process_objects(player: PlayerController, delta: float) -> void:
	var owner := player.get_capture_owner()
	if owner:
		if owner is GameplayObject:
			(owner as GameplayObject).update_player(player, delta)
		return
	if platform_source == null:
		return
	for object in platform_source.get_active_objects():
		if not is_instance_valid(object) or not object.wants_player_updates():
			continue
		object.update_player(player, delta)
		if player.is_captured():
			break
