class_name MatchController
extends RefCounted
## Adapter inbound: traduz a intenção do jogador em chamada de caso de uso e
## emite sinais para a apresentação (contracts/use-case-api.md §5).
## NÃO calcula placar (FR-049) — apenas reflete o estado.

signal score_changed(score: Array)
signal attempt_resolved(outcome: AttemptOutcome)
signal turn_changed(shooter_index: int)
signal match_finished(winner_index: int, final_score: Array)

var state: MatchState = null
var ai = null          ## adapter de IA (duck-typed, definido na US3)
var rng: RngPort = null
var player_index: int = 0  ## índice do participante controlado pelo jogador (FR-027)

func _init(match_state: MatchState, ai_adapter, rng_port: RngPort) -> void:
	state = match_state
	ai = ai_adapter
	rng = rng_port

## O jogador escolheu uma zona. Resolve a cobrança e emite os sinais na ordem
## correta (FR-025): placar atualizado ANTES de attempt_resolved.
func on_zone_selected(zone: int) -> AttemptOutcome:
	var outcome: AttemptOutcome = ResolveAttemptUseCase.resolve_attempt(state, zone, ai, rng, player_index)
	# 3. emite score_changed (UI atualiza imediatamente)
	score_changed.emit(state.score)
	# 4. emite attempt_resolved (animação começa)
	attempt_resolved.emit(outcome)
	# 5. se terminou, emite match_finished
	if state.phase == MatchPhase.Phase.FINISHED:
		match_finished.emit(state.winner, state.score)
	return outcome

## Desconecta todos os sinais (T-30, FR-050): evita que uma tentativa antiga
## altere a partida nova após o reinício.
func disconnect_all() -> void:
	for sig in [&"score_changed", &"attempt_resolved", &"turn_changed", &"match_finished"]:
		var connections: Array = get_signal_connection_list(sig)
		for conn in connections:
			var callable: Callable = conn["callable"]
			if callable.is_valid():
				disconnect(sig, callable)
