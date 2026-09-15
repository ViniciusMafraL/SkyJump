class_name RunOverride
extends RefCounted
## Parâmetros de uma partida definidos por outro modo (ex.: Desafio Diário). O GameManager os usa no
## lugar da seed aleatória, do tema sorteado e do ponto de partida padrão.

var world_seed: int = 0
## Tema fixo da partida. null = tema sorteado.
var theme_scene: PackedScene
## Ponto de partida (pés e ângulo), ex.: o último checkpoint coletado.
var spawn_height: float = 0.0
var spawn_angle: float = 0.0
## Se falso, a partida não altera o recorde do modo normal.
var records_enabled: bool = true
