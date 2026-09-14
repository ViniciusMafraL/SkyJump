class_name ControlScheme
extends Node
## Base de um método de controle: converte uma fonte (toque, sensor, botões) em PlayerInputState.
## Novo método = novo script que estende esta classe, adicionado como filho do ControlManager.

@export var scheme_id: StringName
@export var display_name: String

var manager: ControlManager
var is_active: bool = false


func _ready() -> void:
	set_process_unhandled_input(false)


func activate() -> void:
	is_active = true


func deactivate() -> void:
	is_active = false
	clear_state()


func clear_state() -> void:
	pass


func collect(_state: PlayerInputState, _delta: float) -> void:
	pass


func uses_auto_jump() -> bool:
	return true


func allows_camera_drag() -> bool:
	return true


## Se o teclado (fallback de desenvolvimento) pode somar movimento a este método.
func merges_keyboard_movement() -> bool:
	return true


func get_debug_lines() -> PackedStringArray:
	return PackedStringArray()
