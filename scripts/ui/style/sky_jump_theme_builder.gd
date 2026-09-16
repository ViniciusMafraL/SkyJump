class_name SkyJumpThemeBuilder
extends RefCounted
## Fonte única do tema global da UI (fonte Outfit ExtraBold, botões e textos da nova identidade).
## Gera res://art/ui/sky_jump_theme.tres, registrado em project.godot (gui/theme/custom):
##   godot --headless --path . --script res://scripts/ui/style/build_ui_theme.gd
## As cenas usam as variações (theme_type_variation) em vez de tamanhos e cores soltos.
## O Button base mantém o visual padrão da Godot (ferramentas DEV); o jogo usa as variações.

const THEME_PATH := "res://art/ui/sky_jump_theme.tres"
const FONT_PATH := "res://art/outfit/Outfit-ExtraBold.ttf"

const BUTTON_RADIUS := 18
const BUTTON_SHADOW := 8
const BUTTON_BORDER := 3

## Variações de botão sólido: nome -> cor da paleta.
static var BUTTON_COLORS := {
	&"ButtonYellow": SkyJumpColors.YELLOW,
	&"ButtonCoral": SkyJumpColors.CORAL,
	&"ButtonGreen": SkyJumpColors.GREEN,
	&"ButtonPurple": SkyJumpColors.PURPLE,
	&"ButtonBlue": SkyJumpColors.BLUE,
}

## Variações de Label: nome -> [tamanho, contorno, cor].
static var LABEL_STYLES := {
	&"TitleLarge": [118, 0, SkyJumpColors.WHITE],
	&"Title": [76, 16, SkyJumpColors.WHITE],
	&"Heading": [46, 12, SkyJumpColors.WHITE],
	&"Body": [32, 9, SkyJumpColors.WHITE],
	&"Caption": [24, 7, SkyJumpColors.WHITE],
	&"Subheading": [38, 10, SkyJumpColors.WHITE],
	&"Counter": [36, 10, SkyJumpColors.WHITE],
	&"InkLabel": [30, 0, SkyJumpColors.INK],
	&"InkCaption": [24, 0, SkyJumpColors.INK],
	&"InkCounter": [36, 0, SkyJumpColors.BLACK],
	&"AccentLabel": [30, 0, SkyJumpColors.RED],
}


static func build() -> Theme:
	var theme := Theme.new()
	theme.default_font = load(FONT_PATH)

	theme.set_color(&"font_color", &"Label", SkyJumpColors.WHITE)
	theme.set_color(&"font_outline_color", &"Label", SkyJumpColors.BLACK)
	for label_name: StringName in LABEL_STYLES:
		var style: Array = LABEL_STYLES[label_name]
		theme.set_type_variation(label_name, &"Label")
		theme.set_font_size(&"font_size", label_name, style[0])
		theme.set_constant(&"outline_size", label_name, style[1])
		theme.set_color(&"font_color", label_name, style[2])
		theme.set_color(&"font_outline_color", label_name, SkyJumpColors.BLACK)
	theme.set_color(&"font_shadow_color", &"TitleLarge", Color(SkyJumpColors.BLACK, 0.22))
	theme.set_constant(&"shadow_offset_y", &"TitleLarge", 7)
	theme.set_constant(&"shadow_offset_x", &"TitleLarge", 0)

	for button_name: StringName in BUTTON_COLORS:
		_add_solid_button(theme, button_name, BUTTON_COLORS[button_name], 52, 12)
	_add_solid_button(theme, &"ButtonSmall", SkyJumpColors.BLUE.lerp(SkyJumpColors.BLACK, 0.3), 24, 6)

	# Botão sem fundo (setas e fechar desenhados por UiGlyph).
	theme.set_type_variation(&"GlyphButton", &"Button")
	for state in [&"normal", &"hover", &"pressed", &"disabled", &"focus", &"hover_pressed"]:
		theme.set_stylebox(state, &"GlyphButton", StyleBoxEmpty.new())

	_add_panels(theme)
	_add_settings_controls(theme)
	return theme


static func save(path: String = THEME_PATH) -> Error:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	return ResourceSaver.save(build(), path)


static func _add_solid_button(theme: Theme, type_name: StringName, color: Color, font_size: int, outline: int) -> void:
	theme.set_type_variation(type_name, &"Button")
	theme.set_font_size(&"font_size", type_name, font_size)
	theme.set_constant(&"outline_size", type_name, outline)
	for color_name in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_hover_pressed_color", &"font_focus_color"]:
		theme.set_color(color_name, type_name, SkyJumpColors.WHITE)
	theme.set_color(&"font_disabled_color", type_name, Color(SkyJumpColors.WHITE, 0.85))
	theme.set_color(&"font_outline_color", type_name, SkyJumpColors.BLACK)
	theme.set_stylebox(&"normal", type_name, _button_box(color, BUTTON_SHADOW))
	theme.set_stylebox(&"hover", type_name, _button_box(SkyJumpColors.light(color), BUTTON_SHADOW))
	# Pressionado "afunda": a sombra inferior some e o conteúdo desce.
	theme.set_stylebox(&"pressed", type_name, _button_box(SkyJumpColors.shade(color, 0.08), BUTTON_BORDER, BUTTON_SHADOW - BUTTON_BORDER))
	theme.set_stylebox(&"hover_pressed", type_name, _button_box(SkyJumpColors.shade(color, 0.08), BUTTON_BORDER, BUTTON_SHADOW - BUTTON_BORDER))
	theme.set_stylebox(&"disabled", type_name, _button_box(SkyJumpColors.DISABLED, BUTTON_SHADOW))
	theme.set_stylebox(&"focus", type_name, StyleBoxEmpty.new())


static func _button_box(color: Color, bottom: int, sink: int = 0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = color
	box.border_color = SkyJumpColors.shade(color)
	box.set_border_width_all(BUTTON_BORDER)
	box.border_width_bottom = bottom
	box.set_corner_radius_all(BUTTON_RADIUS)
	box.content_margin_left = 24.0
	box.content_margin_right = 24.0
	box.content_margin_top = 8.0 + sink
	box.content_margin_bottom = 8.0 + bottom - sink
	box.expand_margin_top = -sink
	box.anti_aliasing = true
	return box


## Botão de opção: anel branco; marcado = amarelo com contorno e ponto pretos.
static func _radio_texture(side: int, checked: bool) -> ImageTexture:
	var image := Image.create(side, side, false, Image.FORMAT_RGBA8)
	var center := Vector2(side, side) * 0.5
	var radius := side * 0.5 - 1.0
	var ring := side * 0.13
	for y in side:
		for x in side:
			var distance := Vector2(x + 0.5, y + 0.5).distance_to(center)
			var coverage := clampf(radius - distance + 0.5, 0.0, 1.0)
			if coverage <= 0.0:
				continue
			var color: Color
			if checked:
				color = SkyJumpColors.BLACK if distance > radius - ring or distance < radius * 0.32 else SkyJumpColors.YELLOW
			else:
				color = SkyJumpColors.WHITE if distance > radius - ring else Color(SkyJumpColors.WHITE, 0.12)
			color.a *= coverage
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


## Interruptor: cápsula (verde ligada / translúcida desligada) com botão branco.
static func _toggle_texture(width: int, height: int, on: bool) -> ImageTexture:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var radius := height * 0.5 - 1.0
	var left := Vector2(radius + 1.0, height * 0.5)
	var right := Vector2(width - radius - 1.0, height * 0.5)
	var knob_center := right if on else left
	var knob_radius := radius - 5.0
	var track := SkyJumpColors.GREEN if on else Color(SkyJumpColors.WHITE, 0.22)
	for y in height:
		for x in width:
			var point := Vector2(x + 0.5, y + 0.5)
			var closest := Vector2(clampf(point.x, left.x, right.x), height * 0.5)
			var coverage := clampf(radius - point.distance_to(closest) + 0.5, 0.0, 1.0)
			if coverage <= 0.0:
				continue
			var color := track
			var knob := clampf(knob_radius - point.distance_to(knob_center) + 0.5, 0.0, 1.0)
			color = color.lerp(SkyJumpColors.WHITE, knob)
			color.a = lerpf(track.a, 1.0, knob) * coverage
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)


static func _add_panels(theme: Theme) -> void:
	theme.set_type_variation(&"CardPanel", &"PanelContainer")
	var card := StyleBoxFlat.new()
	card.bg_color = SkyJumpColors.CARD
	card.border_color = SkyJumpColors.BLACK
	card.set_border_width_all(4)
	card.set_corner_radius_all(28)
	card.set_content_margin_all(12.0)
	theme.set_stylebox(&"panel", &"CardPanel", card)

	theme.set_type_variation(&"PaperPanel", &"PanelContainer")
	var paper := StyleBoxFlat.new()
	paper.bg_color = SkyJumpColors.PAPER
	paper.set_corner_radius_all(22)
	paper.set_content_margin_all(0.0)
	theme.set_stylebox(&"panel", &"PaperPanel", paper)

	# Botões virtuais de controle (Panel).
	theme.set_type_variation(&"ControlPad", &"Panel")
	var pad := StyleBoxFlat.new()
	pad.bg_color = Color(SkyJumpColors.BLACK, 0.35)
	pad.border_color = Color(SkyJumpColors.WHITE, 0.55)
	pad.set_border_width_all(4)
	pad.set_corner_radius_all(44)
	pad.anti_aliasing = true
	theme.set_stylebox(&"panel", &"ControlPad", pad)

	# Balão escuro atrás de contadores e textos sobre o jogo.
	theme.set_type_variation(&"PillPanel", &"PanelContainer")
	var pill := StyleBoxFlat.new()
	pill.bg_color = Color(SkyJumpColors.BLACK, 0.35)
	pill.set_corner_radius_all(40)
	pill.content_margin_left = 18.0
	pill.content_margin_right = 18.0
	pill.content_margin_top = 6.0
	pill.content_margin_bottom = 6.0
	theme.set_stylebox(&"panel", &"PillPanel", pill)


## Variações do painel de opções (CheckBox, CheckButton, HSlider), aplicadas pela janela "SettingsWindow".
static func _add_settings_controls(theme: Theme) -> void:
	for type_name in [&"SettingsCheckBox", &"SettingsCheckButton"]:
		theme.set_type_variation(type_name, &"CheckBox" if type_name == &"SettingsCheckBox" else &"CheckButton")
		theme.set_font_size(&"font_size", type_name, 28)
		for color_name in [&"font_color", &"font_hover_color", &"font_pressed_color", &"font_hover_pressed_color", &"font_focus_color"]:
			theme.set_color(color_name, type_name, SkyJumpColors.WHITE)
		theme.set_color(&"font_outline_color", type_name, SkyJumpColors.BLACK)
		theme.set_constant(&"outline_size", type_name, 6)
		theme.set_constant(&"h_separation", type_name, 14)
		theme.set_stylebox(&"focus", type_name, StyleBoxEmpty.new())
	var radio_on := _radio_texture(36, true)
	var radio_off := _radio_texture(36, false)
	for icon_name in [&"radio_checked", &"checked"]:
		theme.set_icon(icon_name, &"SettingsCheckBox", radio_on)
	for icon_name in [&"radio_unchecked", &"unchecked"]:
		theme.set_icon(icon_name, &"SettingsCheckBox", radio_off)
	theme.set_icon(&"checked", &"SettingsCheckButton", _toggle_texture(76, 42, true))
	theme.set_icon(&"unchecked", &"SettingsCheckButton", _toggle_texture(76, 42, false))

	theme.set_type_variation(&"SettingsSlider", &"HSlider")
	var track := StyleBoxFlat.new()
	track.bg_color = Color(SkyJumpColors.BLACK, 0.45)
	track.set_corner_radius_all(8)
	track.content_margin_top = 6.0
	track.content_margin_bottom = 6.0
	theme.set_stylebox(&"slider", &"SettingsSlider", track)
	var fill := track.duplicate() as StyleBoxFlat
	fill.bg_color = SkyJumpColors.YELLOW
	theme.set_stylebox(&"grabber_area", &"SettingsSlider", fill)
	theme.set_stylebox(&"grabber_area_highlight", &"SettingsSlider", fill)

	theme.set_type_variation(&"SettingsSeparator", &"HSeparator")
	var line := StyleBoxLine.new()
	line.color = Color(SkyJumpColors.WHITE, 0.25)
	line.thickness = 3
	theme.set_stylebox(&"separator", &"SettingsSeparator", line)
	theme.set_constant(&"separation", &"SettingsSeparator", 16)
