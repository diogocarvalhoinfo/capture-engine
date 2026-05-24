# Changelog · Capture Engine

> Registo de todas as versões. Cada entrada explica **o que mudou**, **porquê mudou**, e **o impacto real** para o utilizador.
> Formato: `### Adicionado` — nova funcionalidade. `### Modificado` — comportamento existente alterado. `### Corrigido` — bug eliminado.

---

## [V15] — 2026-05-24

### Corrigido

**Race condition na criação de sessões — comportamento: sem impacto visível, mas dado potencialmente corrompido**

Ao colar imagem e texto simultaneamente (dois `Ctrl+V` muito rápidos), a aplicação podia criar duas sessões em paralelo em vez de uma. O utilizador não notaria imediatamente — a interface parecia normal — mas a base de dados ficaria com uma sessão "fantasma" sem conteúdo. A causa: ambas as operações assíncronas verificavam `if(sessId)return` ao mesmo tempo, antes de qualquer uma ter terminado de criar a sessão. Adicionado um mutex (`_ensurePromise`) que garante que a segunda operação espera a primeira terminar.

**Quine Engine corrompido por certos textos em tokens — comportamento: export de User produzia arquivo quebrado**

Se o administrador colocasse o texto `EXPORT MODAL` ou `FIM EXPORT MODAL` em qualquer campo do Visual Builder (título, rodapé, etc.), o Quine Engine ao fazer Export de User interpretava esse texto como um marcador de código e removia a secção HTML correspondente do arquivo exportado. O resultado era um arquivo que abria sem o modal de exportação. A função `sanitizeForQuine()` já protegia outros marcadores (`ADMIN_*`) mas não estes dois. Adicionada proteção por zero-width space nos dois marcadores em falta.

**`restoreDoc` verificava apenas metade das listas na deduplicação — comportamento: nomes potencialmente inconsistentes após restauro**

Ao restaurar um documento da lixeira, a aplicação verificava colisões de nomes apenas contra os documentos ativos. A função equivalente para imagens (`restoreImg`) e para captura inicial (`captureDoc`) já verificavam contra ambas as listas (ativos + lixeira). Esta assimetria podia resultar em nomes de arquivos internamente não-únicos em sessões com muitos documentos movidos entre ativo e lixeira. Alinhado o comportamento de `restoreDoc` com o resto do motor.

**`purgeExpired` engolia erros de base de dados em silêncio — comportamento: sessões expiradas não apagadas, sem aviso**

O bloco `try{}catch(e){}` que apaga documentos removidos durante o purge de sessões expiradas capturava erros do IndexedDB mas não os registava em lado nenhum. Se a base de dados estivesse num estado inconsistente, o purge falhava e a pasta de `removed_documents` crescia indefinidamente sem que ninguém soubesse. Adicionado `SysLogger.warn` com a mensagem de erro para diagnóstico.

**Launcher VBS falhava em pastas com nomes acentuados — comportamento: aplicação não abria, sem mensagem de erro clara**

Se o arquivo estivesse numa pasta chamada `Área de Trabalho`, `Documentação`, ou qualquer pasta com caracteres portugueses acentuados, a URI `file:///` gerada pelo launcher ficava malformada. O Edge tentava abrir o URL inválido e ou mostrava página em branco ou página de erro genérica. A função `SecureURLEncode` passou a codificar em `%HH` qualquer caractere com código ASCII > 127.

---

## [V14] — 2026-05-24

### Adicionado

**Estado inicial em branco (Pristine State) — impacto: experiência mais limpa e previsível ao abrir**

Até à V13, ao abrir a aplicação sem histórico existente, uma sessão era criada automaticamente e aparecia imediatamente no histórico (mesmo vazia). O utilizador via uma entrada `#0001` no histórico mesmo antes de fazer qualquer coisa. Agora a interface abre completamente em branco. A sessão só aparece no histórico no momento em que o utilizador interage pela primeira vez (cola uma imagem, escreve o nome do utilizador, etc.). Histórico limpo = mente limpa.

**Bordas permanentes nos botões de captura — impacto: sem layout shift, interface mais estável**

Os botões "Adicionar Imagem" e "Adicionar Documento" passaram a ter uma borda cinzenta sempre visível (mesmo em repouso), que transita para azul no hover. Antes, a borda só aparecia no hover, causando um "salto" de 1px no layout quando o cursor passava por cima. A borda permanente elimina esse salto — o elemento nunca muda de tamanho.

**Bordas permanentes nos botões de export ZIP — impacto: consistência visual no modo ZIP**

Os botões "Imagens em PDF" e "Imagens Separadas" (quando o modo ZIP está ativo) passaram a usar a classe `btn-zip-cta` com borda azul permanente. Antes, a borda desaparecia ao mover o cursor — o que criava inconsistência visual com os outros botões.

**Deteção automática do tema do sistema — impacto: respeita a preferência do OS na primeira abertura**

Se o utilizador abre a aplicação pela primeira vez sem ter definido preferência de tema, a app passa a seguir o tema do sistema operativo (dark/light). Depois de o utilizador comutar manualmente, essa escolha fica guardada e sobrepõe-se à preferência do OS.

### Modificado

**Ícone do botão "Nova Sessão" substituído — impacto: mais harmonia visual com os outros ícones da barra de topo**

O ícone de "quadrado com +" foi substituído pelo ícone de "duplos quadrados sobrepostos" (o mesmo SVG do botão "Imagens Separadas"). A razão foi puramente visual: o conjunto de ícones da barra de topo ficou mais coeso.

**FAB mobile em estado neutro — impacto: menos distração em mobile**

O botão flutuante de colar em mobile passou de sempre azul/accent para cinzento discreto em repouso. O azul só aparece no momento exato do toque (`:active`). Em mobile, um botão sempre azul chama atenção desnecessariamente — a cor deve sinalizar ação, não presença constante.

**Chips de seleção de modo (Auto/Vertical/Horizontal) — impacto: clareza visual sobre qual modo está ativo**

O chip selecionado passou a ter borda cinzenta permanente (que vai para azul no hover). Os chips não selecionados ficam sem borda em todos os estados. O contraste é claro: borda = ativo, sem borda = inativo.

**Auto-colapso da sidebar de histórico quando vazia — impacto: mais espaço disponível automaticamente**

Quando o histórico está completamente vazio e o utilizador clica fora da sidebar, ela fecha sozinha. Antes ficava aberta mesmo sem conteúdo.

**Espaçamento da left sidebar otimizado — impacto: menos espaço morto em monitores grandes**

Os gaps e paddings internos da coluna esquerda foram reduzidos de valores maiores para valores `clamp` mais compactos. Em monitores de alta resolução, a versão anterior desperdiçava demasiado espaço vertical entre os campos.

### Corrigido

**Touch targets em mobile falhavam — comportamento: apenas 25% esquerdo dos cards respondia a toque**

Em telas com `max-width: 900px`, clicar/tocar num thumbnail de imagem só funcionava se o toque fosse no quarto esquerdo do card. O resto da área não respondia. A causa era um overlay CSS (`pointer-events: auto`) que intercetava os eventos antes de chegarem ao elemento correto. Corrigido com regras defensivas: `pointer-events: auto` + `touch-action: manipulation` nos elementos corretos, `pointer-events: none` forçado no overlay.

**Sessão reutilizada ao reabrir a app — comportamento: estado "sujo" ao abrir em vez de interface limpa**

Ao reabrir a aplicação, o `init()` verificava se havia uma sessão vazia no IndexedDB e reutilizava-a. O resultado era que dados da sessão anterior (nome do utilizador, configurações) podiam persistir indevidamente. Agora `init()` chama sempre `createSession()` de forma incondicional (exceto quando há uma sessão pendente explícita via `localStorage`).

**Auto-save demorava 5 segundos após digitar — comportamento: primeiros caracteres podiam perder-se num crash**

O handler dos campos User e Equipamento marcava `isDirty=true` mas aguardava o intervalo de auto-save (5 segundos) para escrever no IndexedDB. Se a aplicação fechasse ou o browser crashasse nos primeiros 5 segundos, o texto perdia-se. Agora `triggerSave()` é chamado imediatamente a cada keystroke — a latência de escrita passa de até 5 segundos para imediata.

**Campos de texto não limpavam ao apagar sessão ativa — comportamento: texto fantasma visível após apagar**

Ao apagar a sessão atualmente ativa, os campos User, Equipamento e Nome mantinham os valores no tela. Visualmente parecia que ainda havia dados de sessão, quando na verdade não havia sessão nenhuma. Os três campos passaram a ser zerados explicitamente no reset.

**Nova sessão criada automaticamente após apagar — comportamento: apagar a última sessão criava imediatamente uma nova**

Após apagar a sessão ativa, o motor criava automaticamente uma nova sessão vazia que aparecia imediatamente no histórico. O utilizador que apagou a última sessão intencionalmente ficava com `#0001` de volta no histórico sem ter pedido isso. A criação automática foi removida — o interface fica em branco e aguarda interação real.

**Navegação automática ao apagar sessão ativa — comportamento: tela ficava vazio mesmo com sessões adjacentes**

Ao apagar a sessão ativa com histórico existente, a interface ficava em branco em vez de navegar para a sessão adjacente. Reescrita a lógica: antes de apagar, o motor captura qual é a sessão vizinha (`allBefore[idx+1] || allBefore[idx-1]`), e após apagar navega automaticamente para ela. Se não houver vizinha, aplica o estado pristine completo.

**Fechar modal de imagem clicando no fundo não funcionava — comportamento: só o botão × fechava**

Clicar na área escura fora da imagem devia fechar o modal, mas não funcionava. A causa: o `.modal-box` ocupa `96vw × 94vh` com fundo transparente, e o `#ann-viewport` (o canvas de anotação) cobria toda a área de "fundo" e intercetava os cliques. Corrigido adicionando `#ann-viewport` como alvo válido de fecho por backdrop, sem afetar o bloqueio de fecho durante zoom ou anotação ativa.

**Sidebar mostrava texto errado ao limpar rótulos no Visual Builder — comportamento: limpeza não era refletida em tempo real**

Ao apagar o rótulo de "Campo 1" ou "Campo 2" no Visual Builder, o campo correspondente na sidebar não limpava — mantinha "User" ou "Equipamento" como texto fixo. O fallback `|| 'User'` no código da sidebar sobrepunha-se ao valor vazio. Removidos os fallbacks — a sidebar agora espelha exatamente o que está no Visual Builder, incluindo o estado vazio.

### Visual Builder — Melhorias UX

**Terminologia "evergreen" no Visual Builder — impacto: funciona para qualquer contexto de uso, não só Service Desk**

Os títulos das linhas do VB mudaram de referências hardcoded a "User" e "Equipamento" para "Campo 1", "Campo 2", "Rótulo — Campo 1" e "Rótulo — Campo 2". Uma organização que usa o CE para outro fim (ex: jurídico) não quer ver "Equipamento" hardcoded na interface de configuração.

**Fecho do Visual Builder apenas pelo × — impacto: sem perdas acidentais de configuração**

O Visual Builder deixou de fechar ao clicar no backdrop (área escura fora do modal). Fechar por clique acidental a meio de uma configuração era frustrante — todas as alterações não guardadas perdiam-se. Agora só o botão × fecha.

**Label "Qualidade PDF" clarificada — impacto: sem confusão sobre o que é comprimido**

O label passou de `"Qualidade PDF (JPEG)"` para `"Qualidade do PDF"`. A descrição foi atualizada para explicar que as imagens PNG originais são convertidas para JPEG internamente *apenas durante a geração do PDF* — os arquivos originais na sessão ficam sempre em PNG. Vários utilizadores confundiam esta compressão com uma degradação permanente dos originais.

---

## [V13] — 2026-05-22

### Adicionado

**Menu dinâmico de opções ZIP — impacto: clareza sobre as duas formas de exportar ZIP**

Ao clicar no botão ZIP quando há imagens na sessão, a interface revela dois botões de escolha: "Imagens em PDF" e "Imagens Separadas". Antes, estas opções eram menos óbvias. Os novos botões usam estilo outline com uppercase, estilo consistente com os chips de seleção de modo.

### Corrigido

**ReferenceError no modal de cópia de texto — comportamento: botão Copiar falhava silenciosamente**

Um erro de referência a variável (`ReferenceError`) no bloco `catch` do modal de cópia de texto fazia com que, se a cópia falhasse, o código de recuperação também falhasse. O utilizador via o botão reagir mas nada acontecia e nenhuma mensagem de erro aparecia. Corrigido com referência correta ao elemento de botão.

**Purge baseado na data errada — comportamento: sessões ativas eram apagadas prematuramente**

O purge automático calculava a idade de uma sessão com base em `createdAt` (data de criação), não em `updatedAt` (data de última atividade). Uma sessão criada há 3 dias mas usada ontem seria apagada — o critério correto é a última atividade, não a criação. Corrigido para usar `updatedAt`.

**Colisões de nomes com itens na lixeira — comportamento: deduplicação incompleta permitia nomes duplicados internamente**

A deduplicação de nomes verificava apenas os itens ativos. Um item na lixeira com o mesmo nome de um item sendo capturado não era detetado. Em casos extremos podia causar conflitos no ZIP. Estendida a verificação para incluir sempre `removed_images` e `removed_documents`.

**Nomes com acentos vazios no ZIP — comportamento: arquivos com nomes acentuados apareciam sem nome no ZIP**

Ao criar o ZIP, nomes de arquivos com acentos (`imagem-ã.png`) eram processados sem `normalize('NFD')`, resultando em strings vazias ou corrompidas no ZIP dependendo do sistema operativo. Adicionada normalização NFD antes do empacotamento.

**Tecla Escape fechava o visualizador inteiro durante anotação — comportamento: perda de trabalho de anotação**

Pressionar Escape com o modo de anotação ativo e uma ferramenta de desenho selecionada devia apenas cancelar a ferramenta de desenho — não fechar o modal. Antes fechava tudo. Isolado o handler de Escape para agir apenas no contexto correto.

---

## [V12] — 2026-05-22

### Adicionado

**Motor de zoom com física "zoom-to-pointer" — impacto: experiência de visualização de screenshots ao nível FAANG**

O visualizador de imagens foi reescrito do zero. O zoom com scroll/roda do rato passa a centrar-se exatamente no ponto onde o cursor está — se amplia o canto superior direito, é esse canto que fica no centro. Antes o zoom centrava-se sempre no centro da imagem, forçando o utilizador a fazer pan depois de cada zoom. Limites de 20% a 1000%. Barra de controlo flutuante com glassmorphism que aparece apenas quando o zoom é diferente de 100%.

**Modal de histórico centralizado em mobile — impacto: uso com o polegar muito mais fácil em smartphones**

Em telas pequenos (`max-width: 900px`), o histórico de sessões passou de drawer lateral para modal centralizado. A largura e altura do modal foram otimizadas para uso com o polegar — targets de toque maiores, posição central mais acessível.

**Body scroll lock no modal de histórico mobile — impacto: sem rolar o fundo acidentalmente**

Ao abrir o histórico em mobile, `document.body.overflow = 'hidden'` previne que o conteúdo principal role enquanto o utilizador navega no modal. Ao fechar, o scroll é restaurado.

**Rótulos personalizáveis no Visual Builder — impacto: o CE funciona para qualquer domínio, não apenas Service Desk**

Adicionados dois novos tokens (`TOKEN_USER_LABEL`, `TOKEN_EQUIP_LABEL`) e dois campos no Visual Builder para renomear os labels "User" e "Equipamento". Uma clínica pode querer "Médico" e "Paciente"; um escritório jurídico pode querer "Advogado" e "Processo".

**Nomeação cronológica de sessões (#0001, #0002...) — impacto: histórico ordenado e sem ambiguidade**

Sessões sem nome digitado pelo utilizador passaram de `Sessão-1` para `#0001`, `#0002`, etc. O formato com zeros à esquerda garante ordenação alfabética correta em qualquer sistema — `#0009` vem antes de `#0010`, ao contrário de `Sessão-9` vs `Sessão-10`.

### Corrigido

**Colar com Ctrl+V falhava em Edge/WebKit — comportamento: clipboard ignorado silenciosamente em certos browsers**

Em algumas versões do Edge e browsers baseados em WebKit, `DataTransferItemList` não é iterável com `for...of`. O loop de leitura do clipboard falhava silenciosamente sem colar nada. Substituído por iteração com índice numérico explícito (`for(let i=0; i<items.length; i++)`), que funciona em todos os browsers.

**Eventos fantasma bloqueavam a interface em mobile — comportamento: clicar na grelha de imagens mudava de sessão**

O `#sb-content` (a lista de sessões, invisível quando a sidebar está fechada) tinha `pointer-events: auto` mesmo quando não estava visível. Em mobile, a camada invisível intercetava cliques sobre a grelha de imagens e ativava sessões no histórico sem o utilizador saber. Corrigido: `pointer-events: auto` apenas quando o modal está aberto (`.mobile-open`).

---

## [V11] — 2026-05-20

### Adicionado

**Sidebar esquerda em altura completa — impacto: sem cortes em janelas pequenas**

A sidebar esquerda passou a ocupar 100% da altura disponível. Em telas verticais curtos (janelas pequenas ou resoluções baixas), a versão anterior cortava o fundo da sidebar.

**Compressão vertical fluida — impacto: interface utilizável em qualquer tamanho de janela**

Usando `flex-shrink: 1` e `clamp` com `vh`, os elementos da sidebar esquerda comprimem-se suavemente quando a janela encolhe, antes de ativar scroll. Evita que os botões PDF/ZIP sejam cortados em janelas baixas.

### Corrigido

**Dados de sessão vazavam entre sessões — comportamento: campos mostravam texto de uma sessão anterior**

Ao navegar para uma sessão diferente, campos não preenchidos nessa sessão mostravam os valores da sessão anterior. A causa: a atribuição usava `|| 'valor_anterior'` em vez de atribuição incondicional. Corrigido com zeragem explícita antes de atribuir novos valores.

**Todas as sessões mostravam a mesma hora — comportamento: histórico inútil para ordenação temporal**

A lista de histórico exibia o horário do último auto-save (o mesmo para todas as sessões). A data mostrada passou a ser `createdAt` (data de criação da sessão), que nunca muda.

---

## [V10] — 2026-05-19

### Adicionado

**Content Security Policy — impacto: proteção adicional contra injeção de scripts**

Adicionada metatag CSP no `<head>` que restringe quais scripts e estilos podem ser carregados. Num arquivo que corre localmente com `file://`, esta é uma camada extra de defesa contra conteúdo injetado.

**Mini-modal de texto para anotações — impacto: adicionar texto nas imagens sem popups do sistema**

A ferramenta de texto no anotador usava `prompt()` — o popup nativo do browser que congela toda a interface e tem estilo diferente em cada browser. Substituído por um mini-modal interno (`#ann-text-overlay`) com estilo consistente, foco automático, e suporte a Enter/Escape.

**`TOKEN_DEBUG_MODE` — impacto: logs de debug invisíveis para utilizadores finais**

Adicionado token que controla se `SysLogger` escreve na consola do browser. Em exports de User, este token é automaticamente definido como `false` — os utilizadores finais nunca veem logs técnicos na consola.

### Corrigido

**Path traversal e colisões no ZIP — comportamento: arquivos podiam sobrescrever-se mutuamente**

Nomes de arquivos com `/`, `\`, ou `../` podiam criar estruturas de pastas não intencionais dentro do ZIP, ou sobrescrever arquivos uns com os outros. Adicionada sanitização de todos estes caracteres e verificação de unicidade cross-lista antes do empacotamento.

**Caracteres `$` corrompiam o HTML exportado pelo Quine — comportamento: arquivo exportado quebrado**

A função `.replace()` do JavaScript trata `$` no segundo argumento como referência especial a grupos de captura do regex. Um token com o valor `$1` ou `$$` corromperia silenciosamente o HTML gerado. Substituídas as strings de substituição simples por funções callback, que não têm este comportamento especial.

**Export do Quine com DOM mutado — comportamento: arquivo exportado diferente do original**

Se o Quine não conseguisse ler o arquivo original via `fetch(location.href)` (ex: quando corre em `file://` sem servidor), usava `document.documentElement.outerHTML` — o DOM atual, com todas as mutações de runtime (legendas editadas, contadores atualizados). O arquivo exportado ficava "sujo" com estado da sessão atual. Corrigido usando a constante estática `BOOT_HTML` como fallback — capturada antes de qualquer mutação.

---

## [V9] — 2026-05-19

### Adicionado

**Rodapé institucional — impacto: identificação da ferramenta em cada janela**

Adicionado rodapé com texto configurável via `TOKEN_FOOTER_TEXT`. O token `{YEAR}` é substituído automaticamente pelo ano atual. Opacidade 50% e `pointer-events: none` — presente mas discreto.

**Estados visuais de sessão na sidebar — impacto: sempre claro qual a sessão ativa**

A sessão ativa na sidebar passou a ter fundo `var(--bg)` (ligeiramente diferente do fundo da sidebar), distinguindo-a claramente das sessões inativas. Hover suave nos itens inativos.

**Persistência da sidebar aberta entre sessões — impacto: navegação mais rápida entre sessões**

Ao clicar numa sessão diferente no histórico, a sidebar permanece aberta. Antes fechava automaticamente a cada navegação, forçando o utilizador a reabri-la para cada mudança de sessão.

### Corrigido

**FOUC (Flash of Unstyled Content) em dark mode — comportamento: flash branco ao abrir em modo escuro**

Ao abrir a aplicação em modo escuro, havia um flash branco momentâneo antes de o JavaScript aplicar a classe `.dark`. Corrigido com um script síncrono imediatamente após `<body>` que aplica `.dark` antes de qualquer pintura do DOM.

**Bordas residuais nos inputs de User e Equipamento — comportamento: borda visível em repouso que não devia estar**

Os campos User e Equipamento mostravam uma borda visível em repouso e tinham listeners `mouseover/mouseout` que alteravam o estilo. O design correto é sem borda em repouso, com `box-shadow` apenas no foco. Removidos os listeners e as bordas inline.

---

## [V8] — 2026-05-18

### Adicionado

**Cantos perfeitamente retos em imagens — impacto: imagens como evidências, não como decoração**

Thumbnails, wrappers e legendas de imagens passaram a ter `border-radius: 0`. A distinção visual é intencional: elementos de texto (botões, cards, modais) têm cantos arredondados — são interfaces amigáveis. Imagens têm cantos retos — são evidências técnicas, precisas e formais.

**Design borderless em cards de documentos — impacto: interface mais limpa, menos "tabular"**

Os cards de documentos (`.d-item`) passaram a ter `border: 1px solid transparent` em vez de borda visível. Os documentos flutuam sobre o fundo sem criar uma grelha rígida de linhas.

**Lixeira unificada (Trash Bar) — impacto: recuperação fácil de items removidos por engano**

A barra inferior de lixeira foi integrada com botões de restauro e download direto, sem precisar de abrir um modal separado para cada item.

### Corrigido

**Nomes duplicados e prefixos `001-` nos ZIPs — comportamento: ZIPs com arquivos incorretamente nomeados ou colisões**

Capturas sequenciais podiam gerar nomes duplicados em certos fluxos. O ZIP exportado incluía prefixos numéricos (`001-imagem-1.png`) desnecessários. Corrigido o algoritmo de deduplicação e removidos os prefixos — os nomes dos arquivos no ZIP são agora as legendas limpas das imagens.

---

## [V7] — 2026-05-15

### Base da Arquitetura Atual

Esta versão estabeleceu as fundações sobre as quais todo o motor assenta:

- **IndexedDB com 5 object stores:** `sessions`, `images`, `documents`, `removed_images`, `removed_documents` — persistência local robusta, assíncrona, sem localStorage para dados grandes
- **Visualizador de texto modal:** Abre documentos de texto inline com área de texto monoespaçada; arquivos binários (PDF, DOCX) mostram mensagem amigável para download
- **Anotador vetorial:** Desenho sobre screenshots com círculos, retângulos, setas, texto livre — achatamento lossless direto em PNG (as anotações ficam permanentes na imagem)

---

*Capture Engine · FAANG Standards · Zero-Dependency Quine System*
