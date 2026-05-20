# Design Tokens · Capture Engine V11

> Especificação completa do design system — CSS variables, JS tokens, z-index, componentes e estética borderless.

---

## 1. CSS Variables — Cores

### Light Mode (`:root`)

| Variável | Valor | Uso |
|---|---|---|
| `--bg` | `#f4f3f0` | Fundo global da aplicação |
| `--surface` | `#ffffff` | Superfície de componentes e painéis |
| `--border` | `#dddcd8` | Bordas e linhas de separação gerais |
| `--border-strong` | `#b5b3ae` | Bordas com alto contraste |
| `--text` | `#1a1917` | Texto principal e títulos |
| `--text-muted` | `#6b6a66` | Texto de apoio e legendas desativadas |
| `--accent` | `#0ea5e9` | Cor de destaque primária (sky-500) |
| `--accent-fg` | `#ffffff` | Texto legível sobre fundo accent |
| `--accent-hover` | `#0284c7` | Hover em elementos accent |
| `--color-green` | `#22c55e` | Estado de sucesso e confirmação |
| `--color-red` | `#ef4444` | Ação de erro ou remoção |
| `--color-yellow` | `#eab308` | Estado de aviso / aviso de expiração |

### Dark Mode (`body.dark`)

| Variável | Valor | Uso |
|---|---|---|
| `--bg` | `#121212` | Fundo geral em modo noturno |
| `--surface` | `#1e1e1e` | Superfícies em modo noturno |
| `--border` | `#333333` | Bordas escuras secundárias |
| `--border-strong` | `#555555` | Destaque de bordas em modo noturno |
| `--text` | `#e4e4e4` | Texto principal em modo noturno |
| `--text-muted` | `#9a9a9a` | Texto secundário em modo noturno |

> **Regra Absoluta**: O modo escuro ativa-se única e exclusivamente através da classe CSS `body.dark`. Nunca utilizar media queries `prefers-color-scheme`.
> **Estética Borderless**:
> - Elementos `.d-item` (cards de documentos) têm bordas definidas como `1px solid transparent` para flutuar organicamente sobre o fundo.
> - Badges de tamanho `.d-size` não possuem linhas limítrofes, exibindo apenas as dimensões de forma leve.
> **Carregamento Síncrono (Anti-Flicker)**:
> - O script inline localizado imediatamente após `<body>` aplica a classe `.dark` antes de qualquer pintura do DOM, prevenindo FOUC (Flash of Unstyled Content) ou flash branco em refreshes noturnos.

---

## 2. CSS Variables — Semânticas

### Estados de Feedback

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

---

## 3. CSS Variables — Layout e Forma

### Regras Geométricas e Cantos (Ajustes de Simetria)

| Variável | Valor | Uso |
|---|---|---|
| `--font` | `'Segoe UI',Arial,sans-serif` | Tipografia global (herança de sistema) |
| `--radius-xxs` | `3px` | Micro cantos (badges, etiquetas secundárias) |
| `--radius-xs` | `4px` | Pequenos cantos (inputs de dados, chips) |
| `--radius-sm` | `6px` | Cantos normais (botões, cards de documentos) |
| `--radius-md` | `8px` | Cantos médios (painéis e caixas internas) |
| `--radius-lg` | `12px` | Grandes cantos (diálogos, modais principais) |
| `--top-bar-h` | `64px` | Altura estrita da barra de cabeçalho |
| `--thumb-size` | `140px` | Tamanho da caixa de thumbnail de imagem |

> [!IMPORTANT]
> **Cantos das Imagens**: Imagens têm uma regra geométrica técnica contrastante.
> Os seletores `.t-item`, `.t-wrap`, e `.t-label` têm `border-radius: 0` aplicado de forma estrita, garantindo cantos perfeitamente retos (quadrados) exclusivamente para evidências visuais. Os botões e cartões textuais preservam suas curvas arredondadas.

---

## 4. Z-Index Stack

| Camada | Valor | Elemento / Componente |
|---|---|---|
| Base | `0` | Grelha de conteúdos, listas de thumbs e painéis |
| Banner | `1000` | Barra de aviso para restaurar sessões antigas |
| Modal overlay | `9999` | `#img-modal-overlay`, `#text-modal-overlay` |

---

## 5. Animações

| Nome da Animação | Efeito e Uso |
|---|---|
| `spin` | Indicador giratório em botões de exportação pendentes (PDF/ZIP) |
| `fadeIn` | Entrada suave de novos thumbnails e documentos colados |
| `modalIn` | Escalonamento e opacidade suaves ao abrir modais (scale `0.96` para `1`) |
| `fadeInTab` | Transição rápida entre abas do painel Visual Builder |

---

## 6. JS Tokens (SSOT)

Estes tokens são injetados no código por substituição via regex no Quine Engine aquando da exportação de uma build.

| Token | Tipo | Valor Padrão | Aba no Visual Builder |
|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture'` | Interface |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | Interface |
| `TOKEN_TITLE_END` | `string` | `''` | — |
| `TOKEN_SUBTITLE` | `string` | `''` | — (Obsoleto no visualizador, preservado para Quine) |
| `TOKEN_MAIN_COLOR` | `hex` | `'#0ea5e9'` | Interface |
| `TOKEN_ACCENT_FG_OVERRIDE` | `hex` | `''` | Interface |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | Sessão |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | Sessão |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | Captura |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | Captura |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | Manutenção |
| `TOKEN_DEBUG_MODE` | `bool` | `true` | — (Controle de console em build de produção) |

---

## 7. Componentes — Anatomia

### Top Bar
```
[icon][Capture Engine]                              [⚙][💾][🌙]
  ↑ tb-brand                                        ↑ tb-actions
```

### Layout Principal (Borderless & Geometric Panels)
```
┌────────────┬──────────────────────────┬──────────────────┬────┐
│ LEFT       │  IMAGENS (Quadradas)      │  DOCUMENTOS      │ SB │
│ SIDEBAR    │  [blk-hdr]                │  [blk-hdr]       │ ☰  │
│ ┌────────┐ │  ┌────────────────────┐   │  ┌────────────┐  │    │
│ │ User   │ │  │ drop-zone / grid   │   │  │ doc-list   │  │    │
│ │ Equip. │ │  └────────────────────┘   │  └────────────┘  │    │
│ │ Layout │ │                           │                  │    │
│ │ PDF    │ │                           │                  │    │
│ │ ZIP    │ │                           │                  │    │
│ └────────┘ │                           │                  │    │
└────────────┴──────────────────────────┴──────────────────┴────┘
```

### Visualizar documento (`#text-modal-overlay`)
```
┌──────────────────────────────────────────────────────┐
│  Visualizar documento - [Título]                 [X]  │
├──────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────┐  │
│  │ Texto: Console Area (Consolas, Monaco)         │  │
│  │ Binário: SVG icon + .EXT + mensagem centrada   │  │
│  └────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────┤
│    [Restaurar]     [Copiar Texto]      [Download]     │
└──────────────────────────────────────────────────────┘
```

> [!NOTE]
> **Modo Binário**: Para documentos não-textuais, o textarea e o botão "Copiar Texto" são ocultados.
> É exibido um ícone SVG de documento, a extensão em uppercase e uma mensagem informativa centrada.

### Left Sidebar (Flexível)

> [!IMPORTANT]
> A left sidebar utiliza `overflow-y: auto` com scrollbar invisível (`scrollbar-width: none`),
> garantindo que todo o conteúdo é acessível em qualquer altura de viewport.
> Os filhos usam `flex-shrink: 0` para manter o tamanho natural e forçar scroll em vez de compressão.
> Chips de layout (`chips-group`) usam `flex-wrap: nowrap` com `flex: 1 1 0` para ocupar sempre uma única linha.
> A navegação de sessões suporta estado `.active` destacado com cor harmónica suave e transição de opacidade, com botão de deleção fixo invisível por padrão (evitando pulos de layout ao transitar).

### Trash Bar (Semântica Inline)

> [!NOTE]
> A trash bar utiliza ícones SVG inline (16px) em vez de `sb-icon-btn` wrappers,
> mantendo o alinhamento direto com o texto "Removidos" e o badge de contagem.

### Rodapé de Créditos (`#footer-credits`)

> [!NOTE]
> O rodapé de créditos institucional (`© 2026 • CAPTURE ENGINE • DIOGOCARVALHOINFO.COM`) é posicionado de forma síncrona a 50% de opacidade (`opacity: 0.5`) no espaço de margem do trash bar de modo a não colapsar ou ocupar espaço extra na tela. Possui `pointer-events: none` para máxima invisibilidade operacional.

---

## 8. Regras Tipográficas

| Elemento / Classe | Tamanho (Font-size) | Peso (Font-weight) | Notas |
|---|---|---|---|
| Brand name | `20px` | `600` | Logo superior principal |
| Section titles | `11px` | `600` | Caixa alta com `letter-spacing: 0.6px` |
| Body text | `14px` | `400` | Texto geral |
| `.btn-send` | `13px` | `600` | Botões de ação. Altura `36px`, padding `0 18px` |
| `.btn-send svg` | `14px` | — | Ícones internos de botões |
| Document Inputs (`.d-input`) | `13px` | `400` (Normal) | Títulos de documentos sem negrito |
| Image Labels (`.t-label`) | `11px` | `400` (Normal) | Legendas de imagens sem negrito |
| `.blk-hdr svg` | `16px` | — | Ícones de cabeçalho de bloco |
| `.blk-hdr-title` | `11px` | `600` | Títulos de bloco uppercase |
| `.count-badge` | `11px` | `700` | Badges de contagem accent |
| `#trash-badge` | `10px` | `700` | Badge de contagem no trash bar |
| `.sb-sess-name` | `12px` | `500` | Nomes de sessão na sidebar |
| `.sb-sess-date` | `11px` | `400` | Datas de sessão na sidebar |
| `.empty-st-title` | `14px` | `500` | Títulos de estados vazios |
| `.pick-link` | `13px` | `400` | Links de acção nos estados vazios |
| `.modal-title` | `16px` | `600` | Título centralizado horizontalmente por padrão |
| `.modal-close` | `32px` (circle) | — | Botão fechar circular com `var(--bg)` posicionado absolutamente à direita |

---

## 9. Padrão de Botões em Modais

| Ação | Estilo | Cor |
|---|---|---|
| **Restaurar** | Accent fill (`.btn-send` default) | `var(--accent)` + `#fff` |
| **Copiar Texto** | Accent fill | `var(--accent)` + `#fff` |
| **Download** | Outline | `var(--surface)` + `var(--text)` + `border: var(--border)` |
| **Confirmar** (anotação) | Green fill | `var(--color-green)` |
| **Cancelar** (anotação) | Outline | `var(--surface)` + `var(--text)` + `border: var(--border)` |

> [!IMPORTANT]
> O botão Download está **sempre visível** em todos os modais, tanto para itens ativos como removidos (lixeira).

---

## 10. Responsividade

Dois breakpoints de adaptação móvel:
- **`max-width: 900px`** — Layout vertical, sidebar oculta, blocos empilhados
- **`max-width: 480px`** — Padding e margens compactos para telas pequenas

- Grelhas horizontais convertem-se em fluxos verticais fluidos.
- Barra lateral direita (sessões) é ocultada em mobile.
- Zonas de drop ajustam-se para toques diretos de dedo.

---

*Capture Engine V11 · Design Tokens Specification · FAANG Standards*
