class_name SafeAreaOffsets
extends Control
## Mantém este elemento dentro da área segura do aparelho (notch, câmera, bordas arredondadas).
## Soma as margens de área segura aos offsets definidos na cena, respeitando as âncoras:
## um botão preso no canto superior esquerdo desce/anda para dentro; um painel em tela cheia encolhe.

@export_range(0.0, 0.5, 0.01) var max_safe_margin_ratio: float = 0.25

var _base_offsets: Array[float] = []


func _ready() -> void:
	_base_offsets = [offset_left, offset_top, offset_right, offset_bottom]
	get_viewport().size_changed.connect(apply_safe_area)
	apply_safe_area()


func apply_safe_area() -> void:
	var margins := SafeAreaMargins.compute(get_viewport_rect().size, max_safe_margin_ratio)
	offset_left = _base_offsets[0] + margins[0] * (1.0 - anchor_left) - margins[2] * anchor_left
	offset_right = _base_offsets[2] + margins[0] * (1.0 - anchor_right) - margins[2] * anchor_right
	offset_top = _base_offsets[1] + margins[1] * (1.0 - anchor_top) - margins[3] * anchor_top
	offset_bottom = _base_offsets[3] + margins[1] * (1.0 - anchor_bottom) - margins[3] * anchor_bottom
