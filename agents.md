# Agents · Capture Engine v1.0

> Regras operacionais obrigatórias para agentes de IA que editam o Capture Engine.

---

## 1. Regras Absolutas

### 1.1 Zero-Dependency
- **CDN PROIBIDO.** Nenhuma tag `<script src>` ou `<link href>` externa é permitida.
- Toda a lógica deve existir dentro do ficheiro `capture-engine.html`.
- Nenhuma dependência npm, nenhuma biblioteca, nenhum framework.

### 1.2 Single-File Quine
- O ficheiro é um **Quine auto-mutável**. Qualquer alteração deve preservar:
  - A capacidade do ficheiro de se re-exportar via `window.exportFile()`
  - Todos os comment markers (`ADMIN_BUTTONS_START/END`, `ADMIN_EDIT_START/END`, `ADMIN_JS_START/END`, `EXPORT MODAL/FIM EXPORT MODAL`)
  - A função `capturePristine()` que captura o HTML original via `fetch(location.href)`

### 1.3 XSS Prevention
- **TODO** input do utilizador deve passar por `escapeHTML()` antes de ser inserido no DOM via innerHTML.
- `sanitizeForQuine()` deve ser aplicado a qualquer valor antes de injecção no HTML durante export.
- Nunca usar `eval()`, `Function()`, ou `document.write()`.

### 1.4 Air-Gapped Environment
- O motor deve funcionar 100% offline, sem acesso à internet.
- Nenhum `fetch()` para URLs externas (apenas `fetch(location.href)` para Quine).
- LocalStorage e IndexedDB são os únicos mecanismos de persistência.

---

## 2. Convenções de Código

### 2.1 Linguagem
- **Código** em inglês (variáveis, funções, comentários técnicos)
- **Labels de UI** em português neutro (aceitável para PT-BR e PT-PT)

### 2.2 CSS
- Todas as variáveis CSS definidas em `:root` e `body.dark`
- Unidades em `px` (nunca `rem` ou `em`)
- Z-index: modais em `9999`, banners em `1000`
- Dark mode via classe `body.dark` (nunca `prefers-color-scheme`)

### 2.3 JavaScript
- IIFE obrigatório: `(function(){'use strict'; ... })();`
- SysLogger para logging (nunca `console.log` directo em código de produção)
- Funções expostas ao DOM via `window.funcName = ...`
- `const $=id=>document.getElementById(id)` como selector padrão

### 2.4 HTML
- IDs únicos e descritivos para todos os elementos interactivos
- SVG inline (nunca imagens externas)
- Semantic markers para strip zones

---

## 3. Tokens (SSOT)

- Todos os tokens começam com `TOKEN_` e são declarados como `const` no topo do IIFE
- Tokens são a **Single Source of Truth** — o Visual Builder lê e escreve neles via Quine
- Ao adicionar um novo token:
  1. Declarar no bloco `TOKENS` do JS
  2. Adicionar UI correspondente no Visual Builder
  3. Adicionar replace pattern no `window.exportFile()`
  4. Documentar em `design-tokens.md` e `readme.md`

---

## 4. Comment Markers

| Marker | Propósito | Stripped em User export? |
|---|---|---|
| `ADMIN_BUTTONS_START/END` | Botões admin na top bar | ✅ Sim |
| `ADMIN_EDIT_START/END` | Visual Builder modal | ✅ Sim |
| `ADMIN_JS_START/END` | Lógica Quine + Pristine | ✅ Sim |
| `EXPORT MODAL/FIM EXPORT MODAL` | Modal de exportação | ✅ Sim |

### Anti-Cannibalização
- A função `sanitizeForQuine()` insere zero-width spaces nos nomes dos markers para evitar que o regex de strip apague partes do próprio código durante export.

---

## 5. IndexedDB

- Database: `CaptureEngineDB` (versão 2)
- 5 object stores: `sessions`, `images`, `documents`, `removed_images`, `removed_documents`
- Blobs armazenados directamente nos records (não como base64)
- Auto-save a cada 5 segundos via `setInterval` no `boot()`
- Purge automático na inicialização (`purgeExpired()`)

---

## 6. Workflow de Desenvolvimento

1. **Nunca** sobrescrever o ficheiro inteiro — usar edições incrementais
2. **Nunca** abrir o browser para testar — o humano testa
3. Após cada alteração significativa, actualizar:
   - `readme.md` (se nova funcionalidade)
   - `design-tokens.md` (se novo token CSS ou JS)
   - `task.md` (marcar progresso)
4. Manter encodificação UTF-8 sem BOM

---

## 7. Checklist de Validação

Antes de declarar uma tarefa completa:

- [ ] `escapeHTML()` aplicado a todos os inputs interpolados em innerHTML
- [ ] Comment markers intactos e funcionais
- [ ] Tokens documentados em todas as fontes (JS, VB, readme, design-tokens)
- [ ] Dark mode testado (variáveis CSS, não hardcoded colors)
- [ ] IIFE preservado (nenhuma variável global além de SysLogger e window.*)
- [ ] Ficheiro abre sem erros na consola do browser

---

*Capture Engine v1.0 · Agents Operational Rules*
