# Design Tokens · Capture Engine V14

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

> **Regra Absoluta**: O modo escuro ativa-se única e exclusivamente através da classe CSS `body.dark`. Nunca usar media queries `prefers-color-scheme` **no CSS**.
> O **JavaScript** (`initTheme` e script anti-FOUC) usa `window.matchMedia('(prefers-color-scheme: dark)')` como fallback quando o `localStorage` não contém preferência explícita — respeitando o tema do OS na primeira abertura. Após o utilizador comutar manualmente, a preferência é persistida no `localStorage`.
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
> Os seletores `.t-item`, `.t-wrap`, and `.t-label` têm `border-radius: 0` aplicado de forma estrita, garantindo cantos perfeitamente retos (quadrados) exclusivamente para evidências visuais. Os botões e cartões textuais preservam suas curvas arredondadas.

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
| `TOKEN_TITLE_START` | `string` | `'Capture'` | Interface — "Texto Inicial" |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | Interface — "Texto em Destaque" |
| `TOKEN_TITLE_END` | `string` | `''` | — (Obsoleto, preservado para integridade Quine) |
| `TOKEN_SUBTITLE` | `string` | `''` | — (Reservado, sem UI no VB) |
| `TOKEN_MAIN_COLOR` | `string` | `'#0ea5e9'` | Interface — Color picker principal |
| `TOKEN_ACCENT_FG_OVERRIDE` | `string` | `''` | Interface — Color picker foreground (vazio = auto) |
| `TOKEN_FOOTER_TEXT` | `string` | `'© {YEAR} • CAPTURE ENGINE'` | Interface — "Texto do Rodapé" |
| `TOKEN_USER_LABEL` | `string` | `''` | Histórico — "Rótulo — Campo 1" |
| `TOKEN_EQUIP_LABEL` | `string` | `''` | Histórico — "Rótulo — Campo 2" |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | Histórico — "Campo 1" (Oculta secção se ambos false) |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | Histórico — "Campo 2" (Oculta secção se ambos false) |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | Captura — "Qualidade do PDF" |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | Captura |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | Manutenção |
| `TOKEN_DEBUG_MODE` | `bool` | `true` | — (Controle de console em build de produção) |

> **TOKEN_USER_LABEL / TOKEN_EQUIP_LABEL:** Default `''` (vazio). O Visual Builder exibe `User`/`Equipamento` como valor visual inicial hardcoded na UI. O Quine apenas grava o token se o admin alterar o campo activamente (`_vbLabelDirty` flag por campo). Exportar sem editar preserva o token original.

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

### Visualizar imagem (`#img-modal-overlay`)
```
┌──────────────────────────────────────────────────────┐
│  Visualizar imagem - [Título]                    [X]  │
├──────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────┐  │
│  │ ┌────────────────────────────────────────────┐ │  │
│  │ │                                            │ │  │
│  │ │                  [Imagem]                  │ │  │
│  │ │                                            │ │  │
│  │ │                           [ - ] 100% [ + ] │ │  │
│  │ └─────────────────────────── ↑ zoom-ui ──────┘ │  │
│  └────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────┤
│ [Restaurar] [Download]             Dims/Size info    │
└──────────────────────────────────────────────────────┘
```

> [!TIP]
> **Glassmorphism Zoom UI**: O painel `#zoom-ui` está ancorado à base-direita. Flutua apenas se o zoom da imagem estiver ativo. Adota estilos translúcidos com `--radius-md` e texto/ícones unicamente brancos `#fff` para máximo contraste sobre fundos fotográficos dinâmicos.

### Left Sidebar (Flexível)

> [!IMPORTANT]
> A left sidebar utiliza `overflow-y: auto` com `scrollbar-width: none` (esconde scrollbar visualmente).
> - **Gap entre secções:** `clamp(10px, 2vh, 20px)` — comprime harmonicamente em ecrãs menores (antes: `clamp(12px,3vh,32px)` causava até 32px de espaço morto).
> - **Padding interno:** `clamp(10px, 1.5vh, 16px) 12px`.
> - **`.sb-section-title` na left sidebar:** `height: 28px` via selector `#left-sidebar .sb-section-title` — elimina espaço morto acima dos labels. O modal de histórico (`#sidebar .sb-section-title`) mantém `44px` para área de toque confortável.
> - **Mobile (`max-width: 900px`):** padding fixo `16px`, gap fixo `16px`, section titles `28px` via `#left-sidebar .sb-section-title`.
> - Os filhos usam `flex-shrink: 1` para manter visibilidade com compressão elástica.
> - A secção de título usa `flex-shrink: 0` para manter o tamanho natural e forçar scroll em vez de compressão.
> Chips de layout (`chips-group`) usam `flex-wrap: nowrap` com `flex: 1 1 0` para ocupar sempre uma única linha.
> **Comportamento de Sessão V14:** Ao abrir a aplicação, o histórico começa sempre vazio até à primeira interação. Ao apagar a sessão activa com vizinhas disponíveis, o `.active` move-se automaticamente para o item adjacente sem qualquer intervenção do utilizador.

### FAB Mobile (`#mobile-paste-fab`)

> [!NOTE]
> O botão flutuante de paste mobile segue o mesmo padrão visual dos CTAs de captura (PDF/ZIP):
> - **Repouso:** `color: var(--text-muted)`, `border: 1px solid var(--border-strong)` — totalmente neutro/cinzento.
> - **Hover:** `color: var(--text)`, `border-color: var(--text-muted)` — reforço subtil.
> - **`:active`:** `color: var(--accent)`, `border-color: var(--accent)` — accent ativa-se apenas no momento do toque, dando feedback preciso sem poluição visual em repouso.

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
| `#trash-badge` | `11px` | `700` | Badge de contador flutuante na Trash Bar `11px` Bold, bg `--color-red`, radius `99px` |
| `.sb-sess-item` | Item do histórico | padding `6px 12px`, radius `--radius-sm` |
| `.empty-st-sub` | Subtítulo do empty state | `12px`, `--border-strong` (Ocultado ou removido) |
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
- Barra lateral direita (sessões) converte-se num **Modal de Histórico** centralizado de luxo (flutuante com overlay escuro e pointer-events precisos).
- Zonas de drop ajustam-se para toques diretos de dedo.

---


---

## 11. Comportamento de Bordas V14 (Design Uniformity)

### CTAs de Captura (Botões "Adicionar Imagem" / "Adicionar Documento")
- **Estado padrão**: `border: 1px solid var(--border-strong)` — borda permanentemente ativa, visível em repouso.
- **Estado hover**: `border-color: var(--accent)` — transição suave para azul primário.
- **Regra**: A borda **nunca desaparece**. Antes do V14, estes botões tinham `border: 1px solid transparent` com borda apenas no hover, causando micro-instabilidade visual (layout shift em `border-width`).

### CTAs de Exportação ZIP ("Imagens em PDF" / "Imagens Separadas")
- **Classe CSS**: `.btn-send.btn-zip-cta` (substitui `.btn-outline` no modo ZIP ativo).
- **Estado padrão**: `border: 1px solid var(--accent)!important` — borda azul permanente.
- **Estado hover**: Adiciona fundo sutil `rgba(14,165,233,0.06)` e escurece a cor do texto.
- **Regra**: A borda accent **não desaparece** ao sair com o cursor.

### Chips de Seleção de Modo (Auto / Horizontal / Vertical)
| Estado | Borda | Cor de Texto |
|---|---|---|
| **Selecionado (default)** | `1px solid var(--border-strong)` | `var(--text)` |
| **Selecionado (hover)** | `border-color: var(--accent)` | `var(--text)` |
| **Não selecionado (default)** | `border: none` | `var(--text-muted)` |
| **Não selecionado (hover)** | `border: none` (inalterado) | `var(--text)` |

> **Regra**: Chips inativos são completamente sem borda em **todos os estados**. Chips ativos têm borda cinzenta por defeito e azul no hover. Antes do V14, todos os chips tinham borda azul no hover (mesmo inativos), criando inconsistência visual.

*Capture Engine V14 · Design Tokens Specification · FAANG Standards*
