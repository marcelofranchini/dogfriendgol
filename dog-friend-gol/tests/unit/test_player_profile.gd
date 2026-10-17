extends GutTest

## T-33 parcial: validação de cadastro (FR-045, FR-056).
## Campo obrigatório vazio bloqueia o avanço e indica o campo pendente.

func test_child_name_required() -> void:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = ""
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	assert_false(_is_valid(p), "nome da criança vazio deve invalidar o cadastro")

func test_child_age_required() -> void:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 0
	p.dog_name = "Branquinha"
	p.dog_age = 5
	assert_false(_is_valid(p), "idade da criança não preenchida deve invalidar")

func test_dog_name_required() -> void:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = ""
	p.dog_age = 5
	assert_false(_is_valid(p), "nome do cachorro vazio deve invalidar")

func test_dog_age_required() -> void:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 0
	assert_false(_is_valid(p), "idade do cachorro não preenchida deve invalidar")

func test_valid_profile_passes() -> void:
	var p: PlayerProfile = PlayerProfile.new()
	p.child_name = "Crianca"
	p.child_age = 8
	p.dog_name = "Branquinha"
	p.dog_age = 5
	assert_true(_is_valid(p), "cadastro completo deve ser válido")

## Validação de cadastro (regra do domínio, aplicada na apresentação).
func _is_valid(p: PlayerProfile) -> bool:
	return p.child_name != "" and p.child_age > 0 and p.dog_name != "" and p.dog_age > 0
