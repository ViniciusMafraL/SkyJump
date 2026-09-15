class_name StarCounter
extends HBoxContainer
## Total de estrelas do jogador (⭐ 247). Atualiza na hora em que uma estrela é ganha.

@export var icon_size: float = 44.0
@export var font_size: int = 36
@export var star_color: Color = Color(1.0, 0.8, 0.15)
@export var outline_color: Color = Color(0.12, 0.1, 0.1)
@export var text_color: Color = Color.WHITE
@export var text_outline_color: Color = Color(0.05, 0.07, 0.12)

var _icon: PixelIcon
var _label: Label
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"separation", 8)
	alignment = BoxContainer.ALIGNMENT_CENTER
	_icon = PixelIcon.new()
	_icon.icon = PixelIcon.Icon.STAR
	_icon.custom_minimum_size = Vector2(icon_size, icon_size)
	_icon.set_colors(star_color, outline_color)
	add_child(_icon)
	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", font_size)
	_label.add_theme_color_override(&"font_color", text_color)
	_label.add_theme_color_override(&"font_outline_color", text_outline_color)
	_label.add_theme_constant_override(&"outline_size", 8)
	add_child(_label)
	_label.text = str(DailyChallenge.get_stars())
	DailyChallenge.stars_changed.connect(_on_stars_changed)


func get_value_text() -> String:
	return _label.text


func _on_stars_changed(total: int, delta: int, _reason: StringName) -> void:
	_label.text = str(total)
	if delta <= 0:
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_icon.pivot_offset = _icon.size * 0.5
	_icon.scale = Vector2.ONE * 1.5
	_tween = create_tween()
	_tween.tween_property(_icon, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
