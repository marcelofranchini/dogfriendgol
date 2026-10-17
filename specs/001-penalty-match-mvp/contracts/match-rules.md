# Contrato: Regras da Partida

**Feature**: `001-penalty-match-mvp` | **Date**: 2026-10-17
**Camada**: Domain (`scripts/domain/`)
**Requisitos**: FR-013 a FR-026, FR-060 a FR-063, Artigo VI da Constituição

Contrato do estado da partida e das regras de progressão. Complementa
[`zone-grid.md`](./zone-grid.md), que trata apenas da resolução de uma cobrança individual.

---

## 1. Estado da partida

### Contrato

```gdscript
## Fase da partida. Transições válidas em data-model.md.
enum MatchPhase {
    NOT_STARTED,    ## Antes do sorteio
    REGULAR,        ## Cinco cobranças iniciais por participante
    SUDDEN_DEATH,   ## Morte súbita após empate
    FINISHED,       ## Partida encerrada com vencedor
}

## Estado completo de uma partida. Única fonte de verdade do placar.
class MatchState:
    var phase: MatchPhase
    var round: int              ## 1-based
    var shooter_index: int      ## 0 ou 1
    var participants: Array[Participant]
    var score: Array[int]       ## [score_0, score_1]
    var shots_taken: Array[int] ## [taken_0, taken_1]
    var winner: int             ## índice do vencedor, ou -1
    var attempts: Array[ShotAttempt]
```

### Constantes

```gdscript
const INITIAL_SHOTS_PER_PARTICIPANT: int = 5   ## FR-014
const PARTICIPANT_COUNT: int = 2               ## FR-001
```

---

## 2. Invariantes

Devem valer **após toda operação**. Violação é bug de implementação.

| # | Invariante | Requisito |
|---|---|---|
| I-01 | `participants.size() == 2` | FR-001 |
| I-02 | `score[i] >= 0` para todo i | FR-013 |
| I-03 | `shots_taken[i] >= 0` para todo i | FR-014 |
| I-04 | `shots_taken[i] <= 5` em `REGULAR` | FR-014 |
| I-05 | `shots_taken[i]` nunca diminui | FR-022 |
| I-06 | `phase == FINISHED` ⟺ `winner != -1` | FR-024 |
| I-07 | `phase != FINISHED` ⟹ `winner == -1` | FR-021 |
| I-08 | `score` e `shots_taken` imutáveis em `FINISHED` | FR-024 |
| I-09 | `round >= 1` quando `phase != NOT_STARTED` | FR-026 |
| I-10 | `attempts.size() == shots_taken[0] + shots_taken[1]` | Consistência |
| I-11 | Diferença de `shots_taken` entre participantes ≤ 1 | FR-015 |

---

## 3. Operações

### `start_match`

```gdscript
## Inicia a partida. Pré: phase == NOT_STARTED.
## Pós: phase == REGULAR, placar zerado, turnos definidos pelo sorteio.
func start_match(participants: Array[Participant], coin_toss: CoinToss) -> void
```

| Pós-condição | Requisito |
|---|---|
| `score == [0, 0]` | FR-013 |
| `shots_taken == [0, 0]` | FR-014 |
| `round == 1` | FR-026 |
| `phase == REGULAR` | FR-026 |
| `shooter_index == coin_toss.first_shooter_index` | FR-007 |
| `winner == -1` | FR-021 |

---

### `apply_attempt`

Operação central. Registra uma cobrança e avança o estado.

```gdscript
## Aplica uma cobrança resolvida ao estado.
##
## Pré-condições (violação retorna erro, não exceção):
##   - phase ∈ {REGULAR, SUDDEN_DEATH}       (FR-024)
##   - shooter_index é válido                (FR-023)
##   - participante não cobrou nesta rodada  (FR-022)
##   - attempt.shooter_index == shooter_index
##
## Pós-condições:
##   - score atualizado se result == GOAL
##   - shots_taken[shooter] incrementado
##   - turno alternado
##   - fase reavaliada (encerramento antecipado / morte súbita)
func apply_attempt(attempt: ShotAttempt) -> ApplyResult
```

### Sequência interna

```text
apply_attempt(attempt):
    1. validar pré-condições                    -> erro se inválido
    2. registrar attempt em attempts
    3. shots_taken[shooter] += 1
    4. if attempt.result == GOAL:
           score[shooter] += 1
    5. alternar shooter_index
    6. se ambos cobraram nesta rodada:
           round += 1
    7. avaliar encerramento:
           a. if REGULAR and can_finish_early():   -> FINISHED
           b. if REGULAR and both_took_five():
                  if scores differ:                -> FINISHED
                  else:                            -> SUDDEN_DEATH
           c. if SUDDEN_DEATH and both_took_in_round():
                  if round results differ:         -> FINISHED
                  else:                            -> continua
    8. retornar ApplyResult { state, events }
```

**Nota sobre o passo 6 e 7c**: em `SUDDEN_DEATH` a rodada avança apenas quando **ambos**
cobraram (FR-021). O vencedor é decidido somente após a segunda cobrança da rodada.

---

### `can_finish_early`

```gdscript
## Verdadeiro se o participante em desvantagem não pode mais alcançar o adversário.
func can_finish_early() -> bool
```

```text
can_finish_early():
    para cada participante i:
        remaining = 5 - shots_taken[i]
        max_possible = score[i] + remaining
        other = 1 - i
        if max_possible < score[other]:
            return true, winner = other
    return false
```

**Limite exato (edge case crítico)**: usar `<` estritamente. Se
`max_possible == score[other]`, o empate ainda é alcançável e a partida **continua**.
Requisito FR-017 e o edge case "vitória antecipada no limite exato" da spec.

**Exemplo**: placar 3–1, faltando 2 cobranças para quem tem 1:
`max_possible = 1 + 2 = 3`, que **não** é `< 3` → partida **continua**.
Se o placar fosse 3–0 com 2 restantes: `0 + 2 = 2 < 3` → encerra.

---

### `evaluate_sudden_death_round`

```gdscript
## Avalia a rodada de morte súbita após ambos cobrarem.
func evaluate_sudden_death_round() -> void
```

| Resultados da rodada | Ação | Requisito |
|---|---|---|
| Ambos marcaram | Continua | FR-020 |
| Ambos não marcaram | Continua | FR-020 |
| Um marcou, o outro não | `FINISHED`, vencedor = quem marcou | FR-019 |

**Proibido**: encerrar antes de ambos cobrarem (FR-021).

---

### `reset_match`

```gdscript
## Reinicia a partida. Pré: phase == FINISHED.
## Pós: estado equivalente a uma partida nova (FR-050).
func reset_match() -> void
```

| Pós-condição | Requisito |
|---|---|
| `score == [0, 0]` | FR-050 |
| `shots_taken == [0, 0]` | FR-050 |
| `round == 1` | FR-050 |
| `attempts` vazio | FR-050 |
| `winner == -1` | FR-050 |
| `phase == NOT_STARTED` | FR-050 |
| **Nenhum resíduo da partida anterior** | SC-009 |

---

## 4. Alternância de papéis

A cada tentativa, quem cobra muda (FR-015). O papel de **defensor** é sempre o outro participante.

| Rodada | Cobrador | Defensor |
|---|---|---|
| 1 | `first_shooter` | outro |
| 2 | outro | `first_shooter` |
| 3 | `first_shooter` | outro |
| ... | alterna | alterna |

**Nota**: não há goleiro separado (Clarifications). O defensor é o outro protagonista.

---

## 5. Erros e recusas

Toda recusa retorna um resultado tipado — **nunca** altera o estado.

```gdscript
enum ApplyError {
    NONE,
    MATCH_FINISHED,       ## FR-024
    NOT_YOUR_TURN,        ## FR-023
    ALREADY_SHOT_THIS_ROUND,  ## FR-022
    INVALID_ZONE,         ## FR-032
    INVALID_PHASE,        ## FR-026
}
```

| Erro | Condição | Requisito |
|---|---|---|
| `MATCH_FINISHED` | `phase == FINISHED` | FR-024 |
| `NOT_YOUR_TURN` | `attempt.shooter_index != shooter_index` | FR-023 |
| `ALREADY_SHOT_THIS_ROUND` | participante já cobrou na rodada | FR-022 |
| `INVALID_ZONE` | zona fora das 9 | FR-032 |
| `INVALID_PHASE` | `phase == NOT_STARTED` | FR-026 |

**Garantia**: em qualquer erro, `score`, `shots_taken` e `phase` permanecem **inalterados**.

---

## 6. Requisitos de teste

| # | Teste | Requisito |
|---|---|---|
| T-10 | Placar inicia em 0–0 | FR-013 |
| T-11 | Cada participante tem 5 cobranças iniciais | FR-014 |
| T-12 | Turnos alternam corretamente | FR-015 |
| T-13 | Encerramento antecipado nos casos corretos | FR-017 |
| T-14 | **Sem** encerramento no limite exato | FR-017 |
| T-15 | Empate após 5+5 entra em morte súbita | FR-018 |
| T-16 | Morte súbita encerra com resultados diferentes | FR-019 |
| T-17 | Morte súbita continua com resultados iguais | FR-020 |
| T-18 | **Nenhum** vencedor antes do 2º cobrar na morte súbita | FR-021 |
| T-19 | Cobrança duplicada é recusada | FR-022 |
| T-20 | Cobrança fora do turno é recusada | FR-023 |
| T-21 | Alteração após encerramento é recusada | FR-024 |
| T-22 | Placar independe de animações | FR-025 |
| T-23 | Todas as invariantes I-01 a I-11 após cada operação | Consistência |
| T-24 | `reset_match` não deixa resíduo | FR-050, SC-009 |
| T-25 | Morte súbita prolongada (10+ rodadas) funciona | Edge case |

---

## 7. Determinismo

O resultado da partida depende **exclusivamente** de:
1. A sequência de zonas escolhidas pelo cobrador
2. A sequência de zonas escolhidas pelo defensor
3. O resultado do sorteio inicial

**Nada mais.** Não depende de: tempo, FPS, duração de animação, estado visual, ordem de execução
de nós (FR-025, FR-061, Artigo VI.8).

**Implicação para testes**: a mesma sequência de entradas deve produzir o mesmo placar final, e
isso é verificável sem Godot rodando (SC-005).
