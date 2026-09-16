class_name CurrencyBar
extends HBoxContainer
## Contadores de Bronze, Prata e Estrelas lado a lado (menu, calendário e HUD do Daily).

@export var icon_size: float = 46.0
@export var label_variation: StringName = &"Counter"
@export var spacing: int = 26

var _counters: Array[CurrencyCounter] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_constant_override(&"separation", spacing)
	for currency: CurrencyWallet.Currency in CurrencyWallet.Currency.values():
		var counter := CurrencyCounter.new()
		counter.name = "%sCounter" % CurrencyWallet.name_of(currency).capitalize()
		counter.currency = currency
		counter.icon_size = icon_size
		counter.label_variation = label_variation
		add_child(counter)
		_counters.append(counter)


func get_counter(currency: CurrencyWallet.Currency) -> CurrencyCounter:
	for counter in _counters:
		if counter.currency == currency:
			return counter
	return null
