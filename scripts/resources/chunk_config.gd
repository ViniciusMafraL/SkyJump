class_name ChunkConfig
extends Resource
## Parâmetros do streaming de chunks.

## Altura de cada chunk, em unidades do mundo.
@export var chunk_height: float = 50.0
## Chunks pré-gerados acima do chunk atual do jogador.
@export var chunks_ahead: int = 2
## Chunks mantidos em memória abaixo do chunk atual do jogador.
@export var chunks_behind: int = 1
