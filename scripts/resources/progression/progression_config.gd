class_name ProgressionConfig
extends Resource
## Metas de altitude (em metros). Primeiro a lista `milestones` (permite metas não lineares,
## ex.: 100, 250, 500), depois uma meta a cada `milestone_interval`, sem limite de altura.

## Metas explícitas em ordem crescente. Vazio = metas só pelo intervalo desde 0 m.
@export var milestones: Array[MilestoneData] = []
## Distância entre as metas geradas depois da lista.
@export var milestone_interval: float = 1000.0


func get_milestone_height(index: int) -> float:
	if index < 0:
		return 0.0
	if index < milestones.size():
		return milestones[index].height
	return _last_listed_height() + _interval() * float(index - milestones.size() + 1)


func get_milestone_data(index: int) -> MilestoneData:
	return milestones[index] if index >= 0 and index < milestones.size() else null


func find_milestone_data(height: float) -> MilestoneData:
	for data in milestones:
		if data and is_equal_approx(data.height, height):
			return data
	return null


## Índice da próxima meta: a primeira ESTRITAMENTE acima da altura (1000 m alcançado -> próxima é 2000 m).
func next_index_for_height(height: float) -> int:
	for i in milestones.size():
		if milestones[i].height > height:
			return i
	return milestones.size() + floori((height - _last_listed_height()) / _interval())


func _last_listed_height() -> float:
	return milestones[milestones.size() - 1].height if not milestones.is_empty() else 0.0


func _interval() -> float:
	return maxf(milestone_interval, 1.0)
