class_name LevelChunkData
extends RefCounted
## Dados de um chunk gerado. Não referencia nós nem assets visuais.

var index: int = 0
var start_height: float = 0.0
var end_height: float = 0.0
var chunk_seed: int = 0
var difficulty: DifficultyTier
var theme: ThemeData
var platforms: Array[PlatformData] = []
