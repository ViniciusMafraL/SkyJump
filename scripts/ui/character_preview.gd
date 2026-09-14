class_name CharacterPreview
extends Control
## Preview 3D isolado do personagem no menu: mundo, câmera e luzes próprios, sem física nem gameplay.
## Mostra uma PlayerSkin com rotação lenta opcional e animação curta de troca.
## O SubViewport renderiza na resolução real de pixels da tela (nítido em celulares grandes)
## e a imagem é exibida no tamanho do layout.

@export_group("Câmera")
@export var preview_camera_distance: float = 2.2
@export var preview_camera_height: float = 0.75
## Altura do ponto para onde a câmera olha (centro da bola).
@export var preview_look_height: float = 0.34
@export_range(10.0, 120.0, 0.5) var preview_fov: float = 35.0

@export_group("Resolução")
## Multiplicador da resolução de render (1 = pixels reais da tela).
@export_range(0.25, 2.0, 0.05) var render_scale: float = 1.0
## Limite do maior lado do render, para não pesar em tablets e telas muito densas.
@export var max_render_size: int = 1440

@export_group("Rotação")
@export var auto_rotate: bool = true
@export var rotation_speed_degrees: float = 35.0

@export_group("Troca de skin")
@export var swap_animation_enabled: bool = true
@export_range(0.05, 1.0, 0.01, "suffix:s") var swap_duration: float = 0.2
@export_range(0.0, 1.0, 0.01) var swap_min_scale: float = 0.2
@export var locked_modulate: Color = Color(0.3, 0.3, 0.36)

var _tween: Tween
var _shown_skin: PlayerSkin

@onready var _display: TextureRect = %Display
@onready var _sub_viewport: SubViewport = %SubViewport
@onready var _camera: Camera3D = %PreviewCamera
@onready var _pivot: Node3D = %Pivot
@onready var _appearance: PlayerAppearance = %Appearance


func _ready() -> void:
	_display.texture = _sub_viewport.get_texture()
	resized.connect(_update_render_size)
	get_viewport().size_changed.connect(_update_render_size)
	_update_render_size()
	_update_camera()


func _process(delta: float) -> void:
	if auto_rotate:
		_pivot.rotate_y(deg_to_rad(rotation_speed_degrees) * delta)


func get_appearance() -> PlayerAppearance:
	return _appearance


func get_shown_skin() -> PlayerSkin:
	return _shown_skin


func get_render_size() -> Vector2i:
	return _sub_viewport.size


## Troca a skin exibida. Com animação: encolhe, troca o material/modelo e cresce. Não bloqueia o menu.
func show_skin(new_skin: PlayerSkin, animate: bool = true) -> void:
	if new_skin == null or new_skin == _shown_skin:
		return
	_shown_skin = new_skin
	if _tween and _tween.is_valid():
		_tween.kill()
	if not animate or not swap_animation_enabled or _appearance.current_skin == null:
		_apply(new_skin)
		_appearance.scale = Vector3.ONE * new_skin.preview_scale
		return
	var half := swap_duration * 0.5
	_tween = create_tween()
	_tween.tween_property(_appearance, "scale", _appearance.scale * swap_min_scale, half) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_apply.bind(new_skin))
	_tween.tween_property(_appearance, "scale", Vector3.ONE * new_skin.preview_scale, half) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func set_locked(locked: bool) -> void:
	modulate = locked_modulate if locked else Color.WHITE


func _apply(new_skin: PlayerSkin) -> void:
	_appearance.apply_skin(new_skin)
	_appearance.rotation_degrees = new_skin.preview_rotation_degrees


## Tamanho do layout convertido para pixels reais (inclui a escala automática da tela).
func _update_render_size() -> void:
	# Escala do layout (canvas) x escala automática da tela (stretch do viewport).
	var screen_scale := get_global_transform_with_canvas().get_scale().abs() * get_viewport().get_final_transform().get_scale().abs()
	var pixels := size * screen_scale * render_scale
	var longest := maxf(pixels.x, pixels.y)
	if longest > float(max_render_size):
		pixels *= float(max_render_size) / longest
	_sub_viewport.size = Vector2i(maxi(roundi(pixels.x), 1), maxi(roundi(pixels.y), 1))


func _update_camera() -> void:
	_camera.fov = preview_fov
	var camera_position := Vector3(0.0, preview_camera_height, preview_camera_distance)
	var target := Vector3(0.0, preview_look_height, 0.0)
	_camera.transform = Transform3D(Basis.looking_at(target - camera_position), camera_position)
