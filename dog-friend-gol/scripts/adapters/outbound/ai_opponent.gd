class_name AiOpponent
## Adapter outbound: IA local (FR-037 a FR-044). Implementa decisões de zona.
## A assinatura NÃO recebe a zona do jogador (FR-042) — garantia de interface.

var difficulty: int = AiDifficulty.Level.NORMAL

## Escolhe a zona de chute da IA. NÃO recebe a zona do defensor jogador (FR-042).
func choose_shot_zone(state: MatchState, rng: RngPort) -> int:
	return _weighted_zone(state, rng)

## Escolhe a zona de defesa da IA. NÃO recebe a zona do cobrador jogador (FR-042).
func choose_defense_zone(state: MatchState, rng: RngPort) -> int:
	return _weighted_zone(state, rng)

## Escolha ponderada pelo contexto (FR-040) com variação por rng (FR-041).
## A dificuldade altera a distribuição, não as regras (FR-043).
func _weighted_zone(state: MatchState, rng: RngPort) -> int:
	# Distribuição base: favorece zonas centrais (mais seguras).
	# EASY: muito central; NORMAL: equilibrado; HARD: explora cantos altos.
	var zones: Array = ShotZone.all_zones()
	var weights: Array = _weights_for_difficulty()
	var total: int = 0
	for w in weights:
		total += w
	var roll: int = rng.next_int(total)
	var acc: int = 0
	for i in range(zones.size()):
		acc += weights[i]
		if roll < acc:
			return zones[i]
	return zones[zones.size() - 1]

func _weights_for_difficulty() -> Array:
	# Índices: 0=TL,1=TC,2=TR,3=ML,4=MC,5=MR,6=BL,7=BC,8=BR
	match difficulty:
		AiDifficulty.Level.EASY:
			return [1, 2, 1, 2, 4, 2, 1, 2, 1]  # muito central
		AiDifficulty.Level.HARD:
			return [3, 1, 3, 1, 2, 1, 1, 1, 1]  # explora cantos altos
		_:
			return [1, 1, 1, 1, 2, 1, 1, 1, 1]  # NORMAL equilibrado
