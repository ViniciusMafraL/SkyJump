class_name ObjectTestStation
extends Resource
## Estação de teste individual de um objeto especial: o objeto (ou par de objetos) e as
## plataformas auxiliares, montados sobre o piso em anel da sala, sem geração procedural.

@export var display_name: String = "Objeto"
## Seção de TestRoomConfig com os parâmetros exibidos no painel (ex.: &"moving").
@export var settings_section: StringName = &""
@export var placements: Array[PlatformPlacement] = []

@export_group("Spawn")
@export var spawn_angle_degrees: float = 0.0
@export var spawn_height: float = 0.0
