extends GutTest

## T-08 e T-09 de contracts/zone-grid.md — conversões de zona e propriedades.

const Z = ShotZone.Zone

func test_t08_grid_coords_are_inverse() -> void:
	for z in ShotZone.all_zones():
		var coords: Vector2i = ShotZone.to_grid_coords(z)
		var back: int = ShotZone.from_grid_coords(coords.x, coords.y)
		assert_eq(back, z, "to_grid_coords/from_grid_coords devem ser inversas para %d" % z)

func test_t08b_grid_coords_mapping() -> void:
	# Coluna 0=esquerda, 1=centro, 2=direita; altura 0=cima, 1=meio, 2=baixo.
	assert_eq(ShotZone.to_grid_coords(Z.TOP_LEFT), Vector2i(0, 0))
	assert_eq(ShotZone.to_grid_coords(Z.TOP_CENTER), Vector2i(1, 0))
	assert_eq(ShotZone.to_grid_coords(Z.TOP_RIGHT), Vector2i(2, 0))
	assert_eq(ShotZone.to_grid_coords(Z.MIDDLE_LEFT), Vector2i(0, 1))
	assert_eq(ShotZone.to_grid_coords(Z.MIDDLE_CENTER), Vector2i(1, 1))
	assert_eq(ShotZone.to_grid_coords(Z.MIDDLE_RIGHT), Vector2i(2, 1))
	assert_eq(ShotZone.to_grid_coords(Z.BOTTOM_LEFT), Vector2i(0, 2))
	assert_eq(ShotZone.to_grid_coords(Z.BOTTOM_CENTER), Vector2i(1, 2))
	assert_eq(ShotZone.to_grid_coords(Z.BOTTOM_RIGHT), Vector2i(2, 2))

func test_t09_all_zones_returns_nine_distinct() -> void:
	var zones: Array = ShotZone.all_zones()
	assert_eq(zones.size(), 9, "all_zones deve retornar 9 zonas")
	var seen: Dictionary = {}
	for z in zones:
		assert_false(seen.has(z), "zona duplicada: %d" % z)
		seen[z] = true

func test_t09b_is_top_corner_only_two() -> void:
	var corners: int = 0
	for z in ShotZone.all_zones():
		if ShotZone.is_top_corner(z):
			corners += 1
	assert_eq(corners, 2, "apenas TOP_LEFT e TOP_RIGHT são cantos altos")
