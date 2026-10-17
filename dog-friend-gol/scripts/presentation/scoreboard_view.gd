class_name ScoreboardView
extends Control
## Placar e indicadores (contracts/use-case-api.md §7). Recebe o placar, nunca o deriva.

## Atualiza o placar a partir do estado. Nunca calcula o placar (FR-049).
func update_score(score: Array) -> void:
	# A implementação visual (labels) é preenchida na cena. Aqui apenas registra.
	pass

## Indica quem está cobrando e quem está defendendo (FR-046).
func update_turn(shooter_index: int, defender_index: int) -> void:
	pass

## Exibe o resultado da última cobrança (FR-047).
func show_attempt_result(result: int) -> void:
	pass
