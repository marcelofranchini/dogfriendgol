class_name MatchRules
## Regra de resolução de uma cobrança (FR-060, contracts/zone-grid.md).
## Função pura: sem aleatoriedade (FR-061), sem estado global, sem nós, sem sinais (FR-063).

## Resolve uma cobrança de forma determinística.
## Ordem importa: igualdade PRIMEIRO (mesma zona -> DEFENDED, inclusive quando o
## defensor pega o mesmo canto alto), depois canto alto -> OUT_OF_BOUNDS, senão GOAL.
static func resolve_shot(shooter_zone: int, defender_zone: int) -> int:
	if shooter_zone == defender_zone:
		return ShotResult.Result.DEFENDED
	if ShotZone.is_top_corner(shooter_zone):
		return ShotResult.Result.OUT_OF_BOUNDS
	return ShotResult.Result.GOAL
