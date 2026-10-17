class_name ShotZone
## Uma das 9 zonas da meta. Unidade de decisão do cobrador e do defensor (FR-032).
## Domínio puro: sem dependência de nós, cenas ou sinais (Artigo IV).

## 3 colunas × 3 alturas = 9 zonas. A ordem corresponde a (altura * 3 + coluna).
enum Zone {
	TOP_LEFT, TOP_CENTER, TOP_RIGHT,
	MIDDLE_LEFT, MIDDLE_CENTER, MIDDLE_RIGHT,
	BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT,
}

## Converte uma zona nas coordenadas (coluna, altura).
## Coluna: 0 = esquerda, 1 = centro, 2 = direita.
## Altura: 0 = cima, 1 = meio, 2 = baixo.
static func to_grid_coords(zone: int) -> Vector2i:
	return Vector2i(zone % 3, zone / 3)

## Converte (coluna, altura) de volta para a zona.
static func from_grid_coords(col: int, height: int) -> int:
	return height * 3 + col

## Retorna verdadeiro apenas para TOP_LEFT e TOP_RIGHT (os cantos altos).
static func is_top_corner(zone: int) -> bool:
	return zone == Zone.TOP_LEFT or zone == Zone.TOP_RIGHT

## Retorna as 9 zonas (para iteração em testes e na UI).
static func all_zones() -> Array:
	return [
		Zone.TOP_LEFT, Zone.TOP_CENTER, Zone.TOP_RIGHT,
		Zone.MIDDLE_LEFT, Zone.MIDDLE_CENTER, Zone.MIDDLE_RIGHT,
		Zone.BOTTOM_LEFT, Zone.BOTTOM_CENTER, Zone.BOTTOM_RIGHT,
	]
