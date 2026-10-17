extends GutTest

## T-01 a T-07 de contracts/zone-grid.md — a regra de resolução das 81 combinações.
## Cobre SC-005a (100% das 81 combinações) e SC-002 (cada cobrança válida produz
## exatamente um resultado).

const Z = ShotZone.Zone
const R = ShotResult.Result

func test_t01_all_81_combinations_match_matrix() -> void:
	# A matriz completa: para cada par (cobrador, defensor), o resultado esperado.
	for shooter in ShotZone.all_zones():
		for defender in ShotZone.all_zones():
			var expected: int = _expected(shooter, defender)
			var actual: int = MatchRules.resolve_shot(shooter, defender)
			assert_eq(actual, expected,
				"resolve_shot(%d, %d) deveria ser %d" % [shooter, defender, expected])

func test_t02_diagonal_always_defended() -> void:
	for z in ShotZone.all_zones():
		assert_eq(MatchRules.resolve_shot(z, z), R.DEFENDED,
			"mesma zona deve ser DEFENDED para zona %d" % z)

func test_t03_top_left_out_of_bounds_against_different() -> void:
	for x in ShotZone.all_zones():
		if x == Z.TOP_LEFT:
			continue
		assert_eq(MatchRules.resolve_shot(Z.TOP_LEFT, x), R.OUT_OF_BOUNDS,
			"TOP_LEFT contra %d deve ser OUT_OF_BOUNDS" % x)

func test_t04_top_right_out_of_bounds_against_different() -> void:
	for x in ShotZone.all_zones():
		if x == Z.TOP_RIGHT:
			continue
		assert_eq(MatchRules.resolve_shot(Z.TOP_RIGHT, x), R.OUT_OF_BOUNDS,
			"TOP_RIGHT contra %d deve ser OUT_OF_BOUNDS" % x)

func test_t05_middle_never_out_of_bounds() -> void:
	var middle: Array = [Z.MIDDLE_LEFT, Z.MIDDLE_CENTER, Z.MIDDLE_RIGHT]
	for shooter in middle:
		for defender in ShotZone.all_zones():
			assert_ne(MatchRules.resolve_shot(shooter, defender), R.OUT_OF_BOUNDS,
				"zona MIDDLE %d nunca deve produzir OUT_OF_BOUNDS" % shooter)

func test_t06_determinism_1000_reps() -> void:
	for shooter in ShotZone.all_zones():
		for defender in ShotZone.all_zones():
			var first: int = MatchRules.resolve_shot(shooter, defender)
			for i in range(1000):
				assert_eq(MatchRules.resolve_shot(shooter, defender), first,
					"determinismo violado em (%d, %d)" % [shooter, defender])

func test_t07_counts_9_16_56() -> void:
	var defended: int = 0
	var out: int = 0
	var goal: int = 0
	for shooter in ShotZone.all_zones():
		for defender in ShotZone.all_zones():
			match MatchRules.resolve_shot(shooter, defender):
				R.DEFENDED:
					defended += 1
				R.OUT_OF_BOUNDS:
					out += 1
				R.GOAL:
					goal += 1
	assert_eq(defended, 9, "9 DEFENDED")
	assert_eq(out, 16, "16 OUT_OF_BOUNDS")
	assert_eq(goal, 56, "56 GOAL")
	assert_eq(defended + out + goal, 81, "total 81")

## Resultado esperado pela regra (FR-060): igualdade primeiro, depois canto alto.
func _expected(shooter: int, defender: int) -> int:
	if shooter == defender:
		return R.DEFENDED
	if ShotZone.is_top_corner(shooter):
		return R.OUT_OF_BOUNDS
	return R.GOAL
