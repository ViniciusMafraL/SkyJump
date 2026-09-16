class_name StreakBadge
extends HBoxContainer
## Sequência diária: [chama] "N Streak". O valor vem do DailyChallenge.

@export var icon_size: float = 46.0
@export var label_variation: StringName = &"Counter"
@export var text_format: String = "%d Streak"

var _label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"separation", 8)
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(UiIcons.make_icon(UiIcons.STREAK, icon_size))
	_label = Label.new()
	_label.theme_type_variation = label_variation
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)
	var streak := DailyChallenge.get_streak()
	_update(streak.x, streak.y)
	DailyChallenge.streak_changed.connect(_update)


func get_value_text() -> String:
	return _label.text


func _update(current: int, _best: int) -> void:
	_label.text = text_format % current
