class_name DailyState
extends RefCounted
## Estados lógicos de um dia do calendário.
## FUTURE, AVAILABLE, IN_PROGRESS, COMPLETED e ENDED têm comportamento nesta versão;
## RECORD e INVALIDATED existem para a arquitetura (INVALIDATED = progresso salvo com outra seed).

enum State { FUTURE, AVAILABLE, IN_PROGRESS, COMPLETED, RECORD, ENDED, INVALIDATED }


## Estados em que a partida pode ser iniciada ou continuada.
static func is_playable(state: State) -> bool:
	return state == State.AVAILABLE or state == State.IN_PROGRESS


static func name_of(state: int) -> String:
	var key = State.find_key(state)
	return String(key) if key != null else str(state)
