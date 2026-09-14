class_name MilestoneData
extends Resource
## Uma meta de altitude da lista do ProgressionConfig.
## Preparada para representar também uma mudança de bioma (ainda sem uso no gameplay).

@export var height: float = 1000.0
## Texto extra exibido junto da altura (ex.: "Montanha"). Vazio = só a altura.
@export var display_name: String = ""
## Futuro BiomeConfig que começa nesta meta.
@export var biome: Resource
@export var icon: Texture2D
