class_name ShotResult
## Resultado de uma cobrança. Exatamente três valores possíveis (FR-016).
## Domínio puro: sem dependência de nós, cenas ou sinais (Artigo IV).

enum Result {
	GOAL,           ## O cobrador marcou
	DEFENDED,       ## O defensor defendeu
	OUT_OF_BOUNDS,  ## A bola saiu
}

## Importante: OUT_OF_BOUNDS NÃO é uma zona. Não existe uma décima opção
## selecionável (FR-016). É uma consequência da combinação de zonas.
