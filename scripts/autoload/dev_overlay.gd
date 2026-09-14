extends CanvasLayer
## Contador de FPS discreto no topo da tela, acima de tudo (inclusive transições).
## Só existe em builds exportadas com a feature tag "develop"; nas demais se remove ao iniciar.

const DEVELOP_FEATURE := "develop"

## Intervalo entre atualizações do texto, em segundos.
@export var refresh_interval: float = 0.25
@export var good_fps: int = 55
@export var ok_fps: int = 30
@export var good_color: Color = Color(0.45, 1.0, 0.5)
@export var ok_color: Color = Color(1.0, 0.85, 0.3)
@export var bad_color: Color = Color(1.0, 0.4, 0.35)

@onready var _label: Label = %FpsLabel

var _next_refresh_msec: int = 0


func _ready() -> void:
	if not OS.has_feature(DEVELOP_FEATURE):
		queue_free()
		return


func _process(_delta: float) -> void:
	# Relógio real: continua atualizando com o jogo pausado ou com time_scale alterado.
	var now := Time.get_ticks_msec()
	if now < _next_refresh_msec:
		return
	_next_refresh_msec = now + int(refresh_interval * 1000.0)
	var fps := Engine.get_frames_per_second()
	_label.text = "%d FPS" % fps
	_label.add_theme_color_override("font_color", _color_for(fps))


func _color_for(fps: float) -> Color:
	if fps >= good_fps:
		return good_color
	if fps >= ok_fps:
		return ok_color
	return bad_color
