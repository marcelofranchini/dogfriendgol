class_name InputZoneSelector
extends RefCounted
## Adapter inbound: traduz a posição de toque/clique em uma das 9 zonas
## (contracts/use-case-api.md §7). Mouse e teclado (FR-033).

## Traduz a posição local em uma das 9 zonas. Retorna -1 se fora da meta.
## A grade é 3 colunas × 3 alturas. O retângulo da meta é dividido igualmente.
func zone_at_position(local_pos: Vector2, goal_rect: Rect2) -> int:
	if not goal_rect.has_point(local_pos):
		return -1
	var rel: Vector2 = local_pos - goal_rect.position
	var col: int = int(rel.x / (goal_rect.size.x / 3.0))
	var height: int = int(rel.y / (goal_rect.size.y / 3.0))
	col = clampi(col, 0, 2)
	height = clampi(height, 0, 2)
	return ShotZone.from_grid_coords(col, height)

## Destaque visual da zona sob o cursor/toque.
func highlight_zone(zone: int) -> void:
	pass
