class_name WorldGenerationConfig
extends Resource
## Configuração central do mundo e da geração procedural.

@export_group("Seed")
@export var world_seed: int = 12345
## Se verdadeiro, cada tentativa usa uma seed aleatória (world_seed é ignorada).
@export var randomize_seed_each_run: bool = true

@export_group("Cylinder")
## Raio do eixo invisível. Não existe malha de pilar: as plataformas flutuam ao redor dele.
@export var pillar_radius: float = 6.0
## Distância entre o raio do eixo e a trajetória do personagem.
@export var player_surface_offset: float = 1.2
## Recuo das plataformas em direção ao eixo (ajusta o raio em que ficam).
@export var platform_embed_depth: float = 0.3
## Conversão das unidades internas da Godot para os metros exibidos.
@export var meters_per_world_unit: float = 1.0

@export_group("Chunks")
@export var chunk_config: ChunkConfig

@export_group("Platforms")
## Tipos permitidos no sorteio. O peso de cada um fica no próprio PlatformConfig.
@export var platform_configs: Array[PlatformConfig] = []
## Plataforma inicial, onde o jogador nasce.
@export var start_platform: PlatformConfig
## Plataforma de descanso no início de cada chunk. Vazio = desativado.
@export var chunk_start_platform: PlatformConfig
@export var start_angle_degrees: float = 0.0

@export_group("Distances")
## Distância vertical entre plataformas consecutivas (unidades do mundo), antes da dificuldade.
@export var minimum_vertical_distance: float = 1.6
@export var maximum_vertical_distance: float = 2.6
## Distância angular centro a centro (graus), antes da dificuldade.
@export var minimum_angular_distance: float = 20.0
@export var maximum_angular_distance: float = 55.0
## Espaço mínimo (arco) entre as bordas de plataformas consecutivas.
@export var minimum_edge_gap: float = 0.4
## Limite manual para a distância horizontal de salto (arco). 0 = derivado da física do jogador.
@export var maximum_horizontal_jump_distance: float = 0.0
## Fração da capacidade de salto usada pelo gerador (margem de segurança).
@export_range(0.3, 1.0) var reachability_margin: float = 0.85
## Maior ângulo entre plataformas consecutivas que ainda fica visível na câmera.
@export var maximum_visible_angular_distance: float = 60.0
@export_range(0.0, 1.0) var direction_change_chance: float = 0.25
## Após um lançamento forçado (trampolim), a próxima plataforma fica entre esta fração e 100% da altura alcançável.
@export_range(0.2, 1.0) var boost_min_gap_fraction: float = 0.6

@export_group("Checkpoints")
## Anel em volta do cilindro gerado em cada altura de LevelGenerator.checkpoint_heights (Desafio Diário).
@export var checkpoint_platform: PlatformConfig
## Abaixo de um checkpoint, dentro desta distância (unidades do mundo), só entram plataformas comuns:
## nenhum especial ou plataforma lateral pode levar o jogador acima do anel antes de ele existir.
@export var checkpoint_special_clearance: float = 30.0

@export_group("Difficulty")
@export var difficulty: DifficultyConfig


func get_player_orbit_radius() -> float:
	return pillar_radius + player_surface_offset


func to_meters(world_height: float) -> float:
	return world_height * meters_per_world_unit
