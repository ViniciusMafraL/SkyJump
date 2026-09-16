class_name StarRewardFeedback
extends Control
## Feedback de moeda ganha ("+1 [ícone]" com legenda), usado no login diário e nos checkpoints.
## Recompensas que chegam juntas entram numa fila.

@export var icon_size: float = 76.0
## Altura (fração da tela) onde a mensagem para.
@export_range(0.0, 1.0, 0.01) var vertical_anchor: float = 0.3
@export var rise: float = 50.0
@export var hold_time: float = 1.0

var _box: VBoxContainer
var _amount_label: Label
var _icon: TextureRect
var _caption_label: Label
var _queue: Array[Array] = []
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box = VBoxContainer.new()
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_box.add_theme_constant_override(&"separation", 0)
	add_child(_box)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 10)
	_box.add_child(row)
	_amount_label = Label.new()
	_amount_label.theme_type_variation = &"Title"
	_amount_label.add_theme_color_override(&"font_color", SkyJumpColors.YELLOW)
	row.add_child(_amount_label)
	_icon = UiIcons.make_icon(UiIcons.STAR, icon_size)
	row.add_child(_icon)
	_caption_label = Label.new()
	_caption_label.theme_type_variation = &"Heading"
	_caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_box.add_child(_caption_label)
	_box.modulate.a = 0.0


## `icon` = textura da moeda (padrão: estrela).
func show_reward(amount: int, caption: String = "", icon: Texture2D = null) -> void:
	if amount <= 0:
		return
	_queue.append([amount, caption, icon if icon else UiIcons.STAR])
	if not is_playing():
		_play_next()


func is_playing() -> bool:
	return _tween != null and _tween.is_valid()


func get_last_text() -> String:
	return "%s %s" % [_amount_label.text, _caption_label.text]


func get_last_icon() -> Texture2D:
	return _icon.texture


func _play_next() -> void:
	if _queue.is_empty():
		return
	var item: Array = _queue.pop_front()
	_amount_label.text = "+%d" % item[0]
	_caption_label.text = item[1]
	_caption_label.visible = not String(item[1]).is_empty()
	_icon.texture = item[2]
	_box.size = _box.get_combined_minimum_size()
	var target := Vector2((size.x - _box.size.x) * 0.5, size.y * vertical_anchor)
	_box.position = target + Vector2(0.0, rise)
	_box.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(_box, "modulate:a", 1.0, 0.18)
	_tween.parallel().tween_property(_box, "position", target, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(hold_time)
	_tween.tween_property(_box, "modulate:a", 0.0, 0.3)
	_tween.tween_callback(_play_next)
