class_name RegistrationView
extends Control
## Tela de cadastro (FR-003, FR-045, FR-056). Coleta nome e idade da criança e do
## cachorro. Bloqueia o avanço enquanto houver campo obrigatório inválido.

var profile: PlayerProfile = PlayerProfile.new()

## Valida os campos obrigatórios. Retorna true se todos preenchidos.
func is_valid() -> bool:
	return profile.child_name != "" and profile.child_age > 0 \
		and profile.dog_name != "" and profile.dog_age > 0

## Indica qual campo está pendente (FR-056). Retorna "" se válido.
func pending_field() -> String:
	if profile.child_name == "":
		return "child_name"
	if profile.child_age <= 0:
		return "child_age"
	if profile.dog_name == "":
		return "dog_name"
	if profile.dog_age <= 0:
		return "dog_age"
	return ""
