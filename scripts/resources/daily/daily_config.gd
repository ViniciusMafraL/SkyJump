class_name DailyConfig
extends Resource
## Configuração central do Desafio Diário.

@export_group("Checkpoints")
## Distâncias (metros) dos 3 checkpoints do Daily.
@export var checkpoint_1_distance: float = 500.0
@export var checkpoint_2_distance: float = 800.0
@export var checkpoint_3_distance: float = 1000.0

@export_group("Rewards")
@export var login_reward_stars: int = 1
@export var checkpoint_reward_stars: int = 1

@export_group("Seed")
## Muda toda a sequência de seeds e temas (ex.: numa nova versão do gerador).
@export var seed_salt: String = "skyjump-daily-v1"

@export_group("Themes")
@export var theme_library: ThemeLibrary

@export_group("Streak")
@export var streak_rule: StreakRule
## Marcos de sequência (dias). Só emitem sinal nesta versão; recompensas entram depois.
@export var streak_milestones: PackedInt32Array = [7, 14, 30, 100]

@export_group("Calendar")
## Quantos meses para trás o calendário permite visualizar.
@export var months_back: int = 12


func get_checkpoint_distances() -> PackedFloat32Array:
	return PackedFloat32Array([checkpoint_1_distance, checkpoint_2_distance, checkpoint_3_distance])
