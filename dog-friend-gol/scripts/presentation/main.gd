class_name Main
extends Control
## Cena principal jogável: menu → cadastro → partida (grade de 9 zonas) → fim.
## Constrói a UI programaticamente para não depender do editor visual.
## A lógica do jogo vive no domínio (MatchState/MatchRules) e no MatchController;
## esta cena apenas reflete o estado (FR-049).

const Z = ShotZone.Zone
const R = ShotResult.Result
const P = MatchPhase.Phase

var controller: MatchController = null
var profile: PlayerProfile = null

# Nós de UI
var menu_root: Control
var reg_root: Control
var match_root: Control
var end_root: Control

# Campos de cadastro
var child_name_edit: LineEdit
var child_age_edit: LineEdit
var dog_name_edit: LineEdit
var dog_age_edit: LineEdit

# Partida
var score_label: Label
var turn_label: Label
var result_label: Label
var zone_buttons: Array = []  # 9 botões

func _ready() -> void:
	_build_menu()
	_show_menu()

# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------
func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)

	var title: Label = Label.new()
	title.text = "Aventuras na Grama!"
	title.add_theme_font_size_override("font_size", 48)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(0, 120)
	title.size = Vector2(1280, 80)
	menu_root.add_child(title)

	var subtitle: Label = Label.new()
	subtitle.text = "Disputa de pênaltis entre a criança e a Branquinha"
	subtitle.add_theme_font_size_override("font_size", 20)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_preset(Control.PRESET_CENTER_TOP)
	subtitle.position = Vector2(0, 210)
	subtitle.size = Vector2(1280, 40)
	menu_root.add_child(subtitle)

	var play: Button = Button.new()
	play.text = "Jogar"
	play.add_theme_font_size_override("font_size", 28)
	play.set_anchors_preset(Control.PRESET_CENTER)
	play.position = Vector2(-100, 40)
	play.size = Vector2(200, 70)
	play.pressed.connect(_on_play_pressed)
	menu_root.add_child(play)

# ---------------------------------------------------------------------------
# Cadastro
# ---------------------------------------------------------------------------
func _build_registration() -> void:
	reg_root = Control.new()
	reg_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	reg_root.visible = false
	add_child(reg_root)

	var title: Label = Label.new()
	title.text = "Quem vai jogar?"
	title.add_theme_font_size_override("font_size", 36)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.position = Vector2(0, 80)
	title.size = Vector2(1280, 60)
	reg_root.add_child(title)

	child_name_edit = _add_field(reg_root, "Nome da criança", 180)
	child_age_edit = _add_field(reg_root, "Idade da criança", 260)
	dog_name_edit = _add_field(reg_root, "Nome do cachorro", 340)
	dog_age_edit = _add_field(reg_root, "Idade do cachorro", 420)

	var start: Button = Button.new()
	start.text = "Começar partida"
	start.add_theme_font_size_override("font_size", 24)
	start.set_anchors_preset(Control.PRESET_CENTER)
	start.position = Vector2(-120, 120)
	start.size = Vector2(240, 60)
	start.pressed.connect(_on_start_pressed)
	reg_root.add_child(start)

func _add_field(parent: Control, label_text: String, y: float) -> LineEdit:
	var lbl: Label = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	lbl.position = Vector2(-300, y)
	lbl.size = Vector2(600, 30)
	parent.add_child(lbl)

	var edit: LineEdit = LineEdit.new()
	edit.add_theme_font_size_override("font_size", 20)
	edit.set_anchors_preset(Control.PRESET_CENTER_TOP)
	edit.position = Vector2(-300, y + 35)
	edit.size = Vector2(600, 40)
	parent.add_child(edit)
	return edit

# ---------------------------------------------------------------------------
# Partida
# ---------------------------------------------------------------------------
func _build_match() -> void:
	match_root = Control.new()
	match_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	match_root.visible = false
	add_child(match_root)

	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	score_label.position = Vector2(0, 40)
	score_label.size = Vector2(1280, 60)
	match_root.add_child(score_label)

	turn_label = Label.new()
	turn_label.add_theme_font_size_override("font_size", 24)
	turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	turn_label.position = Vector2(0, 110)
	turn_label.size = Vector2(1280, 40)
	match_root.add_child(turn_label)

	# Grade 3x3 de zonas (cima/meio/baixo × esquerda/centro/direita).
	var grid: GridContainer = GridContainer.new()
	grid.columns = 3
	grid.set_anchors_preset(Control.PRESET_CENTER)
	grid.position = Vector2(-300, -60)
	grid.size = Vector2(600, 300)
	match_root.add_child(grid)

	var zone_names: Array = [
		"Cima Esq.", "Cima Centro", "Cima Dir.",
		"Meio Esq.", "Meio Centro", "Meio Dir.",
		"Baixo Esq.", "Baixo Centro", "Baixo Dir.",
	]
	for i in range(9):
		var b: Button = Button.new()
		b.text = zone_names[i]
		b.add_theme_font_size_override("font_size", 20)
		b.custom_minimum_size = Vector2(190, 90)
		b.pressed.connect(_on_zone_pressed.bind(i))
		grid.add_child(b)
		zone_buttons.append(b)

	result_label = Label.new()
	result_label.add_theme_font_size_override("font_size", 28)
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	result_label.position = Vector2(0, 480)
	result_label.size = Vector2(1280, 50)
	match_root.add_child(result_label)

# ---------------------------------------------------------------------------
# Fim
# ---------------------------------------------------------------------------
func _build_end() -> void:
	end_root = Control.new()
	end_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_root.visible = false
	add_child(end_root)

	var title: Label = Label.new()
	title.name = "EndTitle"
	title.add_theme_font_size_override("font_size", 44)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER)
	title.position = Vector2(0, -80)
	title.size = Vector2(1280, 80)
	end_root.add_child(title)

	var again: Button = Button.new()
	again.text = "Jogar de novo"
	again.add_theme_font_size_override("font_size", 24)
	again.set_anchors_preset(Control.PRESET_CENTER)
	again.position = Vector2(-120, 40)
	again.size = Vector2(240, 60)
	again.pressed.connect(_on_again_pressed)
	end_root.add_child(again)

# ---------------------------------------------------------------------------
# Navegação
# ---------------------------------------------------------------------------
func _show_menu() -> void:
	menu_root.visible = true
	reg_root.visible = false
	match_root.visible = false
	end_root.visible = false

func _on_play_pressed() -> void:
	menu_root.visible = false
	reg_root.visible = true

func _on_start_pressed() -> void:
	profile = PlayerProfile.new()
	profile.child_name = child_name_edit.text if child_name_edit.text != "" else "Criança"
	profile.child_age = int(child_age_edit.text) if child_age_edit.text.is_valid_int() else 8
	profile.dog_name = dog_name_edit.text if dog_name_edit.text != "" else "Branquinha"
	profile.dog_age = int(dog_age_edit.text) if dog_age_edit.text.is_valid_int() else 5
	profile.controlled_character = CharacterId.Id.CHILD

	_start_match()

func _start_match() -> void:
	var rng: RngPort = GodotRng.new()
	rng.set_seed(Time.get_ticks_usec())
	var state: MatchState = StartMatchUseCase.start_match(profile, rng)
	var ai: AiOpponent = AiOpponent.new()
	ai.difficulty = AiDifficulty.resolve_difficulty(profile.child_age, AiDifficulty.Level.NORMAL)
	controller = MatchController.new(state, ai, rng)
	controller.player_index = 0  # o jogador controla a criança

	reg_root.visible = false
	match_root.visible = true
	result_label.text = ""
	_refresh_match()

func _on_zone_pressed(zone: int) -> void:
	if controller == null:
		return
	if controller.state.phase == P.FINISHED:
		return
	var outcome: AttemptOutcome = controller.on_zone_selected(zone)
	_show_result(outcome)
	_refresh_match()
	if controller.state.phase == P.FINISHED:
		_show_end()

func _refresh_match() -> void:
	var s: MatchState = controller.state
	var child_name: String = s.participants[0].name
	var dog_name: String = s.participants[1].name
	score_label.text = "%s %d  ×  %d %s" % [child_name, s.score[0], s.score[1], dog_name]

	var shooter: int = s.shooter_index
	var shooter_name: String = s.participants[shooter].name
	if shooter == controller.player_index:
		turn_label.text = "Sua vez de chutar/defender (%s)" % shooter_name
	else:
		turn_label.text = "Vez da IA (%s)" % shooter_name

func _show_result(outcome: AttemptOutcome) -> void:
	var shooter_name: String = controller.state.participants[outcome.shooter_index].name
	match outcome.result:
		R.GOAL:
			result_label.text = "⚽ GOL de %s!" % shooter_name
		R.DEFENDED:
			result_label.text = "🛡️ Defendeu!"
		R.OUT_OF_BOUNDS:
			result_label.text = "💨 Bola para fora!"

func _show_end() -> void:
	var s: MatchState = controller.state
	var winner_name: String = s.participants[s.winner].name
	var title: Label = end_root.get_node("EndTitle")
	title.text = "%s venceu! 🎉" % winner_name
	match_root.visible = false
	end_root.visible = true

func _on_again_pressed() -> void:
	controller = null
	_show_menu()
