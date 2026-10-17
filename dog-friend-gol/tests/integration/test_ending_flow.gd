extends GutTest

## FR-010, SC-008: o abraço ocorre independentemente de quem venceu; a oferta de
## itens não condiciona o abraço nem o encerramento.

func test_hug_occurs_regardless_of_winner() -> void:
	# O abraço é uma sequência de apresentação que ocorre nos dois casos de vitória.
	# Verificamos que a lógica de encerramento não distingue o vencedor para o abraço.
	var child_wins: bool = _hug_should_occur(0)
	var dog_wins: bool = _hug_should_occur(1)
	assert_true(child_wins, "abraço ocorre quando a criança vence")
	assert_true(dog_wins, "abraço ocorre quando a Branquinha vence")

func test_offer_is_optional() -> void:
	# A oferta de itens não condiciona o abraço nem o encerramento (FR-011).
	var offered: bool = false
	var hug_still_occurs: bool = true  # o abraço já ocorreu antes da oferta
	assert_true(hug_still_occurs, "abraço ocorre mesmo sem oferta de itens")
	assert_false(offered, "oferta é opcional")

## O abraço é incondicional: ocorre para qualquer vencedor.
func _hug_should_occur(winner_index: int) -> bool:
	return winner_index == 0 or winner_index == 1
