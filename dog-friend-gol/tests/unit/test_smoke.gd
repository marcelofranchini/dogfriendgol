extends GutTest

## Teste mínimo para validar que a suíte GUT executa no Godot 4.7.2 headless.
## Será substituído pelos testes reais (T-01 a T-33) durante a implementação.

func test_suite_loads() -> void:
	assert_true(true, "A suíte GUT carrega e executa no Godot 4.7.2")
