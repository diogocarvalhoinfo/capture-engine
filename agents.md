# Agents · Capture Engine V9

> Regras operacionais obrigatórias para agentes de IA que editam o Capture Engine.

---

## 1. Regras Absolutas

### 1.1 Zero-Dependency
- **CDN PROIBIDO.** Nenhuma tag `<script src>` ou `<link href>` externa é permitida.
- Toda a lógica deve existir dentro do arquivo `capture-engine.html`.
- Nenhuma dependência npm, nenhuma biblioteca, nenhum framework.

### 1.2 Single-File Quine
- O arquivo é um **Quine auto-mutável**. Qualquer alteração deve preservar:
  - A capacidade do arquivo de se re-exportar via `window.exportFile()`
  - Todos os comment markers (`ADMIN_BUTTONS_START/END`, `ADMIN_EDIT_START/END`, `ADMIN_JS_START/END`, `EXPORT MODAL/FIM EXPORT MODAL`)
  - A função `capturePristine()` que captura o HTML original via `fetch(location.href)`

### 1.3 XSS Prevention
- Todo input do usuário deve passar por `escapeHTML()` antes de ser inserido no DOM via innerHTML.
- `sanitizeForQuine()` deve ser aplicado a qualquer valor antes de injeção no HTML durante export.
- Nunca usar `eval()`, `Function()`, ou `document.write()`.

### 1.4 Air-Gapped Environment
- O motor deve funcionar 100% offline, sem acesso à internet.
- Nenhum `fetch()` para URLs externas (apenas `fetch(location.href)` para Quine).
- LocalStorage e IndexedDB são os únicos mecanismos de persistência.

---

## 2. Convenções de Código

### 2.1 Linguagem
- **Código** em inglês (variáveis, funções, comentários técnicos)
- **Labels de UI** em português neutro harmonizado padrão V9 (ex: utilizar `"User"`, `"Equipamento"`, `"Documento"`, `"Screenshot"`, `"Download"`, `"Confirmar"`, `"Removidos"`, `"Processando..."`, `"Opções"`). Evitar termos regionais como `"ficheiro"`, `"descarregar"`, `"ecrã"`, `"utilizar"`.

### 2.2 CSS
- Todas as variáveis CSS definidas em `:root` e `body.dark`.
- Unidades em `px` (nunca `rem` ou `em`).
- Z-index: modais em `9999`, banners em `1000`.
- Dark mode via classe `body.dark` (nunca `prefers-color-scheme`).

### 2.3 Gold Standard — Escala e Proporção
- **Botões (`.btn-send`)**: `height:36px`, `font-size:13px`, `padding:0 18px`, SVG interno `14px`, `stroke-width:2`.
- **Spinner**: `14px`.
- **Inputs de sessão (`.sess-input`)**: `border: 1px solid transparent` por defeito. Borda visível apenas no focus com `box-shadow`.
- **Ícones de cabeçalho (`.blk-hdr svg`)**: `16px`.
- **Modais**: Título `16px` / Close `32px` circular com `background:var(--bg)` / SVG `16px` `stroke-width:2`.
- **Badges**: `.count-badge` a `11px`, `#trash-badge` a `10px`.
- **Sidebar sessions**: Nomes `12px`, datas `11px`, empty `12px`.
- **Empty states**: Título `14px`, pick-link `13px`.
- **Chips**: `flex-wrap:nowrap`, `flex:1 1 0` — sempre numa única linha, encolhem em vez de quebrar.

### 2.4 Estética e Design Geométrico
- Cartões de documentos (`.d-item`) e badges de tamanho (`.d-size`) devem permanecer **sem bordas visíveis** (transparentes/removidas).
- Legendas de imagens (`.t-label`) devem ter tamanho `11px` e inputs de documentos (`.d-input`) devem ter tamanho `13px`, ambos com peso de fonte normal (`font-weight: 400`), e a linha divisória sobre as legendas das imagens deve ser omitida.
- Imagens, wrappings de imagem e legendas de imagem devem possuir **bordas perfeitamente quadradas** (`border-radius: 0`). Cartões textuais e botões retêm cantos arredondados (`--radius-sm`, `--radius-md`).
- **Left sidebar**: `overflow-y:auto` com scrollbar invisível. Filhos com `flex-shrink:0` — scroll em vez de compressão.
- **Trash bar**: Ícones SVG inline `16px` (sem wrappers `sb-icon-btn`).

### 2.5 JavaScript
- IIFE obrigatório: `(function(){'use strict'; ... })();`
- SysLogger para logging (nunca `console.log` directo em código de produção).
- Funções expostas ao DOM via `window.funcName = ...`.
- `const $=id=>document.getElementById(id)` como selector padrão.

---

## 3. Políticas de Unicidade e Sequenciamento de Documentos (Militar)

Para prevenir colisões de arquivos que bloqueiem extrações de arquivos ZIP em sistemas operacionais, os agentes devem respeitar as seguintes políticas estritas:

### 3.1 Documentos Colados/Importados
- Documentos de texto colados do clipboard devem ser nomeados inicialmente como `texto-1.txt`.
- Se o nome já existir na lista de documentos ativos (`docs`), o motor deve decompor o sufixo numérico `-(\d+)`, incrementá-lo em uma unidade (ex: `texto-1` ➔ `texto-2` ➔ `texto-3`) e atualizar o nome. 
- **Nunca** acumular números secundários como `texto-1-1.txt`.
- Aplicar o mesmo validador inteligente durante renomeações manuais efetuadas pelo User via `window.setDocName`.

### 3.2 Screenshots Capturados
- Screenshots colados/capturados devem ser etiquetadas inicialmente como `imagem-1`.
- Se a etiqueta já estiver em uso, deve ser incrementada sequencialmente (`imagem-2`, `imagem-3`).
- Aplicar o mesmo validador inteligente para legendas redefinidas em `window.setLabel`.
- **ZIP Export:** Ao exportar arquivos para ZIP, omitir prefixos de indexação numéricos adicionais (`001-`). Utilizar diretamente as legendas das imagens limpas (`imagem-1.png`, `imagem-2.jpg`), garantindo que a sua unicidade natural preserva a estrutura.

### 3.3 Histórico de Sessões
- Sessões sem título explícito na barra lateral esquerda ("SESSÕES ANTERIORES") devem ser nomeadas dinamicamente com base na sua ordem cronológica de criação: `Sessão-1`, `Sessão-2`, `Sessão-3`, etc., em vez do termo `"Sem título"`.

---

## 4. Tokens (SSOT)

- Todos os tokens começam com `TOKEN_` e são declarados como `const` no topo do IIFE.
- Tokens são a **Single Source of Truth** — o Visual Builder lê e escreve neles via Quine.

---

## 5. Comment Markers

| Marker | Propósito | Stripped em User export? |
|---|---|---|
| `ADMIN_BUTTONS_START/END` | Botões admin na top bar | ✅ Sim |
| `ADMIN_EDIT_START/END` | Visual Builder modal | ✅ Sim |
| `ADMIN_JS_START/END` | Lógica Quine + Pristine | ✅ Sim |
| `EXPORT MODAL/FIM EXPORT MODAL` | Modal de exportação | ✅ Sim |

---

## 6. IndexedDB

- Database: `CaptureEngineDB` (versão 2)
- Stores: `sessions`, `images`, `documents`, `removed_images`, `removed_documents`.
- Auto-save a cada 5 segundos via `setInterval` no `boot()`.
- Purge automático na inicialização (`purgeExpired()`).

---

## 7. Workflow de Desenvolvimento

1. **Nunca** sobrescrever o arquivo inteiro — usar edições incrementais.
2. **Nunca** abrir o browser para testar — o humano testa.
3. Após cada alteração significativa, atualizar:
   - `readme.md` (se nova funcionalidade)
   - `design-tokens.md` (se novo token CSS ou JS)
   - `task.md` (marcar progresso)
4. Manter codificação UTF-8 sem BOM.

---

## 8. Checklist de Validação

Antes de declarar uma tarefa completa:

- [ ] `escapeHTML()` aplicado a todos os inputs interpolados em innerHTML.
- [ ] Comment markers intactos e funcionais.
- [ ] Sem duplicados de nomes em screenshots ou documentos.
- [ ] Visualizador de texto modal (`#text-modal-overlay`) validado e funcional nos Removidos.
- [ ] Estética borderless e simetria de cantos testados nos cards.
- [ ] Arquivo abre sem erros na console do browser.

---

*Capture Engine V9 · Agents Operational Rules · FAANG Standards*
