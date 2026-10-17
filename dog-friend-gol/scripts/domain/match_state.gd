class_name MatchState
## Estado completo de uma partida. Única fonte de verdade do placar (FR-049).
## Domínio puro (Artigo IV): sem nós, sem sinais, sem dependência do Godot.

var phase: int = MatchPhase.Phase.NOT_STARTED
var round: int = 1                       ## 1-based
var shooter_index: int = 0               ## 0 ou 1
var participants: Array = []             ## exatamente 2 (I-01)
var score: Array = [0, 0]                ## ≥ 0 (I-02)
var shots_taken: Array = [0, 0]          ## ≥ 0, ≤ 5 em REGULAR (I-03, I-04)
var winner: int = -1                      ## -1 enquanto phase != FINISHED (I-06, I-07)
var attempts: Array = []                 ## size == shots_taken[0] + shots_taken[1] (I-10)

## Inicia a partida (FR-013, FR-014, FR-026, FR-007).
func start_match(parts: Array, coin_toss: CoinToss) -> void:
	participants = parts
	score = [0, 0]
	shots_taken = [0, 0]
	round = 1
	phase = MatchPhase.Phase.REGULAR
	shooter_index = coin_toss.first_shooter_index
	winner = -1
	attempts = []

## Aplica uma cobrança resolvida ao estado (contracts/match-rules.md §3).
## Pré-condições violadas retornam erro, nunca exceção, e não alteram o estado.
func apply_attempt(attempt: ShotAttempt) -> ApplyResult:
	var res: ApplyResult = ApplyResult.new()

	# Pré-condições (FR-024, FR-023, FR-022, FR-026).
	if phase == MatchPhase.Phase.FINISHED:
		res.error = ApplyError.Error.MATCH_FINISHED
		return res
	if phase == MatchPhase.Phase.NOT_STARTED:
		res.error = ApplyError.Error.INVALID_PHASE
		return res
	if attempt.shooter_index != shooter_index:
		res.error = ApplyError.Error.NOT_YOUR_TURN
		return res
	if _already_shot_this_round(attempt.shooter_index):
		res.error = ApplyError.Error.ALREADY_SHOT_THIS_ROUND
		return res

	# Registra a tentativa e atualiza o placar.
	attempt.round = round
	attempts.append(attempt)
	shots_taken[attempt.shooter_index] += 1
	if attempt.result == ShotResult.Result.GOAL:
		score[attempt.shooter_index] += 1

	# Alterna o turno (FR-015).
	shooter_index = 1 - shooter_index

	# Reavalia a fase ANTES de avançar a rodada (a morte súbita precisa dos
	# attempts da rodada atual, ainda com round inalterado).
	_evaluate_phase(res)

	# Avança a rodada somente quando ambos cobraram e a partida continua.
	if _both_shot_this_round() and phase != MatchPhase.Phase.FINISHED:
		round += 1

	return res

## Verdadeiro se o participante em desvantagem não pode mais alcançar o adversário.
## Usa < estritamente (FR-017): se max_possible == score[other], continua.
func can_finish_early() -> bool:
	for i in range(2):
		var remaining: int = MatchConstants.INITIAL_SHOTS_PER_PARTICIPANT - shots_taken[i]
		var max_possible: int = score[i] + remaining
		var other: int = 1 - i
		if max_possible < score[other]:
			return true
	return false

## Reinicia a partida (FR-050). Nenhum resíduo da partida anterior (SC-009).
func reset_match() -> void:
	score = [0, 0]
	shots_taken = [0, 0]
	round = 1
	attempts = []
	winner = -1
	phase = MatchPhase.Phase.NOT_STARTED

## --- internos ---

func _already_shot_this_round(shooter: int) -> bool:
	for a in attempts:
		if a.round == round and a.shooter_index == shooter:
			return true
	return false

func _both_shot_this_round() -> bool:
	var count: int = 0
	for a in attempts:
		if a.round == round:
			count += 1
	return count >= 2

func _evaluate_phase(res: ApplyResult) -> void:
	if phase == MatchPhase.Phase.REGULAR:
		if can_finish_early():
			_finish(_leading_index(), res)
			return
		if _both_took_five():
			if score[0] != score[1]:
				_finish(_leading_index(), res)
			else:
				phase = MatchPhase.Phase.SUDDEN_DEATH
				res.events.append(MatchEvent.Event.PHASE_CHANGED)
	elif phase == MatchPhase.Phase.SUDDEN_DEATH:
		if _both_shot_this_round():
			_evaluate_sudden_death_round(res)

func _both_took_five() -> bool:
	return shots_taken[0] >= MatchConstants.INITIAL_SHOTS_PER_PARTICIPANT \
		and shots_taken[1] >= MatchConstants.INITIAL_SHOTS_PER_PARTICIPANT

func _leading_index() -> int:
	return 0 if score[0] > score[1] else 1

func _finish(winner_index: int, res: ApplyResult) -> void:
	phase = MatchPhase.Phase.FINISHED
	winner = winner_index
	res.events.append(MatchEvent.Event.MATCH_FINISHED)

## Avalia a rodada de morte súbita após ambos cobrarem (FR-019, FR-020, FR-021).
func _evaluate_sudden_death_round(res: ApplyResult) -> void:
	var round_attempts: Array = []
	for a in attempts:
		if a.round == round:
			round_attempts.append(a)
	if round_attempts.size() < 2:
		return  # nunca encerra antes do 2º cobrar (FR-021)
	var a0: ShotAttempt = round_attempts[0]
	var a1: ShotAttempt = round_attempts[1]
	var scored0: bool = a0.result == ShotResult.Result.GOAL
	var scored1: bool = a1.result == ShotResult.Result.GOAL
	if scored0 != scored1:
		_finish(a0.shooter_index if scored0 else a1.shooter_index, res)
	# se ambos marcaram ou ambos não marcaram, continua (FR-020)
