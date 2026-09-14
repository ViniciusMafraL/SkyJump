class_name TransitionSettings
extends Resource
## Configuração global das transições: preset de cada evento, bloqueio de input e debug.
## Cada propriedade de evento tem o mesmo nome da constante em TransitionEvent.

## Usado quando um evento não tem preset ou quando nenhuma configuração é passada.
@export var default_config: TransitionConfig
## Mostra na tela a transição atual, o progresso e o estado.
@export var debug_transitions: bool = false
## Bloqueia toques, botões e input do jogador enquanto uma transição acontece.
@export var lock_input: bool = true
## Evento 1: o jogo abre com a tela coberta e revela a primeira cena.
@export var cover_on_start: bool = true
## Frames aguardados depois da troca de cena antes de revelar (a cena termina de montar).
@export_range(0, 30) var scene_ready_frames: int = 2

@export_group("Eventos")
@export var game_start: TransitionConfig
@export var screen_change: TransitionConfig
@export var play: TransitionConfig
@export var open_test_room: TransitionConfig
@export var exit_test_room: TransitionConfig
@export var death: TransitionConfig
@export var restart: TransitionConfig
@export var back_to_menu: TransitionConfig
@export var region_change: TransitionConfig
@export var checkpoint: TransitionConfig
@export var teleport: TransitionConfig
@export var special_event: TransitionConfig


func get_config(event: StringName) -> TransitionConfig:
	if event in TransitionEvent.ALL:
		var config := get(event) as TransitionConfig
		if config:
			return config
	else:
		push_warning("Evento de transição desconhecido: %s" % event)
	return default_config
