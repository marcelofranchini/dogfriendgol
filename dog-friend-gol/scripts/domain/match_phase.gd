class_name MatchPhase
## Fase da partida. Transições válidas em data-model.md (FR-026).
## Domínio puro: sem dependência de nós, cenas ou sinais (Artigo IV).

enum Phase {
	NOT_STARTED,    ## Antes do sorteio
	REGULAR,        ## Cinco cobranças iniciais por participante
	SUDDEN_DEATH,   ## Morte súbita após empate
	FINISHED,       ## Partida encerrada com vencedor
}
