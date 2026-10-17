extends GutTest

## SC-010: a IA varia entre partidas (sementes distintas) e é determinística
## com a mesma semente.

func _make_state() -> MatchState:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	var rng: RngPort = GodotRng.new()
	rng.set_seed(1)
	return StartMatchUseCase.start_match(p, rng)

func test_ai_varies_across_seeds() -> void:
	var state: MatchState = _make_state()
	var ai: AiOpponent = AiOpponent.new()
	var choices: Dictionary = {}
	for seed in range(20):
		var rng: RngPort = GodotRng.new()
		rng.set_seed(seed)
		var z: int = ai.choose_shot_zone(state, rng)
		choices[z] = true
	assert_gt(choices.size(), 1, "a IA deve variar entre sementes distintas")

func test_ai_deterministic_same_seed() -> void:
	var state: MatchState = _make_state()
	var ai: AiOpponent = AiOpponent.new()
	var rng1: RngPort = GodotRng.new()
	rng1.set_seed(42)
	var rng2: RngPort = GodotRng.new()
	rng2.set_seed(42)
	assert_eq(ai.choose_shot_zone(state, rng1), ai.choose_shot_zone(state, rng2),
		"mesma semente deve produzir a mesma escolha")
