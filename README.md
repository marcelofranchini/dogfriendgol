# Aventuras na Grama! ⚽🐶

Jogo infantil de disputa de pênaltis, desenvolvido em **Godot 4** com **GDScript tipado**.
Uma criança e sua cachorrinha (a Branquinha) se enfrentam em uma série de pênaltis, com
sorteio de cara ou coroa, encerramento antecipado e morte súbita.

> **Status**: MVP implementado — a lógica central do jogo está completa e coberta por testes
> automatizados. A parte visual (sprites, animações, arte final) ainda está em produção.

---

## O jogo

- **Mecânica**: escolha de zona em uma **grade de 9 zonas** (3 colunas × 3 alturas) para chutar
  e defender.
- **Regra de resolução** (determinística, sem aleatoriedade):
  - Mesma zona defendida → **defesa**;
  - Zonas diferentes, com o cobrador em um canto alto → **bola para fora**;
  - Demais casos → **gol**.
- **Partida**: 5 cobranças por participante, alternando papéis; encerramento antecipado quando o
  alcance é matematicamente impossível; morte súbita em caso de empate.
- **IA local**: o adversário cobra, defende, reage ao estado e varia entre partidas — sem nunca
  acessar a escolha secreta do jogador.
- **Público**: crianças em idade de alfabetização inicial, com apoio de um adulto.

---

## Estrutura do repositório

```
.
├── dog-friend-gol/          # Projeto Godot (raiz do jogo)
│   ├── project.godot        # Configuração do projeto (Godot 4.7)
│   ├── scripts/             # Código (arquitetura hexagonal pragmática)
│   │   ├── domain/          # Regras puras (sem nós/cenas)
│   │   ├── application/     # Casos de uso, ações, ports
│   │   ├── adapters/        # Entrada, IA, RNG
│   │   ├── bootstrap/       # Composição de dependências
│   │   └── presentation/    # Views e animações
│   ├── scenes/              # Cenas (.tscn)
│   ├── assets/              # Recursos (referências + privados)
│   ├── addons/gut/          # Framework de testes (GUT)
│   └── tests/               # Testes unitários e de integração
├── specs/                   # Especificação (Spec Kit)
│   └── 001-penalty-match-mvp/
│       ├── spec.md          # Especificação da funcionalidade
│       ├── plan.md          # Plano técnico
│       ├── tasks.md         # Tarefas de implementação
│       └── contracts/       # Contratos entre camadas
├── .specify/                # Configuração do Spec Kit
├── .agents/skills/          # Skills do Superpowers
├── AGENTS.md                # Instruções para agentes de IA
└── .github/                 # Instruções do Copilot + skills do Spec Kit
```

---

## Como rodar

### Pré-requisitos

- **Godot 4.7.2** (instalado no Windows)
- **GUT** (já incluído em `dog-friend-gol/addons/gut/`)

### Rodar o jogo

Abra o projeto `dog-friend-gol/` no editor Godot e pressione **F5** (Play).

### Rodar os testes (headless)

```bash
GODOT="/mnt/c/Users/franc/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
PROJECT='\\wsl.localhost\Ubuntu\home\franchini190929\Projects\Game\dog-friend-gol'

# Suíte completa
"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests
```

**Resultado atual**: 54/54 testes passando (14 scripts, 81.298 asserts).

---

## Exportação

### Web

```bash
"$GODOT" --headless --path "$PROJECT" --export-release "Web" build/web/index.html
python3 -m http.server 8000 --directory build/web
```

### Android (APK)

```bash
"$GODOT" --headless --path "$PROJECT" --export-debug "Android" build/android/game.apk
```

> ⚠️ **Requer**: templates de exportação (~1,28 GB), JDK 17 e Android SDK. Ainda não instalados
> neste ambiente. Detalhes em `specs/001-penalty-match-mvp/quickstart.md`.

---

## Desenvolvimento

Este projeto usa **Spec Kit** (spec-driven development) e **Superpowers** (skills de processo):

- **Spec Kit** define *o que* construir: `constitution → specify → clarify → plan → tasks → implement → converge`.
- **Superpowers** define *como*: TDD, debug sistemático, verificação antes de concluir.

Artefatos em `.specify/` e `specs/`. Skills em `.agents/skills/` (Superpowers) e
`.github/skills/` (Spec Kit).

---

## Documentação

- **Constituição do projeto**: `.specify/memory/constitution.md` (princípios e governança)
- **Especificação**: `specs/001-penalty-match-mvp/spec.md`
- **Plano técnico**: `specs/001-penalty-match-mvp/plan.md`
- **Guia de validação**: `specs/001-penalty-match-mvp/quickstart.md`

---

## Licença

Projeto em desenvolvimento. As referências visuais em `dog-friend-gol/assets/references/` são
material de referência de estilo e **não** constituem arte final.
