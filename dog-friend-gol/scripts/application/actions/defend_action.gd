class_name DefendAction
## Ação: intenção explícita de defender (Artigo IV.2). Encapsula a zona do defensor.

var zone: int = ShotZone.Zone.MIDDLE_CENTER

func _init(chosen_zone: int = ShotZone.Zone.MIDDLE_CENTER) -> void:
	zone = chosen_zone
