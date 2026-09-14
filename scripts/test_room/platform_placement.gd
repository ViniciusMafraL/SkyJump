class_name PlatformPlacement
extends Resource
## Plataforma posicionada manualmente (sala de testes).

@export var platform_config: PlatformConfig
## Altura do topo (unidades do mundo).
@export var height: float = 2.0
@export var angle_degrees: float = 0.0
## 0 = usa a largura do PlatformConfig.
@export var width_override: float = 0.0
