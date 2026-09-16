class_name CurrencyCounter
extends HBoxContainer
## Contador de uma moeda do jogador: [ícone] [valor]. O valor vem do DailyChallenge e muda na hora
## em que a moeda é ganha (com um "pulo" do ícone).

@export var currency: CurrencyWallet.Currency = CurrencyWallet.Currency.STAR
@export var icon_size: float = 46.0
@export var label_variation: StringName = &"Counter"

var _icon: TextureRect
var _label: Label
var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"separation", 6)
	alignment = BoxContainer.ALIGNMENT_CENTER
	_icon = UiIcons.make_icon(UiIcons.for_currency(currency), icon_size)
	add_child(_icon)
	_label = Label.new()
	_label.theme_type_variation = label_variation
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(_label)
	_label.text = str(DailyChallenge.get_currency(currency))
	DailyChallenge.currency_changed.connect(_on_currency_changed)


func get_value_text() -> String:
	return _label.text


func _on_currency_changed(changed: int, total: int, delta: int, _reason: StringName) -> void:
	if changed != currency:
		return
	_label.text = str(total)
	if delta <= 0 or not is_inside_tree():
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_icon.pivot_offset = _icon.size * 0.5
	_icon.scale = Vector2.ONE * 1.5
	_tween = create_tween()
	_tween.tween_property(_icon, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
