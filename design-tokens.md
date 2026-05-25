# Design Tokens · Capture Engine V17

> Especificação completa do design system — a linguagem visual que define como a interface se vê, se comporta e se sente.

---

## O que são Design Tokens e porque existem?

Um **design token** é um nome simbólico para um valor visual. Em vez de escrever `#0ea5e9` diretamente no CSS, usamos `var(--accent)`. Em vez de escrever `36px` em cada botão, os botões têm sempre `height: 36px` por convenção documentada.

**Porquê usar tokens?**

1. **Consistência** — Mudar a cor principal em um lugar (`--accent`) muda em toda a interface automaticamente
2. **Personalização via Quine** — O admin muda a cor pelo Visual Builder; o Quine Engine substitui o valor no arquivo exportado
3. **Dark mode sem duplicação** — Os tokens têm valores diferentes em `:root` (light) e `body.dark` (dark); o CSS que usa os tokens não precisa de saber em que modo está
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
| `--bg` | `#f4f3f0` | Fundo geral — off-white quente (não puro) para reduzir fadiga visual |
| `--surface` | `#ffffff` | Superfície de painéis, cards, modais — branco puro para contraste com o fundo |
| `--border` | `#dddcd8` | Bordas subtis, linhas de separação — estruturam sem poluir |
| `--border-strong` | `#b5b3ae` | Bordas com mais presença — elementos de estado ativo ou hover |
| `--text` | `#1a1917` | Texto principal — quase preto (nunca `#000000` puro — muito agressivo) |
| `--text-muted` | `#6b6a66` | Texto secundário — datas, legendas, metadados menos importantes |
| `--accent` | `#0ea5e9` | Cor de destaque primária (Tailwind sky-500) — botões, links, elementos ativos |
| `--accent-fg` | `#ffffff` | Texto legível sobre fundo accent — branco garante contraste WCAG |
| `--accent-hover` | `#0284c7` | Accent escurecido para hover (Tailwind sky-600) |
| `--color-green` | `#22c55e` | Sucesso, confirmação, estado "Gravado" |
| `--color-red` | `#ef4444` | Erro, remoção, ações destrutivas |
| `--color-yellow` | `#eab308` | Aviso, expiração próxima |

### Dark Mode (`body.dark`)

| Token | Hex | Nota |
|---|---|---|
| `--bg` | `#121212` | Quase preto — padrão Material Dark |
| `--surface` | `#1e1e1e` | Ligeiramente mais claro que o fundo — cria profundidade sem bordas |
| `--border` | `#333333` | Bordo escuro subtil |
| `--border-strong` | `#555555` | Bordo escuro mais visível |
| `--text` | `#e4e4e4` | Quase branco (nunca `#ffffff` puro — agressivo em fundos escuros) |
| `--text-muted` | `#9a9a9a` | Cinzento médio para elementos secundários |

> **Regra do dark mode:** Ativa-se *exclusivamente* via classe CSS `body.dark`. A media query `prefers-color-scheme` é usada **apenas em JavaScript** (`initTheme`) como fallback na primeira abertura, quando não há preferência guardada em `localStorage`. Depois de o utilizador comutar manualmente, a escolha fica persistida. Isto dá controlo total ao utilizador.

> **Anti-FOUC:** Existe um script síncrono imediatamente após `<body>` que aplica `body.dark` *antes* de qualquer pintura do DOM. Sem isto, o utilizador em dark mode veria um flash branco ao abrir a app.

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

*Em dark mode, os fundos usam `rgba` com baixa opacidade — a cor semântica mistura-se harmoniosamente com o fundo escuro sem criar blocos de cor agressivos.*

---

## 3. Layout e Forma

### Tipografia — Fonte do sistema

A interface usa `'Segoe UI', Arial, sans-serif` — a fonte nativa do Windows/Mac/Linux. Sem fontes externas (sem Google Fonts, sem CDN), para respeitar o ambiente air-gapped e para que a interface se pareça "em casa" no sistema operativo de cada utilizador.

### Raio de Canto — A escala de arredondamento

Existe uma escala de 5 níveis, cada um com um propósito específico:

| Token | Valor | Onde usar |
|---|---|---|
| `--radius-xxs` | `3px` | Badges, etiquetas de tamanho — micro-elementos |
| `--radius-xs` | `4px` | Inputs, chips de seleção — elementos pequenos interativos |
| `--radius-sm` | `6px` | Botões, cards de documentos — elementos de ação principais |
| `--radius-md` | `8px` | Painéis internos, caixas — contentores secundários |
| `--radius-lg` | `12px` | Modais e diálogos — elementos de maior destaque visual |

> **Exceção geométrica — imagens têm cantos retos:** Os elementos `.t-item`, `.t-wrap` e `.t-label` têm `border-radius: 0`. Isto é intencional: imagens são *evidências técnicas*, não decoração. Cantos retos comunicam precisão e formalidade. Botões e cards textuais ficam arredondados para parecerem interativos e acessíveis.

### Medidas fixas de layout

| Token CSS | Valor | Uso |
|---|---|---|
| `--top-bar-h` | `64px` | Altura estrita da barra de cabeçalho — consistente em todos os ecrãs |
| `--thumb-size` | `140px` | Tamanho da caixa de thumbnail — todos os thumbs têm a mesma área |

---

## 4. Z-Index Stack — Quem fica à frente de quem

| Camada | Z-index | O que está aqui |
|---|---|---|
| Base | `0` | Conteúdo normal (grelha de thumbs, lista de documentos, painéis) |
| Banner | `1000` | Banners de aviso (ex: "Restaurar sessão anterior?") |
| Modal overlay | `9999` | Modais de imagem, texto, anotação — nada pode ficar à frente |

*Porquê apenas 3 níveis?* Uma stack com dezenas de valores é fonte constante de bugs. Três níveis bem definidos eliminam ambiguidade. **Não adicionar novos valores sem documentar aqui e em `agents.md`.**

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

Estes tokens estão declarados como `const` no topo do IIFE do JavaScript. São a **fonte de verdade** para a configuração: o Visual Builder lê estes valores ao abrir, e o Quine Engine substitui-os ao exportar.

| Token | Tipo | Valor padrão | Alterável no VB | Aba VB |
|---|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture'` | ✅ | Interface → "Texto Inicial" |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | ✅ | Interface → "Texto em Destaque" |
| `TOKEN_TITLE_END` | `string` | `''` | ❌ | Obsoleto — preservado para integridade do Quine |
| `TOKEN_SUBTITLE` | `string` | `''` | ❌ | Reservado — sem UI disponível |
| `TOKEN_MAIN_COLOR` | `string` | `'#0ea5e9'` | ✅ | Interface → color picker principal |
| `TOKEN_ACCENT_FG_OVERRIDE` | `string` | `''` | ✅ | Interface → color picker de texto |
| `TOKEN_FOOTER_TEXT` | `string` | `'© {YEAR} • CAPTURE ENGINE'` | ✅ | Interface → "Texto do Rodapé" |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | ✅ | Histórico → toggle "Campo 1" |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | ✅ | Histórico → toggle "Campo 2" |
| `TOKEN_USER_LABEL` | `string` | `''` | ✅ | Histórico → "Rótulo — Campo 1" |
| `TOKEN_EQUIP_LABEL` | `string` | `''` | ✅ | Histórico → "Rótulo — Campo 2" |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | ✅ | Captura → "Qualidade do PDF" |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | ✅ | Captura → dimensão máxima |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | ✅ | Captura → horas até purge |
| `TOKEN_DEBUG_MODE` | `bool` | `true` | ❌ | Sem UI — desativado automaticamente em Export User |

### Notas sobre tokens específicos

**`TOKEN_TITLE_END` (obsoleto):**
Este token não tem uso funcional na V17. Foi preservado para garantir que o Quine Engine, que usa regex para substituir todos os tokens, não quebre ao tentar encontrá-lo. Remover o token corromperia arquivos exportados de versões mais antigas. Não usar, não remover.

**`TOKEN_ACCENT_FG_OVERRIDE` (vazio = automático):**
Quando vazio (`''`), o motor calcula automaticamente se o texto sobre a cor accent deve ser branco ou preto, baseando-se na luminância relativa da cor accent. Preencher apenas se o cálculo automático não produzir o contraste desejado.

**`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL` (vazio = padrão visual):**
Um valor vazio significa "usar o padrão visual" (`User` / `Equipamento`). O Visual Builder mostra estes termos como placeholder, mas o token fica em `''`. Exportar sem editar estes campos preserva a flexibilidade — o motor usa o padrão correto conforme o contexto. A flag `_vbLabelDirty` controla se o admin editou ativamente estes campos.

**`TOKEN_JPEG_QUALITY` (0.70 a 0.95):**
Afeta apenas a geração do PDF — os arquivos originais na sessão ficam sempre em PNG. Valores abaixo de 0.70 produzem artefactos JPEG visíveis em screenshots com texto. Valores acima de 0.95 aumentam o tamanho do PDF sem benefício visual percetível.

**`TOKEN_MAX_IMG_DIMENSION` (0 = sem limite):**
Se definido (ex: `1920`), qualquer imagem com dimensão superior é redimensionada antes de ser armazenada. Útil em ambientes onde o armazenamento é limitado. O redimensionamento preserva a proporção (aspect ratio).

### Como o Quine usa estes tokens

O Quine substitui valores por regex no código-fonte:
```js
// O Quine procura exatamente este padrão:
html.replace(/const TOKEN_MAIN_COLOR='[^']*'/, "const TOKEN_MAIN_COLOR='#ff6600'")
```

**Por isso, o formato exato nunca pode ser alterado:**
- `const` (não `let` ou `var`)
- `TOKEN_NOME` (sem espaços)
- `=` (sem espaços)
- `'valor'` (aspas simples, não duplas)

---

## 7. Anatomia dos Componentes

### Barra de Topo

```
┌────────────────────────────────────────────────────────────────┐
│  [⬚] Capture Engine                         [⚙] [💾] [🌙]   │
│   ↑ logo + brand name                         ↑ tb-actions    │
│                                                                │
│                               [+ Sessão]  [↻]                 │
│                                ↑ btn-new-sess  ↑ btn-refresh  │
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
│ RODAPÉ  © 2026 • CAPTURE ENGINE                      (opacity: 0.5)  │
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

*O fecho por clique no backdrop está bloqueado quando zoom > 100% — evita fechos acidentais durante o panning.*

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
- A sidebar de histórico (desktop: coluna lateral direita) transforma-se num **modal centralizado** em vez de drawer lateral — aumenta a área de toque e facilita uso com o polegar
- O botão de histórico fica na barra de topo
- FAB mobile (`#mobile-paste-fab`) fica visível — botão flutuante para colar do clipboard
- `pointer-events: auto` e `touch-action: manipulation` garantem que 100% da superfície de cada card responde a toque

### `max-width: 480px` — Smartphones em retrato

- Padding e margens reduzidos para maximizar área útil
- Todos os elementos comprimem proporcionalmente

**Body Scroll Lock:** Quando o modal de histórico abre em mobile, `document.body.style.overflow = 'hidden'` previne que o conteúdo de fundo role. Ao fechar, o scroll é restaurado.

---

## 11. Comportamento de Bordas V17

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
| **Hover** | Fundo subtil `rgba(14,165,233,0.06)` + texto mais escuro |
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
| **Hover** | Ícone `var(--text)`, borda `var(--text-muted)` — reforço subtil |
| **`:active` (toque)** | Ícone e borda em `var(--accent)` — feedback preciso no momento do toque |

*O accent aparece só no `:active` (não no `:hover`) porque em mobile não há estado hover real — o dedo ou toca ou não toca.*

---

*Capture Engine V17 · Design Tokens Specification · FAANG Standards*
