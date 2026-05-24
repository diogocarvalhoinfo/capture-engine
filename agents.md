# Agents · Capture Engine V15

> Guia operacional para agentes de IA que lêem, editam ou estendem o Capture Engine.
> **Leia a Secção 0 antes de qualquer outra coisa.**

---

## 0. Modelo Mental — Antes das Regras

Antes de ler as regras, é necessário perceber *por que* elas existem. As regras não são arbitrárias — cada uma protege um dos três contratos fundamentais do motor:

### Contrato 1: O arquivo é a aplicação inteira

O `capture-engine.html` não é uma página que carrega recursos externos. É uma aplicação completa encapsulada num único arquivo. Isso significa:

- **Sem CDN.** Se colocar um `<script src="https://...">` qualquer, o arquivo deixa de funcionar em ambientes offline (bancos, hospitais, governo). O utilizador final não terá internet.
- **Sem npm, sem bundler.** O arquivo tem de abrir com duplo clique num Windows XP sem internet e funcionar. Toda a lógica está inline.

*Consequência de violar:* A aplicação falha silenciosamente em qualquer ambiente sem internet. O utilizador nunca saberá porquê.

### Contrato 2: O arquivo consegue copiar-se a si próprio

O motor tem uma funcionalidade chamada **Quine** — consegue exportar uma cópia de si próprio com configurações personalizadas. Para isso funcionar, o código-fonte original tem de estar recuperável e os marcadores de secção têm de estar intactos.

*Consequência de violar:* O Export Admin/User produz um arquivo corrompido ou incompleto que não abre corretamente no browser.

### Contrato 3: Os dados do utilizador nunca chegam ao DOM sem sanitização

Qualquer texto que o utilizador escreva (nome de sessão, legenda de imagem, nome de documento) pode conter caracteres especiais HTML como `<`, `>`, `"`. Se esses caracteres forem inseridos diretamente no DOM via `innerHTML`, um utilizador malicioso pode injetar HTML ou JavaScript arbitrário — um ataque chamado XSS.

*Consequência de violar:* Vulnerabilidade de segurança em produção num ambiente onde o arquivo pode estar a correr com dados sensíveis (evidências jurídicas, dados de clientes).

---

## 1. Regras Absolutas

### 1.1 Zero-Dependency — Sem dependências externas

**O que não fazer:**
```html
<!-- PROIBIDO — quebra o modo offline -->
<script src="https://cdn.jsdelivr.net/..."></script>
<link rel="stylesheet" href="https://fonts.googleapis.com/...">
```

**Por quê:** O Capture Engine destina-se a ambientes *air-gapped* (sem internet). Um CDN externo é um ponto único de falha: se não houver rede, a app não carrega. Se o CDN mudar, a app quebra. Se o CDN for comprometido, há um vetor de ataque.

**Regra:** Toda a lógica, todo o CSS, todos os ícones SVG, devem estar inline dentro do `capture-engine.html`. Sem exceções.

---

### 1.2 Single-File Quine — O arquivo que se auto-reproduce

**O que é um Quine:** Um programa capaz de produzir uma cópia de si próprio como output. O Capture Engine, ao fazer Export, lê o seu próprio código-fonte e gera um novo arquivo com os tokens de configuração substituídos.

**Como funciona tecnicamente:**
1. `capturePristine()` faz `fetch(location.href)` para ler o próprio arquivo
2. `exportFile()` substitui os valores dos tokens via regex
3. Para exports de User, remove os blocos marcados com comentários especiais
4. Faz download do HTML resultante

**O que nunca alterar:**

| O quê | Onde | Porquê |
|---|---|---|
| `window.exportFile()` | `ADMIN_JS_START/END` | Ponto de entrada do Export |
| `capturePristine()` | `ADMIN_JS_START/END` | Lê o código-fonte original |
| `sanitizeForQuine()` | `ADMIN_JS_START/END` | Protege os marcadores de serem corrompidos pelo próprio conteúdo |
| Todos os comment markers | Ver tabela Secção 5 | Definem o que é removido em exports de User |

**Regra:** Qualquer alteração ao arquivo deve preservar todos os comment markers intactos e todas as funções Quine funcionais.

---

### 1.3 XSS Prevention — Sanitização de inputs

**O problema:** O browser interpreta HTML dentro de strings. Se um utilizador escrever `<img src=x onerror=alert(1)>` como legenda de uma imagem e esse texto for inserido diretamente via `innerHTML`, o JavaScript `alert(1)` executa.

**A solução:** Antes de qualquer `innerHTML` com dados do utilizador, chamar `escapeHTML()`:
```js
// ERRADO — vulnerável
element.innerHTML = `<span>${userInput}</span>`;

// CORRETO — seguro
element.innerHTML = `<span>${escapeHTML(userInput)}</span>`;
```

**Para o Quine especificamente:** Usar `sanitizeForQuine()` antes de injetar valores de tokens no HTML exportado. Esta função também protege os comment markers de serem acidentalmente incluídos em valores de tokens (o que corromperia o arquivo exportado).

**Nunca usar:**
- `eval()` — executa código arbitrário
- `Function()` — equivalente a eval
- `document.write()` — sobrescreve o DOM inteiro

---

### 1.4 Air-Gapped Environment — Funcionar sem internet

**O que significa air-gapped:** O computador onde a app corre não tem (ou não deve ter) acesso à internet. É a realidade de muitos ambientes corporativos (banca, saúde, governo).

**Regras práticas:**
- Nenhum `fetch()` para URLs externas (apenas `fetch(location.href)` para o Quine é permitido)
- Nenhuma fonte de ícones externa (todos os ícones são SVG inline)
- Nenhuma chamada a APIs externas de qualquer tipo
- Persistência apenas em `localStorage` e `IndexedDB` (mecanismos do browser, sem servidor)

---

## 2. Convenções de Código

### 2.1 Língua — Onde usar inglês e onde usar português

| Contexto | Língua | Exemplo |
|---|---|---|
| Nomes de variáveis, funções, comentários técnicos | Inglês | `captureImg()`, `sessId`, `isDirty` |
| Labels visíveis para o utilizador na UI | Português neutro | `"Histórico"`, `"Removidos"`, `"Processando..."` |

**Português neutro — glossário aprovado V15:**

| ✅ Usar | ❌ Evitar | Razão |
|---|---|---|
| `"Arquivo"` | `"Arquivo"` | Regionalismo PT-PT |
| `"Histórico"` | `"Sessões"` | Mais claro para utilizadores não-técnicos |
| `"Download"` | `"Descarregar"` | Termo universal |
| `"Equipamento"` | `"Máquina"` | Mais formal e neutro |
| `"Ecrã"` → Não usar | `"Ecrã"` | Usar contexto ou reformular |

---

### 2.2 CSS — Unidades e Modo Escuro

**Usar `px`, nunca `rem` ou `em`**

Porquê: `rem` depende do `font-size` do elemento `<html>`. Em ambientes corporativos com configurações de acessibilidade que alteram o tamanho de fonte do browser, `rem` produz layouts quebrados imprevisíveis. `px` é determinístico — 36px é sempre 36px.

**Dark mode via `body.dark`, nunca via media query CSS**

Porquê: O utilizador pode ter o sistema em modo escuro mas querer a app em modo claro, ou vice-versa. A class `body.dark` é controlada por JavaScript e persiste a preferência do utilizador em `localStorage`. A media query `prefers-color-scheme` no CSS não permite override manual.

```css
/* CORRETO — controlável pelo utilizador */
body.dark { --bg: #121212; }

/* PROIBIDO — não permite override manual */
@media (prefers-color-scheme: dark) { --bg: #121212; }
```

> **Exceção:** O script anti-FOUC e o `initTheme()` em JavaScript *podem* usar `window.matchMedia('prefers-color-scheme')` como fallback na primeira abertura (antes de o utilizador ter definido preferência). O JS lê a preferência do OS, aplica a classe, e a partir daí o CSS faz o resto.

**Z-index stack:**
- `9999` → Modais (imagem, texto, anotação)
- `1000` → Banners (restaurar sessão)
- `0` → Conteúdo base

---

### 2.3 Gold Standard — Tamanhos e Proporções

Estes valores foram calibrados para simetria visual com o SDE V48. Alterá-los quebra a harmonia visual entre os dois motores.

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

Existe uma distinção visual intencional entre elementos de texto e elementos de imagem:

| Tipo de elemento | `border-radius` | Porquê |
|---|---|---|
| Botões, cards de texto, modais | `--radius-sm` a `--radius-lg` | Orgânicos, amigáveis |
| Imagens, wrappers de imagem, legendas `.t-item`, `.t-wrap`, `.t-label` | `0` (quadrado perfeito) | Técnico, preciso — as imagens são evidências, não decoração |

**Cards de documento sem bordas visíveis:**

Os `.d-item` têm `border: 1px solid transparent`. A borda existe no DOM (evitando layout shift), mas é invisível. Isto faz os documentos "flutuarem" sobre o fundo sem criar uma grelha rígida.

---

### 2.5 JavaScript — Estrutura do Código

**IIFE obrigatório:**
```js
(function() {
  'use strict';
  // Todo o código aqui dentro
})();
```
Porquê: Isola completamente todas as variáveis do scope global da página. Previne que nomes de funções internas colidam com APIs do browser ou com scripts injetados.

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
Porquê: `SysLogger` respeita `TOKEN_DEBUG_MODE`. Em exports de User, este token é `false` — os logs desaparecem automaticamente. `console.log` direto ficaria visível para sempre.

**Funções expostas ao DOM:**
```js
// Para que onclick="window.delImg(id)" funcione
window.delImg = async function(id) { ... };
```
O IIFE isola o scope — funções chamadas por atributos HTML inline (como `onclick="..."`) precisam de estar em `window` para serem acessíveis.

---

## 3. Unicidade de Nomes — Prevenção de Colisões no ZIP

**O problema:** Se dois arquivos no ZIP tiverem o mesmo nome, alguns sistemas operativos (Windows Explorer, macOS Archive Utility) comportam-se de forma imprevisível: podem sobrescrever um com o outro, ou recusar a extração.

**A solução — algoritmo de incremento inteligente:**

1. Nome inicial: `imagem-1` ou `texto-1.txt`
2. Se já existe, decompor o sufixo `-N`: `imagem-1` → extrair `1`
3. Incrementar: `imagem-2`, `imagem-3`, etc.
4. **Nunca** criar `imagem-1-1` — sempre incrementar o número existente

```
imagem-1 → imagem-2 → imagem-3   ✅
imagem-1 → imagem-1-1            ❌
```

**Verificação cross-list:** A unicidade é verificada contra *ambas* as listas simultaneamente — itens ativos E itens na lixeira. Assim, um item restaurado da lixeira nunca colide com um ativo.

**ZIP Export:** Os nomes dos arquivos no ZIP usam diretamente as legendas limpas (`imagem-1.png`, `relatorio.pdf`), sem prefixos numéricos adicionais (`001-imagem-1.png` seria redundante e desnecessário).

### 3.3 Nomes de Sessões sem Título

Sessões sem nome digitado pelo utilizador recebem um identificador cronológico com zeros à esquerda: `#0001`, `#0002`, etc. (nunca `Sessão-1`). O número reflete a ordem de criação — não a posição atual na lista.

---

## 4. Ciclo de Vida da Sessão

Este é o comportamento mais complexo do motor. Qualquer agente que edite código relacionado com sessões deve compreender este fluxo completamente.

### O modelo mental

Pense nas sessões como arquivos num sistema de arquivos:
- **Sessão ativa** = o arquivo aberto agora
- **Histórico** = os outros arquivos guardados
- **Pristine** = estado de "arquivo novo" — sem nada

Ao abrir a aplicação, começa sempre com um arquivo novo (sessão nova em branco). O histórico de sessões anteriores fica acessível, mas a sessão ativa é sempre nova. Sessões só aparecem no histórico depois da primeira interação real (digitação, captura, ou drag-drop).

### Fluxo de estados

```
Abrir arquivo
      │
      ▼
createSession() cria sessão em branco
      │
      ├─── Sem interação ──────────────► Sessão não aparece no histórico
      │
      └─── Primeira interação ─────────► ensureSession() confirma sessão
                                               │
                                               ▼
                                        renderSbSessions() → aparece no histórico
```

### Tabela de eventos obrigatórios

| Evento | Comportamento obrigatório |
|---|---|
| **Abrir a aplicação** | `init()` → `createSession()` diretamente. Nunca reutilizar sessão existente. Excepção: `ec_pending_session` válido em `localStorage` (vem do botão Nova Sessão). |
| **Primeira interação** | `ensureSession()` confirma e regista a sessão; `renderSbSessions()` faz-a aparecer no histórico. |
| **Digitar em User/Equipamento** | `initSessionSync` → `up()` → `isDirty=true` → `triggerSave()` **imediato** (não aguarda os 5 segundos). |
| **Apagar sessão NÃO ativa** | Apenas `renderSbSessions()`. A sessão ativa e o DOM ficam intactos. |
| **Apagar sessão ATIVA com vizinha** | Capturar `neighbor` *antes* da deleção: `allBefore[idx+1] \|\| allBefore[idx-1]`. Após deleção: `loadSession(neighbor.id)` + `renderSbSessions()`. |
| **Apagar sessão ATIVA sem vizinha** | Reset completo: `sessId=null`, `sessObj=null`, arrays zerados, DOM limpo, campos zerrados. **Não criar nova sessão.** |
| **`createSession()` diretamente** | Apenas em `init()` e `ensureSession()`. Nunca chamar em `deleteSessionId()` ou handlers de evento. |

> **Porquê nunca criar sessão em `deleteSessionId`?** Porque o utilizador que apaga a última sessão está a decidir ter um interface vazia. Criar uma sessão automática seria tratar o utilizador como se não soubesse o que quer — e causaria um loop onde apagar sempre gerava uma sessão nova no histórico.

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

**Proteção do Quine:** A função `sanitizeForQuine()` substitui estes marcadores nos *valores de tokens* com versões com zero-width space (caractere invisível). Isto evita que, por exemplo, um token com o texto `ADMIN_JS_START` corrompa o regex de strip. Esta proteção aplica-se também a `EXPORT MODAL` e `FIM EXPORT MODAL`.

---

## 6. IndexedDB — Base de Dados Local

| Propriedade | Valor |
|---|---|
| Nome da base de dados | `CaptureEngineDB` |
| Versão do schema | `2` |
| Tabelas (object stores) | `sessions`, `images`, `documents`, `removed_images`, `removed_documents` |

**Auto-save:** `setInterval` de 5 segundos no `boot()` chama `saveSession()` se `isDirty === true`.

**Purge:** `purgeExpired()` corre em cada `init()`. Apaga sessões cuja `updatedAt` seja mais antiga que `TOKEN_AUTO_PURGE_HOURS` horas. Apaga também todos os items associados (imagens, documentos, removidos).

---

## 7. Workflow de Desenvolvimento para Agentes

1. **Nunca sobrescrever o arquivo inteiro** — sempre edições incrementais e cirúrgicas
2. **Nunca abrir o browser para testar** — o humano testa, o agente edita
3. **Após cada alteração significativa, atualizar:**
   - `readme.md` — se for nova funcionalidade visível ao utilizador
   - `design-tokens.md` — se for novo token CSS ou JS
   - `changelog.md` — sempre, com entrada na versão atual
4. **Codificação:** UTF-8 sem BOM

---

## 8. Checklist de Validação — Antes de Declarar Completo

Nenhuma tarefa está concluída sem validar todos os pontos abaixo:

**Segurança:**
- [ ] `escapeHTML()` aplicado a todos os dados do utilizador inseridos via `innerHTML`
- [ ] `sanitizeForQuine()` aplicado antes de tokens serem injetados no HTML exportado
- [ ] Sem `eval()`, `Function()`, ou `document.write()`

**Integridade do Quine:**
- [ ] Todos os comment markers estão intactos (verificar com `grep`)
- [ ] `window.exportFile()`, `capturePristine()` e `sanitizeForQuine()` não foram movidos ou alterados

**Unicidade:**
- [ ] Sem nomes duplicados possíveis em screenshots ou documentos
- [ ] A deduplicação verifica contra listas ativas E removidos

**Ciclo de vida de sessão (testar manualmente):**
- [ ] Abrir o arquivo → interface limpa, campos vazios, histórico vazio
- [ ] Digitar no campo User → estado "Gravado" aparece sem aguardar 5 segundos
- [ ] Capturar uma imagem → sessão aparece no histórico
- [ ] Apagar sessão ativa com histórico existente → navegação automática para sessão adjacente
- [ ] Apagar última sessão ativa → interface volta ao estado limpo inicial

**Visual:**
- [ ] Imagens têm `border-radius: 0`, botões e cards de texto têm `border-radius` arredondado
- [ ] Arquivo abre sem erros na consola do browser

---

## 9. Protocolo de Version Bump

Ao passar para uma nova versão (ex: V15 → V16), o número de versão antigo tem de ser substituído em **exatamente 5 locais vitais**. Esquecer qualquer um cria inconsistências que confundem futuros agentes.

**Os 5 locais obrigatórios:**

1. **`capture-engine.html`** — Dois locais dentro do arquivo:
   - Comentário do Visual Builder: `<!-- VISUAL BUILDER MODAL (V16) -->`
   - Badge visual no header do modal de configurações: `<span ...>V16</span>`

2. **`changelog.md`** — Nova entrada no topo: `## [V16] — YYYY-MM-DD`

3. **`readme.md`** — Título principal e referências ao "padrão V16"

4. **`design-tokens.md`** — Título principal

5. **`agents.md`** — Este arquivo: título e referências ao "padrão V16"

> **`CaptureEngineApp.vbs.md`** é revisto no bump mas não requer substituição de versão CE — o launcher tem versionamento próprio (`1.x.x`). Verificar apenas se há referências de contexto ao número de versão CE.

**Ação obrigatória antes de fechar:** Correr `grep -r "V15" *.html *.md` para caçar referências fantasma. Nunca assumir que as substituições foram completas sem verificar.

---

*Capture Engine V15 · Agents Operational Rules · FAANG Standards*
