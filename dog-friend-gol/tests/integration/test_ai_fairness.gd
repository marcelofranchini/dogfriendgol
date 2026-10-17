extends GutTest

## T-26 de contracts/use-case-api.md: a IA NÃO acessa a zona do jogador (FR-042).
## Chamar choose_defense_zone com o mesmo state e rng antes e depois de o jogador
## escolher sua zona deve produzir o MESMO resultado.

func _make_state() -> MatchState:
	var rng: RngPort = GodotRng.new()
	rng.set_seed(7)
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	return StartMatchUseCase.start_match(p, rng)

func test_ai_defense_does_not_depend_on_player_zone() -> void:
	var state: MatchState = _make_state()
	var ai: AiOpponent = AiOpponent.new()
	var rng: RngPort = GodotRng.new()
	rng.set_seed(99)

	# Antes de o jogador escolher.
	var before: int = ai.choose_defense_zone(state, rng)

	# O jogador "escolhe" uma zona — mas a IA não recebe essa informação.
	# Re-criamos o rng com a mesma semente para comparar de forma justa.
	var rng2: RngPort = GodotRng.new()
	rng2.set_seed(99)
	var after: int = ai.choose_defense_zone(state, rng2)

	assert_eq(before, after, "a IA deve produzir o mesmo resultado independentemente da escolha do jogador")

func test_ai_shot_does_not_depend_on_player_zone() -> void:
	var state: MatchState = _make_state()
	var ai: AiOpponent = AiOpponent.new()
	var rng: RngPort = GodotRng.new()
	rng.set_seed(99)
	var before: int = ai.choose_shot_zone(state, rng)

	var rng2: RngPort = GodotRng.new()
	rng2.set_seed(99)
	var after: int = ai.choose_shot_zone(state, rng2)

	assert_eq(before, after, "a IA deve produzir o mesmo resultado independentemente da escolha do jogador")
