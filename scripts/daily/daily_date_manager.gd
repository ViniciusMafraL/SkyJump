class_name DailyDateManager
extends RefCounted
## Única fonte de data e hora do Desafio Diário. Nesta versão usa a data LOCAL do dispositivo.
## Nenhum outro sistema lê o relógio diretamente: trocar a fonte (ex.: servidor) muda só esta classe.
## Em builds de debug aceita uma data simulada para testar mudança de dia, semana, mês e ano.

var _simulated_date: DailyDate


func get_today() -> DailyDate:
	if _simulated_date:
		return _simulated_date.duplicate_date()
	var now := Time.get_datetime_dict_from_system()
	return DailyDate.create(now.year, now.month, now.day)


func get_year() -> int:
	return get_today().year


func get_month() -> int:
	return get_today().month


func get_day() -> int:
	return get_today().day


## Semana ISO (ano, número) de uma data.
func get_week(date: DailyDate) -> Vector2i:
	return date.iso_week()


## Segundos desde a meia-noite local (o relógio real continua valendo com data simulada).
func get_seconds_since_midnight() -> int:
	var now := Time.get_time_dict_from_system()
	return int(now.hour) * 3600 + int(now.minute) * 60 + int(now.second)


## Tempo até o início de `date` (0 se já começou).
func seconds_until(date: DailyDate) -> int:
	return maxi(get_today().days_until(date) * DailyDate.SECONDS_PER_DAY - get_seconds_since_midnight(), 0)


## Tempo até o próximo Daily (próxima meia-noite local).
func seconds_until_next_day() -> int:
	return seconds_until(get_today().add_days(1))


func is_simulating() -> bool:
	return _simulated_date != null


## Somente em builds de debug: a versão final sempre usa a data real.
func set_simulated_date(date: DailyDate) -> bool:
	if not OS.is_debug_build() or date == null:
		return false
	_simulated_date = date.duplicate_date()
	return true


func clear_simulated_date() -> void:
	_simulated_date = null
