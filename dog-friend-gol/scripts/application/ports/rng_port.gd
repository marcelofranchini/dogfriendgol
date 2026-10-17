class_name RngPort
## Contrato de aleatoriedade (R-04). Único port da v1 com benefício real.
## Isola o RNG para permitir testes determinísticos (semente fixa).
## Camada Application — contrato, sem implementação concreta.

## Retorna um inteiro em [0, max_exclusive).
func next_int(max_exclusive: int) -> int:
	return 0

## Define a semente do gerador (determinismo em teste).
func set_seed(seed: int) -> void:
	pass
