# Design Tokens · Capture Engine v1.0

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
| `--thumb-size` | `96px` | Tamanho da caixa de thumbnail de imagem |

> [!IMPORTANT]
> **Cantos das Imagens**: Imagens têm uma regra geométrica técnica contrastante.
> Os seletores `.t-item`, `.t-wrap`, e `.t-label` têm `border-radius: 0` aplicado de forma estrita, garantindo cantos perfeitamente retos (quadrados) exclusivamente para evidências visuais. Os botões e cartões textuais preservam suas curvas arredondadas.

---

## 4. Z-Index Stack

| Camada | Valor | Elemento / Componente |
|---|---|---|
| Base | `0` | Grelha de conteúdos, listas de thumbs e painéis |
| Banner | `1000` | Barra de aviso para restaurar sessões antigas |
| Modal overlay | `9999` | `#img-modal-overlay`, `#text-modal-overlay` e `#confirm-overlay` |

---

## 5. Animações

| Nome da Animação | Efeito e Uso |
|---|---|
| `fadeIn` | Entrada suave de novos thumbnails e documentos colados |
| `modalIn` | Escalonamento e opacidade suaves ao abrir modais (scale `0.96` para `1`) |
| `slideDown` | Aparição descendente do banner de restauro superior |
| `fadeInTab` | Transição rápida entre abas do painel Visual Builder |
| `spin` | Indicador giratório em botões de exportação pendentes (PDF/ZIP) |

---

## 6. JS Tokens (SSOT)

Estes tokens são injetados no código por substituição via regex no Quine Engine aquando da exportação de uma build.

| Token | Tipo | Valor Padrão | Aba no Visual Builder |
|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture'` | Interface |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | Interface |
| `TOKEN_TITLE_END` | `string` | `''` | — |
| `TOKEN_SUBTITLE` | `string` | `''` | Interface |
| `TOKEN_MAIN_COLOR` | `hex` | `'#0ea5e9'` | Interface |
| `TOKEN_ACCENT_FG_OVERRIDE` | `hex` | `''` | Interface |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | Sessão |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | Sessão |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | Captura |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | Captura |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | Manutenção |
| `TOKEN_FOOTER_TEXT` | `string` | `''` | — |

---

## 7. Componentes — Anatomia

### Top Bar
```
[icon][Capture Engine]   [User][Equipamento]   [PDF][ZIP][⚙][💾][🌙]
  ↑ tb-brand             ↑ tb-session          ↑ tb-actions
```

### Layout Principal (Borderless & Geometric Panels)
```
┌──────────────────────────────┬──────────────────┬────┐
│  IMAGENS (Quadradas)          │  DOCUMENTOS      │ SB │
│  [blk-hdr]                   │  [blk-hdr]       │ ☰  │
│  ┌──────────────────────┐    │  ┌────────────┐  │    │
│  │ drop-zone / grid     │    │  │ doc-list   │  │    │
│  └──────────────────────┘    │  └────────────┘  │    │
└──────────────────────────────┴──────────────────┴────┘
```

### Visualizar documento (`#text-modal-overlay`)
```
┌──────────────────────────────────────────────────────┐
│  Visualizar documento - [Título]                 [X]  │
├──────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────┐  │
│  │ Console Area (Consolas, Monaco, Courier)       │  │
│  │                                                │  │
│  └────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────┤
│    [Restaurar]     [Copiar Texto]      [Download]     │
└──────────────────────────────────────────────────────┘
```

---

## 8. Regras Tipográficas

| Elemento / Classe | Tamanho (Font-size) | Peso (Font-weight) | Notas |
|---|---|---|---|
| Brand name | `15px` | `600` | Logo superior principal |
| Section titles | `11px` | `600` | Caixa alta com `letter-spacing: 0.6px` |
| Body text | `14px` | `400` | Texto geral |
| Document Inputs (`.d-input`) | `11px` | `400` (Normal) | Títulos de documentos sem negrito |
| Image Labels (`.t-label`) | `11px` | `400` (Normal) | Legendas de imagens sem negrito |
| Micro labels / Badges | `10-11px` | `400` a `600` | Badges de tamanho e estado |
| Modal title | `20px` | `600` | Título nos cabeçalhos de modais |

---

## 9. Responsividade

Breakpoint único de adaptação móvel: `max-width: 900px`
- Grelhas horizontais convertem-se em fluxos verticais fluidos.
- Barra lateral recolhida migra para o rodapé.
- Zonas de drop ajustam-se para toques diretos de dedo.

---

*Capture Engine v1.0 · Design Tokens Specification · FAANG Standards*
