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
| `--color-primary-foreground` | `#fff` | — | Texto sobre a cor principal; calculado pelo YIQ quando o `TOKEN_ACCENT_FG_OVERRIDE` está vazio |
| `--color-primary-hover` | `#d4450f` | — | Cor principal no hover |
| `--color-brand` | `var(--color-primary)` | — | A cor principal em textos e ícones |
| `--color-ring` | `var(--color-primary)` | — | Contorno do foco do teclado |
| `--color-success-subtle` | `#eaf3de` | `rgb(34 197 94 / 8%)` | Fundo de sucesso |
| `--color-success-border` | `#639922` | `#4d7a18` | Borda de sucesso |
| `--color-success-foreground` | `#27500a` | `#86d84f` | Texto de sucesso |
| `--color-destructive-subtle` | `#fcebeb` | `rgb(239 68 68 / 8%)` | Fundo de erro |
| `--color-destructive-border` | `#a32d2d` | `#8a2424` | Borda de erro |
| `--color-destructive-foreground` | `#501313` | `#ff8c8c` | Texto de erro |
| `--color-warning-subtle` | `#faeeda` | `rgb(234 179 8 / 8%)` | Fundo de aviso |
| `--color-warning-border` | `#ba7517` | `#9c6214` | Borda de aviso |
| `--color-warning-foreground` | `#412402` | `#ecc680` | Texto de aviso |
| `--color-green-500` | `#22c55e` | — | Sucesso, estado «Gravado», confirmar a anotação |
| `--color-red-500` | `#ef4444` | — | Erro, remover, cancelar a anotação |
| `--color-yellow-500` | `#eab308` | — | Aviso |
| `--color-white` | `#fff` | — | Branco sobre preenchimentos de cor sólida (contadores, spinner, botões verdes e vermelhos) |
| `--color-green-600` | `#16a34a` | — | Hover do botão de exportar no modo de administrador |
| `--color-orange-500` | `#f97316` | — | Amostra laranja da paleta de anotação |
| `--color-blue-500` | `#3b82f6` | — | Amostra azul da paleta de anotação |
| `--color-purple-500` | `#a855f7` | — | Amostra roxa da paleta de anotação |
| `--color-brand-icon-light` | `#1a1a1a` | — | Ícone da marca no tema claro |
| `--color-annotation-black` | `#1a1a1a` | — | Amostra preta da paleta de anotação |
| `--color-annotation-white` | `#f0f0f0` | — | Amostra branca da paleta de anotação |
| `--color-viewer-control` | `#2a2a2a` | — | Botões da barra de anotação |
| `--color-viewer-control-hover` | `#363636` | — | Hover dos botões da barra de anotação |
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
| `--color-offcanvas-backdrop` | `rgb(0 0 0 / 50%)` | — | Fundo atrás da barra lateral no mobile |
| `--color-viewer-backdrop` | `rgb(10 10 10 / 88%)` | — | Fundo do visualizador de imagem |
| `--color-viewer-surface` | `rgb(255 255 255 / 8%)` | — | Botões claros sobre o visualizador (fechar, download) |
| `--color-viewer-close-hover` | `rgb(255 255 255 / 20%)` | — | Hover do botão de fechar do visualizador |
| `--color-viewer-toolbar` | `rgb(255 255 255 / 6%)` | — | Barra de ferramentas da anotação |
| `--color-viewer-border` | `rgb(255 255 255 / 10%)` | — | Borda da barra de ferramentas e da barra de zoom |
| `--color-viewer-control-border` | `#3f3f3f` | — | Borda dos botões da barra de anotação |
| `--color-viewer-line` | `rgb(255 255 255 / 15%)` | — | Abas e bordas finas do visualizador |
| `--color-viewer-muted-foreground` | `rgb(255 255 255 / 60%)` | — | Dimensões da imagem, sobre o visualizador |
| `--color-viewer-surface-hover` | `rgb(255 255 255 / 18%)` | — | Hover desses botões e das setas |
| `--color-viewer-border-hover` | `rgb(255 255 255 / 30%)` | — | Borda do botão de download no hover |
| `--color-viewer-floating` | `rgb(25 25 25 / 70%)` | — | Barra de zoom e setas, flutuando sobre a imagem |
| `--color-annotation-swatch-border` | `rgb(120 120 120 / 50%)` | — | Borda das amostras preta e branca da paleta |

> [!NOTE]
> **Tema escuro e anti-FOUC.**
> O tema escuro liga-se só pela classe `dark` no `<html>`. Sem escolha guardada, o `initTheme` segue o sistema (`prefers-color-scheme`). Um script logo no início do `<body>` põe a classe antes da primeira pintura, para não haver um flash branco.

## 2. Cores semânticas

Cada estado tem fundo, borda e texto, para um aviso nunca precisar de três cores escritas à mão.

| Estado | Fundo | Borda | Texto |
|---|---|---|---|
| Sucesso | `--color-success-subtle` | `--color-success-border` | `--color-success-foreground` |
| Erro | `--color-destructive-subtle` | `--color-destructive-border` | `--color-destructive-foreground` |
| Aviso | `--color-warning-subtle` | `--color-warning-border` | `--color-warning-foreground` |

No tema escuro, os fundos são a cor do estado com 8% de opacidade, sobre o fundo escuro.

### 2.1 Cores literais fora dos tokens

Algumas cores ficam escritas como valor no `capture-engine.html` e no `index.html`, porque um token não pode ser usado ali. Esta tabela lista todas, para uma auditoria não as tratar como descuido.

| Cor | Onde | Motivo |
|---|---|---|
| `#b91c1c` `#fff` | Fundo e texto dos avisos `#ce-quota-banner` e `#ce-storage-banner`, montados no JavaScript | Decisão do proprietário (D-0080): o vermelho é mais escuro que o `--color-red-500`, para o bloco de largura total. |
| `#ef4444` `#f97316` `#eab308` `#22c55e` `#3b82f6` `#a855f7` `#1a1a1a` `#f0f0f0` | Atributos `data-color` das 8 amostras da paleta de anotação, e `let annCurrentColor` | São dados: o valor fica gravado no objeto da anotação, no IndexedDB, e redesenha a forma depois. A cor que se vê em cada amostra vem dos tokens da §1. |
| `#ef4444` `#22c55e` `#eab308` | Estilos do `SysLogger` (`console.log('%c…')`) | O console do DevTools não lê as custom properties da página. |
| `#ffffff` | `fillStyle` e `strokeStyle` do canvas: o fundo branco do JPEG no PDF e as alças da anotação | O canvas não lê custom properties. |
| `#1a1917` `#ffffff` | Cálculo YIQ do texto sobre a cor principal, e o valor inicial dos campos `#cfg-fg-hex` e `#cfg-cor-fg` | O resultado depende da cor que o administrador escolhe. Os campos mostram o valor antes de qualquer script correr. |
| `#e86b2e` | O `TOKEN_MAIN_COLOR`, os `value=` de `#cfg-cor-hex` e `#cfg-cor-principal`, e o valor de reserva do `getComputedStyle` | É o valor padrão do próprio token (§6): um `var()` aqui seria circular. |
| `#35a800` `#ffd82b` | `stop-color` do gradiente `#ce_accent`, no logotipo SVG | Um `stop-color` com custom property não funciona da mesma forma em todos os navegadores. |
| `#000000` | `<meta name="theme-color">` e `<meta name="msapplication-TileColor">` | O navegador lê as metatags antes de o CSS existir. |
| `#fdfdfc` `#121212` | `--color-background` do `index.html`, claro e escuro | O `index.html` redireciona antes de a aplicação existir e tem o seu próprio `:root`. |

> **Regra para quem edita:** acrescentar uma cor literal nova **fora** desta tabela é violação do contrato. Se for genuinamente necessária, acrescente aqui a linha com a justificação — caso contrário, use um token.

> **Como verificar que esta tabela continua completa.** Uma versão anterior listava 5 categorias, e o código tinha 9. A lacuna sobreviveu a duas auditorias, porque ninguém comparou as duas listas com um comando. O comando abaixo faz essa comparação e deve devolver vazio:
>
> ```bash
> CODIGO=$(grep -hvE '^[[:space:]]*--[a-z-]+[[:space:]]*:' capture-engine.html index.html | grep -oE '#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b' | tr 'A-F' 'a-f' | sort -u)
> DOC=$(sed -n '/^### 2.1/,/^## 3\./p' design-tokens.md | grep -oE '#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b' | tr 'A-F' 'a-f' | sort -u)
> echo "no codigo e nao declaradas:"; comm -23 <(echo "$CODIGO") <(echo "$DOC")
> echo "declaradas e ja sem uso:";    comm -13 <(echo "$CODIGO") <(echo "$DOC")
> ```
>
> **As duas direções importam.** A primeira apanha cor nova por declarar; a segunda apanha entradas que ficaram para
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
| `--text-caption` | `0.6875rem` | Títulos de seção, contadores, datas e legendas (11px) |
| `--text-xs` | `0.75rem` | Nomes no histórico (12px) |
| `--text-code` | `calc(12.5rem / 16)` | Visualizador de texto, em fonte monoespaçada (12.5px) |
| `--text-control` | `0.8125rem` | Botões, campos e chips (13px) |
| `--text-sm` | `0.875rem` | Texto geral (14px) |
| `--text-subtitle` | `0.9375rem` | Título do aviso de documento binário (15px) |
| `--text-base` | `1rem` | Títulos de modal e campos no mobile (16px) |
| `--text-lg` | `1.125rem` | Nome da ferramenta em telas baixas (18px) |
| `--text-xl` | `1.25rem` | Nome da ferramenta e títulos do Visual Builder (20px) |

### Espaçamento

| Token | Valor | Uso |
|---|---|---|
| `--spacing` | `0.25rem` | Base dos espaços: `calc(var(--spacing) * n)` |

### Raios

| Token | Valor | Uso |
|---|---|---|
| `--radius-badge` | `0.1875rem` | Badges e etiquetas de tamanho (3px) |
| `--radius-sm` | `0.25rem` | Campos, chips e o botão de remover (4px) |
| `--radius-md` | `0.375rem` | Botões, cartões de documento e a moldura da miniatura (6px) |
| `--radius-lg` | `0.5rem` | Painéis internos e caixas (8px) |
| `--radius-xl` | `0.75rem` | Modais e diálogos (12px) |
| `--radius-circle` | `50%` | Elementos redondos: botões de ícone, amostras, spinner |
| `--radius-full` | `calc(infinity * 1px)` | Pílulas: contadores e o interruptor |

### Sombras

| Token | Valor | Uso |
|---|---|---|
| `--shadow-card` | `0 2px 8px rgb(0 0 0 / 2%)` | Painéis e barras |
| `--shadow-button` | `0 1px 3px rgb(0 0 0 / 12%), 0 1px 2px rgb(0 0 0 / 6%)` | Botões secundários sem contorno (Adicionar Imagem e Documento, as duas escolhas do modo ZIP), no tema claro |
| `--shadow-control` | `0 2px 4px rgb(0 0 0 / 20%)` | Botões pequenos sobre a miniatura e o interruptor |
| `--shadow-swatch` | `0 2px 4px rgb(0 0 0 / 15%)` | Amostras de cor do Visual Builder |
| `--shadow-swatch-active` | `0 0 0 1px rgb(0 0 0 / 40%)` | Amostra ativa da paleta de anotação |
| `--shadow-input-focus` | `0 0 0 1px var(--color-primary)` | Campos com foco |
| `--shadow-dragging` | `0 12px 30px rgb(0 0 0 / 35%)` | Item em arrasto |
| `--shadow-sidebar` | `0 12px 48px rgb(0 0 0 / 30%)` | Barra lateral no mobile |
| `--shadow-settings` | `0 10px 25px rgb(0 0 0 / 20%)` | Visual Builder e painel de exportação |
| `--shadow-modal` | `0 24px 64px rgb(0 0 0 / 45%)` | Modais |
| `--shadow-viewer-zoom` | `0 4px 12px rgb(0 0 0 / 15%)` | Barra de zoom do visualizador |

### Foco e medidas de componente

| Token | Valor | Uso |
|---|---|---|
| `--focus-width` | `3px` | Espessura do contorno do foco |
| `--focus-offset` | `2px` | Afastamento do contorno do foco |
| `--top-bar-h` | `64px` | Altura da barra do topo |
| `--thumb-size` | `140px` | Lado da caixa de miniatura |

Os elementos `.t-item` e `.t-label` têm `border-radius: 0`: a miniatura fica com cantos retos, e só a moldura `.t-wrap` é arredondada.

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
| `--z-fixed` | `1030` | Botão de colar do mobile (`#mobile-paste-fab`) | global |
| `--z-offcanvas-backdrop` | `1040` | `#sb-mobile-overlay` (fundo escurecido) | mobile |
| `--z-offcanvas` | `1045` | `#sidebar` no mobile, acima do seu fundo | mobile |
| `--z-modal` | `1055` | `.modal-overlay`, `.sb-overlay` | global |
| `--z-toast` | `1090` | Avisos de quota e de armazenamento, **acima dos modais** de propósito, para um aviso crítico nunca ficar escondido | global |

O botão de colar fica abaixo da barra lateral e dos modais. Até a versão 27 ficava acima deles.

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
| `--ease-in` | `cubic-bezier(0.4, 0, 1, 1)` |
| `--ease-out` | `cubic-bezier(0, 0, 0.2, 1)` |
| `--ease-in-out` | `cubic-bezier(0.4, 0, 0.2, 1)` |

| Animação | O que faz | Duração | Onde é usada |
|---|---|---|---|
| `spin` | Rotação contínua | `--duration-spinner` | Spinner nos botões PDF e ZIP durante o processamento |
| `fade-in` | Entrada com opacidade 0→1 | `--duration-moderate-02` | Novas miniaturas e documentos |
| `modal-in` | Escala `0.96→1` e opacidade | `--duration-moderate-02` | Entrada de todos os modais |
| `fade-in-tab` | Opacidade | `--duration-moderate-02` | Troca de abas do Visual Builder |

---

## 6. Tokens JavaScript (SSOT — Single Source of Truth)

Estes tokens estão declarados como `const` no topo do IIFE do JavaScript. São a **fonte de verdade** para a configuração: o Visual Builder lê estes valores ao abrir, e o Quine Engine os substitui ao exportar.

| Token | Tipo | Valor padrão | Alterável no VB | Aba VB |
|---|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture '` | ✅ | Interface → «Texto inicial» |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | ✅ | Interface → «Texto em destaque» |
| `TOKEN_TITLE_END` | `string` | `''` | ✅ | Interface → «Texto final» (terceira parte do título; espaços manuais) |
| `TOKEN_TITLE_START_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do «Texto inicial» (vazio = herda cor do texto) |
| `TOKEN_TITLE_ACCENT_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do «Texto em destaque» (vazio = herda cor accent) |
| `TOKEN_TITLE_END_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do «Texto final» (vazio = herda cor do texto) |
| `TOKEN_MAIN_COLOR` | `string` | `'#e86b2e'` | ✅ | Interface → color seletor principal |
| `TOKEN_ACCENT_FG_OVERRIDE` | `string` | `''` | ✅ | Interface → color seletor de texto |
| `TOKEN_FOOTER_TEXT` | `string` | `'© {YEAR} • CAPTURE ENGINE • DIOGO CARVALHO'` | ✅ | Interface → «Texto do rodapé» |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | ✅ | Histórico → «Primeiro campo», interruptor |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | ✅ | Histórico → «Segundo campo», interruptor |
| `TOKEN_USER_LABEL` | `string` | `''` | ✅ | Histórico → «Primeiro campo», rótulo |
| `TOKEN_EQUIP_LABEL` | `string` | `''` | ✅ | Histórico → «Segundo campo», rótulo |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | ✅ | Captura → "Qualidade do PDF" |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | ✅ | Captura → dimensão máxima |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | ✅ | Manutenção → «Limpeza automática» (8h, 24h, 48h, Nunca). **ℹ️ Valor 0 desativa o purge** (guard `if (!TOKEN_AUTO_PURGE_HOURS) return` — nenhuma sessão é apagada). Valores suportados pelo Visual Builder: 8, 24, 48 (horas) e 0 (Nunca/desativado). Valores arbitrários editados à mão no token não são preservados pelo reexport do Visual Builder — ver a nota no README §7.4. |
| `TOKEN_DEBUG_MODE` | `bool` | `true` | ❌ | Sem UI — desativado automaticamente em Export User |

### Notas sobre tokens específicos

**`TOKEN_TITLE_END` (adicionado na V23):**
Terceira parte do título da aplicação. Renderizado como `<span id="ui-title-end">` com `font-weight: 600`. A cor é controlada por `TOKEN_TITLE_END_COLOR` (vazio = herda cor do texto). Espaços entre partes do título são manuais — incluir no valor do token.

**`TOKEN_ACCENT_FG_OVERRIDE` (vazio = automático):**
Quando vazio (`''`), o motor calcula automaticamente se o texto sobre a cor accent deve ser branco ou preto. O algoritmo usado é **YIQ** — uma ponderação perceptual dos canais RGB calibrada para a sensibilidade do olho humano:

```
yiq = (R × 299 + G × 587 + B × 114) / 1000
yiq ≥ 128  →  texto escuro (#1a1917)
yiq < 128  →  texto branco (#ffffff)
```

O limiar 128 divide a escala 0–255 ao meio. Em cores claras, o texto automático é escuro, e o contraste pode ficar abaixo do WCAG AA (4.5:1 para texto normal). Exemplos: amarelo `#eab308` (yiq ≈ 176), ciano `#06b6d4` (yiq ≈ 133), laranja `#f97316` (yiq ≈ 145). Nestes casos, preencher `TOKEN_ACCENT_FG_OVERRIDE` com a cor desejada. Preencher apenas se o cálculo automático não produzir o contraste desejado.

**`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL` (vazio = padrão visual):**
Um valor vazio significa "usar o padrão visual" (`User` / `Equipamento`). O Visual Builder mostra estes termos como placeholder, mas o token fica em `''`. Exportar sem editar estes campos preserva a flexibilidade — o motor usa o padrão correto conforme o contexto. A flag `_vbLabelDirty` controla se o admin editou ativamente estes campos.

**`TOKEN_JPEG_QUALITY` (0.70 a 0.95):**
Afeta apenas a geração do PDF — os arquivos originais na sessão ficam sempre em PNG. Valores abaixo de 0.70 produzem artefatos JPEG visíveis em capturas de tela com texto. Valores acima de 0.95 aumentam o tamanho do PDF sem benefício visual perceptível.

> **Clamp automático no Visual Builder:** O VB aplica `Math.min(0.95, Math.max(0.70, rawJq / 100))` ao valor introduzido — valores fora do intervalo são silenciosamente corrigidos para o limite mais próximo. A edição manual direta do token no código-fonte não tem este guard. Comportamento com valores fora de `[0.70, 0.95]` editados diretamente: o valor é passado sem clamp para `canvas.toBlob(type, quality)`. Pelo padrão HTML, um valor fora de `[0, 1]` faz o navegador usar a qualidade padrão (em geral ~0.92). Um valor em `[0, 1]`, mas fora de `[0.70, 0.95]`, é aceito sem erro e produz os artefatos ou o desperdício de espaço descritos acima.

**`TOKEN_MAX_IMG_DIMENSION` (0 = sem limite):**
Afeta **apenas a geração do PDF**, tal como `TOKEN_JPEG_QUALITY`. Se definido (ex: `1920`), qualquer imagem com dimensão superior é reduzida ao gerar o PDF, preservando a proporção. É lido num único ponto do código — `imgToJPEG()`, chamada exclusivamente por `generatePDF()`.

> ⚠️ **Importante — não reduz o armazenamento:** `captureImg()` grava sempre o blob **original**, sem redimensionar. Este token não diminui o consumo de quota do IndexedDB e não serve como mitigação para esgotamento de armazenamento. Para isso, o caminho é exportar (PDF ou ZIP) e apagar sessões antigas.
>
> Até a V26, esta seção afirmava que a imagem era «redimensionada antes de ser armazenada», e o `README §9` recomendava o token como forma de prevenir perda de dados por quota. Ambas as afirmações eram falsas: um administrador que o configurasse para esse fim não obtinha redução nenhuma, e continuava exposto à perda que o conselho pretendia evitar. Corrigiu-se a documentação, e não o código. Redimensionar na captura destruiria o original, e numa ferramenta de recolha de provas isso é perda de evidência.

> **Comportamento sem-op:** Se a imagem já tiver ambas as dimensões iguais ou inferiores ao limite configurado, nenhum redimensionamento ocorre — a imagem entra no PDF tal como está.

### Como o Quine usa estes tokens

O Quine substitui valores por regex no código-fonte:
```js
// O Quine procura um padrão flexível, por exemplo:
html.replace(/const TOKEN_MAIN_COLOR\s*=\s*'[^']*'/, "const TOKEN_MAIN_COLOR = '#ff6600'")
```

**Por isso, o formato exato deve seguir a sintaxe:**
- `const` (não `let` ou `var`)
- `TOKEN_NOME` *(placeholder — representa qualquer nome real de token, ex: `TOKEN_MAIN_COLOR`)*
- `=` (espaços à volta são suportados e recomendados para legibilidade)
- `'valor'` (aspas simples, não duplas)

---

## 7. Anatomia dos Componentes

### Barra de Topo

```
┌────────────────────────────────────────────────────────────────┐
│  [⬚] Capture Engine                         [⚙] [💾] [🌙]   │
│   ↑ logo + brand name                         ↑ tb-actions    │
└────────────────────────────────────────────────────────────────┘
  height: 64px (--top-bar-h)
  Os botões [⚙] [💾] são ADMIN_BUTTONS — removidos em exports User
```

### Layout Principal

```
┌──────────────────────────────────────────────────────────────────────┐
│ BARRA DE TOPO (64px)                                                  │
├──────────────┬────────────────────────────┬──────────────────┬───────┤
│ LEFT SIDEBAR │  PAINEL IMAGENS            │  PAINEL DOCS     │ SB    │
│              │  [▲ IMAGENS  ] [count]     │  [≡ DOCUMENTOS ] │  ☰   │
│ [User     ]  │  ┌──────────────────────┐  │  ┌────────────┐  │       │
│ [Equipam. ]  │  │  drop zone / grid    │  │  │ doc list   │  │       │
│              │  │  (thumbnails 140px)  │  │  └────────────┘  │       │
│ [Auto]       │  └──────────────────────┘  │                  │       │
│ [A4V][A4H]   │                            │                  │       │
│              │                            │                  │       │
│ [PDF] [ZIP]  │                            │                  │       │
├──────────────┴────────────────────────────┴──────────────────┴───────┤
│ TRASH BAR  [🗑 Removidos  3]  ← expande ao clicar                    │
├───────────────────────────────────────────────────────────────────────┤
│ RODAPÉ  © 2026 • CAPTURE ENGINE • DIOGO CARVALHO     (opacity: 0.5)  │
└───────────────────────────────────────────────────────────────────────┘
```

### Modal de Imagem (`#img-modal-overlay`)

```
┌──────────────────────────────────────────────────────────┐
│  Visualizar imagem — imagem-1.png                   [×]  │
│   ↑ .modal-title (16px, centrado)               ↑ 32px  │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│  │                                                    │  │
│  │                    [Imagem]                        │  │
│  │                                                    │  │
│  │                               [ − ] 100% [ + ]    │  │  ← #zoom-ui
│  └────────────────────────────────────────────────────┘  │    visível
├──────────────────────────────────────────────────────────┤    apenas zoom > 100%
│  [Restaurar]  [Download]           1920 × 1080 · 245 KB  │
└──────────────────────────────────────────────────────────┘
```

*A barra `#zoom-ui` usa glassmorphism: `background: rgba(25,25,25,0.7)` + `backdrop-filter: blur(10px)`. Flutua sobre a imagem com texto sempre a `#fff` independentemente do conteúdo por baixo.*

*O fechamento por clique no backdrop está bloqueado quando zoom > 100% — evita fechamentos acidentais durante o panning.*

### Modal de Documento (`#text-modal-overlay`)

```
┌──────────────────────────────────────────────────────────┐
│  Visualizar documento — relatorio.txt               [×]  │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│  │ Texto: área de texto com fonte monoespaçada        │  │  ← modo texto
│  │ (Consolas, Monaco, monospace)                      │  │    (TXT, CSV, JSON...)
│  └────────────────────────────────────────────────────┘  │
│
│  OU, para arquivos binários (PDF, DOCX, etc.):          │
│
│  ┌────────────────────────────────────────────────────┐  │
│  │           [ícone]  PDF                             │  │  ← modo binário
│  │   Faça download para visualizar o documento        │  │    (textarea oculta)
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  [Restaurar]  [Copiar Texto]  [Download]                  │
│   ↑ só se na lixeira  ↑ oculto em modo binário           │
└──────────────────────────────────────────────────────────┘
```

**Como o motor decide entre modo texto e modo binário:**
- MIME type começa com `text/` → modo texto (visualizável inline)
- MIME type é `application/json`, `application/xml`, etc. → modo texto
- Qualquer outro MIME type → modo binário (download apenas)

---

## 8. Tipografia — Tabela de Referência

| Elemento | Tamanho | Peso | Notas |
|---|---|---|---|
| Nome da marca (topo) | `var(--text-xl)` (20px) | `600` | Logo principal |
| Section titles (rótulos uppercase) | `var(--text-caption)` (11px) | `600` | `letter-spacing: 0.6px` |
| Texto geral | `var(--text-sm)` (14px) | `400` | Body text |
| Botões `.btn-send` | `var(--text-control)` (13px) | `600` | Altura `36px` |
| Ícones em botões | `14px` | — | `stroke-width: 2` |
| Ícones de cabeçalho `.blk-hdr svg` | `16px` | — | |
| Títulos de bloco `.blk-hdr-title` | `var(--text-caption)` (11px) | `600` | Uppercase |
| Badges `.count-badge`, `#trash-badge` | `var(--text-caption)` (11px) | `700` | |
| Item de histórico — nome | `var(--text-xs)` (12px) | `400` | |
| Item de histórico — data | `var(--text-caption)` (11px) | `400` | `--color-muted-foreground` |
| Título de modal `.modal-title` | `var(--text-base)` (16px) | `600` | Centrado horizontalmente |
| Campo de documento `.d-input` | `var(--text-control)` (13px) | `400` | **Sem negrito** — não é um título, é um nome de arquivo |
| Legenda de imagem `.t-label` | `var(--text-caption)` (11px) | `400` | **Sem negrito** — discreta, não distrai da imagem |
| Links de ação `.pick-link` | `var(--text-control)` (13px) | `400` | Em empty states |

---

## 9. Padrão de Botões em Modais

| Ação | Estilo | Cor | Quando aparece |
|---|---|---|---|
| **Restaurar** | Fill accent | `var(--color-primary)` + branco | Apenas se o item está na lixeira |
| **Copiar Texto** | Fill accent | `var(--color-primary)` + branco | Apenas em documentos de texto (não binários) |
| **Download** | Outline | `var(--color-card)` + `var(--color-foreground)` + `var(--color-border)` | Sempre — ativos e na lixeira |
| **Confirmar** (anotação) | Fill verde | `var(--color-green-500)` | No modo de anotação |
| **Cancelar** (anotação) | Outline | `var(--color-card)` + `var(--color-foreground)` + `var(--color-border)` | No modo de anotação |

---

## 10. Responsividade

A interface tem dois cortes principais de largura, em `rem` (D-0082). Há ainda `width <= 48rem` (768px) e `(height <= 50rem) and (width >= 56.3125rem)`, para telas baixas.

### `width <= 56.25rem` (900px) — tablets e telefones na horizontal

- Layout muda de horizontal para vertical (painéis empilhados)
- A sidebar de histórico (desktop: coluna lateral direita) transforma-se em um **modal centralizado** em vez de drawer lateral — aumenta a área de toque e facilita uso com o polegar
- O botão de histórico fica na barra de topo
- FAB mobile (`#mobile-paste-fab`) fica visível — botão flutuante para colar da área de transferência
- `pointer-events: auto` e `touch-action: manipulation` garantem que 100% da superfície de cada card responde a toque

### `width <= 30rem` (480px) — telefones na vertical

- Padding e margens reduzidos para maximizar área útil
- Todos os elementos comprimem proporcionalmente

### `width >= 112.5rem` (1800px) e `width >= 150rem` (2400px) — telas grandes

Nas telas grandes, a interface inteira cresce junto, com o `zoom` do `html`: os textos, os ícones, os botões e a barra lateral. Antes, tudo ficava do tamanho de um notebook, e a 2560px a barra lateral ocupava 8,6 % da largura.

| Token | Valor | Uso |
|---|---|---|
| `--app-zoom` | `1` | Escala da interface: `1.125` a partir de 1800px e `1.25` a partir de 2400px. As medidas em `vw` e `vh` das janelas dividem-se por ela, para caberem na tela |

**Body Scroll Lock:** Quando o modal de histórico abre em mobile, `document.body.style.overflow = 'hidden'` previne que o conteúdo de fundo role. Ao fechar, o scroll é restaurado.

---

## 11. Comportamento de Bordas

Uma das decisões de design mais impactantes foi padronizar *quando* as bordas aparecem e desaparecem. Bordas que surgem apenas no hover criam layout shift (o elemento "salta" 1px quando o cursor passa).

### Botões de Captura ("Adicionar Imagem" / "Adicionar Documento")

| Estado | Borda |
|---|---|
| **Repouso** | `1px solid var(--color-border-strong)` — sempre visível, cinzenta |
| **Hover** | `border-color: var(--color-primary)` — transição suave para a cor accent |
| **Regra** | A borda **nunca desaparece**. Elimina layout shift. |

### Botões de Export ZIP em Modo ZIP Ativo (`.btn-zip-cta`)

| Estado | Borda |
|---|---|
| **Repouso** | `1px solid var(--color-primary)` — accent permanente |
| **Hover** | Fundo sutil `color-mix(in srgb, var(--color-primary) 6%, transparent)` + texto mais escuro |
| **Regra** | A borda accent **não desaparece** ao sair com o cursor. |

### Chips de Modo (Auto / A4 Vertical / A4 Horizontal)

| Estado | Borda | Texto |
|---|---|---|
| **Selecionado — repouso** | `1px solid var(--color-border-strong)` | `var(--color-foreground)` |
| **Selecionado — hover** | `border-color: var(--color-primary)` | `var(--color-foreground)` |
| **Não selecionado — qualquer estado** | `border: none` | `var(--color-muted-foreground)` |

*Chips inativos são sem borda em todos os estados — comunica claramente "este não está selecionado".*

### FAB Mobile (`#mobile-paste-fab`)

| Estado | Visual |
|---|---|
| **Repouso** | Ícone `var(--color-muted-foreground)`, borda `var(--color-border-strong)` — neutro, discreto |
| **Hover** | Ícone `var(--color-foreground)`, borda `var(--color-muted-foreground)` — reforço sutil |
| **`:active` (toque)** | Ícone e borda em `var(--color-primary)` — feedback preciso no momento do toque |

*O accent aparece só no `:active` (não no `:hover`) porque em mobile não há estado hover real — o dedo ou toca ou não toca.*


---

## Annotation Engine — Constantes e Estado

### Constantes de Traço

| Constante | Valor | Descrição |
|---|---|---|
| `ANN_SIZES` | `[1, 2, 4, 6, 8, 12]` | Espessuras de linha disponíveis (px, coordenadas canvas). Escala de 6 níveis (do mais fino ao mais grosso). |
| `ANN_TEXT_SIZES` | `[14, 18, 24, 36, 48]` | Tamanhos de fonte disponíveis (px canvas); index 2 = 24px padrão |
| `ANN_TEXT_LINE_RATIO` | `1.3` | Line-height ratio do texto. Constante **única** usada no `line-height` do `<textarea>` editor **e** no render do canvas (`annDrawShape`) — garante que o texto multilinha achatado é igual ao que se vê a escrever (WYSIWYG) |

### Variáveis de Estado da Anotação

| Variável | Padrão | Descrição |
|---|---|---|
| `annTool` | `'rect'` | Ferramenta ativa: `select` / `rect` / `circle` / `arrow` / `free` / `text` / `crop` |
| `annSizeIdx` | `1` (2px) | Índice em `ANN_SIZES` — espessura de linha |
| `annTextSizeIdx` | `2` (24px) | Índice em `ANN_TEXT_SIZES` — tamanho de fonte |
| `annTextBold` | `true` | Negrito ativo na ferramenta texto |
| `annTextItalic` | `false` | Itálico ativo na ferramenta texto |
| `annEditingTextIdx` | `-1` | Índice em `annHistory` do texto em reedição; `-1` = novo texto |
| `annTextClickTimer` | `null` | Timer 220ms para distinguir single-click de dblclick |
| `annSmoothLast` | `null` | Último ponto EMA no desenho livre (α=0.35); reset em activate/deactivate/mouseup |

### Tokens CSS do Motor de Reordenação

Estas variáveis CSS controlam a aparência do placeholder de arrasto (o espaço vazio que aparece durante a reordenação de itens). **Requerem edição direta do `capture-engine.html`** — não são expostas no Visual Builder e não viajam com o Export (o Quine não substitui variáveis CSS, apenas tokens `TOKEN_*`).

| Token CSS | Valor padrão (via `color-mix`) | Descrição |
|---|---|---|
| `--color-drop-placeholder` | `color-mix(in srgb, var(--color-foreground) 5%, transparent)` | Cor de fundo do placeholder de arrasto — área muito sutil que indica onde o item irá cair. Alterável apenas por desenvolvedor com acesso ao código-fonte. |
| `--color-drop-placeholder-border` | `color-mix(in srgb, var(--color-foreground) 8%, transparent)` | Cor da borda do placeholder de arrasto. Ligeiramente mais visível que o fundo para delimitar a área. Alterável apenas por desenvolvedor com acesso ao código-fonte. |

### Formato de Entradas em `annHistory`

Cada entrada é um objeto com pelo menos `{type, color, lw}` e campos adicionais por tipo:

| `type` | Campos obrigatórios | Notas |
|---|---|---|
| `rect` | `x1, y1, x2, y2` | Coordenadas dos dois cantos opostos |
| `circle` | `x1, y1, x2, y2` | Bounding box da elipse |
| `arrow` | `x1, y1, x2, y2` | Origem → destino da seta |
| `free` | `pts: [{x,y}]`, `closed` (sempre `false` desde a V23) | Salvo com **os mesmos pontos do preview** (`annPath`) — sem simplificação RDP e sem fechamento automático do contorno. Ver changelog V23. |
| `text` | `x1, y1, txt, bold, italic, fontSize` | `txt` pode conter `\n` (multilinha) — `annDrawShape` desenha linha a linha com `lineH = fontSize × ANN_TEXT_LINE_RATIO`. `textBaseline='top'`; `x1/y1` = canto superior esquerdo da 1.ª linha |
