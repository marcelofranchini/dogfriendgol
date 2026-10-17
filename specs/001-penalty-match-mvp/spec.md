# Feature Specification: Aventuras na Grama! — Primeira Versão Jogável

**Feature Branch**: `001-penalty-match-mvp`

**Created**: 2026-10-17

**Status**: Draft

**Input**: User description: "Crie a especificação completa da primeira versão jogável do nosso jogo infantil de pênaltis, chamado provisoriamente **Aventuras na Grama!**"

## Clarifications

### Session 2026-10-17

- Q: Como o jogador escolhe a zona de chute e de defesa? → A: Em grade de 9 zonas — esquerda, centro e direita, cada uma com altura cima, meio e baixo.
- Q: Com a grade de 9 zonas, qual regra decide entre gol, defesa e bola para fora? → A: Mesma zona defendida resulta em defesa; zonas diferentes resultam em gol, exceto os cantos altos (cima-esquerda e cima-direita), que resultam em bola para fora. A altura do meio nunca sai para fora.
- Q: "Não haverá opção de chute para fora" significa que o resultado "bola para fora" deixa de existir? → A: Não. As 9 zonas são todas válidas e não existe uma décima opção de chutar para fora; "bola para fora" permanece como resultado possível, consequência do canto alto, e não como escolha do jogador.
- Q: Existe um goleiro separado dos protagonistas? → A: Não. O defensor é o outro protagonista (a criança ou a Branquinha), que alterna com o cobrador a cada tentativa, conforme FR-015.
- Q: Os cantos altos (`TOP_LEFT`/`TOP_RIGHT`) nunca produzem gol como cobrador. Isso viola FR-062 ("nenhuma zona inútil")? → A: Não viola. FR-062 significa que toda zona tem efeito válido e é selecionável para chute e defesa; os cantos altos são escolhas de alto risco por design (defesa ou bola para fora), não zonas inúteis. Decisão: manter a regra como está — é a mais simples e usual.
- Q: Qual é a aparência canônica dos protagonistas, dado que as referências divergem? → A: Uniforme **verde com a letra "M"** — o padrão predominante (4 das 5 referências).
- Q: A idade informada deve influenciar a dificuldade da inteligência artificial? → A: Sim. Crianças **até 10 anos** têm **duas dificuldades** selecionáveis (mais fácil e mais difícil). Acima de 10 anos, aplica-se a dificuldade padrão.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Disputar uma partida completa de pênaltis (Priority: P1)

Uma criança abre o jogo, começa uma partida e disputa uma série de pênaltis contra o
adversário controlado pelo jogo. A cada rodada, ela escolhe uma zona da meta para chutar ou para
defender, vê o resultado da tentativa e acompanha o placar. A partida termina quando há um
vencedor, incluindo a possibilidade de morte súbita.

**Why this priority**: é o núcleo do jogo. Sem a disputa funcionando com regras corretas, nenhuma
outra parte do produto entrega valor. Todo o restante (arte, som, celebração) é apresentação em
volta deste núcleo.

**Independent Test**: pode ser testado inteiramente pelas regras da partida, sem depender de
animações, cenas ou arte final. Verifica-se iniciando uma partida, executando cobranças em
zonas escolhidas e conferindo placar, alternância de turnos, encerramento antecipado e morte
súbita.

**Acceptance Scenarios**:

1. **Given** uma partida recém-iniciada, **When** a primeira cobrança é executada, **Then** o
   placar reflete o resultado da tentativa e o turno passa para o outro participante.
2. **Given** uma partida em andamento com placar 3 a 1 e duas cobranças restantes para o
   participante em desvantagem, **When** a cobrança é executada, **Then** a partida encerra
   antecipadamente por impossibilidade matemática de alcance.
3. **Given** uma partida empatada após as cinco cobranças iniciais de cada participante,
   **When** o empate persiste, **Then** a partida entra em morte súbita e continua em rodadas
   alternadas até que apenas um participante marque na rodada.
4. **Given** uma partida em morte súbita, **When** o primeiro participante da rodada marca e o
   segundo ainda não cobrou, **Then** nenhum vencedor é declarado antes da cobrança do segundo.
5. **Given** uma partida encerrada, **When** uma nova cobrança é solicitada, **Then** a
   solicitação é recusada e o placar permanece inalterado.

---

### User Story 2 - Identificar os protagonistas e escolher quem controlar (Priority: P2)

Antes da partida, a criança informa o nome e a idade dela e o nome e a idade do cachorro, e
escolhe se quer controlar a criança ou a Branquinha durante toda a partida.

**Why this priority**: é o que torna a partida pessoal e dá sentido à escolha de personagem. Sem
isso o jogo funciona, mas perde o vínculo afetivo que é a proposta do produto.

**Independent Test**: pode ser testado preenchendo o cadastro, escolhendo cada um dos dois
protagonistas e confirmando que os nomes informados aparecem na interface da partida.

**Acceptance Scenarios**:

1. **Given** o formulário de cadastro, **When** um campo obrigatório é deixado vazio, **Then** o
   avanço é bloqueado e o campo pendente é indicado.
2. **Given** o cadastro preenchido, **When** a criança escolhe controlar a Branquinha, **Then** a
   partida é iniciada com a Branquinha sob controle do jogador e a criança sob controle da IA.
3. **Given** o cadastro preenchido com os nomes informados, **When** a partida é exibida,
   **Then** os nomes escolhidos aparecem na interface no lugar de rótulos genéricos.

---

### User Story 3 - Enfrentar um adversário que joga de forma variada e justa (Priority: P3)

O participante controlado pelo jogo cobra e defende pênaltis, escolhe zonas e reage ao estado
da partida, variando o comportamento entre partidas para que os confrontos não sejam idênticos.

**Why this priority**: sem um adversário competente e variado, a partida se torna previsível e
perde o interesse. Também é requisito de justiça: o adversário não pode conhecer antecipadamente
a escolha secreta do jogador.

**Independent Test**: pode ser testado executando partidas repetidas e verificando que o
adversário cobra, defende, escolhe zonas distintas e não acessa a escolha do jogador antes de
a própria decisão estar tomada.

**Acceptance Scenarios**:

1. **Given** o jogador no papel de cobrador, **When** a cobrança é iniciada, **Then** o
   adversário escolhe a zona de defesa sem ter acesso à escolha do jogador.
2. **Given** partidas sucessivas nas mesmas condições, **When** as decisões do adversário são
   comparadas, **Then** há variação de comportamento entre elas.
3. **Given** o jogador no papel de goleiro, **When** o adversário cobra, **Then** o adversário
   escolhe uma zona de chute e a tentativa é resolvida pelas mesmas regras aplicadas ao
   jogador.

---

### User Story 4 - Vivenciar a entrada no estádio e o encerramento afetivo (Priority: P4)

O jogo apresenta uma introdução com os protagonistas entrando no estádio e torcidas
correspondentes. Ao final, mostra a comemoração do vencedor, o abraço entre a criança e a
Branquinha independentemente do resultado, e permite oferecer um brinquedo e um bifinho ao
cachorro.

**Why this priority**: é a camada emocional que diferencia o produto. Depende da partida já
funcionar, mas sem ela o jogo deixa de cumprir sua proposta de experiência infantil.

**Independent Test**: pode ser testado percorrendo a introdução, concluindo uma partida com cada
protagonista vencedor e verificando que o abraço ocorre nos dois casos e que a oferta de itens é
opcional.

**Acceptance Scenarios**:

1. **Given** a introdução em exibição, **When** a criança solicita pular, **Then** a introdução é
   encerrada e a partida prossegue.
2. **Given** uma partida encerrada com a criança vencedora, **When** a sequência final é
   exibida, **Then** a comemoração ocorre seguida do abraço entre os dois protagonistas.
3. **Given** uma partida encerrada com a Branquinha vencedora, **When** a sequência final é
   exibida, **Then** o abraço entre os dois protagonistas ocorre da mesma forma.
4. **Given** a cena final, **When** a criança não oferece nenhum item, **Then** o abraço já
   ocorreu e o fluxo segue para o retorno ao menu.

---

### User Story 5 - Iniciar uma nova partida (Priority: P5)

Depois da sequência final, a criança retorna à tela inicial e pode começar outra partida, com o
placar, os turnos, o sorteio e o estado do jogo reiniciados.

**Why this priority**: garante a repetibilidade, essencial para um jogo infantil. É o último
passo porque depende de todo o restante estar funcional.

**Independent Test**: pode ser testado concluindo uma partida, retornando ao menu e iniciando
outra, conferindo que nenhum resíduo da partida anterior permanece.

**Acceptance Scenarios**:

1. **Given** uma partida concluída, **When** a criança retorna ao menu e inicia outra partida,
   **Then** o placar volta a zero, os turnos são reiniciados e um novo sorteio é realizado.
2. **Given** uma nova partida iniciada após uma anterior, **When** o estado é inspecionado,
   **Then** nenhum dado da partida anterior permanece ativo.

---

### Edge Cases

- **Cobrança duplicada**: o mesmo participante tenta cobrar duas vezes na mesma rodada — a segunda
  solicitação é recusada e o placar não muda.
- **Alteração após o encerramento**: uma tentativa de modificar o placar depois do fim da partida
  é recusada.
- **Turno inválido**: uma solicitação de cobrança fora da vez do participante é recusada.
- **Vitória antecipada no limite exato**: o encerramento antecipado só ocorre quando o alcance é
  matematicamente impossível, nunca antes.
- **Morte súbita prolongada**: a morte súbita pode se estender por várias rodadas sem limite
  artificial de rodadas.
- **Morte súbita com apenas um cobrador**: nenhum vencedor é declarado enquanto o segundo
  participante da rodada não tiver cobrado.
- **Cadastro com campos vazios ou inválidos**: o avanço é bloqueado com indicação do campo.
- **Nomes muito longos ou com caracteres especiais**: a interface acomoda o texto sem quebrar o
  layout.
- **Idade fora de uma faixa plausível**: a idade informada não impede o uso do jogo.
- **Introdução pulada antes de terminar**: o estado da partida permanece íntegro e jogável.
- **Entrada do jogador durante uma animação**: as animações apenas apresentam o resultado já
  decidido, portanto entradas durante a exibição não alteram o placar.
- **Escolha do jogador no limite do tempo de decisão**: a ausência de escolha é tratada de forma
  definida, sem travar a partida.
- **Reinício durante uma partida em andamento**: o estado é descartado corretamente e uma nova
  partida começa limpa.

## Requirements *(mandatory)*

### Functional Requirements

#### Fluxo de telas e navegação

- **FR-001**: O jogo MUST exibir uma tela inicial com o título, os protagonistas e um botão
  funcional para iniciar a partida.
- **FR-002**: O jogo MUST oferecer, a partir da tela inicial, acesso funcional a opções e
  créditos.
- **FR-003**: O jogo MUST solicitar, antes da partida, o nome e a idade da criança e o nome e a
  idade do cachorro.
- **FR-004**: O jogo MUST permitir que o jogador escolha controlar a criança ou a Branquinha, com
  a escolha válida durante toda a partida.
- **FR-005**: O jogo MUST apresentar uma introdução animada com os protagonistas entrando no
  estádio, com torcida de crianças apoiando a criança e torcida de cachorros apoiando a
  Branquinha.
- **FR-006**: O jogo MUST permitir pular a introdução a qualquer momento.
- **FR-007**: O jogo MUST executar um sorteio de cara ou coroa antes da primeira cobrança, para
  definir quem cobra primeiro e os lados iniciais.
- **FR-008**: O jogo MUST apresentar uma tela de partida exibindo os nomes dos participantes, o
  placar, as cobranças já realizadas e quem está cobrando ou defendendo no momento.
- **FR-009**: O jogo MUST apresentar, ao final, a comemoração do vencedor.
- **FR-010**: O jogo MUST apresentar, ao final, o abraço entre a criança e a Branquinha
  independentemente de quem venceu.
- **FR-011**: O jogo MUST permitir que a criança ofereça um brinquedo e um bifinho ao cachorro
  após o abraço, sem que a oferta seja obrigatória.
- **FR-012**: O jogo MUST retornar à tela inicial após a sequência final e permitir uma nova
  partida.

#### Regras da partida

- **FR-013**: A partida MUST iniciar com o placar em zero a zero.
- **FR-014**: Cada participante MUST dispor de cinco cobranças iniciais.
- **FR-015**: As cobranças MUST alternar entre os participantes, alternando também os papéis de
  cobrador e defensor a cada tentativa.
- **FR-016**: Uma cobrança MUST resultar em gol, defesa ou bola para fora. Bola para fora MUST ser
  consequência da combinação de zonas escolhidas, e MUST NOT ser uma opção selecionável pelo
  cobrador.
- **FR-017**: A partida MUST encerrar antecipadamente quando o participante em desvantagem não
  puder mais alcançar o placar do adversário com as cobranças iniciais restantes.
- **FR-018**: A partida MUST entrar em morte súbita quando houver empate após as cinco cobranças
  iniciais de cada participante.
- **FR-019**: Na morte súbita, cada participante MUST realizar uma cobrança por rodada, vencendo
  quem marcar em uma rodada em que o outro não marcar.
- **FR-020**: Enquanto os resultados da rodada de morte súbita forem iguais, a partida MUST
  continuar em novas rodadas.
- **FR-021**: O jogo MUST NOT declarar vencedor antes de ambos os participantes terem realizado a
  cobrança da rodada em curso.
- **FR-022**: O jogo MUST recusar cobranças duplicadas do mesmo participante na mesma rodada.
- **FR-023**: O jogo MUST recusar solicitações de cobrança fora da vez do participante.
- **FR-024**: O jogo MUST recusar qualquer alteração do placar após o encerramento da partida.
- **FR-025**: O resultado de cada cobrança MUST ser determinado pela lógica central da partida,
  independentemente da duração das animações, da taxa de quadros ou do estado visual da cena.
- **FR-026**: A partida MUST possuir um estado explícito com transições válidas e definidas.
- **FR-060**: A resolução de uma cobrança MUST seguir a regra da grade de 9 zonas, aplicada de
  forma determinística a partir da zona escolhida pelo cobrador e da zona escolhida pelo defensor:

  1. Se as duas zonas forem iguais, o resultado MUST ser defesa.
  2. Se as zonas forem diferentes e a zona do cobrador for um dos cantos altos (cima-esquerda ou
     cima-direita), o resultado MUST ser bola para fora.
  3. Nos demais casos de zonas diferentes, o resultado MUST ser gol.

- **FR-061**: A regra de resolução MUST NOT depender de aleatoriedade: a mesma combinação de zonas
  MUST produzir sempre o mesmo resultado.
- **FR-062**: As 9 zonas MUST ser selecionáveis tanto para chute quanto para defesa. Nenhuma zona
  MUST ser inútil, ou seja, toda zona MUST produzir ao menos um resultado distinto e válido
  (defesa, gol ou bola para fora). Os cantos altos (`TOP_LEFT` e `TOP_RIGHT`) são escolhas de
  **alto risco por design**: como cobrador produzem defesa ou bola para fora, nunca gol; como
  defensor são válidos contra qualquer zona. A altura do meio MUST NOT resultar em bola para fora
  por si só.
- **FR-063**: A regra de resolução MUST ser verificável isoladamente, sem renderização ou
  carregamento de cenas.

#### Controle e mecânicas

- **FR-027**: O jogador MUST controlar um único protagonista durante toda a partida, com o outro
  sob controle da inteligência artificial local.
- **FR-028**: O jogador MUST conseguir cobrar pênaltis.
- **FR-029**: O jogador MUST conseguir defender pênaltis.
- **FR-030**: A criança MUST cobrar com os pés e defender com as mãos e o corpo.
- **FR-031**: A Branquinha MUST cobrar usando o focinho e defender com saltos em diferentes
  direções.
- **FR-032**: Os controles MUST basear-se em escolha de zona, tanto para chutar quanto para
  defender, usando uma grade de 9 zonas: esquerda, centro e direita, cada uma com altura cima,
  meio e baixo.
- **FR-033**: Os controles MUST funcionar por mouse e teclado e por toque, conforme a plataforma.
- **FR-034**: Os controles MUST ser simples o suficiente para uso por crianças.
- **FR-035**: A resolução de cada tentativa MUST considerar a escolha do cobrador e a escolha do
  defensor, seguindo regras consistentes e previsíveis.
- **FR-036**: O resultado de uma cobrança MUST ser decidido pela comparação entre a zona escolhida
  pelo cobrador e a zona escolhida pelo defensor, conforme FR-060.

#### Inteligência artificial

- **FR-037**: A inteligência artificial MUST cobrar pênaltis.
- **FR-038**: A inteligência artificial MUST defender pênaltis.
- **FR-039**: A inteligência artificial MUST escolher zonas de chute e de defesa.
- **FR-040**: A inteligência artificial MUST reagir ao estado da partida, considerando o placar,
  as cobranças restantes e a situação de vitória antecipada ou morte súbita.
- **FR-041**: A inteligência artificial MUST apresentar variação de comportamento entre partidas,
  evitando sequências idênticas.
- **FR-042**: A inteligência artificial MUST NOT acessar a escolha secreta do jogador antes de
  tomar a própria decisão.
- **FR-043**: A dificuldade da inteligência artificial MUST ser adequada para crianças e MUST ser
  selecionável em **duas opções** quando a criança tiver **até 10 anos** de idade (mais fácil e
  mais difícil). Acima de 10 anos, a dificuldade padrão MUST ser aplicada. A idade informada no
  cadastro MUST determinar a faixa aplicável.
- **FR-044**: As decisões da inteligência artificial MUST ser resolvidas pela lógica central da
  partida, sem serviços externos ou APIs pagas.

#### Interface e experiência

- **FR-045**: O cadastro MUST validar os campos obrigatórios antes de permitir o avanço.
- **FR-046**: A interface da partida MUST indicar claramente quem está cobrando e quem está
  defendendo.
- **FR-047**: A interface da partida MUST exibir o resultado de cada cobrança já realizada.
- **FR-048**: A interface MUST adaptar-se a diferentes resoluções e proporções de tela.
- **FR-049**: A interface MUST comunicar as intenções do jogador sem ser a fonte de verdade das
  regras ou do placar.
- **FR-050**: A nova partida MUST reiniciar placar, turnos, sorteio e estado do jogo.
- **FR-051**: As funcionalidades principais MUST permanecer acessíveis sem conexão com a
  Internet.

#### Apresentação e recursos visuais

- **FR-052**: A aparência da criança e da Branquinha MUST permanecer consistente em todas as
  cenas. A criança MUST usar o **uniforme verde com a letra "M"** (aparência canônica definida);
  a Branquinha MUST usar o colete azul.
- **FR-053**: A apresentação MUST cobrir entrada no estádio, preparação e chute da criança, chute
  da Branquinha com o focinho, defesa da criança, saltos defensivos da Branquinha, reações a gol,
  defesa e bola para fora, comemorações, abraço e oferta de brinquedo e bifinho.
- **FR-054**: A apresentação MUST exibir reação visual distinta para gol, defesa e chute para
  fora.
- **FR-055**: As animações MUST fornecer feedback visual sem comprometer a clareza ou a correção
  das regras.

#### Tratamento de erros

- **FR-056**: O jogo MUST impedir o avanço do cadastro enquanto houver campo obrigatório inválido.
- **FR-057**: O jogo MUST recusar qualquer operação de cobrança inválida sem alterar o estado da
  partida.
- **FR-058**: O jogo MUST manter o estado da partida íntegro quando a introdução for pulada.
- **FR-059**: O jogo MUST tratar a ausência de escolha do jogador de forma definida, sem travar a
  partida.

### Key Entities

- **Partida**: representa um confronto completo entre dois participantes. Atributos conceituais:
  estado atual, placar de cada participante, fase (cobranças iniciais ou morte súbita), rodada
  atual, cobranças restantes por participante, participante da vez, papel do jogador e resultado
  final.
- **Participante**: representa um dos dois lados da partida. Atributos conceituais: nome, idade,
  personagem associado (criança ou Branquinha), papel atual (cobrador ou defensor) e total de
  gols.
- **Cobrança**: representa uma tentativa individual. Atributos conceituais: participante
  cobrador, participante defensor, zona escolhida pelo cobrador (uma das 9 zonas da grade), zona
  escolhida pelo defensor (uma das 9 zonas da grade), resultado (gol, defesa ou bola para fora) e
  rodada a que pertence.
- **Zona de chute e defesa**: representa uma das 9 áreas da meta disponíveis para escolha, formada
  pela combinação de coluna (esquerda, centro, direita) e altura (cima, meio, baixo). É a unidade
  de decisão tanto do cobrador quanto do defensor, e a base da regra de resolução.
- **Perfil do jogador**: representa a personalização informada antes da partida. Atributos
  conceituais: nome e idade da criança, nome e idade do cachorro e personagem escolhido pelo
  jogador.
- **Sorteio inicial**: representa a definição de quem cobra primeiro e os lados iniciais.
  Atributos conceituais: resultado do sorteio e atribuição de lados.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Uma criança consegue iniciar uma partida a partir da tela inicial em até 3 ações
  (iniciar, preencher cadastro, escolher personagem).
- **SC-002**: 100% das cobranças válidas produzem exatamente um resultado entre gol, defesa e bola
  para fora.
- **SC-003**: 100% das partidas terminam com um vencedor, incluindo as que exigirem morte súbita.
- **SC-004**: O encerramento antecipado ocorre exatamente nas situações em que o alcance é
  matematicamente impossível, sem encerramento prematuro e sem prolongamento indevido.
- **SC-005**: O placar final é idêntico em 100% das execuções da mesma sequência de zonas
  escolhidas, independentemente da duração das animações ou da taxa de quadros.
- **SC-005a**: A regra de resolução da grade de 9 zonas produz o resultado esperado em 100% das 81
  combinações possíveis de zona do cobrador × zona do defensor.
- **SC-006**: Uma partida completa pode ser concluída em menos de 5 minutos por uma criança.
- **SC-007**: Uma criança consegue identificar quem está cobrando em cada momento sem instrução
  externa.
- **SC-008**: A sequência final apresenta comemoração, abraço e oferta opcional de itens em 100%
  das partidas concluídas, com o abraço ocorrendo independentemente do vencedor.
- **SC-009**: Uma nova partida iniciada após o término não apresenta nenhum dado residual da
  partida anterior.
- **SC-010**: O adversário controlado pelo jogo apresenta variação de decisões em execuções
  repetidas nas mesmas condições.
- **SC-011**: As funcionalidades principais são executáveis em navegador e em dispositivo Android
  com comportamento equivalente.
- **SC-012**: Nenhuma funcionalidade principal exige conexão com a Internet.

## Assumptions

- **Público-alvo**: crianças em idade de alfabetização inicial, com apoio de um adulto para ler
  instruções longas quando necessário.
- **Sessão de uso**: partidas curtas, adequadas a sessões de poucos minutos.
- **Idioma**: toda a documentação e toda a comunicação do jogo em português brasileiro; nomes de
  código em inglês, conforme a Constituição.
- **Plataformas**: a mesma base de código atende Web e Android, com exportação de APK instalável
  para testes.
- **Sem backend**: toda a lógica roda localmente; não há servidor obrigatório nem serviço externo
  pago.
- **Sem persistência entre sessões na primeira versão**: o cadastro é usado durante a partida e
  não é armazenado entre execuções, salvo decisão em contrário.
- **Inteligência artificial local**: a IA executa no próprio dispositivo, sem chamadas de rede.
- **Idade informada**: a idade é coletada para personalização **e determina a faixa de
  dificuldade da IA** (FR-043): até 10 anos permite escolher entre duas dificuldades; acima de
  10 anos aplica-se a padrão.
- **Controles por zona**: a mecânica principal baseia-se em escolha de zona na grade de 9 zonas,
  coerente com a
  descrição da funcionalidade.
- **Introdução pulável**: a introdução pode ser pulada sem prejuízo do estado da partida.
- **Oferta de itens opcional**: a oferta de brinquedo e bifinho não condiciona o abraço nem o
  encerramento.
- **Recursos visuais em produção**: as artes de referência existentes são estáticas e servem como
  referência de estilo e de personagem; não constituem sprites finais, modelos tridimensionais ou
  animações prontas.

## Restrições e Conformidade

Esta especificação está subordinada à Constituição do projeto em
`.specify/memory/constitution.md` (versão 1.1.0). Restrições aplicáveis:

- **Artigo I**: documentação em português brasileiro; nomenclatura de código em inglês.
- **Artigo II**: motor Godot 4.x, GDScript com tipagem explícita, recursos nativos do Godot,
  mesma base de código para Web e Android, sem introdução de outras linguagens ou extensões
  nativas sem necessidade documentada.
- **Artigo III**: o projeto Godot reside em `dog-friend-gol/`; a raiz do repositório permanece
  distinta da raiz do projeto Godot.
- **Artigos IV e V**: arquitetura hexagonal pragmática, com separação entre regras da partida,
  estado, casos de uso, IA, controles e apresentação, sem abstrações desnecessárias.
- **Artigos VI e VII**: regras verificáveis por testes automatizados sem exigir renderização ou
  carregamento de cenas sempre que tecnicamente viável.
- **Artigo XII**: fotos pessoais, referências privadas e segredos permanecem fora do controle de
  versão.

## Dúvidas a Esclarecer

**Nenhuma dúvida aberta.** As duas dúvidas anteriores foram resolvidas:

### Resolvido: Aparência canônica dos protagonistas

**Decisão**: uniforme **verde com a letra "M"** — o padrão predominante (4 das 5 referências).
Incorporado em FR-052.

Consequência para a produção de arte: a folha `sprites_kick_and_defense.png` (uniforme amarelo
"BRASIL") precisa ser reproduzida em verde, ou usada apenas como referência de poses e
enquadramento.

### Resolvido: Efeito da idade informada sobre a dificuldade

**Decisão**: crianças **até 10 anos** têm **duas dificuldades** selecionáveis (mais fácil e mais
difícil). Acima de 10 anos, aplica-se a dificuldade padrão. A idade informada no cadastro
determina a faixa. Incorporado em FR-043.

## Escopo

### Obrigatório na primeira versão

- Tela inicial com título, protagonistas e botão de início, além de acesso a opções e créditos.
- Cadastro com validação de nome e idade da criança e do cachorro.
- Escolha do protagonista controlado pelo jogador.
- Sorteio de cara ou coroa com definição de quem cobra primeiro e dos lados iniciais.
- Introdução animada com entrada no estádio e torcidas, pulável.
- Partida completa de pênaltis com cinco cobranças iniciais, alternância, encerramento
  antecipado e morte súbita.
- Controles por zona na grade de 9 zonas para chute e defesa, em mouse, teclado e toque.
- Inteligência artificial local que cobra, defende, varia o comportamento e não acessa a escolha
  secreta do jogador.
- Interface de partida com nomes, placar, cobranças realizadas e indicação de quem cobra e
  defende.
- Reações visuais distintas para gol, defesa e bola para fora.
- Sequência final com comemoração, abraço e oferta opcional de brinquedo e bifinho.
- Retorno ao menu e nova partida com estado reiniciado.
- Testes automatizados das regras da partida, independentes de animações.
- Exportação Web e geração de APK Android para testes.

### Melhorias futuras

- Dificuldade ajustável nas opções e ajuste automático por idade.
- Seleção de uniforme ou variações de aparência.
- Persistência do cadastro e de estatísticas entre sessões.
- Modos de jogo adicionais, como campeonato ou desafios.
- Trilha sonora e efeitos sonoros licenciados.
- Localização para outros idiomas.
- Conquistas e recompensas.
- Novos cenários além do estádio principal.
- Acessibilidade ampliada, como ajuste de contraste e tamanho de texto.

## Dependências

- **Projeto Godot existente**: `dog-friend-gol/`, identificado por `project.godot`.
- **Referências visuais**: arquivos em `dog-friend-gol/assets/references/`, sujeitos às
  divergências relatadas nas Dúvidas a Esclarecer.
- **Recursos visuais a produzir**: ver a seção Pendências de Recursos Visuais.
- **Ferramenta de testes**: a ser escolhida e documentada durante o planejamento, conforme o
  Artigo VII da Constituição.

## Pendências de Recursos Visuais

As referências disponíveis são imagens estáticas em formato JPEG (apesar da extensão `.png` em
quatro delas). Elas servem como referência de estilo, proporção e caracterização, mas **não**
constituem sprites finais, folhas de animação utilizáveis nem modelos tridimensionais.

Recursos a produzir:

| Recurso | Situação | Observação |
|---------|----------|------------|
| Entrada no estádio | A produzir | Referência de composição disponível |
| Preparação e chute da criança | A produzir | Folha de referência existente, porém em uniforme divergente |
| Chute da Branquinha com o focinho | A produzir | Referência parcial na folha de chute e defesa |
| Defesa da criança | A produzir | Sem referência específica |
| Saltos defensivos da Branquinha | A produzir | Folha de referência existente |
| Reações de gol, defesa e bola para fora | A produzir | Referência de comemoração disponível |
| Comemorações | A produzir | Folha de referência existente |
| Abraço entre os protagonistas | A produzir | Folha de referência existente |
| Oferta do brinquedo e do bifinho | A produzir | Sem referência |
| Torcida (crianças e cachorros) | A produzir | Referência de composição disponível |
| Bola e cenário do campo | A produzir | Referência de composição disponível |
| Interface da partida (placar e indicadores) | A produzir | Sem referência |
| Tela de cadastro | A produzir | Sem referência |
| Telas de opções e créditos | A produzir | Sem referência |
