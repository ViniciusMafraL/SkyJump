class_name UiIcons
extends RefCounted
## Texturas de ícones da UI (art/icons) e ajuda para exibi-los preservando proporção e transparência.

static var STAR: Texture2D = load("res://art/icons/icon-star.png")
static var BRONZE: Texture2D = load("res://art/icons/icon-bronze.png")
static var SILVER: Texture2D = load("res://art/icons/icon-prata.png")
static var STREAK: Texture2D = load("res://art/icons/icon-strike.png")
static var BACKGROUND_AGENDA: Texture2D = load("res://art/backgrounds/BackgroundAgenda.png")


static func for_currency(currency: CurrencyWallet.Currency) -> Texture2D:
	match currency:
		CurrencyWallet.Currency.BRONZE:
			return BRONZE
		CurrencyWallet.Currency.SILVER:
			return SILVER
	return STAR


## TextureRect quadrado que encaixa o ícone sem distorcer.
static func make_icon(texture: Texture2D, side: float) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.custom_minimum_size = Vector2(side, side)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon


## Retângulo onde a textura cabe dentro de `area` mantendo a proporção (para _draw).
static func fit_rect(texture: Texture2D, area: Rect2) -> Rect2:
	var texture_size := texture.get_size()
	var scale_factor := minf(area.size.x / texture_size.x, area.size.y / texture_size.y)
	var fitted := texture_size * scale_factor
	return Rect2(area.get_center() - fitted * 0.5, fitted)
