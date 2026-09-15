class_name TestRoomLayout
extends Resource
## Geometria fixa da sala de testes: eixo invisível menor, piso em anel e poucas plataformas.

@export_group("Cylinder")
## Raio do eixo invisível. Não existe malha de pilar: as plataformas flutuam ao redor dele.
@export var pillar_radius: float = 3.0
@export var player_surface_offset: float = 1.2
@export var platform_embed_depth: float = 0.3

@export_group("Spawn")
@export var spawn_angle_degrees: float = 0.0
@export var spawn_height: float = 0.0
## Abaixo desta altura o teste é reiniciado automaticamente.
@export var respawn_below_height: float = -6.0

@export_group("Floor")
## Piso em anel completo, para testar voltas de 360 graus. Vazio = sem piso.
@export var floor_platform: PlatformConfig
@export var floor_segments: int = 10
@export var floor_height: float = 0.0
## Sobreposição (arco) entre segmentos vizinhos do piso.
@export var floor_overlap: float = 0.3

@export_group("Platforms")
@export var placements: Array[PlatformPlacement] = []
@export var theme_config: ThemeConfig

@export_group("Object Stations")
## Testes individuais dos objetos especiais, selecionáveis na sala (ordem do seletor).
@export var stations: Array[ObjectTestStation] = []


func get_player_orbit_radius() -> float:
	return pillar_radius + player_surface_offset


func get_platform_radius(depth: float) -> float:
	return PlatformFactory.radius_for(pillar_radius, depth, platform_embed_depth)


func get_floor_segment_width() -> float:
	return TAU * get_player_orbit_radius() / maxi(floor_segments, 1) + floor_overlap


func get_theme() -> ThemeData:
	return theme_config.get_theme_for_height(0.0) if theme_config else null
