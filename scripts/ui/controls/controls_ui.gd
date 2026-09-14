class_name ControlsUI
extends Control
## Camada visual dos controles: área de arraste da câmera, toque invisível, botões,
## indicador de inclinação e debug. Não gera comandos de gameplay: os ControlSchemes leem daqui.

## Limite das margens de área segura, em fração do tamanho da tela.
@export_range(0.0, 0.5) var max_safe_margin_ratio: float = 0.25

@onready var camera_drag_area: TouchDragArea = $CameraDragArea
@onready var touch_ui: TouchControlUI = $TouchUI
@onready var button_ui: ButtonControlUI = $SafeArea/ButtonUI
@onready var _safe_area: Control = $SafeArea
@onready var _gyro_indicator: Range = $SafeArea/GyroIndicator
@onready var _debug_label: Label = $SafeArea/DebugLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	camera_drag_area.excluded_controls = button_ui.get_buttons()
	# Tudo começa oculto; o ControlManager ativa apenas o necessário para o método selecionado.
	touch_ui.visible = false
	button_ui.visible = false
	_gyro_indicator.visible = false
	_debug_label.visible = false
	get_viewport().size_changed.connect(_apply_safe_area)
	_apply_safe_area()


func set_gyro_indicator_visible(indicator_visible: bool) -> void:
	_gyro_indicator.visible = indicator_visible


func set_gyro_indicator_value(value: float) -> void:
	_gyro_indicator.value = value


func set_debug_visible(debug_visible: bool) -> void:
	_debug_label.visible = debug_visible


func set_debug_text(text: String) -> void:
	_debug_label.text = text


## Mantém botões e indicadores fora de entalhes/bordas arredondadas do aparelho.
func _apply_safe_area() -> void:
	var margins := SafeAreaMargins.compute(get_viewport_rect().size, max_safe_margin_ratio)
	_safe_area.offset_left = margins[0]
	_safe_area.offset_top = margins[1]
	_safe_area.offset_right = -margins[2]
	_safe_area.offset_bottom = -margins[3]
