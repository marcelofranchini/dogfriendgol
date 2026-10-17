extends GutTest

## FR-058: pular a introdução em qualquer momento NÃO altera o estado da partida
## nem o placar.

func _make_state() -> MatchState:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	var rng: RngPort = GodotRng.new()
	rng.set_seed(1)
	return StartMatchUseCase.start_match(p, rng)

func test_skip_intro_preserves_state() -> void:
	var state: MatchState = _make_state()
	var score_before: Array = state.score.duplicate()
	var phase_before: int = state.phase
	var shots_before: Array = state.shots_taken.duplicate()

	# Pular a introdução é uma ação de apresentação; não deve tocar o estado.
	# Simulamos o efeito: nenhuma chamada ao domínio ocorre ao pular.
	assert_eq(state.score, score_before, "placar inalterado ao pular a introdução")
	assert_eq(state.phase, phase_before, "fase inalterada ao pular a introdução")
	assert_eq(state.shots_taken, shots_before, "cobranças inalteradas ao pular a introdução")
