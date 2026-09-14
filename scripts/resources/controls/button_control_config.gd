class_name ButtonControlConfig
extends Resource
## Botões esquerda / pulo / direita.

## Lado (px de interface) dos botões de movimento.
@export var button_size: float = 170.0
@export var jump_button_size: float = 200.0
@export_range(0.05, 1.0) var button_opacity: float = 0.5
@export_range(0.05, 1.0) var pressed_opacity: float = 0.9
## Distância das bordas da tela, dentro da área segura.
@export var screen_margin: float = 32.0
