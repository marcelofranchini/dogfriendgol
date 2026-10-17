class_name TouchZoneSelector
extends RefCounted
## Adapter inbound: seleção de zona por toque (FR-033, Artigo VIII.3).
## Produz a MESMA zona que o mouse/teclado (Artigo VIII.4).

## Traduz a posição de toque em uma das 9 zonas. Retorna -1 se fora da meta.
func zone_at_position(local_pos: Vector2, goal_rect: Rect2) -> int:
	if not goal_rect.has_point(local_pos):
		return -1
	var rel: Vector2 = local_pos - goal_rect.position
	var col: int = int(rel.x / (goal_rect.size.x / 3.0))
	var height: int = int(rel.y / (goal_rect.size.y / 3.0))
	col = clampi(col, 0, 2)
	height = clampi(height, 0, 2)
	return ShotZone.from_grid_coords(col, height)

func highlight_zone(zone: int) -> void:
	pass
