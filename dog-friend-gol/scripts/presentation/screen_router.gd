class_name ScreenRouter
extends RefCounted
## Navegação entre telas (FR-001, FR-002, FR-012).
## menu -> cadastro -> escolha de personagem -> partida -> final -> menu.

enum Screen {
	MAIN_MENU,
	REGISTRATION,
	CHARACTER_SELECT,
	MATCH,
	ENDING,
}

var current: int = Screen.MAIN_MENU

func go_to(screen: int) -> void:
	current = screen
