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
## Espelha a direção local do objeto (direita <-> esquerda).
@export var flip: bool = false
## Propriedades aplicadas à instância antes do setup (ex.: ids de portais, curva do tubo).
@export var object_properties: Dictionary = {}

## Informações do gerador para debug e testes (ex.: mira alvo do canhão). Não afeta o objeto.
var hints: Dictionary = {}
