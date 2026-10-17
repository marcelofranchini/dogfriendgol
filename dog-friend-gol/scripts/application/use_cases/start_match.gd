class_name StartMatchUseCase
## Caso de uso: iniciar uma nova partida (contracts/use-case-api.md §2).
## Monta os 2 participantes a partir do perfil e delega a MatchState.start_match.

## Inicia uma nova partida. Pré: perfil definido, personagem escolhido.
static func start_match(profile: PlayerProfile, rng: RngPort) -> MatchState:
	var child: Participant = Participant.new()
	child.name = profile.child_name
	child.age = profile.child_age
	child.character = CharacterId.Id.CHILD

	var dog: Participant = Participant.new()
	dog.name = profile.dog_name
	dog.age = profile.dog_age
	dog.character = CharacterId.Id.DOG

	var toss: CoinToss = DrawLots.draw_lots(rng)

	var state: MatchState = MatchState.new()
	state.start_match([child, dog], toss)
	return state
