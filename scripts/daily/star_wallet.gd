class_name StarWallet
extends RefCounted
## Currency global de ESTRELAS (Star Manager). Acumula para sempre e salva imediatamente após cada
## recompensa. Login diário: uma vez por data. Checkpoint: uma vez por checkpoint de cada Daily.

signal stars_changed(total: int, delta: int, reason: StringName)

const REASON_LOGIN := &"login"
const REASON_CHECKPOINT := &"checkpoint"
const REASON_DEBUG := &"debug"

var login_reward: int = 1
var checkpoint_reward: int = 1

var _store: DailySaveStore


func _init(store: DailySaveStore, login_amount: int = 1, checkpoint_amount: int = 1) -> void:
	_store = store
	login_reward = login_amount
	checkpoint_reward = checkpoint_amount


func get_stars() -> int:
	return _store.total_stars


func add_stars(amount: int, reason: StringName = &"") -> void:
	if amount <= 0:
		return
	_store.total_stars += amount
	_store.save_player()
	stars_changed.emit(_store.total_stars, amount, reason)


func can_claim_daily_login(today: DailyDate) -> bool:
	return today != null and _store.last_daily_login_reward != today.to_key()


func claim_daily_login(today: DailyDate) -> bool:
	if not can_claim_daily_login(today):
		return false
	_store.last_daily_login_reward = today.to_key()
	add_stars(login_reward, REASON_LOGIN)
	return true


## Marca o checkpoint e concede a estrela. Nunca recompensa o mesmo checkpoint duas vezes.
func claim_checkpoint_reward(progress: DailyProgress, checkpoint: int) -> bool:
	if progress == null or not progress.mark_checkpoint(checkpoint):
		return false
	_store.save_history()
	add_stars(checkpoint_reward, REASON_CHECKPOINT)
	return true
