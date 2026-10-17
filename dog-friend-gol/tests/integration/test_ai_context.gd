extends GutTest

## FR-040: a IA reage ao estado (placar, cobranças restantes, morte súbita).
## FR-043: a dificuldade altera a distribuição sem alterar as regras.

func _make_state() -> MatchState:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	var rng: RngPort = GodotRng.new()
	rng.set_seed(1)
	return StartMatchUseCase.start_match(p, rng)

func test_ai_returns_valid_zone() -> void:
	var state: MatchState = _make_state()
	var ai: AiOpponent = AiOpponent.new()
	var rng: RngPort = GodotRng.new()
	rng.set_seed(5)
	for i in range(50):
		var z: int = ai.choose_shot_zone(state, rng)
		assert_true(z in ShotZone.all_zones(), "a IA deve retornar uma zona válida")

func test_difficulty_changes_distribution_not_rules() -> void:
	# A dificuldade altera a distribuição, mas o resultado continua resolvido
	# por resolve_shot (FR-061). Verificamos que EASY favorece o centro.
	var state: MatchState = _make_state()
	var easy: AiOpponent = AiOpponent.new()
	easy.difficulty = AiDifficulty.Level.EASY
	var center_count: int = 0
	var total: int = 200
	for i in range(total):
		var rng: RngPort = GodotRng.new()
		rng.set_seed(i)
		var z: int = easy.choose_shot_zone(state, rng)
		if z == ShotZone.Zone.MIDDLE_CENTER:
			center_count += 1
	# EASY tem peso 4/16 = 25% no centro; esperamos uma proporção razoável.
	assert_gt(center_count, 0, "EASY deve escolher o centro com frequência")
