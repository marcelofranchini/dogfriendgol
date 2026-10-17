class_name MatchView
extends Control
## Apresentação da tela de partida. Recebe o placar via sinal e apenas o exibe
## (FR-046, FR-047, FR-049). NÃO calcula placar.

@onready var scoreboard: ScoreboardView = $Scoreboard

## Nomes de exibição dos participantes (FR-008). O domínio não conhece nomes fixos
## (Artigo VI.3); a apresentação recebe os nomes do cadastro.
var participant_names: Array = ["", ""]

## Define os nomes de exibição a partir do perfil (FR-008).
func set_participant_names(child_name: String, dog_name: String) -> void:
	participant_names = [child_name, dog_name]

## Conecta aos sinais do controller. A view apenas reflete o estado.
func bind(controller: MatchController) -> void:
	controller.score_changed.connect(_on_score_changed)
	controller.attempt_resolved.connect(_on_attempt_resolved)
	controller.turn_changed.connect(_on_turn_changed)
	controller.match_finished.connect(_on_match_finished)

func _on_score_changed(score: Array) -> void:
	scoreboard.update_score(score)

func _on_attempt_resolved(outcome: AttemptOutcome) -> void:
	scoreboard.show_attempt_result(outcome.result)

func _on_turn_changed(shooter_index: int) -> void:
	scoreboard.update_turn(shooter_index, 1 - shooter_index)

func _on_match_finished(winner_index: int, final_score: Array) -> void:
	# A navegação para a tela final é responsabilidade do screen_router (US2).
	pass
