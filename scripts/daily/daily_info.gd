class_name DailyInfo
extends RefCounted
## Tudo o que se sabe de um Daily: data, seed, tema do dia, progresso salvo e estado atual.
## Seed e tema são recalculados deterministicamente a partir da data.

var date: DailyDate
var seed: int = 0
## Índice na ThemeLibrary (-1 sem temas).
var theme_index: int = -1
var theme_id: StringName = &""
var theme_name: String = ""
var theme_scene: PackedScene
## null enquanto o Daily nunca foi iniciado.
var progress: DailyProgress
var state: DailyState.State = DailyState.State.FUTURE


func get_date_key() -> String:
	return date.to_key() if date else ""


func get_collected_count() -> int:
	return progress.get_checkpoint_count() if progress else 0
