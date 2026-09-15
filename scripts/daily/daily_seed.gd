class_name DailySeed
extends RefCounted
## Seeds determinísticas do Desafio Diário. A mesma entrada sempre gera a mesma seed, em qualquer
## abertura do jogo e em qualquer dispositivo (String.hash é estável). Nada aqui usa randomize().
## O `salt` (DailyConfig.seed_salt) permite trocar toda a sequência numa nova versão do jogo.


## DATA -> DAILY SEED (usada também como seed do gerador de mapa).
static func get_daily_seed(date: DailyDate, salt: String) -> int:
	return ("%s|day|%s" % [salt, date.to_key()]).hash()


## Seed da semana ISO usada pela rotação de temas.
static func get_week_seed(iso_year: int, week: int, salt: String) -> int:
	return ("%s|week|%04d-W%02d" % [salt, iso_year, week]).hash()
