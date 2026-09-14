class_name TransitionEvent
extends RefCounted
## Lista centralizada dos momentos do jogo que usam transição.
## Quem pede a transição conhece só o evento; o preset de cada evento fica no TransitionSettings.

const GAME_START := &"game_start"
const SCREEN_CHANGE := &"screen_change"
const PLAY := &"play"
const OPEN_TEST_ROOM := &"open_test_room"
const EXIT_TEST_ROOM := &"exit_test_room"
const DEATH := &"death"
const RESTART := &"restart"
const BACK_TO_MENU := &"back_to_menu"
const REGION_CHANGE := &"region_change"
const CHECKPOINT := &"checkpoint"
const TELEPORT := &"teleport"
const SPECIAL_EVENT := &"special_event"

const ALL: Array[StringName] = [
	GAME_START, SCREEN_CHANGE, PLAY, OPEN_TEST_ROOM, EXIT_TEST_ROOM, DEATH,
	RESTART, BACK_TO_MENU, REGION_CHANGE, CHECKPOINT, TELEPORT, SPECIAL_EVENT,
]
