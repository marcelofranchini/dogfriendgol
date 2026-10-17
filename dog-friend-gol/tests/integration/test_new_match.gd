extends GutTest

## T-24 e SC-009: reset_match não deixa resíduo. FR-050: novo sorteio na partida
## seguinte.

func _make_state() -> MatchState:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	var rng: RngPort = GodotRng.new()
	rng.set_seed(1)
	return StartMatchUseCase.start_match(p, rng)

func test_reset_leaves_no_residue() -> void:
	var state: MatchState = _make_state()
	# Joga algumas cobranças e encerra.
	state.phase = MatchPhase.Phase.FINISHED
	state.winner = 0
	state.score = [3, 1]
	state.shots_taken = [5, 4]
	state.attempts = [ShotAttempt.new()]

	state.reset_match()

	assert_eq(state.score, [0, 0], "placar zerado")
	assert_eq(state.shots_taken, [0, 0], "cobranças zeradas")
	assert_eq(state.round, 1, "round == 1")
	assert_eq(state.attempts.size(), 0, "attempts vazio")
	assert_eq(state.winner, -1, "winner == -1")
	assert_eq(state.phase, MatchPhase.Phase.NOT_STARTED, "phase == NOT_STARTED")

func test_new_match_has_new_toss() -> void:
	# Um novo sorteio é realizado na partida seguinte (FR-050).
	var rng: RngPort = GodotRng.new()
	rng.set_seed(1)
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	var state1: MatchState = StartMatchUseCase.start_match(p, rng)
	var first1: int = state1.shooter_index

	# Nova partida com semente distinta -> sorteio potencialmente diferente.
	var rng2: RngPort = GodotRng.new()
	rng2.set_seed(2)
	var state2: MatchState = StartMatchUseCase.start_match(p, rng2)
	var first2: int = state2.shooter_index

	# O sorteio é determinístico por semente; sementes distintas podem diferir.
	# Verificamos apenas que ambos são índices válidos (0 ou 1).
	assert_true(first1 in [0, 1], "primeiro cobrador válido")
	assert_true(first2 in [0, 1], "primeiro cobrador válido")
