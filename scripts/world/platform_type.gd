class_name PlatformType
extends RefCounted
## Tipos de plataforma conhecidos pelo jogo.
## Novos tipos: adicionar aqui, criar um PlatformConfig .tres e (opcionalmente) uma cena
## com script que estende Platform. O gerador procedural não precisa ser alterado.

enum Type {
	NORMAL,
	SMALL,
	LARGE,
	MOVING,
	## Impulsora / trampolim.
	BOOST,
	TEMPORARY,
	DANGER,
}
