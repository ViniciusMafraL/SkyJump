class_name StreakTracker
extends RefCounted
## Sequência diária (streak) calculada a partir do histórico. A regra de quando um dia conta e de
## quando a sequência quebra fica no StreakRule, separada desta lógica.


static func qualifies(progress: DailyProgress, rule: StreakRule) -> bool:
	return progress != null and progress.get_checkpoint_count() >= maxi(rule.min_checkpoints, 1)


## Dias consecutivos (por data) que contam, terminando hoje. Se hoje ainda não conta e a regra
## permite, a sequência de ontem continua valendo até o fim do dia.
static func current_streak(history: Dictionary, today: DailyDate, rule: StreakRule) -> int:
	var date := today
	if not qualifies(history.get(today.to_key()), rule):
		if not rule.keep_until_today_ends:
			return 0
		date = today.add_days(-1)
	var count := 0
	while qualifies(history.get(date.to_key()), rule):
		count += 1
		date = date.add_days(-1)
	return count


## Maior sequência existente no histórico.
static func longest_streak(history: Dictionary, rule: StreakRule) -> int:
	var days: Array[int] = []
	for key in history:
		if qualifies(history[key], rule):
			days.append(DailyDate.from_key(key).to_unix_day())
	days.sort()
	var best := 0
	var run := 0
	for i in days.size():
		run = run + 1 if i > 0 and days[i] == days[i - 1] + 1 else 1
		best = maxi(best, run)
	return best
