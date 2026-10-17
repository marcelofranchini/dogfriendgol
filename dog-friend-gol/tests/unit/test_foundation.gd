extends GutTest

## Teste de validação da fundação (Phase 2): confirma que os class_name globais
## do domínio e da aplicação resolvem corretamente no GUT headless.

func test_shot_zone_has_nine_zones() -> void:
	assert_eq(ShotZone.all_zones().size(), 9, "deve haver exatamente 9 zonas")

func test_is_top_corner() -> void:
	assert_true(ShotZone.is_top_corner(ShotZone.Zone.TOP_LEFT), "TOP_LEFT é canto alto")
	assert_true(ShotZone.is_top_corner(ShotZone.Zone.TOP_RIGHT), "TOP_RIGHT é canto alto")
	assert_false(ShotZone.is_top_corner(ShotZone.Zone.TOP_CENTER), "TOP_CENTER não é canto alto")
	assert_false(ShotZone.is_top_corner(ShotZone.Zone.MIDDLE_CENTER), "MIDDLE_CENTER não é canto alto")

func test_godot_rng_resolves() -> void:
	var rng: RngPort = GodotRng.new()
	rng.set_seed(42)
	var v: int = rng.next_int(10)
	assert_between(v, 0, 9, "next_int deve retornar valor em [0, 10)")

func test_bootstrap_exposes_rng() -> void:
	var boot: GameBootstrap = GameBootstrap.new()
	assert_not_null(boot.rng, "bootstrap deve expor um RngPort")
