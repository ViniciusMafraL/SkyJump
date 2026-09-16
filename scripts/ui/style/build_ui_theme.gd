extends SceneTree
## Regrava res://art/ui/sky_jump_theme.tres a partir do SkyJumpThemeBuilder.
##   godot --headless --path . --script res://scripts/ui/style/build_ui_theme.gd


func _initialize() -> void:
	var builder: GDScript = load("res://scripts/ui/style/sky_jump_theme_builder.gd")
	var error: Error = builder.call(&"save")
	print("UI theme saved: %s (%s)" % [builder.get(&"THEME_PATH"), error_string(error)])
	quit(0 if error == OK else 1)
