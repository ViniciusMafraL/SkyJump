class_name TransitionConfig
extends Resource
## Dados de uma transição de tela (um .tres por preset).
## Aparência = gradiente (ordem em que cada ponto da tela é coberto) + padrão (forma que cresce
## dentro de cada célula) + progresso. O shader desenha; o TransitionManager controla o tempo.

enum Type {
	## A tela inteira escurece por igual.
	FADE,
	## Uma borda atravessa a tela a partir de uma direção.
	DIRECTIONAL,
	## Círculo sólido que cresce a partir do centro (ou fecha para o centro com invert).
	CIRCLE,
	## Formas do padrão crescem do centro para as bordas.
	RADIAL,
	## Formas do padrão crescem seguindo o gradiente (direção ou textura).
	PATTERN,
	## Cada ponto some em um momento sorteado pelo ruído do padrão.
	DISSOLVE,
}

enum Direction { LEFT, RIGHT, TOP, BOTTOM, TOP_LEFT, TOP_RIGHT, BOTTOM_LEFT, BOTTOM_RIGHT, CUSTOM }

enum Easing { LINEAR, EASE_IN, EASE_OUT, EASE_IN_OUT }

## Nome exibido no debug. Vazio = nome do arquivo.
@export var display_name: String = ""
@export var transition_type: Type = Type.FADE

@export_group("Cor")
@export var base_color: Color = Color.BLACK
## Opacidade máxima da cobertura. Abaixo de 1 a tela nunca fica totalmente escondida.
@export_range(0.0, 1.0, 0.01) var intensity: float = 1.0

@export_group("Tempo")
## Duração da saída (cobrir a tela), em segundos.
@export_range(0.0, 5.0, 0.01, "suffix:s") var duration: float = 0.35
## Duração da entrada (revelar a tela). Negativo = igual a duration.
@export_range(-1.0, 5.0, 0.01, "suffix:s") var in_duration: float = -1.0
## Tempo com a tela totalmente coberta antes de revelar.
@export_range(0.0, 5.0, 0.01, "suffix:s") var hold_duration: float = 0.0
## Multiplicador de velocidade aplicado a todas as durações.
@export_range(0.1, 5.0, 0.05) var speed: float = 1.0
@export var easing: Easing = Easing.EASE_IN_OUT
## Curva usada pelo easing (ignorada em LINEAR).
@export var curve: Tween.TransitionType = Tween.TRANS_SINE

@export_group("Borda")
## Largura da região intermediária: baixo = transição seca, alto = cobertura espalhada.
@export_range(0.001, 1.0, 0.001) var width: float = 0.2
## Suavidade da borda de cada forma: baixo = borda definida, alto = borda suave.
@export_range(0.0, 1.0, 0.01) var feathering: float = 0.05

@export_group("Direção")
## Lado por onde a cobertura entra (DIRECTIONAL e PATTERN sem textura de gradiente).
@export var direction: Direction = Direction.LEFT
## Usado quando direction = CUSTOM. Coordenadas de tela: +X direita, +Y para baixo.
@export var custom_direction: Vector2 = Vector2.RIGHT
## Centro de CIRCLE, RADIAL e da rotação do padrão (0..1 da tela).
@export var center: Vector2 = Vector2(0.5, 0.5)
## Inverte a ordem de cobertura (ex.: CIRCLE fecha para o centro em vez de abrir).
@export var invert: bool = false
## Na entrada, inverte de novo: a borda continua no mesmo sentido em vez de voltar.
@export var mirror_on_in: bool = false

@export_group("Texturas")
## Gradiente em tons de cinza (preto = coberto primeiro). Vazio = gradiente do tipo.
@export var gradient_texture: Texture2D
## Mantém a proporção da textura de gradiente em qualquer tela (evita círculos ovais).
@export var gradient_keep_aspect: bool = true
## Forma de cada célula em tons de cinza (preto = coberto primeiro). Vazio = círculo (ou blocos no DISSOLVE).
@export var shape_texture: Texture2D

@export_group("Padrão")
## Quantidade de células no menor lado da tela.
@export_range(0.1, 64.0, 0.1) var pattern_scale: float = 8.0
@export_range(-360.0, 360.0, 0.5, "suffix:°") var pattern_rotation_degrees: float = 0.0
## Deslocamento fixo do padrão, em células.
@export var pattern_offset: Vector2 = Vector2.ZERO
## Movimento do padrão durante a transição, em células por segundo.
@export var pattern_scroll: Vector2 = Vector2.ZERO


func get_display_name() -> String:
	if not display_name.is_empty():
		return display_name
	return resource_path.get_file().get_basename() if not resource_path.is_empty() else "Transition"


func get_out_duration() -> float:
	return duration / maxf(speed, 0.01)


func get_in_duration() -> float:
	return (in_duration if in_duration >= 0.0 else duration) / maxf(speed, 0.01)


func get_hold_duration() -> float:
	return hold_duration / maxf(speed, 0.01)


func get_direction_vector() -> Vector2:
	match direction:
		Direction.LEFT:
			return Vector2.RIGHT
		Direction.RIGHT:
			return Vector2.LEFT
		Direction.TOP:
			return Vector2.DOWN
		Direction.BOTTOM:
			return Vector2.UP
		Direction.TOP_LEFT:
			return Vector2(1.0, 1.0).normalized()
		Direction.TOP_RIGHT:
			return Vector2(-1.0, 1.0).normalized()
		Direction.BOTTOM_LEFT:
			return Vector2(1.0, -1.0).normalized()
		Direction.BOTTOM_RIGHT:
			return Vector2(-1.0, -1.0).normalized()
	return custom_direction.normalized() if not custom_direction.is_zero_approx() else Vector2.RIGHT


func get_tween_transition() -> Tween.TransitionType:
	return Tween.TRANS_LINEAR if easing == Easing.LINEAR else curve


func get_tween_ease() -> Tween.EaseType:
	match easing:
		Easing.EASE_IN:
			return Tween.EASE_IN
		Easing.EASE_OUT:
			return Tween.EASE_OUT
	return Tween.EASE_IN_OUT
