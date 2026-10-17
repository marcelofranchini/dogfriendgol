class_name StartAttemptUseCase
## Caso de uso: preparar uma cobrança sem resolver nada (contracts/use-case-api.md §2).
## Retorna o contexto que a apresentação precisa para animar a preparação.

## Contexto de preparação de uma cobrança.
class AttemptContext:
	var shooter_index: int = 0
	var defender_index: int = 0

## Prepara uma cobrança. Não resolve nada ainda.
static func start_attempt(state: MatchState) -> AttemptContext:
	var ctx: AttemptContext = AttemptContext.new()
	ctx.shooter_index = state.shooter_index
	ctx.defender_index = 1 - state.shooter_index
	return ctx
