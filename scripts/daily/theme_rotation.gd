class_name ThemeRotation
extends RefCounted
## Rotação determinística dos temas por semana: a seed da semana embaralha a lista de temas e os
## 7 dias usam as 7 primeiras posições. Assim nenhum tema se repete na mesma semana (com 7 ou mais
## temas) e a semana seguinte tem outra ordem, podendo repetir temas.


## Ordem embaralhada (Fisher-Yates) dos índices de tema para uma seed de semana.
static func get_week_order(week_seed: int, theme_count: int) -> PackedInt32Array:
	var order := PackedInt32Array()
	for i in theme_count:
		order.append(i)
	var rng := RandomNumberGenerator.new()
	rng.seed = week_seed
	for i in range(theme_count - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := order[i]
		order[i] = order[j]
		order[j] = swap
	return order


## Índice do tema (na ThemeLibrary) de uma data. -1 sem temas.
static func get_theme_index(date: DailyDate, theme_count: int, salt: String) -> int:
	if theme_count <= 0:
		return -1
	var week := date.iso_week()
	var order := get_week_order(DailySeed.get_week_seed(week.x, week.y, salt), theme_count)
	return order[date.weekday() % theme_count]
