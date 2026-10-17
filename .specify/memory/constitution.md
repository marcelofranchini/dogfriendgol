<!--
Sync Impact Report
==================
Versão: 1.0.0 → 1.1.0
Tipo de incremento: MINOR — adição de nova seção e novo artigo, sem remoção,
redefinição ou enfraquecimento de conteúdo existente.

Adicionado:
- Seção "Segurança e Proteção de Informações Sensíveis"
- Artigo XII — Segurança e proteção de informações sensíveis, com as subseções:
  - Escopo das informações protegidas
  - Verificação antes do commit
  - Operações Git restritas
  - Dependências e exportações

Alterado:
- Linha de versão e data de última alteração (1.0.0 → 1.1.0; 2026-10-17)
- Metadados do projeto: registro da política de segurança aplicável

Preservado integralmente (sem remoção nem enfraquecimento):
- Artigo I — Idioma e convenções
- Artigo II — Tecnologias obrigatórias
- Artigo III — Organização do repositório
- Artigo IV — Arquitetura hexagonal pragmática
- Artigo V — Organização do código do jogo
- Artigo VI — Regras do domínio do jogo
- Artigo VII — Testabilidade e qualidade
- Artigo VIII — Experiência do usuário e acessibilidade
- Artigo IX — Desempenho e compatibilidade
- Artigo X — Fluxo de desenvolvimento assistido por IA
- Artigo XI — Governança

Seções removidas: nenhuma

TODOs:
- TODO(GODOT_VERSION): a versão-alvo declarada é Godot 4.7.2. O arquivo
  `project.godot` declara `config/features=("4.7", "GL Compatibility")` e o
  Godot não está instalado neste ambiente. Confirmar a versão realmente
  instalada antes de validar compatibilidade de recursos.
- TODO(GITIGNORE_HARDENING): o `.gitignore` da raiz já cobre `.env`, `.env.*`,
  `*.pem` e `*.key`, mas não cobre keystores Android (`*.keystore`, `*.jks`,
  `*.p12`, `*.pfx`) nem a senha de keystore que o Godot grava em
  `export_presets.cfg`. Endurecimento adiado por estar fora do escopo desta
  emenda (ver Next Actions).
-->

# Constituição do DogFriendGoal

## Princípios Fundamentais

### Artigo I — Idioma e convenções

1. Toda a documentação do projeto DEVE ser escrita em português brasileiro (pt-BR), incluindo
   especificações, planos, tarefas, decisões arquiteturais e instruções dos agentes.
2. Classes, funções, variáveis, sinais, constantes e arquivos de código DEVEM usar nomes em
   inglês, seguindo as convenções do GDScript e do Godot.
3. O código DEVE priorizar clareza, legibilidade, coesão e simplicidade.
4. Comentários DEVEM explicar decisões, regras ou comportamentos não óbvios, evitando
   comentários redundantes.
5. Os agentes DEVEM comunicar resultados, limitações, erros e verificações realizadas em
   português brasileiro.

**Rationale**: a documentação em pt-BR mantém o projeto acessível ao seu público, enquanto a
nomenclatura de código em inglês preserva a compatibilidade com as convenções do ecossistema
Godot e GDScript.

### Artigo II — Tecnologias obrigatórias

1. O motor do jogo DEVE ser Godot 4.x.
2. A linguagem principal DEVE ser GDScript com tipagem explícita sempre que prática,
   especialmente em parâmetros, retornos de funções, modelos de domínio e contratos.
3. Cenas, nós, sinais, recursos, animações, física e interface DEVEM utilizar os mecanismos
   nativos do Godot quando apropriado.
4. O projeto DEVE compartilhar a mesma base de código para Web e Android.
5. A exportação Android DEVE permitir gerar um APK instalável.
6. A exportação Web DEVE utilizar recursos oficialmente suportados pela versão adotada do Godot.
7. Go, TypeScript, C# e extensões nativas NÃO DEVEM ser introduzidos no núcleo do jogo sem uma
   necessidade técnica concreta e documentada.
8. Dependências externas DEVEM ser justificadas e avaliadas quanto à manutenção, segurança e
   compatibilidade com Web e Android.

**Rationale**: uma única base em GDScript reduz custo de manutenção e mantém paridade de
comportamento entre Web e Android, evitando divergência de implementação entre plataformas.

### Artigo III — Organização do repositório

A raiz do repositório é `/Game`.

O projeto Godot existente está localizado em `/Game/dog-friend-gol`, identificado pelo arquivo
`project.godot`.

1. O Spec Kit, suas especificações e configurações DEVEM permanecer organizados na raiz do
   repositório conforme a instalação real das ferramentas.
2. As configurações do OpenCode, as instruções dos agentes e os componentes do Superpowers DEVEM
   respeitar os locais efetivamente utilizados pelas ferramentas instaladas.
3. Todo o código executável, as cenas, os recursos e as configurações específicas do jogo DEVEM
   ficar dentro de `/Game/dog-friend-gol`, salvo exceções técnicas documentadas.
4. O agente DEVE distinguir a raiz do repositório da raiz do projeto Godot.
5. O agente NÃO DEVE criar outro projeto Godot, duplicar `project.godot` ou mover arquivos
   existentes sem necessidade demonstrável.
6. Antes de modificar a estrutura, o agente DEVE inspecionar os diretórios, os arquivos e as
   configurações existentes.
7. O arquivo `project.godot` DEVE permanecer na raiz do projeto Godot.

**Rationale**: a separação entre raiz do repositório e raiz do projeto Godot evita que a
ferramentaria de agentes e especificações se misture com o conteúdo do jogo, preservando
referências de cenas e recursos.

### Artigo IV — Arquitetura hexagonal pragmática

O código do jogo DEVE seguir uma arquitetura hexagonal adaptada ao Godot, com separação entre
domínio, aplicação, adaptadores, inicialização e apresentação.

#### Domain

Responsável pelas regras de negócio, entidades, objetos de valor, serviços de domínio e
invariantes da partida.

O domínio NÃO DEVE depender de cenas, nós, animações, controles visuais, APIs de plataforma ou
detalhes de infraestrutura do Godot.

#### Application

Responsável por orquestrar os fluxos da aplicação.

DEVE conter:

- `use_cases/`: casos de uso que coordenam operações do jogo.
- `actions/`: comandos ou intenções explícitas, como cobrar um pênalti ou iniciar uma partida.
- `ports/`: contratos necessários para integrar dependências externas, quando aplicável.

Os casos de uso DEVEM depender do domínio e de contratos próprios, sem depender de implementações
concretas dos adaptadores.

#### Adapters

Responsáveis por integrar a aplicação com o motor, a entrada do jogador e os serviços externos.

DEVE haver separação lógica entre:

- `inbound/`: entrada do jogador, controladores e integração entre cenas e casos de uso.
- `outbound/`: persistência, áudio, serviços externos e outras implementações de portas, quando
  necessários.

#### Bootstrap

Responsável por inicializar a aplicação e conectar as dependências concretas aos contratos
correspondentes.

#### Presentation

Responsável pelas cenas, interface, câmeras, personagens visuais, animações, efeitos, áudio de
apresentação e demais componentes de interação com o jogador.

A apresentação DEVE comunicar as intenções do jogador à aplicação. Ela NÃO DEVE ser a fonte de
verdade das regras ou da pontuação.

#### Princípios de dependência

1. As dependências DEVEM apontar para o domínio e os contratos internos.
2. O domínio NÃO DEVE importar adaptadores ou componentes visuais.
3. A aplicação NÃO DEVE depender de nós ou cenas concretas.
4. Os adaptadores DEVEM traduzir os mecanismos do Godot para os contratos da aplicação.
5. O bootstrap DEVE compor as dependências necessárias.
6. Abstrações, interfaces e injeção de dependência DEVEM ser utilizadas quando oferecerem
   benefícios concretos, sem complexidade desnecessária.

**Rationale**: isolar as regras da partida de cenas e nós permite testá-las sem renderização e
impede que detalhes de apresentação alterem o resultado do jogo.

### Artigo V — Organização do código do jogo

A estrutura lógica recomendada é:

- `scripts/domain/`: entidades e regras do jogo.
- `scripts/application/actions/`: comandos e intenções.
- `scripts/application/use_cases/`: orquestração dos fluxos.
- `scripts/application/ports/`: contratos de dependências externas.
- `scripts/adapters/inbound/`: entradas e integração com a apresentação.
- `scripts/adapters/outbound/`: persistência e serviços externos.
- `scripts/bootstrap/`: inicialização e composição das dependências.
- `scenes/`: cenas do Godot.
- `assets/`: modelos, texturas, sprites, fontes, áudio e animações.
- `tests/`: testes automatizados e infraestrutura de testes, quando compatível com as ferramentas
  escolhidas.

Essa estrutura é uma referência lógica e DEVE ser ajustada às convenções reais do Godot. O agente
NÃO DEVE criar diretórios vazios ou classes artificiais apenas para preencher uma estrutura.

A pasta `internal/` NÃO É obrigatória e somente DEVE ser criada quando houver uma necessidade de
encapsulamento claramente justificada.

Os recursos e as cenas DEVEM manter caminhos e referências válidos. Renomeações e movimentações
DEVEM ser verificadas no editor e nas ferramentas de validação do Godot.

**Rationale**: uma referência lógica orienta a organização sem transformar a estrutura em um
requisito burocrático que produza diretórios e classes sem função real.

### Artigo VI — Regras do domínio do jogo

1. A partida DEVE possuir um estado explícito e transições válidas.
2. O domínio DEVE representar participantes, tentativas, gols, defesas, cobranças restantes e
   resultado da partida.
3. Pedro e Branquinha DEVEM ser participantes configuráveis, sem nomes fixos nas regras centrais.
4. Na fase inicial, cada participante DEVE ter até cinco cobranças, alternando entre cobrador e
   goleiro a cada tentativa.
5. A partida DEVE terminar antecipadamente quando o adversário não puder mais alcançar o placar
   com as cobranças iniciais restantes.
6. Se houver empate após as cinco cobranças de cada participante, a partida DEVE continuar em
   cobranças alternadas até que haja um vencedor, conforme as regras tradicionais de disputa por
   pênaltis.
7. A aplicação DEVE impedir cobranças duplicadas, mudanças de turno inválidas e alterações do
   resultado após o encerramento da partida.
8. O resultado de uma cobrança NÃO DEVE depender da duração de animações, da taxa de quadros ou
   do estado visual da cena.
9. A apresentação DEVE refletir o estado confirmado pelo domínio e pela aplicação.
10. As regras DEVEM ser verificáveis por testes automatizados sem exigir renderização ou
    carregamento de cenas sempre que tecnicamente viável.

**Rationale**: modelar o estado da partida de forma explícita garante que vitória antecipada,
empate e morte súbita sejam determinísticos e independentes da apresentação visual.

### Artigo VII — Testabilidade e qualidade

1. O domínio DEVE ser testável isoladamente.
2. Os casos de uso DEVEM possuir testes para fluxos principais, limites e erros relevantes.
3. Os testes DEVEM cobrir gols, defesas, alternância de participantes, vitória antecipada,
   empate, morte súbita e transições inválidas.
4. A estratégia de testes DEVE utilizar ferramentas compatíveis com Godot e GDScript, escolhidas
   e documentadas durante o planejamento inicial.
5. O agente DEVE executar os testes e as verificações disponíveis antes de declarar uma tarefa
   concluída.
6. Alterações DEVEM ser verificadas quanto a erros de sintaxe, recursos ausentes, referências
   quebradas e incompatibilidades relevantes.
7. Testes não executados DEVEM ser identificados como não executados. O agente NÃO DEVE afirmar
   que houve validação sem evidências.
8. Testes automatizados NÃO substituem a execução do jogo no Godot quando a alteração envolver
   cenas, animações, física, entrada ou renderização.

**Rationale**: separar testes automatizados de verificação visual deixa explícito o que foi
efetivamente comprovado e o que ainda depende de execução manual no editor.

### Artigo VIII — Experiência do usuário e acessibilidade

1. O jogo DEVE apresentar uma experiência visual amigável, apropriada para crianças e com
   instruções claras.
2. A interface DEVE exibir o placar, o participante da vez, o resultado de cada cobrança e o
   estado da partida.
3. O jogo DEVE suportar mouse e teclado na Web e controles por toque no Android.
4. As ações essenciais DEVEM oferecer comportamento equivalente nas plataformas suportadas.
5. A interface DEVE adaptar-se a diferentes resoluções e proporções de tela.
6. Animações e efeitos DEVEM fornecer feedback visual sem comprometer a clareza ou a correção das
   regras.
7. As funcionalidades principais DEVEM permanecer acessíveis sem depender de conexão com a
   Internet.

**Rationale**: o público-alvo infantil exige clareza de instruções e feedback imediato, e a
paridade entre mouse, teclado e toque evita funcionalidades inacessíveis em uma das plataformas.

### Artigo IX — Desempenho e compatibilidade

1. A lógica central da partida DEVE funcionar localmente, sem backend obrigatório.
2. O código DEVE evitar processamento desnecessário por quadro, alocações excessivas e
   dependências que prejudiquem o desempenho.
3. Recursos visuais e sonoros DEVEM ter tamanhos adequados para Web e Android.
4. Recursos específicos de uma plataforma DEVEM ser isolados e documentados.
5. As exportações DEVEM ser validadas para Web e Android antes da publicação.
6. A compatibilidade com navegadores, dispositivos Android e recursos de renderização DEVE ser
   verificada durante o planejamento e os testes de lançamento.

**Rationale**: sem backend obrigatório e com recursos enxutos, o jogo mantém tempo de
carregamento aceitável na Web e comportamento estável em dispositivos Android de entrada.

## Fluxo de Desenvolvimento Assistido por IA

### Artigo X — Fluxo de desenvolvimento assistido por IA

1. O desenvolvimento DEVE seguir o fluxo do Spec Kit: especificação, esclarecimento,
   planejamento, tarefas, análise e implementação.
2. O Superpowers DEVE ser utilizado quando disponível e compatível com o agente, respeitando as
   instruções e os recursos efetivamente instalados.
3. Antes de implementar uma funcionalidade, o agente DEVE compreender os requisitos, inspecionar
   os arquivos relevantes e identificar as dependências afetadas.
4. O agente DEVE preferir alterações pequenas, verificáveis e coerentes com a arquitetura
   existente.
5. Os planos DEVEM identificar arquivos e diretórios afetados, testes necessários e verificações
   para Web e Android.
6. A implementação DEVE preservar o trabalho existente e evitar refatorações amplas sem
   justificativa.
7. Cada funcionalidade DEVE ser validada antes de iniciar trabalho dependente dela.
8. O agente DEVE documentar limitações, decisões relevantes e exceções arquiteturais.

**Rationale**: o fluxo especificação → plano → tarefas → implementação reduz retrabalho e mantém
as decisões rastreáveis antes de qualquer alteração de código.

## Governança

### Artigo XI — Governança

1. Esta Constituição é obrigatória para novas funcionalidades, correções e refatorações.
2. Os planos DEVEM verificar a conformidade com os princípios aplicáveis.
3. Exceções DEVEM apresentar justificativa técnica explícita.
4. A Constituição DEVE ser revisada quando houver mudanças relevantes de tecnologia, arquitetura
   ou plataformas.
5. A simplicidade, a jogabilidade funcional, a confiabilidade e a capacidade de evolução DEVEM
   prevalecer sobre a complexidade arquitetural desnecessária.

#### Procedimento de emenda

1. Emendas DEVEM ser propostas com justificativa explícita e o princípio ou seção afetada.
2. A alteração DEVE ser registrada em `.specify/memory/constitution.md` com atualização da
   versão e da data de última alteração.
3. A emenda DEVE indicar o impacto sobre planos e tarefas em andamento.

#### Política de versionamento

A versão segue versionamento semântico:

- **MAJOR**: remoção ou redefinição incompatível de princípios ou regras de governança.
- **MINOR**: adição de princípio ou seção, ou expansão material de orientação existente.
- **PATCH**: esclarecimentos, correções de redação e refinamentos não semânticos.

#### Conformidade

1. Planos e tarefas DEVEM declarar a verificação dos princípios aplicáveis.
2. O agente NÃO DEVE declarar conformidade sem evidência das verificações executadas.
3. Divergências identificadas DEVEM ser registradas com a justificativa técnica correspondente.

**Metadados do projeto**

- Idioma da documentação: português brasileiro
- Linguagem principal: GDScript tipado
- Motor: Godot 4.7.2 (alvo declarado) — TODO(GODOT_VERSION): confirmar versão instalada
- Plataformas: Web e Android (APK)
- Arquitetura: hexagonal pragmática
- Segurança: política de proteção de informações sensíveis no Artigo XII

## Segurança e Proteção de Informações Sensíveis

### Artigo XII — Segurança e proteção de informações sensíveis

#### Escopo das informações protegidas

1. Tokens, senhas, chaves de API, credenciais, certificados privados, chaves de assinatura,
   dados pessoais e demais segredos NÃO DEVEM ser incluídos em arquivos versionados, logs,
   documentação, capturas de tela ou artefatos de build.
2. Arquivos de configuração locais DEVEM ser protegidos contra commits, incluindo `.env` e
   variantes, arquivos com credenciais e configurações privadas das ferramentas instaladas
   (por exemplo, configurações locais de agentes e do Spec Kit).
3. A proteção DEVE respeitar as necessidades reais do projeto: arquivos necessários para abrir,
   executar, testar ou exportar o jogo NÃO DEVEM ser excluídos do controle de versão apenas por
   precaução genérica.
4. Arquivos de exemplo, como `.env.example`, DEVEM conter apenas nomes de variáveis e valores
   fictícios, nunca credenciais reais.
5. Os agentes NÃO DEVEM expor o conteúdo de segredos em respostas, relatórios, mensagens de
   erro, comandos executados ou logs.

#### Verificação antes do commit

1. O agente DEVE inspecionar e atualizar o `.gitignore` existente, preservando suas regras
   válidas e adicionando somente as exclusões efetivamente necessárias.
2. Antes de adicionar arquivos ao Git, o agente DEVE verificar o que será efetivamente
   versionado.
3. O agente DEVE considerar que o `.gitignore` NÃO protege arquivos já rastreados: um arquivo
   adicionado anteriormente permanece versionado mesmo que uma regra de exclusão passe a
   corresponder a ele.
4. Ao identificar um arquivo sensível já rastreado, o agente DEVE interromper a inclusão,
   informar o usuário e solicitar autorização antes de qualquer remoção do índice.
5. O agente NÃO DEVE afirmar que o repositório está seguro sem apresentar as verificações
   executadas e os respectivos resultados.

#### Operações Git restritas

1. Operações destrutivas no Git NÃO DEVEM ser executadas sem autorização explícita, incluindo
   descarte de alterações, remoção forçada de arquivos, limpeza de diretório de trabalho e
   reescrita de histórico.
2. O agente NÃO DEVE descartar alterações do usuário nem reescrever histórico de commits por
   iniciativa própria.
3. Segredos encontrados no histórico do Git DEVEM ser tratados como potencialmente
   comprometidos, mesmo que já tenham sido removidos do estado atual.
4. Ao detectar um segredo no histórico, o agente DEVE recomendar revogação ou rotação da
   credencial como primeira medida, registrando que a remoção do histórico por si só não
   invalida o valor exposto.

#### Dependências e exportações

1. Dependências externas DEVEM ser avaliadas quanto à manutenção, procedência e segurança antes
   de serem adotadas, conforme o Artigo II.
2. Arquivos de configuração de dependências DEVEM evitar a inclusão de credenciais; quando uma
   credencial for inevitável, ela DEVE vir de variável de ambiente ou de arquivo local não
   versionado.
3. As futuras exportações Web e Android DEVEM ser avaliadas quanto a segredos embarcados:
   chaves, endpoints privados e credenciais NÃO DEVEM ser incluídos nos artefatos exportados.
4. Chaves de assinatura Android e arquivos de keystore DEVEM permanecer fora do controle de
   versão, e as senhas correspondentes NÃO DEVEM ser registradas em arquivos versionados.
5. Exclusões adicionadas para proteger segredos NÃO DEVEM remover arquivos necessários para
   abrir, executar, testar ou exportar o projeto Godot, conforme o Artigo III.

**Rationale**: a verificação explícita do que entra no controle de versão, combinada com a
proibição de operações destrutivas e de exposição de segredos, reduz o risco de comprometer
credenciais de forma irreversível — risco que o `.gitignore` isoladamente não cobre para
arquivos já rastreados.

**Version**: 1.1.0 | **Ratified**: 2026-10-17 | **Last Amended**: 2026-10-17
