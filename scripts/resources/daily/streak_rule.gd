class_name StreakRule
extends Resource
## Regra da sequência diária (quando um dia conta e quando a sequência quebra).

## Estrelas de checkpoint mínimas no Daily para o dia contar na sequência (a estrela de login não conta).
@export_range(1, 3, 1) var min_checkpoints: int = 1
## Enquanto o dia atual não termina, a sequência até ontem continua valendo.
@export var keep_until_today_ends: bool = true
