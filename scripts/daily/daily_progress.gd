class_name DailyProgress
extends RefCounted
## Progresso salvo de um Daily (uma data). Os dados carregados são validados: valores inválidos
## voltam ao padrão e `completed` é sempre coerente com os checkpoints.

const CHECKPOINT_COUNT := 3

var date_key: String = ""
var seed: int = 0
var theme_id: StringName = &""
var started: bool = false
var checkpoints: Array[bool] = [false, false, false]
var completed: bool = false
## Maior altura (metros) alcançada neste Daily.
var record: float = 0.0
## Ponto de retomada: plataforma do último checkpoint coletado.
var resume_height: float = 0.0
var resume_angle: float = 0.0
## Último estado calculado (informativo; o estado real é recalculado pelo DailyChallenge).
var state: DailyState.State = DailyState.State.AVAILABLE


func get_checkpoint_count() -> int:
	var count := 0
	for collected in checkpoints:
		if collected:
			count += 1
	return count


func has_checkpoint(index: int) -> bool:
	return index >= 0 and index < CHECKPOINT_COUNT and checkpoints[index]


## Marca o checkpoint. Retorna false se o índice for inválido ou já estava coletado.
func mark_checkpoint(index: int) -> bool:
	if index < 0 or index >= CHECKPOINT_COUNT or checkpoints[index]:
		return false
	checkpoints[index] = true
	started = true
	completed = get_checkpoint_count() == CHECKPOINT_COUNT
	return true


func to_dict() -> Dictionary:
	var values := {
		"date": date_key,
		"seed": seed,
		"theme": String(theme_id),
		"started": started,
		"completed": completed,
		"record": record,
		"resume_height": resume_height,
		"resume_angle": resume_angle,
		"state": int(state),
	}
	for i in CHECKPOINT_COUNT:
		values["checkpoint_%d" % (i + 1)] = checkpoints[i]
	return values


## null quando o registro não tem uma data válida.
static func from_dict(values: Variant) -> DailyProgress:
	if not values is Dictionary:
		return null
	var dict: Dictionary = values
	var key := str(dict.get("date", ""))
	if DailyDate.from_key(key) == null:
		return null
	var progress := DailyProgress.new()
	progress.date_key = key
	progress.seed = _to_int(dict.get("seed"), 0)
	progress.theme_id = StringName(str(dict.get("theme", "")))
	for i in CHECKPOINT_COUNT:
		progress.checkpoints[i] = dict.get("checkpoint_%d" % (i + 1)) == true
	progress.started = dict.get("started") == true or progress.get_checkpoint_count() > 0
	progress.completed = progress.get_checkpoint_count() == CHECKPOINT_COUNT
	progress.record = maxf(_to_float(dict.get("record"), 0.0), 0.0)
	progress.resume_height = _to_float(dict.get("resume_height"), 0.0)
	progress.resume_angle = wrapf(_to_float(dict.get("resume_angle"), 0.0), 0.0, TAU)
	var saved_state := _to_int(dict.get("state"), 0)
	progress.state = saved_state as DailyState.State if saved_state >= 0 and saved_state < DailyState.State.size() else DailyState.State.AVAILABLE
	return progress


static func _to_int(value: Variant, fallback: int) -> int:
	return int(value) if value is int or value is float else fallback


static func _to_float(value: Variant, fallback: float) -> float:
	if value is int or value is float:
		var number := float(value)
		return number if is_finite(number) else fallback
	return fallback
