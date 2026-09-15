class_name StreakBadge
extends HBoxContainer
## Sequência diária (🔥 7 DIAS) e, opcionalmente, a melhor sequência.

@export var icon_size: float = 40.0
@export var font_size: int = 30
@export var show_best: bool = true
@export var flame_color: Color = Color(1.0, 0.45, 0.15)
@export var outline_color: Color = Color(0.12, 0.1, 0.1)
@export var text_color: Color = Color.WHITE
@export var text_outline_color: Color = Color(0.05, 0.07, 0.12)

var _label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"separation", 8)
	alignment = BoxContainer.ALIGNMENT_CENTER
	var icon := PixelIcon.new()
	icon.icon = PixelIcon.Icon.FLAME
	icon.custom_minimum_size = Vector2(icon_size, icon_size)
	icon.set_colors(flame_color, outline_color)
	add_child(icon)
	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", font_size)
	_label.add_theme_color_override(&"font_color", text_color)
	_label.add_theme_color_override(&"font_outline_color", text_outline_color)
	_label.add_theme_constant_override(&"outline_size", 8)
	add_child(_label)
	var streak := DailyChallenge.get_streak()
	_update(streak.x, streak.y)
	DailyChallenge.streak_changed.connect(_update)


func get_value_text() -> String:
	return _label.text


func _update(current: int, best: int) -> void:
	_label.text = "%d %s" % [current, "DIA" if current == 1 else "DIAS"]
	if show_best:
		_label.text += "  (MELHOR %d)" % best
