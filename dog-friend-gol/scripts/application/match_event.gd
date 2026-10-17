class_name MatchEvent
## Eventos emitidos para a apresentação reagir (contracts/use-case-api.md §3).
## Camada Application. Não é emitido pelo domínio (o domínio não depende do Godot).

enum Event {
	ATTEMPT_RESOLVED,  ## uma cobrança terminou
	TURN_CHANGED,      ## trocou quem cobra
	ROUND_CHANGED,     ## nova rodada
	PHASE_CHANGED,     ## REGULAR -> SUDDEN_DEATH, etc.
	EARLY_FINISH,      ## encerramento antecipado (FR-017)
	MATCH_FINISHED,    ## partida terminou
}
