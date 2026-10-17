# Quickstart: Validação de Aventuras na Grama!

**Feature**: `001-penalty-match-mvp` | **Date**: 2026-10-17

Guia para **validar** que a funcionalidade funciona de ponta a ponta. Não contém código de
implementação — apenas como preparar o ambiente, executar e o que esperar.

> ⚠️ **Estado do ambiente (verificado em 2026-10-17)**:
> - ✅ **Godot 4.7.2 instalado** — `/mnt/c/Users/franc/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`
> - ✅ **Execução headless a partir do WSL comprovada**
> - ❌ **Templates de exportação ausentes** — bloqueiam as exportações Web e Android
> - ❌ **Android SDK, `adb` e JDK 17 ausentes** — bloqueiam a exportação Android
> - ❌ **Addon GUT não instalado** — bloqueia os testes automatizados
>
> Os passos de teste e de exportação **ainda não foram executados**. Nenhuma validação foi
> confirmada.

## 0. Como invocar o Godot

O Godot roda no **Windows**; o projeto está no **WSL**. A comunicação se dá por caminho UNC.

```bash
# Executável (use a variante _console.exe para ter stdout no terminal)
GODOT="/mnt/c/Users/franc/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"

# Caminho do projeto como o Windows o vê
PROJECT='\\wsl.localhost\Ubuntu\home\franchini190929\Projects\Game\dog-friend-gol'
```

**Verificado**: `"$GODOT" --version` retorna `4.7.2.stable.official.ed1daf0bf`, e executar um
script via `--script res://...` com `--path "$PROJECT"` funciona.

**Nota**: um script passado por caminho Linux (ex.: `/tmp/probe.gd`) **não** é acessível ao Godot
do Windows. Use sempre `res://` com o script dentro do projeto.

---

## 1. Pré-requisitos

| Requisito | Versão | Situação atual | Como verificar |
|---|---|---|---|
| Godot | 4.7.2 | ✅ **Instalado** | `"$GODOT" --version` |
| Templates de exportação | Compatíveis com 4.7.2 | ❌ **Ausentes** | Listar em *Editor → Manage Export Templates* |
| JDK | **17** (Godot exige 17) | ⚠️ Ambiente tem **25** | `java -version` |
| Android SDK + build-tools + platform-tools | — | ❌ Ausentes | `echo $ANDROID_HOME` |
| `adb` | — | ❌ Ausente | `adb version` |
| Addon GUT | compatível com 4.7 | ❌ Não instalado | `ls dog-friend-gol/addons/gut` |
| Servidor HTTP | qualquer | ⚠️ `python3` não resolvido no PATH | `python3 --version` |
| Navegador moderno | com WebAssembly | ✅ presumido | — |

### Instalar os templates de exportação (necessário para CA-06 e CA-09)

Abra o Godot no projeto e use *Editor → Manage Export Templates → Download and Install*. Isso
preenche `/mnt/c/Users/franc/AppData/Roaming/Godot/export_templates/` (hoje vazio).

### Provisionar o Android (necessário para CA-06, CA-07, CA-08)

1. Instalar **JDK 17** (não 25) e definir `JAVA_HOME`
2. Instalar Android SDK com `build-tools` e `platform-tools`
3. Definir `ANDROID_HOME`
4. Verificar: `adb version`

---

## 2. Validar as regras do jogo (sem renderização)

**O que prova**: as 81 combinações de zona, as regras de placar, as transições de estado e o
encerramento — sem carregar cenas (FR-063, Artigo VII.1).

```bash
GODOT="/mnt/c/Users/franc/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
PROJECT='\\wsl.localhost\Ubuntu\home\franchini190929\Projects\Game\dog-friend-gol'

"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit
```

**Saída esperada**: todos os testes passam, incluindo:

| Verificação | Resultado esperado |
|---|---|
| Matriz de 81 combinações | 9 `DEFENDED`, 16 `OUT_OF_BOUNDS`, 56 `GOAL` |
| Mesma zona → defesa | 9/9 zonas |
| Cantos altos → fora | `TOP_LEFT` e `TOP_RIGHT` contra qualquer outra zona |
| Altura do meio nunca sai | Nenhuma zona `MIDDLE_*` produz `OUT_OF_BOUNDS` |
| Determinismo | 1000 execuções idênticas → mesmo resultado |

Detalhes da matriz em [`contracts/zone-grid.md`](./contracts/zone-grid.md).

---

## 3. Validar as regras da partida

**O que prova**: alternância, encerramento antecipado, morte súbita e recusas.

```bash
"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit/test_match_state.gd
```

**Cenários obrigatórios**:

| Cenário | Entrada | Resultado esperado |
|---|---|---|
| Placar inicial | iniciar partida | 0–0, ambos com 5 cobranças |
| Alternância | 4 cobranças | turnos alternam, diferença ≤ 1 |
| Encerramento antecipado | 3–1 com 2 restantes | **continua** (limite exato) |
| Encerramento antecipado | 3–0 com 2 restantes | **encerra** (2 < 3) |
| Morte súbita | empate após 5+5 | entra em `SUDDEN_DEATH` |
| Morte súbita | um marca, outro não | encerra com o vencedor |
| Morte súbita | ambos marcam | continua |
| **Encerramento prematuro** | 1º marca na morte súbita | **NÃO** encerra antes do 2º cobrar |
| Cobrança duplicada | mesmo participante 2× | recusada, placar intacto |
| Após encerramento | tentar alterar placar | recusado, placar intacto |

Detalhes em [`contracts/match-rules.md`](./contracts/match-rules.md).

---

## 4. Validar a IA

**O que prova**: a IA cobra, defende, varia e **não trapaceia**.

```bash
"$GODOT" --headless --path "$PROJECT" -s addons/gut/gut_cmdln.gd -gdir=res://tests/integration
```

| Verificação | Resultado esperado |
|---|---|
| IA escolhe zonas | Retorna uma zona válida das 9 |
| IA reage ao estado | Escolhas mudam conforme placar/rodada |
| IA varia | Sementes diferentes → escolhas diferentes |
| **IA não trapaceia** | Chamar a IA antes e depois da escolha do jogador → **mesmo** resultado |

---

## 5. Validar o jogo no editor (manual)

**O que prova**: a integração de cenas, animações, controles e interface.

> ⚠️ Requer Godot instalado. **Não executado.**

```bash
"$GODOT" --path "$PROJECT"
```

### Roteiro de validação manual

| # | Passo | Resultado esperado |
|---|---|---|
| 1 | Abrir o jogo | Tela inicial com título e botão Jogar |
| 2 | Clicar em Jogar | Formulário de cadastro |
| 3 | Deixar um campo vazio | Avanço bloqueado, campo indicado |
| 4 | Preencher e avançar | Escolha de personagem |
| 5 | Escolher a Branquinha | Partida inicia com ela sob controle do jogador |
| 6 | Observar a introdução | Entrada no estádio com torcidas |
| 7 | Pular a introdução | Partida prossegue normalmente |
| 8 | Ver o sorteio | Define quem cobra primeiro |
| 9 | Jogar uma partida completa | 5 cobranças cada, alternando papéis |
| 10 | Observar o placar | Atualiza **imediatamente**, antes da animação |
| 11 | Clicar em zonas diferentes | Chute e defesa respondem |
| 12 | Testar canto alto contra zona diferente | Bola para fora |
| 13 | Forçar um empate | Entra em morte súbita |
| 14 | Concluir a partida | Comemoração do vencedor |
| 15 | Ver a cena final | **Abraço ocorre** independentemente do vencedor |
| 16 | Não oferecer os itens | Fluxo segue para o menu |
| 17 | Iniciar nova partida | Placar zerado, novo sorteio, sem resíduo |

**Verificação crítica do passo 10**: o placar deve estar correto no momento em que a animação
começa. Interromper ou pular a animação **não** pode alterar o placar (FR-025).

---

## 6. Validar a exportação Web

> ⚠️ Requer Godot. **Não executado.**

### Exportar

```bash
"$GODOT" --headless --path "$PROJECT" --export-release "Web" build/web/index.html
```

### Servir (obrigatório — `file://` não funciona)

```bash
python3 -m http.server 8000 --directory build/web
```

Abra `http://localhost:8000` em um navegador moderno.

### Verificações

| # | Verificação | Resultado esperado |
|---|---|---|
| 1 | A página carrega | Sem erro no console |
| 2 | O jogo inicia | Tela inicial aparece |
| 3 | Controles com mouse | Seleção de zona responde |
| 4 | Controles com teclado | Produz a **mesma** zona que o mouse |
| 5 | Recursos visuais carregam | Sprites e animações presentes |
| 6 | Áudio funciona | Após a primeira interação |
| 7 | Partida completa | Jogável do início ao fim |
| 8 | Redimensionar a janela | Interface se adapta |
| 9 | Tempo de carregamento | Aceitável |

**Se usar threads/SharedArrayBuffer**: requer cabeçalhos COOP/COEP no servidor. Evitar dependência
de threads é preferível.

---

## 7. Validar a exportação Android

> ⚠️ Requer Godot + toolchain Android + dispositivo. **Não executado.**

### Exportar APK de depuração

```bash
"$GODOT" --headless --path "$PROJECT" --export-debug "Android" build/android/game.apk
```

### Instalar e validar

```bash
adb install -r build/android/game.apk
adb shell am start -n <application_id>/.MainActivity
```

### Verificações em dispositivo

| # | Verificação | Resultado esperado |
|---|---|---|
| 1 | APK instala | Sem erro no `adb install` |
| 2 | O app inicia | Tela inicial aparece |
| 3 | Controles por toque | Seleção de zona responde ao toque |
| 4 | Alvos de toque | Zonas atingíveis em tela pequena |
| 5 | Partida completa | Jogável do início ao fim |
| 6 | Animações | Executam sem travar |
| 7 | Orientação | Conforme configurado no preset |
| 8 | Resoluções diferentes | Interface se adapta |
| 9 | Desempenho | Sem quedas perceptíveis de FPS |

**Limitação**: sem dispositivo físico disponível, **este critério não pode ser aprovado**
(Artigo VII.7). Deve ser registrado como **não verificado**.

---

## 8. Validar a paridade entre plataformas

**O que prova**: as duas versões compartilham a mesma implementação (Artigo II.4).

| Verificação | Como |
|---|---|
| Mesmas regras | Rodar a mesma sequência de zonas em Web e Android → mesmo placar |
| Mesma lógica | Confirmar que ambos usam os mesmos arquivos em `scripts/domain/` |
| Diferenças isoladas | Verificar que adaptações de plataforma estão só em `adapters/` e `presentation/` |
| Sem duplicação | Não existem dois conjuntos de regras no repositório |

---

## 9. Segurança

Verificações do Artigo XII:

```bash
# Nenhum segredo rastreado
git ls-files | grep -iE '\.env$|\.pem$|\.key$|keystore|\.jks$|credentials'

# Nenhum segredo no histórico
git log --all -p | grep -iE 'AKIA[0-9A-Z]{16}|BEGIN.*PRIVATE KEY|ghp_'

# Confirmação de que artefatos de exportação estão ignorados
git check-ignore -v build/web/index.html build/android/game.apk
```

**Verificado em 2026-10-17**: nenhum segredo encontrado em 118 arquivos rastreados nem nos 2
commits do histórico.

**Lacunas conhecidas** (ver `plan.md` → Security Findings):

| Lacuna | Ação |
|---|---|
| `assets/private/` não ignorado | ✅ **CORRIGIDO** — adicionado ao `.gitignore` |
| Keystores não ignorados | ✅ **CORRIGIDO** — `*.keystore`, `*.jks`, `*.p12`, `*.pfx`, `*.pepk` |
| `export_presets.cfg` pode conter senha | ✅ **Documentado** — versionar com senhas vazias |
| Artefatos de exportação não ignorados | ✅ **CORRIGIDO** — `*.apk`, `*.aab`, `*.pck`, `*.wasm`, `build/` |

---

## 10. Critérios de conclusão

O projeto **não** está concluído apenas porque compila ou porque os arquivos de exportação foram
gerados.

| # | Critério | Status neste ambiente |
|---|---|---|
| CA-01 | Projeto Godot abre e executa | ❌ Não verificável |
| CA-02 | 9 combinações funcionam (81 testes) | ❌ Não verificável |
| CA-03 | Regras documentadas implementadas | ❌ Não verificável |
| CA-04 | Interface e animações integradas | ❌ Não verificável |
| CA-05 | Testes automatizados passam | ❌ Não verificável |
| CA-06 | APK de depuração gerado | ❌ Não verificável |
| CA-07 | APK instala e inicia | ❌ Não verificável |
| CA-08 | Partida completa no Android | ❌ Não verificável |
| CA-09 | Versão Web exportada | ❌ Não verificável |
| CA-10 | Versão Web jogável em navegador | ❌ Não verificável |
| CA-11 | Procedimentos reproduzíveis | ⚠️ Documentados, não executados |
| CA-12 | Documentação atualizada | ✅ |

**Nenhum critério acima é declarado aprovado sem evidência** (Artigo VII.7).
