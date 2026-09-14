class_name ControlConfig
extends Resource
## Configuração central dos controles. Os valores do .tres são os padrões;
## as escolhas do jogador são salvas localmente por ControlPreferences.

const SECTIONS := [&"touch", &"gyroscope", &"button"]

## touch_invisible, gyroscope ou buttons (scheme_id de um ControlScheme).
@export var selected_control_scheme: StringName = &"touch_invisible"

@export_group("Auto Jump")
@export var auto_jump_enabled: bool = true
## Espera (s) após aterrissar antes do pulo automático.
@export var auto_jump_delay: float = 0.05

@export_group("General")
@export var camera_control_enabled: bool = true
## No PC, o teclado simula os controles (apenas desenvolvimento).
@export var keyboard_fallback_enabled: bool = true
@export var show_control_debug: bool = false
@export var haptics_enabled: bool = true

@export_group("Schemes")
@export var touch_config: TouchControlConfig
@export var gyroscope_config: GyroscopeConfig
@export var button_config: ButtonControlConfig


func get_section(section: StringName) -> Resource:
	return get(String(section) + "_config")


## Cópia independente, inclusive das configurações de cada método.
func make_copy() -> ControlConfig:
	var copy: ControlConfig = duplicate()
	for section in SECTIONS:
		var source := get_section(section)
		copy.set(String(section) + "_config", source.duplicate() if source else null)
	return copy


## Copia valores preservando as referências deste objeto.
func copy_values_from(other: ControlConfig) -> void:
	ConfigValues.copy_values(other, self, true)
	for section in SECTIONS:
		var target := get_section(section)
		var source := other.get_section(section)
		if target and source:
			ConfigValues.copy_values(source, target)
