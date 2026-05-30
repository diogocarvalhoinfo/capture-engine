# Agents · Capture Engine V20

> Guia operacional para desenvolvedores e agentes de IA que lêem, editam ou estendem o Capture Engine.
> **Leia a Secção 0 e a Secção 1 antes de qualquer outra coisa. Sem exceções.**

---

## Índice

- [Secção 0 — Modelo Mental](#0-modelo-mental--antes-das-regras)
- [Secção 1 — Regras Absolutas](#1-regras-absolutas)
- [Secção 2 — Convenções de Código](#2-convenções-de-código)
- [Secção 3 — Unicidade de Nomes](#3-unicidade-de-nomes--prevenção-de-colisões-no-zip)
- [Secção 4 — Ciclo de Vida da Sessão](#4-ciclo-de-vida-da-sessão)
- [Secção 5 — Comment Markers do Quine](#5-comment-markers--blocos-de-código-removíveis)
- [Secção 6 — IndexedDB — Schema Completo](#6-indexeddb--schema-completo)
- [Secção 7 — Funções Críticas — Referência Rápida](#7-funções-críticas--referência-rápida)
- [Secção 8 — Fluxos de Comportamento](#8-fluxos-de-comportamento)
- [Secção 9 — Variáveis de Estado Global](#9-variáveis-de-estado-global)
- [Secção 10 — Workflow de Desenvolvimento](#10-workflow-de-desenvolvimento-para-agentes)
- [Secção 11 — Checklist de Validação](#11-checklist-de-validação--antes-de-declarar-completo)
- [Secção 12 — Protocolo de Version Bump](#12-protocolo-de-version-bump)

---

## 0. Modelo Mental — Antes das Regras

Antes de ler as regras, é necessário perceber *por que* elas existem. As regras não são arbitrárias — cada uma protege um dos três contratos fundamentais do motor:

### Contrato 1: O arquivo é a aplicação inteira

O `capture-engine.html` não é uma página que carrega recursos externos. É uma aplicação completa encapsulada num único arquivo. Isso significa:

- **Sem CDN.** Se colocar um `<script src="https://...">` qualquer, o arquivo deixa de funcionar em ambientes offline (bancos, hospitais, governo). O utilizador final não terá internet.
- **Sem npm, sem bundler.** O arquivo tem de abrir com duplo clique num Windows sem internet e funcionar. Toda a lógica está inline.

*Consequência de violar:* A aplicação falha silenciosamente em qualquer ambiente sem internet. O utilizador nunca saberá porquê.

### Contrato 2: O arquivo consegue copiar-se a si próprio

O motor tem uma funcionalidade chamada **Quine** — consegue exportar uma cópia de si próprio com configurações personalizadas. Para isso funcionar, o código-fonte original tem de estar recuperável e os marcadores de secção têm de estar intactos.

*Consequência de violar:* O Export Admin/User produz um arquivo corrompido ou incompleto que não abre corretamente no browser.

### Contrato 3: Os dados do utilizador nunca chegam ao DOM sem sanitização

Qualquer texto que o utilizador escreva (nome de sessão, legenda de imagem, nome de documento) pode conter caracteres especiais HTML. Se inseridos diretamente via `innerHTML`, um utilizador malicioso pode injetar JavaScript — ataque XSS.

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

> **Aviso Técnico (CORS Local):** Ao testar localmente, abrir o ficheiro HTML via protocolo `file://` no Chrome ou Safari causará uma falha imediata no `fetch(location.href)` devido a políticas rigorosas de CORS para recursos locais (o browser trata ficheiros locais como origens opacas e proíbe `fetch` a si mesmos). O sistema sobrevive a isto porque `BOOT_HTML` captura a string estática do DOM exato (via `document.documentElement.outerHTML` adaptado) no momento do boot antes de qualquer mutação. O Quine opera sobre o fallback de forma impercetível ao utilizador.
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
| Todos os comment markers | Ver Secção 5 | Definem o que é removido em exports de User |

**Formato dos tokens:**
```js
// O regex do Quine aceita espaços, e devem ser mantidos para legibilidade:
const TOKEN_MAIN_COLOR = '#0ea5e9';
```

**Regra:** Qualquer alteração ao arquivo deve preservar todos os comment markers intactos e todas as funções Quine funcionais.

---

### 1.3 XSS Prevention — Sanitização de inputs

**O problema:** O browser interpreta HTML dentro de strings. Se um utilizador escrever `<img src=x onerror=alert(1)>` como legenda e esse texto for inserido via `innerHTML`, o JavaScript executa.

**A solução:** Usar sempre `escapeHTML()` antes de qualquer `innerHTML` com dados do utilizador:
```js
// ERRADO — vulnerável a XSS
element.innerHTML = `<span>${userInput}</span>`;

// CORRETO — seguro
element.innerHTML = `<span>${escapeHTML(userInput)}</span>`;
```

**Para o Quine:** Usar `sanitizeForQuine()` antes de injetar valores de tokens no HTML exportado. Esta função protege os comment markers de serem acidentalmente incluídos em valores de tokens (o que corromperia o arquivo exportado).

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
| Labels visíveis para o utilizador na UI | Português neutro | `"Histórico"`, `"Removidos"`, `"Processando..."` |

**Português neutro — glossário aprovado:**

| ✅ Usar | ❌ Evitar | Razão |
|---|---|---|
| `"Arquivo"` | `"Ficheiro"` | Regionalismo PT-PT |
| `"Histórico"` | `"Sessões"` | Mais claro para utilizadores não-técnicos |
| `"Download"` | `"Descarregar"` | Termo universal |
| `"Equipamento"` | `"Máquina"` | Mais formal e neutro |
| `"Campo 1"`, `"Campo 2"` | `"User"`, `"Equipamento"` (hardcoded no VB) | Evergreen — funciona para qualquer domínio |

---

### 2.2 CSS — Unidades e Modo Escuro

**Usar `px`, nunca `rem` ou `em`**

Porquê: `rem` depende do `font-size` do `<html>`. Em ambientes corporativos com configurações de acessibilidade que alteram o tamanho de fonte do browser, `rem` produz layouts quebrados imprevisíveis. `px` é determinístico.

**Dark mode via `body.dark`, nunca via media query CSS**

Porquê: O utilizador pode ter o sistema em dark mode mas querer a app em light mode. A class `body.dark` é controlada por JavaScript e persiste em `localStorage`. A media query `prefers-color-scheme` no CSS não permite override manual.

```css
/* CORRETO — controlável pelo utilizador */
body.dark { --bg: #121212; }

/* PROIBIDO — não permite override manual */
@media (prefers-color-scheme: dark) { --bg: #121212; }
```

> **Exceção permitida:** `initTheme()` em JavaScript *pode* usar `window.matchMedia('prefers-color-scheme')` como fallback na primeira abertura (antes de o utilizador ter definido preferência). O JS lê o OS, aplica a classe, e a partir daí o CSS faz o resto.

**Z-index stack (apenas 3 níveis — não adicionar outros sem documentar aqui):**
- `9999` → Modais (imagem, texto, anotação)
- `1000` → Banners (restaurar sessão)
- `0` → Conteúdo base

---

### 2.3 Gold Standard — Tamanhos e Proporções

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
Para evitar colisões na base de dados, a função `genId(prefix)` é utilizada na criação de novos itens. Ela gera uma string leve e estatisticamente única através do formato `{prefix}_{entropia}` (ex: `img_1a2b3c4d5`). A entropia é baseada na conversão de `Math.random()` para base 36 truncada. A probabilidade de colisão numa mesma sessão local (Single Page App no IndexedDB) é desprezável.

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

**Extensão de arquivo:** Ao renomear um documento, a extensão original é sempre preservada. Se o utilizador escrever `relatorio` (sem extensão) num documento `.pdf`, o nome final é `relatorio.pdf`.

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

> **Porquê nunca criar sessão em `deleteSessionId`?** Porque o utilizador que apaga a última sessão está a decidir ter uma interface vazia. Criar uma sessão automática seria ignorar a intenção do utilizador — e causaria um loop onde apagar sempre gerava uma sessão nova no histórico.

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

**Regra crítica:** Nunca mover código para dentro ou fora destes blocos sem perceber as consequências. Código dentro de `ADMIN_JS_START/END` desaparece nos exports de User — se a funcionalidade for necessária para utilizadores normais, não pode estar nesse bloco.

**Proteção do Quine:** `sanitizeForQuine()` substitui os marcadores nos *valores de tokens* com versões contendo zero-width space (caractere invisível `\u200B`). Isto evita que um token com o texto `ADMIN_JS_START` corrompa o regex de strip. Aplica-se a todos os 8 marcadores (4 pares de abertura/fecho).

**Para verificar integridade dos markers:**
```bash
grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" capture-engine.html
# Deve retornar 10
# (Nota: ADMIN_JS_START/END aparecem em 2 locais distintos: o bloco principal de funções Quine e o bloco de chamada em boot)
```

---

## 6. IndexedDB — Schema Completo

**Nome da base de dados:** `CaptureEngineDB`
**Versão do schema:** `2`

### Tabela: `sessions`

Índices: `createdAt`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | ✅ | ID único gerado por `genId('sess')` — chave primária |
| `name` | string | ❌ | Nome da sessão digitado pelo utilizador (vazio = usa fallback #XXXX) |
| `user` | string | ❌ | Valor do Campo 1 (ex: "João Silva") |
| `pc` | string | ❌ | Valor do Campo 2 (ex: "PC-001") |
| `createdAt` | number | ✅ | Timestamp Unix (ms) da criação — imutável após criação |
| `updatedAt` | number | ✅ | Timestamp Unix (ms) da última atividade — atualizado a cada save |
| `exported` | boolean | ✅ | `true` se foi exportada pelo menos uma vez (para referência futura) |

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

O sistema utiliza localStorage para preferências que devem sobreviver a diferentes abas ou ficheiros na mesma origem:
- `theme`: Controla o modo visual. Valores possíveis: `'dark'`, `'light'` ou `null` (neste caso cai para a preferência do OS).
- *Histórico:* A chave `ec_pending_session` foi utilizada em versões antigas e removida na V17.
Limpar o localStorage apenas reseta preferências visuais. Limpar o IndexedDB apaga os dados reais das sessões.

### Auto-save e Purge

**Auto-save e Falhas Assíncronas:** `setInterval` de 5 segundos no `boot()` chama `saveSession()` se `isDirty === true`. A função `triggerSave()` é chamada na digitação. Se o browser for fechado durante a janela de latência ou a transação falhar, as últimas mutações perdem-se.

**Esgotamento de Quota:** Se o limite de disco do browser for atingido, a gravação de novos blobs falha nativamente. O manipulador `tx.onerror` regista a exceção na consola (Zero Trust). A aplicação falha silenciosamente na interface para não causar pânico de UX (já que as gravações são assíncronas em background e a captura visual na grelha acontece via URL local em memória temporária). A sessão já guardada e os itens antigos permanecem íntegros no DB.

**Purge:** `purgeExpired()` corre em cada `init()`. Apaga sessões cuja `updatedAt` seja mais antiga que `TOKEN_AUTO_PURGE_HOURS` horas. Apaga também todos os items associados (imagens, documentos, removidos das duas categorias).

**Bloqueio de múltiplas instâncias:** Se o IndexedDB estiver aberto noutras abas, o evento `onblocked` mostra um ecrã de erro vermelho a pedir que o utilizador feche as outras abas.

---

## 7. Funções Críticas — Referência Rápida

Esta secção documenta as funções mais importantes. Consultar antes de editar qualquer uma delas.

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
| `idbTx(store, mode)` | `(string, string) → Promise` | Wrapper transacional para IndexedDB com gestão de erro e fallback | Base para todas as leituras e escritas |

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
| `updateBtns()` | `() → void` | Atualiza estado dos botões PDF/ZIP (enable/disable) |

### Funções do Quine

| Função | O que faz | Quando chamar |
|---|---|---|
| `capturePristine()` | Lê o código-fonte original via `fetch` ou `BOOT_HTML` | Apenas em `exportFile()` |
| `exportFile(isUser)` | Gera e faz download do arquivo exportado | No botão Export Admin (`false`) ou Export User (`true`) |
| `sanitizeForQuine(str)` | Substitui marcadores Quine com zero-width space para proteger tokens | Antes de injetar valores de tokens no HTML exportado |

### Funções de Anotação

| Função | O que faz | Notas |
|---|---|---|
| `annActivate()` | Ativa o modo de anotação: carrega `origBlob`, inicializa canvas, mostra toolbar | Chamada pelo botão "Anotar" |
| `annDeactivate()` | Desativa anotação: esconde canvas e toolbar, cancela timers pendentes, restaura `o.blob` | Cancela `annTextClickTimer` e `annCommitText` |
| `annSetTool(t)` | Define ferramenta ativa; mostra/esconde botões B/I consoante `t==='text'` | Atualiza `.active` nos botões |
| `annRedraw()` | Limpa canvas e redesenha `annHistory` completo; salta `annEditingTextIdx` | Chamar após qualquer mutação de `annHistory` |
| `annDrawShape(ctx, h)` | Desenha uma forma do histórico no contexto fornecido | Usado por `annRedraw` e pelo `ann-save` |
| `annShowTextInput(x, y, prefill?)` | Posiciona e mostra o input de texto no canvas, com EMA state e B/I sync | `prefill` opcional para reedição via dblclick |
| `annCanvasXY(e)` | Converte coordenadas do evento para coordenadas do canvas (sem clamping) | Para posicionamento de texto |
| `annCanvasXYClamped(e)` | Converte + clamp aos limites do canvas | Para formas (evita saírem do canvas) |
| `rdp(pts, eps)` | Ramer-Douglas-Peucker — simplifica um path de pontos removendo colineares | Aplicado no mouseup do desenho livre (ε=1.8px), após passagem Laplaciana |
| `laplacian(pts, iters)` | Suavização Laplaciana — desloca cada ponto para a média ponderada dos vizinhos | Aplicado no mouseup do desenho livre (2 iterações), antes do RDP |
| `deactivateAdmin()` | Oculta botões admin; exposta como `window._deactivateAdmin` | Chamada por `closeSettingsModal` e pelo gate manual |

### Funções de Estado de Anotação (V20)

| Função | O que faz | Notas |
|---|---|---|
| `setAnnDirty(val)` | Define `annIsDirty` e controla visibilidade do botão fechar modal | Esconde `img-modal-close` quando `annActive && annIsDirty` |
| `hasUnsavedAnnotations()` | Retorna `true` se há anotações não guardadas (`annActive && annIsDirty`) | Usada por `closeImgModal`, `imgModalNav` e backdrop click |
| `triggerUnsavedAlert()` | Anima botões Confirmar/Cancelar com pulse para alertar o utilizador | Chamada quando se tenta fechar com anotações pendentes |

### Funções de Segurança

| Função | Assinatura | O que faz |
|---|---|---|
| `escapeHTML(s)` | `(string) → string` | Escapa `& < > " ' \`` para entidades HTML seguras |

---

## 8. Fluxos de Comportamento

### Modo PDF 'exact' (Exportação em Tamanho Real)

Gera páginas com dimensões em pontos derivadas diretamente das dimensões em píxeis da imagem × 0.75 (conversão 96dpi → 72dpi). A imagem ocupa a página inteira, sem margens ou centrações. Útil para preservar as proporções exatas da evidência. Não está acessível via interface, sendo ativável apenas através do código via `pdfFmt = 'exact'` antes de `generatePDF()`.

### Fluxo completo de captura de imagem (Ctrl+V)

```
Utilizador pressiona Ctrl+V
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
| `images` | array | Imagens ativas da sessão (espelho em memória do IndexedDB) |
| `docs` | array | Documentos ativos da sessão |
| `removed` | array | Imagens na lixeira |
| `removedDocs` | array | Documentos na lixeira |
| `isDirty` | boolean | `true` = há alterações não guardadas |
| `sbExp` | boolean | `true` = sidebar de histórico está expandida |
| `_db` | IDBDatabase | Handle da base de dados IndexedDB |
| `_ensurePromise` | Promise \| null | Mutex de `ensureSession()` — evita race conditions |
| `_vbLabelDirty` | object | `{user: bool, equip: bool}` — track se o admin editou rótulos no VB |
| `sysColors` | object | Cores atuais `{main, fg}` — para cálculos de contraste automático |
| `annActive` | boolean | `true` = modo de anotação ativo |
| `annTool` | string | Ferramenta ativa: `rect` \| `circle` \| `arrow` \| `free` \| `text` |
| `annHistory` | array | Stack de formas anotadas (undo buffer); cada entrada: `{type, x1, y1, ...}` |
| `annRedoHistory` | array | Stack de redo; populado por undo |
| `annCurrentColor` | string | Cor ativa da toolbar de anotação (hex) |
| `annSizeIdx` | number | Índice em `ANN_SIZES=[2,4,8]` — espessura de linha ativa |
| `annTextBold` | boolean | Negrito ativo na ferramenta texto (padrão: `true`) |
| `annTextItalic` | boolean | Itálico ativo na ferramenta texto |
| `annTextSizeIdx` | number | Índice em `ANN_TEXT_SIZES=[14,18,24,36,48]` — tamanho de fonte ativo |
| `annEditingTextIdx` | number | Índice em `annHistory` do texto em edição via dblclick; `-1` = novo texto |
| `annTextClickTimer` | TimeoutID \| null | Timer de 220ms para distinguir single-click (novo texto) de dblclick (editar); scope de módulo |
| `annSmoothLast` | object \| null | Último ponto suavizado pelo EMA no desenho livre; resetado em activate/deactivate/mouseup |
| `annInitialState` | string \| null | JSON.stringify do `annHistory` ao ativar anotação — usado para detetar se houve alterações reais |
| `lastSaveAt` | number | Timestamp do último save automático para a status bar |
| `pdfFmt` | string | Modo de layout da página PDF ('vertical', 'horizontal', 'auto', 'exact') |
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

---

## 10. Workflow de Desenvolvimento para Agentes

1. **Nunca sobrescrever o arquivo inteiro** — sempre edições incrementais e cirúrgicas
2. **Nunca abrir o browser para testar** — o humano testa, o agente edita
3. **Após cada alteração significativa, atualizar:**
   - `readme.md` — se for nova funcionalidade visível ao utilizador
   - `design-tokens.md` — se for novo token CSS ou JS
   - `changelog.md` — sempre, com entrada na versão atual
4. **Codificação:** UTF-8 sem BOM
5. **Testar regressão mental:** Para cada alteração, verificar se os 3 contratos (zero-dep, Quine, XSS) continuam válidos
6. **Verificar markers:** Após qualquer edição ao HTML, confirmar que os 8 comment markers estão intactos

---

## 11. Checklist de Validação — Antes de Declarar Completo

Nenhuma tarefa está concluída sem validar todos os pontos abaixo:

**Segurança:**
- [ ] `escapeHTML()` aplicado a todos os dados do utilizador inseridos via `innerHTML`
- [ ] `sanitizeForQuine()` aplicado antes de tokens serem injetados no HTML exportado
- [ ] Sem `eval()`, `Function()`, ou `document.write()`

**Integridade do Quine:**
- [ ] Todos os 10 comment markers estão intactos (verificar com `grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" capture-engine.html` → deve retornar 10)
- [ ] `window.exportFile()`, `capturePristine()` e `sanitizeForQuine()` não foram movidos
- [ ] Formato das declarações `const TOKEN_* = 'valor'` preservado

**Unicidade:**
- [ ] Sem nomes duplicados possíveis em screenshots ou documentos
- [ ] A deduplicação verifica contra listas ativas **e** lixeira
- [ ] Comparação de nomes é case-insensitive

**Ciclo de vida de sessão (testar manualmente):**
- [ ] Abrir o arquivo → interface limpa, campos vazios, histórico vazio
- [ ] Digitar no campo User → estado "Gravado" aparece sem aguardar 5 segundos
- [ ] Capturar uma imagem → sessão aparece no histórico
- [ ] Apagar sessão ativa com histórico existente → navegação automática para sessão adjacente
- [ ] Apagar última sessão ativa → interface volta ao estado limpo inicial (sem sessão nova no histórico)
- [ ] Botão Nova Sessão → recarrega em branco, sessão anterior ainda no histórico

**Visual:**
- [ ] Imagens têm `border-radius: 0`, botões e cards de texto têm `border-radius` arredondado
- [ ] Arquivo abre sem erros na consola do browser
- [ ] Dark mode funciona sem flash branco (FOUC)

**Internacionalização:**
- [ ] Sem strings hardcoded em inglês visíveis ao utilizador
- [ ] Sem strings hardcoded em PT-PT (regionalismo) — usar PT neutro

**Ferramenta de Anotação (verificar após qualquer edição ao annotation engine):**
- [ ] `annTextClickTimer` declarado no scope de módulo (antes de `initAnnotation`)
- [ ] `annSmoothLast` declarado no scope de módulo
- [ ] `annDeactivate()` faz `clearTimeout(annTextClickTimer)` e `annSmoothLast=null`
- [ ] `annRedraw()` usa `forEach((h,_ri) => { if(_ri===annEditingTextIdx) return; ... })`
- [ ] `annDrawShape` usa `ctx.textBaseline='top'` e repõe `'alphabetic'` no final
- [ ] `closeSettingsModal` chama `window._deactivateAdmin()`
- [ ] `window._deactivateAdmin` é atribuído dentro de `initAdminGate`

---

## 12. Protocolo de Version Bump

Ao passar para uma nova versão (ex: V19 → V20), o número de versão antigo tem de ser substituído em **exatamente 5 locais vitais**.

**Os 5 locais obrigatórios:**

1. **`capture-engine.html`** — Dois locais dentro do arquivo:
   - Comentário do Visual Builder: `<!-- VISUAL BUILDER MODAL (V20) -->`
   - Badge visual no header do modal de configurações: `<span ...>V20</span>`

2. **`changelog.md`** — Nova entrada no topo: `## [V20] — YYYY-MM-DD`

3. **`readme.md`** — Título principal e referências

4. **`design-tokens.md`** — Título principal

5. **`agents.md`** — Este arquivo: título e referências


**Ação obrigatória antes de fechar:**
```bash
grep -rn "V20" capture-engine.html readme.md design-tokens.md agents.md changelog.md
# Verificar se restam referências intencionais vs fantasmas
```
Nunca assumir que as substituições foram completas sem verificar.

---

## 13. Disaster Recovery Técnico

Caso um utilizador apague ou corrompa o seu ficheiro `capture-engine.html` mas mantenha a pasta inalterada, o administrador pode orientar a recuperação baseada no princípio Same-Origin:

1. **Recuperação Simples (Same-Origin):** Colocar uma nova cópia do ficheiro com o **exato mesmo nome** na **exata mesma pasta** reativa o vínculo do browser ao IndexedDB existente.
2. **Extração de Emergência (DevTools):** Se a lógica do HTML for inoperável e precisar extrair os dados puros:
   - Abra um HTML em branco no contexto/pasta correta.
   - Pressione F12 para abrir as **Chrome DevTools**.
   - Navegue até `Application` > `IndexedDB` > `CaptureEngineDB`.
   - Expanda `images` ou `documents` e inspecione os registos.
   - Os ficheiros estão armazenados na coluna `blob`. Poderão necessitar de ser guardados programaticamente caso a interface gráfica falhe.

---

*Capture Engine V20 · Regras Operacionais para Agentes*
