class_name ProgressBarMarker
extends Control
## Base dos marcadores da barra. A origem do nó fica sobre a linha; o desenho é feito ao redor dela.
## A posição vertical é uma proporção (0 = base, 1 = topo) suavizada, nunca aplicada de uma vez.

var config: ProgressBarConfig
var target_ratio: float = 0.0
var display_ratio: float = 0.0

var _has_target: bool = false


func setup(bar_config: ProgressBarConfig) -> void:
	config = bar_config
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_target(ratio: float, snap: bool = false) -> void:
	target_ratio = clampf(ratio, 0.0, 1.0)
	if snap or not _has_target:
		display_ratio = target_ratio
		_has_target = true


func snap() -> void:
	display_ratio = target_ratio


func advance(delta: float) -> void:
	display_ratio = lerpf(display_ratio, target_ratio, 1.0 - exp(-config.animation_speed * delta))


func _process(_delta: float) -> void:
	queue_redraw()


func _draw_text(text: String, position_2d: Vector2, font_size: int, color: Color) -> void:
	var font := config.get_font()
	if config.outline_size > 0:
		draw_string_outline(font, position_2d, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, config.outline_size, config.outline_color)
	draw_string(font, position_2d, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
