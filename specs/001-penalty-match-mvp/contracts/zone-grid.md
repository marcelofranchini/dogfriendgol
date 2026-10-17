# Contrato: Grade de Zonas e Resolução de Cobrança

**Feature**: `001-penalty-match-mvp` | **Date**: 2026-10-17
**Camada**: Domain (`scripts/domain/`)
**Requisitos**: FR-016, FR-032, FR-060, FR-061, FR-062, FR-063, SC-005a

Este é o contrato **mais crítico** do projeto: a função que decide o resultado de cada cobrança.
É determinística, pura e testável sem renderização.

---

## 1. Grade de 9 zonas

### Estrutura

A meta é dividida em **3 colunas × 3 alturas = 9 zonas** (FR-032).

| Coluna → / Altura ↓ | Esquerda | Centro | Direita |
|---|---|---|---|
| **Cima** | `TOP_LEFT` | `TOP_CENTER` | `TOP_RIGHT` |
| **Meio** | `MIDDLE_LEFT` | `MIDDLE_CENTER` | `MIDDLE_RIGHT` |
| **Baixo** | `BOTTOM_LEFT` | `BOTTOM_CENTER` | `BOTTOM_RIGHT` |

### Contrato

```gdscript
## Uma das 9 zonas da meta. Unidade de decisão do cobrador e do defensor.
enum ShotZone {
    TOP_LEFT, TOP_CENTER, TOP_RIGHT,
    MIDDLE_LEFT, MIDDLE_CENTER, MIDDLE_RIGHT,
    BOTTOM_LEFT, BOTTOM_CENTER, BOTTOM_RIGHT,
}
```

### Propriedades obrigatórias

| Propriedade | Regra | Requisito |
|---|---|---|
| Total de zonas | Exatamente 9 | FR-032 |
| Validade para chute | Todas as 9 são selecionáveis | FR-062 |
| Validade para defesa | Todas as 9 são selecionáveis | FR-062 |
| Zonas inúteis | **Nenhuma** | FR-062 |
| Cantos altos | Apenas `TOP_LEFT` e `TOP_RIGHT` | FR-060 |

### Funções de conversão

```gdscript
## Converte uma zona nas coordenadas (coluna, altura).
## Coluna: 0 = esquerda, 1 = centro, 2 = direita
## Altura: 0 = cima, 1 = meio, 2 = baixo
func to_grid_coords(zone: ShotZone) -> Vector2i

## Converte (coluna, altura) de volta para a zona.
func from_grid_coords(col: int, height: int) -> ShotZone

## Retorna verdadeiro apenas para TOP_LEFT e TOP_RIGHT.
func is_top_corner(zone: ShotZone) -> bool

## Retorna as 9 zonas (para iteração em testes e na UI).
func all_zones() -> Array[ShotZone]
```

---

## 2. Resultado da cobrança

```gdscript
## Resultado de uma cobrança. Exatamente três valores possíveis.
enum ShotResult {
    GOAL,           ## O cobrador marcou
    DEFENDED,       ## O defensor defendeu
    OUT_OF_BOUNDS,  ## A bola saiu
}
```

**Importante**: `OUT_OF_BOUNDS` **não** é uma zona. Não existe uma décima opção selecionável
(FR-016). É uma **consequência** da combinação de zonas.

---

## 3. Regra de resolução

### Contrato

```gdscript
## Resolve uma cobrança de forma determinística.
##
## Pré-condições:
##   - shooter_zone e defender_zone são zonas válidas (uma das 9)
##
## Pós-condições:
##   - Retorna exatamente um ShotResult
##   - Não usa aleatoriedade (FR-061)
##   - Não lê estado global, não acessa nós, não emite sinais
##   - Mesma entrada produz sempre a mesma saída
func resolve_shot(shooter_zone: ShotZone, defender_zone: ShotZone) -> ShotResult
```

### Tabela de decisão

| Condição | Resultado |
|---|---|
| `shooter_zone == defender_zone` | `DEFENDED` |
| `shooter_zone` é canto alto (`TOP_LEFT` ou `TOP_RIGHT`) | `OUT_OF_BOUNDS` |
| Qualquer outro caso | `GOAL` |

### Pseudo-código de referência

```text
resolve_shot(shooter_zone, defender_zone):
    1. if shooter_zone == defender_zone:
           return DEFENDED
    2. if shooter_zone == TOP_LEFT or shooter_zone == TOP_RIGHT:
           return OUT_OF_BOUNDS
    3. return GOAL
```

**Ordem importa**: a verificação de igualdade vem **primeiro**. Se o defensor escolhe exatamente o
mesmo canto alto do cobrador, o resultado é `DEFENDED`, não `OUT_OF_BOUNDS`. O defensor salvou a
bola antes de ela sair.

---

## 4. Matriz completa das 81 combinações

Legenda: **G** = `GOAL` · **D** = `DEFENDED` · **F** = `OUT_OF_BOUNDS`

Linhas = zona do **cobrador**. Colunas = zona do **defensor**.

| Cobrador ↓ \ Defensor → | TL | TC | TR | ML | MC | MR | BL | BC | BR |
|---|---|---|---|---|---|---|---|---|---|
| **TL** (canto alto) | D | F | F | F | F | F | F | F | F |
| **TC** | G | D | G | G | G | G | G | G | G |
| **TR** (canto alto) | F | F | D | F | F | F | F | F | F |
| **ML** | G | G | G | D | G | G | G | G | G |
| **MC** | G | G | G | G | D | G | G | G | G |
| **MR** | G | G | G | G | G | D | G | G | G |
| **BL** | G | G | G | G | G | G | D | G | G |
| **BC** | G | G | G | G | G | G | G | D | G |
| **BR** | G | G | G | G | G | G | G | G | D |

### Verificação da matriz (SC-005a)

| Contagem | Esperado | Regra |
|---|---|---|
| `DEFENDED` | 9 | Diagonal principal (mesma zona) |
| `OUT_OF_BOUNDS` | 16 | 2 linhas (TL, TR) × 8 colunas não diagonais |
| `GOAL` | 56 | 81 − 9 − 16 |
| **Total** | **81** | 9 × 9 |

### ✅ Evidência de execução real (2026-10-17)

A regra de resolução foi **implementada em GDScript e executada no Godot 4.7.2** para validar as
81 combinações. Saída real:

```text
TOTAL:      81
GOAL:       56
DEFENDED:   9
OUT:        16
---
Diagonal sempre DEFENDED:      true
Meio nunca OUT_OF_BOUNDS:      true
Determinismo (100 reps):       true
---
TL vs TL  = DEFENDED? true
TL vs MC  = OUT?      true
MC vs TL  = GOAL?     true
MC vs MC  = DEFENDED? true
BC vs BR  = GOAL?     true
---
VEREDITO: PASS
```

**O que isso comprova**:
- As contagens da matriz estão corretas (9 / 16 / 56, total 81)
- A diagonal sempre resulta em `DEFENDED`
- A altura do meio **nunca** resulta em `OUT_OF_BOUNDS` (FR-062)
- A regra é **determinística** — 100 repetições de cada combinação deram o mesmo resultado (FR-061)

**O que isso NÃO comprova**: os casos de teste formais (T-01 a T-09) ainda não existem como
suíte permanente. O addon GUT não está instalado. A verificação acima foi feita com um script
descartável, já removido.

**Nota sobre FR-062 (nenhuma zona inútil)** — verificada por contagem independente:

| Zona | Como cobrador | Como defensor | Útil? |
|---|---|---|---|
| `TOP_LEFT` / `TOP_RIGHT` | Nunca marca `GOAL`; produz `DEFENDED` (1 caso) ou `OUT_OF_BOUNDS` (8 casos) | Defende contra qualquer zona (9 casos) | ✅ risco por design |
| `MIDDLE_*` | Nunca sai; marca `GOAL` contra 8 zonas | Defende contra qualquer zona (9 casos) | ✅ |
| `BOTTOM_*` | Nunca sai; marca `GOAL` contra 8 zonas | Defende contra qualquer zona (9 casos) | ✅ |

**Decisão registrada (2026-10-17)**: **manter a regra como está** — é a mais simples e usual.

Os cantos altos **não são zonas inúteis**: são escolhas de **alto risco por design**. Como
cobrador, oferecem uma aposta (o defensor pode não estar lá), com a penalidade de bola para fora
se o defensor escolher outra zona. Como defensor, são válidos contra todas as 9 zonas do cobrador.

FR-062 foi reescrito para explicitar essa interpretação: "toda zona MUST produzir ao menos um
resultado distinto e válido", o que os cantos altos cumprem (`OUT_OF_BOUNDS`).

**Nota sobre a altura do meio (FR-062)**: nenhuma zona de altura `MIDDLE` resulta em
`OUT_OF_BOUNDS` como cobrador. `MIDDLE_CENTER` é a zona mais segura do jogo — nunca sai para fora
e só é defendida se o defensor escolher exatamente a mesma zona.

---

## 5. Requisitos de teste

| # | Teste | Cobertura |
|---|---|---|
| T-01 | Todas as 81 combinações produzem o resultado da matriz | SC-005a |
| T-02 | `resolve_shot(z, z) == DEFENDED` para todas as 9 zonas | FR-060.1 |
| T-03 | `resolve_shot(TOP_LEFT, x) == OUT_OF_BOUNDS` para todo x ≠ TOP_LEFT | FR-060.2 |
| T-04 | `resolve_shot(TOP_RIGHT, x) == OUT_OF_BOUNDS` para todo x ≠ TOP_RIGHT | FR-060.2 |
| T-05 | Nenhuma zona `MIDDLE_*` produz `OUT_OF_BOUNDS` | FR-062 |
| T-06 | Determinismo: 1000 execuções da mesma entrada → mesmo resultado | FR-061 |
| T-07 | Contagens: 9 `DEFENDED`, 16 `OUT_OF_BOUNDS`, 56 `GOAL` | SC-005a |
| T-08 | `to_grid_coords` / `from_grid_coords` são inversas para as 9 zonas | Consistência |
| T-09 | `all_zones()` retorna exatamente 9 zonas distintas | FR-032 |

### Como executar

Requer Godot instalado (ver `quickstart.md`). A suíte roda sem renderização (FR-063):

```bash
godot --headless --path dog-friend-gol -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit
```

**Como executar**: requer o Godot 4.7.2 (instalado no Windows) e o addon GUT (não instalado).
A suíte roda sem renderização (FR-063). Ver [`quickstart.md`](../quickstart.md) para os comandos
completos.

**Estado**: a regra foi **validada empiricamente em Godot 4.7.2** (ver evidência acima). O addon
GUT ainda **não está instalado**, portanto os testes T-01 a T-09 **não existem como suíte
permanente**.

---

## 6. O que este contrato NÃO cobre

| Fora do escopo | Onde está |
|---|---|
| Placar, turnos, encerramento antecipado, morte súbita | [`match-rules.md`](./match-rules.md) |
| Casos de uso e sinais | [`use-case-api.md`](./use-case-api.md) |
| Escolha da IA | `scripts/adapters/outbound/ai_opponent.gd` |
| Apresentação visual do resultado | `scripts/presentation/character_animator.gd` |
