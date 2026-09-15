class_name ObjectTestStation
extends Resource
## Estação de teste individual de um objeto especial: o objeto (ou par de objetos) e as
## plataformas auxiliares, montados sobre o piso em anel da sala, sem geração procedural.

@export var display_name: String = "Objeto"
## Seção de TestRoomConfig com os parâmetros exibidos no painel (ex.: &"moving").
@export var settings_section: StringName = &""
@export var placements: Array[PlatformPlacement] = []

@export_group("Generated Map")
## Em vez dos placements, gera um trecho do mapa com a distribuição de plataformas do tema ativo.
@export var generated_map: bool = false
@export var generation_config: WorldGenerationConfig
@export var generated_chunks: int = 2
## Chunks gerados só em dados para medir a distribuição exibida no debug.
@export var report_chunks: int = 80
## Piso em anel da sala (desligar em mapas gerados, que têm a própria plataforma inicial).
@export var use_floor: bool = true

@export_group("Spawn")
@export var spawn_angle_degrees: float = 0.0
@export var spawn_height: float = 0.0
