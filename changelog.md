# Changelog · Capture Engine

> Registro de todas as versões. Cada entrada explica **o que mudou**, **porquê mudou**, e **o impacto real** para o usuário.
> Formato: `### Adicionado` — nova funcionalidade. `### Modificado` — comportamento existente alterado. `### Corrigido` — bug eliminado.

---

## [V25] - 2026-06-06

- Mobile: desenho por toque via Pointer Events + touch-action:none no canvas de anotação
- Mobile: scroll lock em todos os modais fullscreen (imagem, documento, Visual Builder, sidebar)
- Mobile: botões de apagar e restaurar sempre visíveis em dispositivos touch (@media hover:none)
- Mobile: toolbar de anotação em 3 linhas responsivas
- Código: comentários de secção HTML padronizados para maiúsculo
- Visual: logo Símbolo SVG theme-aware (sem caixa, currentColor) + PWA completo (favicon SVG, apple-touch-icon, manifest com ícones base64) + cor de destaque #e65616 (laranja)

Anotação iterativa: motor de interação enriquecido com suporte completo a seleção, edição, redimensionamento, movimento e um novo modelo de histórico (undo/redo).

### Adicionado

**Motor de Seleção e Edição (Anotação)** — agora é possível selecionar, mover, redimensionar e apagar anotações previamente desenhadas. A ferramenta "Selecionar" (ativa por padrão ao abrir anotações existentes) permite clicar numa forma para exibir uma caixa de seleção sólida e fina com quatro alças de redimensionamento e um botão de exclusão (✕). Suporta redimensionamento bidirecional contínuo (incluindo redimensionamento visual contínuo de texto). O ✕ e a tecla `Delete` apagam o item atual.

**Edição de Propriedades Pós-Desenho** — com uma anotação selecionada, os botões da barra de ferramentas alteram diretamente o objeto em vez de apenas mudar o próximo traço. Os botões −/+ ajustam a espessura ou tamanho de fonte, e a paleta altera a cor atual. Os níveis de espessura foram expandidos para seis opções: `[1, 2, 4, 6, 8, 12]`.

**Polimentos de UX (Anotação)** — o botão direito do mouse permite agarrar e mover anotações em qualquer ferramenta (sem desenhar, suprimindo o menu nativo). O ícone "T" fica azul (cor primária) quando a ferramenta de texto está ativa OU quando uma anotação de texto encontra-se selecionada (`.ann-txt-selected`). A seleção anterior limpa automaticamente ao confirmar ou trocar para texto.

### Modificado

**Desfazer e Refazer (Modelo Snapshots de Estado)** — o sistema de undo/redo foi integralmente reescrito. Substitui a antiga pilha única baseada em eventos (que causava bugs de ordem ao intercalar ações) por um modelo de snapshots completos com dupla pilha (`annUndoStack` / `annRedoStack`, teto de 50). Toda mutação altera a fonte única (`annHistory`). Ações contínuas de mover/redimensionar só persistem se houve mudança efetiva (flags `_dragDirty` / `_resizeDirty`). Ao reentrar numa imagem salva, o histórico é "semeado" iterativamente, permitindo desfazer todas as ações até revelar a imagem original sem anotações.

**Logótipo e Favicon (V25, sessão 2026-06-10)** — O SVG do logo foi substituído pela variante Símbolo: sem caixa de fundo, quatro cantos em L preenchidos (`fill`) em vez de traços (`stroke`), com `fill="currentColor"` nos 3 cantos neutros e `fill="url(#ce_accent)"` no canto inferior direito (gradiente verde→amarelo). O CSS de `#tb-brand-icon` deixou de ter `background`, `border-radius` e `overflow`. Adicionadas duas regras de theming: `color: #ffffff` em dark mode (padrão) e `color: #1a1a1a` em `body:not(.dark)`, para que o logo use `currentColor` e adapte-se automaticamente ao tema activo. O favicon no `<head>` foi actualizado para o novo SVG. Adicionados `<link rel="apple-touch-icon">`, `<link rel="manifest">` com ícones e manifest embebidos como data URI (zero ficheiros externos), `<meta name="theme-color">` e `<meta name="msapplication-TileColor">`.

**Cor de destaque `--accent`** — substituída de `#0ea5e9` (azul) para `#e65616` (laranja de marca). `--accent-hover` actualizado de `#0284c7` para `#d4450f`. Cor hardcoded em `#ann-text-input::selection` (2 ocorrências) actualizada para `rgba(230, 86, 22, 0.32)` em consistência.

### Corrigido

**Performance mobile — deleção de arquivos:** eliminado freeze ao apagar múltiplos itens. `renderTrash()`, `updateCounters()` e `updateBtns()` consolidados num único ciclo com debounce de 50ms via `scheduleUIUpdate`; `triggerSave()` chamado uma única vez no fim desse ciclo. Transações IndexedDB em `deleteSessionId` e `purgeExpired` consolidadas por store em batch via `idbDelBatch` (uma transação em vez de N individuais).

**Reordenação no Mobile** — Restaurado o scroll vertical nativo em dispositivos de toque nas listas de imagens e documentos através de `touch-action: pan-y`. Um temporizador de toque longo (`LONG_PRESS_DELAY = 500ms`) foi introduzido para distinguir a rolagem da página do gesto intencional de arrastar e reordenar. Ao expirar o tempo, o scroll nativo é dinamicamente desabilitado no item (`touch-action: none`) para permitir a reordenação precisa, sendo restaurado ao final do gesto.

---

## [V24] — 2026-06-01

Ferramenta de Texto da anotação: suporte a **texto multilinha** e **redimensionamento ao vivo** do tamanho da fonte, com o texto a ficar achatado na imagem exatamente como aparece no editor (WYSIWYG).

### Adicionado

**Texto multilinha na anotação** — o editor de texto (`#ann-text-input`, dentro de `#ann-text-overlay`) passou de `<input type="text">` para `<textarea wrap="off">`. Agora é possível escrever **várias linhas** e o editor cresce em altura e largura à medida que se escreve (nova função `annAutosizeText()`: como `wrap="off"` não quebra linhas sozinho, mede a linha mais longa com `measureText` na fonte escalada e ajusta `width`/`height`). O render no canvas (`annDrawShape`, ramo `h.type === 'text'`) deixou de usar um único `fillText` (que ignora `\n`) e desenha **linha a linha** (`String(h.txt).split('\n')`). Foi introduzida a constante única `ANN_TEXT_LINE_RATIO = 1.3`, usada **tanto** no `line-height` do `<textarea>` **como** no canvas, garantindo que o que se vê a escrever é igual ao que fica gravado. Alinhamento vertical determinístico: a 1.ª linha é desenhada em `y1 + halfLeading`, com `halfLeading = (lineH − fontSize) / 2` e `lineH = fontSize × ANN_TEXT_LINE_RATIO`. A reedição por duplo-clique passou a testar o clique contra a **caixa completa** do texto (largura da linha mais comprida × número de linhas, com o mesmo `lineH`), permitindo reabrir o texto clicando em qualquer linha.

**Cursor da ferramenta Texto** — ao selecionar a ferramenta Texto, o cursor sobre o canvas de anotação passa de cruz (`crosshair`) para cursor de texto (`text` / I-beam), dando feedback imediato do modo ativo; volta a `crosshair` nas restantes ferramentas (definido em `annSetTool`).

### Modificado

**Enter deixou de confirmar o texto — passou a inserir nova linha** — na ferramenta Texto, removido o ramo `if (e.key === 'Enter') { e.preventDefault(); commit() }` do `onkeydown`. A confirmação acontece agora ao **clicar fora** do editor (`onblur`), ao clicar noutro ponto do canvas, ou no botão **Confirmar** (`#ann-save`). `Ctrl+B` / `Ctrl+I` e `Escape` (cancelar) mantêm-se inalterados.

### Corrigido

**Botões de tamanho −/+ fechavam o editor de texto e não redimensionavam ao vivo** — com texto em edição, clicar em `#ann-thickness-down` / `#ann-thickness-up` tirava o foco ao editor (disparando o commit) e mudava o tamanho apenas uma vez, sem refletir na caixa aberta. Corrigido aplicando o mesmo padrão já usado pelas swatches e pelos botões B/I: `mousedown` com `e.preventDefault()` quando o overlay de texto está visível (impede o blur/commit) e, no `onclick` (só no ramo `annTool === 'text'` e com o editor visível), atualização **ao vivo** do `font-size` e `line-height` do editor + reposicionamento, via `annTextLiveResize()` → `annAutosizeText()`, sem fechar. Fora do modo texto, os botões continuam a controlar a espessura do traço, sem qualquer alteração.

**Texto novo aparecia abaixo do cursor** — o ponto clicado corresponde ao **centro vertical** do cursor I-beam (`cursor: text`), mas a 1.ª linha ancorava pelo topo nesse ponto, fazendo o texto aparecer abaixo de onde se mirava. Corrigido em `annShowTextInput`: para texto novo (sem `prefill`), a âncora sobe meia linha — `canvasY -= ANN_TEXT_SIZES[annTextSizeIdx] × ANN_TEXT_LINE_RATIO / 2` (coords do canvas) — ficando a 1.ª linha **centrada** no ponto clicado, tanto no editor como no canvas (o `y1` gravado já leva o ajuste, por isso o WYSIWYG mantém-se). A reedição por duplo-clique (com `prefill`) preserva a âncora gravada, sem deslocamento.

**Ctrl+Z desfazia a anotação enquanto se escrevia texto** — o listener global de `keydown` tratava `Ctrl+Z`/`Ctrl+Y` como undo/redo da anotação mesmo com o foco no editor de texto, impedindo o desfazer nativo da digitação. Adicionado um guard: se `document.activeElement` for `INPUT`/`TEXTAREA`/`isContentEditable`, o bloco de undo/redo da anotação é ignorado (sem `preventDefault`), deixando o campo desfazer/refazer as letras nativamente. Fora de um campo de texto, o comportamento é igual ao anterior.

**Documentação** — `agents.md` §7 (`annShowTextInput` agora descreve o `<textarea>` multilinha e Enter=nova linha; `annDrawShape` o render linha a linha; nova função `annAutosizeText`), §9 (nova constante `ANN_TEXT_LINE_RATIO`) e §11 (checklist de `annDrawShape` estendida ao render multilinha); `readme.md` §5.3 (secção da ferramenta Texto: multilinha, Enter=nova linha, confirmar a clicar fora/Confirmar, resize ao vivo dos −/+).

**Documentação — auditoria universal (correções).** Após uma auditoria à documentação: documentados os motores **PDF** e **ZIP** em `agents.md` §7 (até aqui sem referência de funções); acrescentados os campos `origBlob`/`annHistory` ao esquema do `images` (`agents.md` §6 e `readme.md` §13); corrigida a descrição da anotação na `readme.md` §5.3 (de "permanente" para **não-destrutiva e reeditável**, com o original preservado); reposto o cabeçalho em falta `## 7. Segurança e privacidade` na `readme.md`; corrigida a posição do script anti-FOUC no diagrama da `readme.md` §13 (de `<head>` para logo após `<body>`); `design-tokens.md` actualizado (constante `ANN_TEXT_LINE_RATIO`, entrada `text` multilinha, afirmações subjectivas); siglas **EMA** e **FLIP** expandidas; tamanho do ficheiro (~190KB → ~198KB) corrigido.

## [V23] — 2026-05-31

Versão maior: correção de dois bugs de interação reportados pelo usuário (visíveis durante o uso, não no código estático) e substituição do mecanismo de reordenação.

### Modificado

**Documentação — auditoria universal (9 correções)**

- `agents.md` §11: removido item de checklist "Botão Nova Sessão" — botão eliminado na V17, item era falso negativo garantido em qualquer execução
- `agents.md` §2.5: documentada API completa do `SysLogger` (`info`/`warn` só com debug ativo; `error` sempre ativo)
- `agents.md` §7: adicionadas assinaturas e descrições de `idbPut`, `idbGet`, `idbAll`, `idbDel`, `idbIdx` — funções de IDB usadas em todo o motor mas ausentes da referência
- `agents.md` §7: documentadas `applyTokens()`, `initVbSync()` e `buildFilename()` — funções críticas presentes no diagrama de boot mas sem entrada na tabela de referência
- `agents.md` §6: campo `exported` da tabela `sessions` passou de "para referência futura" para descrição factual (quando é definido, que lógica o usa, que é informativo/reservado)
- `design-tokens.md`: `--drop-ph-bg` e `--drop-ph-border` corrigidos — descreviam-se como "ajustáveis sem Export" mas requerem edição direta do código-fonte; inacessíveis a admins via Visual Builder
- `readme.md` §2: perfil Desenvolvedor/Agente IA expandido com referência explícita e descritiva a `agents.md`

**Setas de navegação no visualizador de imagens** — adicionados botões ← → flutuantes no modal de imagem. Aparecem automaticamente quando há ≥2 imagens na sessão; ficam ocultos no modo de anotação (restaurados ao sair) e na lixeira com apenas 1 item. Estilo glassmorphism consistente com o zoom UI. Equivalentes às teclas ArrowLeft/ArrowRight já existentes (que foram mantidas).

**Corrigido: cliques rápidos nas setas de navegação ativavam o zoom** — o `#ann-viewport` tem um listener de `dblclick` que faz zoom ao clicar duas vezes na imagem. Cliques rápidos nos botões ← → propagavam até ao viewport e eram interpretados como duplo-clique. Corrigido adicionando um guard no handler de `dblclick` que ignora eventos originados nos botões de navegação (`e.target.closest('#img-nav-prev,#img-nav-next')`).

**`TOKEN_FOOTER_TEXT` — valor padrão atualizado para incluir o autor** — o texto do rodapé pré-preenchido no Visual Builder passou de `© {YEAR} • CAPTURE ENGINE` para `© {YEAR} • CAPTURE ENGINE • DIOGO CARVALHO`. Atualizado em `capture-engine.html`, `readme.md` e `design-tokens.md`.

**Botão "Anotar" renomeado para "Editar"** — o botão do modal de imagem (id `ann-toggle`) que abre o modo de anotação passou a chamar-se "Editar". Apenas o rótulo visível mudou; a função (`annActivate()`) e o comportamento são os mesmos. Atualizada a referência em `agents.md` §7.

**Ícone do botão "Editar" melhorado** — o lápis do botão `#ann-toggle` foi substituído por um traçado mais comprido, com a borracha arredondada no topo e a ponta menos afiada (estilo contorno, sem o triângulo cheio anterior). Apenas o SVG mudou; o comportamento é o mesmo. Verificado no browser.

**Bloqueio de multi-aba removido** — abrir o Capture Engine numa segunda aba do mesmo browser já não mostra a tela de erro vermelho que substituía a interface. O manipulador `onblocked` do IndexedDB passou a apenas registar um aviso discreto na consola. Várias abas partilham a mesma base de dados local; a única ressalva é não editar a mesma sessão em duas abas ao mesmo tempo (a última gravação prevalece). Documentação atualizada em `readme.md` §7, §8 e §10 e `agents.md` §6 e §11. *(Nota: testado o arranque da app em viewport mobile durante esta sessão — sem erros de JS, sem camadas a cobrir o ecrã; os handlers respondem.)*

### Corrigido (interação — após teste manual)

**Não era possível reordenar imagens no mobile (toque)** — a reescrita da reordenação na V23 (Pointer Events) exige `touch-action: none` nos itens para o browser não interpretar o gesto como scroll. Porém, a media query mobile (`max-width:900px`) forçava `touch-action: manipulation` em `.t-item` e `.t-wrap`, anulando isso — e só nas imagens (os documentos `.d-item` não eram afetados, por isso já reordenavam no toque). Corrigido: `.t-item` e `.t-wrap` passam a `touch-action: none` também em mobile. Verificado no browser que o valor calculado é agora `none` em viewport de 375px. O toque simples para abrir continua a funcionar (`touch-action: none` não impede o clique).

**Rodapé do Visual Builder não atualizava na app** — o campo "Texto do Rodapé" (`cfg-footer-text`) não tinha listener de `input` no `initVbSync`, ao contrário dos campos de cor, título e rótulos. O valor só era aplicado na exportação, nunca no preview ao vivo. Corrigido: adicionado o listener que atualiza `#footer-credits` ao editar (espelhando a substituição de `{YEAR}` do `applyTokens`). Verificado no browser: editar o campo altera o rodapé imediatamente.

### Documentação (2.ª auditoria de 2026-05-31 — correcções críticas, verificadas no código)

Quatro divergências identificadas numa segunda auditoria externa e confirmadas por leitura directa do `capture-engine.html`. Sem alterações de comportamento da app — apenas documentação e o script de validação.

- **`sysColors` — estrutura completada (`agents.md` §9).** A tabela documentava `{main, fg}`; o código (`capture-engine.html`) declara `{main, fg, tStart, tAccent, tEnd}` — os 3 campos de cor de título (`tStart`/`tAccent`/`tEnd`) estavam ausentes. Um agente a mexer no motor de título/cores tinha uma visão incompleta do estado global. Corrigido com a estrutura real e a sua origem (tokens) e consumidores (`applyTokens`/`initVbSync`/Quine).
- **`deactivateAdmin()` recategorizada (`agents.md` §7).** Estava listada na tabela "Funções de Anotação", mas pertence ao **Admin Gate** (oculta os botões ⚙️/💾; exposta como `window._deactivateAdmin`; chamada por `closeSettingsModal`). Movida para uma nova subsecção "Funções do Admin Gate".
- **Contradição sobre o Firefox reconciliada (`readme.md` §10 ↔ §11/§9).** A FAQ afirmava "experiência idêntica ao Chrome/Edge", contradizendo §11 ("não testado formalmente") e o modelo de recuperação da §9. A FAQ passou a indicar que captura/anotação/exportação funcionam, mas que a partilha e recuperação de dados `file://` só foi verificada em Chromium — e a recomendar Chrome/Edge para requisitos de recuperação.
- **`validate.sh` — número de versão deixou de ser hardcoded.** A verificação #8 tinha `V23` literal e quebraria (ou daria falso-positivo) no próximo version bump; além disso o protocolo de bump (`agents.md` §12) não a mencionava. Reescrita para **auto-detectar** a versão a partir do boot message (`Capture Engine Vxx Ready`) e confirmar que essa versão é consistente nas 3 referências de produto (comentário VB, badge, console). Resultado: o script nunca mais precisa de edição manual no bump e passa a **apanhar** referências de versão por substituir. Nota adicionada ao `agents.md` §12.

### Documentação (auditoria de 2026-05-31 — correcções de alta prioridade)

Três inconsistências de nível alto identificadas em auditoria externa e corrigidas no `design-tokens.md`. Sem alterações de comportamento — apenas a documentação passou a descrever o que o código faz.

- **`TOKEN_TITLE_END` — versão de introdução corrigida.** A nota dizia "ativo desde V22"; o token foi adicionado nesta versão (V23), conforme o próprio changelog regista em "Nova Funcionalidade". Corrigido para "adicionado na V23".
- **`TOKEN_JPEG_QUALITY` — comportamento fora do intervalo especificado.** A nota avisava que edição directa no código "não tem guard" mas não dizia o que acontecia. Documentado o comportamento real: valores fora de `[0, 1]` fazem o browser usar qualidade padrão da implementação (~0.92); valores dentro de `[0, 1]` mas fora de `[0.70, 0.95]` são aceites sem erro (produzem os artefactos ou desperdício de espaço já documentados).
- **`TOKEN_ACCENT_FG_OVERRIDE` — algoritmo de contraste automático especificado.** A nota dizia apenas "calcula baseando-se na luminância relativa" sem detalhar o algoritmo. Documentado o algoritmo real presente no código: **YIQ** com ponderação `R×299 + G×587 + B×114` e limiar 128 (≥128 → texto escuro `#1a1917`; <128 → texto branco `#ffffff`). Adicionados três exemplos de cores de baixo contraste onde o resultado automático pode não atingir WCAG AA.

### Documentação (auditoria de 2026-05-31)

Reconciliação da documentação com o código real, após auditoria. Sem alterações de comportamento — apenas a documentação passou a descrever o que o código faz hoje.

- **Comportamento de GIF animados por tipo de export documentado** (confirmado por teste do proprietário). `readme.md` §5.6, §5.7 e §8 actualizados: export **ZIP** preserva o arquivo GIF original com animação intacta; export **PDF** inclui apenas a primeira frame (a animação perde-se). A limitação anterior dizia apenas "tratado como imagem estática", sem distinguir os dois modos de export.
- **Protocolo de version bump reescrito com placeholders genéricos** (`agents.md` §12). A versão anterior usava `V23` e `V24` como exemplos concretos dentro das próprias instruções, o que tornava o protocolo auto-obsoleto a cada bump. Substituído por `VERSAO_ANTERIOR` / `VERSAO_NOVA`, tornando o protocolo permanentemente correcto independentemente da versão actual.
- **Migração de schema IndexedDB documentada com código executável** (`agents.md` §6). A nota existente avisava que a migração era necessária mas não instruía como fazê-la. Adicionados dois blocos de código: Caso A (adicionar nova store — seguro, sem migração de dados) e Caso B (alterar campos de store existente — requer iteração e reescrita), com regras críticas sobre o uso de `e.target.transaction` e atomicidade do `onupgradeneeded`.

- **Anotação (desenho livre) alinhada com o código V23.** O `readme.md` (§5.3), o `agents.md` (§7) e o `design-tokens.md` ainda descreviam o pipeline antigo (EMA + suavização Laplaciana + simplificação RDP + fecho automático a 12px). O código V23 mantém **apenas** a suavização EMA em tempo real; a Laplaciana e o auto-fecho foram removidos e o RDP deixou de ser chamado. A documentação foi corrigida nos três arquivos. Removida a referência à função `laplacian()`, que já não existe no arquivo.
- **Tabela de tokens do `readme.md` (§6.4) completada.** Faltavam três tokens que existem no código: `TOKEN_TITLE_START_COLOR`, `TOKEN_TITLE_ACCENT_COLOR` e `TOKEN_TITLE_END_COLOR`. Corrigido também o valor por padrão de `TOKEN_TITLE_START` para `'Capture '` (com o espaço final).
- **Texto duplicado removido.** No `readme.md` (§9) havia dois bullets repetidos após o aviso de recuperação; no `changelog.md` o parágrafo de introdução da V23 estava duplicado. Ambos limpos.
- **Cobertura de browser esclarecida na recuperação de dados.** O `readme.md` (§9) e o `agents.md` (§14) passaram a indicar que o modelo de partilha por perfil foi confirmado em Chromium/Windows; Firefox e Safari não foram testados formalmente.
- **Aviso de quota tornado claro.** O `readme.md` (§8) explica agora que o esgotamento de espaço falha sem aviso visível na tela (só na consola), e recomenda exportar com frequência em sessões grandes. Acrescentada nota sobre ausência de limite fixo de itens.
- **Anotação no código.** Adicionado comentário junto a `rdp()` no `capture-engine.html` a indicar que está definida mas inativa desde a V23.
- **Instruções de execução do `validate.sh`.** O `agents.md` (§10) passou a explicar como correr o script (ambiente Bash; em Windows via Git Bash/WSL) e a alternativa manual.
- **Nota de prevenção de deriva.** Adicionado item à checklist do `agents.md` (§11) para manter os três documentos sincronizados sempre que se altera um motor.
- **Checklist de validação reorganizada.** A Seção 11 do `agents.md` passou a ter duas partes claras: **A — verificações sem browser** (mecânicas via `validate.sh` + leitura de código) e **B — Checklist de Teste Manual no Browser**, agora única e completa (sessão, anotação, reordenação, visual/tema, export, multi-aba). Os testes de export, reordenação e comportamento da anotação, que antes estavam dispersos por vários documentos, ficaram reunidos num só sítio.
- **Linguagem.** Pequenos ajustes para linguagem mais clara e factual (ex.: "pasta inteligente", "sem perda de qualidade").
- **Toda a documentação convertida para PT neutro.** Os quatro `.md` e a string de erro de multi-aba na interface foram uniformizados: `ficheiro→arquivo`, `ecrã→tela`, `seção` (de `secção`), `utilizador→usuário`, `rato→mouse`, `registo→registro`, `anónimo→anônimo`, `deteção→detecção`, `contacto→contato`, `telemóvel→celular`, `aceder→acessar`, `comutar→alternar`, `gerido→gerenciado`, `noutras→em outras`, `premir→pressionar`, `predefinido→padrão` (com correção de concordância, ex.: "do ecrã"→"da tela"). Termos já neutros (`equipamento`, `máquina`, `botão`, `também`, `guardar`, `gravar`) foram mantidos. A tabela-glossário do `agents.md` (§2.1) preservou os exemplos PT-PT de propósito — são o "antes" que ilustra o que evitar.
- **Índice do `agents.md` completado.** Acrescentadas as Seções 13 (Decisões de Design) e 14 (Disaster Recovery), que existiam mas não constavam do índice.

### Corrigido (desenho à mão livre — fidelidade do traço)

> **Estado final (resumo):** RDP definido no código mas **não chamado** no fluxo de desenho. O traço livre é salvo com exactamente os mesmos pontos do preview (`annPath`), sem simplificação. A suavização activa é apenas o filtro EMA (α=0.35) em tempo real. Esta secção regista o percurso de decisões que levou a este estado.

**O traço salvo deixou de ser arredondado ao soltar — impacto: o resultado é igual ao que se vê a desenhar**
- Causa: ao soltar o mouse, o traço passava por uma suavização Laplaciana (2 iterações) antes de ser salvo, o que "alisava" e arredondava a forma em relação ao preview ao vivo.
- Correção: removida a suavização Laplaciana no `mouseup`. O traço é salvo com os mesmos pontos do desenho, renderizado pela mesma curva (`annCR`) usada no preview. Mantida apenas a simplificação RDP (agora com epsilon 1.0, mais suave), que reduz pontos redundantes sem alterar a forma — a pedido do usuário (manter arquivos leves sem perda visual).
- **Correção adicional (auto-fechar):** o traço ainda se alterava ao soltar quando a ponta ficava perto do início — o código marcava `closed = true` e a curva salva **fechava-se sozinha** (ligava ponta ao início), algo que não acontecia durante o desenho. A pedido do usuário, o auto-fechar foi **removido por completo**: o traço salvo fica sempre aberto, idêntico ao desenhado. Removido também o círculo-indicador de "fechar" do preview, que deixou de fazer sentido.
- **Correção final (quinas pontudas):** mesmo sem Laplaciana e sem auto-fechar, as quinas das curvas ficavam **suaves durante o desenho mas pontudas ao soltar**. Causa: a simplificação RDP removia os pontos intermédios das curvas; com menos pontos, a curva `annCR` fazia ângulos em vez de curvas. Como o traço já é filtrado em tempo real (só regista pontos a >5px de distância), o RDP poupava pouco e partia as curvas. **RDP removido do fluxo de desenho** (a função fica definida mas deixa de ser chamada): o traço é salvo com **exatamente os mesmos pontos** do preview (`annPath`), garantindo fidelidade total — o que se desenha é o que fica, quinas suaves incluídas.

### Corrigido

**Desenho à mão livre a piscar — impacto: traço estável durante o desenho**
- Causa: o manipulador de `mousemove` limpava e repintava o canvas inteiro (`annRedraw`) a cada evento de mouse, o que produzia cintilação entre o `clearRect` e o repintar, sobretudo com histórico grande ou muitos eventos por segundo.
- Correção: a acumulação de pontos do traço continua a acontecer a cada evento (precisão mantida), mas o **repintar do canvas passou a ser agendado via `requestAnimationFrame`**, coalescendo vários eventos num único repintar sincronizado com a tela. Adicionada também a limpeza do frame pendente (`cancelAnimationFrame`) no `mouseup` para o redraw final não ser sobreposto por um frame obsoleto. A matemática de suavização (EMA + Laplaciana + RDP) não foi alterada.

**Imagens a piscar e a saltar de posição ao arrastar — impacto: reordenação estável, com mouse e toque**
- Causa: a reordenação usava HTML5 drag-and-drop. Durante o `dragover`, mover o elemento arrastado no DOM (`insertBefore`/`appendChild`) alterava o que estava sob o cursor, o que voltava a disparar `dragover`/`dragleave` e reposicionava de novo — um ciclo de reposicionamento que continuava mesmo com o mouse imóvel.
- Correção: a reordenação foi **reescrita com Pointer Events**. O `initReorder` deixou de depender do mecanismo nativo de drag; passou a seguir o ponteiro diretamente, com um limiar de ~6px antes de iniciar o arrasto (um clique simples continua a abrir o item). Removidos os atributos `draggable` e os handlers `dragstart`/`dragend` dos thumbs e documentos. Adicionado `touch-action: none` aos itens para o arrasto funcionar também em telas de toque. A persistência da nova ordem no IndexedDB mantém-se igual.

**Correção de seguimento (mesmo ciclo):** após o primeiro teste, faltavam duas coisas no arrasto novo: (1) o `<img>` dentro de cada miniatura continuava a ser arrastável nativamente pelo browser, o que gerava uma *cópia fantasma* da imagem e impedia a reordenação — bloqueado agora via CSS (`-webkit-user-drag: none`, `pointer-events: none` na imagem) e em JS (`draggable=false` + cancelamento de `dragstart` nos itens); (2) a reordenação saltava de posição sem transição.

**Reordenação reescrita com a técnica FLIP (arrasto livre estilo celular):** numa segunda iteração, o arrasto passou a comportar-se como nas apps de iPhone/Android. O item arrastado sai do fluxo e **segue o cursor/dedo livremente** (via `transform`), flutuando por cima dos restantes (`z-index`, sombra, contorno). Os outros itens **deslizam suavemente** para abrir/fechar espaço, usando FLIP (First-Last-Invert-Play) com uma transição CSS (`transform 0.22s`). Ao largar, o item **anima até o lugar final** (snap suave) e só então a ordem é confirmada no DOM e gravada no IndexedDB. Mantida a supressão do clique-fantasma pós-arrasto e o limiar de ~6px que distingue clique de arrasto.

**Refinamento do arrasto (3.ª iteração, modelo placeholder):** a pedido, o arrasto passou a usar um **espaço reservado (placeholder)** em vez de reordenar os itens em tempo real. Comportamento final: ao segurar, o item **encolhe para 75%** (`transform: scale(0.75)`) e flutua em `position: fixed` a seguir o cursor (offset de pega corrigido para a escala); no destino aparece um **placeholder de área cinza muito suave** (tom derivado de `--text` via `color-mix`, ajustável pelas variáveis `--drop-ph-bg`/`--drop-ph-border`); os outros itens deslizam à volta do placeholder (FLIP a cada deslocação); e **só ao soltar** é que o item real assume a posição do placeholder e volta ao tamanho normal. Adicionada limpeza de transforms residuais dos irmãos no fim do gesto.

**Correção de flicker em fronteiras (4.ª iteração):** o placeholder oscilava (A→B→A) quando o cursor pairava junto à fronteira entre células, sobretudo perto da borda e na última linha. Três causas tratadas: (1) o cálculo do alvo passou a **excluir o próprio placeholder** (antes contava como célula e fazia o alvo alternar); (2) adicionada **histerese** — uma zona morta de ~18% à volta do centro de cada item, para o alvo só mudar quando o cursor passa o centro com margem, em vez de a cada micro-tremor; (3) reforçado o guard que ignora relocações que correspondem ao lugar atual do placeholder, evitando animações FLIP desnecessárias.

**Correção da causa-raiz do flicker (5.ª iteração):** mesmo com histerese, o placeholder ainda saltava para a posição errada (ex.: arrastar da posição 1 para a 5 punha o espaço vazio na 8). Causa real identificada: o cálculo do alvo media `getBoundingClientRect` dos itens **enquanto estes deslizavam** (animação FLIP em curso), apanhando posições intermédias e decidindo o alvo errado, o que disparava novo FLIP — um ciclo. Correção: o `targetBefore` passou a usar a **geometria de repouso** (`offsetLeft`/`offsetTop`/`offsetWidth`/`offsetHeight`), que é independente dos `transform` da animação, mais o scroll do contentor. O alvo deixa de depender de posições transitórias, eliminando o salto.

### Notas

- Esta versão precisa de **teste manual no browser** (desenhar à mão livre; arrastar imagens/documentos para reordenar; confirmar que um clique simples ainda abre o item; testar em mouse e, se possível, em toque). A verificação estática (`validate.sh`) confirma apenas a integridade estrutural — passou 15/15.
- O drop de **arquivos** vindos do sistema operativo para as zonas de imagens/documentos não foi alterado (continua a usar o mecanismo nativo, que é o adequado para esse caso).



Resultado de uma auditoria externa de documentação, com as decisões de intenção confirmadas pelo proprietário (Diogo Carvalho).

### Adicionado

**Licença MIT — impacto: a ferramenta pode ir para o GitHub e ser usada livremente por qualquer pessoa**
- Novo arquivo `LICENSE` (MIT, Copyright (c) 2026 Diogo Carvalho).
- Cabeçalho de copyright adicionado no topo do `capture-engine.html` (dentro de `<html>`, por isso é preservado pelo Quine em todos os exports). Garante que o aviso viaja mesmo quando só o `.html` é distribuído.
- Seção "Licença" adicionada ao `readme.md`, em linguagem simples.

**`validate.sh` — impacto: um agente de IA pode verificar a integridade sem abrir o browser e sem alucinar**
- Script de verificação estática (apenas grep + contagens + sintaxe via `node` se disponível): contagem de markers (=11), presença das funções Quine, spans de título, ausência de `eval/Function/document.write`, regra zero-dependência, cabeçalho de licença, ausência de código removido, sintaxe JS. Resultado determinístico (sempre igual para o mesmo arquivo). Documentado em `agents.md` (Seções 10 e 11).

### Removido

**`TOKEN_SUBTITLE` — impacto: menos código morto**
- Token "reservado" sem qualquer UI nem efeito. Removido da declaração, da `exportFile` (variável `sub` e respetiva substituição Quine) e da tabela em `design-tokens.md`.

**Modo PDF `'exact'` — impacto: remoção de ramo inalcançável**
- O modo `'exact'` (página = tamanho da imagem) não tinha nenhuma forma de ser ativado pela interface (os botões só produzem `auto`/`a4v`/`a4h`) e não estava associado ao controlo de qualidade do VB (esse é o `TOKEN_JPEG_QUALITY`). Ramo removido de `generatePDF`, e da documentação (`readme.md` §5.6, `agents.md` §8 e tabela de `pdfFmt`).

### Corrigido

**Documentação de recuperação de desastres — impacto: deixa de prometer algo que falha em vários cenários**
- A promessa "mesmo nome + mesma pasta → dados voltam" foi reescrita com as condições reais (confirmadas por teste): só funciona no **mesmo browser e mesmo perfil**, com o arquivo **extraído para uma pasta** (não aberto de dentro de um ZIP), e **não** funciona em janela anônima/privada. Atualizado em `readme.md` §9 e `agents.md` §14. *(Corrigido novamente na seção "modelo de armazenamento" mais abaixo: a bateria de testes provou que nome e pasta são irrelevantes — só o perfil de browser importa.)*

**Contradição da contagem de markers — impacto: instrução de integridade coerente**
- `agents.md` §5: o comentário do bloco `grep` dizia "Deve retornar 10"; corrigido para **11**, em linha com a Seção 11 e com o resultado real do `grep`. (A correção anunciada na V22.1 tinha ficado incompleta neste ponto.)

**Tamanho do arquivo no FAQ — impacto: número realista**
- `readme.md` §10: "140KB" corrigido para ~187KB (versão admin) com nota de que o Export User fica menor.

### Documentação — modelo de armazenamento (confirmado por testes)

Bateria de 13 testes executada pelo usuário em Windows 11 25H2 com Edge 148 e Chrome 148. Resultado: **o acesso aos dados é determinado pelo perfil de browser local**, não pelo nome/pasta/versão do arquivo (todos usam a mesma base `CaptureEngineDB`). Confirmado também que os dados são **locais à máquina** — não são sincronizados pela conta Google (mesmo perfil em outro PC = histórico vazio). A documentação de recuperação (README §9 e agents.md §14) foi reescrita para refletir o comportamento real e testado, substituindo a suposição anterior de que os dados eram "indexados pelo caminho do arquivo". Adicionada nota sobre isolamento natural por VDI e a possível exceção de ambientes com roaming de perfil. Protocolo e resultados documentados internamente (não incluídos no pacote distribuído).

### Documentação

- **Linguagem promocional neutralizada** (decisão do proprietário): "Auditoria FAANG/Militar", "Auditoria Zero Trust", "premium", "blindadas", referência a "padrões de grandes empresas (Google, Stripe, Notion, Apple, Microsoft)" e título "Gold Standard" da Seção 2.3 do `agents.md` substituídos por descrições factuais.
- **Modelo de ameaça XSS** explicitado em `agents.md` §1.3 (conteúdo de terceiros colado a partir de tickets de cliente).
- **Aviso de dados efémeros** em linguagem simples adicionado ao topo do `readme.md`.
- `readme.md` §12: estrutura de arquivos atualizada com `LICENSE` e `validate.sh`.

### Decisões mantidas (confirmadas pelo proprietário, sem alteração de comportamento)

- **Purge automático às 48h + sem backup automático** → comportamento **intencional** por privacidade. Para salvar, o usuário exporta PDF/ZIP. Apenas clarificado na documentação, não alterado.
- **Título com 3 partes e cores independentes** → **funcionalidade desejada** (ex.: "C" verde, "B" amarelo, "F" azul). Mantida; removida da lista de "complexidade desnecessária" da auditoria.



### Correções (auditoria de consistência documentação↔código)

**BUG #4 — delDoc selector sem especificidade de classe**
- `window.delDoc`: selector DOM corrigido de `[data-id="..."]` para `.d-item[data-id="..."]`
- Consistente com `delImg` que já usava `.t-item[data-id=...]`

**BUG #5 — Memory leak no modal de imagem (img.onerror ausente)**
- `openImgModal`: adicionado `img.onerror = function() { URL.revokeObjectURL(url); }`
- Object URL agora é libertado tanto em sucesso (`onload`) como em falha (`onerror`)

**INC #2 — Variável morta `_vbOverlayMdOnBackdrop` removida**
- Resíduo da versão anterior em que o VB fechava ao clicar fora
- Comportamento atual (fechar só pelo ✕) é intencional — ver Seção 13 do agents.md (Decisão D2)

**INC #3 — ZIP path traversal: sanitização de backslash Windows**
- `generateZIP`: adicionado `.replace(/\.\.\\/g, '')` para cobrir paths `..\` (Windows-style)
- Contexto de uso: ambiente bancário/corporativo multi-OS

**INC #5 — Blob validation ao carregar sessão (Safari/WebView)**
- `loadSession`: imagens e documentos são agora filtrados por `blob instanceof Blob && blob.size > 0`
- Protege contra Safari em modo privado e WebViews corporativos que deserializam Blobs como `{}`
- Sem esta proteção, `URL.createObjectURL({})` causava crash silencioso

### Nova Funcionalidade

**TOKEN_TITLE_END — Terceiro campo de título**
- HTML: `#tb-brand-name` refatorado de 1 span para 3 spans independentes (`#ui-title-start`, `#ui-title-accent`, `#ui-title-end`)
- Visual Builder (Tab Interface): novo campo "Texto Final" (`cfg-title-end`) com nota "espaços manuais"
- `initVbSync`: função `syncTitleSpans()` centraliza atualização live dos 3 campos
- `applyTokens`: inicializa e renderiza os 3 spans
- `exportFile` (Quine): substitui `TOKEN_TITLE_END` via regex (par com START e ACCENT)
- CSS: `#ui-title-accent` herda `opacity:0.5`, `#ui-title-end` herda `font-weight:600` e `opacity:1`
- Permite títulos como `CPC` (letras alternadas) ou `Service Desk Engine` com espaços manuais

### Decisões Documentadas (sem código alterado)

- **D1**: PDF desativado com imagens+docs — intencional (PDF é exclusivo de imagens)
- **D2**: VB não fecha ao clicar fora — intencional (proteção contra fecho acidental)
- **D3**: setInterval 5s mantido — cobre 16 eventos isDirty no VB sem triggerSave imediato
- **D4**: Placeholder "Imagem N" não atualiza após reorder — decorativo, não numeração oficial
- **D5**: triggerSave sem await em closeSettingsModal — risco aceite, coberto pelo interval

### Documentação

- `agents.md`: nova Seção 13 "Decisões de Design Documentadas" (D1-D6)
- `agents.md`: Seção 5 — nota sobre VB modal intencional
- `agents.md`: Seção 7 — lógica de `updateBtns()` documentada
- `agents.md`: Seção 9 — `_vbOverlayMdOnBackdrop` removida; nota sobre blob validation
- `agents.md`: Seção 11 — checklist atualizada com verificações TOKEN_TITLE_END
- `agents.md`: Seção 1.2 — TOKEN_TITLE_END documentado com exemplo de uso

## [V22] — 2026-05-30
### Adicionado

**Swatches de cor individuais para os 3 campos de título — impacto: permite criar títulos multicolor (ex: `C P C`) com cada parte numa cor independente**

Os campos "Texto Inicial", "Texto em Destaque" e "Texto Final" no Visual Builder têm agora cada um o seu próprio swatch de cor (circle picker), à imagem do padrão do Service Desk Engine. Duplo clique ou clique direito no swatch repõe a cor para automático (herda cor do contexto). Três novos tokens adicionados ao sistema:

- `TOKEN_TITLE_START_COLOR` — cor do Texto Inicial (vazio = herda `--text`)
- `TOKEN_TITLE_ACCENT_COLOR` — cor do Texto em Destaque (vazio = herda opacidade da accent)
- `TOKEN_TITLE_END_COLOR` — cor do Texto Final (vazio = herda `--text`)

Todos os 3 tokens são exportados pelo Quine em Export Admin e Export User. As CSS vars `--title-start-color`, `--title-accent-color`, `--title-end-color` são aplicadas dinamicamente. Quando vazias, a propriedade é removida do `documentElement` para herança natural.


### Corrigido

**Bug de deduplicação em `setLabel` — impacto: renomear imagem já não permite colisão com nomes na lixeira**

A função `setLabel` (renomear imagem ativa) verificava duplicados apenas contra `images[]`, ignorando `removed[]`. Era possível renomear uma imagem ativa para o mesmo nome de uma imagem na lixeira, violando a invariante de unicidade documentada no checklist ("deduplicação verifica contra listas ativas e lixeira"). A condição `while` foi corrigida para verificar ambas as listas, em paridade com `captureImg` e `restoreImg`.

### Documentação — Auditoria de Resiliência V22

Quatro divergências documentação/código identificadas e corrigidas:

- **`agents.md` — `genId` (Seção 3):** Formato documentado corrigido de `{prefix}_{entropia}` (2 partes, exemplo `img_1a2b3c4d5`) para o formato real de **3 partes**: `{prefix}_{Date.now()}_{5_chars_base36}` (ex: `img_1748611200000_a3f7k`). Adicionada explicação do papel de cada componente (timestamp para ordenação cronológica, base-36 para entropia contra colisões no mesmo milissegundo).
- **`agents.md` — Contagem de marcadores (Seção 5):** Adicionada nota explicativa que distingue **8 strings únicas de marcadores** (cobertura de `sanitizeForQuine`) de **10 ocorrências no HTML** (resultado do `grep -c` no checklist). Elimina a ambiguidade entre os dois números que apareciam sem contexto.
- **`agents.md` — Protocolo de Version Bump (Seção 12):** Corrigido de "2 locais dentro do `capture-engine.html`" para **3 locais**: comentário do Visual Builder, badge visual, e `SysLogger.info('Capture Engine Vxx Ready')`. Atualizada contagem de "5 locais vitais" para "5 arquivos (6 substituições no total)".
- **`agents.md` — Checklist (Seção 11):** Item de deduplicação agora é consistente com o comportamento real do código após a correção de `setLabel`.

### Auditoria de consistência — correções adicionais

**Bug `setDocName` — deduplicação incompleta (simétrico ao bug de `setLabel`)**

A função `setDocName` (renomear documento ativo) verificava duplicados apenas contra `docs[]`, ignorando `removedDocs[]`. O mesmo padrão de bug que existia em `setLabel` — prometido corrigido em V22 mas ainda presente nesta versão. Corrigido: condição `while` agora verifica `docs[]` e `removedDocs[]` em paridade com `captureDoc` e `restoreDoc`.

**Bug `annDrawShape` — side effects no branch `arrow`**

`annDrawShape` é uma função de desenho pura chamada por `annRedraw` (incluindo em undo/redo). O branch `type === 'arrow'` continha `annIsDirty = true` e manipulação de DOM (`btn-admin-save`, `btn-ann-close`) — side effects que não pertencem a uma função de draw. Consequência: abrir o modal de uma imagem com setas anotadas marcava imediatamente `annIsDirty = true` e exibia o botão de Export sem o usuário ter editado nada. Corrigido: side effects removidos do branch arrow; o estado dirty é gerenciado exclusivamente pelos event handlers de input (mouseup, commit text).

**`agents.md` — Contagem de markers: 10 → 11**

O `grep -c` real retorna 11 (não 10). Os 3 locais em `agents.md` que diziam 10 foram corrigidos para 11, e a nota explicativa expandida para detalhar as 4 categorias de linhas: 8 estruturais, 1 em `boot()`, 1 em `sanitizeForQuine`, 1 em `exportFile`.

**`agents.md` — Seção 9: 9 variáveis de estado adicionadas à tabela**

Variáveis ausentes da tabela de referência rápida adicionadas: `PRISTINE_HTML` (fonte primária do Quine), 4 flags de gesture de modal (`_imgOverlayMdOnBackdrop`, `_textOverlayMdOnBackdrop`, `_vbOverlayMdOnBackdrop`, `_expOverlayMdOnBackdrop`), `textModalItemId`, `textModalIsTrash`, `ANN_SIZES`, `ANN_TEXT_SIZES`.

**`design-tokens.md` — `TOKEN_NOME` clarificado**

`TOKEN_NOME` na seção de sintaxe era ambíguo (parecia um token real). Clarificado como placeholder de sintaxe.

---

## [V21] — 2026-05-30

### Corrigido

**Bug crítico do Quine Engine — impacto: configurações do administrador agora são corretamente aplicadas em todos os exports**

O regex de substituição de tokens de string no `exportFile()` usava o padrão `/const TOKEN_NOME='[^']*'/` (sem espaços em redor do `=`), enquanto as declarações reais no código têm o formato `const TOKEN_NOME = 'valor'` (com espaços). Consequência: todas as substituições de string — cor principal, título, texto do rodapé, rótulos de campos — falhavam silenciosamente. O arquivo exportado ignorava as configurações do Visual Builder e mantinha sempre os valores padrão. Corrigido com regex flexível `\s*=\s*` que aceita espaços opcionais; o output escreve sempre com espaços para consistência de leitura.

Tokens afetados: `TOKEN_MAIN_COLOR`, `TOKEN_ACCENT_FG_OVERRIDE`, `TOKEN_TITLE_START`, `TOKEN_TITLE_ACCENT`, `TOKEN_SUBTITLE`, `TOKEN_USER_LABEL`, `TOKEN_EQUIP_LABEL`, `TOKEN_FOOTER_TEXT`.

Tokens não afetados (usavam regex `=[^;]+` sem aspas, já funcionavam): `TOKEN_SHOW_SESSION_USER`, `TOKEN_SHOW_SESSION_PC`, `TOKEN_JPEG_QUALITY`, `TOKEN_MAX_IMG_DIMENSION`, `TOKEN_AUTO_PURGE_HOURS`, `TOKEN_DEBUG_MODE`.

### Documentação — Auditoria de Resiliência Operacional

Auditoria completa de consistência entre documentação e código. Todas as divergências identificadas foram corrigidas:

- **`agents.md`:** Contagem de markers corrigida de 8 para 10 (com nota sobre o segundo par `ADMIN_JS` em `boot()`); localização de `BOOT_HTML` corrigida para "dentro do bloco ADMIN_JS"; 15+ variáveis de estado global adicionadas à Seção 9 (`lastSaveAt`, `pdfFmt`, `zipModeActive`, `modalIsTrash`, `modalItemId`, variáveis de zoom/pan, variáveis de anotação em progresso); `idbTx` adicionada à tabela de funções críticas; schema de `localStorage` documentado (chave `theme`, histórico de `ec_pending_session`); modo PDF `exact` documentado na Seção 8.
- **`readme.md`:** Diagrama `boot()` corrigido — hierarquia invertida (`init → boot`, não `boot → init`) e lista de funções expandida de 7 para 18 chamadas reais; termos `Estado Pristine` e `initSessionSync` adicionados ao glossário; seção de Diagnóstico de Export adicionada para administradores; suporte Safari documentado (parcial, mitigado pelo fallback `BOOT_HTML`).
- **`design-tokens.md`:** Instrução de formato de tokens atualizada para refletir que espaços à volta do `=` são suportados e recomendados; referência a "V17" em `TOKEN_TITLE_END` corrigida para "a partir da V17".
- **`changelog.md`:** Nomenclatura "Zero Trust Audit" substituída por "Auditoria de Resiliência Operacional" em todas as ocorrências da V20.
- **`agents.md` — Checklist (Seção 11):** Corrigida referência residual a "8 markers" (deve ser 10); adicionada nova seção **Documentação** com dois itens preventivos: verificação do diagrama `boot()` sempre que uma função de inicialização for adicionada ou removida, e verificação da tabela de variáveis globais sempre que uma nova variável de estado for introduzida.

---

## [V20] — 2026-05-30

### Adicionado

**Melhorias na Lixeira (Trashbar) — impacto: gestão e recuperação rápida de arquivos apagados**
- **Botão de Restauro:** Adicionado um botão dedicado de restauro nos itens da lixeira, permitindo recuperar imagens ou documentos com apenas um clique.
- **Pré-visualização (Hover):** Arquivos na lixeira passam a exibir um ícone de inspecção ("olho") quando o cursor é posicionado sobre eles, melhorando a interatividade visual.

**Alerta visual ao fechar sem salvar — impacto: alerta de modificações pendentes**
- Introduzida uma animação de aviso fluida (*pulse* com escala a 1.08x) nos botões de "Confirmar" e "Cancelar", que é acionada caso o usuário tente fechar o modal com modificações pendentes por gravar.

### Modificado

**Estado Real de Modificação (annIsDirty) — impacto: bloqueios inteligentes apenas quando estritamente necessário**
- Introduzida uma flag de ciclo de vida em tempo real (`annIsDirty`) para detetar alterações efetivas feitas com o cursor. Isto substitui as pesadas comparações de base de dados, eliminando os falsos positivos que bloqueavam indevidamente o fecho imediato das imagens.

**Lógica de fecho dinâmico do modal de edição — impacto: proteção contra perda de dados**
- O botão de "Fechar" (`X`) no canto superior direito do modal desaparece dinamicamente assim que uma edição é iniciada. O botão permanece visível apenas se não houver modificações pendentes, canalizando o usuário para cliques seguros e prevenindo encerramentos acidentais.

**Padronização e UI dos botões de ação — impacto: aspeto visual mais uniforme e limpo**
- Removido o efeito de sombra (`box-shadow`) nos botões de ação, padronizando o design para um aspeto mais limpo, harmonioso e com maior destaque dentro da UI.
- Adicionado destaque visual refinado aos ícones de texto dentro do modo de anotação.
- Removido o comportamento de seleção acidental de texto (*highlight*) no ícone de "Excluir Sessões", tornando o clique na UI mais consistente.

**Limpeza automática (Purge) — impacto: base de dados resiliente em falhas isoladas**
- A funcionalidade de limpeza de sessões antigas (`purgeExpired`) foi reestruturada: a deleção individual de cada sessão isola-se em blocos `try/catch`, pelo que uma eventual corrupção num arquivo não interrompe a eliminação do restante lixo acumulado.
- As transações IndexedDB (`idbTx`) foram reforçadas para intercetar falhas nativas (`tx.onerror`) diretamente na raiz, prevenindo erros silenciosos.

### Corrigido

**Expansão da Lixeira (Trashbar) — impacto: UI responsiva e sem interrupções visuais**
- Aperfeiçoada a lógica de expansão do painel da lixeira: a animação de abertura é agora ininterrupta, crescendo na proporção exata do conteúdo e eliminando o *flicker* da barra de *scroll* que surgia por breves milissegundos.

**Gestão de Memória e Downloads (Object URLs) — impacto: downloads fiáveis e eficiência de RAM**
- Resolvido um bug crítico nos botões de download (`img-modal-dl` e `text-modal-dl`) herdado da V19. A URL do arquivo era revogada instantaneamente (`URL.revokeObjectURL`), cortando a ligação antes de o browser iniciar o download. Foi aplicado um desfasamento seguro de 1000ms.
- Eliminado um *memory leak* na rotina de conversão de imagens (`imgToJPEG`). Anteriormente, se o carregamento falhasse (`img.onerror`), a memória do *blob* nunca era liberta. A revogação ocorre agora de forma imediata na captura do erro.

### Auditoria de Resiliência Operacional

**Recuperação de Desastres e Expectativas — impacto: eliminação de risco de perda de dados e falsas expectativas**
- **Same-Origin Policy Documentada:** Adicionado alerta crítico para administradores garantirem a consistência do nome e pasta do arquivo nas atualizações enviadas aos usuários, prevenindo o reinício silencioso da base de dados e aparente perda de histórico.
- **Desambiguação do Export:** Definida explicitamente a regra de que os botões de Exportar NUNCA guardam os dados da sessão corrente (apenas a configuração).
- **Mecanismos de Esgotamento de Quota:** Documentado o comportamento passivo da aplicação ao esgotar o armazenamento do disco, de forma a acalmar os usuários num eventual desastre (as sessões anteriores ficam salvaguardas e ilesas).
- **Disaster Recovery e DevTools:** Adicionado aos manuais operacionais novos passos para recuperar dados bloqueados ou dados corrompidos usando apenas os recursos nativos e as premissas estritas do IndexedDB, e documentada a lógica oculta de contorno a bloqueios CORS do WebKit/Chromium em ambientes `file://` que justificam o `BOOT_HTML`.

**Finalização da Auditoria de Resiliência Operacional — impacto: correção final de inconsistências técnicas**
- **Quine Engine Token Regex:** O motor Quine foi ajustado (`\s*=\s*`) para suportar e escrever tokens com espaços ao redor do `=`, garantindo legibilidade do código-fonte sem quebrar o regex em exports futuros.
- **Boot Flow Corrigido:** O diagrama de arquitetura no `readme.md` foi corrigido para refletir a ordem real de execução: `init()` chama `boot()`, e não o inverso.
- **Suporte Safari:** Documentado o suporte parcial e as mitigações do Quine Engine para o browser Safari.
- **Modo PDF Exato:** Documentado formalmente o modo `exact` (geração de PDF à escala original) nos manuais `agents.md` e `readme.md`.
- **Contagem de Markers:** A documentação de validação (grep) foi atualizada de 8 para 10 markers, refletindo a duplicação natural do bloco `ADMIN_JS_START/END` no motor.
- **Glossário e Estado Global:** Documentados conceitos ausentes como `Estado Pristine` e variáveis de estado recém-descobertas no código base.

---

## [V19] — 2026-05-26

### Modificado

**Desenho livre — suavização equilibrada para mouses de baixa qualidade — impacto: traços suaves sem perder cantos definidos**

- EMA `alpha` ajustado de `0.55` para `0.35` — meio termo entre responsividade e suavização; permite desenhar formas com cantos (quadrados, retângulos) sem que as esquinas sejam demasiado arredondadas.
- Adicionada passagem de suavização **Laplaciana** (2 iterações) antes do RDP no `mouseup`, eliminando jitter residual sem deformar cantos.
- Epsilon do RDP ajustado de `1.5` para `1.8`.
- Raio de **fecho automático** do traço reduzido de 24px para **12px** — evita fechos acidentais ao passar perto do ponto inicial.

### Removido

**`CaptureEngineApp-Atalho.md` — removido do pacote — impacto: distribuição simplificada, sem método não fiável**

O guia de atalho Windows (`CaptureEngineApp-Atalho.md`) foi removido do pacote após confirmação de falhas em ambiente corporativo. O método `--app` do Edge é bloqueado por políticas GPO em organizações com hardening de browser, tornando o guia inútil e potencialmente confuso. O Capture Engine abre diretamente com duplo clique no `capture-engine.html` em qualquer sistema operativo — esse continua a ser o método oficial e único suportado.

### Adicionado

#### Ferramenta de Texto — Reformulação Completa
- **Fix: Salto de posição eliminado** — O texto agora é renderizado exatamente onde o cursor clicar. A causa era um erro de `textBaseline`: o canvas usava `alphabetic` (baseline na base dos caracteres) enquanto o input HTML era posicionado a partir do topo. Corrigido com `textBaseline = 'top'` no canvas e `top = screenY` no input.
- **Negrito (Ctrl+B)** — Toggle de negrito durante a digitação ou ao clicar no botão B na toolbar. Ativo por padrão.
- **Itálico (Ctrl+I)** — Toggle de itálico durante a digitação ou ao clicar no botão I na toolbar.
- **Tamanho de fonte variável** — Os botões −/+ de espessura, quando a ferramenta Texto está ativa, controlam o tamanho da fonte em 5 níveis: 14 · 18 · 24 · 36 · 48px (padrão: 24px).
- **Double-click para reeditar** — Clicar duas vezes em cima de um texto já colocado (antes de confirmar) reabre o campo de edição com o conteúdo original, mantendo cor, bold e itálico.
- **Cor ao reeditar** — Ao reeditar texto existente via double-click, clicar numa swatch atualiza a cor do texto em tempo real.

#### Ícone da Ferramenta Texto
- Substituído o ícone T "vazado" (com caule duplo e linha de base) por um T tipográfico com serifs em cima e baixo — mais harmonioso com os restantes ícones da toolbar.

### Melhorias Técnicas
- `annHistory` agora armazena `{bold, italic, fontSize}` por entrada de texto, permitindo fidelidade total na re-renderização.
- `annShowTextInput` refatorizado: aceita `prefillText` opcional para suportar edição de texto existente.
- Botões B/I aparecem automaticamente ao selecionar a ferramenta Texto e ocultam ao mudar para outra ferramenta.
- `annEditingTextIdx` rastreia se o usuário está a editar uma entrada existente ou a criar uma nova.

### Corrigido (pós-release)

#### Ferramenta Texto — Correções de Comportamento
- **Fix: Salto invertido (texto subia)** — O `<input>` mesmo com `padding:0` adicionava *internal leading* que deslocava o texto visível abaixo do topo do elemento. Corrigido forçando `line-height` e `height` do input ao valor de `scaledFontSize` — o texto fica encostado ao topo, alinhado com o `textBaseline='top'` do canvas.
- **Fix: Double-click criava novo texto em vez de editar** — O `mousedown` disparava antes do `dblclick` na sequência de eventos do browser (`mousedown → mouseup → click → mousedown → mouseup → click → dblclick`), chamando `annShowTextInput` com `annEditingTextIdx=-1` e destruindo a intenção de edição. Solução: single-click aguarda **220ms** via `setTimeout` antes de abrir input novo; o `dblclick` cancela o timer e toma conta da edição.
- **Fix: Cor não mudava durante edição de texto** — Clicar numa swatch disparava `blur` no input (perda de foco), fazendo `commit()` antes de a cor ser aplicada. Corrigido com `mousedown.preventDefault()` nas swatches, botões B e I **apenas quando o input está ativo** — o input mantém foco, `inp.style.color` atualiza em tempo real, e `inp.focus()` garante continuidade de digitação.
- **Fix: Perda de texto ao pressionar Escape durante edição** — O `dblclick` fazia `annHistory.splice(_i, 1)` imediatamente ao abrir o input. Se o usuário pressionasse Escape, o texto era apagado permanentemente. Corrigido: sem splice; `annRedraw()` passa a saltar o índice `annEditingTextIdx` (texto fica em "ghost" durante edição); Escape faz `annRedraw()` que o restaura.
- **Fix: Timer fantasma em `annDeactivate`** — `annTextClickTimer` era declarado dentro de `initAnnotation()`, tornando-o inacessível a `annDeactivate`. Ao fechar o modal durante os 220ms, o timer disparava `annShowTextInput` num overlay invisível. Corrigido: timer hoistado para scope de módulo; `annDeactivate` limpa-o explicitamente.

#### Visual Builder — Admin Gate
- **Fix: Ícones admin não desapareciam ao fechar o VB** — `deactivateAdmin()` estava encapsulada no closure de `initAdminGate`, inacessível a `closeSettingsModal`. Corrigido expondo-a como `window._deactivateAdmin`; `closeSettingsModal` chama-a ao fechar — ícones desaparecem imediatamente ao clicar no X.

#### Ferramenta Desenho Livre — Suavização (valores pré-V19, antes dos ajustes acima)
- **Fix: Linha tremia ao desenhar** — O `annPath` acumulava todos os pontos em bruto do mouse (threshold 3px), e o Catmull-Rom interpolava fiel e fielmente cada micro-tremor. Três camadas de correção:
  1. **EMA (Exponential Moving Average, α=0.55)** — cada ponto é misturado com o anterior (`0.55 × novo + 0.45 × último`) antes de entrar no path, eliminando tremor de alta frequência em tempo real.
  2. **Threshold 3px → 5px** — pontos mais próximos que 5px do anterior são descartados.
  3. **RDP no commit (ε=1.5px)** — ao soltar o mouse, o path é simplificado com Ramer-Douglas-Peucker antes de ser salvo em `annHistory`, removendo pontos colineares redundantes sem alterar a geometria visível.

> **Nota:** Estes valores de EMA (α=0.55) e RDP (ε=1.5px) foram os valores iniciais. Foram posteriormente ajustados para α=0.35 e ε=1.8px na seção "Modificado" acima.

---

## [V18] — 2026-05-25

### Modificado

**Sessão criada apenas na primeira interação real — impacto: abrir e fechar o programa sem usar não gera sessão no histórico**

Anteriormente, `init()` chamava `createSession()` de forma incondicional ao abrir o arquivo — uma sessão era escrita no IndexedDB mesmo que o usuário abrisse e fechasse o programa sem qualquer interação. Ao longo do tempo, isto acumulava sessões vazias no histórico. Agora `init()` não cria sessão. A criação acontece de forma lazy via `ensureSession()`, que é chamada automaticamente no primeiro evento real: digitar nos campos de sessão, colar uma imagem, arrastar um documento. Sessão sem interação = sessão inexistente.

Alterações técnicas:
- `init()`: removida chamada `await createSession()`
- `saveSession()`: retorna imediatamente se `sessId === null` (guard contra o intervalo de 5s sem sessão ativa)
- `ensureSession()` já existia e já era chamada por `captureImg`, `captureDoc` e `initSessionSync` — nenhuma alteração necessária nessas funções

**Remoção do launcher VBS — substituído por guia de atalho manual**

Os arquivos `CaptureEngineApp.vbs` e `CaptureEngineApp.vbs.md` foram removidos do pacote V18 por alerta de segurança (scripts VBS são bloqueados por políticas de segurança em ambientes corporativos e detetados como potencial ameaça por alguns antivírus). Substituídos pelo arquivo `CaptureEngineApp-Atalho.md` — guia passo a passo para criar um atalho Windows manualmente usando o parâmetro `--app` do Edge, sem nenhum script.

**Ícone de desenho livre — lápis em vez de caneta/pena**

O ícone do botão de desenho livre (modo Anotar) e do botão "Anotar" no modal de imagem foram substituídos por um lápis padrão (path `M17 3a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L17 3z`), mais reconhecível e intuitivo para a ação de desenho manual.

**Desenho livre suavizado com Bezier quadrático + point thinning**

O traço de desenho livre era renderizado com `lineTo` puro, produzindo linhas quebradas e tremidas especialmente em movimentos rápidos. Implementada suavização via curvas Bezier quadráticas: cada segmento usa o ponto médio entre dois pontos consecutivos como endpoint da curva, com o ponto original como ponto de controlo. Adicionado point thinning (pontos com distância < 3px são descartados) para reduzir ruído sem perder fidelidade. A mesma lógica aplica-se à re-renderização do histórico (`annDrawShape`).

### Corrigido

**Português neutro — correções de regionalismo PT-PT na interface**

- `title="Guardar"` (botão de confirmar anotação) → `title="Confirmar"` — mais preciso semanticamente e neutro
- `"Fecha-as e recarrega esta página"` (erro de IDB com múltiplas abas) → `"Feche-as e recarregue esta página"` — forma verbal mais neutra
- `title="Cor (Duplo clique para Automático)"` → `title="Cor (Clique duplo para Automático)"` — ordem natural em português brasileiro

---

## [V17] — 2026-05-25

### Modificado

**Remoção do botão e mecanismo de "Nova Sessão" — impacto: usuário não consegue abrir sessões em janelas separadas fora do launcher VBS**

O botão "Nova Sessão" (ícone de duplos quadrados sobrepostos na barra de topo) foi removido por decisão de produto. O fluxo de abrir uma nova sessão numa janela independente fazia sentido apenas em conjunto com o launcher `CaptureEngineApp.vbs`; fora desse contexto, o usuário podia inadvertidamente abrir múltiplas instâncias do Capture Engine no browser, cada uma com o seu próprio contexto de sessão, gerando confusão. A remoção garante que o fluxo de trabalho é sempre numa única janela, com navegação entre sessões feita pelo histórico interno.

Remoções associadas:
- HTML: bloco `<button id="btn-new-sess">` da barra de topo
- JS `boot()`: handler `_newSessLock` / `onclick` / `localStorage.setItem('ec_pending_session')` / `window.open()`

**Limpeza de código morto pós-remoção (auditoria V17)**

Após a remoção do botão de nova sessão, foram identificados e eliminados dois blocos de código que se tornaram dead code:

- `init()` — Bloco `ec_pending_session`: lia a chave `ec_pending_session` do localStorage para decidir se devia carregar uma sessão pendente em vez de criar uma nova. Como nada escreve mais nessa chave, o bloco de leitura + remoção + `loadSession` era código morto. Removido.

- `initPickers()` — Setups de `onclick` para `btn-img-pick` e `btn-doc-pick`: tentavam registar handlers de clique em IDs que nunca existiram no HTML (os botões usam `onclick` inline com `document.getElementById` diretamente). Os guards `if($('btn-img-pick'))` preveniam crashes mas o código era inoperante. Removidos. Os handlers `onchange` dos `<input type="file">`, que são a parte funcional real, foram preservados.

## [V16] — 2026-05-24

### Modificado

**Documentação completamente reescrita — impacto: onboarding sem dependência de conhecimento verbal**

Toda a documentação foi auditada, reorganizada e expandida seguindo práticas comuns de boa documentação técnica (glossário, perfis de usuário, fluxos reais, FAQ). As principais mudanças:

- `readme.md` — Expandido de guia funcional para documentação completa com glossário de termos técnicos, perfis de usuário (usuário final / administrador / desenvolvedor), fluxos reais, limitações conhecidas, FAQ, e schema da base de dados. Qualquer pessoa sem contexto prévio consegue entender o sistema sem perguntar aos criadores.

- `agents.md` — Expandido com schema completo do IndexedDB (campos, tipos, obrigatoriedade, índices), documentação de `ec_pending_session`, `BOOT_HTML`, `_ensurePromise`, `isDirty`, `_vbLabelDirty`, e `sysColors`. Adicionados fluxos de comportamento em diagrama (captura de imagem, Export User, apagar sessão ativa). Adicionada tabela de referência rápida de funções críticas. Adicionada documentação de variáveis de estado global.

- `design-tokens.md` — Adicionada explicação sobre como o motor decide entre modo texto e modo binário no modal de documento. Adicionadas notas detalhadas sobre `TOKEN_TITLE_END` (obsoleto mas preservado), `TOKEN_ACCENT_FG_OVERRIDE` (vazio = automático), e `TOKEN_USER_LABEL`/`TOKEN_EQUIP_LABEL` (vazio = padrão visual).

- `CaptureEngineApp.vbs.md` — Adicionada tabela de dados em disco criados pelo launcher, nota sobre suporte exclusivo Windows, e resolução de problema de Edge instalado em caminho não-padrão.

---

## [V15] — 2026-05-24

### Corrigido

**Race condition na criação de sessões — comportamento: sem impacto visível, mas dado potencialmente corrompido**

Ao colar imagem e texto simultaneamente (dois `Ctrl+V` muito rápidos), a aplicação podia criar duas sessões em paralelo em vez de uma. O usuário não notaria imediatamente — a interface parecia normal — mas a base de dados ficaria com uma sessão "fantasma" sem conteúdo. A causa: ambas as operações assíncronas verificavam `if(sessId)return` ao mesmo tempo, antes de qualquer uma ter terminado de criar a sessão. Adicionado um mutex (`_ensurePromise`) que garante que a segunda operação espera a primeira terminar.

**Quine Engine corrompido por certos textos em tokens — comportamento: export de User produzia arquivo quebrado**

Se o administrador colocasse o texto `EXPORT MODAL` ou `FIM EXPORT MODAL` em qualquer campo do Visual Builder (título, rodapé, etc.), o Quine Engine ao fazer Export de User interpretava esse texto como um marcador de código e removia a seção HTML correspondente do arquivo exportado. O resultado era um arquivo que abria sem o modal de exportação. A função `sanitizeForQuine()` já protegia outros marcadores (`ADMIN_*`) mas não estes dois. Adicionada proteção por zero-width space nos dois marcadores em falta.

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

Até à V13, ao abrir a aplicação sem histórico existente, uma sessão era criada automaticamente e aparecia imediatamente no histórico (mesmo vazia). O usuário via uma entrada `#0001` no histórico mesmo antes de fazer qualquer coisa. Agora a interface abre completamente em branco. A sessão só aparece no histórico no momento em que o usuário interage pela primeira vez (cola uma imagem, escreve o nome do usuário, etc.). Histórico limpo = mente limpa.

**Bordas permanentes nos botões de captura — impacto: sem layout shift, interface mais estável**

Os botões "Adicionar Imagem" e "Adicionar Documento" passaram a ter uma borda cinzenta sempre visível (mesmo em repouso), que transita para azul no hover. Antes, a borda só aparecia no hover, causando um "salto" de 1px no layout quando o cursor passava por cima. A borda permanente elimina esse salto — o elemento nunca muda de tamanho.

**Bordas permanentes nos botões de export ZIP — impacto: consistência visual no modo ZIP**

Os botões "Imagens em PDF" e "Imagens Separadas" (quando o modo ZIP está ativo) passaram a usar a classe `btn-zip-cta` com borda azul permanente. Antes, a borda desaparecia ao mover o cursor — o que criava inconsistência visual com os outros botões.

**Detecção automática do tema do sistema — impacto: respeita a preferência do OS na primeira abertura**

Se o usuário abre a aplicação pela primeira vez sem ter definido preferência de tema, a app passa a seguir o tema do sistema operativo (dark/light). Depois de o usuário alternar manualmente, essa escolha fica guardada e sobrepõe-se à preferência do OS.

### Modificado

**Ícone do botão "Nova Sessão" substituído — impacto: mais harmonia visual com os outros ícones da barra de topo**

O ícone de "quadrado com +" foi substituído pelo ícone de "duplos quadrados sobrepostos" (o mesmo SVG do botão "Imagens Separadas"). A razão foi puramente visual: o conjunto de ícones da barra de topo ficou mais coeso.

**FAB mobile em estado neutro — impacto: menos distração em mobile**

O botão flutuante de colar em mobile passou de sempre azul/accent para cinzento discreto em repouso. O azul só aparece no momento exato do toque (`:active`). Em mobile, um botão sempre azul chama atenção desnecessariamente — a cor deve sinalizar ação, não presença constante.

**Chips de seleção de modo (Auto/Vertical/Horizontal) — impacto: clareza visual sobre qual modo está ativo**

O chip selecionado passou a ter borda cinzenta permanente (que vai para azul no hover). Os chips não selecionados ficam sem borda em todos os estados. O contraste é claro: borda = ativo, sem borda = inativo.

**Auto-colapso da sidebar de histórico quando vazia — impacto: mais espaço disponível automaticamente**

Quando o histórico está completamente vazio e o usuário clica fora da sidebar, ela fecha sozinha. Antes ficava aberta mesmo sem conteúdo.

**Espaçamento da left sidebar otimizado — impacto: menos espaço morto em monitores grandes**

Os gaps e paddings internos da coluna esquerda foram reduzidos de valores maiores para valores `clamp` mais compactos. Em monitores de alta resolução, a versão anterior desperdiçava demasiado espaço vertical entre os campos.

### Corrigido

**Touch targets em mobile falhavam — comportamento: apenas 25% esquerdo dos cards respondia a toque**

Em telas com `max-width: 900px`, clicar/tocar num thumbnail de imagem só funcionava se o toque fosse no quarto esquerdo do card. O resto da área não respondia. A causa era um overlay CSS (`pointer-events: auto`) que intercetava os eventos antes de chegarem ao elemento correto. Corrigido com regras defensivas: `pointer-events: auto` + `touch-action: manipulation` nos elementos corretos, `pointer-events: none` forçado no overlay.

**Sessão reutilizada ao reabrir a app — comportamento: estado "sujo" ao abrir em vez de interface limpa**

Ao reabrir a aplicação, o `init()` verificava se havia uma sessão vazia no IndexedDB e reutilizava-a. O resultado era que dados da sessão anterior (nome do usuário, configurações) podiam persistir indevidamente. Agora `init()` chama sempre `createSession()` de forma incondicional (exceto quando há uma sessão pendente explícita via `localStorage`).

**Auto-save demorava 5 segundos após digitar — comportamento: primeiros caracteres podiam perder-se num crash**

O handler dos campos User e Equipamento marcava `isDirty=true` mas aguardava o intervalo de auto-save (5 segundos) para escrever no IndexedDB. Se a aplicação fechasse ou o browser crashasse nos primeiros 5 segundos, o texto perdia-se. Agora `triggerSave()` é chamado imediatamente a cada keystroke — a latência de escrita passa de até 5 segundos para imediata.

**Campos de texto não limpavam ao apagar sessão ativa — comportamento: texto fantasma visível após apagar**

Ao apagar a sessão atualmente ativa, os campos User, Equipamento e Nome mantinham os valores na tela. Visualmente parecia que ainda havia dados de sessão, quando na verdade não havia sessão nenhuma. Os três campos passaram a ser zerados explicitamente no reset.

**Nova sessão criada automaticamente após apagar — comportamento: apagar a última sessão criava imediatamente uma nova**

Após apagar a sessão ativa, o motor criava automaticamente uma nova sessão vazia que aparecia imediatamente no histórico. O usuário que apagou a última sessão intencionalmente ficava com `#0001` de volta no histórico sem ter pedido isso. A criação automática foi removida — o interface fica em branco e aguarda interação real.

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

O label passou de `"Qualidade PDF (JPEG)"` para `"Qualidade do PDF"`. A descrição foi atualizada para explicar que as imagens PNG originais são convertidas para JPEG internamente *apenas durante a geração do PDF* — os arquivos originais na sessão ficam sempre em PNG. Vários usuários confundiam esta compressão com uma degradação permanente dos originais.

---

## [V13] — 2026-05-22

### Adicionado

**Menu dinâmico de opções ZIP — impacto: clareza sobre as duas formas de exportar ZIP**

Ao clicar no botão ZIP quando há imagens na sessão, a interface revela dois botões de escolha: "Imagens em PDF" e "Imagens Separadas". Antes, estas opções eram menos óbvias. Os novos botões usam estilo outline com uppercase, estilo consistente com os chips de seleção de modo.

### Corrigido

**ReferenceError no modal de cópia de texto — comportamento: botão Copiar falhava silenciosamente**

Um erro de referência a variável (`ReferenceError`) no bloco `catch` do modal de cópia de texto fazia com que, se a cópia falhasse, o código de recuperação também falhasse. O usuário via o botão reagir mas nada acontecia e nenhuma mensagem de erro aparecia. Corrigido com referência correta ao elemento de botão.

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

**Motor de zoom com física "zoom-to-pointer" — impacto: experiência de visualização fluida e natural**

O visualizador de imagens foi reescrito do zero. O zoom com scroll/roda do mouse passa a centrar-se exatamente no ponto onde o cursor está — se amplia o canto superior direito, é esse canto que fica no centro. Antes o zoom centrava-se sempre no centro da imagem, forçando o usuário a fazer pan depois de cada zoom. Limites de 20% a 1000%. Barra de controlo flutuante com glassmorphism que aparece apenas quando o zoom é diferente de 100%.

**Modal de histórico centralizado em mobile — impacto: uso com o polegar muito mais fácil em smartphones**

Em telas pequenos (`max-width: 900px`), o histórico de sessões passou de drawer lateral para modal centralizado. A largura e altura do modal foram otimizadas para uso com o polegar — targets de toque maiores, posição central mais acessível.

**Body scroll lock no modal de histórico mobile — impacto: sem rolar o fundo acidentalmente**

Ao abrir o histórico em mobile, `document.body.overflow = 'hidden'` previne que o conteúdo principal role enquanto o usuário navega no modal. Ao fechar, o scroll é restaurado.

**Rótulos personalizáveis no Visual Builder — impacto: o CE funciona para qualquer domínio, não apenas Service Desk**

Adicionados dois novos tokens (`TOKEN_USER_LABEL`, `TOKEN_EQUIP_LABEL`) e dois campos no Visual Builder para renomear os labels "User" e "Equipamento". Uma clínica pode querer "Médico" e "Paciente"; um escritório jurídico pode querer "Advogado" e "Processo".

**Nomeação cronológica de sessões (#0001, #0002...) — impacto: histórico ordenado e sem ambiguidade**

Sessões sem nome digitado pelo usuário passaram de `Sessão-1` para `#0001`, `#0002`, etc. O formato com zeros à esquerda garante ordenação alfabética correta em qualquer sistema — `#0009` vem antes de `#0010`, ao contrário de `Sessão-9` vs `Sessão-10`.

### Corrigido

**Colar com Ctrl+V falhava em Edge/WebKit — comportamento: clipboard ignorado silenciosamente em certos browsers**

Em algumas versões do Edge e browsers baseados em WebKit, `DataTransferItemList` não é iterável com `for...of`. O loop de leitura do clipboard falhava silenciosamente sem colar nada. Substituído por iteração com índice numérico explícito (`for(let i=0; i<items.length; i++)`), que funciona em todos os browsers.

**Eventos fantasma bloqueavam a interface em mobile — comportamento: clicar na grelha de imagens mudava de sessão**

O `#sb-content` (a lista de sessões, invisível quando a sidebar está fechada) tinha `pointer-events: auto` mesmo quando não estava visível. Em mobile, a camada invisível intercetava cliques sobre a grelha de imagens e ativava sessões no histórico sem o usuário saber. Corrigido: `pointer-events: auto` apenas quando o modal está aberto (`.mobile-open`).

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

**`TOKEN_DEBUG_MODE` — impacto: logs de debug invisíveis para usuários finais**

Adicionado token que controla se `SysLogger` escreve na consola do browser. Em exports de User, este token é automaticamente definido como `false` — os usuários finais nunca veem logs técnicos na consola.

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

Ao clicar numa sessão diferente no histórico, a sidebar permanece aberta. Antes fechava automaticamente a cada navegação, forçando o usuário a reabri-la para cada mudança de sessão.

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

## [V7] — 2026-05-17

### Base da Arquitetura Atual

Esta versão estabeleceu as fundações sobre as quais todo o motor assenta:

- **IndexedDB com 5 object stores:** `sessions`, `images`, `documents`, `removed_images`, `removed_documents` — persistência local, assíncrona, sem localStorage para dados grandes
- **Visualizador de texto modal:** Abre documentos de texto inline com área de texto monoespaçada; arquivos binários (PDF, DOCX) mostram mensagem amigável para download
- **Anotador vetorial:** Desenho sobre screenshots com círculos, retângulos, setas, texto livre — achatamento lossless direto em PNG (as anotações ficam permanentes na imagem)

---

*Capture Engine · Zero-Dependency Quine System*

