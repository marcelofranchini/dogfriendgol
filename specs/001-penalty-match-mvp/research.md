# Research: Aventuras na Grama! — Primeira Versão Jogável

**Feature**: `001-penalty-match-mvp` | **Date**: 2026-10-17

Este documento resolve os `NEEDS CLARIFICATION` do Technical Context do plano e registra as
decisões técnicas com alternativas consideradas.

---

## ⚠️ CORREÇÃO IMPORTANTE: o ambiente tem Godot

**A versão anterior deste documento afirmava que o Godot não estava instalado. Isso estava
errado.** A verificação inicial consultou apenas o PATH do WSL, mas o Godot roda no **Windows**.

**Estado real, verificado em 2026-10-17**:

| Item | Valor verificado | Como foi verificado |
|---|---|---|
| Godot | **4.7.2.stable.official.ed1daf0bf** | `--version` |
| Executável | `/mnt/c/Users/franc/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe` | `ls` |
| Execução headless a partir do WSL | ✅ **FUNCIONA** | Script de teste imprimiu `GODOT_HEADLESS_OK` |
| Acesso ao projeto | ✅ via UNC `\\wsl.localhost\Ubuntu\...` | Executou o script com `res://` |
| Projeto registrado no editor | ✅ `//wsl$/Ubuntu/home/franchini190929/Projects/Game/dog-friend-gol` | `projects.cfg` |
| Templates de exportação | ❌ **AUSENTES** (diretório vazio) | `ls export_templates/` |
| Android SDK | ❌ Ausente | `ls AppData/Local/Android` |
| `adb` | ❌ Ausente | `which adb` |
| JDK | ⚠️ **25** (Godot Android exige **17**) | `ls Program Files/Eclipse Adoptium/` |

**Impacto nos critérios de aceitação**: CA-01, CA-02, CA-03, CA-04, CA-05, CA-09 e CA-10 passam a
ser **verificáveis** neste ambiente. CA-06, CA-07 e CA-08 (Android) continuam bloqueados por
falta de templates, SDK e dispositivo.

---

## R-01: Ferramenta de testes

**Decision**: Adotar **GUT (Godot Unit Test)** como ferramenta de testes.

**Rationale**:
- É um addon de teste para Godot escrito em GDScript, sem dependência de linguagens externas —
  compatível com o Artigo II.7 (proíbe Go/TypeScript/C#).
- Executa pela linha de comando com `godot --headless`, o que **agora está comprovado que
  funciona neste ambiente**.
- Permite testar as regras do domínio sem carregar cenas, atendendo ao Artigo VII.1.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **GoDotTest** | Também é um addon GDScript, mas tem ecossistema menor. Mantido como plano B. |
| **Testes manuais** | Não atendem ao Artigo VII.5 nem produzem evidência reproduzível. |
| **Sem framework** (scripts `assert` próprios) | Zero dependência, mas exige reimplementar descoberta de testes, relatório e isolamento. |
| **GdUnit4** | Mais poderoso, porém mais pesado — desproporcional ao escopo. |

**Tarefa de validação**: instalar o addon GUT no projeto e confirmar que
`godot --headless --script addons/gut/gut_cmdln.gd` executa a suíte. **Ainda não validado** — o
addon não está instalado.

**Impacto se indisponível**: cair para GoDotTest; se nenhum estiver acessível, implementar um
runner mínimo em GDScript e registrar a decisão.

---

## R-02: Representação da zona de chute

**Decision**: Usar um **`enum` de 9 valores** para a zona, com funções de conversão entre o enum e
o par (coluna, altura).

**Rationale**:
- GDScript suporta `enum` nativamente; valores nomeados evitam erros de índice numérico.
- Tipagem explícita (Artigo II.2) fica natural: `func resolve(shooter_zone: ShotZone, defender_zone: ShotZone) -> ShotResult`.
- A conversão explícita para (coluna, altura) deixa a regra de resolução legível e testável.
- Testar as 81 combinações (SC-005a) torna-se uma iteração dupla sobre 9 valores.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **`Vector2i(coluna, altura)`** | Não é auto-documentado (o que é `(0,0)`?) e permite valores fora da faixa. |
| **`String`** (`"top_left"`) | Sem verificação em tempo de compilação; erros de digitação passam silenciosamente. |
| **`Resource` customizado** | Permite dados extras, mas é pesado para um domínio puro e adiciona dependência do Godot ao domínio. |

**Tarefa de validação**: confirmar que o domínio permanece livre de imports do Godot. `enum` é
nativo do GDScript, portanto compatível.

---

## R-03: Comunicação entre camadas

**Decision**: Usar **sinais do Godot** para notificar a apresentação, com os casos de uso expondo
resultados de forma síncrona.

**Rationale**:
- Sinais são mecanismo nativo (Artigo II.3) e desacoplam quem emite de quem reage.
- A apresentação se conecta aos sinais sem que os casos de uso conheçam a UI — preserva o Artigo
  IV (apresentação não é fonte de verdade).
- O retorno síncrono do caso de uso permite testes sem loop de eventos.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **Chamadas diretas** (UI chama o caso de uso e lê o estado) | Simples, mas acopla a apresentação ao fluxo interno e dificulta múltiplos observadores (placar + animador). |
| **Barramento de eventos próprio** | Reimplementa sinais do Godot — complexidade desnecessária (Artigo V). |
| **Autoload singleton global** | Cria estado global difícil de testar e de resetar entre partidas (FR-050). |

**Tarefa de validação**: garantir que os sinais sejam declarados nos nós de apresentação, não no
domínio. O domínio não pode declarar sinais (seria dependência do Godot).

---

## R-04: Aleatoriedade testável

**Decision**: Introduzir o port **`rng_port`** com um gerador de números aleatórios injetável e
semente configurável.

**Rationale**:
- Há exatamente dois usos de aleatoriedade: o **sorteio de cara ou coroa** (FR-007) e a **variação
  da IA** (FR-041). A regra de resolução de cobrança **não** usa aleatoriedade (FR-061).
- Isolar o RNG permite injetar uma semente fixa nos testes, tornando o sorteio e a IA
  **determinísticos em teste** sem alterar o comportamento em produção.
- É o **único port com benefício concreto** — atende ao Artigo IV.6 (abstrações só quando trazem
  benefício) e ao Artigo V (evitar abstração desnecessária).

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **`randi()` direto no domínio** | Torna sorteio e IA não testáveis; impossibilita verificar SC-010 de forma reproduzível. |
| **Semente global do Godot** | Afeta todo o projeto; difícil de isolar por teste. |
| **Sem abstração, com injeção de número pronto** | Viável e mais simples, mas espalha a lógica de geração pelos casos de uso. |

**Tarefa de validação**: confirmar que a implementação concreta (`godot_rng`) usa
`RandomNumberGenerator` com `seed` configurável.

---

## R-05: Grafia do diretório `assests/`

**Decision**: **Renomear `assests/` → `assets/`** (decidido pelo usuário em 2026-10-17).
Executado: `mv assests assets`.

**Rationale**:
- A grafia `assests` é um erro de digitação, e o Artigo V da Constituição já especifica `assets/`
  como o diretório canônico de recursos.
- A verificação prévia mostrou que **nenhuma referência quebraria**: nenhum arquivo `.gd`,
  `.tscn`, `.cfg`, `.godot` ou `.import` referenciava `assests`, e o cache `.godot/` também não.
- Manter `assests/` ao lado de `assets/` criaria dois nomes quase idênticos — fonte provável de
  erro de caminho.

**Verificação executada antes da renomeação**:
- `grep -rn 'assests'` em `.md`, `.gd`, `.tscn`, `.cfg`, `.godot`, `.import` → apenas documentos
  do Spec Kit (que foram atualizados); nenhum código
- `grep -rl 'assests' dog-friend-gol/.godot/` → nenhum resultado
- Nenhum arquivo `.import` dentro de `assests/` (as imagens ainda não foram importadas pelo Godot)

**Consequência**: as 5 referências visuais permanecem intactas em `assets/references/`. Nenhuma
reimportação é necessária, pois as imagens nunca foram importadas.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **Preservar `assests/` e criar `assets/` separado** | Decisão anterior, revertida: criaria ambiguidade de caminhos. |
| **Colocar recursos finais dentro de `assests/`** | Normalizaria a grafia incorreta e contrariaria o Artigo V. |

---

## R-06: Persistência

**Decision**: **Nenhuma persistência na v1.**

**Rationale**:
- A spec declara explicitamente: "Sem persistência entre sessões na primeira versão" (Assumptions).
- O Artigo IX.1 exige lógica local; persistência não é requisito.
- Evita introduzir `ConfigFile` ou I/O de arquivo sem necessidade (Artigo V).

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **`ConfigFile` para salvar o cadastro** | Fora do escopo da v1; a spec o lista em "Melhorias futuras". |
| **Save em JSON** | Mesma razão; adiciona requisito de compatibilidade de esquema. |

**Impacto**: FR-050 (reiniciar partida) trabalha apenas em memória.

---

## R-07: Port de persistência

**Decision**: **Não implementar `match_repository` na v1.** Registrar apenas como ponto de
extensão documentado, ou remover se permanecer sem uso.

**Rationale**:
- O Artigo V é explícito: "O agente NÃO DEVE criar diretórios vazios ou classes artificiais apenas
  para preencher uma estrutura".
- Sem persistência (R-06), não há implementação concreta para o port — seria uma interface sem
  implementação, exatamente a "classe artificial" que o Artigo V proíbe.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **Criar o port agora para uso futuro** | Contraria o Artigo V. YAGNI. |
| **Criar port + implementação em memória** | Adiciona uma indireção sem benefício real, já que o estado vive em `match_state`. |

**Tarefa de validação**: revisar na implementação se algum caso de uso realmente precisa do port.
Se não, não criar o arquivo.

---

## R-08: Controles

**Decision**: **Seleção direta de zona** — o jogador toca ou clica na região correspondente da
meta; teclado oferece atalhos equivalentes.

**Rationale**:
- Atende ao Artigo VIII.3 (mouse e teclado na Web, toque no Android) com o **mesmo** modelo mental.
- Atende ao Artigo VIII.4 (comportamento equivalente entre plataformas).
- Atende a FR-034 (controles simples para crianças) — apontar para onde quer chutar é mais
  intuitivo que combinar teclas.
- FR-032 exige escolha de zona; a seleção direta é a tradução mais literal.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **Setas do teclado** | Exige duas decisões (coluna + altura) e não mapeia bem para toque. |
| **Arrasto direcional** (swipe) | Natural no toque, mas impreciso para 9 zonas distintas. |
| **Barra de força + direção** | Adiciona dimensão não prevista na spec e contraria FR-032. |

**Tarefa de validação**: confirmar que a grade de 9 zonas é atingível por toque em telas pequenas
(alvos de toque com tamanho mínimo adequado).

---

## R-09: Inteligência artificial

**Decision**: IA com **escolha ponderada pelo contexto da partida** e **variação controlada**,
implementada no adapter `ai_opponent`.

**Rationale**:
- FR-040 exige reação ao estado (placar, cobranças restantes, morte súbita).
- FR-041 exige variação entre partidas — obtida via `rng_port` (R-04).
- FR-042 proíbe acesso à escolha do jogador: a IA recebe o contexto da partida, **nunca** a zona
  secreta do adversário. Isso é uma restrição de **interface**, verificável por teste.
- FR-043 exige dificuldade adequada a crianças: a distribuição de probabilidade deve favorecer
  zonas centrais e não punir excessivamente o jogador.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **IA determinística** (sempre a mesma escolha) | Viola FR-041 e torna as partidas previsíveis. |
| **IA aleatória pura** | Viola FR-040 (não reage ao estado) e FR-043 (dificuldade errática). |
| **IA que lê a escolha do jogador** | Viola FR-042 explicitamente. |

**Tarefa de validação**: teste que verifica que a IA não recebe a zona do jogador — por exemplo,
chamando a IA antes da escolha do jogador e conferindo que o resultado é o mesmo.

---

## R-10: Estratégia de exportação

**Decision**: Criar `export_presets.cfg` com presets **Web** e **Android**; manter artefatos
gerados fora do Git; nunca versionar senhas de keystore.

**Rationale**:
- FR do Artigo II.5 e II.6 exigem ambas as exportações a partir da mesma base.
- O Artigo XII proíbe segredos em arquivos versionados. O Godot grava a **senha do keystore em
  texto claro** dentro de `export_presets.cfg` — risco real.
- Artefatos (`*.apk`, `*.wasm`, `*.pck`) são binários grandes e reproduzíveis; não pertencem ao
  controle de versão.

**Alternativas consideradas**:

| Alternativa | Por que não |
|---|---|
| **Versionar `export_presets.cfg` completo** | Pode vazar a senha do keystore (Artigo XII). |
| **Não versionar preset algum** | Perde a reprodutibilidade da exportação (CA-11). |
| **Versionar apenas exemplo sem segredos** | ✅ Escolhido: preset versionado sem campos sensíveis + senha por variável de ambiente. |

**Tarefa de validação**: exportar em ambiente com Godot + toolchain e confirmar que o APK instala
e a versão Web carrega por HTTP. **Impossível validar aqui.**

---

## Resumo das decisões

| # | Decisão | Validada? |
|---|---|---|
| R-01 | GUT como ferramenta de teste | ⚠️ Parcial — Godot headless funciona; addon não instalado |
| R-02 | `enum` de 9 valores para zona | ⚠️ Parcial — GDScript suporta; não executado |
| R-03 | Sinais do Godot entre camadas | ⚠️ Parcial — mecanismo nativo; não executado |
| R-04 | Port `rng_port` com semente injetável | ⚠️ Parcial — API do Godot conhecida; não executado |
| R-05 | Renomear `assests/` → `assets/` | ✅ **Executado** — 5 arquivos preservados |
| R-06 | Sem persistência na v1 | ✅ Decisão de escopo |
| R-07 | Não implementar `match_repository` na v1 | ✅ Decisão de escopo |
| R-08 | Seleção direta de zona | ❌ Não — requer teste de usabilidade |
| R-09 | IA ponderada por contexto | ❌ Não — requer calibração |
| R-10 | Presets sem segredos; artefatos fora do Git | ⚠️ Parcial — `.gitignore` atualizado; templates ausentes |

## Decisões do usuário (2026-10-17)

| # | Pendência | Decisão |
|---|---|---|
| 1 | **FR-062 vs. cantos altos** | **Manter a regra como está** — a mais simples e usual. Cantos altos são escolhas de alto risco por design, não zonas inúteis. FR-062 reescrito para explicitar isso. |
| 2 | **Aparência canônica** | **Uniforme verde com a letra "M"** (4 das 5 referências). Incorporado em FR-052. |
| 3 | **Idade × dificuldade** | **Crianças até 10 anos** têm **duas dificuldades** selecionáveis; acima de 10 anos, dificuldade padrão. Incorporado em FR-043. |
| 4 | **Grafia `assests/`** | **Corrigir** → `assets/`. Executado e verificado. |
| 5 | **Provisionar ambiente** | Godot **já está instalado** (4.7.2, Windows). Exportação Android permanece bloqueada por templates/SDK ausentes. |

## Pendências que exigem decisão do usuário

**Nenhuma pendência de escopo em aberto.** Todas as cinco decisões foram tomadas.

**Pendências de ambiente** (não de decisão):

1. **Templates de exportação** — ausentes. Necessários para CA-06 (APK) e CA-09 (Web export).
   Instalar via *Editor → Manage Export Templates → Download and Install*.
2. **Android SDK + `adb`** — ausentes. Necessários para CA-07 e CA-08.
3. **JDK 17** — o ambiente tem JDK **25**; o Godot Android exige **17**.
4. **Addon GUT** — não instalado. Necessário para CA-02, CA-03 e CA-05.
