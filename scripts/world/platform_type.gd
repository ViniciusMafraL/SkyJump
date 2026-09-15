class_name PlatformType
extends RefCounted
## Identificação única dos tipos de plataforma e objetos especiais do jogo.
## Os valores inteiros ficam salvos nos .tres: novos tipos entram sempre no fim.
## Novos tipos: adicionar aqui, criar um PlatformConfig .tres e (opcionalmente) uma cena
## com script que estende Platform/GameplayObject. O gerador procedural não precisa ser alterado.

enum Type {
	NORMAL,
	SMALL,
	LARGE,
	MOVING,
	## Trampolim comum (impulso vertical).
	TRAMPOLINE,
	## Plataforma bolha / temporária.
	BUBBLE,
	DANGER,
	WALL = 7,
	DIAGONAL_TRAMPOLINE = 8,
	TUBE = 9,
	## 10 era a plataforma deslizante (removida): o valor fica livre para não alterar os .tres salvos.
	VINE = 11,
	STAIR = 12,
	PORTAL = 13,
	TNT = 14,
	CANNON = 15,
}


## Nome do tipo pelo valor (os valores não são sequenciais: não usar Type.keys()[valor]).
static func name_of(type: int) -> String:
	var key = Type.find_key(type)
	return String(key) if key != null else str(type)
