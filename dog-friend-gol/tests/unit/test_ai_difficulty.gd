extends GutTest

## T-33 de contracts/use-case-api.md: regra de idade × dificuldade (FR-043).
## A idade acima de 10 sobrepõe a escolha.

func test_age_8_hard_is_hard() -> void:
	assert_eq(AiDifficulty.resolve_difficulty(8, AiDifficulty.Level.HARD), AiDifficulty.Level.HARD,
		"8 anos com HARD deve ser HARD")

func test_age_10_easy_is_easy() -> void:
	assert_eq(AiDifficulty.resolve_difficulty(10, AiDifficulty.Level.EASY), AiDifficulty.Level.EASY,
		"10 anos com EASY deve ser EASY")

func test_age_12_hard_is_normal() -> void:
	assert_eq(AiDifficulty.resolve_difficulty(12, AiDifficulty.Level.HARD), AiDifficulty.Level.NORMAL,
		"12 anos com HARD deve ser NORMAL (idade sobrepõe)")

func test_age_12_easy_is_normal() -> void:
	assert_eq(AiDifficulty.resolve_difficulty(12, AiDifficulty.Level.EASY), AiDifficulty.Level.NORMAL,
		"12 anos com EASY deve ser NORMAL (idade sobrepõe)")
