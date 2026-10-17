class_name CharacterId
## Personagem associado a um participante (FR-004).
## Domínio puro: sem dependência de nós, cenas ou sinais (Artigo IV).

enum Id {
	CHILD,  ## A criança
	DOG,    ## A Branquinha
}

## Nota (Artigo VI.3): "Pedro" e "Branquinha" são valores de exibição, não
## constantes do domínio. O domínio conhece apenas CHILD e DOG.
