class_name CurrencyWallet
extends RefCounted
## Moedas globais do jogador: BRONZE, PRATA e ESTRELA. Acumulam para sempre e salvam logo após cada
## recompensa. Login diário: estrelas, uma vez por data. Checkpoints do Daily: 1º bronze, 2º prata,
## 3º estrela (configurável), cada checkpoint recompensado uma única vez.

signal currency_changed(currency: Currency, total: int, delta: int, reason: StringName)

enum Currency { BRONZE, SILVER, STAR }

const REASON_LOGIN := &"login"
const REASON_CHECKPOINT := &"checkpoint"
const REASON_DEBUG := &"debug"

var login_reward: int = 1
var checkpoint_reward: int = 1
## Moeda de cada checkpoint, na ordem.
var checkpoint_currencies: Array[Currency] = [Currency.BRONZE, Currency.SILVER, Currency.STAR]

var _store: DailySaveStore


func _init(store: DailySaveStore, login_amount: int = 1, checkpoint_amount: int = 1, currencies: Array = []) -> void:
	_store = store
	login_reward = login_amount
	checkpoint_reward = checkpoint_amount
	if not currencies.is_empty():
		checkpoint_currencies.assign(currencies)


static func name_of(currency: Currency) -> String:
	return str(Currency.find_key(currency))


func get_amount(currency: Currency) -> int:
	match currency:
		Currency.BRONZE:
			return _store.total_bronze
		Currency.SILVER:
			return _store.total_silver
	return _store.total_stars


func get_stars() -> int:
	return _store.total_stars


func add(currency: Currency, amount: int, reason: StringName = &"") -> void:
	if amount <= 0:
		return
	match currency:
		Currency.BRONZE:
			_store.total_bronze += amount
		Currency.SILVER:
			_store.total_silver += amount
		_:
			_store.total_stars += amount
	_store.save_player()
	currency_changed.emit(currency, get_amount(currency), amount, reason)


func get_checkpoint_currency(index: int) -> Currency:
	if checkpoint_currencies.is_empty():
		return Currency.STAR
	return checkpoint_currencies[clampi(index, 0, checkpoint_currencies.size() - 1)]


func can_claim_daily_login(today: DailyDate) -> bool:
	return today != null and _store.last_daily_login_reward != today.to_key()


func claim_daily_login(today: DailyDate) -> bool:
	if not can_claim_daily_login(today):
		return false
	_store.last_daily_login_reward = today.to_key()
	add(Currency.STAR, login_reward, REASON_LOGIN)
	return true


## Marca o checkpoint e concede sua moeda. Nunca recompensa o mesmo checkpoint duas vezes.
func claim_checkpoint_reward(progress: DailyProgress, checkpoint: int) -> bool:
	if progress == null or not progress.mark_checkpoint(checkpoint):
		return false
	_store.save_history()
	add(get_checkpoint_currency(checkpoint), checkpoint_reward, REASON_CHECKPOINT)
	return true
