class_name ResolveAttemptUseCase
## Caso de uso central: resolve uma cobrança e atualiza o estado
## (contracts/use-case-api.md §2, §5). A resolução ocorre ANTES de qualquer animação.

## Resolve uma cobrança e atualiza o estado.
##
## Parâmetros:
##   player_zone: zona escolhida pelo jogador
##   ai: implementação da IA (adapter) — duck-typed, sem acoplamento estático
##   rng: fonte de aleatoriedade (adapter)
##   player_index: índice do participante controlado pelo jogador (FR-027)
##
## Retorna: AttemptOutcome com o resultado e o estado atualizado.
static func resolve_attempt(state: MatchState, player_zone: int, ai, rng: RngPort, player_index: int = 0) -> AttemptOutcome:
	var outcome: AttemptOutcome = AttemptOutcome.new()
	var shooter: int = state.shooter_index
	var defender: int = 1 - shooter

	# Determina as duas zonas conforme o papel do jogador.
	# A IA decide SEM conhecer a zona do jogador (FR-042).
	var shooter_zone: int
	var defender_zone: int
	if shooter == player_index:
		shooter_zone = player_zone
		defender_zone = ai.choose_defense_zone(state, rng)
	else:
		shooter_zone = ai.choose_shot_zone(state, rng)
		defender_zone = player_zone

	# 1. Calcula o resultado (ANTES de qualquer animação — FR-025).
	var result: int = MatchRules.resolve_shot(shooter_zone, defender_zone)

	# 2. Aplica ao estado.
	var attempt: ShotAttempt = ShotAttempt.new()
	attempt.shooter_index = shooter
	attempt.shooter_zone = shooter_zone
	attempt.defender_zone = defender_zone
	attempt.result = result
	var apply_res: ApplyResult = state.apply_attempt(attempt)

	# Monta o outcome com o estado APÓS a cobrança.
	outcome.shooter_index = shooter
	outcome.defender_index = defender
	outcome.shooter_zone = shooter_zone
	outcome.defender_zone = defender_zone
	outcome.result = result
	outcome.state = state
	outcome.events = apply_res.events

	return outcome
