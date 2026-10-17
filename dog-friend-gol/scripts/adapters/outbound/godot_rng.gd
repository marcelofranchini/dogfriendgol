class_name GodotRng
extends RngPort
## Implementação concreta de RngPort usando RandomNumberGenerator (R-04).
## Camada Adapters/outbound — traduz o mecanismo do Godot para o contrato.

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func next_int(max_exclusive: int) -> int:
	return _rng.randi_range(0, max_exclusive - 1)

func set_seed(seed: int) -> void:
	_rng.seed = seed
