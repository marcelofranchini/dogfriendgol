extends GutTest

## T-10 a T-25 de contracts/match-rules.md — estado da partida, invariantes,
## encerramento antecipado, morte súbita e recusas.

const Z = ShotZone.Zone
const R = ShotResult.Result
const P = MatchPhase.Phase

func _make_participants() -> Array:
	var a: Participant = Participant.new()
	a.name = "Crianca"
	a.age = 8
	a.character = CharacterId.Id.CHILD
	var b: Participant = Participant.new()
	b.name = "Branquinha"
	b.age = 5
	b.character = CharacterId.Id.DOG
	return [a, b]

func _make_toss(first: int = 0) -> CoinToss:
	var t: CoinToss = CoinToss.new()
	t.first_shooter_index = first
	return t

func _started() -> MatchState:
	var s: MatchState = MatchState.new()
	s.start_match(_make_participants(), _make_toss())
	return s

func _attempt(shooter: int, shooter_zone: int, defender_zone: int) -> ShotAttempt:
	var a: ShotAttempt = ShotAttempt.new()
	a.shooter_index = shooter
	a.shooter_zone = shooter_zone
	a.defender_zone = defender_zone
	a.result = MatchRules.resolve_shot(shooter_zone, defender_zone)
	return a

func test_t10_score_starts_zero() -> void:
	var s: MatchState = _started()
	assert_eq(s.score, [0, 0], "placar inicia 0-0")

func test_t11_five_shots_each() -> void:
	var s: MatchState = _started()
	assert_eq(s.shots_taken, [0, 0], "0 cobranças no início")
	assert_eq(MatchConstants.INITIAL_SHOTS_PER_PARTICIPANT, 5, "5 cobranças iniciais")

func test_t12_turns_alternate() -> void:
	var s: MatchState = _started()
	var first: int = s.shooter_index
	s.apply_attempt(_attempt(first, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_eq(s.shooter_index, 1 - first, "turno alterna após a cobrança")

func test_t13_early_finish_correct() -> void:
	# Placar 3-0 com 2 restantes para quem tem 0: 0+2=2 < 3 -> encerra.
	var s: MatchState = _started()
	s.score = [3, 0]
	s.shots_taken = [3, 3]
	s.shooter_index = 1
	s.apply_attempt(_attempt(1, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_eq(s.phase, P.FINISHED, "deve encerrar antecipadamente")
	assert_eq(s.winner, 0, "vencedor é quem lidera")

func test_t14_no_early_finish_at_exact_limit() -> void:
	# Placar 3-1 com 2 restantes para quem tem 1: 1+2=3 == 3 -> continua.
	var s: MatchState = _started()
	s.score = [3, 1]
	s.shots_taken = [3, 3]
	s.shooter_index = 1
	s.apply_attempt(_attempt(1, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_ne(s.phase, P.FINISHED, "não deve encerrar no limite exato")

func test_t15_tie_after_five_enters_sudden_death() -> void:
	var s: MatchState = _started()
	# Força empate: ambos com 5 cobranças e placar igual.
	# O participante 0 cobra a 5ª e NÃO marca (mesma zona -> DEFENDED), mantendo 2-2.
	s.score = [2, 2]
	s.shots_taken = [4, 5]
	s.shooter_index = 0
	s.apply_attempt(_attempt(0, Z.MIDDLE_CENTER, Z.MIDDLE_CENTER))  # DEFENDED, não marca
	assert_eq(s.phase, P.SUDDEN_DEATH, "empate após 5+5 entra em morte súbita")

func test_t16_sudden_death_ends_on_different_results() -> void:
	var s: MatchState = _started()
	s.phase = P.SUDDEN_DEATH
	s.score = [2, 2]
	s.shots_taken = [5, 5]
	s.shooter_index = 0
	# 0 marca (GOAL), 1 não marca (DEFENDED) -> 0 vence.
	s.apply_attempt(_attempt(0, Z.MIDDLE_CENTER, Z.TOP_LEFT))  # GOAL
	assert_eq(s.phase, P.SUDDEN_DEATH, "ainda não encerra após o 1º cobrar")
	s.apply_attempt(_attempt(1, Z.MIDDLE_CENTER, Z.MIDDLE_CENTER))  # DEFENDED
	assert_eq(s.phase, P.FINISHED, "encerra após o 2º cobrar")
	assert_eq(s.winner, 0, "vencedor é quem marcou")

func test_t17_sudden_death_continues_on_equal_results() -> void:
	var s: MatchState = _started()
	s.phase = P.SUDDEN_DEATH
	s.score = [2, 2]
	s.shots_taken = [5, 5]
	s.shooter_index = 0
	s.apply_attempt(_attempt(0, Z.MIDDLE_CENTER, Z.TOP_LEFT))  # GOAL
	s.apply_attempt(_attempt(1, Z.MIDDLE_CENTER, Z.TOP_LEFT))  # GOAL
	assert_eq(s.phase, P.SUDDEN_DEATH, "ambos marcaram -> continua")

func test_t18_no_winner_before_second_shooter() -> void:
	var s: MatchState = _started()
	s.phase = P.SUDDEN_DEATH
	s.score = [2, 2]
	s.shots_taken = [5, 5]
	s.shooter_index = 0
	s.apply_attempt(_attempt(0, Z.MIDDLE_CENTER, Z.TOP_LEFT))  # 0 marca
	assert_eq(s.phase, P.SUDDEN_DEATH, "nenhum vencedor antes do 2º cobrar")
	assert_eq(s.winner, -1, "winner ainda -1")

func test_t19_duplicate_shot_rejected() -> void:
	var s: MatchState = _started()
	var first: int = s.shooter_index
	s.apply_attempt(_attempt(first, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	# O turno alternou para o outro participante. Forçamos o turno de volta para
	# o mesmo participante para testar a recusa de cobrança duplicada na rodada.
	s.shooter_index = first
	var before: Array = s.score.duplicate()
	var res: ApplyResult = s.apply_attempt(_attempt(first, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_eq(res.error, ApplyError.Error.ALREADY_SHOT_THIS_ROUND, "cobrança duplicada recusada")
	assert_eq(s.score, before, "placar inalterado")

func test_t20_out_of_turn_rejected() -> void:
	var s: MatchState = _started()
	var first: int = s.shooter_index
	var res: ApplyResult = s.apply_attempt(_attempt(1 - first, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_eq(res.error, ApplyError.Error.NOT_YOUR_TURN, "cobrança fora do turno recusada")

func test_t21_change_after_finish_rejected() -> void:
	var s: MatchState = _started()
	s.phase = P.FINISHED
	s.winner = 0
	var res: ApplyResult = s.apply_attempt(_attempt(0, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_eq(res.error, ApplyError.Error.MATCH_FINISHED, "alteração após encerramento recusada")

func test_t22_score_independent_of_animation() -> void:
	# O placar é derivado apenas do estado; não há dependência de animação.
	var s: MatchState = _started()
	var first: int = s.shooter_index
	s.apply_attempt(_attempt(first, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_eq(s.score[first], 1, "GOAL incrementa o placar do cobrador")

func test_t23_invariants_hold_after_operations() -> void:
	var s: MatchState = _started()
	var first: int = s.shooter_index
	for i in range(4):
		s.apply_attempt(_attempt(s.shooter_index, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	assert_eq(s.participants.size(), 2, "I-01: 2 participantes")
	assert_true(s.score[0] >= 0 and s.score[1] >= 0, "I-02: score >= 0")
	assert_true(s.shots_taken[0] >= 0 and s.shots_taken[1] >= 0, "I-03: shots_taken >= 0")
	assert_true(s.shots_taken[0] <= 5 and s.shots_taken[1] <= 5, "I-04: <= 5 em REGULAR")
	assert_eq(s.attempts.size(), s.shots_taken[0] + s.shots_taken[1], "I-10: attempts == soma")

func test_t24_reset_leaves_no_residue() -> void:
	var s: MatchState = _started()
	s.apply_attempt(_attempt(s.shooter_index, Z.MIDDLE_CENTER, Z.TOP_LEFT))
	s.phase = P.FINISHED
	s.winner = 0
	s.reset_match()
	assert_eq(s.score, [0, 0], "placar zerado")
	assert_eq(s.shots_taken, [0, 0], "cobranças zeradas")
	assert_eq(s.round, 1, "round == 1")
	assert_eq(s.attempts.size(), 0, "attempts vazio")
	assert_eq(s.winner, -1, "winner == -1")
	assert_eq(s.phase, P.NOT_STARTED, "phase == NOT_STARTED")

func test_t25_prolonged_sudden_death() -> void:
	var s: MatchState = _started()
	s.phase = P.SUDDEN_DEATH
	s.score = [2, 2]
	s.shots_taken = [5, 5]
	s.shooter_index = 0
	# 10+ rodadas de empate (ambos marcam ou ambos não marcam).
	for round in range(12):
		s.apply_attempt(_attempt(0, Z.MIDDLE_CENTER, Z.TOP_LEFT))  # GOAL
		s.apply_attempt(_attempt(1, Z.MIDDLE_CENTER, Z.TOP_LEFT))  # GOAL
		assert_eq(s.phase, P.SUDDEN_DEATH, "morte súbita prolongada continua")
