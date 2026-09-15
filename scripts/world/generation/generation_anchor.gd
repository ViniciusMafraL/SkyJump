class_name GenerationAnchor
extends RefCounted
## Ponto de onde o jogador parte para o próximo passo da geração: a última plataforma do caminho
## ou a saída de uma seção especial (fim do percurso da plataforma móvel, topo da escada...).

var angle: float = 0.0
## Altura do topo (onde ficam os pés).
var height: float = 0.0
var width: float = 3.0
## Velocidade vertical com que o jogador sai deste ponto (pulo normal ou lançamento forçado).
var launch_speed: float = 0.0


static func at(anchor_angle: float, anchor_height: float, anchor_width: float, anchor_launch_speed: float) -> GenerationAnchor:
	var anchor := GenerationAnchor.new()
	anchor.angle = wrapf(anchor_angle, 0.0, TAU)
	anchor.height = anchor_height
	anchor.width = anchor_width
	anchor.launch_speed = anchor_launch_speed
	return anchor
