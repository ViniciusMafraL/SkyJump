class_name PlatformSource
extends Node3D
## Fonte das plataformas e objetos ativos usados pela detecção de chão e de interação.
## Implementada pelo ChunkManager (jogo) e pelo TestPlatformSet (sala de testes).


func get_active_platforms() -> Array[Platform]:
	return []


## Objetos que reagem ao personagem fora do pouso (paredes, tubos, portais, canhões...).
func get_active_objects() -> Array[GameplayObject]:
	return []
