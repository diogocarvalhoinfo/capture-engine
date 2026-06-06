# Design Tokens · Capture Engine V24

> Especificação completa do design system — a linguagem visual que define como a interface se vê, se comporta e se sente.

---

## O que são Design Tokens e por que existem?

Um **design token** é um nome simbólico para um valor visual. Em vez de escrever `#0ea5e9` diretamente no CSS, usamos `var(--accent)`. Em vez de escrever `36px` em cada botão, os botões têm sempre `height: 36px` por convenção documentada.

**Por que usar tokens?**

1. **Consistência** — Mudar a cor principal em um lugar (`--accent`) muda em toda a interface automaticamente
2. **Personalização via Quine** — O admin muda a cor pelo Visual Builder; o Quine Engine substitui o valor no arquivo exportado
3. **Dark mode sem duplicação** — Os tokens têm valores diferentes em `:root` (light) e `body.dark` (dark); o CSS que usa os tokens não precisa saber em que modo está
4. **Legibilidade** — `color: var(--text-muted)` diz o que faz; `color: #6b6a66` não

**Dois tipos de tokens:**
- **Tokens CSS** — definidos como variáveis CSS (`:root { --token: valor }`) — usados em `var(--token)` no CSS
- **Tokens JavaScript** — definidos como `const TOKEN_*` no início do script — controlam o comportamento e são substituídos pelo Quine na exportação

---

## 1. Paleta de Cores

### Como o sistema de cores funciona

A paleta tem dois grupos:
- **Cores base** (não mudam entre light/dark): `--accent`, `--color-green`, `--color-red`, `--color-yellow` — mantêm o mesmo matiz mas adaptam-se ao fundo
- **Cores adaptativas** (mudam entre light/dark): `--bg`, `--surface`, `--border`, `--text`... — invertem ou ajustam conforme o modo

### Light Mode (`:root` — padrão)

| Token | Hex | Uso na interface |
|---|---|---|
| `--bg` | `#f4f3f0` | Fundo geral — off-white (não branco puro) para suavizar o contraste com a superfície branca dos painéis |
| `--surface` | `#ffffff` | Superfície de painéis, cards, modais — branco puro para contraste com o fundo |
| `--border` | `#dddcd880` | Bordas sutis, linhas de separação — estruturam sem poluir (alpha 50%) |
| `--border-strong` | `#b5b3ae` | Bordas com mais presença — elementos de estado ativo ou hover |
| `--text` | `#1a1917` | Texto principal — quase preto (nunca `#000000` puro — muito agressivo) |
| `--text-muted` | `#6b6a66` | Texto secundário — datas, legendas, metadados menos importantes |
| `--accent` | `#0ea5e9` | Cor de destaque primária (Tailwind sky-500) — botões, links, elementos ativos |
| `--accent-fg` | `#ffffff` | Texto legível sobre fundo accent — branco sobre `#0ea5e9` tem ratio ~3.1:1 (WCAG AA para texto grande/negrito ≥3:1; abaixo do mínimo para texto pequeno normal ≥4.5:1). Para texto pequeno, ajustar via `TOKEN_ACCENT_FG_OVERRIDE`. |
| `--accent-hover` | `#0284c7` | Accent escurecido para hover (Tailwind sky-600) |
| `--color-green` | `#22c55e` | Sucesso, confirmação, estado "Gravado" |
| `--color-red` | `#ef4444` | Erro, remoção, ações destrutivas |
| `--color-yellow` | `#eab308` | Aviso, expiração próxima |

### Dark Mode (`body.dark`)

| Token | Hex | Nota |
|---|---|---|
| `--bg` | `#121212` | Quase preto — padrão Material Dark |
| `--surface` | `#1e1e1e` | Ligeiramente mais claro que o fundo — cria profundidade sem bordas |
| `--border` | `#33333380` | Borda escura sutil (alpha 50%) |
| `--border-strong` | `#555555` | Borda escura mais visível |
| `--text` | `#e4e4e4` | Quase branco (nunca `#ffffff` puro — agressivo em fundos escuros) |
| `--text-muted` | `#9a9a9a` | Cinza médio para elementos secundários |

> **Regra do dark mode:** Ativa-se *exclusivamente* via classe CSS `body.dark`. A media query `prefers-color-scheme` é usada **apenas em JavaScript** (`initTheme`) como fallback na primeira abertura, quando não há preferência salva em `localStorage`. Depois de o usuário alternar manualmente, a escolha fica persistida. Isto dá controle total ao usuário.

> **Anti-FOUC:** Existe um script síncrono imediatamente após `<body>` que aplica `body.dark` *antes* de qualquer pintura do DOM. Sem isto, o usuário em dark mode veria um flash branco ao abrir a app.

---

## 2. Cores Semânticas — Estados de Feedback

Estas variáveis definem estados de sucesso, erro e aviso de forma completa (fundo + borda + texto) para que qualquer alerta fique consistente sem definir três cores manualmente.

| Estado | Token de fundo | Token de borda | Token de texto |
|---|---|---|---|
| **Sucesso** | `--success-bg` | `--success-border` | `--success-text` |
| **Erro** | `--error-bg` | `--error-border` | `--error-text` |
| **Aviso** | `--warn-bg` | `--warn-border` | `--warn-text` |

**Valores Light / Dark:**

| Variável | Light | Dark |
|---|---|---|
| `--success-bg` | `#eaf3de` | `rgba(34,197,94,0.08)` |
| `--success-border` | `#639922` | `#4d7a18` |
| `--success-text` | `#27500a` | `#86d84f` |
| `--error-bg` | `#fcebeb` | `rgba(239,68,68,0.08)` |
| `--error-border` | `#a32d2d` | `#8a2424` |
| `--error-text` | `#501313` | `#ff8c8c` |
| `--warn-bg` | `#faeeda` | `rgba(234,179,8,0.08)` |
| `--warn-border` | `#ba7517` | `#9c6214` |
| `--warn-text` | `#412402` | `#ecc680` |

*Em dark mode, os fundos usam `rgba` com opacidade ~0.08 — a cor semântica fica sobreposta ao fundo escuro com baixa saturação, em vez de um bloco de cor sólido.*

---

## 3. Layout e Forma

### Tipografia — Fonte do sistema

A interface usa `'Segoe UI', Arial, sans-serif` — a fonte nativa do Windows/Mac/Linux. Sem fontes externas (sem Google Fonts, sem CDN), para garantir o funcionamento 100% offline e para que a interface se pareça "em casa" no sistema operacional de cada usuário.

### Raio de Canto — A escala de arredondamento

Existe uma escala de 5 níveis, cada um com um propósito específico:

| Token | Valor | Onde usar |
|---|---|---|
| `--radius-xxs` | `3px` | Badges, etiquetas de tamanho — micro-elementos |
| `--radius-xs` | `4px` | Inputs, chips de seleção — elementos pequenos interativos |
| `--radius-sm` | `6px` | Botões, cards de documentos — elementos de ação principais |
| `--radius-md` | `8px` | Painéis internos, caixas — contentores secundários |
| `--radius-lg` | `12px` | Modais e diálogos — elementos de maior destaque visual |

> **Exceção geométrica — imagens:** Os elementos `.t-item` e `.t-label` têm `border-radius: 0` (cantos retos — comunicam precisão e formalidade). O `.t-wrap` (wrapper do thumbnail) tem `border-radius: var(--radius-sm)` (6px) para suavizar visualmente a moldura da imagem na grelha, mantendo o card exterior reto. Botões e cards textuais ficam arredondados para parecerem interativos e acessíveis.

### Medidas fixas de layout

| Token CSS | Valor | Uso |
|---|---|---|
| `--top-bar-h` | `64px` | Altura estrita da barra de cabeçalho — consistente em todas as telas |
| `--thumb-size` | `140px` | Tamanho da caixa de thumbnail — todos os thumbs têm a mesma área |

---

## 4. Z-Index Stack — Quem fica à frente de quem

| Camada | Z-index | O que está aqui |
|---|---|---|
| Base | `0` | Conteúdo normal (grelha de thumbs, lista de documentos, painéis) |
| Banner | `1000` | Banners de aviso (ex: "Restaurar sessão anterior?") |
| Modal overlay | `9999` | Modais de imagem, texto, anotação — nada pode ficar à frente |

*Por que apenas 3 níveis?* Uma stack com dezenas de valores é fonte constante de bugs. Três níveis bem definidos eliminam ambiguidade. **Não adicionar novos valores sem documentar aqui e em `agents.md`.**

---

## 5. Animações

| Animação | O que faz | Duração | Onde é usada |
|---|---|---|---|
| `spin` | Rotação contínua | Contínua | Spinner nos botões PDF/ZIP durante o processamento |
| `fadeIn` | Entrada com opacidade 0→1 | 150ms | Novos thumbnails e documentos ao serem adicionados |
| `modalIn` | Escala `0.96→1` + opacidade | 200ms | Entrada suave de todos os modais |
| `fadeInTab` | Opacidade rápida | 150ms | Transição entre abas do Visual Builder |

*Todas as animações são curtas (150–300ms) e sem inércia. O objetivo é dar feedback imediato — não criar uma experiência cinematográfica que atrase a interação.*

---

## 6. Tokens JavaScript (SSOT — Single Source of Truth)

Estes tokens estão declarados como `const` no topo do IIFE do JavaScript. São a **fonte de verdade** para a configuração: o Visual Builder lê estes valores ao abrir, e o Quine Engine os substitui ao exportar.

| Token | Tipo | Valor padrão | Alterável no VB | Aba VB |
|---|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture '` | ✅ | Interface → "Texto Inicial" |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | ✅ | Interface → "Texto em Destaque" |
| `TOKEN_TITLE_END` | `string` | `''` | ✅ | Interface → "Texto Final" (terceira parte do título; espaços manuais) |
| `TOKEN_TITLE_START_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do Texto Inicial (vazio = herda cor do texto) |
| `TOKEN_TITLE_ACCENT_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do Texto em Destaque (vazio = herda cor accent) |
| `TOKEN_TITLE_END_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do Texto Final (vazio = herda cor do texto) |
| `TOKEN_MAIN_COLOR` | `string` | `'#0ea5e9'` | ✅ | Interface → color picker principal |
| `TOKEN_ACCENT_FG_OVERRIDE` | `string` | `''` | ✅ | Interface → color picker de texto |
| `TOKEN_FOOTER_TEXT` | `string` | `'© {YEAR} • CAPTURE ENGINE • DIOGO CARVALHO'` | ✅ | Interface → "Texto do Rodapé" |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | ✅ | Histórico → toggle "Campo 1" |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | ✅ | Histórico → toggle "Campo 2" |
| `TOKEN_USER_LABEL` | `string` | `''` | ✅ | Histórico → "Rótulo — Campo 1" |
| `TOKEN_EQUIP_LABEL` | `string` | `''` | ✅ | Histórico → "Rótulo — Campo 2" |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | ✅ | Captura → "Qualidade do PDF" |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | ✅ | Captura → dimensão máxima |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | ✅ | Captura → horas até purge. **⚠️ Valor 0 é destrutivo** — apaga todas as sessões na próxima abertura (cutoff = `Date.now() - 0`). Para purge infrequente usar valor alto (ex: `8760` = 1 ano). |
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

O limiar 128 divide a escala 0–255 ao meio. Para cores de baixo contraste intrínseco (ex: amarelo `#eab308` — yiq ≈ 176, texto escuro; ciano `#06b6d4` — yiq ≈ 133, texto escuro; laranja `#f97316` — yiq ≈ 145, texto escuro), o resultado automático pode não atingir os rácios WCAG AA (4.5:1 para texto normal). Nestes casos, preencher `TOKEN_ACCENT_FG_OVERRIDE` com a cor desejada. Preencher apenas se o cálculo automático não produzir o contraste desejado.

**`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL` (vazio = padrão visual):**
Um valor vazio significa "usar o padrão visual" (`User` / `Equipamento`). O Visual Builder mostra estes termos como placeholder, mas o token fica em `''`. Exportar sem editar estes campos preserva a flexibilidade — o motor usa o padrão correto conforme o contexto. A flag `_vbLabelDirty` controla se o admin editou ativamente estes campos.

**`TOKEN_JPEG_QUALITY` (0.70 a 0.95):**
Afeta apenas a geração do PDF — os arquivos originais na sessão ficam sempre em PNG. Valores abaixo de 0.70 produzem artefatos JPEG visíveis em screenshots com texto. Valores acima de 0.95 aumentam o tamanho do PDF sem benefício visual perceptível.

> **Clamp automático no Visual Builder:** O VB aplica `Math.min(0.95, Math.max(0.70, rawJq / 100))` ao valor introduzido — valores fora do intervalo são silenciosamente corrigidos para o limite mais próximo. A edição manual direta do token no código-fonte não tem este guard. Comportamento com valores fora de `[0.70, 0.95]` editados diretamente: o valor é passado sem clamp para `canvas.toBlob(type, quality)`. O standard HTML define que valores fora de `[0, 1]` fazem o browser usar a qualidade padrão da implementação (tipicamente ~0.92); valores no intervalo `[0, 1]` mas fora de `[0.70, 0.95]` são aceitos sem erro — apenas produzem os artefatos ou o desperdício de espaço documentados acima.

**`TOKEN_MAX_IMG_DIMENSION` (0 = sem limite):**
Se definido (ex: `1920`), qualquer imagem com dimensão superior é redimensionada antes de ser armazenada. Útil em ambientes onde o armazenamento é limitado. O redimensionamento preserva a proporção (aspect ratio).

> **Comportamento sem-op:** Se a imagem já tiver ambas as dimensões iguais ou inferiores ao limite configurado, nenhum redimensionamento ocorre — a imagem é armazenada tal como está.

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
| Nome da marca (topo) | `20px` | `600` | Logo principal |
| Section titles (labels uppercase) | `11px` | `600` | `letter-spacing: 0.6px` |
| Texto geral | `14px` | `400` | Body text |
| Botões `.btn-send` | `13px` | `600` | Altura `36px` |
| Ícones em botões | `14px` | — | `stroke-width: 2` |
| Ícones de cabeçalho `.blk-hdr svg` | `16px` | — | |
| Títulos de bloco `.blk-hdr-title` | `11px` | `600` | Uppercase |
| Badges `.count-badge`, `#trash-badge` | `11px` | `700` | |
| Item de histórico — nome | `12px` | `400` | |
| Item de histórico — data | `11px` | `400` | `--text-muted` |
| Título de modal `.modal-title` | `16px` | `600` | Centrado horizontalmente |
| Input de documento `.d-input` | `13px` | `400` | **Sem negrito** — não é um título, é um nome de arquivo |
| Legenda de imagem `.t-label` | `11px` | `400` | **Sem negrito** — discreta, não distrai da imagem |
| Links de ação `.pick-link` | `13px` | `400` | Em empty states |

---

## 9. Padrão de Botões em Modais

| Ação | Estilo | Cor | Quando aparece |
|---|---|---|---|
| **Restaurar** | Fill accent | `var(--accent)` + branco | Apenas se o item está na lixeira |
| **Copiar Texto** | Fill accent | `var(--accent)` + branco | Apenas em documentos de texto (não binários) |
| **Download** | Outline | `var(--surface)` + `var(--text)` + `var(--border)` | Sempre — ativos e na lixeira |
| **Confirmar** (anotação) | Fill verde | `var(--color-green)` | No modo de anotação |
| **Cancelar** (anotação) | Outline | `var(--surface)` + `var(--text)` + `var(--border)` | No modo de anotação |

---

## 10. Responsividade

A interface tem dois breakpoints de adaptação:

### `max-width: 900px` — Tablets e smartphones em paisagem

- Layout muda de horizontal para vertical (painéis empilhados)
- A sidebar de histórico (desktop: coluna lateral direita) transforma-se em um **modal centralizado** em vez de drawer lateral — aumenta a área de toque e facilita uso com o polegar
- O botão de histórico fica na barra de topo
- FAB mobile (`#mobile-paste-fab`) fica visível — botão flutuante para colar do clipboard
- `pointer-events: auto` e `touch-action: manipulation` garantem que 100% da superfície de cada card responde a toque

### `max-width: 480px` — Smartphones em retrato

- Padding e margens reduzidos para maximizar área útil
- Todos os elementos comprimem proporcionalmente

**Body Scroll Lock:** Quando o modal de histórico abre em mobile, `document.body.style.overflow = 'hidden'` previne que o conteúdo de fundo role. Ao fechar, o scroll é restaurado.

---

## 11. Comportamento de Bordas

Uma das decisões de design mais impactantes foi padronizar *quando* as bordas aparecem e desaparecem. Bordas que surgem apenas no hover criam layout shift (o elemento "salta" 1px quando o cursor passa).

### Botões de Captura ("Adicionar Imagem" / "Adicionar Documento")

| Estado | Borda |
|---|---|
| **Repouso** | `1px solid var(--border-strong)` — sempre visível, cinzenta |
| **Hover** | `border-color: var(--accent)` — transição suave para azul |
| **Regra** | A borda **nunca desaparece**. Elimina layout shift. |

### Botões de Export ZIP em Modo ZIP Ativo (`.btn-zip-cta`)

| Estado | Borda |
|---|---|
| **Repouso** | `1px solid var(--accent)` — azul permanente |
| **Hover** | Fundo sutil `rgba(14,165,233,0.06)` + texto mais escuro |
| **Regra** | A borda accent **não desaparece** ao sair com o cursor. |

### Chips de Modo (Auto / A4 Vertical / A4 Horizontal)

| Estado | Borda | Texto |
|---|---|---|
| **Selecionado — repouso** | `1px solid var(--border-strong)` | `var(--text)` |
| **Selecionado — hover** | `border-color: var(--accent)` | `var(--text)` |
| **Não selecionado — qualquer estado** | `border: none` | `var(--text-muted)` |

*Chips inativos são sem borda em todos os estados — comunica claramente "este não está selecionado".*

### FAB Mobile (`#mobile-paste-fab`)

| Estado | Visual |
|---|---|
| **Repouso** | Ícone `var(--text-muted)`, borda `var(--border-strong)` — neutro, discreto |
| **Hover** | Ícone `var(--text)`, borda `var(--text-muted)` — reforço sutil |
| **`:active` (toque)** | Ícone e borda em `var(--accent)` — feedback preciso no momento do toque |

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
| `annTool` | `'rect'` | Ferramenta ativa: `rect` / `circle` / `arrow` / `free` / `text` |
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
| `--drop-ph-bg` | `color-mix(in srgb, var(--text) 5%, transparent)` | Cor de fundo do placeholder de arrasto — área muito sutil que indica onde o item irá cair. Alterável apenas por desenvolvedor com acesso ao código-fonte. |
| `--drop-ph-border` | `color-mix(in srgb, var(--text) 8%, transparent)` | Cor da borda do placeholder de arrasto. Ligeiramente mais visível que o fundo para delimitar a área. Alterável apenas por desenvolvedor com acesso ao código-fonte. |

### Formato de Entradas em `annHistory`

Cada entrada é um objeto com pelo menos `{type, color, lw}` e campos adicionais por tipo:

| `type` | Campos obrigatórios | Notas |
|---|---|---|
| `rect` | `x1, y1, x2, y2` | Coordenadas dos dois cantos opostos |
| `circle` | `x1, y1, x2, y2` | Bounding box da elipse |
| `arrow` | `x1, y1, x2, y2` | Origem → destino da seta |
| `free` | `pts: [{x,y}]`, `closed` (sempre `false` desde a V23) | Salvo com **os mesmos pontos do preview** (`annPath`) — sem simplificação RDP e sem fechamento automático do contorno. Ver changelog V23. |
| `text` | `x1, y1, txt, bold, italic, fontSize` | `txt` pode conter `\n` (multilinha) — `annDrawShape` desenha linha a linha com `lineH = fontSize × ANN_TEXT_LINE_RATIO`. `textBaseline='top'`; `x1/y1` = canto superior esquerdo da 1.ª linha |


---

*Capture Engine V24 · Especificações de Design Tokens*
