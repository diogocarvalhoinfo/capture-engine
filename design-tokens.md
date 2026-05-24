# Design Tokens · Capture Engine V15

> Especificação completa do design system — a linguagem visual que define como a interface se vê, se comporta e se sente.

---

## O que são Design Tokens e porque existem?

Um **design token** é um nome simbólico para um valor visual. Em vez de escrever `#0ea5e9` diretamente no CSS, usamos `var(--accent)`. Em vez de escrever `36px` em cada botão, os botões têm sempre `height: 36px` por convenção documentada.

**Porquê usar tokens?**

1. **Consistência** — Mudar a cor principal em um lugar (`--accent`) muda em toda a interface
2. **Personalização via Quine** — O admin pode mudar a cor principal pelo Visual Builder; o Quine Engine substitui o valor do token no código exportado
3. **Dark mode sem duplicação** — Os tokens têm valores diferentes em `:root` (light) e `body.dark` (dark); o CSS que usa os tokens não precisa de saber em que modo está
4. **Legibilidade** — `color: var(--text-muted)` diz o que faz; `color: #6b6a66` não

---

## 1. Paleta de Cores

### Como o sistema de cores funciona

A paleta tem dois grupos:
- **Cores base** (não mudam entre light/dark): `--accent`, `--color-green`, `--color-red`, `--color-yellow` — mantêm o mesmo matiz mas adaptam-se ao fundo
- **Cores adaptativas** (mudam entre light/dark): `--bg`, `--surface`, `--border`, `--text`... — invertem ou ajustam conforme o modo

### Light Mode (`:root` — padrão)

| Token | Hex | Uso na interface |
|---|---|---|
| `--bg` | `#f4f3f0` | Fundo geral — um off-white quente, não puro, para reduzir fadiga visual |
| `--surface` | `#ffffff` | Superfície de painéis, cards, modais — branco puro para contraste com o fundo |
| `--border` | `#dddcd8` | Bordas subtis, linhas de separação — quase invisíveis, estruturam sem poluir |
| `--border-strong` | `#b5b3ae` | Bordas com mais presença — usadas em elementos de estado ativo ou hover |
| `--text` | `#1a1917` | Texto principal — quase preto, nunca puro (`#000000`) para suavizar o contraste |
| `--text-muted` | `#6b6a66` | Texto secundário — datas, legendas, metadados menos importantes |
| `--accent` | `#0ea5e9` | Cor de destaque primária (Tailwind sky-500) — botões, links, elementos ativos |
| `--accent-fg` | `#ffffff` | Texto legível sobre fundo accent — branco garante contraste WCAG |
| `--accent-hover` | `#0284c7` | Accent escurecido para hover (Tailwind sky-600) |
| `--color-green` | `#22c55e` | Sucesso, confirmação, "Gravado" |
| `--color-red` | `#ef4444` | Erro, remoção, ações destrutivas |
| `--color-yellow` | `#eab308` | Aviso, expiração próxima |

### Dark Mode (`body.dark`)

| Token | Hex | Nota |
|---|---|---|
| `--bg` | `#121212` | Preto quase puro — padrão Material Dark |
| `--surface` | `#1e1e1e` | Ligeiramente mais claro que o fundo — cria profundidade sem usar bordas |
| `--border` | `#333333` | Bordo escuro subtil |
| `--border-strong` | `#555555` | Bordo escuro mais visível |
| `--text` | `#e4e4e4` | Quase branco — nunca `#ffffff` puro (demasiado agressivo em fundos escuros) |
| `--text-muted` | `#9a9a9a` | Cinzento médio para elementos secundários |

> **Regra do dark mode:** O modo escuro ativa-se *exclusivamente* via classe CSS `body.dark`. A media query `prefers-color-scheme` é usada **apenas em JavaScript** (`initTheme`) como fallback na primeira abertura, quando não há preferência guardada em `localStorage`. Depois de o utilizador comutar manualmente, a escolha fica persistida. Isto dá ao utilizador controlo total — o sistema dele pode estar em dark mas ele pode querer a app em light.

> **Anti-FOUC (Flash of Unstyled Content):** Existe um script síncrono imediatamente após `<body>` que aplica `body.dark` *antes* de qualquer pintura do DOM. Sem isto, o utilizador em modo escuro veria um flash branco ao abrir a app.

---

## 2. Cores Semânticas — Estados de Feedback

Estas variáveis definem os estados de sucesso, erro e aviso de forma completa (fundo + borda + texto) para que qualquer banner ou alerta fique consistente sem ter de definir três cores manualmente.

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

*Em dark mode, os fundos usam `rgba` com baixa opacidade em vez de cores sólidas — para que a cor semântica se misture harmoniosamente com o fundo escuro sem criar um bloco de cor agressivo.*

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

> **Exceção geométrica — imagens têm cantos retos:** Os elementos `.t-item`, `.t-wrap` e `.t-label` (thumbnails de imagens e as suas legendas) têm `border-radius: 0`. Isto é intencional: imagens são *evidências técnicas*, não decoração. Cantos retos comunicam precisão e formalidade. Botões e cards textuais ficam com cantos arredondados para parecerem interativos e acessíveis.

### Medidas fixas de layout

| Token | Valor | Uso |
|---|---|---|
| `--top-bar-h` | `64px` | Altura estrita da barra de cabeçalho — consistente em todos os telas |
| `--thumb-size` | `140px` | Tamanho da caixa de thumbnail — todos os thumbs têm a mesma área |

---

## 4. Z-Index Stack — Quem fica à frente de quem

| Camada | Z-index | O que está aqui |
|---|---|---|
| Base | `0` | Conteúdo normal (grelha de thumbs, lista de documentos, painéis) |
| Banner | `1000` | Banners de aviso (ex: "Restaurar sessão anterior?") |
| Modal overlay | `9999` | Modais de imagem, texto, anotação — nada pode ficar à frente |

*Porquê apenas 3 níveis?* Uma stack de z-index com dezenas de valores é uma fonte constante de bugs ("porque é que o modal está a ficar atrás daquele elemento?"). Três níveis bem definidos eliminam a ambiguidade.

---

## 5. Animações

| Animação | O que faz | Onde é usada |
|---|---|---|
| `spin` | Rotação contínua | Spinner nos botões PDF/ZIP durante o processamento |
| `fadeIn` | Entrada com opacidade 0→1 | Novos thumbnails e documentos ao serem adicionados |
| `modalIn` | Escala `0.96→1` + opacidade | Entrada suave de todos os modais |
| `fadeInTab` | Opacidade rápida | Transição entre abas do Visual Builder |

*Todas as animações são curtas (150–300ms) e sem inércia. O objetivo é dar feedback imediato ao utilizador, não criar uma experiência cinematográfica que atrase a interação.*

---

## 6. Tokens JavaScript (SSOT — Single Source of Truth)

Estes tokens estão declarados como `const` no topo do IIFE do JavaScript. São a **fonte de verdade** para a configuração da app: o Visual Builder lê estes valores ao abrir, e o Quine Engine substitui-os ao exportar.

| Token | Tipo | Valor padrão | Onde se altera no VB |
|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture'` | Interface → "Texto Inicial" |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | Interface → "Texto em Destaque" |
| `TOKEN_TITLE_END` | `string` | `''` | *(obsoleto, preservado para integridade Quine)* |
| `TOKEN_SUBTITLE` | `string` | `''` | *(reservado, sem UI)* |
| `TOKEN_MAIN_COLOR` | `string` | `'#0ea5e9'` | Interface → Color picker principal |
| `TOKEN_ACCENT_FG_OVERRIDE` | `string` | `''` | Interface → Color picker de texto (vazio = automático) |
| `TOKEN_FOOTER_TEXT` | `string` | `'© {YEAR} • CAPTURE ENGINE'` | Interface → "Texto do Rodapé" (`{YEAR}` é substituído dinamicamente) |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | Histórico → "Campo 1" (toggle de visibilidade) |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | Histórico → "Campo 2" (toggle de visibilidade) |
| `TOKEN_USER_LABEL` | `string` | `''` | Histórico → "Rótulo — Campo 1" (vazio = mostra "User") |
| `TOKEN_EQUIP_LABEL` | `string` | `''` | Histórico → "Rótulo — Campo 2" (vazio = mostra "Equipamento") |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | Captura → "Qualidade do PDF" (0.70–0.95) |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | Captura → dimensão máxima de redimensionamento (0 = sem limite) |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | Manutenção → horas até purge automático |
| `TOKEN_DEBUG_MODE` | `bool` | `true` | *(sem UI — desativado automaticamente em exports de User)* |

**Como o Quine usa estes tokens:**

Ao exportar, o Quine Engine faz substituições por regex no código-fonte:
```js
html.replace(/const TOKEN_MAIN_COLOR='[^']*'/, "const TOKEN_MAIN_COLOR='#ff6600'")
```
Por isso, o formato exato da declaração `const TOKEN_XXXX='valor'` nunca pode ser alterado — o regex depende desta estrutura.

**`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL` com valor vazio:**

Um valor vazio (`''`) significa "usar o padrão visual". O Visual Builder mostra `User`/`Equipamento` como placeholder na UI, mas o token em si fica em `''`. O Quine só escreve um valor diferente de `''` se o admin *editar ativamente* o campo (controlado pela flag `_vbLabelDirty`). Exportar sem tocar nesses campos preserva a flexibilidade — o token vazio faz o motor usar o padrão correto.

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
│  └────────────────────────────────────────────────────┘  │    só visível
├──────────────────────────────────────────────────────────┤    quando zoom > 100%
│  [Restaurar]  [Download]           1920 × 1080 · 245 KB  │
└──────────────────────────────────────────────────────────┘
```

*A barra `#zoom-ui` usa glassmorphism: `background: rgba(25,25,25,0.7)` + `backdrop-filter: blur(10px)`. Flutua sobre a imagem com texto e ícones sempre a `#fff` independentemente do conteúdo da imagem por baixo.*

*O fecho por clique no backdrop está bloqueado quando o zoom > 100% — evita fechos acidentais durante o panning (arrastar a imagem ampliada).*

### Modal de Documento (`#text-modal-overlay`)

```
┌──────────────────────────────────────────────────────────┐
│  Visualizar documento — relatorio.txt               [×]  │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│  │ Texto: área de texto com fonte monoespaçada        │  │  ← modo texto
│  │ (Consolas, Monaco)                                 │  │
│  └────────────────────────────────────────────────────┘  │
│
│  OU, para arquivos binários (PDF, DOCX, etc.):          │
│
│  ┌────────────────────────────────────────────────────┐  │
│  │           [ícone]  PDF                             │  │  ← modo binário
│  │   Faça download para visualizar o documento        │  │    textarea oculta
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  [Restaurar]  [Copiar Texto]  [Download]                  │
│   ↑ só se estiver na lixeira  ↑ oculto em modo binário   │
└──────────────────────────────────────────────────────────┘
```

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
| Legenda de imagem `.t-label` | `11px` | `400` | **Sem negrito** — label discreta, não distrai da imagem |
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
- A sidebar de histórico (desktop: coluna lateral direita) transforma-se num **modal centralizado** em vez de drawer lateral — aumenta a área de toque e facilita o uso com o polegar
- O botão de histórico fica na barra de topo
- FAB mobile (`#mobile-paste-fab`) fica visível — botão flutuante para colar do clipboard sem atalho de teclado
- `pointer-events: auto` e `touch-action: manipulation` garantem que 100% da superfície de cada card responde a toque

### `max-width: 480px` — Smartphones em retrato

- Padding e margens reduzidos para maximizar a área útil
- Todos os elementos comprimem proporcionalmente

**Body Scroll Lock:** Quando o modal de histórico abre em mobile, `document.body.style.overflow = 'hidden'` previne que o conteúdo de fundo role enquanto o utilizador navega no modal.

---

## 11. Comportamento de Bordas V15

Uma das decisões de design mais impactantes foi padronizar *quando* as bordas aparecem e desaparecem. O problema com bordas que surgem apenas no hover é que criam layout shift (o elemento "salta" 1px quando o cursor passa por cima).

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

*Chips inativos são completamente sem borda em todos os estados — comunica claramente "este não está selecionado". Apenas os chips ativos têm borda.*

### FAB Mobile (`#mobile-paste-fab`)

| Estado | Visual |
|---|---|
| **Repouso** | Ícone `var(--text-muted)`, borda `var(--border-strong)` — neutro, discreto |
| **Hover** | Ícone `var(--text)`, borda `var(--text-muted)` — reforço subtil |
| **`:active` (toque)** | Ícone e borda em `var(--accent)` — feedback preciso apenas no momento do toque |

*O accent aparece só no `:active` (e não no `:hover`) porque em mobile o "hover" não existe da mesma forma — o dedo ou toca ou não toca. Manter accent no hover desktop seria enganador no contexto mobile.*

---

*Capture Engine V15 · Design Tokens Specification · FAANG Standards*
