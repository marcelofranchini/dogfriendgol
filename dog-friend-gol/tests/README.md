# Testes — Aventuras na Grama!

Suíte de testes automatizados do domínio e da integração, executada com **GUT** (Godot Unit Test)
no Godot 4.7.2, sem renderização (Artigo VII.1, FR-063).

## Comando canônico (headless a partir do WSL)

```bash
GODOT="/mnt/c/Users/franc/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
PROJECT='\\wsl.localhost\Ubuntu\home\franchini190929\Projects\Game\dog-friend-gol'

# Suíte de unidade (domínio)
"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit

# Suíte de integração (IA, fluxo, reinício)
"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests/integration

# Suíte completa
"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests
```

## Regra de tipagem do Godot 4.7 (obrigatória)

A anotação explícita de tipo é **obrigatória** (Artigo II.2). Quando o lado direito é uma
expressão booleana composta, `var ok := (...)` **falha** com "Cannot infer the type". Use sempre:

```gdscript
var ok: bool = (a and b) or c
```

## Estrutura

- `unit/` — regras puras do domínio (sem nós, sem cenas)
- `integration/` — IA, fluxo de partida, reinício, determinismo

## Evidência de setup (2026-10-17)

GUT v9.7.1 carregou e executou no Godot 4.7.2 headless:

```
Godot version:  4.7.2
GUT version:  9.7.1
res://tests/unit/test_smoke.gd
* test_suite_loads
1/1 passed.
---- All tests passed! ----
```

## Evidência da suíte completa (2026-10-17)

Após a implementação das 5 user stories, a suíte completa passa:

```
Scripts  14
Tests    54
Passing  54
Asserts  81298
---- All tests passed! ----
```

## Comandos de exportação (CA-06, CA-09)

```bash
# Web (requer templates de exportação instalados)
"$GODOT" --headless --path "$PROJECT" --export-release "Web" build/web/index.html

# Android (requer templates + JDK 17 + Android SDK)
"$GODOT" --headless --path "$PROJECT" --export-debug "Android" build/android/game.apk
```

Os templates de exportação (~1,28 GB) e o toolchain Android ainda **não estão
instalados** neste ambiente — as exportações permanecem bloqueadas (CA-06, CA-09).
