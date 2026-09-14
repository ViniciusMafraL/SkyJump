class_name TransitionOverlay
extends CanvasLayer
## Componente visual das transições: um ColorRect em tela cheia com o shader, acima de toda a UI.
## Só traduz um TransitionConfig em parâmetros do shader; não decide quando nada acontece.

var progress: float = 0.0

var _material: ShaderMaterial

@onready var _cover: ColorRect = %Cover
@onready var _input_blocker: Control = %InputBlocker
@onready var _debug_panel: Control = %DebugPanel
@onready var _debug_label: Label = %DebugLabel


func _ready() -> void:
	_material = _cover.material as ShaderMaterial
	_cover.resized.connect(_update_resolution)
	_update_resolution()
	set_progress(0.0)
	set_input_blocked(false)
	set_debug_visible(false)


## in_phase = revelando a tela (a entrada pode espelhar a direção da saída).
func apply_config(config: TransitionConfig, in_phase: bool) -> void:
	var gradient_inverted := config.invert != (in_phase and config.mirror_on_in)
	_material.set_shader_parameter("mode", config.transition_type)
	_material.set_shader_parameter("base_color", config.base_color)
	_material.set_shader_parameter("intensity", config.intensity)
	_material.set_shader_parameter("width", config.width)
	_material.set_shader_parameter("feathering", config.feathering)
	_material.set_shader_parameter("invert", gradient_inverted)
	_material.set_shader_parameter("direction", config.get_direction_vector())
	_material.set_shader_parameter("center", config.center)
	_material.set_shader_parameter("use_gradient_texture", config.gradient_texture != null)
	_material.set_shader_parameter("gradient_texture", config.gradient_texture)
	_material.set_shader_parameter("gradient_keep_aspect", config.gradient_keep_aspect)
	_material.set_shader_parameter("use_shape_texture", config.shape_texture != null)
	_material.set_shader_parameter("shape_texture", config.shape_texture)
	_material.set_shader_parameter("pattern_scale", config.pattern_scale)
	_material.set_shader_parameter("pattern_rotation", deg_to_rad(config.pattern_rotation_degrees))
	_material.set_shader_parameter("pattern_offset", config.pattern_offset)
	_material.set_shader_parameter("pattern_scroll", config.pattern_scroll)


func set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	_material.set_shader_parameter("progress", progress)
	# Invisível quando não cobre nada: nenhum custo de GPU fora das transições.
	_cover.visible = progress > 0.0


func set_pattern_time(seconds: float) -> void:
	_material.set_shader_parameter("pattern_time", seconds)


func set_input_blocked(blocked: bool) -> void:
	_input_blocker.visible = blocked


func is_input_blocked() -> bool:
	return _input_blocker.visible


func set_debug_visible(debug_visible: bool) -> void:
	_debug_panel.visible = debug_visible


func set_debug_text(text: String) -> void:
	_debug_label.text = text


func _update_resolution() -> void:
	_material.set_shader_parameter("node_resolution", _cover.size)
