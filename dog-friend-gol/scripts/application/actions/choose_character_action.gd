class_name ChooseCharacterAction
## Ação: escolha do protagonista controlado pelo jogador (FR-004).
## A escolha permanece válida durante toda a partida.

var character: int = CharacterId.Id.CHILD

func _init(chosen: int = CharacterId.Id.CHILD) -> void:
	character = chosen
