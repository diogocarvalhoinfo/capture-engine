# Design Tokens · Capture Engine v1.0

> Especificação completa do design system — CSS variables, JS tokens, z-index, componentes.

---

## 1. CSS Variables — Cores

### Light Mode (`:root`)

| Variável | Valor | Uso |
|---|---|---|
| `--bg` | `#f4f3f0` | Fundo global |
| `--surface` | `#ffffff` | Superfície de componentes |
| `--border` | `#dddcd8` | Bordas subtis |
| `--border-strong` | `#b5b3ae` | Bordas com contraste |
| `--text` | `#1a1917` | Texto principal |
| `--text-muted` | `#6b6a66` | Texto secundário |
| `--accent` | `#0ea5e9` | Cor principal (sky-500) |
| `--accent-fg` | `#ffffff` | Texto sobre accent |
| `--accent-hover` | `#0284c7` | Hover do accent |
| `--color-green` | `#22c55e` | Sucesso |
| `--color-red` | `#ef4444` | Erro / Remover |
| `--color-yellow` | `#eab308` | Aviso |

### Dark Mode (`body.dark`)

| Variável | Valor |
|---|---|
| `--bg` | `#121212` |
| `--surface` | `#1e1e1e` |
| `--border` | `#333333` |
| `--border-strong` | `#555555` |
| `--text` | `#e4e4e4` |
| `--text-muted` | `#9a9a9a` |

> **Regra**: Dark mode activa-se exclusivamente via classe `body.dark`. Nunca usar `prefers-color-scheme`.

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

| Variável | Valor | Uso |
|---|---|---|
| `--font` | `'Segoe UI',Arial,sans-serif` | Fonte global |
| `--radius-xxs` | `3px` | Micro (badges) |
| `--radius-xs` | `4px` | Pequeno (chips, inputs) |
| `--radius-sm` | `6px` | Normal (botões, cards) |
| `--radius-md` | `8px` | Médio (painéis) |
| `--radius-lg` | `12px` | Grande (modais) |
| `--top-bar-h` | `64px` | Altura da top bar |
| `--thumb-size` | `96px` | Tamanho das thumbnails |

---

## 4. Z-Index Stack

| Camada | Valor | Elemento |
|---|---|---|
| Base | `0` | Conteúdo normal |
| Banner | `1000` | Restore banner |
| Modal overlay | `9999` | Todos os modais e overlays |

---

## 5. Animações

| Nome | Uso |
|---|---|
| `fadeIn` | Thumbnails e doc items ao aparecer |
| `modalIn` | Modais ao abrir (scale 0.96→1) |
| `slideDown` | Restore banner ao aparecer |
| `fadeInTab` | Tabs do Visual Builder |
| `spin` | Spinner de loading nos botões |
| `shake` | Feedback de erro (reservado) |
| `pulse` | Pulsação subtil (reservado) |

---

## 6. JS Tokens (SSOT)

Declarados como `const` no topo do IIFE, substituídos pelo Quine Engine em export.

| Token | Tipo | Default | Visual Builder |
|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture'` | Aba Interface |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | Aba Interface |
| `TOKEN_TITLE_END` | `string` | `''` | — |
| `TOKEN_SUBTITLE` | `string` | `''` | Aba Interface |
| `TOKEN_MAIN_COLOR` | `hex` | `'#0ea5e9'` | Aba Interface |
| `TOKEN_ACCENT_FG_OVERRIDE` | `hex` | `''` | Aba Interface |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | Aba Sessão |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | Aba Sessão |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | Aba Captura |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | Aba Captura |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | Aba Manutenção |
| `TOKEN_FOOTER_TEXT` | `string` | `''` | — |

---

## 7. Componentes — Anatomia

### Top Bar
```
[icon][Capture Engine]   [utilizador][computador]   [PDF][ZIP][⚙][💾][🌙]
 ↑ tb-brand              ↑ tb-session               ↑ tb-actions
```

### Main Layout
```
┌──────────────────────────────┬──────────────────┬────┐
│  IMAGENS                     │  DOCUMENTOS      │ SB │
│  [blk-hdr]                   │  [blk-hdr]       │ ☰  │
│  ┌──────────────────────┐    │  ┌────────────┐  │    │
│  │ drop-zone / grid     │    │  │ doc-list   │  │    │
│  └──────────────────────┘    │  └────────────┘  │    │
└──────────────────────────────┴──────────────────┴────┘
┌───────────────────────────────────────────────────────┐
│  TRASH BAR (collapsible)                              │
└───────────────────────────────────────────────────────┘
```

### Botões de Acção
- `.btn-send` — Botão primário (accent background)
- `.action-btn` — Botão ícone redondo (transparent)
- `.ann-btn` — Botão de ferramenta de anotação

### Estados dos Botões
- `.st-success` → verde, pointer-events none, 2.5s timeout
- `.st-error` → vermelho, pointer-events none, 2.5s timeout
- `disabled` → `--border-strong` background

---

## 8. Regras Tipográficas

| Elemento | Font-size | Font-weight |
|---|---|---|
| Brand name | `15px` | `600` |
| Section titles | `11px` | `600` (uppercase, letter-spacing 0.6px) |
| Body text | `14px` | `400` |
| Labels/meta | `12px` | `400` |
| Micro labels | `10-11px` | `400–600` |
| Modal title | `20px` | `600` |

---

## 9. Responsividade

Breakpoint único: `max-width: 900px`

- Layout muda de horizontal → vertical
- Sidebar colapsa para barra horizontal fixa no fundo
- Painéis empilham verticalmente

---

*Capture Engine v1.0 · Design Tokens Specification*
