class_name TubeExitPoint
extends Marker3D
## Ponto de saída do tubo: define posição, orientação/direção e velocidade de saída.
## Por padrão fica no fim da curva e usa os valores do TubeConfig; `use_own_values` permite
## que cada tubo tenha a própria saída sem alterar o config compartilhado.

## Deslocamento a partir do fim da curva (x = direita do objeto, y = cima).
@export var offset: Vector2 = Vector2.ZERO
## Usa direção, velocidade e preservação definidas aqui em vez do TubeConfig.
@export var use_own_values: bool = false
## Direção de saída (graus: 0 = direita do objeto, 90 = cima).
@export_range(-180.0, 180.0, 1.0) var direction_degrees: float = 80.0
@export var exit_speed: float = 12.0
@export var preserve_velocity: bool = false
