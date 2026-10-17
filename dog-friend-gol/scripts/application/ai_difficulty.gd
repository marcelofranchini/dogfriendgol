class_name AiDifficulty
## Nível de dificuldade da IA (FR-043, contracts/use-case-api.md §4).
## Até 10 anos: EASY ou HARD (duas opções selecionáveis). Acima de 10: NORMAL.

enum Level {
	EASY,    ## mais fácil — para crianças menores
	NORMAL,  ## padrão — acima de 10 anos
	HARD,    ## mais difícil — opção para crianças até 10 anos
}

## Define a dificuldade aplicada à partida (FR-043).
## Se child_age > 10, retorna NORMAL independentemente de chosen.
static func resolve_difficulty(child_age: int, chosen: int) -> int:
	if child_age > 10:
		return Level.NORMAL
	return chosen
