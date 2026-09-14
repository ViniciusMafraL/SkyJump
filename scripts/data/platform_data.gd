class_name PlatformData
extends Resource
## Dados de gameplay de uma plataforma gerada. Independente do modelo 3D.

## Altura do topo (unidades do mundo).
@export var height: float = 0.0
## Posição ao redor do cilindro (radianos).
@export var angle: float = 0.0
## Distância do centro da plataforma ao eixo do cilindro.
@export var radius: float = 0.0
@export var width: float = 3.0
@export var depth: float = 3.0
@export var platform_type: PlatformType.Type = PlatformType.Type.NORMAL
@export var config: PlatformConfig
