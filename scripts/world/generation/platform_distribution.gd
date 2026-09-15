class_name PlatformDistribution
extends Resource
## Distribuição de plataformas de um tema: a plataforma comum (predominante), a especial
## característica e as secundárias, cada uma com seu peso. O gerador só consulta esta configuração;
## nenhum tema tem lógica própria de geração.

@export_group("Weights")
## Peso da plataforma comum (normal, pequena e grande, sorteadas pelos pesos de cada PlatformConfig).
@export var common_weight: float = 65.0
## Especial mais frequente do tema: define sua identidade mecânica.
@export var characteristic: SpecialPlatformEntry
## Especiais secundárias, com pesos menores.
@export var secondary: Array[SpecialPlatformEntry] = []

@export_group("Rules")
## Plataformas comuns obrigatórias entre duas especiais (evita sequências contínuas de especiais).
## O sorteio é compensado para as frequências finais continuarem próximas dos pesos.
@export var min_common_between_specials: int = 1
## Altura (metros) a partir da qual especiais podem aparecer.
@export var special_start_height: float = 8.0


func get_entries() -> Array[SpecialPlatformEntry]:
	var entries: Array[SpecialPlatformEntry] = []
	if characteristic and characteristic.is_available():
		entries.append(characteristic)
	for entry in secondary:
		if entry and entry.is_available():
			entries.append(entry)
	return entries


func get_special_weight() -> float:
	var total := 0.0
	for entry in get_entries():
		total += entry.weight
	return total


func get_total_weight() -> float:
	return maxf(common_weight, 0.0) + get_special_weight()


## Fração esperada de uma entrada (ou da comum, com entry = null) no total de escolhas.
func get_expected_share(entry: SpecialPlatformEntry) -> float:
	var total := get_total_weight()
	if total <= 0.0:
		return 0.0
	return (entry.weight if entry else maxf(common_weight, 0.0)) / total


## Sorteia o tipo: null = plataforma comum. Só é chamado quando o espaçamento mínimo já foi cumprido;
## por isso o peso das especiais é ampliado para compensar as comuns obrigatórias.
func pick(rng: RandomNumberGenerator, height_m: float) -> SpecialPlatformEntry:
	var roll := rng.randf()
	var entries := get_entries()
	var special_weight := get_special_weight()
	if height_m < special_start_height or entries.is_empty() or special_weight <= 0.0:
		return null
	var special_chance := _free_pick_special_chance(special_weight)
	if roll >= special_chance:
		return null
	var target := roll / special_chance * special_weight
	for entry in entries:
		target -= entry.weight
		if target <= 0.0:
			return entry
	return entries[entries.size() - 1]


## Probabilidade de especial num sorteio livre para que a fração final seja special/total,
## considerando `min_common_between_specials` comuns forçadas após cada especial.
func _free_pick_special_chance(special_weight: float) -> float:
	var share := special_weight / maxf(get_total_weight(), 0.0001)
	var spacing := maxi(min_common_between_specials, 0)
	var denominator := 1.0 - spacing * share
	if denominator <= 0.0:
		return 1.0
	return clampf(share / denominator, 0.0, 1.0)
