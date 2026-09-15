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
	WALL,
	DIAGONAL_TRAMPOLINE,
	TUBE,
	SLIDING,
	VINE,
	STAIR,
	PORTAL,
	TNT,
	CANNON,
}
