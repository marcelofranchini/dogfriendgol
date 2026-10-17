class_name ResetMatchUseCase
## Caso de uso: reiniciar a partida, descartando todo o estado anterior (FR-050).

## Reinicia a partida. Retorna o estado reiniciado.
static func reset_match(state: MatchState) -> MatchState:
	state.reset_match()
	return state
