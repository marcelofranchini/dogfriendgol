class_name Participant
## Um dos dois lados da partida (data-model.md). Domínio puro (Artigo IV).

var name: String = ""          ## Não vazio (FR-045)
var age: int = 0               ## ≥ 0; idade fora de faixa plausível não bloqueia o jogo
var character: int = CharacterId.Id.CHILD  ## CHILD ou DOG
var goals: int = 0             ## ≥ 0; espelha score
var shots_taken: int = 0       ## ≥ 0
