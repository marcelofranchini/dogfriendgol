class_name DrawLots
## Caso de uso: sorteio de cara ou coroa (FR-007). Determinístico com semente fixa.

## Realiza o sorteio usando o RngPort injetado.
static func draw_lots(rng: RngPort) -> CoinToss:
	var toss: CoinToss = CoinToss.new()
	toss.first_shooter_index = rng.next_int(2)
	toss.side_a = rng.next_int(2)
	toss.side_b = 1 - toss.side_a
	return toss
