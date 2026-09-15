class_name DailySaveStore
extends RefCounted
## Persistência local do Desafio Diário, sobre o save existente (LocalSave):
## seção "daily_player" (estrelas, login e sequência) e seção "daily_history" (progresso por data).
## Save inexistente ou corrompido carrega valores padrão; carregar nunca concede recompensas.

const PLAYER_SECTION := "daily_player"
const HISTORY_SECTION := "daily_history"
const HISTORY_ENTRIES_KEY := "entries"

var save_path: String = LocalSave.SAVE_PATH

var total_stars: int = 0
## Data ("YYYY-MM-DD") da última estrela de login concedida. Vazio = nunca.
var last_daily_login_reward: String = ""
var current_streak: int = 0
var best_streak: int = 0
## date_key -> DailyProgress
var history: Dictionary = {}


func load_data() -> void:
	var player := LocalSave.load_section(PLAYER_SECTION, save_path)
	total_stars = maxi(DailyProgress._to_int(player.get("total_stars"), 0), 0)
	var login_key := str(player.get("last_daily_login_reward", ""))
	last_daily_login_reward = login_key if DailyDate.from_key(login_key) else ""
	current_streak = maxi(DailyProgress._to_int(player.get("current_streak"), 0), 0)
	best_streak = maxi(DailyProgress._to_int(player.get("best_streak"), 0), current_streak)
	history.clear()
	var entries: Variant = LocalSave.load_section(HISTORY_SECTION, save_path).get(HISTORY_ENTRIES_KEY, [])
	if entries is Array:
		for entry in entries:
			var progress := DailyProgress.from_dict(entry)
			if progress:
				history[progress.date_key] = progress


func save_player() -> void:
	LocalSave.save_section(PLAYER_SECTION, {
		"total_stars": total_stars,
		"last_daily_login_reward": last_daily_login_reward,
		"current_streak": current_streak,
		"best_streak": best_streak,
	}, save_path)


func save_history() -> void:
	var entries := []
	for key in history:
		entries.append((history[key] as DailyProgress).to_dict())
	LocalSave.save_section(HISTORY_SECTION, {HISTORY_ENTRIES_KEY: entries}, save_path)


func save_all() -> void:
	save_player()
	save_history()


func get_progress(date_key: String) -> DailyProgress:
	return history.get(date_key) as DailyProgress


## Progresso existente ou um novo (ainda não salvo) para a data.
func ensure_progress(date_key: String, daily_seed: int, theme_id: StringName) -> DailyProgress:
	var progress := get_progress(date_key)
	if progress == null:
		progress = DailyProgress.new()
		progress.date_key = date_key
		progress.seed = daily_seed
		progress.theme_id = theme_id
		history[date_key] = progress
	return progress


func remove_progress(date_key: String) -> void:
	history.erase(date_key)
	save_history()


## Apaga todo o progresso do Desafio Diário (ferramenta de debug).
func clear() -> void:
	total_stars = 0
	last_daily_login_reward = ""
	current_streak = 0
	best_streak = 0
	history.clear()
	save_all()
