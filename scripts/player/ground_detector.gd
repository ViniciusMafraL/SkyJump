class_name GroundDetector
extends Node
## Detecta aterrissagem e apoio sobre plataformas usando apenas dados de gameplay.

## Tolerância vertical para aceitar pouso quando os pés já estão praticamente no topo.
const HEIGHT_TOLERANCE := 0.05

var platform_source: PlatformSource


## Plataforma mais alta cujo topo foi cruzado entre `previous_height` e `new_height` (descendo).
func find_landing(previous_height: float, new_height: float, angle: float, radius: float, margin: float) -> Platform:
	if platform_source == null:
		return null
	var best: Platform = null
	var best_top := -INF
	for platform in platform_source.get_active_platforms():
		if not platform.is_solid():
			continue
		var top := platform.get_top_height()
		if top > previous_height + HEIGHT_TOLERANCE or top < new_height or top <= best_top:
			continue
		if platform.contains(angle, radius, margin):
			best = platform
			best_top = top
	return best


func is_supported_by(platform: Platform, angle: float, radius: float, margin: float) -> bool:
	return platform.is_solid() and platform.contains(angle, radius, margin)
