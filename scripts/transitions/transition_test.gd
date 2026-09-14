class_name TransitionTest
extends Control
## Ferramenta de desenvolvimento: executa cada preset e mostra progresso, duração e estado.
## Os controles ficam em uma camada acima do overlay para continuarem clicáveis com a tela coberta.

@export var presets: Array[TransitionConfig] = []
@export_file("*.tscn") var exit_scene_path: String = "res://scenes/ui/main_menu.tscn"
@export var stage_colors: Array[Color] = [Color(0.16, 0.55, 0.62), Color(0.85, 0.45, 0.2)]

var _selected: TransitionConfig
var _stage_index: int = 0

@onready var _stage_background: ColorRect = %StageBackground
@onready var _stage_label: Label = %StageLabel
@onready var _info_label: Label = %InfoLabel
@onready var _preset_grid: GridContainer = %PresetGrid
@onready var _out_button: Button = %OutButton
@onready var _in_button: Button = %InButton
@onready var _play_button: Button = %PlayButton
@onready var _force_button: Button = %ForceButton
@onready var _debug_toggle: CheckButton = %DebugToggle
@onready var _exit_button: Button = %ExitButton


func _ready() -> void:
	var group := ButtonGroup.new()
	for preset in presets:
		var button := Button.new()
		button.text = preset.get_display_name().trim_suffix("Transition")
		button.toggle_mode = true
		button.button_group = group
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size.y = 64.0
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_select.bind(preset))
		_preset_grid.add_child(button)
		if _selected == null:
			button.button_pressed = true
			_select(preset)
	_out_button.pressed.connect(func() -> void: TransitionManager.play_out(_selected))
	_in_button.pressed.connect(func() -> void: TransitionManager.play_in(_selected))
	_play_button.pressed.connect(func() -> void: TransitionManager.play(_selected))
	_force_button.pressed.connect(func() -> void: TransitionManager.force_transition(_selected))
	_debug_toggle.button_pressed = TransitionManager.debug_transitions
	_debug_toggle.toggled.connect(func(pressed: bool) -> void: TransitionManager.debug_transitions = pressed)
	_exit_button.pressed.connect(_on_exit_pressed)
	TransitionManager.screen_covered.connect(_on_screen_covered)
	_apply_stage()


func _process(_delta: float) -> void:
	var manager_config: TransitionConfig = TransitionManager.current_config
	_info_label.text = "Preset: %s\nDuração: saída %.2fs | espera %.2fs | entrada %.2fs\nProgresso: %.2f\nEstado: %s\nÚltima transição: %s" % [
		_selected.get_display_name() if _selected else "-",
		_selected.get_out_duration() if _selected else 0.0,
		_selected.get_hold_duration() if _selected else 0.0,
		_selected.get_in_duration() if _selected else 0.0,
		TransitionManager.get_progress(),
		TransitionManager.State.keys()[TransitionManager.state],
		manager_config.get_display_name() if manager_config else "-",
	]


func _select(preset: TransitionConfig) -> void:
	_selected = preset


func _on_exit_pressed() -> void:
	# Com a tela coberta por OUT, libera antes de sair.
	if TransitionManager.state == TransitionManager.State.COVERED:
		TransitionManager.cancel()
	TransitionManager.change_scene_for_event(exit_scene_path, TransitionEvent.SCREEN_CHANGE)


## Alterna entre "Tela A" e "Tela B" sempre que a tela fica coberta, como numa troca real.
func _on_screen_covered(_config: TransitionConfig) -> void:
	_stage_index = (_stage_index + 1) % stage_colors.size()
	_apply_stage()


func _apply_stage() -> void:
	_stage_background.color = stage_colors[_stage_index]
	_stage_label.text = "TELA %s" % char(65 + _stage_index)
