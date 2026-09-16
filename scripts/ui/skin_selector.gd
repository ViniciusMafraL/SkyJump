class_name SkinSelector
extends VBoxContainer
## Interface de seleção de skin do menu: setas, preview 3D e nome. Os dados vêm do SkinManager
## e de cada PlayerSkin; nenhum nome de skin fica neste script.

@export var locked_text: String = "LOCKED"
@export var arrow_margin: float = 30.0

@onready var _previous_button: Button = %PreviousButton
@onready var _next_button: Button = %NextButton
@onready var _preview: CharacterPreview = %CharacterPreview
@onready var _name_label: Label = %SkinName
@onready var _status_label: Label = %SkinStatus


func _ready() -> void:
	SkinManager.reset_focus()
	UiGlyph.fill_button(_previous_button, UiGlyph.Glyph.ARROW_LEFT, arrow_margin)
	UiGlyph.fill_button(_next_button, UiGlyph.Glyph.ARROW_RIGHT, arrow_margin)
	_status_label.add_theme_color_override(&"font_color", SkyJumpColors.YELLOW)
	_previous_button.pressed.connect(show_previous)
	_next_button.pressed.connect(show_next)
	for button: Button in [_previous_button, _next_button]:
		UiFeedback.attach(button, 1.1, 0.85)
	_refresh(false)


func _exit_tree() -> void:
	# Uma skin bloqueada em foco nunca fica selecionada ao sair do menu.
	SkinManager.reset_focus()


func show_previous() -> void:
	SkinManager.previous_skin()
	_refresh(true)


func show_next() -> void:
	SkinManager.next_skin()
	_refresh(true)


func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or TransitionManager.is_input_locked():
		return
	if event.is_action_pressed("ui_left"):
		show_previous()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		show_next()
		get_viewport().set_input_as_handled()


func _refresh(animate: bool) -> void:
	var skin := SkinManager.get_focused_skin()
	if skin == null:
		_name_label.text = "-"
		_status_label.text = " "
		return
	var unlocked := SkinManager.is_unlocked(skin)
	_name_label.text = skin.get_display_name().to_upper()
	_status_label.text = " " if unlocked else locked_text
	_preview.show_skin(skin, animate)
	_preview.set_locked(not unlocked)
