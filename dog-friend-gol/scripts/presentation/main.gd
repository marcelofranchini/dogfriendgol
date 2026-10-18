class_name Main
extends Control
## Cena principal jogável: menu → cadastro → partida (grade de 9 zonas) → fim.
## Constrói a UI programaticamente para não depender do editor visual.
## A lógica do jogo vive no domínio (MatchState/MatchRules) e no MatchController;
## esta cena apenas reflete o estado (FR-049).

const Z = ShotZone.Zone
const R = ShotResult.Result
const P = MatchPhase.Phase

# Largura de design (retrato 720x1280)
const W := 720.0

# Cores (paleta infantil, verde grama)
const C_GRASS := Color(0.16, 0.55, 0.24)
const C_GRASS_DARK := Color(0.10, 0.40, 0.17)
const C_WHITE := Color(1, 1, 1)
const C_GOLD := Color(1.0, 0.84, 0.0)
const C_RED := Color(0.85, 0.25, 0.20)
const C_BLUE := Color(0.20, 0.45, 0.85)

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
	_build_registration()
	_build_match()
	_build_end()
	_show_menu()

# ---------------------------------------------------------------------------
# Helpers de estilo
# ---------------------------------------------------------------------------
func _bg(parent: Control, texture_path: String) -> TextureRect:
	var bg: TextureRect = TextureRect.new()
	bg.texture = load(texture_path)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)
	return bg

func _overlay(parent: Control, color: Color) -> ColorRect:
	var ov: ColorRect = ColorRect.new()
	ov.color = color
	ov.set_anchors_preset(Control.PRESET_FULL_RECT)
	ov.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(ov)
	return ov

func _label(parent: Control, text: String, size: int, color: Color, y: float, h: float = 60) -> Label:
	var l: Label = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	l.add_theme_constant_override("outline_size", 6)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.set_anchors_preset(Control.PRESET_CENTER_TOP)
	l.position = Vector2(-W / 2.0, y)
	l.size = Vector2(W, h)
	parent.add_child(l)
	return l

func _button(parent: Control, text: String, y: float, w: float = 300, h: float = 80, color: Color = C_GOLD) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 28)
	b.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	b.add_theme_color_override("font_hover_color", Color(0.1, 0.1, 0.1))
	b.add_theme_stylebox_override("normal", _stylebox(color))
	b.add_theme_stylebox_override("hover", _stylebox(color.lightened(0.15)))
	b.add_theme_stylebox_override("pressed", _stylebox(color.darkened(0.15)))
	b.set_anchors_preset(Control.PRESET_CENTER_TOP)
	b.position = Vector2(-w / 2.0, y)
	b.size = Vector2(w, h)
	parent.add_child(b)
	return b

func _stylebox(color: Color) -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = 16
	sb.corner_radius_top_right = 16
	sb.corner_radius_bottom_left = 16
	sb.corner_radius_bottom_right = 16
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb
# Imagem centralizada, mantendo proporção (não distorce).
func _art(parent: Control, texture_path: String, y: float, w: float, h: float) -> TextureRect:
	var t: TextureRect = TextureRect.new()
	t.texture = load(texture_path)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.set_anchors_preset(Control.PRESET_CENTER_TOP)
	t.position = Vector2(-w / 2.0, y)
	t.size = Vector2(w, h)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(t)
	return t
# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------
func _build_menu() -> void:
	menu_root = Control.new()
	menu_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(menu_root)

	_bg(menu_root, "res://assets/references/bg_stadium_crowd.jpg")
	_overlay(menu_root, Color(0, 0, 0, 0.35))

	_label(menu_root, "Aventuras na Grama!", 52, C_GOLD, 70, 80)
	_label(menu_root, "Disputa de pênaltis entre a criança e a Branquinha", 22, C_WHITE, 160, 60)

	# Ilustração dos protagonistas (retrato 768x1024 → proporção 0.75).
	_art(menu_root, "res://assets/references/concepts_boy_and_dog.jpg", 260, 360, 480)

	var play: Button = _button(menu_root, "⚽ Jogar", 820, 320, 90, C_GOLD)
	play.pressed.connect(_on_play_pressed)

# ---------------------------------------------------------------------------
# Cadastro
# ---------------------------------------------------------------------------
func _build_registration() -> void:
	reg_root = Control.new()
	reg_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	reg_root.visible = false
	add_child(reg_root)

	_bg(reg_root, "res://assets/references/bg_stadium_crowd.jpg")
	_overlay(reg_root, Color(0, 0, 0, 0.55))

	_label(reg_root, "Quem vai jogar?", 44, C_GOLD, 60, 70)

	child_name_edit = _add_field(reg_root, "Nome da criança", 180)
	child_age_edit = _add_field(reg_root, "Idade da criança", 300)
	dog_name_edit = _add_field(reg_root, "Nome do cachorro", 420)
	dog_age_edit = _add_field(reg_root, "Idade do cachorro", 540)

	var start: Button = _button(reg_root, "Começar partida", 700, 320, 80, C_GOLD)
	start.pressed.connect(_on_start_pressed)

func _add_field(parent: Control, label_text: String, y: float) -> LineEdit:
	var lbl: Label = Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", C_WHITE)
	lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
	lbl.add_theme_constant_override("outline_size", 4)
	lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	lbl.position = Vector2(-280, y)
	lbl.size = Vector2(560, 30)
	parent.add_child(lbl)

	var edit: LineEdit = LineEdit.new()
	edit.add_theme_font_size_override("font_size", 22)
	edit.set_anchors_preset(Control.PRESET_CENTER_TOP)
	edit.position = Vector2(-280, y + 36)
	edit.size = Vector2(560, 50)
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

	_bg(match_root, "res://assets/references/bg_stadium_crowd.jpg")
	_overlay(match_root, Color(0, 0, 0, 0.45))

	score_label = _label(match_root, "", 40, C_GOLD, 40, 60)
	turn_label = _label(match_root, "", 24, C_WHITE, 110, 40)

	# Grade 3x3 de zonas (3 colunas de 200px + espaçamento).
	var grid: GridContainer = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	grid.set_anchors_preset(Control.PRESET_CENTER_TOP)
	grid.position = Vector2(-312, 200)
	grid.size = Vector2(624, 360)
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
		b.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
		b.add_theme_color_override("font_hover_color", Color(0.1, 0.1, 0.1))
		b.add_theme_stylebox_override("normal", _stylebox(Color(1, 1, 1, 0.85)))
		b.add_theme_stylebox_override("hover", _stylebox(C_GOLD))
		b.add_theme_stylebox_override("pressed", _stylebox(C_GOLD.darkened(0.2)))
		b.custom_minimum_size = Vector2(200, 110)
		b.pressed.connect(_on_zone_pressed.bind(i))
		grid.add_child(b)
		zone_buttons.append(b)

	result_label = _label(match_root, "", 30, C_WHITE, 620, 60)

# ---------------------------------------------------------------------------
# Fim
# ---------------------------------------------------------------------------
func _build_end() -> void:
	end_root = Control.new()
	end_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_root.visible = false
	add_child(end_root)

	_bg(end_root, "res://assets/references/bg_stadium_crowd.jpg")
	_overlay(end_root, Color(0, 0, 0, 0.5))

	var title: Label = _label(end_root, "", 48, C_GOLD, 80, 90)
	title.name = "EndTitle"

	# Arte da comemoração/abraço (retrato 768x1024).
	_art(end_root, "res://assets/references/ui_main_menu.jpg", 220, 360, 480)

	var again: Button = _button(end_root, "Jogar de novo", 820, 320, 80, C_GOLD)
	again.pressed.connect(_on_again_pressed)

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
			result_label.add_theme_color_override("font_color", C_GOLD)
		R.DEFENDED:
			result_label.text = "🛡️ Defendeu!"
			result_label.add_theme_color_override("font_color", C_BLUE)
		R.OUT_OF_BOUNDS:
			result_label.text = "💨 Bola para fora!"
			result_label.add_theme_color_override("font_color", C_RED)

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
