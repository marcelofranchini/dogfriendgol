---

description: "Task list for Aventuras na Grama! — Primeira Versão Jogável"
---

# Tasks: Aventuras na Grama! — Primeira Versão Jogável

**Feature Branch**: `001-penalty-match-mvp`

**Input**: Design documents from `/specs/001-penalty-match-mvp/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/](./contracts/), [quickstart.md](./quickstart.md)

**Tests**: **INCLUÍDOS** — exigidos pelo Artigo VII da Constituição e pelo Escopo da spec
("Testes automatizados das regras da partida, independentes de animações"). Os contratos já
definem T-01 a T-33. Ferramenta: **GUT** (R-01).

**Organização**: tarefas agrupadas por user story, para permitir implementação e teste
independentes de cada história.

## Formato: `[ID] [P?] [Story] Descrição`

- **[P]**: pode rodar em paralelo (arquivo diferente, sem dependência pendente)
- **[Story]**: US1 a US5, conforme `spec.md`
- Todo caminho de arquivo é relativo à raiz do repositório

## Convenções de Caminho

Projeto Godot único em `dog-friend-gol/` (Artigo III.3). Nomenclatura de código em inglês;
comentários e documentação em pt-BR (Artigos I.1, I.2).

**Nota sobre os arquivos de teste**: a lista de arquivos em `plan.md` → "Project Structure" era
**ilustrativa**. Esta lista é a canônica e a subdivide por contrato e por user story, para que cada
arquivo corresponda a um contrato verificável (`zone-grid`, `match-rules`, `use-case-api`):

| Arquivo | Contrato / história |
|---|---|
| `tests/unit/test_zone_resolution.gd` | `zone-grid.md` (T-01 a T-07) — US1 |
| `tests/unit/test_shot_zone.gd` | `zone-grid.md` (T-08, T-09) — US1 |
| `tests/unit/test_match_state.gd` | `match-rules.md` (T-10 a T-25) — US1 |
| `tests/unit/test_player_profile.gd` | Validação de cadastro — US2 |
| `tests/unit/test_ai_difficulty.gd` | `use-case-api.md` (T-33) — US2 |
| `tests/integration/test_ai_fairness.gd` | `use-case-api.md` (T-26) — US3 |
| `tests/integration/test_ai_variation.gd` | SC-010 — US3 |
| `tests/integration/test_ai_context.gd` | FR-040 — US3 |
| `tests/integration/test_intro_skip.gd` | FR-058 — US4 |
| `tests/integration/test_ending_flow.gd` | FR-010, SC-008 — US4 |
| `tests/integration/test_new_match.gd` | `match-rules.md` (T-24), T-30 — US5 |
| `tests/integration/test_match_flow.gd` | Determinismo ponta a ponta (SC-005) — Polish |

Os nomes `test_match_rules.gd` e `test_ai_opponent.gd` que apareciam no plano foram **substituídos**
pelos acima: a regra de resolução passou a ter arquivo próprio (`test_zone_resolution.gd`) por ser o
contrato mais crítico, e a IA passou a ter **três** arquivos, porque justiça (FR-042), variação
(SC-010) e contexto (FR-040) são propriedades independentes.

---

## Phase 1: Setup (Infraestrutura Compartilhada)

**Propósito**: preparar o projeto Godot existente e a ferramenta de testes. Nenhum código de jogo.

- [X] T001 Criar a árvore de diretórios em `dog-friend-gol/`: `scripts/domain/`,
      `scripts/application/use_cases/`, `scripts/application/actions/`, `scripts/application/ports/`,
      `scripts/adapters/inbound/`, `scripts/adapters/outbound/`, `scripts/bootstrap/`,
      `scripts/presentation/`, `scenes/components/`, `tests/unit/`, `tests/integration/`.
      Diretórios não permanecem vazios: cada um recebe seu primeiro arquivo em T006–T016 e nas
      fases seguintes (Artigo V)

- [X] T002 Instalar o addon **GUT v9.7.1** (compatível com Godot 4.7.x) em
      `dog-friend-gol/addons/gut/`. Baixar de
      `https://github.com/bitwes/Gut/archive/refs/tags/v9.7.1.zip` e copiar apenas o conteúdo de
      `addons/gut/`. **Não** usar a branch `main` (suporta apenas 4.6.x)

- [X] T003 [P] Criar `dog-friend-gol/.gutconfig.json` apontando `dirs` para `res://tests/unit` e
      `res://tests/integration`, com `include_subdirs: true` e `log_level: 1`

- [X] T004 Registrar em `dog-friend-gol/tests/README.md` o comando canônico de execução headless a
      partir do WSL, usando as variáveis de `quickstart.md`:
      `"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit`

- [X] T005 **Evidência de setup**: executar a suíte GUT (ainda vazia) com o comando registrado em
      `dog-friend-gol/tests/README.md` e registrar a saída real. Esperado: GUT carrega, encontra 0
      testes, sai com código 0. Se o GUT não carregar, aplicar o plano B de R-01 (GoDotTest) antes
      de prosseguir. **Nenhuma fase seguinte começa sem esta evidência**

**Checkpoint**: projeto Godot íntegro + suíte de testes executável de verdade.

---

## Phase 2: Foundational (Pré-requisitos Bloqueantes)

**Propósito**: vocabulário compartilhado e infraestrutura de que **todas** as user stories
dependem.

**⚠️ CRÍTICO**: nenhuma user story pode começar antes desta fase terminar.

- [X] T006 [P] Criar o enum `ShotZone` com exatamente 9 valores em
      `dog-friend-gol/scripts/domain/shot_zone.gd`, na ordem declarada em
      `contracts/zone-grid.md`: `TOP_LEFT, TOP_CENTER, TOP_RIGHT, MIDDLE_LEFT, MIDDLE_CENTER,
      MIDDLE_RIGHT, BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT`. Incluir `to_grid_coords`,
      `from_grid_coords`, `is_top_corner`, `all_zones`. Coluna: 0=esquerda, 1=centro, 2=direita;
      altura: 0=cima, 1=meio, 2=baixo. `is_top_corner` retorna verdadeiro **apenas** para
      `TOP_LEFT` e `TOP_RIGHT`. Todas as 9 zonas são selecionáveis para chute **e** para defesa;
      nenhuma zona é inútil (FR-032, FR-062). Sem dependência de nós (Artigo IV)

- [X] T007 [P] Criar o enum `ShotResult` em `dog-friend-gol/scripts/domain/shot_result.gd` com
      **exatamente três** valores: `GOAL`, `DEFENDED`, `OUT_OF_BOUNDS`. Documentar que
      `OUT_OF_BOUNDS` **não** é uma zona e não existe décima opção selecionável (FR-016)

- [X] T008 [P] Criar o enum `MatchPhase` em `dog-friend-gol/scripts/domain/match_phase.gd` com
      `NOT_STARTED`, `REGULAR`, `SUDDEN_DEATH`, `FINISHED` (FR-026)

- [X] T009 [P] Criar o enum `CharacterId` em `dog-friend-gol/scripts/domain/character_id.gd` com
      `CHILD` e `DOG`. Nomes de exibição ("Pedro", "Branquinha") **não** pertencem ao domínio
      (Artigo VI.3)

- [X] T010 [P] Criar o contrato `RngPort` em `dog-friend-gol/scripts/application/ports/rng_port.gd`
      com `next_int(max_exclusive: int) -> int` e `set_seed(seed: int) -> void`. Único port da v1
      com benefício real (R-04, R-07)

- [X] T011 [P] Implementar `GodotRng` em `dog-friend-gol/scripts/adapters/outbound/godot_rng.gd`
      usando `RandomNumberGenerator` com `seed` configurável. Implementa `RngPort`

- [X] T012 [P] Criar o enum `MatchEvent` em `dog-friend-gol/scripts/application/match_event.gd`
      com `ATTEMPT_RESOLVED`, `TURN_CHANGED`, `ROUND_CHANGED`, `PHASE_CHANGED`, `EARLY_FINISH`,
      `MATCH_FINISHED`, conforme `contracts/use-case-api.md` §3

- [X] T013 Criar `dog-friend-gol/scripts/domain/match_constants.gd` com
      `INITIAL_SHOTS_PER_PARTICIPANT: int = 5` (FR-014) e `PARTICIPANT_COUNT: int = 2` (FR-001),
      ambos com tipo explícito (Artigo II.2)

- [X] T014 Criar o esqueleto de composição em `dog-friend-gol/scripts/bootstrap/game_bootstrap.gd`:
      instancia `GodotRng` e expõe as dependências para as cenas. Sem lógica de jogo

- [X] T015 Registrar em `dog-friend-gol/tests/README.md` a regra de tipagem do Godot 4.7:
      **anotação explícita é obrigatória** (`var ok: bool = (...)`, nunca `var ok := (...)` quando
      o lado direito é expressão booleana composta). Erro observado: "Cannot infer the type"

- [X] T016 **Verificação de arquitetura** (Artigo IV): confirmar por busca que nenhum arquivo em
      `dog-friend-gol/scripts/domain/` referencia `Node`, `Node2D`, `Control`, `@onready` ou
      `signal`. O domínio é GDScript puro. Registrar a evidência

**Checkpoint**: fundação pronta — as user stories podem começar em paralelo.

---

## Phase 3: User Story 1 - Disputar uma partida completa de pênaltis (Priority: P1) 🎯 MVP

**Goal**: o núcleo do jogo — partida completa com 5 cobranças, alternância, encerramento
antecipado e morte súbita, resolvida pela grade de 9 zonas.

**Independent Test**: iniciar uma partida, executar cobranças em zonas escolhidas e conferir
placar, alternância de turnos, encerramento antecipado e morte súbita — **sem depender de
animações, cenas ou arte final**. Rodar headless.

### Tests for User Story 1 ⚠️

> **ESCREVER PRIMEIRO. Confirmar que FALHAM antes de implementar.**

- [X] T017 [P] [US1] Teste das **81 combinações** em `dog-friend-gol/tests/unit/test_zone_resolution.gd`
      — T-01 a T-07 de `contracts/zone-grid.md`: matriz completa, diagonal sempre `DEFENDED`,
      `TOP_LEFT`/`TOP_RIGHT` sempre `OUT_OF_BOUNDS` contra zona diferente, nenhuma zona `MIDDLE_*`
      produz `OUT_OF_BOUNDS`, contagens exatas **9 `DEFENDED` / 16 `OUT_OF_BOUNDS` / 56 `GOAL` /
      total 81**, e determinismo (1000 repetições → mesmo resultado). Cobre **SC-005a** (100% das 81
      combinações) e **SC-002** (cada cobrança válida produz exatamente um resultado)

- [X] T018 [P] [US1] Teste das conversões de zona em `dog-friend-gol/tests/unit/test_shot_zone.gd`
      — T-08 e T-09: `to_grid_coords` e `from_grid_coords` são inversas para as 9 zonas;
      `all_zones()` retorna exatamente 9 zonas distintas; `is_top_corner` verdadeiro apenas para
      `TOP_LEFT` e `TOP_RIGHT`

- [X] T019 [P] [US1] Teste do estado da partida em `dog-friend-gol/tests/unit/test_match_state.gd`
      — T-10 a T-25 de `contracts/match-rules.md`: placar inicia 0–0; 5 cobranças por participante;
      alternância de turnos; encerramento antecipado (FR-017) **e ausência de encerramento no
      limite exato** (`max_possible == score[other]` → continua); empate 5+5 → `SUDDEN_DEATH`;
      morte súbita encerra com resultados diferentes e continua com iguais; **nenhum vencedor antes
      do 2º cobrar na morte súbita** (FR-021); recusa de cobrança duplicada, fora do turno e após
      encerramento; todas as invariantes **I-01 a I-11** após cada operação; `reset_match` sem
      resíduo; morte súbita prolongada (10+ rodadas). Cobre **SC-003** (100% das partidas terminam
      com vencedor), **SC-004** (encerramento antecipado exatamente nos casos corretos) e **SC-005**
      (placar idêntico em execuções repetidas)

### Implementation for User Story 1

- [X] T020 [P] [US1] Criar `Participant` em `dog-friend-gol/scripts/domain/participant.gd`.
      Campos: `name: String` (**não vazio** — FR-045), `age: int` (**≥ 0**; idade fora de faixa
      plausível **não** bloqueia o jogo), `character: CharacterId`, `goals: int` (**≥ 0**),
      `shots_taken: int` (**≥ 0**)

- [X] T021 [P] [US1] Criar `ShotAttempt` em `dog-friend-gol/scripts/domain/shot_attempt.gd`.
      Campos: `round: int` (**≥ 1**), `shooter_index: int` (**0 ou 1**),
      `shooter_zone: ShotZone` (uma das 9), `defender_zone: ShotZone` (uma das 9),
      `result: ShotResult` (derivado, nunca atribuído livremente)

- [X] T022 [P] [US1] Criar `CoinToss` em `dog-friend-gol/scripts/domain/coin_toss.gd`.
      Campos: `first_shooter_index: int`, `side_a: Side`, `side_b: Side` (FR-007)

- [X] T023 [US1] Implementar `resolve_shot(shooter_zone, defender_zone) -> ShotResult` em
      `dog-friend-gol/scripts/domain/match_rules.gd`. **Ordem importa**: igualdade **primeiro**
      (mesma zona → `DEFENDED`, inclusive quando o defensor pega o mesmo canto alto), depois canto
      alto → `OUT_OF_BOUNDS`, senão `GOAL`. Considera **as duas** escolhas (FR-035) e compara
      zona do cobrador × zona do defensor (FR-036) conforme FR-060. Função **pura**: sem
      aleatoriedade (FR-061), sem estado global, sem nós, sem sinais (FR-063). Fazer T017 e T018
      passarem

- [X] T024 [US1] Implementar `MatchState` em `dog-friend-gol/scripts/domain/match_state.gd`.
      Campos: `phase: MatchPhase`, `round: int` (**≥ 1**), `shooter_index: int` (**0 ou 1**),
      `participants: Array[Participant]` (**exatamente 2**), `score: Array[int]` (**≥ 0**),
      `shots_taken: Array[int]` (**≥ 0**, **≤ 5 em `REGULAR`**, nunca diminui),
      `winner: int` (**-1 enquanto `phase != FINISHED`**; índice válido quando `FINISHED`),
      `attempts: Array[ShotAttempt]` (**size == shots_taken[0] + shots_taken[1]**)

- [X] T025 [US1] Implementar `start_match(participants, coin_toss)` em
      `dog-friend-gol/scripts/domain/match_state.gd`. Pós-condições: `score == [0, 0]` (FR-013),
      `shots_taken == [0, 0]`, `round == 1`, `phase == REGULAR`,
      `shooter_index == coin_toss.first_shooter_index`, `winner == -1`

- [X] T026 [US1] Implementar `apply_attempt(attempt) -> ApplyResult` em
      `dog-friend-gol/scripts/domain/match_state.gd`, seguindo a sequência de 8 passos de
      `contracts/match-rules.md` §3. Alternar `shooter_index` e o papel de defensor a cada tentativa
      (FR-015); avançar `round` **somente quando ambos cobraram**; reavaliar a fase. Em
      `SUDDEN_DEATH`, o vencedor só é decidido após a segunda cobrança da rodada (FR-021)

- [X] T027 [US1] Implementar `can_finish_early()` em `dog-friend-gol/scripts/domain/match_state.gd`
      usando **`<` estritamente**: encerra somente se
      `score[i] + (5 - shots_taken[i]) < score[other]`. Se for igual, o empate ainda é alcançável e
      a partida **continua** (FR-017)

- [X] T028 [US1] Implementar `evaluate_sudden_death_round()` em
      `dog-friend-gol/scripts/domain/match_state.gd`: ambos marcaram → continua; ambos não
      marcaram → continua; um marcou e o outro não → `FINISHED` com vencedor = quem marcou.
      Sem limite artificial de rodadas (FR-018, FR-019, FR-020)

- [X] T029 [US1] Implementar o enum `ApplyError` em `dog-friend-gol/scripts/domain/apply_error.gd`
      com `NONE`, `MATCH_FINISHED`, `NOT_YOUR_TURN`, `ALREADY_SHOT_THIS_ROUND`, `INVALID_ZONE`,
      `INVALID_PHASE`. Cobre: cobrança duplicada recusada (FR-022), cobrança fora do turno recusada
      (FR-023), alteração após encerramento recusada (FR-024) e recusa de operação inválida sem
      alterar o estado (FR-057). **Garantia**: em qualquer erro, `score`, `shots_taken` e `phase`
      permanecem **inalterados** — recusa nunca lança exceção. Fazer T019 passar

- [X] T030 [P] [US1] Implementar o caso de uso `draw_lots(rng: RngPort) -> CoinToss` em
      `dog-friend-gol/scripts/application/use_cases/draw_lots.gd` (FR-007). Determinístico quando o
      RNG recebe semente fixa

- [X] T031 [P] [US1] Implementar o caso de uso `start_match(profile) -> MatchState` em
      `dog-friend-gol/scripts/application/use_cases/start_match.gd` — monta os 2 participantes e
      delega a `MatchState.start_match`

- [X] T032 [US1] Implementar o caso de uso `resolve_attempt(player_zone, ai, rng) -> AttemptOutcome`
      em `dog-friend-gol/scripts/application/use_cases/resolve_attempt.gd`. **Ordem obrigatória**
      (`contracts/use-case-api.md` §5): 1) calcular resultado, 2) aplicar ao estado, 3) emitir
      `score_changed`, 4) emitir `attempt_resolved`, 5) emitir `match_finished` se terminou.
      O placar **já está correto** quando a animação começa (FR-025). Depende de T023, T024, T033

- [X] T033 [P] [US1] Criar `AttemptOutcome` em
      `dog-friend-gol/scripts/application/attempt_outcome.gd`. Campos: `shooter_index: int`,
      `defender_index: int`, `shooter_zone: ShotZone`, `defender_zone: ShotZone`,
      `result: ShotResult`, `state: MatchState` (**estado APÓS a cobrança**),
      `events: Array[MatchEvent]`

- [X] T034 [US1] Implementar o caso de uso `start_attempt() -> AttemptContext` em
      `dog-friend-gol/scripts/application/use_cases/start_attempt.gd`. Prepara uma cobrança sem
      resolver nada; retorna o contexto que a apresentação precisa para animar a preparação
      (`contracts/use-case-api.md` §2). Depende de T024

- [X] T035 [P] [US1] Implementar a ação `shoot_action` em
      `dog-friend-gol/scripts/application/actions/shoot_action.gd` — intenção explícita de cobrar
      (Artigo IV.2). Encapsula a zona escolhida pelo cobrador

- [X] T036 [P] [US1] Implementar a ação `defend_action` em
      `dog-friend-gol/scripts/application/actions/defend_action.gd` — intenção explícita de defender
      (Artigo IV.2). Encapsula a zona escolhida pelo defensor

- [X] T037 [US1] Criar `MatchController` em `dog-friend-gol/scripts/adapters/inbound/match_controller.gd`:
      traduz a intenção do jogador (via `shoot_action`/`defend_action`) em chamada de caso de uso e
      emite os sinais `score_changed`, `attempt_resolved`, `turn_changed`, `match_finished`. **Não**
      calcula placar (FR-049). Depende de T032, T034, T035, T036

- [X] T038 [US1] Criar a cena `dog-friend-gol/scenes/match.tscn` com os nós de placar, indicador de
      turno e grade de zonas, mais o script `dog-friend-gol/scripts/presentation/match_view.gd`.
      A view **recebe** o placar via sinal e apenas o exibe (FR-046, FR-047, FR-049). A interface
      adapta-se a diferentes resoluções e proporções de tela (FR-048)

- [X] T039 [US1] Criar `dog-friend-gol/scripts/presentation/scoreboard_view.gd` com
      `update_score(score: Array[int])`, `update_turn(shooter_index, defender_index)` e
      `show_attempt_result(result: ShotResult)`. **Restrição**: `update_score` **recebe** o placar,
      nunca o deriva

- [X] T040 [US1] Criar o componente `dog-friend-gol/scenes/components/zone_grid.tscn` e os
      seletores `dog-friend-gol/scripts/adapters/inbound/input_zone_selector.gd` (mouse e teclado) e
      `dog-friend-gol/scripts/adapters/inbound/touch_zone_selector.gd` (toque), com
      `zone_at_position(local_pos: Vector2) -> int` cobrindo as **9** zonas (retorna `-1` fora da
      meta) e `highlight_zone(zone: int) -> void`. Mouse, teclado **e toque** (FR-033); controles
      simples o suficiente para uso por crianças (FR-034). Tratar a **ausência de escolha** do
      jogador de forma definida, sem travar a partida (FR-059). O jogador **DEVE** conseguir cobrar
      (FR-028) e defender (FR-029) pênaltis. **Testes T-28 e T-29**: `zone_at_position` cobre as 9
      zonas, e mouse, teclado e toque produzem a **mesma** zona (Artigo VIII.4)

- [X] T041 [US1] **Evidência de US1**: rodar a suíte de US1 headless e registrar a saída real.
      Registrar também o determinismo: a mesma sequência de zonas produz o mesmo placar final
      (SC-005). **Testes T-27, T-31 e T-32** (FR-025, FR-049): o placar é atualizado **antes** de
      `attempt_resolved`; a apresentação **nunca** altera o placar; e interromper a animação **não**
      altera o placar

**Checkpoint**: US1 funcional e testável isoladamente. **MVP atingido.**

---

## Phase 4: User Story 2 - Identificar os protagonistas e escolher quem controlar (Priority: P2)

**Goal**: cadastro com validação, escolha do protagonista e menu inicial com nomes reais na
interface.

**Independent Test**: preencher o cadastro, escolher cada um dos dois protagonistas e confirmar
que os nomes informados aparecem na interface da partida.

### Tests for User Story 2 ⚠️

- [X] T042 [P] [US2] Teste da validação de cadastro em
      `dog-friend-gol/tests/unit/test_player_profile.gd` — T-33 parcial: nome da criança não vazio;
      idade da criança preenchida; nome do cachorro não vazio; idade do cachorro preenchida.
      Campo obrigatório vazio **bloqueia** o avanço e indica o campo pendente (FR-045, FR-056)

- [X] T043 [P] [US2] Teste da regra de idade × dificuldade em
      `dog-friend-gol/tests/unit/test_ai_difficulty.gd` — T-33 de `contracts/use-case-api.md`:
      `resolve_difficulty(8, HARD) == HARD`, `resolve_difficulty(10, EASY) == EASY`,
      `resolve_difficulty(12, HARD) == NORMAL`, `resolve_difficulty(12, EASY) == NORMAL`.
      **A idade acima de 10 sobrepõe a escolha** (FR-043)

### Implementation for User Story 2

- [X] T044 [P] [US2] Criar `PlayerProfile` em
      `dog-friend-gol/scripts/application/player_profile.gd`. Campos: `child_name: String`
      (**não vazio**), `child_age: int` (**preenchido**), `dog_name: String` (**não vazio**),
      `dog_age: int` (**preenchido**), `controlled_character: CharacterId`

- [X] T045 [P] [US2] Criar o enum `AiDifficulty` em
      `dog-friend-gol/scripts/application/ai_difficulty.gd` com `EASY`, `NORMAL`, `HARD`,
      documentando: **até 10 anos** → `EASY` ou `HARD` (duas opções selecionáveis); **acima de
      10 anos** → `NORMAL` (padrão, não selecionável)

- [X] T046 [US2] Implementar `resolve_difficulty(child_age: int, chosen: AiDifficulty) -> AiDifficulty`
      em `dog-friend-gol/scripts/application/ai_difficulty.gd`. Se `child_age > 10`, retornar
      `NORMAL` **independentemente** de `chosen`. Fazer T043 passar

- [X] T047 [P] [US2] Implementar a ação `choose_character_action` em
      `dog-friend-gol/scripts/application/actions/choose_character_action.gd` (FR-004)

- [X] T048 [US2] Criar a cena `dog-friend-gol/scenes/registration.tscn` e o script de validação.
      Coleta nome e idade da criança e do cachorro. Bloqueia o avanço enquanto houver campo
      obrigatório inválido e **indica qual campo está pendente** (FR-003, FR-045, FR-056). A
      interface acomoda nomes longos ou com caracteres especiais sem quebrar o layout

- [X] T049 [US2] Criar a cena `dog-friend-gol/scenes/character_select.tscn` (FR-004). Exibe os
      dois protagonistas e a escolha permanece válida durante toda a partida

- [X] T050 [US2] Criar a cena `dog-friend-gol/scenes/main_menu.tscn` com título, protagonistas e
      botão funcional de início, mais acesso funcional a opções e créditos (FR-001, FR-002)

- [X] T051 [US2] Criar `dog-friend-gol/scripts/presentation/screen_router.gd` para navegação entre
      telas: menu → cadastro → escolha de personagem → partida

- [X] T052 [US2] Ligar os nomes informados à interface da partida em
      `dog-friend-gol/scripts/presentation/match_view.gd`: substituir rótulos genéricos pelos nomes
      do cadastro. O domínio **não** conhece os nomes fixos (FR-008, Artigo VI.3). O jogador
      controla **um único** protagonista durante toda a partida, com o outro sob controle da IA
      local (FR-027). Fazer T042 passar

- [ ] T053 [US2] **Evidência de US2**: executar o fluxo no editor, com cada um dos dois
      protagonistas controlados pelo jogador, e registrar que os nomes aparecem corretamente na
      tela da partida. Verificar **SC-001** (iniciar partida em até 3 ações: iniciar, preencher
      cadastro, escolher personagem)

**Checkpoint**: US1 e US2 funcionam independentemente.

---

## Phase 5: User Story 3 - Enfrentar um adversário que joga de forma variada e justa (Priority: P3)

**Goal**: IA local que cobra, defende, reage ao estado, varia entre partidas e **nunca** acessa a
escolha secreta do jogador.

**Independent Test**: executar partidas repetidas e verificar que o adversário cobra, defende,
escolhe zonas distintas e não acessa a escolha do jogador antes de a própria decisão estar tomada.

### Tests for User Story 3 ⚠️

- [X] T054 [P] [US3] Teste da **garantia de interface** em
      `dog-friend-gol/tests/integration/test_ai_fairness.gd` — T-26: chamar
      `choose_defense_zone(state, rng)` com o mesmo `state` e `rng` **antes e depois** de o jogador
      escolher sua zona deve produzir o **mesmo** resultado. Se diferir, a IA está trapaceando
      (FR-042)

- [X] T055 [P] [US3] Teste de variação da IA em
      `dog-friend-gol/tests/integration/test_ai_variation.gd` — SC-010: executar N partidas com
      sementes distintas e confirmar que as decisões variam. Executar N partidas com a **mesma**
      semente e confirmar que são idênticas (determinismo do teste)

- [X] T056 [P] [US3] Teste de reação ao estado em
      `dog-friend-gol/tests/integration/test_ai_context.gd` — FR-040: a distribuição de escolhas
      difere entre placar confortável, placar apertado e morte súbita. Confirmar também que a
      dificuldade altera a distribuição sem alterar as regras (FR-043)

### Implementation for User Story 3

- [X] T057 [US3] Implementar `choose_shot_zone(state: MatchState, rng: RngPort) -> ShotZone` em
      `dog-friend-gol/scripts/adapters/outbound/ai_opponent.gd`. A assinatura **não recebe** a zona
      do defensor jogador (FR-042)

- [X] T058 [US3] Implementar `choose_defense_zone(state: MatchState, rng: RngPort) -> ShotZone` em
      `dog-friend-gol/scripts/adapters/outbound/ai_opponent.gd`. A assinatura **não recebe** a zona
      do cobrador jogador (FR-042). Fazer T054 passar

- [X] T059 [US3] Implementar a escolha ponderada pelo contexto em
      `dog-friend-gol/scripts/adapters/outbound/ai_opponent.gd`: considerar placar, cobranças
      restantes, situação de vitória antecipada e morte súbita (FR-040). Nenhum serviço externo ou
      API paga (FR-044). Fazer T056 passar

- [X] T060 [US3] Implementar a variação por `rng_port` (FR-041) e as distribuições por
      `AiDifficulty` em `dog-friend-gol/scripts/adapters/outbound/ai_opponent.gd`: `EASY` favorece
      zonas centrais e não pune excessivamente o jogador; `HARD` explora melhor os cantos altos;
      `NORMAL` é o padrão. A IA cobra (FR-037), defende (FR-038) e escolhe zonas (FR-039).
      **A dificuldade não altera as regras** — só a distribuição. Fazer T055 passar

- [X] T061 [US3] Integrar a IA ao caso de uso `resolve_attempt`, garantindo que a IA decide
      **antes** de conhecer a escolha do jogador, nos dois papéis (jogador cobrador → IA escolhe
      defesa; jogador defensor → IA escolhe chute)

- [X] T062 [US3] **Evidência de US3**: executar a suíte de US3 headless
      (`dog-friend-gol/tests/integration/`) e registrar a saída real, incluindo a contagem de
      variação entre partidas

**Checkpoint**: as três primeiras user stories funcionam independentemente.

---

## Phase 6: User Story 4 - Vivenciar a entrada no estádio e o encerramento afetivo (Priority: P4)

**Goal**: introdução pulável e sequência final com comemoração, abraço e oferta opcional de
itens.

**Independent Test**: percorrer a introdução, concluir uma partida com cada protagonista vencedor
e verificar que o abraço ocorre nos dois casos e que a oferta de itens é opcional.

### Tests for User Story 4 ⚠️

- [X] T063 [P] [US4] Teste do estado após pular a introdução em
      `dog-friend-gol/tests/integration/test_intro_skip.gd` — FR-058: pular a introdução em
      qualquer momento **não** altera o estado da partida nem o placar

- [X] T064 [P] [US4] Teste da ordem da sequência final em
      `dog-friend-gol/tests/integration/test_ending_flow.gd` — FR-010, SC-008: o abraço ocorre
      **independentemente** de quem venceu (testar as duas vitórias); a oferta de itens **não**
      condiciona o abraço nem o encerramento; sem oferta, o fluxo segue para o menu

### Implementation for User Story 4

- [X] T065 [P] [US4] Criar a cena `dog-friend-gol/scenes/intro.tscn` com os protagonistas entrando
      no estádio e as torcidas (crianças apoiando a criança, cachorros apoiando a Branquinha).
      Emitir `intro_finished` ao terminar (FR-005). Manter a aparência canônica dos protagonistas
      consistente em todas as cenas: criança com o **uniforme verde com a letra "M"**, Branquinha
      com o **colete azul** (FR-052)

- [X] T066 [US4] Implementar o botão de pular a introdução a qualquer momento (FR-006, FR-058).
      Fazer T063 passar

- [X] T067 [P] [US4] Criar a cena `dog-friend-gol/scenes/ending.tscn` com comemoração do vencedor,
      abraço entre os protagonistas e oferta **opcional** de brinquedo e bifinho (FR-009, FR-010,
      FR-011)

- [X] T068 [US4] Implementar a animação de comemoração e o abraço nos dois casos de vitória.
      Fazer T064 passar

- [X] T069 [US4] Implementar a oferta opcional de itens em
      `dog-friend-gol/scenes/ending.tscn`: a ausência de oferta **não** bloqueia o avanço para o
      menu (FR-011)

- [X] T070 [US4] Criar `dog-friend-gol/scripts/presentation/character_animator.gd` com animações de
      chute e defesa para os dois protagonistas: a criança cobra com os pés e defende com as mãos e
      o corpo (FR-030); a Branquinha cobra com o focinho e defende com saltos em direções
      diferentes (FR-031). A apresentação cobre entrada no estádio, preparação e chute da criança,
      chute da Branquinha, defesa da criança, saltos defensivos da Branquinha, reações a gol, defesa
      e bola para fora, comemorações, abraço e oferta de itens (FR-053)

- [X] T071 [US4] Implementar **reação visual distinta** para gol, defesa e bola para fora em
      `dog-friend-gol/scripts/presentation/character_animator.gd` (FR-054). As animações apenas
      apresentam o resultado já decidido e **nunca** alteram o placar (FR-025, FR-055)

- [ ] T072 [US4] **Evidência de US4**: concluir uma partida com cada protagonista vencedor
      (`dog-friend-gol/scenes/ending.tscn`) e registrar que o abraço ocorreu nos dois casos e que
      pular a introdução preservou o estado

**Checkpoint**: as quatro primeiras user stories funcionam independentemente.

---

## Phase 7: User Story 5 - Iniciar uma nova partida (Priority: P5)

**Goal**: retorno ao menu e nova partida sem nenhum resíduo da anterior.

**Independent Test**: concluir uma partida, retornar ao menu e iniciar outra, conferindo que
nenhum resíduo da partida anterior permanece.

### Tests for User Story 5 ⚠️

- [X] T073 [P] [US5] Teste de ausência de resíduo em
      `dog-friend-gol/tests/integration/test_new_match.gd` — T-24 e SC-009: após `reset_match`,
      `score == [0, 0]`, `shots_taken == [0, 0]`, `round == 1`, `attempts` vazio, `winner == -1`,
      `phase == NOT_STARTED`. Executar uma partida completa, reiniciar e confirmar que nenhum dado
      anterior permanece ativo

- [X] T074 [P] [US5] Teste de novo sorteio em `dog-friend-gol/tests/integration/test_new_match.gd`
      — FR-050: um **novo** sorteio é realizado na partida seguinte, com sementes distintas

### Implementation for User Story 5

- [X] T075 [US5] Implementar o caso de uso `reset_match() -> MatchState` em
      `dog-friend-gol/scripts/application/use_cases/reset_match.gd` (FR-050). Descartar
      completamente o estado anterior. Fazer T073 passar

- [X] T076 [US5] Ligar o retorno ao menu após a sequência final e permitir uma nova partida com
      placar, turnos, sorteio e estado reiniciados (FR-012, FR-050)

- [X] T077 [US5] Garantir que sinais e conexões da partida anterior sejam desconectados no
      reinício em `dog-friend-gol/scripts/adapters/inbound/match_controller.gd` (T-30), evitando
      que uma tentativa antiga altere a partida nova

- [X] T078 [US5] **Evidência de US5**: executar a suíte de US5
      (`dog-friend-gol/tests/integration/test_new_match.gd`) e registrar a saída real

**Checkpoint**: todas as user stories funcionam independentemente.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Propósito**: exportação, conformidade e documentação.

- [X] T079 [P] Criar `dog-friend-gol/export_presets.cfg` com os presets **Web** e **Android**
      (R-10). O preset versionado **DEVE** ter os campos de senha do keystore **vazios** — o Godot
      grava senha em texto claro (Artigo XII). Senhas reais vêm de variável de ambiente ou entrada
      manual

- [X] T080 [P] Configurar o preset Web com renderer `gl_compatibility` (já configurado no projeto)
      e documentar em `quickstart.md` que a exportação Web exige **servidor HTTP** — não funciona
      em `file://`

- [X] T081 [P] Configurar o preset Android em `dog-friend-gol/export_presets.cfg` com identificador
      de aplicativo, ícone, orientação e **permissões mínimas** (Artigo XII)

- [X] T082 **Verificação de segurança** (Artigo XII): rodar `git check-ignore` sobre
      `assets/private/`, `*.keystore`, `*.jks`, `*.p12`, `*.pfx`, `*.pepk`, `*.apk`, `*.aab`,
      `*.pck`, `*.wasm` e confirmar que **todos** estão ignorados, e que `export_presets.cfg`
      **não** está ignorado. Registrar a evidência

- [X] T083 **Verificação de determinismo** (FR-025, SC-005): executar a mesma sequência de zonas
      duas vezes via `dog-friend-gol/tests/integration/test_match_flow.gd` e confirmar placar final
      idêntico. Registrar a evidência

- [ ] T084 [P] Rodar `quickstart.md` de ponta a ponta em ambiente preparado e corrigir divergências
      entre o documento e a realidade (CA-11)

- [X] T085 [P] Confirmar que nenhuma funcionalidade principal exige conexão com a Internet
      (FR-051, SC-012) e que não há dependência externa nem API paga (FR-044, Artigo II.7).
      Registrar a verificação em `dog-friend-gol/tests/README.md`

- [X] T086 Atualizar a documentação: registrar em `dog-friend-gol/tests/README.md` o comando da
      suíte completa; atualizar `AGENTS.md` e `.github/copilot-instructions.md` com os comandos de
      exportação (CA-12)

- [X] T087 **Relatório de critérios de aceitação**: preencher o estado real de CA-01 a CA-12 em
      `specs/001-penalty-match-mvp/plan.md` (seção "Critérios de Aceitação"). Critérios não
      executados **MUST** ser registrados como **não verificados**, nunca como aprovados
      (Artigo VII.7). CA-06, CA-07, CA-08 e CA-09 permanecem bloqueados por ausência de templates
      de exportação, Android SDK e dispositivo físico. Registrar também os critérios que dependem de
      **observação com uma criança**: **SC-006** (partida completa em menos de 5 minutos), **SC-007**
      (a criança identifica quem está cobrando sem instrução externa) e **SC-011** (comportamento
      equivalente em navegador e Android) — nenhum deles é verificável sem dispositivo e uso real,
      portanto **não podem** ser declarados aprovados

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sem dependências — começa imediatamente
- **Foundational (Phase 2)**: depende do Setup — **BLOQUEIA todas as user stories**
- **User Stories (Phases 3–7)**: dependem da Foundational
  - Podem prosseguir em paralelo (se houver capacidade)
  - Ou sequencialmente na ordem de prioridade P1 → P2 → P3 → P4 → P5
- **Polish (Phase 8)**: depende das user stories desejadas estarem completas

### User Story Dependencies

- **US1 (P1)**: começa após a Foundational. **Sem dependência de outras histórias**
- **US2 (P2)**: começa após a Foundational. Independentemente testável. Fornece o cadastro que a
  US1 consome na interface, mas a US1 é validável sem ela (teste headless do domínio)
- **US3 (P3)**: começa após a Foundational. Depende da assinatura de `MatchState` (T024) e do
  `RngPort` (T010). Independentemente testável
- **US4 (P4)**: começa após a Foundational. Depende de `match_finished` (T037) e de `ShotResult`
  (T007). Independentemente testável
- **US5 (P5)**: começa após a Foundational. Depende de `MatchState` (T024). Independentemente
  testável

### Within Each User Story

- Testes **DEVEM** ser escritos e **FALHAR** antes da implementação
- Entidades antes do estado; estado antes dos casos de uso; casos de uso antes dos adapters;
  adapters antes das cenas
- História completa antes de avançar para a próxima prioridade

### Parallel Opportunities

- T006–T012 (enums, port, adapter, evento) são todos arquivos distintos → paralelo
- T017–T019 (três arquivos de teste de US1) → paralelo
- T020–T022 (três entidades de US1) → paralelo
- T042–T043 (testes de US2) → paralelo; T044–T045 (entidades de US2) → paralelo
- T054–T056 (testes de US3) → paralelo
- T063–T064 (testes de US4) → paralelo
- T073–T074 (testes de US5) → paralelo
- Após a Foundational, US1–US5 podem ser trabalhadas em paralelo por pessoas diferentes

---

## Parallel Example: User Story 1

```bash
# Lançar os três arquivos de teste de US1 juntos (devem FALHAR primeiro):
Task: "Teste das 81 combinações em dog-friend-gol/tests/unit/test_zone_resolution.gd"
Task: "Teste das conversões de zona em dog-friend-gol/tests/unit/test_shot_zone.gd"
Task: "Teste do estado da partida em dog-friend-gol/tests/unit/test_match_state.gd"

# Lançar as três entidades de US1 juntas:
Task: "Criar Participant em dog-friend-gol/scripts/domain/participant.gd"
Task: "Criar ShotAttempt em dog-friend-gol/scripts/domain/shot_attempt.gd"
Task: "Criar CoinToss em dog-friend-gol/scripts/domain/coin_toss.gd"
```

---

## Parallel Example: Foundational

```bash
# Sete arquivos independentes, todos sem dependência entre si:
Task: "Criar enum ShotZone em dog-friend-gol/scripts/domain/shot_zone.gd"
Task: "Criar enum ShotResult em dog-friend-gol/scripts/domain/shot_result.gd"
Task: "Criar enum MatchPhase em dog-friend-gol/scripts/domain/match_phase.gd"
Task: "Criar enum CharacterId em dog-friend-gol/scripts/domain/character_id.gd"
Task: "Criar contrato RngPort em dog-friend-gol/scripts/application/ports/rng_port.gd"
Task: "Implementar GodotRng em dog-friend-gol/scripts/adapters/outbound/godot_rng.gd"
Task: "Criar enum MatchEvent em dog-friend-gol/scripts/application/match_event.gd"
```

---

## Implementation Strategy

### MVP First (User Story 1 apenas)

1. Completar a Phase 1: Setup — **incluindo a evidência T005 do GUT**
2. Completar a Phase 2: Foundational (CRÍTICO — bloqueia todas as histórias)
3. Completar a Phase 3: US1
4. **PARAR e VALIDAR**: rodar a suíte de US1 headless, conferir as 81 combinações e a saída real
5. A partir daqui o núcleo do jogo está provado

**Por que US1 é o MVP**: o teste independente de US1 não depende de animações, cenas ou arte
final. É a única história que pode ser considerada pronta com evidência puramente automatizada.

### Incremental Delivery

1. Setup + Foundational → fundação pronta
2. US1 → validar headless → **MVP**
3. US2 → validar no editor (cadastro e escolha de personagem)
4. US3 → validar por variação entre partidas
5. US4 → validar percorrendo introdução e final
6. US5 → validar reinício sem resíduo
7. Polish → exportação e conformidade

### Parallel Team Strategy

1. Setup + Foundational em conjunto
2. Com a Foundational pronta:
   - Pessoa A: US1 (domínio — o caminho crítico)
   - Pessoa B: US2 (telas de entrada)
   - Pessoa C: US3 (IA)
   - Pessoa D: US4 (apresentação)
   - Pessoa E: US5 (reinício)
3. As histórias se integram sem quebrar umas às outras

---

## Notes

- `[P]` = arquivos diferentes, sem dependência pendente
- Testes **DEVEM** falhar antes da implementação (Artigo VII, TDD)
- **Nenhuma conclusão pode ser declarada sem saída de comando real** (Artigo VII.7)
- A regra de resolução das 81 combinações já foi validada empiricamente em Godot 4.7.2
  (`VEREDITO: PASS`, ver `contracts/zone-grid.md` §4). As tarefas T017 e T023 **formalizam** essa
  verificação como suíte permanente — não a estão descobrindo do zero
- **Bloqueios de ambiente conhecidos**: templates de exportação ausentes (CA-06, CA-09),
  Android SDK e `adb` ausentes (CA-07, CA-08), JDK 25 em vez de 17. Esses critérios serão
  registrados como **não verificados**
- Evitar: tarefas vagas, conflito de arquivo, dependência cruzada entre histórias que quebre a
  independência
