extends GutTest

## Teste de integração do fluxo completo de US1: MatchController + resolve_attempt
## + AiOpponent, de ponta a ponta (T041 evidência, SC-005 determinismo).

const Z = ShotZone.Zone

func _make_profile() -> PlayerProfile:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	p.controlled_character = CharacterId.Id.CHILD
	return p

func _make_controller() -> MatchController:
	var rng: RngPort = GodotRng.new()
	rng.set_seed(123)
	var state: MatchState = StartMatchUseCase.start_match(_make_profile(), rng)
	var ai: AiOpponent = AiOpponent.new()
	ai.difficulty = AiDifficulty.Level.NORMAL
	return MatchController.new(state, ai, rng)

func test_full_flow_resolves_attempts() -> void:
	var ctrl: MatchController = _make_controller()
	var outcome: AttemptOutcome = ctrl.on_zone_selected(Z.MIDDLE_CENTER)
	assert_not_null(outcome, "resolve_attempt retorna um AttemptOutcome")
	assert_true(outcome.result in [ShotResult.Result.GOAL, ShotResult.Result.DEFENDED, ShotResult.Result.OUT_OF_BOUNDS],
		"resultado é um dos três valores válidos")

func test_determinism_same_sequence_same_score() -> void:
	# Mesma semente e mesma sequência de zonas -> mesmo placar final (SC-005).
	var score1: Array = _run_sequence(123)
	var score2: Array = _run_sequence(123)
	assert_eq(score1, score2, "mesma sequência produz o mesmo placar")

func _run_sequence(seed: int) -> Array:
	var rng: RngPort = GodotRng.new()
	rng.set_seed(seed)
	var state: MatchState = StartMatchUseCase.start_match(_make_profile(), rng)
	var ai: AiOpponent = AiOpponent.new()
	ai.difficulty = AiDifficulty.Level.NORMAL
	var ctrl: MatchController = MatchController.new(state, ai, rng)
	# Sequência fixa de zonas do jogador.
	var zones: Array = [Z.MIDDLE_CENTER, Z.TOP_LEFT, Z.BOTTOM_RIGHT, Z.MIDDLE_LEFT, Z.TOP_CENTER]
	for z in zones:
		if state.phase == MatchPhase.Phase.FINISHED:
			break
		ctrl.on_zone_selected(z)
	return state.score
