class_name ApplyError
## Erros de recusa de uma cobrança (contracts/match-rules.md §5).
## Toda recusa retorna um resultado tipado — nunca altera o estado.

enum Error {
	NONE,
	MATCH_FINISHED,        ## FR-024
	NOT_YOUR_TURN,         ## FR-023
	ALREADY_SHOT_THIS_ROUND,  ## FR-022
	INVALID_ZONE,          ## FR-032
	INVALID_PHASE,         ## FR-026
}
