class_name DailyDate
extends RefCounted
## Data de um Desafio Diário, sem horário. O identificador único é sempre "YYYY-MM-DD"
## (nunca só o número do dia), o que evita conflitos entre meses e anos.

const SECONDS_PER_DAY := 86400

var year: int = 1970
var month: int = 1
var day: int = 1


## Retorna null para datas inválidas (ex.: 31/02).
static func create(date_year: int, date_month: int, date_day: int) -> DailyDate:
	if not is_valid(date_year, date_month, date_day):
		return null
	var date := DailyDate.new()
	date.year = date_year
	date.month = date_month
	date.day = date_day
	return date


## "2026-09-15" -> DailyDate. Retorna null se o texto não for uma data válida.
static func from_key(key: String) -> DailyDate:
	var parts := key.split("-")
	if key.length() != 10 or parts.size() != 3 or not parts[0].is_valid_int() or not parts[1].is_valid_int() or not parts[2].is_valid_int():
		return null
	return create(parts[0].to_int(), parts[1].to_int(), parts[2].to_int())


## Dia a partir do número de dias desde 1970-01-01.
static func from_unix_day(unix_day: int) -> DailyDate:
	var parts := Time.get_date_dict_from_unix_time(unix_day * SECONDS_PER_DAY)
	return create(parts.year, parts.month, parts.day)


static func is_valid(date_year: int, date_month: int, date_day: int) -> bool:
	return date_year >= 1970 and date_month >= 1 and date_month <= 12 and date_day >= 1 and date_day <= days_in_month(date_year, date_month)


static func is_leap_year(date_year: int) -> bool:
	return (date_year % 4 == 0 and date_year % 100 != 0) or date_year % 400 == 0


static func days_in_month(date_year: int, date_month: int) -> int:
	match date_month:
		2:
			return 29 if is_leap_year(date_year) else 28
		4, 6, 9, 11:
			return 30
	return 31


func to_key() -> String:
	return "%04d-%02d-%02d" % [year, month, day]


func to_unix_day() -> int:
	var unix := Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0})
	return floori(unix / float(SECONDS_PER_DAY))


func add_days(amount: int) -> DailyDate:
	return from_unix_day(to_unix_day() + amount)


## Soma meses mantendo o dia dentro do mês de destino (31/01 + 1 mês = 28 ou 29/02).
func add_months(amount: int) -> DailyDate:
	var total := year * 12 + (month - 1) + amount
	var target_year := floori(total / 12.0)
	var target_month := total - target_year * 12 + 1
	return create(target_year, target_month, mini(day, days_in_month(target_year, target_month)))


func first_of_month() -> DailyDate:
	return create(year, month, 1)


## Dias de `self` até `other` (positivo = `other` no futuro).
func days_until(other: DailyDate) -> int:
	return other.to_unix_day() - to_unix_day()


## 0 = segunda-feira ... 6 = domingo. 1970-01-01 foi uma quinta-feira.
func weekday() -> int:
	return posmod(to_unix_day() + 3, 7)


## Semana ISO-8601 (começa na segunda): Vector2i(ano ISO, número da semana). Os dias entre anos
## (ex.: 31/12 e 01/01 na mesma semana) pertencem à mesma semana.
func iso_week() -> Vector2i:
	var thursday := add_days(3 - weekday())
	var first_day := create(thursday.year, 1, 1)
	return Vector2i(thursday.year, floori(first_day.days_until(thursday) / 7.0) + 1)


func equals(other: DailyDate) -> bool:
	return other != null and year == other.year and month == other.month and day == other.day


func duplicate_date() -> DailyDate:
	return create(year, month, day)
