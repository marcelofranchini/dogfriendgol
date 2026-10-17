class_name CharacterAnimator
extends Node
## Animações de chute/defesa/comemoração (FR-030, FR-031, FR-053, FR-054).
## As animações apenas apresentam o resultado já decidido e NUNCA alteram o placar
## (FR-025, FR-055).

## A criança cobra com os pés e defende com as mãos e o corpo (FR-030).
func animate_child_kick() -> void:
	pass

## A Branquinha cobra com o focinho e defende com saltos (FR-031).
func animate_dog_kick() -> void:
	pass

## Reação visual distinta para gol, defesa e bola para fora (FR-054).
func show_result_reaction(result: int) -> void:
	match result:
		ShotResult.Result.GOAL:
			_celebrate()
		ShotResult.Result.DEFENDED:
			_defend_pose()
		ShotResult.Result.OUT_OF_BOUNDS:
			_miss_pose()

func _celebrate() -> void:
	pass

func _defend_pose() -> void:
	pass

func _miss_pose() -> void:
	pass
