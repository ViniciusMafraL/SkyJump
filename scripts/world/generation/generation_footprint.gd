class_name GenerationFootprint
extends RefCounted
## Volume ocupado por uma plataforma ou estrutura gerada, no espaço desenrolado do cilindro.
## O gerador consulta esses volumes para não sobrepor plataformas, paredes, tubos e portais.

## Espaço mínimo entre bordas de volumes vizinhos (ao longo da circunferência).
const EDGE_GAP := 0.3

var angle: float = 0.0
## Meia largura ao longo da circunferência (unidades do mundo).
var half_width: float = 0.0
var bottom: float = 0.0
var top: float = 0.0


static func box(center_angle: float, half_width_value: float, bottom_value: float, top_value: float) -> GenerationFootprint:
	var footprint := GenerationFootprint.new()
	footprint.angle = center_angle
	footprint.half_width = half_width_value
	footprint.bottom = bottom_value
	footprint.top = top_value
	return footprint


## Plataformas com mais de 0.6 de diferença de altura não se sobrepõem (colisão one-way).
static func for_platform(data: PlatformData) -> GenerationFootprint:
	return box(data.angle, data.width * 0.5, data.height - 0.3, data.height + 0.3)


func overlaps(other: GenerationFootprint, radius: float) -> bool:
	if top <= other.bottom or other.top <= bottom:
		return false
	return absf(angle_difference(angle, other.angle)) * radius < half_width + other.half_width + EDGE_GAP
