class_name PlayerProfile
## Perfil do jogador informado antes da partida (contracts/use-case-api.md §3).

var child_name: String = ""      ## não vazio (FR-045)
var child_age: int = 0           ## preenchido (FR-003)
var dog_name: String = ""        ## não vazio (FR-045)
var dog_age: int = 0             ## preenchido (FR-003)
var controlled_character: int = CharacterId.Id.CHILD  ## CHILD ou DOG (FR-004)
