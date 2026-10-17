class_name GameBootstrap
## Composição de dependências (Artigo IV — Bootstrap).
## Instancia as dependências concretas e as expõe às cenas. Sem lógica de jogo.

var rng: RngPort

func _init() -> void:
	rng = GodotRng.new()
