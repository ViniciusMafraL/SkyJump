@tool
class_name LevelTheme
extends Node3D
## Raiz de uma Theme Scene (Theme_Castle, Theme_Magma...): a "Theme Configuration" do tema.
## Contém SOMENTE o semicilindro de fundo (Background), a estrutura de iluminação (Lighting) e o
## ThemeData com cores, materiais de plataformas/objetos especiais e iluminação.
## Executar a cena sozinha (F6) abre uma visualização de teste com câmera e amostras de material.

@export var theme_data: ThemeData:
	set(value):
		if theme_data and theme_data.changed.is_connected(refresh):
			theme_data.changed.disconnect(refresh)
		theme_data = value
		if theme_data:
			theme_data.changed.connect(refresh)
		refresh()

@onready var background: ThemeBackground = $Background
## Luzes próprias do tema (futuras) ficam como filhos deste nó.
@onready var lighting: Node3D = $Lighting


func _ready() -> void:
	refresh()
	if not Engine.is_editor_hint() and get_tree().current_scene == self:
		add_child(ThemePreview.new())


func refresh() -> void:
	if is_node_ready() and theme_data:
		background.apply_theme(theme_data)
