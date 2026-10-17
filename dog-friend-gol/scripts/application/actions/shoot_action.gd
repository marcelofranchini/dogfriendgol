class_name ShootAction
## Ação: intenção explícita de cobrar (Artigo IV.2). Encapsula a zona do cobrador.

var zone: int = ShotZone.Zone.MIDDLE_CENTER

func _init(chosen_zone: int = ShotZone.Zone.MIDDLE_CENTER) -> void:
	zone = chosen_zone
