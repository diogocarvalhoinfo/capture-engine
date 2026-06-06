# Agents · Capture Engine V24

> Guia operacional para desenvolvedores e agentes de IA que lêem, editam ou estendem o Capture Engine.
> **Leia a Seção 0 e a Seção 1 antes de qualquer outra coisa. Sem exceções.**

---

## Índice

- [Seção 0 — Modelo Mental](#0-modelo-mental--antes-das-regras)
- [Seção 1 — Regras Absolutas](#1-regras-absolutas)
- [Seção 2 — Convenções de Código](#2-convenções-de-código)
- [Seção 3 — Unicidade de Nomes](#3-unicidade-de-nomes--prevenção-de-colisões-no-zip)
- [Seção 4 — Ciclo de Vida da Sessão](#4-ciclo-de-vida-da-sessão)
- [Seção 5 — Comment Markers do Quine](#5-comment-markers--blocos-de-código-removíveis)
- [Seção 6 — IndexedDB — Schema Completo](#6-indexeddb--schema-completo)
- [Seção 7 — Funções Críticas — Referência Rápida](#7-funções-críticas--referência-rápida)
- [Seção 8 — Fluxos de Comportamento](#8-fluxos-de-comportamento)
- [Seção 9 — Variáveis de Estado Global](#9-variáveis-de-estado-global)
- [Seção 10 — Workflow de Desenvolvimento](#10-workflow-de-desenvolvimento-para-agentes)
- [Seção 11 — Checklist de Validação](#11-checklist-de-validação--antes-de-declarar-completo)
- [Seção 12 — Protocolo de Version Bump](#12-protocolo-de-version-bump)
- [Seção 13 — Decisões de Design Documentadas](#13-decisões-de-design-documentadas)
- [Seção 14 — Disaster Recovery Técnico](#14-disaster-recovery-técnico)

---

## Índice de Leitura por Perfil

Não é necessário ler o documento inteiro antes de cada tarefa. Use esta tabela:

| Situação | Ler obrigatoriamente |
|---|---|
| **Primeira vez a trabalhar no código** | §0, §1, §2, §3, §4, §5, §11 |
| **Corrigir um bug pontual** | §0, §1, §5, §11 + a secção do motor afectado |
| **Adicionar funcionalidade** | §0, §1, §2, §3, §4, §5, §7, §10, §11 |
| **Modificar o ciclo de sessões** | §0, §1, §4, §6, §7 (funções de sessão), §11 |
| **Modificar a anotação** | §0, §1, §7 (funções de anotação), §9, §11 |
| **Modificar o Quine / Export** | §0, §1, §1.2, §5, §7 (funções Quine), §11 |
| **Modificar tokens ou Visual Builder** | §1.2, §6, §7 (funções Quine), §13 |
| **Fazer version bump** | §12 |
| **Disaster recovery / recuperação de dados** | §14 |

---

Antes de ler as regras, é necessário entender *por que* elas existem. As regras não são arbitrárias — cada uma protege um dos três contratos fundamentais do motor:

### Contrato 1: O arquivo é a aplicação inteira

O `capture-engine.html` não é uma página que carrega recursos externos. É uma aplicação completa encapsulada num único arquivo. Isso significa:

- **Sem CDN.** Se colocar um `<script src="https://...">` qualquer, o arquivo deixa de funcionar em ambientes offline (bancos, hospitais, governo). O usuário final não terá internet.
- **Sem npm, sem bundler.** O arquivo tem de abrir com duplo clique num Windows sem internet e funcionar. Toda a lógica está inline.

*Consequência de violar:* A aplicação falha silenciosamente em qualquer ambiente sem internet. O usuário nunca saberá porquê.

### Contrato 2: O arquivo consegue copiar-se a si próprio

O motor tem uma funcionalidade chamada **Quine** — consegue exportar uma cópia de si próprio com configurações personalizadas. Para isso funcionar, o código-fonte original tem de estar recuperável e os marcadores de seção têm de estar intactos.

*Consequência de violar:* O Export Admin/User produz um arquivo corrompido ou incompleto que não abre corretamente no browser.

### Contrato 3: Os dados do usuário nunca chegam ao DOM sem sanitização

Qualquer texto que o usuário escreva (nome de sessão, legenda de imagem, nome de documento) pode conter caracteres especiais HTML. Se inseridos diretamente via `innerHTML`, um usuário malicioso pode injetar JavaScript — ataque XSS.

*Consequência de violar:* Vulnerabilidade de segurança em produção num ambiente onde o arquivo pode processar dados sensíveis (evidências jurídicas, dados de clientes).

---

## 1. Regras Absolutas

### 1.1 Zero-Dependency — Sem dependências externas

**O que não fazer:**
```html
<!-- PROIBIDO — quebra o modo offline -->
<script src="https://cdn.jsdelivr.net/..."></script>
<link rel="stylesheet" href="https://fonts.googleapis.com/...">
```

**Por quê:** O Capture Engine destina-se a ambientes totalmente isolados (sem internet). Um CDN externo é um ponto único de falha: se não houver rede, a app não carrega.

**Regra:** Toda a lógica, todo o CSS, todos os ícones SVG, devem estar inline dentro do `capture-engine.html`. Sem exceções.

---

### 1.2 Single-File Quine — O arquivo que se auto-reproduz

**Como funciona o Quine:**
1. `capturePristine()` faz `fetch(location.href)` para ler o próprio arquivo
2. Fallback para `BOOT_HTML` se o `fetch` falhar (ex: protocolo `file://` com restrições)
3. `exportFile()` substitui os valores dos tokens via regex

> **Aviso Técnico (CORS Local):** Ao testar localmente, abrir o arquivo HTML via protocolo `file://` no Chrome ou Safari causará uma falha imediata no `fetch(location.href)` devido a políticas rigorosas de CORS para recursos locais (o browser trata arquivos locais como origens opacas e proíbe `fetch` a si mesmos). O sistema sobrevive a isto porque `BOOT_HTML` captura a string estática do DOM exato (via `document.documentElement.outerHTML` adaptado) no momento do boot antes de qualquer mutação. O Quine opera sobre o fallback de forma imperceptível ao usuário.

> **Aviso Técnico (Servidor HTTP):** Se a ferramenta for servida via servidor HTTP (ex: `python -m http.server`, Apache, Nginx), o `fetch(location.href)` pode ter sucesso — mas retornar HTML **gerado dinamicamente pelo servidor** em vez do código-fonte original. Neste cenário, o Quine exportaria o DOM mutado pelo runtime (com contadores actualizados, legendas editadas) em vez do código limpo. O `BOOT_HTML` (fallback estático) não é utilizado quando o fetch tem sucesso. Para desenvolvimento local, usar um servidor que sirva o ficheiro estático sem processamento (ex: `python -m http.server` serve ficheiros estáticos directamente — é seguro neste caso). Em servidores com geração dinâmica de HTML, o Export pode produzir arquivos corrompidos silenciosamente.
4. Para exports de User, remove os blocos marcados com comment markers
5. Faz download do HTML resultante

**O que é `BOOT_HTML`:** Uma constante estática capturada no momento do boot, antes de qualquer mutação do DOM. É o fallback do Quine quando o `fetch(location.href)` não está disponível. Sem ela, o Quine exportaria o DOM mutado pelo runtime (com legendas editadas, contadores atualizados) em vez do código-fonte limpo.

**O que nunca alterar:**

| O quê | Onde | Porquê |
|---|---|---|
| `window.exportFile()` | `ADMIN_JS_START/END` | Ponto de entrada do Export |
| `capturePristine()` | `ADMIN_JS_START/END` | Lê o código-fonte original |
| `sanitizeForQuine()` | `ADMIN_JS_START/END` | Protege os marcadores de serem corrompidos pelo próprio conteúdo |
| `BOOT_HTML` | Dentro do bloco ADMIN_JS, no início do bloco | Fallback estático do Quine. Capturado sincronamente quando o script executa, antes de qualquer mutação de runtime. Em Export User este bloco é removido. |
| Todos os comment markers | Ver Seção 5 | Definem o que é removido em exports de User |

**Tokens de título — três partes:**

O título da app é composto por 3 spans independentes:
```
[TOKEN_TITLE_START][TOKEN_TITLE_ACCENT][TOKEN_TITLE_END]
     cor normal         opacity 0.5         cor normal
     font-weight 600    font-weight 400    font-weight 600
```
Os espaços entre as partes são **manuais** — incluir no valor do token se necessário. Exemplo para "Capture Engine": `TOKEN_TITLE_START='Capture '`, `TOKEN_TITLE_ACCENT='Engine'`, `TOKEN_TITLE_END=''`.

No Visual Builder, o campo "Texto Final" (cfg-title-end) controla `TOKEN_TITLE_END`. O Quine exporta os 3 tokens.

**Formato dos tokens:**
```js
// O regex do Quine aceita espaços, e devem ser mantidos para legibilidade:
const TOKEN_MAIN_COLOR = '#0ea5e9';
```

**Regra:** Qualquer alteração ao arquivo deve preservar todos os comment markers intactos e todas as funções Quine funcionais.

---

### 1.3 XSS Prevention — Sanitização de inputs

**O problema:** O browser interpreta HTML dentro de strings. Se um usuário escrever `<img src=x onerror=alert(1)>` como legenda e esse texto for inserido via `innerHTML`, o JavaScript executa.

> **Modelo de ameaça:** Embora a app seja local e de usuário único, o conteúdo capturado pode ter origem em terceiros (ex.: um screenshot ou documento com texto controlado por outra pessoa, colado por um técnico de Service Desk a partir de um ticket de cliente). Esse texto, ao ser renderizado sem sanitização, executaria no contexto do arquivo. Em ambientes que processam dados de clientes (setor bancário, seguros), isto é um risco real — daí a sanitização ser obrigatória.

**A solução:** Usar sempre `escapeHTML()` antes de qualquer `innerHTML` com dados do usuário:
```js
// ERRADO — vulnerável a XSS
element.innerHTML = `<span>${userInput}</span>`;

// CORRETO — seguro
element.innerHTML = `<span>${escapeHTML(userInput)}</span>`;
```

**Para o Quine:** Usar `sanitizeForQuine()` antes de injetar valores de tokens no HTML exportado. Esta função protege os comment markers de serem acidentalmente incluídos em valores de tokens (o que corromperia o arquivo exportado).

> **Comportamento adicional de `sanitizeForQuine()`:** Para além de proteger os 8 marcadores, a função também escapa aspas simples (`'` → `\'`). Tokens com apóstrofos (ex: `TOKEN_FOOTER_TEXT = '© 2026 • O'Brien Tools'`) são exportados com a aspa escapada — o arquivo resultante é sintaticamente correcto em JavaScript, mas quem inspecionar o HTML manualmente verá `O\'Brien` em vez de `O'Brien`. Este é o comportamento correcto e esperado.

**Nunca usar:**
- `eval()` — executa código arbitrário
- `Function()` — equivalente a eval
- `document.write()` — sobrescreve o DOM inteiro

---

### 1.4 Ambiente Isolado — Funcionar totalmente offline

**Regras práticas:**
- Nenhum `fetch()` para URLs externas (apenas `fetch(location.href)` para o Quine é permitido)
- Nenhuma fonte de ícones externa (todos os ícones são SVG inline)
- Nenhuma chamada a APIs externas
- Persistência apenas em `localStorage` e `IndexedDB` (mecanismos do browser, sem servidor)

---

## 2. Convenções de Código

### 2.1 Língua — Onde usar inglês e onde usar português

| Contexto | Língua | Exemplo |
|---|---|---|
| Nomes de variáveis, funções, comentários técnicos | Inglês | `captureImg()`, `sessId`, `isDirty` |
| Labels visíveis para o usuário na UI | Português neutro | `"Histórico"`, `"Removidos"`, `"Processando..."` |

**Português neutro — glossário aprovado:**

| ✅ Usar | ❌ Evitar | Razão |
|---|---|---|
| `"Arquivo"` | `"Ficheiro"` | Regionalismo PT-PT |
| `"Histórico"` | `"Sessões"` | Mais claro para usuários não-técnicos |
| `"Download"` | `"Descarregar"` | Termo universal |
| `"Equipamento"` | `"Máquina"` | Mais formal e neutro |
| `"Campo 1"`, `"Campo 2"` | `"User"`, `"Equipamento"` (hardcoded no VB) | Evergreen — funciona para qualquer domínio |

---

### 2.2 CSS — Unidades e Modo Escuro

**Usar `px`, nunca `rem` ou `em`**

Porquê: `rem` depende do `font-size` do `<html>`. Em ambientes corporativos com configurações de acessibilidade que alteram o tamanho de fonte do browser, `rem` produz layouts quebrados imprevisíveis. `px` é determinístico.

**Dark mode via `body.dark`, nunca via media query CSS**

Porquê: O usuário pode ter o sistema em dark mode mas querer a app em light mode. A class `body.dark` é controlada por JavaScript e persiste em `localStorage`. A media query `prefers-color-scheme` no CSS não permite override manual.

```css
/* CORRETO — controlável pelo usuário */
body.dark { --bg: #121212; }

/* PROIBIDO — não permite override manual */
@media (prefers-color-scheme: dark) { --bg: #121212; }
```

> **Exceção permitida:** `initTheme()` em JavaScript *pode* usar `window.matchMedia('prefers-color-scheme')` como fallback na primeira abertura (antes de o usuário ter definido preferência). O JS lê o OS, aplica a classe, e a partir daí o CSS faz o resto.

**Z-index stack (apenas 3 níveis — não adicionar outros sem documentar aqui):**
- `9999` → Modais (imagem, texto, anotação)
- `1000` → Banners (restaurar sessão)
- `0` → Conteúdo base

---

### 2.3 Tamanhos e Proporções Calibrados

Estes valores foram calibrados para simetria visual. Alterá-los quebra a harmonia visual.

| Elemento | Tamanho |
|---|---|
| Botões principais `.btn-send` | `height: 36px`, `font-size: 13px`, `padding: 0 18px` |
| Ícones dentro de botões | `14px`, `stroke-width: 2` |
| Ícones de cabeçalho de bloco `.blk-hdr svg` | `16px` |
| Spinner de loading | `14px` |
| Título de modal `.modal-title` | `16px`, centrado |
| Botão fechar modal `.modal-close` | `32px` circular, `background: var(--bg)` |
| Badges de contagem | `11px`, bold |
| Nomes na sidebar | `12px` |
| Datas na sidebar | `11px` |
| Legendas de imagem `.t-label` | `11px`, `font-weight: 400` (sem negrito) |
| Inputs de documento `.d-input` | `13px`, `font-weight: 400` (sem negrito) |

---

### 2.4 Estética Geométrica — Bordas e Cantos

**A lógica dos cantos:**

| Tipo de elemento | `border-radius` | Porquê |
|---|---|---|
| Botões, cards de texto, modais | `--radius-sm` a `--radius-lg` | Orgânicos, amigáveis |
| Imagens e legendas `.t-item`, `.t-label` | `0` (quadrado perfeito) | Técnico, preciso — card e legenda com cantos retos |
| Wrapper de thumbnail `.t-wrap` | `var(--radius-sm)` (6px) | Suaviza a moldura visual da imagem na grelha |

**Cards de documento sem bordas visíveis:**

Os `.d-item` têm `border: 1px solid transparent`. A borda existe no DOM (evita layout shift), mas é invisível.

---

### 2.5 JavaScript — Estrutura do Código

**IIFE obrigatório:**
```js
(function() {
  'use strict';
  // Todo o código aqui dentro
})();
```
Porquê: Isola completamente todas as variáveis do scope global da página. Previne colisões com APIs do browser ou scripts injetados.

**Selector padrão:**
```js
const $ = id => document.getElementById(id);
// Uso: $('btn-pdf') em vez de document.getElementById('btn-pdf')
```

**Logging — nunca `console.log` direto:**
```js
// ERRADO
console.log('imagem capturada');

// CORRETO
SysLogger.info('Imagem capturada: ' + label);
```
Porquê: `SysLogger` respeita `TOKEN_DEBUG_MODE`. Em exports de User, os logs desaparecem automaticamente.

**API do `SysLogger`:**

| Método | Quando faz output | Cor na consola |
|---|---|---|
| `SysLogger.info(msg)` | Apenas quando `TOKEN_DEBUG_MODE = true` | Verde `[CE]` |
| `SysLogger.warn(msg)` | Apenas quando `TOKEN_DEBUG_MODE = true` | Amarelo `[CE]` |
| `SysLogger.error(msg)` | **Sempre** — independente de `TOKEN_DEBUG_MODE` | Vermelho `[CE]` |

> **Importante:** `SysLogger.error` é o único método que persiste em exports de User. Usar exclusivamente para falhas reais (ex: IndexedDB inacessível, boot com erro) — nunca para debug.

**Funções expostas ao DOM (onclick inline):**
```js
// Para que onclick="window.delImg(id)" funcione dentro do IIFE
window.delImg = async function(id) { ... };
```
O IIFE isola o scope — funções chamadas por atributos HTML inline (`onclick="..."`) precisam estar em `window`.

---

## 3. Unicidade de Nomes — Prevenção de Colisões no ZIP

**O problema:** Nomes duplicados num ZIP causam comportamento imprevisível no Windows Explorer, macOS Archive Utility, e outros descompressores.

### Mecanismo de Identificadores (genId)
Para evitar colisões na base de dados, a função `genId(prefix)` é utilizada na criação de novos itens. Ela gera uma string única com **3 partes** separadas por `_`:

```
{prefix}_{Date.now()}_{5_chars_base36}
```

Exemplo real: `img_1748611200000_a3f7k`

- `prefix` — tipo do objeto (`img`, `doc`, `sess`)
- `Date.now()` — timestamp em milissegundos (13 dígitos) — garante ordenação cronológica e unicidade temporal
- `Math.random().toString(36).slice(2,7)` — 5 caracteres em base-36 — entropia adicional contra colisões no mesmo milissegundo

A probabilidade de colisão numa mesma sessão local (Single Page App no IndexedDB) é desprezável.

**O algoritmo de incremento inteligente:**

1. Nome inicial: `imagem-1` ou `texto-1.txt`
2. Se já existe, decompor o sufixo `-N`: `imagem-1` → extrair `1`
3. Incrementar: `imagem-2`, `imagem-3`, etc.
4. **Nunca** criar `imagem-1-1` — sempre incrementar o número existente

```
imagem-1 → imagem-2 → imagem-3   ✅
imagem-1 → imagem-1-1            ❌
```

**Verificação cross-list obrigatória:** A unicidade verifica-se contra *ambas* as listas simultaneamente — itens ativos **e** itens na lixeira. Um item restaurado da lixeira nunca colide com um ativo.

**Extensão de arquivo:** Ao renomear um documento, a extensão original é sempre preservada. Se o usuário escrever `relatorio` (sem extensão) num documento `.pdf`, o nome final é `relatorio.pdf`.

**Comparação case-insensitive:** Toda a deduplicação usa `.toLowerCase()` para evitar colisões entre `Imagem-1.png` e `imagem-1.png` no Windows (que é case-insensitive).

### 3.1 Nomes de Sessões sem Título

Sessões sem nome digitado recebem um identificador cronológico com zeros à esquerda: `#0001`, `#0002`, etc. O número reflete a ordem de criação absoluta — não a posição atual na lista.

---

## 4. Ciclo de Vida da Sessão

Este é o comportamento mais complexo do motor. Qualquer agente que edite código relacionado com sessões deve compreender este fluxo completamente.

### O modelo mental

Pense nas sessões como documentos num processador de texto:
- **Sessão ativa** = o documento aberto agora
- **Histórico** = outros documentos guardados
- **Pristine** = estado de "documento novo" — em branco

Ao abrir a aplicação, começa sempre com um documento novo. O histórico fica acessível mas a sessão ativa é sempre nova.

### Fluxo de estados

```
Abrir arquivo
      │
      ▼
init() → interface em branco (Pristine State)
      │
      ├── Sem interação ──────────────► Sessão não aparece no histórico
      │
      └── Primeira interação ─────────► ensureSession() confirma sessão
                                               │
                                               ▼
                                        renderSbSessions() → aparece no histórico
```

### Tabela de eventos obrigatórios

| Evento | Comportamento obrigatório |
|---|---|
| **Abrir a aplicação** | `init()` → interface em branco (Pristine State). Nunca reutilizar sessão existente. |
| **Primeira interação** | `ensureSession()` confirma e regista a sessão; `renderSbSessions()` faz-a aparecer no histórico. |
| **Digitar em User/Equipamento/Nome** | `isDirty=true` → `triggerSave()` **imediato** (não aguarda os 5 segundos). |
| **Apagar sessão NÃO ativa** | Apenas `renderSbSessions()`. A sessão ativa e o DOM ficam intactos. |
| **Apagar sessão ATIVA com vizinha** | Capturar `neighbor` *antes* da deleção: `allBefore[idx+1] \|\| allBefore[idx-1]`. Após deleção: `loadSession(neighbor.id)` + `renderSbSessions()`. |
| **Apagar sessão ATIVA sem vizinha** | Reset completo: `sessId=null`, `sessObj=null`, arrays zerados, DOM limpo, campos zerados. **Não criar nova sessão.** |
| **`createSession()` diretamente** | Apenas em `init()` e `ensureSession()`. Nunca chamar em `deleteSessionId()` ou handlers de evento. |

> **Porquê nunca criar sessão em `deleteSessionId`?** Porque o usuário que apaga a última sessão está a decidir ter uma interface vazia. Criar uma sessão automática seria ignorar a intenção do usuário — e causaria um loop onde apagar sempre gerava uma sessão nova no histórico.

### isDirty — O flag de alterações pendentes

`isDirty` é um boolean que indica se há dados não guardados. É `true` sempre que algo muda (captura de imagem, edição de legenda, reordenação). O auto-save de 5 segundos só corre quando `isDirty === true`. Após guardar, `isDirty` volta a `false`.

Digitação em campos de texto chama `triggerSave()` imediatamente (sem esperar os 5 segundos), para garantir que até os primeiros caracteres são persistidos imediatamente.

---

## 5. Comment Markers — Blocos de Código Removíveis

Os markers são comentários especiais que o Quine Engine usa para identificar e remover blocos inteiros no export de User.

| Marker | Conteúdo que protege | Removido em Export User? |
|---|---|---|
| `<!-- ADMIN_BUTTONS_START -->` ... `<!-- ADMIN_BUTTONS_END -->` | Botões ⚙️ e 💾 na barra de topo | ✅ Sim |
| `<!-- ADMIN_EDIT_START -->` ... `<!-- ADMIN_EDIT_END -->` | Modal do Visual Builder completo | ✅ Sim |
| `/* ADMIN_JS_START */` ... `/* ADMIN_JS_END */` | Funções `capturePristine()`, `exportFile()`, `sanitizeForQuine()` | ✅ Sim |
| `<!-- EXPORT MODAL -->` ... `<!-- FIM EXPORT MODAL -->` | Modal de escolha Admin/User export | ✅ Sim |

**Regra crítica:** Nunca mover código para dentro ou fora destes blocos sem entender as consequências. Código dentro de `ADMIN_JS_START/END` desaparece nos exports de User — se a funcionalidade for necessária para usuários normais, não pode estar nesse bloco.

**Proteção do Quine:** `sanitizeForQuine()` substitui os marcadores nos *valores de tokens* com versões contendo zero-width space (caractere invisível `\u200B`). Isto evita que um token com o texto `ADMIN_JS_START` corrompa o regex de strip. Aplica-se a todos os 8 marcadores (4 pares de abertura/fecho).

> **Nota sobre contagens — 8 vs 11:** existem **8 strings únicas de marcadores** (4 pares: ADMIN_BUTTONS, ADMIN_EDIT, ADMIN_JS, EXPORT MODAL), mas o `grep -c` no HTML retorna **11 linhas** porque os marcadores aparecem em 3 categorias de locais:
> - **8 locais estruturais** — os 4 pares de comentários/tokens HTML e JS que delimitam blocos removíveis
> - **1 linha em `boot()`** — o par `ADMIN_JS_START`/`ADMIN_JS_END` inline que envolve `capturePristine()`
> - **1 linha em `sanitizeForQuine()`** — os 8 nomes como strings para substituição com zero-width space
> - **1 linha em `exportFile()`** — os 4 pares como regex para remoção de blocos
>
> `sanitizeForQuine()` protege os 8 strings únicos; o checklist de integridade verifica as 11 linhas totais. Todos os números estão corretos — referem coisas diferentes.

> **Decisão de Design — Modal do VB não fecha ao clicar fora:** O modal do Visual Builder (`#vb-overlay`) **não fecha ao clicar no backdrop**. Esta é uma decisão intencional (alterada na V22). O usuário deve usar o botão ✕ para fechar. Todos os outros modais (imagem, documento, export) fecham ao clicar fora. A variável `_vbOverlayMdOnBackdrop` foi removida na V22 — era um resíduo da versão anterior em que o VB fechava ao clicar fora.

**Para verificar integridade dos markers:**
```bash
grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" capture-engine.html
# Deve retornar 11
# (8 strings únicas; 11 linhas = 8 estruturais + 1 em boot() + 1 em sanitizeForQuine() + 1 em exportFile())
```

---

## 6. IndexedDB — Schema Completo

**Nome da base de dados:** `CaptureEngineDB`
**Versão do schema:** `2`

> **Nota de migração de schema:** O `onupgradeneeded` actual usa `if (!db.objectStoreNames.contains(...))` — padrão aditivo seguro. Adicionar uma nova object store em V24+ é seguro sem migração destrutiva. Porém, **alterar campos de uma store existente** (ex: adicionar campo obrigatório a `images`) **não é seguro** com a lógica actual: o `onupgradeneeded` não executa para utilizadores já na versão 2. Qualquer alteração de schema existente requer incrementar a versão da base (`indexedDB.open('CaptureEngineDB', 3)`) e implementar lógica de migração explícita dentro de `onupgradeneeded`.

#### Como migrar o schema em segurança

**Caso A — Adicionar uma nova object store (seguro, sem migração destrutiva)**

Incrementar a versão e adicionar a store com `contains` guard — utilizadores existentes passam pelo `onupgradeneeded` e recebem a nova store; stores existentes e dados não são tocados:

```js
// Alterar: indexedDB.open('CaptureEngineDB', 2)  →  indexedDB.open('CaptureEngineDB', 3)
const r = indexedDB.open('CaptureEngineDB', 3);
r.onupgradeneeded = e => {
  const db = e.target.result;
  // Stores existentes — manter os guards para não recriar
  if (!db.objectStoreNames.contains('sessions')) { /* ... */ }
  // ... (todas as stores existentes mantidas como estão)

  // Nova store — adicionar aqui
  if (!db.objectStoreNames.contains('nova_store')) {
    const s = db.createObjectStore('nova_store', { keyPath: 'id' });
    s.createIndex('sessionId', 'sessionId', { unique: false });
  }
};
```

**Caso B — Alterar campos de uma store existente (requer migração de dados)**

Por exemplo, adicionar o campo `tags` à store `images`. Os registos existentes não têm `tags` — é necessário iterar e reescrever:

```js
// Alterar: indexedDB.open('CaptureEngineDB', 2)  →  indexedDB.open('CaptureEngineDB', 3)
const r = indexedDB.open('CaptureEngineDB', 3);
r.onupgradeneeded = e => {
  const db = e.target.result;
  const tx = e.target.transaction; // transação de upgrade — usar este, não criar novo

  // Stores existentes sem alteração — manter os guards
  if (!db.objectStoreNames.contains('sessions')) { /* ... */ }
  // ... (restantes stores inalteradas)

  // Migração de `images`: adicionar campo `tags` com valor padrão []
  // IMPORTANTE: usar a transação do upgrade (e.target.transaction), não idbTx()
  const imgStore = tx.objectStore('images');
  const req = imgStore.getAll();
  req.onsuccess = ev => {
    for (const record of ev.target.result) {
      if (record.tags === undefined) {
        record.tags = []; // valor padrão para registos existentes
        imgStore.put(record);
      }
    }
  };
};
```

> **Regras críticas de migração:**
> - Usar **sempre** `e.target.transaction` (a transação de upgrade) — não abrir transações novas dentro de `onupgradeneeded`
> - O `onupgradeneeded` é **atómico**: se alguma operação falhar, a base reverte para a versão anterior
> - Após a migração, incrementar também o comentário de versão no código: `// CaptureEngineDB versão 3`
> - **Testar com uma cópia de segurança dos dados** antes de distribuir — uma migração errada que seja distribuída aos utilizadores é irreversível

### Tabela: `sessions`

Índices: `createdAt`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | ✅ | ID único gerado por `genId('sess')` — chave primária |
| `name` | string | ❌ | Nome da sessão digitado pelo usuário (vazio = usa fallback #XXXX) |
| `user` | string | ❌ | Valor do Campo 1 (ex: "João Silva") |
| `pc` | string | ❌ | Valor do Campo 2 (ex: "PC-001") |
| `createdAt` | number | ✅ | Timestamp Unix (ms) da criação — imutável após criação |
| `updatedAt` | number | ✅ | Timestamp Unix (ms) da última atividade — atualizado a cada save |
| `exported` | boolean | ✅ | Definido como `false` na criação; passa a `true` quando `exportFile()` é chamado (Export Admin ou User). Atualmente informativo — nenhuma lógica de UI, purge ou Quine depende deste valor. Reservado para uso futuro (ex: marcar visualmente sessões já exportadas). |

### Tabela: `images`

Índices: `sessionId`, `order`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | ✅ | ID único gerado por `genId('img')` — chave primária |
| `sessionId` | string | ✅ | ID da sessão a que pertence |
| `blob` | Blob | ✅ | Dados binários da imagem (PNG, JPEG, WEBP, GIF) |
| `label` | string | ✅ | Nome/legenda da imagem (ex: `imagem-1`) — único dentro da sessão |
| `order` | number | ✅ | Posição na grelha (0-based) — define a ordem de exibição e export |
| `addedAt` | number | ✅ | Timestamp Unix (ms) de quando foi capturada |
| `origBlob` | Blob | ❌ | Imagem **original** antes da anotação. Criada por `ann-save` na primeira vez que se confirma uma anotação; usada por `annActivate` como fundo do canvas ao reeditar. Removida (e `blob` reposto ao original) se todas as anotações forem apagadas. Presente apenas em imagens anotadas. |
| `annHistory` | array | ❌ | Stack de formas anotadas (`{type, x1, y1, ...}`) persistida com a imagem para reedição posterior (anotação **não-destrutiva**). Presente apenas em imagens anotadas; removida quando fica vazia. |

### Tabela: `documents`

Índices: `sessionId`, `order`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | ✅ | ID único gerado por `genId('doc')` — chave primária |
| `sessionId` | string | ✅ | ID da sessão a que pertence |
| `blob` | Blob | ✅ | Dados binários do documento |
| `name` | string | ✅ | Nome do arquivo com extensão (ex: `relatorio.pdf`) — único dentro da sessão |
| `type` | string | ✅ | MIME type (ex: `text/plain`, `application/pdf`) |
| `size` | number | ✅ | Tamanho em bytes |
| `order` | number | ✅ | Posição na lista (0-based) |
| `addedAt` | number | ✅ | Timestamp Unix (ms) |

### Tabelas: `removed_images` e `removed_documents`

Mesmos campos das tabelas ativas, com adição de:

| Campo | Tipo | Descrição |
|---|---|---|
| `removedAt` | number | Timestamp Unix (ms) de quando foi movido para a lixeira |

**Nota:** Items na lixeira **não têm** campo `order` — a lixeira ordena por `removedAt`.

### Chaves de LocalStorage

O sistema utiliza localStorage para preferências que devem sobreviver a diferentes abas ou arquivos na mesma origem:
- `theme`: Controla o modo visual. Valores possíveis: `'dark'`, `'light'` ou `null` (neste caso cai para a preferência do OS).
- *Histórico:* A chave `ec_pending_session` foi utilizada em versões antigas e removida na V17.
Limpar o localStorage apenas reseta preferências visuais. Limpar o IndexedDB apaga os dados reais das sessões.

### Auto-save e Purge

**Auto-save e Falhas Assíncronas:** `setInterval` de 5 segundos no `boot()` chama `saveSession()` se `isDirty === true`. A função `triggerSave()` é chamada na digitação. Se o browser for fechado durante a janela de latência ou a transação falhar, as últimas mutações perdem-se.

**Esgotamento de Quota:** Se o limite de disco do browser for atingido, a gravação de novos blobs falha nativamente. O manipulador `tx.onerror` regista a exceção na consola. A aplicação falha silenciosamente na interface para não causar pânico de UX (já que as gravações são assíncronas em background e a captura visual na grelha acontece via URL local em memória temporária). A sessão já guardada e os itens antigos permanecem íntegros no DB.

**Purge:** `purgeExpired()` corre em cada `init()`. Apaga sessões cuja `updatedAt` seja mais antiga que `TOKEN_AUTO_PURGE_HOURS` horas. Apaga também todos os items associados (imagens, documentos, removidos das duas categorias).

> **Risco de redistribuição:** Se redistribuir com um valor de `TOKEN_AUTO_PURGE_HOURS` menor do que o anterior (ex: de 48h para 24h), sessões que antes sobreviveriam são purgadas na próxima abertura. O comportamento é correcto (o código usa sempre o valor actual do token), mas pode surpreender utilizadores com sessões em curso. Comunicar a mudança antes de redistribuir.

**Múltiplas instâncias (multi-aba permitido):** O `onblocked` apenas regista um aviso na consola — **não** bloqueia a interface. Em versões anteriores mostrava uma tela de erro vermelho que substituía o `body`; esse bloqueio foi removido na V23 (a pedido do proprietário). Várias abas partilham a mesma base `CaptureEngineDB`; a ressalva conhecida é a gravação concorrente na mesma sessão (a última gravação prevalece). Ver readme §7.

---

## 7. Funções Críticas — Referência Rápida

Esta seção documenta as funções mais importantes. Consultar antes de editar qualquer uma delas.

### Funções de Sessão

| Função | Assinatura | O que faz | Quando chamar |
|---|---|---|---|
| `createSession()` | `async () → void` | Cria sessão nova em branco e atualiza `sessId`/`sessObj` | Apenas em `init()` e `ensureSession()` |
| `ensureSession()` | `async () → void` | Confirma sessão se não existe; usa mutex `_ensurePromise` | Antes de qualquer captura (chamada por `captureImg`/`captureDoc`) |
| `loadSession(id)` | `async (string) → void` | Carrega sessão do IndexedDB para memória e renderiza | Ao navegar para sessão existente |
| `saveSession()` | `async () → void` | Persiste sessão atual no IndexedDB | Pelo auto-save e `triggerSave()` |
| `triggerSave()` | `async () → void` | Chama `saveSession()` se `isDirty`, reseta flag | Em digitação e após capturas |
| `deleteSessionId(id)` | `async (string) → void` | Apaga sessão e todos os seus items; navega ou reset | No botão ✕ da sidebar |
| `renderSbSessions()` | `async () → void` | Re-renderiza a lista de sessões na sidebar | Após qualquer alteração de sessão |

### Funções do IndexedDB

| Função | Assinatura | O que faz | Quando chamar |
|---|---|---|---|
| `idbTx(store, mode, fn)` | `(string, string, Function) → Promise` | Wrapper transacional para IndexedDB com gestão de erro e fallback. `fn` recebe o `objectStore` e deve retornar um `IDBRequest` (ex: `st => st.get(id)`). | Base para todas as leituras e escritas |

**Atalhos sobre `idbTx` (usar em vez de `idbTx` diretamente):**

| Função | Assinatura | O que faz |
|---|---|---|
| `idbPut(store, data)` | `(string, object) → Promise` | Insere ou substitui um registo (upsert). `data` deve conter a chave primária. |
| `idbGet(store, id)` | `(string, any) → Promise<object>` | Lê um registo pela chave primária. Retorna `undefined` se não existir. |
| `idbAll(store)` | `(string) → Promise<array>` | Retorna todos os registos da store como array. |
| `idbDel(store, id)` | `(string, any) → Promise` | Apaga o registo com a chave primária dada. |
| `idbIdx(store, idx, val)` | `(string, string, any) → Promise<array>` | Retorna todos os registos onde o índice `idx` é igual a `val`. Ex: `idbIdx('images', 'sessionId', sessId)`. |

### Funções de Captura

| Função | Assinatura | O que faz |
|---|---|---|
| `captureImg(blob)` | `async (Blob) → void` | Captura imagem: gera label único, guarda em IndexedDB, renderiza thumb |
| `captureDoc(blob, name, type)` | `async (Blob, string, string) → void` | Captura documento: gera nome único, guarda em IndexedDB, renderiza card |

### Funções de Renderização

| Função | Assinatura | O que faz |
|---|---|---|
| `renderThumb(o)` | `(object) → void` | Cria e insere card de imagem na grelha |
| `renderDoc(o)` | `(object) → void` | Cria e insere card de documento na lista |
| `renderTrash()` | `() → void` | Re-renderiza a barra de lixeira com itens atuais |
| `updateCounters()` | `() → void` | Atualiza badges de contagem (imagens, documentos, lixeira) |
| `updateBtns()` | `() → void` | Atualiza estado dos botões PDF/ZIP. **Lógica:** `btn-pdf.disabled = (!hi \| hd)` — PDF desativado quando não há imagens **OU** quando há documentos (intencional: PDF é exclusivo de imagens). `btn-zip.disabled = !(hi \| hd)`. |
| `updateBtnTitles()` | `() → void` | Actualiza os atributos `title` dos botões PDF e ZIP com o nome de arquivo que será gerado (ex: `Exportar: captura-2026-05-31.pdf`). Chama `buildFilename()` internamente. Chamar após qualquer alteração ao nome da sessão ou ao modo PDF/ZIP. Retorna imediatamente sem fazer nada se `zipModeActive` for `true`. |
| `updateStatusBar()` | `() → void` | Actualiza a barra de estado com o timestamp do último auto-save (`lastSaveAt`). Chamada pelo auto-save de 5 segundos e directamente em `boot()` para estado inicial. |
| `applyTokens()` | `() → void` | Lê todos os `TOKEN_*` declarados no JS, aplica-os ao DOM e às variáveis CSS (`--accent`, `--title-*-color`, etc.) e inicializa `sysColors`. Também substitui `{YEAR}` no rodapé. Chamada uma vez em `boot()` e novamente pelo `initVbSync` a cada alteração no Visual Builder. **Não chamar antes de `boot()`** — o DOM não está pronto. |
| `initVbSync()` | `() → void` | Regista todos os listeners de `input` do Visual Builder e sincroniza as alterações em tempo real na interface (cor, título, rodapé, rótulos, toggles). Chamada uma vez em `boot()`. Cada listener chama `applyTokens()` ou a função de atualização correspondente. **Não duplicar listeners** — chamar apenas uma vez. |
| `buildFilename(ext)` | `(string) → string` | Gera o nome de arquivo para PDF ou ZIP com base no nome da sessão atual e no timestamp do momento. Sanitiza o nome (remove acentos, caracteres especiais, converte para maiúsculas com hífens). Fallback: `SESSAO-SEM-TITULO`. Formato: `NOME-HHhMMm-DD-mon-YYYY.ext`. Usada por `updateBtnTitles()`. |

### Funções do Modal de Imagem

| Função | O que faz | Notas |
|---|---|---|
| `openImgModal(id, trash)` | Abre o modal para a imagem `id`; inicializa título, zoom, botões de ação e setas de navegação (visíveis se array ≥ 2) | Chamada pelos thumbnails e pela lixeira |
| `closeImgModal()` | Fecha o modal; bloqueia se há anotações por guardar | |
| `imgModalNav(dir)` | Navega ±1 na lista dentro do modal aberto; bloqueia se há anotações por guardar | `dir = -1` (anterior) ou `+1` (seguinte). Chamada pelas setas ← → e pelas teclas ArrowLeft / ArrowRight |

### Funções do Quine

| Função | O que faz | Quando chamar |
|---|---|---|
| `capturePristine()` | Lê o código-fonte original via `fetch` ou `BOOT_HTML` | Apenas em `exportFile()` |
| `exportFile(isUser)` | Gera e faz download do arquivo exportado | No botão Export Admin (`false`) ou Export User (`true`) |
| `sanitizeForQuine(str)` | Substitui marcadores Quine com zero-width space para proteger tokens | Antes de injetar valores de tokens no HTML exportado |

### Funções dos Motores PDF e ZIP

Ambos geram os ficheiros **em JavaScript puro, sem bibliotecas** (contrato zero-dependência) — escrevem os bytes do formato à mão. Partilham os helpers `ENC` (`TextEncoder`), `dlBlob(blob, filename)` (cria Object URL, dispara o download e revoga ao fim de 1 s) e `buildFilename(ext)`.

**PDF** (bloco `/* PDF ENGINE (JPEG COMPRESSED) */`):

| Função | O que faz | Notas |
|---|---|---|
| `generatePDF(returnBlob=false)` | Constrói um PDF 1.4 com **uma imagem por página**. Por imagem: converte para JPEG (`imgToJPEG`), cria um XObject `/Image` com `/Filter /DCTDecode` (os bytes JPEG são embebidos directamente, sem reprocessamento), uma `/Page` e um content stream que escala a imagem para caber na página mantendo a proporção e centra. Monta Catalog (obj 1), Pages (obj 2), a tabela `xref`, o `trailer` e `%%EOF`. | Página A4 = `595.28 × 841.89` pt. Formato lido de `pdfFmt`: `auto` (paisagem se largura ≥ altura, senão retrato), `a4v` (retrato), `a4h` (paisagem). `returnBlob=true` devolve o `Blob` (usado pela opção ZIP "Imagens em PDF"); senão faz download. Desativado quando há documentos na sessão (ver `updateBtns`). |
| `imgToJPEG(blob, quality)` | Carrega a imagem, redimensiona se exceder `TOKEN_MAX_IMG_DIMENSION` (mantém proporção), desenha num canvas e devolve `canvas.toBlob('image/jpeg', quality)`. | `quality` = `TOKEN_JPEG_QUALITY`. Os originais na sessão permanecem PNG — a conversão JPEG é só para o PDF. |
| `getJPEGDims(u8)` | Lê o marcador SOF do JPEG para extrair largura/altura reais (usadas no `MediaBox`/escala). | Fallback `800 × 600` se não encontrar o marcador. |

**ZIP** (bloco `/* ZIP ENGINE */`):

| Função | O que faz | Notas |
|---|---|---|
| `generateZIP(usePdf=false)` | Reúne os ficheiros da sessão e chama `buildZIP`. Com `usePdf=true` e imagens presentes, gera **um** PDF (`generatePDF(true)`) como `Imagens.pdf`; senão adiciona cada imagem no formato original (extensão por MIME). Adiciona os documentos com o nome sanitizado (remove travessias de path `../`, `..\`). Nomes deduplicados por `dedupeZipName`. | Corresponde às duas opções do modo ZIP: "Imagens em PDF" e "Imagens Separadas" (ver `handleZipClick`). |
| `buildZIP(files)` | Escreve um ZIP à mão pelo método **STORE (`0` — sem compressão)**: por ficheiro, um *local file header* (`PK\x03\x04`) seguido dos dados; depois o *central directory* (`PK\x01\x02`) e o *EOCD* (`PK\x05\x06`). CRC32 por tabela própria; data/hora em formato DOS. | Sem `deflate` — empacota sem recomprimir (PNG/GIF entram intactos). Devolve `Blob` `application/zip`. |

### Motor de Reordenação (`initReorder`)

O mecanismo de drag-and-drop para reordenação foi completamente reescrito na V23 com Pointer Events e animações FLIP (*First-Last-Invert-Play* — mede a posição inicial e final do elemento, aplica a diferença como `transform` e anima-a até zero). Documentado aqui porque é o código mais complexo da versão e não é inferível sem leitura directa do changelog.

**Constantes e parâmetros:**

| Constante / Parâmetro | Valor | Descrição |
|---|---|---|
| `DRAG_THRESHOLD` | `6` px | Deslocamento mínimo desde o `pointerdown` para activar o arrasto. Abaixo deste valor, o gesto é tratado como clique simples e abre o item normalmente. |
| Escala do item em arrasto | `0.75` | O card encolhe para 75% durante o arrasto — indica visualmente que está a ser movido. |
| Histerese de reposicionamento | ~18% do tamanho do item | O placeholder só muda de posição quando o centro do item arrastado ultrapassa 18% do tamanho do item em relação ao centro do slot seguinte. Evita trocas involuntárias por movimentos mínimos. |
| Transição FLIP | `transform 0.22s cubic-bezier(0.2,0,0,1)` | Duração e easing da animação que move os cards vizinhos para abrir/fechar espaço. |

**O que é o placeholder:** Um elemento DOM vazio (`.reorder-placeholder`) com fundo e borda muito subtis (configuráveis via `--drop-ph-bg` / `--drop-ph-border`) que ocupa o espaço-alvo durante o arrasto. A sua posição actualiza com base na histerese descrita acima.

**Fluxo do gesto (resumo):**
```
pointerdown  → registar posição inicial; aguardar movimento
   │
   ▼ (se deslocamento > DRAG_THRESHOLD)
activar arrasto:
  - escalar item para 0.75
  - inserir placeholder na posição actual
  - capturar pointer (setPointerCapture)
   │
   ▼ pointermove
  - mover item via transform (sem alterar o DOM)
  - recalcular posição-alvo com histerese
  - mover placeholder suavemente (FLIP)
   │
   ▼ pointerup / pointercancel
  - remover placeholder
  - fazer snap do item para a posição final via FLIP
  - persistir nova ordem no IndexedDB
  - repor escala (1.0)
```

**Algoritmo de geometria de repouso:** A posição final de cada item é calculada a partir de `offsetLeft`, `offsetTop`, `offsetWidth`, `offsetHeight` — coordenadas reais do DOM após reflow, não coordenadas salvas em memória. Isto garante que o snap é sempre preciso independentemente de redimensionamentos ou scroll ocorridos durante o arrasto.

**Nota sobre o item `pointercancel`:** Cancela o arrasto e repõe o item na posição original sem persistir alterações — importante para gestos de scroll em mobile que começam com um toque.

---

### Funções de Anotação

| Função | O que faz | Notas |
|---|---|---|
| `annActivate()` | Ativa o modo de anotação: carrega `origBlob`, inicializa canvas, mostra toolbar; oculta `#img-nav-prev` e `#img-nav-next` | Chamada pelo botão "Editar" (id `ann-toggle`) |
| `annDeactivate()` | Desativa anotação: esconde canvas e toolbar, cancela timers pendentes, restaura `o.blob`; restaura visibilidade das setas de navegação se o modal ainda está aberto | Cancela `annTextClickTimer` e `annCommitText` |
| `annSetTool(t)` | Define ferramenta ativa; mostra/esconde botões B/I consoante `t==='text'` | Atualiza `.active` nos botões |
| `annRedraw()` | Limpa canvas e redesenha `annHistory` completo; salta `annEditingTextIdx` | Chamar após qualquer mutação de `annHistory` |
| `annDrawShape(ctx, h)` | Desenha uma forma do histórico no contexto fornecido. Para texto (`h.type==='text'`) desenha **linha a linha** (`String(h.txt).split('\n')`) com `lineH = fontSize × ANN_TEXT_LINE_RATIO` e `halfLeading = (lineH - fontSize)/2`; usa `ctx.textBaseline='top'` e repõe `'alphabetic'` no fim | Usado por `annRedraw` e pelo `ann-save` |
| `annShowTextInput(x, y, prefill?)` | Posiciona e mostra o editor de texto (`#ann-text-input`, um `<textarea>` multilinha) no canvas, com B/I sync e `line-height = fontSize escalado × ANN_TEXT_LINE_RATIO`. **Enter insere nova linha**; a confirmação acontece no blur (clicar fora), ao clicar noutro ponto do canvas, e no botão Confirmar; `Escape` cancela. Chama `annAutosizeText()` ao abrir | `prefill` opcional para reedição via dblclick |
| `annAutosizeText()` | Faz o `<textarea>` de texto crescer em altura (`scrollHeight`) e largura (linha mais longa medida com `measureText` na fonte escalada, + 4px). Necessário porque `wrap="off"` não quebra linhas automaticamente | Chamada em `oninput`, ao abrir o editor (`annShowTextInput`) e após cada resize ao vivo pelos botões −/+ |
| `annCanvasXY(e)` | Converte coordenadas do evento para coordenadas do canvas (sem clamping) | Para posicionamento de texto |
| `annCanvasXYClamped(e)` | Converte + clamp aos limites do canvas | Para formas (evita saírem do canvas) |
| `annCR(ctx, pts, closed)` | Interpola e renderiza um traço livre usando o algoritmo **Catmull-Rom** (spline cúbica). Recebe o contexto canvas (`ctx`), um array de pontos `[{x,y}]` (`pts`) e um booleano `closed`. Produz curvas suaves que passam exactamente por todos os pontos sem overshooting. Chamada em dois momentos: no preview em tempo real durante o `pointermove` (via `annPath`) e no guardado final do traço via `annDrawShape`. **Não chamar directamente** — usar `annDrawShape` ou `annRedraw`. |
| `rdp(pts, eps)` | Ramer-Douglas-Peucker — simplifica um path removendo pontos colineares | **Definida mas NÃO usada no fluxo de desenho desde a V23** (ver changelog V23). O traço livre é guardado com os mesmos pontos do preview (`annPath`), sem simplificação. A função permanece no arquivo caso seja reativada no futuro. |

### Motor de Anotação — Seleção, Edição e Desfazer (desenvolvimento local — ainda não publicado)

| Comportamento | Descrição e Invariantes |
|---|---|
| **Selecionar** | Ativa por padrão ao abrir imagem com anotações existentes (se vazia, ativa `free`). Permite clicar numa forma para selecioná-la. Exibe caixa de seleção sólida e fina (não mais tracejada) e botão apagar (✕). A seleção limpa ao confirmar ou trocar para texto. O ícone "T" fica azul (cor primária) quando a ferramenta texto está ativa **OU** quando há uma anotação de texto selecionada (através da classe `.ann-txt-selected`). |
| **Mover (Arrastar)** | A anotação selecionada pode ser movida arrastando-a (o arrasto começa no primeiro clique sobre a forma). A caixa acompanha em tempo real; o botão ✕ é oculto durante o arrasto e reaparece ao soltar. O **botão direito** permite agarrar e mover imediatamente, não importando qual a ferramenta ativa (nunca desenha e suprime o menu de contexto nativo). |
| **Redimensionar** | A caixa de seleção possui quatro alças pequenas e arredondadas nos cantos. Funcionam nas duas direções. Textos sofrem redimensionamento por escala contínua visual ao puxar pelas alças. |
| **Editar Propriedades** | Com anotação selecionada: os botões −/+ ajustam espessura (formas) ou tamanho da fonte (texto). A paleta de cores altera a cor da anotação selecionada. Níveis de espessura escalam agora em `[1, 2, 4, 6, 8, 12]`. |
| **Apagar** | O botão ✕ (reutiliza classe `.t-del`) ou a tecla `Delete` apagam a anotação selecionada. O ✕ e a caixa aparecem logo ao selecionar (sem precisar arrastar). |
| **Desfazer / Refazer** | **REESCRITO (Snapshot Model):** Utiliza duas pilhas de estado completas (`annUndoStack` e `annRedoStack`). `annHistory` é a fonte única da verdade. Toda mutação chama `annPushUndo()` (usa `annCommitUndo` + `annCloneState`) **ANTES** de alterar o `annHistory`. `annDoUndo` e `annDoRedo` são simétricos, sem casos especiais: restauram o estado mutando `annHistory` *no lugar* (`splice`). Nova ação limpa `annRedoStack`. Movimentos/redimensionamentos só geram histórico se houve mudança efetiva (via flags `_dragDirty` / `_resizeDirty`). O histórico de desfazer é por sessão e fica apenas em memória (reseta ao recarregar a página). Ao reentrar numa imagem salva, a pilha é semeada passo a passo para permitir desfazer as anotações existentes até o original. Teto de memória: `ANN_HISTORY_MAX = 50`. **Invariante Crítica:** NÃO reintroduzir o modelo antigo de pilha única com flags como `_isMoveUndo` (causava bugs graves de ordem temporal). |

### Funções do Admin Gate

| Função | O que faz | Notas |
|---|---|---|
| `deactivateAdmin()` | Oculta os botões admin (⚙️/💾) e sai do modo administrador | Definida dentro de `initAdminGate` e exposta como `window._deactivateAdmin`. Chamada por `closeSettingsModal` e pelo gate manual. **Não pertence ao motor de anotação** — é do Admin Gate (6 cliques no logo). |

### Funções de Estado de Anotação (V20)

| Função | O que faz | Notas |
|---|---|---|
| `setAnnDirty(val)` | Define `annIsDirty` e controla visibilidade do botão fechar modal | Esconde `img-modal-close` quando `annActive && annIsDirty` |
| `hasUnsavedAnnotations()` | Retorna `true` se há anotações não guardadas (`annActive && annIsDirty`) | Usada por `closeImgModal`, `imgModalNav` e backdrop click |
| `triggerUnsavedAlert()` | Anima botões Confirmar/Cancelar com pulse para alertar o usuário | Chamada quando se tenta fechar com anotações pendentes |

### Funções de Segurança

| Função | Assinatura | O que faz |
|---|---|---|
| `escapeHTML(s)` | `(string) → string` | Escapa `& < > " ' \`` para entidades HTML seguras |

---

## 8. Fluxos de Comportamento

### Fluxo completo de captura de imagem (Ctrl+V)

```
Usuário pressiona Ctrl+V
      │
      ▼
Listener 'paste' verifica:
  - activeElement é INPUT/TEXTAREA? → devolver ao elemento nativo
      │
      ▼
Iterar items do clipboard (índice numérico, não for...of)
      │
      ├── Tipo image/* encontrado
      │         ↓
      │   captureImg(blob)
      │         ↓
      │   ensureSession()       → cria sessão se não existe (com mutex)
      │         ↓
      │   Gerar label único     → verificar contra images[] e removed[]
      │         ↓
      │   idbPut('images', o)   → guardar em IndexedDB
      │         ↓
      │   renderThumb(o)        → inserir card na grelha
      │         ↓
      │   isDirty=true → triggerSave() → saveSession()
      │
      ├── Tipo file (não imagem) encontrado
      │         ↓
      │   captureDoc(blob, name, type)  [mesmo fluxo, tabela 'documents']
      │
      └── Nenhum arquivo — verificar texto
                ↓
          clipboard.getData('text/plain')
                ↓
          captureDoc(Blob(texto), 'texto-1.txt', 'text/plain')
```

### Fluxo de Export User (Quine)

```
Admin clica Export User
      │
      ▼
exportFile(isUser=true)
      │
      ▼
capturePristine()
  ├── fetch(location.href) → sucesso → usa o HTML original
  └── fetch falha → usa BOOT_HTML (constante estática do boot)
      │
      ▼
Para cada TOKEN_*:
  sanitizeForQuine(valor) → valor com marcadores protegidos
  html.replace(regex do token) → substituir valor no HTML
      │
      ▼
isUser=true:
  Remover blocos entre comment markers (ADMIN_BUTTONS, ADMIN_EDIT, ADMIN_JS, EXPORT MODAL)
  TOKEN_DEBUG_MODE → forçar 'false'
      │
      ▼
Criar Blob → URL.createObjectURL → link download → click → revokeObjectURL
```

### Fluxo de apagar sessão ativa com histórico

```
window.deleteSessionId(id) onde id === sessId
      │
      ▼
1. idbAll('sessions') → obter todas as sessões (ANTES de apagar)
2. Determinar neighbor: allBefore[idx+1] || allBefore[idx-1]
      │
      ▼
3. Apagar da IndexedDB:
   - images onde sessionId === id
   - documents onde sessionId === id
   - removed_images onde sessionId === id
   - removed_documents onde sessionId === id
   - sessions[id]
      │
      ▼
4. Neighbor existe?
   ├── Sim → loadSession(neighbor.id) → renderSbSessions()
   └── Não → Pristine reset:
              sessId=null, sessObj=null
              images=[], docs=[], removed=[], removedDocs=[]
              DOM limpo, campos zerados
              renderSbSessions() → sidebar vazia
```

---

## 9. Variáveis de Estado Global

Estas variáveis existem no scope do IIFE e representam o estado em memória da sessão atual.

| Variável | Tipo | Descrição |
|---|---|---|
| `sessId` | string \| null | ID da sessão ativa (`null` = estado pristine) |
| `sessObj` | object \| null | Objeto completo da sessão ativa |
| `images` | array | Imagens ativas da sessão (espelho em memória do IndexedDB). **Nota:** ao carregar sessão, items sem Blob válido são filtrados automaticamente (`blob instanceof Blob && blob.size > 0`) para proteger ambientes Safari/WebView onde blobs podem deserializar como `{}`. |
| `docs` | array | Documentos ativos da sessão |
| `removed` | array | Imagens na lixeira |
| `removedDocs` | array | Documentos na lixeira |
| `isDirty` | boolean | `true` = há alterações não guardadas |
| `sbExp` | boolean | `true` = sidebar de histórico está expandida |
| `_db` | IDBDatabase | Handle da base de dados IndexedDB |
| `_ensurePromise` | Promise \| null | Mutex de `ensureSession()` — evita race conditions |
| `_vbLabelDirty` | object | `{user: bool, equip: bool}` — track se o admin editou rótulos no VB |
| `sysColors` | object | Cores atuais `{main, fg, tStart, tAccent, tEnd}`. `main`/`fg` são a cor principal e a cor do texto sobre ela (usadas no contraste automático YIQ); `tStart`/`tAccent`/`tEnd` são as cores dos 3 spans de título (vazio = herda do contexto). Inicializado a partir de `TOKEN_MAIN_COLOR`, `TOKEN_ACCENT_FG_OVERRIDE`, `TOKEN_TITLE_START_COLOR`, `TOKEN_TITLE_ACCENT_COLOR`, `TOKEN_TITLE_END_COLOR`. Lido por `applyTokens()`/`initVbSync()` e exportado pelo Quine. |
| `annActive` | boolean | `true` = modo de anotação ativo |
| `annTool` | string | Ferramenta ativa: `select` \| `rect` \| `circle` \| `arrow` \| `free` \| `text` |
| `annHistory` | array | Fonte única da verdade das formas atuais no canvas; cada entrada: `{type, x1, y1, ...}` |
| `annUndoStack` | array | Pilha de snapshots de estado (`annHistory` serializado) para desfazer; máximo `ANN_HISTORY_MAX` (50) |
| `annRedoStack` | array | Pilha de snapshots para refazer; limpa sempre que uma nova ação gera um undo |
| `annSelectedIdx` | number | Índice em `annHistory` da anotação selecionada; `-1` = nenhuma seleção |
| `_dragDirty` / `_resizeDirty` | boolean | Flags transitórias para identificar se o gesto contínuo gerou mutação de coordenadas antes do undo |
| `annCurrentColor` | string | Cor ativa da toolbar de anotação (hex) |
| `annSizeIdx` | number | Índice em `ANN_SIZES=[1,2,4,6,8,12]` — espessura de linha ativa |
| `annTextBold` | boolean | Negrito ativo na ferramenta texto (padrão: `true`) |
| `annTextItalic` | boolean | Itálico ativo na ferramenta texto |
| `annTextSizeIdx` | number | Índice em `ANN_TEXT_SIZES=[14,18,24,36,48]` — tamanho de fonte ativo |
| `annEditingTextIdx` | number | Índice em `annHistory` do texto em edição via dblclick; `-1` = novo texto |
| `annTextClickTimer` | TimeoutID \| null | Timer de 220ms para distinguir single-click (novo texto) de dblclick (editar); scope de módulo |
| `annSmoothLast` | object \| null | Último ponto suavizado pelo EMA no desenho livre; resetado em activate/deactivate/mouseup |
| `annInitialState` | string \| null | JSON.stringify do `annHistory` ao ativar anotação — usado para detetar se houve alterações reais |
| `lastSaveAt` | number | Timestamp do último save automático para a status bar |
| `pdfFmt` | string | Modo de layout da página PDF ('vertical', 'horizontal', 'auto') |
| `zipModeActive` | boolean | Define se o modo ZIP está ativado |
| `modalIsTrash` | boolean | Indica se o modal de visualização provém da lixeira |
| `modalItemId` | string | ID da imagem visualizada no modal |
| `imgZoomed` | boolean | Flag de imagem ampliada no modal |
| `imgScale` | number | Fator de zoom atual da imagem |
| `imgPanX` / `imgPanY` | number | Offsets de pan da imagem no modal |
| `imgPanning` | boolean | Flag de estado de pan (arrastamento) ativo |
| `imgStartX` / `imgStartY` | number | Coordenadas iniciais do pan |
| `trashUrls` | array | Lista de ObjectURLs das imagens na lixeira |
| `annDrawing` | boolean | Estado de desenho em progresso na anotação |
| `annStart` | object | Coordenadas de início do traço de anotação |
| `annPath` | array | Lista de pontos desenhados na ferramenta 'free' |
| `annCommitText` | function | Callback para commitar input de texto na anotação |
| `PRISTINE_HTML` | string \| null | Fonte primária do Quine — HTML original capturado via `fetch(location.href)` em `capturePristine()`; `null` até a primeira chamada. Fallback para `BOOT_HTML` se fetch falhar. Declarado dentro do bloco `ADMIN_JS`. |
| `_imgOverlayMdOnBackdrop` | boolean | Flag de gesture do modal de imagem — `true` se o `mousedown` ocorreu no backdrop (não num filho interativo); evita fechar o modal ao arrastar para fora |
| `_textOverlayMdOnBackdrop` | boolean | Flag de gesture do modal de documento — idem para o text modal |
| `_expOverlayMdOnBackdrop` | boolean | Flag de gesture do modal de Export |
| `textModalItemId` | string \| null | ID do documento atualmente aberto no text modal; `null` = modal fechado |
| `textModalIsTrash` | boolean | `true` se o documento aberto no text modal provém da lixeira |
| `ANN_SIZES` | array (const) | `[1, 2, 4, 6, 8, 12]` — espessuras de linha disponíveis na toolbar de anotação (px) |
| `ANN_TEXT_SIZES` | array (const) | `[14, 18, 24, 36, 48]` — tamanhos de fonte disponíveis na ferramenta texto (px) |
| `ANN_TEXT_LINE_RATIO` | number (const) | `1.3` — line-height ratio da ferramenta texto. Constante **única** usada nos dois sítios (line-height do `<textarea>` e do canvas em `annDrawShape`) para que o texto achatado seja igual ao que se vê a escrever (WYSIWYG) |

---

## 10. Workflow de Desenvolvimento para Agentes

1. **Nunca sobrescrever o arquivo inteiro** — sempre edições incrementais e cirúrgicas
2. **Nunca abrir o browser para testar** — o humano testa, o agente edita
3. **Após cada alteração significativa, atualizar:**
   - `readme.md` — se for nova funcionalidade visível ao usuário
   - `design-tokens.md` — se for novo token CSS ou JS
   - `changelog.md` — sempre, com entrada na versão atual
4. **Codificação:** UTF-8 sem BOM
5. **Testar regressão mental:** Para cada alteração, verificar se os 3 contratos (zero-dep, Quine, XSS) continuam válidos
6. **Verificar markers:** Após qualquer edição ao HTML, confirmar que os 11 comment markers estão intactos
7. **Correr a verificação estática:** Após qualquer edição ao HTML, executar o `validate.sh` na pasta do projeto. É um conjunto de verificações mecânicas (grep + sintaxe) que dá sempre o mesmo resultado — uma IA pode confiar nele sem alucinar. **Não declarar a tarefa concluída se algum check falhar.** Isto não substitui o teste manual no browser (ver Seção 11), mas apanha regressões estruturais antes disso.

   **Como executar** (o `validate.sh` é um script em Bash; este passo destina-se a agentes de IA):
   - Num ambiente com Bash (Linux, macOS, ou um agente de IA com terminal Bash), correr na pasta do projeto:
     ```bash
     bash validate.sh
     ```
   - Em Windows, o duplo clique **não** executa arquivos `.sh`. É preciso um terminal Bash (por exemplo, "Git Bash" ou WSL) e correr o mesmo comando: `bash validate.sh`.
   - Se não houver Bash disponível, fazer as mesmas verificações manualmente seguindo a Seção 11 (são contagens com `grep` e comparações de texto — nenhuma exige o browser).
   - Saída esperada: uma lista de `[PASS]`/`[FAIL]` e um resumo. Código de saída `0` = tudo OK.

---

## 11. Checklist de Validação — Antes de Declarar Completo

Nenhuma tarefa está concluída sem validar todos os pontos abaixo:

A validação tem **duas partes**:
- **Parte A — sem browser:** verificações mecânicas e de leitura de código. As mecânicas (markers, funções Quine, spans de título, APIs proibidas, zero-dependência, sintaxe JS) são feitas automaticamente por `validate.sh` (ver Seção 10, "Como executar"); as restantes são confirmadas a ler o código.
- **Parte B — teste manual no browser:** comportamento que só se confirma a abrir e a usar a aplicação. **Tem de ser feito por um humano** — o agente edita, o humano testa.

---

### Parte A — Verificações sem browser

**Segurança:**
- [ ] `escapeHTML()` aplicado a todos os dados do usuário inseridos via `innerHTML`
- [ ] `sanitizeForQuine()` aplicado antes de tokens serem injetados no HTML exportado
- [ ] Sem `eval()`, `Function()`, ou `document.write()`

**Integridade do Quine:**
- [ ] Todos os 11 comment markers estão intactos (verificar com `grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" capture-engine.html` → deve retornar 11)
- [ ] `window.exportFile()`, `capturePristine()` e `sanitizeForQuine()` não foram movidos
- [ ] Formato das declarações `const TOKEN_* = 'valor'` preservado
- [ ] Os 3 spans de título (`#ui-title-start`, `#ui-title-accent`, `#ui-title-end`) existem no HTML
- [ ] `exportFile()` substitui `TOKEN_TITLE_END` via regex (além de START e ACCENT)
- [ ] Campo `cfg-title-end` existe no VB (Tab Interface)

**Unicidade:**
- [ ] Sem nomes duplicados possíveis em screenshots ou documentos
- [ ] A deduplicação verifica contra listas ativas **e** lixeira (verificar: `captureImg`, `captureDoc`, `restoreImg`, `restoreDoc`, `setLabel`, `setDocName`)
- [ ] Comparação de nomes é case-insensitive

**Internacionalização:**
- [ ] Sem strings hardcoded em inglês visíveis ao usuário
- [ ] Sem strings hardcoded em PT-PT (regionalismo) — usar PT neutro

**Estrutura da Anotação (ler o código, após qualquer edição ao annotation engine):**
- [ ] `annTextClickTimer` declarado no scope de módulo (antes de `initAnnotation`)
- [ ] `annSmoothLast` declarado no scope de módulo
- [ ] `annDeactivate()` faz `clearTimeout(annTextClickTimer)` e `annSmoothLast=null`
- [ ] `annRedraw()` usa `forEach((h,_ri) => { if(_ri===annEditingTextIdx) return; ... })`
- [ ] `annDrawShape` usa `ctx.textBaseline='top'` e repõe `'alphabetic'` no final; o texto é desenhado **linha a linha** (split por `\n`) com `lineH = fontSize × ANN_TEXT_LINE_RATIO` (mesma constante do line-height do `<textarea>`)
- [ ] `closeSettingsModal` chama `window._deactivateAdmin()`
- [ ] `window._deactivateAdmin` é atribuído dentro de `initAdminGate`
- [ ] `annDrawShape` é função de draw pura — não contém `annIsDirty = true` nem manipulação do DOM (side effects pertencem ao caller)

**Documentação:**
- [ ] Se foi adicionada ou removida uma função de inicialização, verificar se o diagrama `boot()` na Seção 13 do `readme.md` foi atualizado
- [ ] Se foi adicionada uma variável de estado global, verificar se foi incluída na tabela da Seção 9
- [ ] Se foi alterado o comportamento de um motor (anotação, Quine, PDF/ZIP, sessões), confirmar que o `readme.md`, o `design-tokens.md` e o `agents.md` descrevem o comportamento **atual** — e não uma versão anterior. *(Já aconteceu deriva neste ponto: a anotação foi reescrita na V23 e os três documentos ficaram a descrever o pipeline antigo — EMA + Laplaciana + RDP. Verificar sempre que se mexe num motor.)*

---

### Parte B — Checklist de Teste Manual no Browser

Esta é a lista **única e completa** de testes que exigem abrir a aplicação. Não depende de outros documentos — tudo o que precisa de ser confirmado no browser está aqui.

**Ciclo de vida da sessão:**
- [ ] Abrir o arquivo → interface limpa, campos vazios, histórico vazio
- [ ] Digitar no campo User → estado "Gravado" aparece **sem aguardar 5 segundos**
- [ ] Capturar uma imagem (Ctrl+V) → sessão aparece no histórico
- [ ] Apagar sessão ativa **com** histórico existente → navegação automática para a sessão adjacente
- [ ] Apagar a **última** sessão ativa → interface volta ao estado limpo inicial (sem sessão nova no histórico)

**Visualizador de imagem — navegação:**
- [ ] Com ≥2 imagens na sessão, botões ← → aparecem nas laterais do modal
- [ ] Com apenas 1 imagem, botões ← → estão ocultos
- [ ] Clicar ← / → navega para a imagem anterior / seguinte
- [ ] ArrowLeft / ArrowRight funcionam da mesma forma
- [ ] Cliques **rápidos** nas setas não ativam zoom (guard dblclick funciona)
- [ ] Abrir modo de anotação → setas desaparecem; cancelar → setas reaparecem

**Anotação — comportamento (motor reescrito na V23, testar com atenção):**
- [ ] Desenho à mão livre **não pisca** durante o desenho
- [ ] O traço guardado é **igual ao que se viu na tela** — sem arredondar, sem alisar e sem fechar o contorno sozinho
- [ ] Curvas mantêm as quinas suaves depois de soltar (não ficam pontudas)
- [ ] Retângulo, círculo e seta desenham por arrasto
- [ ] Texto: colocar (Enter confirma, Escape cancela), reeditar com duplo-clique, mudar cor / negrito / itálico
- [ ] Desfazer / Refazer (Ctrl+Z / Ctrl+Y)
- [ ] "Confirmar" funde a anotação na imagem; "Cancelar" descarta
- [ ] Tentar fechar o modal com anotações por guardar → botões Confirmar/Cancelar pulsam (alerta)

**Reordenação (reescrita com Pointer Events / FLIP na V23):**
- [ ] Arrastar imagens para reordenar é **estável** (não salta nem pisca), com mouse
- [ ] Se possível, testar também em **tela de toque**
- [ ] Um **clique simples** continua a abrir o item (não confunde clique com arrasto)
- [ ] Arrastar documentos na lista também reordena

**Visual e tema:**
- [ ] Imagens com cantos retos; botões e cards de texto com cantos arredondados
- [ ] O arquivo abre **sem erros na consola** (F12)
- [ ] Dark mode funciona **sem flash branco** ao abrir (anti-FOUC)

**Export (testar o ciclo real):**
- [ ] PDF gera com imagens; fica **desativado** quando há documentos na sessão
- [ ] ZIP empacota imagens + documentos
- [ ] **Export Admin** → a cópia mantém o painel de administração e a capacidade de re-exportar
- [ ] **Export User** → a cópia **não** tem botões de admin, Visual Builder, nem logs na consola
- [ ] Abrir a cópia exportada e confirmar que as configurações (cor, nome, rodapé) foram aplicadas

**Multi-aba:**
- [ ] Abrir o arquivo numa segunda aba do mesmo browser → **carrega normalmente** (sem tela de erro vermelho); ambas as abas funcionam e partilham a mesma base de dados

---

## 12. Protocolo de Version Bump

Ao passar para uma nova versão (ex: V23 → V24), o número de versão tem de ser actualizado em **exatamente 5 arquivos**, com **10 substituições + 1 inserção**, distribuídas da seguinte forma.

Nos exemplos abaixo, `VERSAO_ANTERIOR` = a versão que está agora (ex: `V23`), `VERSAO_NOVA` = a versão de destino (ex: `V24`).

**Os 5 arquivos e as alterações exactas:**

1. **`capture-engine.html`** — 3 substituições:
   - Comentário do Visual Builder: `<!-- VISUAL BUILDER MODAL (VERSAO_ANTERIOR) -->` → `(VERSAO_NOVA)`
   - Badge visual no header do modal de configurações: `>VERSAO_ANTERIOR</span>` → `>VERSAO_NOVA</span>`
   - Mensagem de inicialização no console: `SysLogger.info('Capture Engine VERSAO_ANTERIOR Ready')` → `VERSAO_NOVA`

2. **`changelog.md`** — 1 inserção (não substituição):
   - Adicionar nova entrada no topo: `## [VERSAO_NOVA] — YYYY-MM-DD`
   - As referências `VERSAO_ANTERIOR` existentes no changelog são **registos históricos — não se substituem**.

3. **`readme.md`** — 3 substituições:
   - Título principal: `# Capture Engine · VERSAO_ANTERIOR` → `VERSAO_NOVA`
   - Bloco de estrutura de arquivos: `VERSAO_ANTERIOR/` → `VERSAO_NOVA/`
   - Rodapé do documento: `*Capture Engine VERSAO_ANTERIOR ·` → `VERSAO_NOVA`

4. **`design-tokens.md`** — 2 substituições:
   - Título principal: `# Design Tokens · Capture Engine VERSAO_ANTERIOR` → `VERSAO_NOVA`
   - Rodapé do documento: `*Capture Engine VERSAO_ANTERIOR ·` → `VERSAO_NOVA`

5. **`agents.md`** — 2 substituições:
   - Título principal: `# Agents · Capture Engine VERSAO_ANTERIOR` → `VERSAO_NOVA`
   - Rodapé do documento: `*Capture Engine VERSAO_ANTERIOR ·` → `VERSAO_NOVA`

**Referências contextuais — NÃO substituir:**

Em todos os arquivos existem referências ao número de versão anterior que são **registos históricos** e devem ser preservadas. A regra é simples: **substituir apenas onde o número de versão identifica o produto actual** (títulos, badges, logs de boot). Preservar onde descreve quando algo aconteceu.

Exemplos de referências a preservar após um bump para VERSAO_NOVA:
- `agents.md`: "removido na VERSAO_ANTERIOR", "reescrita com Pointer Events / FLIP na VERSAO_ANTERIOR", "desde a VERSAO_ANTERIOR"
- `design-tokens.md`: "sempre `false` desde a VERSAO_ANTERIOR"
- `capture-engine.html`: comentários inline como `// NOTA (VERSAO_ANTERIOR): definida mas NAO chamada...`
- `changelog.md`: todos os cabeçalhos `## [VERSAO_ANTERIOR]` e o respectivo conteúdo

**Verificação obrigatória antes de fechar:**
```bash
grep -rn "VERSAO_ANTERIOR" capture-engine.html readme.md design-tokens.md agents.md changelog.md
```
Substituir `VERSAO_ANTERIOR` pelo número real (ex: `V23`). Confrontar cada resultado: os únicos que devem restar são referências históricas (changelog e comentários de código). Se restar algum nos títulos ou rodapés, está incompleto.

Nunca assumir que as substituições foram completas sem verificar.

> **Nota sobre o `validate.sh`:** o script **não** tem número de versão hardcoded — a verificação #8 auto-detecta a versão a partir do boot message (`Capture Engine Vxx Ready`) e confirma que essa mesma versão aparece nas 3 referências de produto do HTML (comentário do Visual Builder, badge e console). Por isso o `validate.sh` **não precisa de ser editado** no version bump; pelo contrário, **correr `validate.sh` após o bump apanha** os 3 locais caso algum tenha ficado por substituir (a verificação #8 dá `FAIL` se a versão do boot message não bater com o badge/comentário VB).

---

## 13. Decisões de Design Documentadas

Estas decisões foram explicitamente confirmadas pelo proprietário do projeto e **não devem ser revertidas sem aprovação**:

| # | Decisão | Justificação |
|---|---|---|
| D1 | **Botão PDF desativado quando há imagens + documentos** | PDF é exclusivo de imagens. Quando há docs na sessão, o usuário deve usar o ZIP. |
| D2 | **Modal do Visual Builder não fecha ao clicar fora** | O VB é de uso exclusivo Admin e requer fecho explícito pelo botão ✕ para evitar perda de configurações acidentais. |
| D3 | **setInterval de 5 segundos mantido no auto-save** | Cobre os 16 eventos `isDirty=true` dentro do VB (color pickers, sliders, radios) que não chamam `triggerSave()` imediatamente por serem `input` events contínuos. Sem o interval, alterações no VB perdem-se se o browser for fechado dentro da janela de 5s. |
| D4 | **Placeholder "Imagem N" não atualiza após drag-and-drop** | O placeholder é decorativo (hint visual). Não representa numeração oficial — a legenda editável é o campo `label`. |
| D5 | **triggerSave() sem await em closeSettingsModal** | Risco de perda de dados aceite. O setInterval de 5s garante persistência antes do fecho do browser em uso normal. |
| D6 | **TOKEN_TITLE_END com 3 spans independentes no brand-name + swatches de cor individuais** | Permite construir títulos como `C P C` (letras a cores alternadas) com espaços controlados manualmente. Cada span tem cor independente configurável via `TOKEN_TITLE_START_COLOR`, `TOKEN_TITLE_ACCENT_COLOR`, `TOKEN_TITLE_END_COLOR`. Vazio = herda cor do contexto. Duplo clique no swatch para repor automático. |

## 14. Disaster Recovery Técnico

**Modelo de armazenamento (confirmado por bateria de testes — Windows 11 25H2, Edge 148, Chrome 148):**

A base de dados é aberta com `indexedDB.open('CaptureEngineDB', 2)` — **sem nome de arquivo nem caminho**. No Windows com Edge/Chrome, todos os arquivos `file://` partilham a mesma *origin*, pelo que a base é, na prática, **partilhada por perfil de browser**. Consequências confirmadas:

| Condição | Encontra os dados? |
| --- | --- |
| Mesmo perfil, qualquer arquivo/pasta/disco | **SIM** |
| Arquivo renomeado | **SIM** |
| Versão/produto diferente (ex.: "Evidence Collector" V1/V2 vê sessões da "Capture Engine" V3) | **SIM** — todos usam `CaptureEngineDB` |
| Caminho com espaços/caracteres especiais | **SIM** |
| ZIP extraído para pasta | **SIM** |
| Abrir de dentro do ZIP (sem extrair) | **NÃO** |
| Janela anônima/privada | **NÃO** |
| Outro perfil do browser | **NÃO** |
| Outro browser (Edge ↔ Chrome) | **NÃO** |
| Mesma conta/perfil **em outra máquina** (sync ligado) | **NÃO** — IndexedDB não é sincronizado |

> **Âmbito dos testes:** esta matriz foi confirmada em Windows 11 com Edge 148 e Chrome 148 (ambos motores Chromium). O Firefox e o Safari usam motores diferentes e **não foram testados formalmente** — o princípio geral (os dados estão ligados ao perfil de browser, não ao arquivo) deve manter-se, mas os detalhes de partilha entre arquivos `file://` podem variar.

**Pontos-chave:**
- O que decide o acesso é o **perfil de browser**, não o nome/pasta/versão do arquivo.
- Os dados são **locais à máquina**. O sync do Chrome leva favoritos/senhas, mas **não** o IndexedDB (confirmado por teste: conta sincronizada em outro PC → histórico vazio).
- **Isolamento por ambiente:** dentro de uma VDI (perfil próprio e isolado), as sessões ficam contidas nessa VDI. Fora das VDIs, no perfil local pessoal, todas as sessões partilham a mesma base. *Ambientes com roaming de perfil gerenciados pela TI poderiam alterar isto (os dados seguiriam o usuário) — não confirmado, depende da infraestrutura.*

**Recuperação prática:** se o `capture-engine.html` for apagado, basta abrir **qualquer** cópia da ferramenta no **mesmo perfil do mesmo browser** — as sessões reaparecem. Nome e pasta são irrelevantes.

**Extração de Emergência (DevTools):** se a lógica do HTML estiver inoperável e for preciso extrair os dados puros:

1. Abra qualquer cópia da ferramenta no perfil correcto e pressione **F12** (DevTools).
2. Navegue até **Application** (Chrome/Edge) ou **Storage** (Firefox) → **IndexedDB** → **CaptureEngineDB**.
3. Clique em **`images`** ou **`documents`** para ver os registos. Cada linha é um item.
4. Para exportar um ficheiro individual:
   - Clique no registo pretendido para o expandir.
   - Localize o campo **`blob`** — aparece como `Blob {size: XXXXX, type: "image/png"}`.
   - Clique com o botão direito no valor do blob → **"Save as..."** (Chrome/Edge) ou copie via console (ver abaixo).
5. Se a opção "Save as" não estiver disponível, use a consola (tab **Console**):
   ```js
   // Substituir 'images' pelo nome da store e o ID pelo valor real
   const req = indexedDB.open('CaptureEngineDB', 2);
   req.onsuccess = e => {
     const db = e.target.result;
     const tx = db.transaction('images', 'readonly');
     const store = tx.objectStore('images');
     store.getAll().onsuccess = ev => {
       ev.target.result.forEach((item, i) => {
         const a = document.createElement('a');
         a.href = URL.createObjectURL(item.blob);
         a.download = (item.label || 'imagem-' + i) + '.png';
         a.click();
       });
     };
   };
   ```
   Este script faz download de todas as imagens da store. Para documentos, substituir `'images'` por `'documents'` e `item.label` por `item.name`.

> **Nota:** A única salvaguarda fiável é **exportar (PDF/ZIP)** o material importante. Não existe backup automático dos dados — é uma decisão de design (privacidade), não uma falha.

---

*Capture Engine V24 · Regras Operacionais para Agentes*
