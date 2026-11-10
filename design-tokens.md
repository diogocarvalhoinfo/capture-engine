# Design tokens

Os valores visuais do projeto: o nome e o valor de cada token.

Nenhuma regra do CSS usa uma cor, um espaço, um tamanho ou uma duração literal: usa um token desta tabela.

## O que são e como se conferem

Um token é um nome para um valor visual: `color: var(--color-muted-foreground)` em vez de `color: #6b6a66`. Os nomes seguem os prefixos do Tailwind v4 (`--color-*`, `--text-*`, `--radius-*`) e o vocabulário de cores do shadcn/ui (`background`, `foreground`, `primary`, `muted-foreground`).

Há dois tipos:
- **Tokens CSS**, no `:root` do `capture-engine.html`. O bloco `html.dark` redefine alguns para o tema escuro.
- **Tokens JavaScript** (`const TOKEN_*`), na §6. Controlam a configuração, e o Quine troca-os na exportação.

Este documento é uma cópia verificada. O `validate.sh` (check 29) compara cada linha das tabelas com o código, nome a nome e valor a valor, nos dois temas. Um token novo entra aqui no mesmo commit.

## 1. Cores

A coluna «Escuro» mostra o valor no tema escuro (classe `dark` no `<html>`); «—» quer dizer que o valor não muda. O visualizador de imagem é escuro nos dois temas, por isso as suas cores não mudam.

| Token | Claro | Escuro | Uso |
|---|---|---|---|
| `--color-background` | `#f4f3f0` | `#121212` | Fundo geral. No claro, um branco quente, para a superfície dos painéis se destacar |
| `--color-card` | `#fff` | `#1e1e1e` | Painéis, cartões e modais |
| `--color-border` | `rgb(221 220 216 / 50.2%)` | `rgb(51 51 51 / 50.2%)` | Bordas suaves e linhas de separação |
| `--color-border-strong` | `#b5b3ae` | `#555` | Bordas com mais presença: estado ativo e hover |
| `--color-foreground` | `#1a1917` | `#e4e4e4` | Texto principal |
| `--color-muted-foreground` | `#6b6a66` | `#9a9a9a` | Texto secundário: datas, legendas, metadados |
| `--color-primary` | `#e86b2e` | — | Cor principal, escolhida no Visual Builder: botões e elementos ativos |
| `--color-primary-foreground` | `#fff` | — | Texto sobre a cor principal (botões, chips, contadores de bloco); calculado pelo YIQ quando o `TOKEN_ACCENT_FG_OVERRIDE` está vazio |
| `--color-brand` | `var(--color-primary)` | — | A cor principal em textos e ícones |
| `--color-ring` | `var(--color-primary)` | — | Contorno do foco do teclado |
| `--color-green-500` | `#22c55e` | — | Sucesso, estado «Gravado», confirmar a anotação |
| `--color-red-500` | `#ef4444` | — | Erro, remover, cancelar a anotação |
| `--color-yellow-500` | `#eab308` | — | Aviso |
| `--color-white` | `#fff` | — | Branco sobre preenchimentos de cor sólida (contador dos «Removidos», spinner, botões verdes e vermelhos, avisos de armazenamento) |
| `--color-black` | `#000` | — | Preto do quadrado de tons do seletor de cor, na bandeja «Outra cor» (D-0156) |
| `--color-banner-critical` | `#b91c1c` | — | Fundo dos avisos de armazenamento cheio e indisponível (D-0080): mais escuro que o `--color-red-500`, para o bloco de largura total |
| `--color-banner-close` | `rgb(255 255 255 / 25%)` | — | Fundo do ✕ desses avisos |
| `--color-green-600` | `#16a34a` | — | Hover do botão de exportar no modo de administrador |
| `--color-orange-500` | `#f97316` | — | Amostra laranja da paleta de anotação |
| `--color-blue-500` | `#3b82f6` | — | Amostra azul da paleta de anotação |
| `--color-purple-500` | `#a855f7` | — | Amostra roxa da paleta de anotação |
| `--color-brand-icon-light` | `#1a1a1a` | — | Ícone da marca no tema claro |
| `--color-annotation-black` | `#1a1a1a` | — | Amostra preta da paleta de anotação |
| `--color-annotation-white` | `#f0f0f0` | — | Amostra branca da paleta de anotação |
| `--color-viewer-control` | `#2a2a2a` | — | Botões da barra de anotação e botões secundários do visualizador (Download, Restaurar) |
| `--color-viewer-control-hover` | `#363636` | — | Hover desses botões |
| `--color-viewer-control-border-hover` | `#555` | — | Borda desses botões no hover |
| `--color-viewer-control-foreground` | `#e0e0e0` | — | Texto e ícones desses botões |
| `--color-viewer-active-foreground` | `#121212` | — | Texto do negrito e do itálico ativos |
| `--color-annotation-selection` | `rgb(232 107 46 / 32%)` | — | Seleção do texto no editor de texto da anotação |
| `--color-hover-overlay-dark` | `rgb(255 255 255 / 6%)` | — | No tema escuro: fundo de hover dos botões de ação e fundo dos botões secundários sem contorno, onde a sombra não aparece |
| `--color-hover-overlay` | `rgb(0 0 0 / 5%)` | — | Fundo de hover dos botões de ação, no tema claro |
| `--color-spinner-track` | `rgb(255 255 255 / 30%)` | — | Trilho do spinner |
| `--color-thumb-overlay` | `rgb(0 0 0 / 40%)` | — | Véu sobre a miniatura no hover |
| `--color-modal-backdrop` | `rgb(0 0 0 / 72%)` | — | Fundo atrás dos modais |
| `--color-settings-backdrop` | `rgb(0 0 0 / 85%)` | — | Fundo atrás do Visual Builder e do painel de exportação |
| `--color-offcanvas-backdrop` | `rgb(0 0 0 / 50%)` | — | Fundo atrás da barra lateral no telefone |
| `--color-viewer-backdrop` | `rgb(10 10 10 / 88%)` | — | Fundo do visualizador de imagem |
| `--color-viewer-surface` | `rgb(255 255 255 / 8%)` | — | Botão de fechar sobre o visualizador |
| `--color-viewer-close-hover` | `rgb(255 255 255 / 20%)` | — | Hover do botão de fechar do visualizador |
| `--color-viewer-border` | `rgb(255 255 255 / 10%)` | — | Borda da barra de ferramentas e da barra de zoom |
| `--color-viewer-control-border` | `#3f3f3f` | — | Borda desses botões e da bandeja das opções (`.ann-flyout`) |
| `--color-viewer-line` | `rgb(255 255 255 / 15%)` | — | Abas e bordas finas do visualizador |
| `--color-viewer-muted-foreground` | `rgb(255 255 255 / 60%)` | — | Dimensões da imagem, sobre o visualizador |
| `--color-viewer-mark` | `rgb(255 255 255 / 30%)` | — | Ponto acima de uma ferramenta que tem opções (D-0102) |
| `--color-viewer-tray` | `#1b1b1b` | — | Bandeja das opções de uma ferramenta (D-0102) |
| `--color-viewer-surface-hover` | `rgb(255 255 255 / 18%)` | — | Hover desses botões e das setas |
| `--color-viewer-floating` | `rgb(25 25 25 / 70%)` | — | Barra de zoom e setas, flutuando sobre a imagem |
| `--color-annotation-swatch-border` | `rgb(120 120 120 / 50%)` | — | Borda das amostras preta e branca da paleta |
| `--color-selected` | `color-mix(in srgb, var(--color-primary) 8%, transparent)` | — | Fundo de um item marcado, com a borda na cor principal (D-0128) |
| `--color-file-pdf` | `#b30b00` | — | Etiqueta de tipo: PDF (D-0128) |
| `--color-file-docx` | `#2b579a` | — | Etiqueta de tipo: Word |
| `--color-file-xlsx` | `#217346` | — | Etiqueta de tipo: Excel e CSV |
| `--color-file-pptx` | `#b7472a` | — | Etiqueta de tipo: PowerPoint |
| `--color-file-zip` | `#fbbf24` | — | Etiqueta de tipo: arquivos compactados |
| `--color-file-zip-foreground` | `#1a1917` | — | Letra da etiqueta dos arquivos compactados |
| `--color-file-text` | `#64748b` | — | Etiqueta de tipo: TXT, Markdown e HTML |
| `--color-archive-folder` | `var(--color-yellow-500)` | — | Ícone de pasta na lista de um arquivo compactado (D-0126) |

> [!NOTE]
> **Tema escuro e anti-FOUC.**
> O tema escuro liga-se só pela classe `dark` no `<html>`. Sem escolha guardada, o `initTheme` segue o sistema (`prefers-color-scheme`). Um script logo no início do `<body>` põe a classe antes da primeira pintura, para não haver um flash branco.

## 2. Cores literais, fora dos tokens

Algumas cores ficam escritas como valor no `capture-engine.html` e no `index.html`, porque um token não pode ser usado ali. Esta tabela lista todas, para uma auditoria não as tratar como descuido.

| Cor | Onde | Motivo |
|---|---|---|
| `#ef4444` `#f97316` `#eab308` `#22c55e` `#3b82f6` `#a855f7` `#1a1a1a` `#f0f0f0` | Atributos `data-color` das 8 amostras da paleta de anotação, `let annCurrentColor` e `annColorBy` | São dados: o valor fica gravado no objeto da anotação, no IndexedDB, e redesenha a forma depois. A cor que se vê em cada amostra vem dos tokens da §1. |
| `#ef4444` `#22c55e` `#eab308` | Estilos do `SysLogger` (`console.log('%c…')`) | O console do DevTools não lê as custom properties da página. |
| `#ffffff` | `fillStyle` e `strokeStyle` do canvas: o fundo branco do JPEG no PDF e as alças da anotação | O canvas não lê custom properties. |
| `#1a1917` `#ffffff` | Cálculo YIQ do texto sobre a cor principal, e o valor inicial dos campos `#cfg-fg-hex` e `#cfg-cor-fg` | O resultado depende da cor que o administrador escolhe. Os campos mostram o valor antes de qualquer script rodar. |
| `#e86b2e` | O `TOKEN_MAIN_COLOR`, os `value=` de `#cfg-cor-hex` e `#cfg-cor-principal`, e o valor de reserva do `getComputedStyle` | É o valor padrão do próprio token (§6): um `var()` aqui seria circular. |
| `#35a800` `#ffd82b` | `stop-color` do gradiente `#ce_accent`, no logotipo SVG | Um `stop-color` com custom property não funciona da mesma forma em todos os navegadores. |
| `#000000` | `<meta name="theme-color">` e `<meta name="msapplication-TileColor">` | O navegador lê as metatags antes de o CSS existir. |
| `#fdfdfc` `#121212` | `--color-background` do `index.html`, claro e escuro | O `index.html` redireciona antes de a aplicação existir e tem o seu próprio `:root`. |

> **Regra para quem edita:** acrescentar uma cor literal nova **fora** desta tabela é violação do contrato. Se for genuinamente necessária, acrescente aqui a linha com a justificação — caso contrário, use um token.

> **Como verificar que esta tabela continua completa.** Uma versão anterior listava 5 categorias, e o código tinha 9. A lacuna sobreviveu a duas auditorias, porque ninguém comparou as duas listas com um comando. O comando abaixo faz essa comparação e deve devolver vazio:

```bash
CODIGO=$(grep -hvE '^[[:space:]]*--[a-z0-9-]+[[:space:]]*:' capture-engine.html index.html | grep -oE '#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b' | tr 'A-F' 'a-f' | sort -u)
DOC=$(sed -n '/^## 2\. Cores literais/,/^## 3\./p' design-tokens.md | grep -oE '#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b' | tr 'A-F' 'a-f' | sort -u)
echo "no codigo e nao declaradas:"; comm -23 <(echo "$CODIGO") <(echo "$DOC")
echo "declaradas e ja sem uso:";    comm -13 <(echo "$CODIGO") <(echo "$DOC")
```

> **As duas direções importam.** A primeira detecta cor nova não declarada; a segunda detecta entradas que ficaram para
> trás quando o código mudou — e sem ela a tabela apodrece sem ninguém dar por isso. Ambas devem devolver vazio.
> O `index.html` entra no âmbito desde a D70: é o outro arquivo distribuído, e tem cores próprias.
>
> O `grep -v` precisa filtrar **linhas**, antes de extrair as cores — as declarações de custom property (uma linha do tipo `--color-background: <hex>`) definem a paleta e não são exceções. Filtrar depois da extração não faz nada, porque nessa altura já não há contexto de linha para casar.
>
> ⚠️ **Não escrever cores literais nesta seção fora da tabela** (D70). O comando abaixo lê a seção inteira: um hex citado numa nota explicativa passa a contar como exceção declarada. Foi assim que uma cor do modo escuro — que só existia no texto a explicar o comando, e nunca no código — ficou declarada como exceção. **Esta própria nota já reincidiu uma vez**: escrevê-la citando o hex voltava a poluir o comando. Se precisar de referir uma cor aqui, descreva-a; não a escreva.
>
> Qualquer linha devolvida é uma cor no código que esta seção não declara.

---

## 3. Tipografia, espaço e forma

Tamanhos e espaços em `rem` (D-0082): com a letra padrão do navegador (16 px), cada valor dá o mesmo pixel que dava em `px`.

### Tipografia

| Token | Valor | Uso |
|---|---|---|
| `--font-sans` | `'Segoe UI', arial, sans-serif` | Fonte de toda a interface: a do sistema, sem fontes externas |
| `--text-micro` | `0.625rem` | Rodapé e botão de remover da miniatura (10px) |
| `--text-caption` | `0.6875rem` | Contadores, datas, legendas e o título da barra «Removidos» (11px) |
| `--text-xs` | `0.75rem` | Títulos das seções e dos blocos, chips, botões «Adicionar», nomes no histórico e tooltip (12px) |
| `--text-code` | `calc(12.5rem / 16)` | Visualizador de texto, em fonte monoespaçada (12.5px) |
| `--text-control` | `0.8125rem` | Botões principais e campos; chips no telefone (13px) |
| `--text-sm` | `0.875rem` | Texto geral (14px) |
| `--text-subtitle` | `0.9375rem` | Título do aviso de documento binário (15px) |
| `--text-base` | `1rem` | Títulos de modal e campos no telefone (16px) |
| `--text-lg` | `1.125rem` | Nome da ferramenta em telas baixas (18px) |
| `--text-xl` | `1.25rem` | Nome da ferramenta e títulos do Visual Builder (20px) |

### Espaçamento

| Token | Valor | Uso |
|---|---|---|
| `--spacing` | `0.25rem` | Base dos espaços: `calc(var(--spacing) * n)` |

### Raios

| Token | Valor | Uso |
|---|---|---|
| `--radius-sm` | `0.25rem` | A lixeira e o restaurar das miniaturas, a lixeira e o nome do documento, a etiqueta do tamanho, a linha do Histórico e o balão (4px) |
| `--radius-md` | `0.375rem` | A moldura da miniatura, o item arrastado, o espaço onde ele cai, os campos e o aviso do rodapé (6px) |
| `--radius-lg` | `0.5rem` | Botões, chips, abas, painéis, linhas de documento e caixas (8px) |
| `--radius-xl` | `0.75rem` | Modais e diálogos (12px) |
| `--radius-circle` | `50%` | Elementos redondos: botões de ícone, amostras, spinner |
| `--radius-full` | `calc(infinity * 1px)` | Pílulas: contadores e o interruptor |

### Sombras

| Token | Valor | Uso |
|---|---|---|
| `--shadow-card` | `0 2px 8px rgb(0 0 0 / 2%)` | Painéis e barras |
| `--shadow-button` | `0 1px 3px rgb(0 0 0 / 12%), 0 1px 2px rgb(0 0 0 / 6%)` | Botões secundários sem contorno («Adicionar imagem» e «Adicionar documento», as duas escolhas do modo ZIP), no tema claro |
| `--shadow-control` | `0 2px 4px rgb(0 0 0 / 20%)` | Botões pequenos sobre a miniatura e o interruptor |
| `--shadow-swatch` | `0 2px 4px rgb(0 0 0 / 15%)` | Amostras de cor do Visual Builder |
| `--shadow-swatch-active` | `0 0 0 1px rgb(0 0 0 / 40%)` | Amostra ativa da paleta de anotação |
| `--shadow-input-focus` | `0 0 0 1px var(--color-primary)` | Campos com foco |
| `--shadow-dragging` | `0 12px 30px rgb(0 0 0 / 35%)` | Item em arrasto e a bandeja das opções do editor (`.ann-flyout`) |
| `--shadow-sidebar` | `0 12px 48px rgb(0 0 0 / 30%)` | Barra lateral no telefone |
| `--shadow-settings` | `0 10px 25px rgb(0 0 0 / 20%)` | Visual Builder e painel de exportação |
| `--shadow-modal` | `0 24px 64px rgb(0 0 0 / 45%)` | Modais |
| `--shadow-viewer-zoom` | `0 4px 12px rgb(0 0 0 / 15%)` | Barra de zoom do visualizador |

### Foco e medidas de componente

| Token | Valor | Uso |
|---|---|---|
| `--focus-width` | `3px` | Espessura do contorno do foco |
| `--focus-offset` | `2px` | Afastamento do contorno do foco |
| `--opacity-dimmed` | `0.3` | Botões da barra do editor, título, zoom e ✕ da anotação apagados durante o aviso de anotações por salvar |
| `--filter-dimmed` | `brightness(35%)` | Foto e anotações escurecidas durante o mesmo aviso; um filtro, e não uma opacidade, para não mostrar o app por trás |
| `--top-bar-h` | `64px` | Altura da barra do topo |
| `--thumb-size` | `140px` | Lado da caixa de miniatura |

Os elementos `.t-item` e `.t-label` têm `border-radius: 0`: a miniatura fica com cantos retos, e só a moldura `.t-wrap` é arredondada.

### Superfícies

Um componente novo usa uma destas superfícies, com o seu fundo, borda, raio e sombra. Uma superfície nova pede a decisão do dono. Há duas famílias: as claras, que seguem o tema, e as escuras do visualizador, iguais nos dois temas.

| Superfície | Seletor | Fundo | Borda | Raio | Sombra |
|---|---|---|---|---|---|
| Painel (Imagens, Documentos, barra lateral, Histórico, «Removidos») | `.ev-block`, `#left-sidebar`, `#sidebar`, `#trash-bar` | `--color-card` | 1 px `--color-border` | `--radius-lg` | `--shadow-card` |
| Linha de documento | `.d-item` | `--color-card`; no hover, `--color-background` | 1 px transparente | `--radius-lg` | nenhuma |
| Linha do Histórico | `.sb-sess-item` | no hover e ativa, `--color-background` | nenhuma | `--radius-sm` | nenhuma |
| Página do visualizador de documentos | `.doc-page`, dentro do visualizador | `--color-card` | nenhuma | `--radius-lg` | nenhuma |
| Visual Builder e exportação | `.sb-modal` | `--color-card` | nenhuma | `--radius-xl` | `--shadow-settings` |
| Histórico no telefone | `#sidebar`, até 900 px | `--color-card` | 1 px `--color-border` | `--radius-xl` | `--shadow-sidebar` |
| Visualizador (imagem e documento) | `#img-modal-overlay .modal-box`, `#text-modal-overlay .modal-box` | transparente, sobre `--color-viewer-backdrop` | nenhuma | — | nenhuma |
| Menu do clique direito e o submenu | `.ctx-menu`, `.ctx-sub` | `--color-card`; item no hover, `--color-background` | 1 px `--color-border` | `--radius-lg` | `--shadow-settings` |
| Bandeja das opções do editor | `.ann-flyout` | `--color-viewer-tray` | 1 px `--color-viewer-control-border` | `--radius-xl` | `--shadow-dragging` |
| Barra de zoom | `#zoom-ui` | `--color-viewer-floating`, com desfoque | 1 px `--color-viewer-border` | `--radius-lg` | `--shadow-viewer-zoom` |
| Faixa de armazenamento | `.ce-banner` | `--color-banner-critical` | nenhuma | nenhum; largura total, no topo | nenhuma |
| Aviso do rodapé | `.ce-notice` | `--color-foreground`, letra `--color-background` | nenhuma | `--radius-md` | `--shadow-modal` |
| Balão (tooltip) | `.ce-tip` | `--color-foreground`, letra `--color-card`; no visualizador, `--color-white` | nenhuma | `--radius-sm` | `--shadow-control` |

---

## 4. Camadas (z-index)

Todo `z-index` usa um token `--z-*`. Os globais seguem a escala do Bootstrap; os de dentro de um componente são números pequenos, que só competem no seu próprio contexto de empilhamento.

| Token | Valor | Onde / propósito | Contexto |
|---|---|---|---|
| `--z-raised` | `1` | Empilhamento local: placeholders de arrasto, pequenos overlays | local |
| `--z-dragging` | `2` | Item a ser arrastado (`.t-item/.d-item.dragging`) acima dos vizinhos | local |
| `--z-viewer-controls` | `3` | Barra de zoom (`#zoom-ui`) e setas (`#img-nav-prev/next`) sobre a imagem | dentro do modal |
| `--z-viewer-text` | `4` | `#ann-text-overlay` sobre o canvas | dentro do modal |
| `--z-viewer-delete` | `5` | Botão `✕` acima do overlay de texto | dentro do modal |
| `--z-offcanvas-backdrop` | `1040` | `#sb-mobile-overlay` (fundo escurecido) | telefone |
| `--z-offcanvas` | `1045` | `#sidebar` no telefone, acima do seu fundo | telefone |
| `--z-popover` | `1070` | Menu do clique direito e o submenu, acima dos modais (D-0129, D-0131) | global |
| `--z-modal` | `1055` | `.modal-overlay`, `.sb-overlay` | global |
| `--z-toast` | `1090` | Avisos de quota e de armazenamento, **acima dos modais** de propósito, para um aviso crítico nunca ficar escondido | global |

**Regra:** um valor novo entra nesta tabela e no `validate.sh` (check 23), que falha com um valor não documentado ou com um `z-index` literal.

---

## 5. Movimento

As durações seguem o IBM Carbon, e as curvas, o Tailwind. Uma animação longa de um componente tem token próprio.

| Token | Valor |
|---|---|
| `--duration-fast-02` | `110ms` |
| `--duration-moderate-01` | `150ms` |
| `--duration-moderate-02` | `240ms` |
| `--duration-slow-01` | `400ms` |
| `--duration-slow-02` | `700ms` |
| `--duration-spinner` | `650ms` |
| `--duration-ann-alert` | `400ms` |
| `--duration-admin-pulse` | `1.2s` |
| `--duration-status-pulse` | `3s` |
| `--ease-out` | `cubic-bezier(0, 0, 0.2, 1)` |
| `--ease-in-out` | `cubic-bezier(0.4, 0, 0.2, 1)` |

| Animação | O que faz | Duração | Onde é usada |
|---|---|---|---|
| `spin` | Rotação contínua | `--duration-spinner` | Spinner nos botões PDF e ZIP durante o processamento |
| `fade-in` | Entrada com opacidade 0→1 | `--duration-moderate-02` | Novas miniaturas e documentos |
| `modal-in` | Escala `0.96→1` e opacidade | `--duration-moderate-02` | Entrada de todos os modais |
| `fade-in-tab` | Opacidade | `--duration-moderate-02` | Troca de abas do Visual Builder |

---

## 6. Tokens JavaScript (fonte única de verdade)

Estes tokens estão declarados como `const` no topo do IIFE do JavaScript. São a **fonte de verdade** para a configuração: o Visual Builder lê estes valores ao abrir, e o Quine Engine os substitui ao exportar.

| Token | Tipo | Valor padrão | Alterável no VB | Aba VB |
|---|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture '` | ✅ | Interface → «Texto inicial» |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | ✅ | Interface → «Texto em destaque» |
| `TOKEN_TITLE_END` | `string` | `''` | ✅ | Interface → «Texto final» (terceira parte do título; espaços manuais) |
| `TOKEN_TITLE_START_COLOR` | `string` | `''` | ✅ | Interface → amostra de cor do «Texto inicial» (vazio = herda cor do texto) |
| `TOKEN_TITLE_ACCENT_COLOR` | `string` | `''` | ✅ | Interface → amostra de cor do «Texto em destaque» (vazio = herda a cor principal) |
| `TOKEN_TITLE_END_COLOR` | `string` | `''` | ✅ | Interface → amostra de cor do «Texto final» (vazio = herda cor do texto) |
| `TOKEN_MAIN_COLOR` | `string` | `'#e86b2e'` | ✅ | Interface → seletor da «Cor principal» |
| `TOKEN_ACCENT_FG_OVERRIDE` | `string` | `''` | ✅ | Interface → seletor da «Cor do texto sobre destaque» |
| `TOKEN_FOOTER_TEXT` | `string` | `'© {YEAR} • CAPTURE ENGINE • DIOGO CARVALHO'` | ✅ | Interface → «Texto do rodapé» |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | ✅ | Histórico → «Primeiro campo», interruptor |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | ✅ | Histórico → «Segundo campo», interruptor |
| `TOKEN_USER_LABEL` | `string` | `''` | ✅ | Histórico → «Primeiro campo», rótulo |
| `TOKEN_EQUIP_LABEL` | `string` | `''` | ✅ | Histórico → «Segundo campo», rótulo |
| `TOKEN_ID_UPPERCASE` | `bool` | `true` | ✅ | Histórico → «Maiúsculas», interruptor |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | ✅ | Captura → "Qualidade do PDF" |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | ✅ | Captura → dimensão máxima |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | ✅ | Manutenção → «Limpeza automática» (8h, 24h, 48h, Nunca). O valor 0 desliga a limpeza; ver a nota no README §7.4 |
| `TOKEN_DEBUG_MODE` | `bool` | `true` | ❌ | Sem UI — desativado automaticamente em Export User |

### Notas sobre tokens específicos

**`TOKEN_TITLE_END` (adicionado na V23):**
Terceira parte do título da aplicação. Renderizado como `<span id="ui-title-end">` com `font-weight: 600`. A cor é controlada por `TOKEN_TITLE_END_COLOR` (vazio = herda cor do texto). Espaços entre partes do título são manuais — incluir no valor do token.

**`TOKEN_ACCENT_FG_OVERRIDE` (vazio = automático):**
Quando vazio (`''`), o motor calcula automaticamente se o texto sobre a cor principal deve ser branco ou preto. O algoritmo usado é **YIQ** — uma ponderação perceptual dos canais RGB calibrada para a sensibilidade do olho humano:

```
yiq = (R × 299 + G × 587 + B × 114) / 1000
yiq ≥ 128  →  texto escuro (#1a1917)
yiq < 128  →  texto branco (#ffffff)
```

O limiar 128 divide a escala 0–255 ao meio. Em cores claras, o texto automático é escuro, e o contraste pode ficar abaixo do WCAG AA (4.5:1 para texto normal). Exemplos: amarelo `#eab308` (yiq ≈ 176), ciano `#06b6d4` (yiq ≈ 133), laranja `#f97316` (yiq ≈ 145). Nestes casos, preencher `TOKEN_ACCENT_FG_OVERRIDE` com a cor desejada. Preencher apenas se o cálculo automático não produzir o contraste desejado.

**`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL` (vazio = padrão visual):**
Um valor vazio significa "usar o padrão visual" (`Quem` / `O que`). O Visual Builder mostra estes termos no próprio campo. Se o administrador não os edita (`_vbLabelDirty`), o export mantém o token em `''`. Exportar sem editar estes campos preserva a flexibilidade — o motor usa o padrão correto conforme o contexto. A flag `_vbLabelDirty` controla se o admin editou ativamente estes campos.

**`TOKEN_JPEG_QUALITY` (0.70 a 0.95):**
Afeta apenas a geração do PDF — os originais ficam na sessão no formato em que foram capturados. Valores abaixo de 0.70 produzem artefatos JPEG visíveis em capturas de tela com texto. Valores acima de 0.95 aumentam o tamanho do PDF sem benefício visual perceptível.

> **Clamp automático no Visual Builder:** O VB aplica `Math.min(0.95, Math.max(0.70, rawJq / 100))` ao valor digitado — valores fora do intervalo são silenciosamente corrigidos para o limite mais próximo. A edição manual direta do token no código-fonte não tem este guard. Comportamento com valores fora de `[0.70, 0.95]` editados diretamente: o valor é passado sem clamp para `canvas.toBlob(type, quality)`. Pelo padrão HTML, um valor fora de `[0, 1]` faz o navegador usar a qualidade padrão (em geral ~0.92). Um valor em `[0, 1]`, mas fora de `[0.70, 0.95]`, é aceito sem erro e produz os artefatos ou o desperdício de espaço descritos acima.

**`TOKEN_MAX_IMG_DIMENSION` (0 = sem limite):**
Afeta **apenas a geração do PDF**, tal como `TOKEN_JPEG_QUALITY`. Se definido (ex: `1920`), qualquer imagem com dimensão superior é reduzida ao gerar o PDF, preservando a proporção. É lido num único ponto do código — `imgToJPEG()`, chamada exclusivamente por `generatePDF()`.

> ⚠️ **Importante — não reduz o armazenamento:** `captureImg()` grava sempre o blob **original**, sem redimensionar. Este token não diminui o consumo de quota do IndexedDB e não serve como mitigação para esgotamento de armazenamento. Para isso, o caminho é exportar (PDF ou ZIP) e apagar sessões antigas.
>
> Até a V26, esta seção afirmava que a imagem era «redimensionada antes de ser armazenada», e o `README §9` recomendava o token como forma de prevenir perda de dados por quota. Ambas as afirmações eram falsas: um administrador que o configurasse para esse fim não obtinha redução nenhuma, e continuava exposto à perda que o conselho pretendia evitar. Corrigiu-se a documentação, e não o código. Redimensionar na captura destruiria o original, e numa ferramenta de coleta de provas isso é perda de evidência.

> **Comportamento sem-op:** Se a imagem já tiver ambas as dimensões iguais ou inferiores ao limite configurado, nenhum redimensionamento ocorre — a imagem entra no PDF tal como está.

### Como o Quine usa estes tokens

O Quine substitui valores por regex no código-fonte:
```js
// O Quine procura a declaração; o valor aceita aspas escapadas (\'), como no exportFile:
html.replace(/const TOKEN_MAIN_COLOR\s*=\s*'(?:[^'\\]|\\.)*'/, "const TOKEN_MAIN_COLOR = '#ff6600'")
```

O padrão do valor precisa aceitar escapes. Um padrão que para no primeiro apóstrofo funciona na primeira exportação e corrompe a seguinte (ver `AGENTS.md` §1.3).

**Por isso, o formato exato deve seguir a sintaxe:**
- `const` (não `let` ou `var`)
- `TOKEN_NOME` *(placeholder — representa qualquer nome real de token, ex: `TOKEN_MAIN_COLOR`)*
- `=` (espaços à volta são suportados e recomendados para legibilidade)
- `'valor'` (aspas simples, não duplas)

---

## 7. Anatomia dos componentes

### Barra do topo

```
┌────────────────────────────────────────────────────────────────┐
│  [⬚] Capture Engine                 [⚙] [💾] [↻] [🕒] [🌙]   │
│   ↑ logo + brand name                 ↑ tb-actions             │
└────────────────────────────────────────────────────────────────┘
  height: 64px (--top-bar-h)
  [⚙] [💾]: ADMIN_BUTTONS, removidos em exports User
  [↻] «Atualizar»; [🕒] «Histórico», só até 900 px de largura; [🌙] tema
```

### Layout principal

```
┌──────────────────────────────────────────────────────────────────────┐
│ BARRA DE TOPO (64px)                                                  │
├──────────────┬────────────────────────────┬──────────────────┬───────┤
│ LEFT SIDEBAR │  PAINEL IMAGENS            │  PAINEL DOCS     │ SB    │
│ IDENTIFICAÇÃO│  [▣ IMAGENS ] [count]      │  [▤ DOCUMENTOS]  │  ‹    │
│ [Quem     ]  │  ┌──────────────────────┐  │  ┌────────────┐  │  🕒   │
│ [O que    ]  │  │  drop zone / grid    │  │  │ doc list   │  │       │
│ LAYOUT PDF   │  │  (thumbnails 140px)  │  │  └────────────┘  │       │
│ [Auto][▭][▯] │  └──────────────────────┘  │                  │       │
│ CAPTURA      │                            │                  │       │
│ [Adicionar…] │                            │                  │       │
│ EXPORTAR     │                            │                  │       │
│ [.pdf] [.zip]│                            │                  │       │
│ ● Gravado    │                            │                  │       │
├──────────────┴────────────────────────────┴──────────────────┴───────┤
│ TRASH BAR  [🗑 REMOVIDOS  3]                              [⌃]        │
├───────────────────────────────────────────────────────────────────────┤
│ RODAPÉ  © 2026 • CAPTURE ENGINE • DIOGO CARVALHO     (opacity: 0.5)  │
└───────────────────────────────────────────────────────────────────────┘
```

### Modal de imagem (`#img-modal-overlay`)

```
┌──────────────────────────────────────────────────────────┐
│        imagem-1.png  1920×1080 · 245,0 KB           [×]  │
│   ↑ .modal-title (16px) e .modal-info (11px), na   ↑ 32px│
│     mesma linha; o nome corta antes da informação        │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│ ‹│                    [Imagem]                        │› │  ← setas, com 2 imagens ou mais
│  │                               [ − ] 100% [ + ]    │  │  ← #zoom-ui, só com zoom > 100%
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│        [Restaurar]  [Editar]  [Download]                 │
│         ↑ só nos «Removidos», no lugar do Editar         │
└──────────────────────────────────────────────────────────┘
```

*A barra `#zoom-ui` usa um fundo translúcido: `--color-viewer-floating` e `backdrop-filter: blur(10px)`. Flutua sobre a imagem com texto sempre a `#fff` independentemente do conteúdo por baixo.*

*O fechamento por clique no backdrop está bloqueado quando zoom > 100 % — evita fechamentos acidentais durante o panning.*

### Modal de documento (`#text-modal-overlay`)

```
┌──────────────────────────────────────────────────────────┐
│                 relatorio.txt  2,4 KB           [×]  │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│  │ Texto: área de texto com fonte monoespaçada        │  │  ← modo texto
│  │ (Consolas, Monaco, monospace)                      │  │    (TXT, CSV, JSON...)
│  └────────────────────────────────────────────────────┘  │
│
│  OU, para um PDF:                                        │
│
│  ┌────────────────────────────────────────────────────┐  │
│  │ iframe com blob: (o leitor do próprio navegador)   │  │  ← .view-pdf
│  └────────────────────────────────────────────────────┘  │
│
│  OU, para os outros binários (DOCX, XLSX, etc.):         │
│
│  ┌────────────────────────────────────────────────────┐  │
│  │           [ícone]  DOCX                            │  │  ← modo binário
│  │   Faça download para visualizar o documento        │  │    (textarea oculta)
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  [Restaurar]  [Copiar texto]  [Download]                  │
│   ↑ só nos «Removidos»  ↑ oculto em modo binário         │
└──────────────────────────────────────────────────────────┘
```

**Como o motor decide entre modo texto e modo binário:**
- MIME type começa com `text/` → modo texto (visualizável inline)
- MIME type é `application/json`, `application/xml`, etc. → modo texto
- Extensão `.pdf` ou MIME `application/pdf` → modo binário, com o PDF num `iframe` de endereço `blob:` (D-0130)
- Qualquer outro MIME type → modo binário (download apenas)

---

## 8. Tipografia: tabela de referência

| Elemento | Tamanho | Peso | Notas |
|---|---|---|---|
| Nome da marca (topo) | `var(--text-xl)` (20px) | `600` | Logo principal |
| Títulos das seções `.sb-section-title` | `var(--text-xs)` (12px) | `600` | Maiúsculas, `letter-spacing: 0.6px`, ícone de 14px |
| Texto geral | `var(--text-sm)` (14px) | `400` | Body text |
| Botões `.btn-send` | `var(--text-control)` (13px) | `600` | Altura `36px` |
| Ícones em botões | `14px` | — | `stroke-width: 2` |
| Ícones de cabeçalho `.blk-hdr svg` | `16px` | — | |
| Títulos de bloco `.blk-hdr-title` | `var(--text-xs)` (12px) | `600` | Maiúsculas |
| Chips `.chip-label` | `var(--text-xs)` (12px) | `500`; `600` no escolhido | O escolhido tem fundo `--color-primary` |
| Badges `.count-badge`, `#trash-badge` | `var(--text-caption)` (11px) | `700` | |
| Item de histórico — nome | `var(--text-xs)` (12px) | `400` | |
| Item de histórico — data | `var(--text-caption)` (11px) | `400` | `--color-muted-foreground` |
| Título de modal `.modal-title` | `var(--text-base)` (16px) | `600` | Centrado horizontalmente |
| Campo de documento `.d-input` | `var(--text-control)` (13px) | `400` | **Sem negrito** — não é um título, é um nome de arquivo |
| Legenda de imagem `.t-label` | `var(--text-caption)` (11px) | `400` | **Sem negrito** — discreta, não distrai da imagem |

---

## 9. Botões nos modais

| Onde | Ação | Estilo | Cor | Quando aparece |
|---|---|---|---|---|
| Visualizador de imagem | **Editar** | `.btn-send`, cheio | `var(--color-primary)` + `var(--color-primary-foreground)` | Imagem ativa |
| Visualizador de imagem | **Download** e **Restaurar** | `.btn-viewer`, a regra das ferramentas do editor (D-0098) | `--color-viewer-control`, borda `--color-viewer-control-border`; no hover, `--color-viewer-control-hover` | Download sempre; Restaurar só nos «Removidos» |
| Editor | **Aplicar alterações** | Cheio | `var(--color-green-500)` + branco | No modo de anotação |
| Editor | **Descartar alterações** | Cheio | `var(--color-red-500)` + branco | No modo de anotação |
| Visualizador de documento | **Restaurar**, **Copiar texto** e **Download** | `.btn-viewer`, como no visualizador de imagem (D-0123) | `--color-viewer-control`, borda `--color-viewer-control-border` | Restaurar só nos «Removidos»; Copiar texto só em documentos de texto; Download sempre |

O Editar, o Download e o Restaurar do visualizador têm a mesma largura, 120 px.

---

## 10. Responsividade

A interface tem dois cortes principais de largura, em `rem` (D-0082). Há ainda `width <= 48rem` (768px) e `(height <= 43.75rem) and (width >= 56.3125rem)`, para telas baixas: um modo compacto da barra lateral, só abaixo de 700px de altura. Numa tela de 1920 × 1080, o Windows a 125 % deixa cerca de 1536 × 777, e a barra fica no tamanho normal. A 150 % (cerca de 1280 × 633), ela comprime: cerca de 14px entre as seções e textos de 12px.

O corte `height <= 50rem` (800px) diminui a dica das zonas vazias: o ícone passa de 48px a 40px e o texto de `--text-sm` a `--text-control`. Não é um modo compacto: não muda nada da barra lateral.

### `width <= 56.25rem` (900px) — tablets e telefones na horizontal

- Layout muda de horizontal para vertical (painéis empilhados)
- A sidebar de histórico (desktop: coluna lateral direita) transforma-se em um **modal centralizado** em vez de drawer lateral — aumenta a área de toque e facilita uso com o polegar
- O botão de histórico fica na barra de topo
- `pointer-events: auto` e `touch-action: manipulation` garantem que 100 % da superfície de cada card responde a toque

### `width <= 30rem` (480px) — telefones na vertical

- Padding e margens reduzidos para maximizar área útil
- Todos os elementos comprimem proporcionalmente

### De `width >= 102.5rem` (1640px) a `width >= 140rem` (2240px): telas grandes

Nas telas grandes, a interface inteira cresce junto, com o `zoom` do `html`: os textos, os ícones, os botões e a barra lateral. O aumento é uma rampa de 16 degraus de 40px: 1 até 1600px, 1,125 a 1920px e 1,25 a partir de 2240px. Com degraus finos, cada passo de zoom do navegador deixa a interface maior.

| Token | Valor | Uso |
|---|---|---|
| `--app-zoom` | `1` | Escala da interface: sobe 1/64 a cada 40px, de 1640px a 2240px, até `1.25`. As medidas em `vw` e `vh` das janelas dividem-se por ela, para caberem na tela |

**Body Scroll Lock:** Quando o modal de histórico abre no telefone, `document.body.style.overflow = 'hidden'` previne que o conteúdo de fundo role. Ao fechar, o scroll é restaurado.

---

## 11. Bordas, sombras e preenchimentos

Uma das decisões de design mais impactantes foi padronizar *quando* as bordas aparecem e desaparecem. Bordas que surgem apenas no hover criam layout shift (o elemento "salta" 1px quando o cursor passa).

### Botões «Adicionar imagem», «Adicionar documento» e as duas escolhas do modo ZIP (`.btn-capture`, `.btn-zip-cta`)

| Estado | Visual |
|---|---|
| **Repouso, tema claro** | Sem borda; fundo `--color-card` e sombra `--shadow-button` |
| **Repouso, tema escuro** | Sem borda nem sombra; fundo `--color-hover-overlay-dark`, 6 % mais claro que o painel |
| **Hover** | Contorno fino na cor principal (`--shadow-input-focus`) e texto `--color-foreground` |

A sombra e o contorno não ocupam espaço, por isso o botão não muda de tamanho no hover.

### Chips do «Layout PDF» (Auto, Horizontal, Vertical)

| Estado | Visual |
|---|---|
| **Escolhido** | Fundo `--color-primary`, texto `--color-primary-foreground`, peso 600 |
| **Não escolhido** | Sem borda nem fundo; texto `--color-muted-foreground`, e `--color-foreground` no hover |

«Horizontal» e «Vertical» são ícones de página, com o nome no tooltip; «Auto» é escrito.


---

## 12. Motor de anotação: constantes e estado

### Constantes de traço

| Constante | Valor | Descrição |
|---|---|---|
| `ANN_SIZES` | `[1, 2, 4, 6, 8, 12]` | Espessuras de linha disponíveis (px, coordenadas canvas). Escala de 6 níveis (do mais fino ao mais grosso). |
| `ANN_HL_SIZES` | `[8, 12, 18, 26, 36, 48]` | Larguras do marca-texto (px canvas), nos mesmos seis passos |
| `ANN_TEXT_SIZES` | `[12, 14, 16, 18, 20, 24, 28, 32, 40, 48, 56, 64, 80, 96, 128, 160, 200, 256, 320, 400]` | Os 20 passos do − e do + no texto (px canvas) |
| `ANN_TEXT_MIN` / `ANN_TEXT_MAX` | `8` / `400` | Limites do tamanho do texto ao arrastar as alças |
| `ANN_TEXT_LINE_RATIO` | `1.3` | Line-height ratio do texto. Constante **única** usada no `line-height` do `<textarea>` editor **e** no render do canvas (`annDrawShape`) — garante que o texto multilinha achatado é igual ao que se vê a escrever (WYSIWYG) |

### Variáveis de estado da anotação

| Variável | Padrão | Descrição |
|---|---|---|
| `annTool` | `'rect'` (declarado) | Ferramenta ativa: `select` / `rect` / `circle` / `arrow` / `free` / `highlight` / `text` / `crop`. Ao abrir o editor: `select` com anotações, `free` sem elas |
| `annSizeIdx` | `2` (4px) | Índice em `ANN_SIZES` (ou `ANN_HL_SIZES` no marca-texto) da ferramenta atual |
| `annSizeByTool` | `{ free: 2, rect: 2, circle: 2, arrow: 2, highlight: 1 }` | O passo guardado de cada ferramenta (4 px nas linhas, 12 px no marca-texto) |
| `annColorBy` | `{ hl: '#eab308', line: '#ef4444' }` | A cor do marca-texto e a das outras ferramentas |
| `annFill` | `{ rect: false, circle: false, highlight: false }` | A segunda opção de cada ferramenta, «Preenchido» ou «Sólido»; chaves `fill-rect`, `fill-circle` e `hl-solid` (`ANN_OPT2`) |
| `annTextSize` | `24` | Tamanho do texto (px), reposto a 24 a cada abertura do editor |
| `annTextBold` | `true` | Negrito ativo na ferramenta texto |
| `annTextItalic` | `false` | Itálico ativo na ferramenta texto |
| `annEditingTextIdx` | `-1` | Índice em `annHistory` do texto em reedição; `-1` = novo texto |
| `annTextClickTimer` | `null` | Timer 220ms para distinguir single-click de dblclick |
| `annSmoothLast` | `null` | Último ponto EMA no desenho livre (α=0.35); reset em activate/deactivate/mouseup |

### Tokens CSS do motor de reordenação

Estas variáveis CSS controlam a aparência do placeholder de arrasto (o espaço vazio que aparece durante a reordenação de itens). **Requerem edição direta do `capture-engine.html`** — não são expostas no Visual Builder e não viajam com o Export (o Quine não substitui variáveis CSS, apenas tokens `TOKEN_*`).

| Token CSS | Valor padrão (via `color-mix`) | Descrição |
|---|---|---|
| `--color-drop-placeholder` | `color-mix(in srgb, var(--color-foreground) 5%, transparent)` | Cor de fundo do placeholder de arrasto — área muito sutil que indica onde o item irá cair. Alterável apenas por desenvolvedor com acesso ao código-fonte. |
| `--color-drop-placeholder-border` | `color-mix(in srgb, var(--color-foreground) 8%, transparent)` | Cor da borda do placeholder de arrasto. Ligeiramente mais visível que o fundo para delimitar a área. Alterável apenas por desenvolvedor com acesso ao código-fonte. |

### Formato das entradas em `annHistory`

Cada entrada é um objeto com pelo menos `{type, color, lw}` e campos adicionais por tipo:

| `type` | Campos obrigatórios | Notas |
|---|---|---|
| `rect` | `x1, y1, x2, y2`; `fill: true` quando «Preenchido» | Coordenadas dos dois cantos opostos |
| `circle` | `x1, y1, x2, y2`; `fill: true` quando «Preenchido» | Bounding box da elipse |
| `arrow` | `x1, y1, x2, y2` | Origem → destino da seta |
| `free` | `pts: [{x,y}]`, `closed` (sempre `false` desde a V23); no marca-texto, `hl`: `'soft'` (Translúcido, 40 %) ou `'solid'` | Salvo com **os mesmos pontos da pré-visualização** (`annPath`) — sem simplificação RDP e sem fechamento automático do contorno. Ver changelog V23. |
| `text` | `x1, y1, txt, bold, italic, fontSize`; `rot` (graus) quando girado | `txt` pode conter `\n` (multilinha) — `annDrawShape` desenha linha a linha com `lineH = fontSize × ANN_TEXT_LINE_RATIO`. `textBaseline='top'`; `x1/y1` = canto superior esquerdo da 1.ª linha |
