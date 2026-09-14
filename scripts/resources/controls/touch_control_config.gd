class_name TouchControlConfig
extends Resource
## Toque invisível: a tela é dividida em área esquerda e área direita.

## Intensidade do movimento (0..1). Valores baixos = movimento mais lento.
@export_range(0.1, 1.0) var touch_sensitivity: float = 1.0
## Fração da largura da tela que pertence à área esquerda.
@export_range(0.2, 0.8) var split_ratio: float = 0.5

@export_group("Hint")
@export var control_hint_enabled: bool = true
## Tempo (s) que a dica "< >" fica visível.
@export var control_hint_timeout: float = 2.5
## Tempo (s) sem tocar na tela para mostrar a dica novamente. 0 = não repetir.
@export var control_hint_repeat_delay: float = 6.0

@export_group("Feedback")
@export var feedback_enabled: bool = true
@export_range(0.0, 1.0) var feedback_opacity: float = 0.12
