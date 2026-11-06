# Regras para agentes

Regras para quem edita este projeto, pessoa ou IA, com o motivo de cada uma.

Toda mudança no `capture-engine.html` preserva os marcadores do Quine e passa no `validate.sh` antes do commit.

## Índice

- [Seção 0 — Modelo mental](#0-modelo-mental)
- [Seção 1 — Regras absolutas](#1-regras-absolutas)
- [Seção 2 — Convenções de código](#2-convenções-de-código)
- [Seção 3 — Unicidade de nomes](#3-unicidade-de-nomes--prevenção-de-colisões-no-zip)
- [Seção 4 — Ciclo de vida da sessão](#4-ciclo-de-vida-da-sessão)
- [Seção 5 — Comment markers do Quine](#5-comment-markers--blocos-de-código-removíveis)
- [Seção 6 — IndexedDB: schema completo](#6-indexeddb--schema-completo)
- [Seção 7 — Funções críticas: referência rápida](#7-funções-críticas--referência-rápida)
- [Seção 8 — Fluxos de comportamento](#8-fluxos-de-comportamento)
- [Seção 9 — Variáveis de estado global](#9-variáveis-de-estado-global)
- [Seção 10 — Fluxo de trabalho de desenvolvimento](#10-fluxo-de-trabalho-de-desenvolvimento-para-agentes)
- [Seção 11 — Checklist de validação](#11-checklist-de-validação--antes-de-declarar-completo)
- [Seção 12 — Versões e changelog](#12-versões-e-changelog)
- [Seção 13 — Decisões, pendentes e IDs](#13-decisões-pendentes-e-ids)
- [Seção 14 — Disaster recovery técnico](#14-disaster-recovery-técnico)

## Índice de leitura por perfil

Não é necessário ler o documento inteiro antes de cada tarefa. Use esta tabela:

| Situação | Ler obrigatoriamente |
|---|---|
| **Primeira vez no código** | §0, §1, §2, §3, §4, §5, §11 |
| **Corrigir um bug pontual** | §0, §1, §5, §11 + a seção do motor afetado |
| **Adicionar funcionalidade** | §0, §1, §2, §3, §4, §5, §7, §10, §11 |
| **Modificar o ciclo de sessões** | §0, §1, §4, §6, §7 (funções de sessão), §11 |
| **Modificar a anotação** | §0, §1, §7 (funções de anotação), §9, §11 |
| **Modificar o Quine / Export** | §0, §1, §1.2, §5, §7 (funções Quine), §11 |
| **Modificar tokens ou Visual Builder** | §1.2, §6, §7 (funções Quine), §13 |
| **Fechar uma versão** | §12 |
| **Recuperação de dados** | §14 |

## Como editar este arquivo com segurança

- Desative qualquer auto-formatador (Prettier, ESLint --fix, EditorConfig-based format-on-save) antes de editar. Formatação automática SILENCIOSAMENTE corrompe os comment-markers que o `validate.sh` e o Quine dependem. Se o IDE formatar ao salvar, desative essa opção especificamente para este arquivo.

  **VS Code / Cursor** — crie ou edite `.vscode/settings.json` na raiz do projeto:
  ```json
  {
    "[html]": {
      "editor.formatOnSave": false,
      "editor.defaultFormatter": null
    }
  }
  ```
  **JetBrains / Sublime / outros:** desative a formatação automática de `.html` nas preferências do IDE.

  **Antigravity:** risco menor — agentes editam por código. Confirme que nenhum fluxo de trabalho com "format" está ativo para `.html`.
- Use code folding para navegar (ex.: VS Code "Fold by Indentation"). O arquivo tem mais de 5000 linhas — sem folding a navegação é impraticável.
- Extensões de navegador que injetam no DOM (Grammarly, Adblockers, gerenciadores de senha, tradutores automáticos) podem corromper o snapshot do Quine (`BOOT_HTML` é capturado do `outerHTML` no boot). Para testes de desenvolvimento, use um perfil de navegador sem extensões.
- Sempre execute `validate.sh` após qualquer mudança no `capture-engine.html` e antes de qualquer commit.

---

## 0. Modelo mental

Antes de ler as regras, é necessário entender *por que* elas existem. As regras não são arbitrárias — cada uma protege um dos três contratos fundamentais do motor:

### Contrato 1: O arquivo é a aplicação inteira

O `capture-engine.html` não é uma página que carrega recursos externos. É a aplicação inteira num único arquivo. Isso significa:

- **Sem CDN.** Se colocar um `<script src="https://...">` qualquer, o arquivo deixa de funcionar em ambientes sem internet (bancos, hospitais, governo). O usuário final não terá internet.
- **Sem npm, sem bundler.** O arquivo precisa abrir com duplo clique num Windows sem internet e funcionar. Toda a lógica está inline.

*Consequência de violar:* A aplicação falha silenciosamente em qualquer ambiente sem internet. O usuário nunca saberá porquê.

### Contrato 2: O arquivo consegue copiar-se a si próprio

O motor tem uma funcionalidade chamada **Quine** — consegue exportar uma cópia de si próprio com configurações personalizadas. Para isso funcionar, o código-fonte original precisa estar recuperável e os marcadores de seção precisam estar intactos.

*Consequência de violar:* O Export Admin/User produz um arquivo corrompido ou incompleto que não abre corretamente no navegador.

### Contrato 3: Os dados do usuário nunca chegam ao DOM sem sanitização

Qualquer texto que o usuário escreva (nome de sessão, legenda de imagem, nome de documento) pode conter caracteres especiais HTML. Se inseridos diretamente via `innerHTML`, um usuário malicioso pode injetar JavaScript — ataque XSS.

*Consequência de violar:* Vulnerabilidade de segurança em produção num ambiente onde o arquivo pode processar dados sensíveis (evidências jurídicas, dados de clientes).

---

## 1. Regras absolutas

### 1.1 Zero dependências externas

**O que não fazer:**
```html
<!-- PROIBIDO — deixa de funcionar sem internet -->
<script src="https://cdn.jsdelivr.net/..."></script>
<link rel="stylesheet" href="https://fonts.googleapis.com/...">
```

**Motivo:** O Capture Engine destina-se a ambientes totalmente isolados (sem internet). Um CDN externo é um ponto único de falha: se não houver rede, a app não carrega.

**Regra:** Toda a lógica, todo o CSS, todos os ícones SVG, devem estar inline dentro do `capture-engine.html`. Sem exceções.

---

### 1.2 Quine de arquivo único: o arquivo que se copia

**Como funciona o Quine:**
1. `capturePristine()` faz `fetch(location.href)` para ler o próprio arquivo
2. Fallback para `BOOT_HTML` se o `fetch` falhar (ex: protocolo `file://` com restrições)
3. `exportFile()` substitui os valores dos tokens via regex

> **Aviso Técnico (CORS Local):** Aberto por `file://` no Chrome ou no Safari, o `fetch(location.href)` falha logo, por causa das regras de CORS para arquivos locais. O navegador trata um arquivo local como origem opaca e proíbe o `fetch` a si mesmo. O sistema sobrevive porque o `BOOT_HTML` guarda o DOM ao abrir, antes de qualquer mutação. É o `document.documentElement.outerHTML`, com `<!DOCTYPE html>` à frente para manter o standards mode. O Quine opera sobre o fallback de forma imperceptível ao usuário.

> **Aviso Técnico (Servidor HTTP):** Servida por HTTP (ex.: `python -m http.server`, Apache, Nginx), o `fetch(location.href)` pode ter sucesso e devolver HTML **gerado pelo servidor**, e não o código-fonte. Nesse caso, o Quine exporta **o que o servidor devolveu**. Nunca é o DOM vivo: depois da abertura, nenhum caminho volta a ler o DOM. O `BOOT_HTML` (fallback estático) não é utilizado quando o fetch tem sucesso. Para desenvolvimento local, use um servidor que sirva o arquivo sem o processar; o `python -m http.server` é seguro. Em servidores com geração dinâmica de HTML, o Export pode produzir arquivos corrompidos silenciosamente.
4. Para exports de User, remove os blocos marcados com comment markers
5. Faz download do HTML resultante

**O que é `BOOT_HTML`:** Uma constante estática capturada no momento do boot, antes de qualquer mutação do DOM. É o fallback do Quine quando o `fetch(location.href)` não está disponível. Sem ela, e se o `fetch` falhar, o `PRISTINE_HTML` ficaria `null` e o export **abortaria** — `if (!PRISTINE_HTML) { SysLogger.error('PRISTINE_HTML not available'); return }`. ⚠️ **Não confundir com proteção contra mutação do DOM (ver D69):** o `BOOT_HTML` **é** a serialização do DOM, tirada cedo. O que o protege de mutações é o **momento** em que é tirado. Por isso, em `file://`, o artefato exportado é HTML serializado de novo pelo navegador, e não os bytes do arquivo.

**O que nunca alterar:**

| O quê | Onde | Motivo |
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

No Visual Builder, o campo «Texto final» (`cfg-title-end`) controla `TOKEN_TITLE_END`. O Quine exporta os 3 tokens.

**Formato dos tokens:**
```js
// O regex do Quine aceita espaços, e devem ser mantidos para legibilidade:
const TOKEN_MAIN_COLOR = '#e86b2e';
```

> **Proteção de colisão do regex:** As substituições de tokens no `exportFile()` usam regex presas à sintaxe da declaração, como `/const TOKEN_MAIN_COLOR\s*=\s*'(?:[^'\\]|\\.)*'/`. O padrão do valor **precisa conhecer escapes** (ver o aviso crítico na `§1.3`). Assim, só a declaração é substituída, e não o nome num comentário, num log ou no código (ex.: `console.log("TOKEN_MAIN_COLOR")`). Além disso, `sanitizeForQuine()` insere espaços de largura zero (U+200B) nos valores dos campos editáveis antes de serializar o HTML. Um texto digitado nunca coincide com os marcadores do Quine (ex.: `ADMIN_EDIT_START`).

**Regra:** Qualquer alteração ao arquivo deve preservar todos os comment markers intactos e todas as funções Quine funcionais.

---

### 1.3 Prevenção de XSS: sanitização de campos

**O problema:** O navegador interpreta HTML dentro de strings. Se um usuário escrever `<img src=x onerror=alert(1)>` como legenda e esse texto for inserido via `innerHTML`, o JavaScript executa.

> **Modelo de ameaça:** A app é local e de um só usuário, mas o conteúdo capturado pode vir de terceiros. Um exemplo é o texto de um ticket de cliente, colado por um técnico de Service Desk. Esse texto, ao ser renderizado sem sanitização, executaria no contexto do arquivo. Em ambientes que processam dados de clientes (setor bancário, seguros), isto é um risco real — daí a sanitização ser obrigatória.

**A solução:** Usar sempre `escapeHTML()` antes de qualquer `innerHTML` com dados do usuário:
```js
// ERRADO — vulnerável a XSS
element.innerHTML = `<span>${userInput}</span>`;

// CORRETO — seguro
element.innerHTML = `<span>${escapeHTML(userInput)}</span>`;
```

**Para o Quine:** Usar `sanitizeForQuine()` antes de injetar valores de tokens no HTML exportado. Esta função protege os comment markers de serem acidentalmente incluídos em valores de tokens (o que corromperia o arquivo exportado).

> **Comportamento adicional de `sanitizeForQuine()`:** Para além de proteger os 8 marcadores, a função também escapa aspas simples (`'` → `\'`). Tokens com apóstrofos (ex.: `TOKEN_FOOTER_TEXT = '© 2026 • O'Brien Tools'`) saem com a aspa escapada. O arquivo resultante é JavaScript válido, mas quem abrir o HTML num editor verá `O\'Brien` em vez de `O'Brien`. Este é o comportamento correto e esperado.

> ⚠️ **AVISO CRÍTICO — as regexes de substituição precisam conhecer escapes:** escapar o apóstrofo em `sanitizeForQuine` só resolve **metade** do problema. Da V11 à V26 as 11 regexes de token de texto usavam `'[^']*'`, que **para no primeiro apóstrofo, mesmo escapado**. Consequência: o artefato da 1.ª geração ficava correto. Ao **reexportar a partir dele**, o padrão cortava a declaração no meio e produzia `SyntaxError`, e a aplicação ficava morta. Corrigido na D40 com `'(?:[^'\\]|\\.)*'`, que consome pares escapados como unidade.
>
> **Ao editar `exportFile`:** qualquer regex nova que capture um valor de token entre aspas simples precisa usar este padrão. `'[^']*'` é sempre errado aqui — funciona uma geração e quebra a seguinte, o que o torna especialmente traiçoeiro: passa em qualquer teste que exporte só uma vez.

**Nunca usar:**
- `eval()` — executa código arbitrário
- `Function()` — equivalente a eval
- `document.write()` — sobrescreve o DOM inteiro

---

### 1.4 Ambiente isolado — funcionar sem internet

**Regras práticas:**
- Nenhum `fetch()` para URLs externas (apenas `fetch(location.href)` para o Quine é permitido)
- Nenhuma fonte de ícones externa (todos os ícones são SVG inline)
- Nenhuma chamada a APIs externas
- Persistência apenas em `localStorage` e `IndexedDB` (mecanismos do navegador, sem servidor)

#### A CSP que torna estas regras executáveis

As regras acima não dependem de disciplina do programador — estão impostas por uma metatag no cabeçalho do `capture-engine.html` (linha 19):

```html
<meta http-equiv="Content-Security-Policy"
  content="default-src 'self' blob: data:; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src blob: data:; connect-src 'self';">
```

| Diretiva | O que impõe |
|---|---|
| `default-src 'self' blob: data:` | Rede de segurança para os tipos de recurso **que não têm diretiva própria** (`font-src`, `media-src`, `frame-src`, …). Para scripts, estilos, imagens e conexões **não se aplica**: as quatro diretivas abaixo substituem-no para os respectivos tipos. É a §1.1 aplicada pelo navegador, mas em camadas — não uma regra única que cobre tudo. |
| `script-src 'unsafe-inline'` | Permite o JS inline — **consequência estrutural** do single-file, não comodidade. Não há `'self'`: um `<script src>` externo não carregaria nem que alguém o acrescentasse. |
| `style-src 'unsafe-inline'` | O mesmo para o CSS inline. |
| `img-src blob: data:` | As capturas vivem como `blob:`/`data:`. Uma `<img src="https://…">` é bloqueada. |
| `connect-src 'self'` | **Não mexer sem ler o parágrafo seguinte.** |

> ⚠️ **`connect-src 'self'` é o que mantém o Quine vivo.** O `capturePristine()` faz `fetch(location.href)` para ler o próprio arquivo (§1.2). Apertar esta diretiva para `'none'` não produz erro visível. O `fetch` falha, a função cai no fallback `BOOT_HTML`, e o export continua, com uma cópia desatualizada do arquivo. É uma falha silenciosa que o `validate.sh` não detecta, porque o artefato produzido continua estruturalmente válido.

**Ao acrescentar qualquer recurso novo:** a CSP bloqueia primeiro e o sintoma aparece no console, não na interface. Antes de concluir que «o recurso não funciona», confirme no console se foi a CSP que o recusou. Se foi, embuta o recurso em vez de relaxar a diretiva.

O `README.md` §Segurança documenta o mesmo para o público externo, incluindo por que `'unsafe-inline'` não é aqui a fraqueza que costuma ser.

---

## 2. Convenções de código

### 2.1 Idioma em três zonas

Cada zona tem a sua regra.

- **Documentação** (README, `AGENTS.md`, `CHANGELOG.md`, `design-tokens.md`, mensagens de commit): português neutro, sem formas só do Brasil nem só de Portugal. Onde os dois países usam palavras diferentes, vale a tabela abaixo. Um termo da interface aparece como está na interface, entre aspas («User»).
- **Interface** (o texto que o usuário vê): português neutro. **Motivo:** a ferramenta serve equipes de suporte de qualquer país de língua portuguesa.
- **Código** (ids, classes, tokens, variáveis, funções e comentários técnicos): inglês. Os comentários do HTML estão em inglês desde a 28.6.4 (F-0029, D-0085). Sem apóstrofos neles: a heurística de complexidade do `validate.sh` lê os comentários (§10).

**Tabela de palavras:**

| Use | Não use |
|---|---|
| arquivo, usuário, seção, registrar, registro, compartilhar, tela, equipe, fato, contato, lugar, por isso | ficheiro, utilizador, secção, registar, registo, partilhar, ecrã, equipa, facto, contacto, sítio, pelo que |
| navegador, captura de tela, sem internet, entrada, saída, rótulo | browser, screenshot, offline, input, output, label |
| «precisa», «deve» | «tem de», «tem que» |
| presente simples («usa») | «está a usar», «está usando» |

**Palavras de propósito na interface:**
- **«User»**, rótulo padrão do primeiro campo da identificação. **Motivo:** é o padrão que o administrador troca no Visual Builder (`TOKEN_USER_LABEL`). É também o nome do perfil «Export User».
- **«Equipamento»**, rótulo padrão do segundo campo, é a forma dos dois países e não precisa de motivo.
- **«Histórico»**, e não «Sessões». **Motivo:** é mais claro para quem não é técnico.
- No Visual Builder, os dois campos da identificação chamam-se «Primeiro campo» e «Segundo campo». **Motivo:** o nome segue a ordem da barra lateral e vale para qualquer rótulo; o exemplo por baixo diz para que serve. Foram descartados «Campo 1», «Identificação 1», «Título» e «Identificação primária». Os números liam-se mal, «Título» sugere um título, e «primária» uma hierarquia que não existe.

### 2.2 CSS: unidades e tema escuro

**Tamanhos de fonte, espaços e cortes do layout em `rem` (D-0082)**

- Tamanho de fonte: sempre por token `--text-*` (`var(--text-control)`, 13px). Os degraus do Tailwind (`--text-xs` a `--text-xl`) valem o mesmo que no Tailwind; os outros têm nome de papel (`--text-caption`, `--text-control`).
- Espaços (`padding`, `margin`, `gap`): múltiplos de `--spacing: 0.25rem`, escritos `calc(var(--spacing) * n)`.
- Cortes do layout: em `rem`, na notação de intervalo (`@media (width <= 56.25rem)`).
- Bordas, alturas, larguras e ícones podem ficar em `px`.
- Telas grandes: a interface cresce com `zoom: var(--app-zoom)` no `html` (uma rampa de 1 até 100rem a 1,25 a partir de 140rem, em 16 degraus de 2.5rem). **Motivo da rampa:** o zoom do navegador diminui a largura útil; com um degrau grande, um passo de zoom deixava a interface menor. Uma medida em `vw` ou `vh` divide-se por `var(--app-zoom)`. Uma posição medida na tela (`getBoundingClientRect`, `clientX`) que vai para um estilo em `px` divide-se por `uiZoom()`, porque o `zoom` volta a multiplicá-la.

**Motivo:** em `rem`, o texto acompanha o tamanho de letra escolhido no navegador. Com a letra padrão (16 px), cada valor dá o mesmo pixel que dava em `px`.

**Tema escuro pela classe `dark` no `<html>`, nunca por media query no CSS**

Motivo: O usuário pode ter o sistema em dark mode mas querer a app em light mode. A classe `dark` do `<html>` é controlada por JavaScript e persiste em `localStorage`. A media query `prefers-color-scheme` no CSS não permite override manual.

```css
/* CORRETO — controlável pelo usuário */
html.dark { --color-background: #121212; }

/* PROIBIDO — não permite override manual */
@media (prefers-color-scheme: dark) { --color-background: #121212; }
```

> **Exceção permitida:** `initTheme()` em JavaScript *pode* usar `window.matchMedia('prefers-color-scheme')` como fallback na primeira abertura (antes de o usuário ter definido preferência). O JS lê o OS, aplica a classe, e a partir daí o CSS faz o resto.

**Camadas (z-index):** todo `z-index` usa um token `--z-*`, na escala do Bootstrap. A tabela está no `design-tokens.md` §4, e o check 23 do `validate.sh` confere-a.

---

### 2.3 Tamanhos e proporções calibrados

Estes valores foram calibrados para simetria visual. Alterá-los quebra a harmonia visual.

| Elemento | Tamanho |
|---|---|
| Botões principais `.btn-send` | `height: 36px`, `font-size: var(--text-control)` (13px), `padding: 0 calc(var(--spacing) * 4.5)` (18px) |
| Ícones dentro de botões | `14px`, `stroke-width: 2` |
| Ícones de cabeçalho de bloco `.blk-hdr svg` | `16px` |
| Spinner de loading | `14px` |
| Título de modal `.modal-title` | `var(--text-base)` (16px), centrado |
| Botão fechar modal `.modal-close` | `32px` circular, `background: var(--color-background)` |
| Badges de contagem | `var(--text-caption)` (11px), bold |
| Nomes na sidebar | `var(--text-xs)` (12px) |
| Datas na sidebar | `var(--text-caption)` (11px) |
| Legendas de imagem `.t-label` | `var(--text-caption)` (11px), `font-weight: 400` (sem negrito) |
| Campos de documento `.d-input` | `var(--text-control)` (13px), `font-weight: 400` (sem negrito) |

---

### 2.4 Estética geométrica: bordas e cantos

**A lógica dos cantos:**

| Tipo de elemento | `border-radius` | Motivo |
|---|---|---|
| Botões, cards de texto, modais | `--radius-md` a `--radius-xl` | Orgânicos, amigáveis |
| Imagens e legendas `.t-item`, `.t-label` | `0` (quadrado perfeito) | Técnico, preciso — card e legenda com cantos retos |
| Wrapper de miniatura `.t-wrap` | `var(--radius-md)` (6px) | Suaviza a moldura visual da imagem na grade |

**Cards de documento sem bordas visíveis:**

Os `.d-item` têm `border: 1px solid transparent`. A borda existe no DOM (evita layout shift), mas é invisível.

---

### 2.5 JavaScript: estrutura do código

**IIFE obrigatório:**
```js
(function() {
  'use strict';
  // Todo o código aqui dentro
})();
```
Motivo: Isola completamente todas as variáveis do escopo global da página. Previne colisões com APIs do navegador ou scripts injetados.

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
Motivo: `SysLogger` respeita `TOKEN_DEBUG_MODE`. Em exports de User, os logs desaparecem automaticamente.

**API do `SysLogger`:**

| Método | Quando escreve no console | Cor no console |
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
O IIFE isola o escopo — funções chamadas por atributos HTML inline (`onclick="..."`) precisam estar em `window`.

---

## 3. Unicidade de nomes — prevenção de colisões no ZIP

**O problema:** Nomes duplicados num ZIP causam comportamento imprevisível no Windows Explorer, macOS Archive Utility, e outros descompressores.

### Mecanismo de identificadores (genId)
Para evitar colisões na base de dados, a função `genId(prefix)` é utilizada na criação de novos itens. Ela gera uma string única com **3 partes** separadas por `_`:

```
{prefix}_{Date.now()}_{5_chars_base36}
```

Exemplo real: `img_1748611200000_a3f7k`

- `prefix` — tipo do objeto (`img`, `doc`, `sess`)
- `Date.now()` — timestamp em milissegundos (13 dígitos) — garante ordenação cronológica e unicidade temporal
- `Math.random().toString(36).slice(2,7)` — 5 caracteres em base-36 — entropia adicional contra colisões no mesmo milissegundo

A probabilidade de colisão numa mesma sessão local (Single Page App no IndexedDB) é desprezível.

**O algoritmo de incremento inteligente:**

1. Nome inicial: `imagem-1` ou `texto-1.txt`
2. Se já existe, decompor o sufixo `-N`: `imagem-1` → extrair `1`
3. Incrementar: `imagem-2`, `imagem-3`, etc.
4. **Nunca** criar `imagem-1-1` — sempre incrementar o número existente

```
imagem-1 → imagem-2 → imagem-3   ✅
imagem-1 → imagem-1-1            ❌
```

**Verificação cross-list obrigatória:** A unicidade verifica-se contra *ambas* as listas simultaneamente — itens ativos **e** itens nos «Removidos». Um item restaurado dos «Removidos» nunca colide com um ativo.

**Extensão de arquivo:** Ao renomear um documento, a extensão original é sempre preservada. Se o usuário escrever `relatorio` (sem extensão) num documento `.pdf`, o nome final é `relatorio.pdf`.

**Comparação case-insensitive:** Toda a deduplicação usa `.toLowerCase()` para evitar colisões entre `Imagem-1.png` e `imagem-1.png` no Windows (que é case-insensitive).

### 3.1 Nomes de sessões sem título

Sessões sem nome digitado recebem um identificador cronológico com zeros à esquerda: `#0001`, `#0002`, etc. O número é a **posição da sessão entre as que existem no momento**, ordenadas por `createdAt` (`sortedOldest.findIndex(...) + 1`) — não há contador persistido. Consequência: apagar ou purgar uma sessão mais antiga **renumera** as seguintes, por isso o identificador não é estável ao longo do tempo. Não usar como referência externa. (Até a V26 este parágrafo dizia «ordem de criação absoluta», o que sugeria estabilidade que o código não dá.)

---

## 4. Ciclo de vida da sessão

Este é o comportamento mais complexo do motor. Qualquer agente que edite código relacionado com sessões deve compreender este fluxo completamente.

### O modelo mental

Pense nas sessões como documentos num processador de texto:
- **Sessão ativa** = o documento aberto agora
- **Histórico** = outros documentos salvos
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
| **Primeira interação** | `ensureSession()` confirma e registra a sessão; `renderSbSessions()` faz-a aparecer no histórico. |
| **Digitar em User/Equipamento/Nome** | `isDirty=true` → `triggerSave()` **imediato** (não aguarda os 5 segundos). |
| **Apagar sessão NÃO ativa** | Apenas `renderSbSessions()`. A sessão ativa e o DOM ficam intactos. |
| **Apagar sessão ATIVA com vizinha** | Capturar `neighbor` *antes* da deleção: `allBefore[idx+1] \|\| allBefore[idx-1]`. Após deleção: `loadSession(neighbor.id)` + `renderSbSessions()`. |
| **Apagar sessão ATIVA sem vizinha** | Reset completo: `sessId=null`, `sessObj=null`, arrays zerados, DOM limpo, campos zerados. **Não criar nova sessão.** |
| **`createSession()` diretamente** | Apenas em `ensureSession()`. Nunca chamar em `deleteSessionId()` ou handlers de evento. |

> **Por que nunca criar sessão em `deleteSessionId`?** Porque o usuário que apaga a última sessão decide ter uma interface vazia. Criar uma sessão automática seria ignorar a intenção do usuário — e causaria um loop onde apagar sempre gerava uma sessão nova no histórico.

### isDirty: o flag de alterações pendentes

`isDirty` é um boolean que indica se há dados não salvos. É `true` sempre que algo muda (captura de imagem, edição de legenda, reordenação). O auto-save de 5 segundos só roda quando `isDirty === true`. Após salvar, `isDirty` volta a `false`.

Digitação em campos de texto chama `triggerSave()` imediatamente (sem esperar os 5 segundos), para garantir que até os primeiros caracteres são persistidos imediatamente.

---

## 5. Comment markers — blocos de código removíveis

Os markers são comentários especiais que o Quine Engine usa para identificar e remover blocos inteiros no export de User.

| Marker | Conteúdo que protege | Removido em Export User? |
|---|---|---|
| `<!-- ADMIN_BUTTONS_START -->` ... `<!-- ADMIN_BUTTONS_END -->` | Botões ⚙️ e 💾 na barra de topo | ✅ Sim |
| `<!-- ADMIN_EDIT_START -->` ... `<!-- ADMIN_EDIT_END -->` | Modal do Visual Builder completo | ✅ Sim |
| `/* ADMIN_JS_START */` ... `/* ADMIN_JS_END */` | Funções `capturePristine()`, `exportFile()`, `sanitizeForQuine()` | ✅ Sim |
| `<!-- EXPORT MODAL -->` ... `<!-- FIM EXPORT MODAL -->` | Modal de escolha Admin/User export | ✅ Sim |

**Regra crítica:** Nunca mover código para dentro ou fora destes blocos sem entender as consequências. Código dentro de `ADMIN_JS_START/END` desaparece nos exports de User — se a funcionalidade for necessária para usuários normais, não pode estar nesse bloco.

**Proteção do Quine:** `sanitizeForQuine()` substitui os marcadores nos *valores de tokens* com versões contendo zero-width space (caractere invisível `\u200B`). Isto evita que um token com o texto `ADMIN_JS_START` corrompa o regex de strip. Aplica-se a todos os 8 marcadores (4 pares de abertura e fechamento).

**Localização dos markers no arquivo** (diagnóstico manual sem `validate.sh`):

| Marker | Localização | Contagem no grep |
|---|---|---|
| `<!-- ADMIN_BUTTONS_START -->` / `END` | `<body>` — barra de topo | 2 |
| `<!-- ADMIN_EDIT_START -->` / `END` | `<body>` — modal Visual Builder | 2 |
| `/* ADMIN_JS_START */` / `END` | `<script>` IIFE — bloco de funções admin | 2 |
| `<!-- EXPORT MODAL -->` / `<!-- FIM EXPORT MODAL -->` | `<body>` — modal de export | 2 |
| 3 ocorrências em funções JS | `boot()`, `sanitizeForQuine()`, `exportFile()` | 3 |
| **Total** | | **11** |

> Verificação rápida sem `validate.sh`: procure cada um dos 8 textos acima no HTML com Ctrl+F. Se algum estiver ausente ou duplicado, o Quine está corrompido.

> **Nota sobre contagens — 8 vs 11:** existem **8 strings únicas de marcadores**, em 4 pares: ADMIN_BUTTONS, ADMIN_EDIT, ADMIN_JS e EXPORT MODAL. O `grep -c` no HTML retorna **11 linhas**, porque os marcadores aparecem em 3 categorias de locais:
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

## 6. IndexedDB — schema completo

**Nome da base de dados:** `CaptureEngineDB`

> **Escopo de armazenamento (origem):** o IndexedDB é particionado por **origem** = protocolo + host + porta. A mesma `CaptureEngineDB` aberta via `file://`, `http://localhost:8080` e `https://<user>.github.io` são **três bases distintas e isoladas** — sem compartilhamento entre elas, mesmo no mesmo perfil de navegador. Dentro de `file://`, o caminho do arquivo não altera a origem (mesma base). Decorre disto que distribuir a ferramenta hospedada vs como arquivo local resulta em históricos separados.
**Versão do schema:** `2`

> **Nota de migração de schema:** O `onupgradeneeded` atual usa `if (!db.objectStoreNames.contains(...))` — padrão aditivo seguro. Adicionar uma nova object store em V25+ é seguro sem migração destrutiva. Porém, **alterar campos de uma store existente** (ex: adicionar campo obrigatório a `images`) **não é seguro** com a lógica atual: o `onupgradeneeded` não executa para usuários já na versão 2. Qualquer alteração de schema existente requer incrementar a versão da base (`indexedDB.open('CaptureEngineDB', 3)`) e implementar lógica de migração explícita dentro de `onupgradeneeded`.

#### Como migrar o schema em segurança

**Caso A — Adicionar uma nova object store (seguro, sem migração destrutiva)**

Incrementar a versão e adicionar a store com `contains` guard — usuários existentes passam pelo `onupgradeneeded` e recebem a nova store; stores existentes e dados não são tocados:

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

Por exemplo, adicionar o campo `tags` à store `images`. Os registros existentes não têm `tags` — é necessário iterar e reescrever:

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
        record.tags = []; // valor padrão para registros existentes
        imgStore.put(record);
      }
    }
  };
};
```

> **Regras críticas de migração:**
> - Usar **sempre** `e.target.transaction` (a transação de upgrade) — não abrir transações novas dentro de `onupgradeneeded`
> - O `onupgradeneeded` é **atômico**: se alguma operação falhar, a base reverte para a versão anterior
> - Após a migração, incrementar também o comentário de versão no código: `// CaptureEngineDB versão 3`
> - **Testar com uma cópia de segurança dos dados** antes de distribuir — uma migração errada que seja distribuída aos usuários é irreversível

### Tabela: `sessions`

Índices: `createdAt`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | ✅ | ID único gerado por `genId('sess')` — chave primária |
| `name` | string | ❌ | Nome da sessão derivado de `session-user` + `session-pc` (maiúsculas, separados por `-`, via initSessionSync). Ambos vazios = usa fallback #XXXX |
| `user` | string | ❌ | Valor do primeiro campo (ex: "João Silva") |
| `pc` | string | ❌ | Valor do segundo campo (ex: "PC-001") |
| `createdAt` | number | ✅ | Timestamp Unix (ms) da criação — imutável após criação |
| `updatedAt` | number | ✅ | Timestamp Unix (ms) da última atividade — atualizado a cada save |

### Tabela: `images`

Índices: `sessionId`, `order`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | ✅ | ID único gerado por `genId('img')` — chave primária |
| `sessionId` | string | ✅ | ID da sessão a que pertence |
| `blob` | Blob | ✅ | Dados binários da imagem (PNG, JPEG, WEBP, GIF) |
| `label` | string | ✅ | Nome/legenda da imagem (ex: `imagem-1`) — único dentro da sessão |
| `order` | number | ✅ | Posição na grade — define a ordem de exibição e export. **Único, mas não necessariamente contíguo.** Novos valores vêm de `nextOrder(arr)` = `max(order)+1`, nunca de `arr.length`: `delImg`/`delDoc` não renumeram os restantes, por isso o `length` colidiria com um `order` existente (ver D45). As lacunas são normais e desaparecem no primeiro reordenamento, que renumera densamente |
| `addedAt` | number | ✅ | Timestamp Unix (ms) de quando foi capturada |
| `origBlob` | Blob | ❌ | Imagem **original** antes da anotação. Criada por `ann-save` na primeira vez que se confirma uma anotação; usada por `annActivate` como fundo do canvas ao reeditar. Removida (e `blob` reposto ao original) se todas as anotações forem apagadas **e não houver redo pendente** (`annRedoStack` vazio). Presente apenas em imagens anotadas. |
| `annHistory` | array | ❌ | Stack de formas anotadas (`{type, x1, y1, ...}`; um traço do marca-texto é `{type: 'free', hl: 'soft' \| 'solid', pts, ...}`) persistida com a imagem para reedição posterior (anotação **não-destrutiva**). Presente apenas em imagens anotadas; removida quando fica vazia. |
| `annRedoStack` | array | ❌ | Pilha de **refazer** persistida: snapshots `{h, rot, crop, pcrop}` (até `ANN_HISTORY_MAX` = 50) para que o redo sobreviva a salvar+reabrir. Restaurada por `annActivate`, gravada por `ann-save`. Invalidada (gravada vazia) por qualquer nova mutação via `annCommitUndo`. Presente apenas em imagens anotadas com redo pendente. **Limitação:** redo que atravessa rotação/crop é aproximado — a semeadura do undo achata `rot`/`crop`. |
| `rotation` | number | ❌ | Rotação acumulada em graus (`0`, `90`, `180`, `270`). Aplicada ao bitmap de exibição mas não ao `origBlob` — o original permanece intacto. Removida se igual a `0` e sem outras modificações. |
| `cropBox` | object | ❌ | Área de recorte ativa: `{x, y, w, h}` em pixels relativos ao `origBlob`. Não-destrutivo — o `origBlob` nunca é cortado. Removido se o crop cobrir a imagem inteira. |

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
| `removedAt` | number | Timestamp Unix (ms) de quando foi movido para os «Removidos» |

**Nota:** a barra «Removidos» **ordena por `removedAt`**, não por `order`. O campo `order` continua presente nos registros movidos para os «Removidos» — `delImg`/`delDoc` fazem `splice` do array e acrescentam `removedAt`, sem apagar o `order` anterior. Até a V26 esta nota dizia que os itens «não têm» o campo; têm, apenas não é usado para os ordenar. O valor antigo é ignorado na restauração, que atribui uma ordem nova.

### Chaves do localStorage

O sistema utiliza localStorage para preferências que devem sobreviver a diferentes abas ou arquivos na mesma origem:
- `theme`: Controla o modo visual. Valores possíveis: `'dark'`, `'light'` ou `null` (neste caso cai para a preferência do OS).
- `hl-solid`: a escolha do marca-texto. `'1'` é «Sólido»; `'0'` ou `null` é «Translúcido», o padrão (D-0095).
- `fill-rect` e `fill-circle`: a escolha do retângulo e do círculo. `'1'` é «Preenchido»; `'0'` ou `null` é «Contorno», o padrão (D-0102).
- *Histórico:* A chave `ec_pending_session` foi utilizada em versões antigas e removida na V17.
Limpar o localStorage apenas reseta preferências visuais. Limpar o IndexedDB apaga os dados reais das sessões.

### Auto-save e purge

**Auto-save e Falhas Assíncronas:** `setInterval` de 5 segundos no `boot()` chama `saveSession()` se `isDirty === true`. A função `triggerSave()` é chamada na digitação. Se o navegador for fechado durante a janela de latência ou a transação falhar, as últimas mutações perdem-se.

**Esgotamento de Quota:** Se o limite de disco do navegador for atingido, a gravação de novos blobs falha nativamente. `idbTx` e `idbDelBatch` inspecionam o erro da transação e também o erro que o `put` ou o `delete` lança na hora. Num `QuotaExceededError`, e só nele, chamam `showQuotaBanner()`, que injeta um aviso vermelho fixo no topo (`id="ce-quota-banner"`, camada `--z-toast`). O aviso é criado em runtime e **não** está no HTML estático. Diz que as capturas deixaram de ser gravadas e recomenda exportar já. Tem um botão ✕, e volta na falha seguinte, porque a guarda testa se o elemento existe. `SysLogger.error` registra a exceção no console em qualquer caso. A sessão já salva e os itens antigos permanecem íntegros no DB.

> **Correção histórica:** até a V26 esta seção afirmava que «a aplicação falha silenciosamente na interface para não causar pânico de UX». Era falso e contradizia o README. O banner existe desde a correção D9 (commit `a5656f5`).

**Purge:** `purgeExpired()` é chamada uma vez por `init()` (carregamento da página). Sessões fora do prazo de 48h (ou o valor de `TOKEN_AUTO_PURGE_HOURS`) só são removidas na próxima inicialização. Abas mantidas abertas por dias sem recarregar não ativam o purge — a quota do IndexedDB pode esgotar antes da próxima inicialização. Apaga também todos os itens associados (imagens, documentos, removidos das duas categorias).

> **Risco de redistribuição:** Se redistribuir com um valor de `TOKEN_AUTO_PURGE_HOURS` menor do que o anterior (ex: de 48h para 24h), sessões que antes sobreviveriam são purgadas na próxima abertura. O comportamento é correto (o código usa sempre o valor atual do token), mas pode surpreender usuários com sessões em curso. Comunicar a mudança antes de redistribuir.

**Múltiplas instâncias (multi-aba permitido):** O `onblocked` apenas registra um aviso no console — **não** bloqueia a interface. Em versões anteriores mostrava uma tela de erro vermelha que substituía o `body`; esse bloqueio foi removido na V23 (a pedido do proprietário). Várias abas compartilham a mesma base `CaptureEngineDB`; a ressalva conhecida é a gravação concorrente na mesma sessão (a última gravação prevalece). Ver o README §8, «Comportamento com múltiplas abas».

---

## 7. Funções críticas — referência rápida

Esta seção documenta as funções mais importantes. Consultar antes de editar qualquer uma delas.

### Funções de sessão

| Função | Assinatura | O que faz | Quando chamar |
|---|---|---|---|
| `createSession()` | `async () → void` | Cria sessão nova em branco e atualiza `sessId`/`sessObj` | Apenas em `ensureSession()` |
| `ensureSession()` | `async () → void` | Confirma sessão se não existe; usa mutex `_ensurePromise` | Antes de qualquer captura (chamada por `captureImg`/`captureDoc`) |
| `loadSession(id)` | `async (string) → void` | Carrega sessão do IndexedDB para memória e renderiza | Ao navegar para sessão existente |
| `saveSession()` | `async () → void` | Persiste sessão atual no IndexedDB | Pelo auto-save e `triggerSave()` |
| `triggerSave()` | `async () → void` | Chama `saveSession()` se `isDirty`, reseta flag | Em digitação e após capturas |
| `deleteSessionId(id)` | `async (string) → void` | Apaga sessão e todos os seus items; navega ou reset | No botão ✕ da sidebar |
| `renderSbSessions()` | `async () → void` | Re-renderiza a lista de sessões na sidebar. A lista só é montada quando a barra abre: numa página recém-carregada, `#sb-sess-list` fica vazio no DOM mesmo com sessões no banco (um teste automático precisa abrir a barra antes de contar) | Após qualquer alteração de sessão |

### Funções do IndexedDB

| Função | Assinatura | O que faz | Quando chamar |
|---|---|---|---|
| `idbTx(store, mode, fn)` | `(string, string, Function) → Promise` | Wrapper transacional para IndexedDB com gestão de erro e fallback. `fn` recebe o `objectStore` e deve retornar um `IDBRequest` (ex: `st => st.get(id)`). | Base para todas as leituras e escritas |

**Atalhos sobre `idbTx` (usar em vez de `idbTx` diretamente):**

| Função | Assinatura | O que faz |
|---|---|---|
| `idbPut(store, data)` | `(string, object) → Promise` | Insere ou substitui um registro (upsert). `data` deve conter a chave primária. |
| `idbGet(store, id)` | `(string, any) → Promise<object>` | Lê um registro pela chave primária. Retorna `undefined` se não existir. |
| `idbAll(store)` | `(string) → Promise<array>` | Retorna todos os registros da store como array. |
| `idbDel(store, id)` | `(string, any) → Promise` | Apaga o registro com a chave primária dada. |
| `idbDelBatch(store, ids)` | `(string, string[]) → Promise` | Apaga múltiplos registros da store `store` em **uma única transação** `readwrite`. Mais eficiente que N chamadas a `idbDel` em loop. Usa `tx.oncomplete` em vez de `r.onsuccess`. |
| `idbIdx(store, idx, val)` | `(string, string, any) → Promise<array>` | Retorna todos os registros onde o índice `idx` é igual a `val`. Ex: `idbIdx('images', 'sessionId', sessId)`. |

### Teclado e camadas

| Função | O que faz |
|---|---|
| `initCollapsedBars()` | Com o Histórico ou os «Removidos» recolhidos, o conteúdo fica `inert`, e o Tab passa só pelas setas (F-0064) |
| `initModalLayers()` | Pilha de modais: tudo fora do modal de cima fica `inert`, e o foco volta à origem ao fechar (F-0065) |
| `initKeyClick()` | Enter e Espaço num `role="button"`, `"tab"` ou `"radio"` que não é botão nativo fazem o clique dele (F-0066) |
| `initChips()` | Cada chip vira uma parada do Tab, com `role="radio"` e `aria-checked` |
| `keepInTab(o, e)` | Uma captura que o navegador não grava fica na aba, com o aviso «Capturas só nesta aba» uma vez por página (F-0063) |

### Funções de captura

| Função | Assinatura | O que faz |
|---|---|---|
| `captureFile(f)` | `async (File) → void` | Porta de entrada de todo arquivo (botões, arrastar e colar). Uma imagem que o navegador desenha vai para `captureImg`; o resto, incluindo HEIC, TIFF e RAW, vai para `captureDoc`, com o nome e os bytes originais, e um aviso |
| `canDrawImage(blob)` | `(Blob) → Promise<boolean>` | Abre a imagem e desenha-a num canvas de 1 × 1 px. É o mesmo caminho do `imgToJPEG` do PDF: o que passa aqui entra no PDF |
| `moveUndrawableToDocs()` | `async () → number` | Antes do PDF e do ZIP, passa para «Documentos» as imagens que o navegador não desenha (sessões gravadas antes do `captureFile`). A extensão vem do tipo ou dos primeiros bytes (`sniffExt`) |
| `holdSuccess(reset)` | `(Function) → void` | Mantém o verde «Concluído» do botão PDF ou ZIP até a próxima interação na página (`pointerdown`, `keydown`, `paste`, `drop`). Teclas sozinhas de modificador (Alt, Ctrl, Shift, Tab) não contam, porque o Alt + Tab para trocar de janela as envia |
| `initTips()` | `() → void` | Tooltip padrão de toda a aplicação: o texto do `title` passa a `data-tip`, e um balão aparece logo por cima do elemento (por baixo, perto do topo da tela) enquanto o mouse ou o foco do teclado estiverem nele. Um `title` que o código muda depois passa a `data-tip` no hover seguinte. Só com ícone, o texto vai também para `aria-label`; com texto, para `aria-description`. O balão segue o contraste da tela, e é branco por cima do visualizador. O toque não mostra tooltip. O primeiro balão espera 500 ms com o mouse parado; com um balão visível há menos de 500 ms, o seguinte aparece na hora, e pelo teclado também. O balão só aparece onde não há nome visível (no máximo uma letra no texto: ✕, B, I, 90°); onde há uma palavra, o `title` vai só para o leitor de tela. Um elemento novo com tooltip usa só o atributo `title` |
| `showNotice(msg)` | `(string) → void` | Aviso no fundo da tela (`role="status"`), que some em 8 s ou com um clique |
| `captureImg(blob)` | `async (Blob) → void` | Captura imagem: gera rótulo único, salva em IndexedDB, renderiza thumb |
| `captureDoc(blob, name, type)` | `async (Blob, string, string) → void` | Captura documento: gera nome único, salva em IndexedDB, renderiza card |

### Funções de renderização

| Função | Assinatura | O que faz |
|---|---|---|
| `renderThumb(o)` | `(object) → void` | Cria e insere card de imagem na grade |
| `renderDoc(o)` | `(object) → void` | Cria e insere card de documento na lista |
| `renderTrash()` | `() → void` | Re-renderiza a barra «Removidos» com os itens atuais |
| `updateCounters()` | `() → void` | Atualiza badges de contagem (imagens, documentos, «Removidos») |
| `scheduleUIUpdate()` | `() → void` | Debounce de 50ms que consolida `renderTrash()`, `updateCounters()`, `updateBtns()` e `triggerSave()` numa única execução. Chamada por `delImg`/`delDoc` em vez de chamar cada função diretamente — evita N rebuilds do DOM em deleções múltiplas rápidas. |
| `updateBtns()` | `() → void` | Atualiza estado dos botões PDF/ZIP. **Lógica:** `btn-pdf.disabled = (!hi \| hd)` — PDF desativado quando não há imagens **OU** quando há documentos (intencional: PDF é exclusivo de imagens). `btn-zip.disabled = !(hi \| hd)`. |
| `updateBtnTitles()` | `() → void` | Atualiza o `aria-description` dos botões PDF e ZIP com o nome de arquivo que será gerado (ex.: `Exportar: 13h29m-16-ago-2026.pdf`). Os dois botões não têm `title` desde a 28.5.0. Chama `buildFilename()` internamente. Chamar após qualquer alteração ao nome da sessão ou ao modo PDF/ZIP. Retorna imediatamente sem fazer nada se `zipModeActive` for `true`. |
| `updateStatusBar()` | `() → void` | Atualiza a barra de estado com o timestamp do último auto-save (`lastSaveAt`). Chamada pelo auto-save de 5 segundos e diretamente em `boot()` para estado inicial. |
| `applyTokens()` | `() → void` | Lê todos os `TOKEN_*` declarados no JS, aplica-os ao DOM e às variáveis CSS (`--color-primary`, `--title-*-color`, etc.) e inicializa `sysColors`. Também substitui `{YEAR}` no rodapé. Chamada uma vez em `boot()` e novamente pelo `initVbSync` a cada alteração no Visual Builder. **Não chamar antes de `boot()`** — o DOM não está pronto. Os campos do Visual Builder são preenchidos por `vbFillColorsAndTitle` e `vbFillSessionFields`, só quando existem: o Export User não os tem. |
| `initVbSync()` | `() → void` | Registra todos os listeners de `input` do Visual Builder e sincroniza as alterações em tempo real na interface (cor, título, rodapé, rótulos, toggles). Chamada uma vez em `boot()`. Cada listener chama `applyTokens()` ou a função de atualização correspondente. **Não duplicar listeners** — chamar apenas uma vez. |
| `buildFilename(ext)` | `(string) → string` | Gera o nome de arquivo para PDF ou ZIP com base no nome da sessão atual e no timestamp do momento. Sanitiza o nome (remove acentos, caracteres especiais, converte para maiúsculas com hífens). Formato: `NOME-HHhMMm-DD-mon-YYYY.ext`. **Sem nome de sessão, o prefixo é omitido junto com o seu hífen** — o nome fica só com o timestamp (`13h29m-16-ago-2026.zip`), nunca com um hífen inicial órfão. O mesmo acontece se a sanitização esvaziar o nome (ex.: título só com pontuação). Usada por `updateBtnTitles()`. |

> **Nota (round-trip de purge/max-dim):** `applyTokens` marca o radio do Visual Builder cujo `value` corresponde ao token. Se o token tiver um valor sem radio correspondente (ex.: `TOKEN_AUTO_PURGE_HOURS=8760`), nenhum radio é marcado, e fica o default: `48` para purge e `0` para max-dim. O reexport usa esse default, e não o valor do token. Por design, os valores suportados são os dos radios. Não recomendar valores fora dos radios na documentação de usuário.

### Funções do modal de imagem

| Função | O que faz | Notas |
|---|---|---|
| `openImgModal(id, trash)` | Abre o modal para a imagem `id`; inicializa título, zoom, botões de ação e setas de navegação (visíveis se array ≥ 2) | Chamada pelas miniaturas e pela barra «Removidos» |
| `closeImgModal()` | Fecha o modal; bloqueia se há anotações por salvar | |
| `imgModalNav(dir)` | Navega ±1 na lista dentro do modal aberto; bloqueia se há anotações por salvar | `dir = -1` (anterior) ou `+1` (seguinte). Chamada pelas setas ← → e pelas teclas ArrowLeft / ArrowRight |

### Funções do Quine

| Função | O que faz | Quando chamar |
|---|---|---|
| `capturePristine()` | Lê o código-fonte original via `fetch` ou `BOOT_HTML` e guarda em `PRISTINE_HTML` | **Uma vez, em `boot()`** — não em `exportFile()`, que apenas *lê* `PRISTINE_HTML` e aborta com `SysLogger.error` se ainda for `null`. (Até a V26 esta linha dizia «Apenas em `exportFile()`»; o diagrama do `README §15` sempre esteve certo.) |
| `exportFile(isUser)` | Gera e faz download do arquivo exportado | No botão Export Admin (`false`) ou Export User (`true`) |
| `sanitizeForQuine(str)` | Substitui marcadores Quine com zero-width space para proteger tokens | Antes de injetar valores de tokens no HTML exportado |

**`buildFilename(ext, baseName?)`** — O parâmetro opcional `baseName` permite sobrepor o nome base. Quando não fornecido, usa `$('session-name').value` (comportamento original para PDF/ZIP). O export Admin/User (Quine) passa o título da app (`TOKEN_TITLE_START + TOKEN_TITLE_ACCENT + TOKEN_TITLE_END`) como `baseName`, seguido do perfil (`ADMIN` ou `USER`). O resultado é um nome como `CAPTURE-ENGINE-ADMIN-14h22m-11-jun-2026.html`, e não um nome derivado da sessão. O perfil no nome evita distribuir a cópia do administrador por engano (F-0069).

### Funções dos motores PDF e ZIP

Ambos geram os arquivos **em JavaScript puro, sem bibliotecas** (contrato zero-dependência) — escrevem os bytes do formato à mão. Compartilham os helpers `ENC` (`TextEncoder`), `dlBlob(blob, filename)` (cria Object URL, dispara o download e revoga ao fim de 1 s) e `buildFilename(ext)`.

**PDF** (bloco `/* PDF ENGINE (JPEG COMPRESSED) */`):

| Função | O que faz | Notas |
|---|---|---|
| `generatePDF(returnBlob=false)` | Constrói um PDF 1.4 com **uma imagem por página**. Por imagem: converte para JPEG (`imgToJPEG`) e cria um XObject `/Image` com `/Filter /DCTDecode`, com os bytes JPEG sem reprocessamento. Cria também uma `/Page` e um content stream que escala a imagem para caber na página, centrada e com a proporção mantida. Monta Catalog (obj 1), Pages (obj 2), a tabela `xref`, o `trailer` e `%%EOF`. A escrita do arquivo fica em `buildPdfBlob`, e o lugar da imagem na página em `pdfPagePlacement`. | Página A4 = `595.28 × 841.89` pt. Formato lido de `pdfFmt`: `auto` (paisagem se largura ≥ altura, senão retrato), `a4v` (retrato), `a4h` (paisagem). `returnBlob=true` devolve o `Blob` (usado pela opção ZIP "Imagens em PDF"); senão faz download. Desativado quando há documentos na sessão (ver `updateBtns`).<br><br>**Nota sobre texto e fontes:** O motor PDF empacota exclusivamente as imagens geradas. Não existem instruções de texto (como `/Font` ou `/BT`) no PDF e nenhuma fonte é incorporada. Anotações e todo o conteúdo visual estão rasterizados nas imagens JPEG — não há camada de texto separada nem conteúdo pesquisável no arquivo PDF. |
| `imgToJPEG(blob, quality)` | Carrega a imagem, redimensiona se exceder `TOKEN_MAX_IMG_DIMENSION` (mantém proporção), desenha num canvas e devolve `canvas.toBlob('image/jpeg', quality)`. | `quality` = `TOKEN_JPEG_QUALITY`. Os originais ficam na sessão no formato capturado; a conversão para JPEG é só para o PDF. |
| `getJPEGDims(u8)` | Lê o marcador SOF do JPEG para extrair largura/altura reais (usadas no `MediaBox`/escala). | Fallback `800 × 600` se não encontrar o marcador. |

**ZIP** (bloco `/* ZIP ENGINE */`):

| Função | O que faz | Notas |
|---|---|---|
| `generateZIP(usePdf=false)` | Reúne os arquivos da sessão e chama `buildZIP`. Com `usePdf=true` e imagens presentes, gera **um** PDF (`generatePDF(true)`) como `Imagens.pdf`; senão adiciona cada imagem a partir de **`img.blob`** (extensão por MIME). **Nunca lê `origBlob`.** Numa imagem anotada, girada ou recortada, o `img.blob` é o PNG regenerado pelo `ann-save`. O original fica em `origBlob` e não se exporta por nenhuma via. É intencional, porque as edições devem acompanhar a exportação; a limitação está no `README §6.7` e em «Uso como prova» (§9). Adiciona os documentos com o nome sanitizado (remove travessias de path `../`, `..\`). Nomes deduplicados por `dedupeZipName`. | Corresponde às duas opções do modo ZIP: "Imagens em PDF" e "Imagens separadas" (ver `handleZipClick`). |
| `buildZIP(files)` | Escreve um ZIP à mão pelo método **STORE (`0` — sem compressão)**: por arquivo, um *local file header* (`PK\x03\x04`) seguido dos dados; depois o *central directory* (`PK\x01\x02`) e o *EOCD* (`PK\x05\x06`). CRC32 por tabela própria; data/hora em formato DOS. | Sem `deflate` — empacota sem recomprimir (PNG/GIF entram intactos). Devolve `Blob` `application/zip`.<br><br>**Codificação dos nomes (não alterar sem ler isto):** os nomes são escritos em UTF-8 por `ENC.encode()`. O **bit 11 (`0x0800`) do *general purpose bit flag*** declara-o, nos **dois** cabeçalhos (APPNOTE.TXT §4.4.4). Os dois andam sempre juntos. Com o bit a `0`, o descompressor lê os bytes como CP437/ANSI, e um nome com acentos sai ilegível (`Diagnóstico` → `Diagn+¦stico`). O `validate.sh` check #26 protege esta invariante. Ver D21. |

### Motor de reordenação (`initReorder`)

O arrastar e soltar da reordenação foi reescrito na V23 com Pointer Events e animações FLIP. O FLIP (*First-Last-Invert-Play*) mede a posição inicial e a final, aplica a diferença como `transform` e anima-a até zero. Documentado aqui porque é o código mais complexo da versão e não é inferível sem leitura direta do changelog.

**Constantes e parâmetros:**

| Constante / Parâmetro | Valor | Descrição |
|---|---|---|
| `DRAG_THRESHOLD` | `6` px | Deslocamento mínimo desde o `pointerdown` para ativar o arrasto. Abaixo deste valor, o gesto é tratado como clique simples e abre o item normalmente. // calibrado empiricamente — não alterar sem validação manual |
| `LONG_PRESS_DELAY` | `500` ms | Tempo de pressão contínua necessário para ativar o arrasto em dispositivos touch (`pointerType === 'touch'`). Abaixo deste tempo, o gesto é tratado como toque/scroll nativo. Em mouse, o arrasto ativa imediatamente (sem espera). // calibrado empiricamente — não alterar sem validação manual |
| Escala do item em arrasto | `0.75` | O card encolhe para 75% durante o arrasto — indica visualmente que é movido. |
| Histerese de reposicionamento | ~18% do tamanho do item | O placeholder só muda de posição quando o centro do item arrastado ultrapassa 18% do tamanho do item em relação ao centro do slot seguinte. Evita trocas involuntárias por movimentos mínimos. |
| Transição FLIP | `transform var(--duration-moderate-02) cubic-bezier(0.2, 0, 0, 1)` (240 ms) | Duração e easing da animação que move os cards vizinhos para abrir/fechar espaço. |

**Comportamento touch vs mouse:** Em dispositivos touch, `.t-item` e `.d-item` usam `touch-action: pan-y` (permite scroll vertical nativo). O arrasto só ativa após `LONG_PRESS_DELAY` ms sem movimento > `DRAG_THRESHOLD`. Movimento acima do threshold durante a espera cancela o timer e entrega o gesto ao navegador (scroll). Em mouse, `touch-action` não interfere e o drag ativa imediatamente ao ultrapassar `DRAG_THRESHOLD`.

**O que é o placeholder:** Um elemento DOM vazio (`.reorder-placeholder`) com fundo e borda muito sutis (configuráveis via `--color-drop-placeholder` / `--color-drop-placeholder-border`) que ocupa o espaço-alvo durante o arrasto. A sua posição atualiza com base na histerese descrita acima.

**Fluxo do gesto (resumo):**
```
pointerdown (touch)  → iniciar timer LONG_PRESS_DELAY; aguardar
   │
   ├── movimento > DRAG_THRESHOLD antes do timer → cancelar; scroll nativo
   ├── pointerup antes do timer → cancelar; toque normal
   └── timer dispara (500ms) → ativar arrasto (igual ao fluxo mouse abaixo)

pointerdown (mouse)  → registrar posição inicial; aguardar movimento
   │
   ▼ (se deslocamento > DRAG_THRESHOLD)
ativar arrasto:
  - escalar item para 0.75
  - inserir placeholder na posição atual
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

**Algoritmo de geometria de repouso:** A posição final de cada item vem de `offsetLeft`, `offsetTop`, `offsetWidth` e `offsetHeight`. São as coordenadas reais do DOM depois do reflow, e não coordenadas guardadas em memória. Isto garante que o snap é sempre preciso independentemente de redimensionamentos ou scroll ocorridos durante o arrasto.

**Nota sobre o item `pointercancel`:** está registrado com o **mesmo handler** do `pointerup` (`onUp`) — não existe caminho de reversão separado. O comportamento depende de o arrasto ter chegado a ativar:
- **Gesto que nunca ativou** (`!wasActive` — abaixo do `DRAG_THRESHOLD`, ou long-press ainda em curso): sai por `return` antecipado, limpa o estado visual e **não persiste**. É este caso que protege os gestos de scroll em mobile que começam com um toque.
- **Arrasto já ativo:** segue o mesmo caminho do `pointerup` — encaixa o item na posição do placeholder e **persiste a nova ordem** com `idbPut`. Um `pointercancel` no meio de um arrasto ativo confirma a reordenação, não a desfaz.

---

### Funções de anotação

| Função | O que faz | Notas |
|---|---|---|
| `annActivate()` | Ativa o modo de anotação: carrega `origBlob`, inicializa canvas, mostra a barra de ferramentas; oculta `#img-nav-prev` e `#img-nav-next` | Chamada pelo botão "Editar" (id `ann-toggle`) |
| `annDeactivate()` | Desativa anotação: esconde canvas e barra de ferramentas, cancela timers pendentes, restaura `o.blob`; restaura visibilidade das setas de navegação se o modal ainda está aberto | Cancela `annTextClickTimer` e `annCommitText` |
| `annSetTool(t)` | Define a ferramenta ativa: guarda e repõe o passo (`annSizeByTool`) e a cor (`annColorBy`) de cada ferramenta, fecha a bandeja de outra ferramenta e esquece o `annTempSelectFrom` | Atualiza `.active` nos botões. Para `t='crop'`: expande canvas para dimensões do `origBlob`, carrega `origBlob` com rotação aplicada via `getRotatedBlob` (usando `annCurrentRotation` viva), desloca coordenadas de todas as anotações +cx/+cy. Para saída do crop (`t!='crop'` com `annCropBox` ativo): reverte deslocamento -cx/-cy, restaura `o.blob`, encolhe canvas. A entrada e a saída ficam em `annEnterCrop` e `annLeaveCrop`; o deslocamento de todas as anotações, também das pilhas de desfazer e refazer, em `annShiftAll`. |
| `annRedraw()` | Limpa canvas e redesenha `annHistory` completo; salta `annEditingTextIdx` | Chamar após qualquer mutação de `annHistory` |
| `annDrawShape(ctx, h)` | Desenha uma forma do histórico no contexto fornecido. Para texto (`h.type==='text'`) desenha **linha a linha** (`String(h.txt).split('\n')`) com `lineH = fontSize × ANN_TEXT_LINE_RATIO` e `halfLeading = (lineH - fontSize)/2`; usa `ctx.textBaseline='top'` e repõe `'alphabetic'` no fim | Usado por `annRedraw` e pelo `ann-save` |
| `getRotatedBlob(blob, degrees)` | Gera um novo Blob com o bitmap girado `degrees` graus no sentido horário via `<canvas>`. Usado por `annActivate` (ao abrir imagem rodada), pela ferramenta Crop (para mostrar `origBlob` com rotação aplicada) e pelo restore de rotação em `annDoUndo`/`annDoRedo`. | |
| `annShowTextInput(x, y, prefill?)` | Posiciona e mostra o editor de texto (`#ann-text-input`, um `<textarea>` multilinha) no canvas, com B/I sync e `line-height = fontSize escalado × ANN_TEXT_LINE_RATIO`. **Enter insere nova linha**; a confirmação acontece no blur (clicar fora), ao clicar em outro ponto do canvas, e no botão Confirmar; `Escape` cancela. Chama `annAutosizeText()` ao abrir | `prefill` opcional para reedição via dblclick |
| `annAutosizeText()` | Faz o `<textarea>` de texto crescer em altura (`scrollHeight`) e largura (linha mais longa medida com `measureText` na fonte escalada, + 4px). Necessário porque `wrap="off"` não quebra linhas automaticamente | Chamada em `oninput`, ao abrir o editor (`annShowTextInput`) e após cada resize ao vivo pelos botões −/+ |
| `annCanvasXY(e)` | Converte coordenadas do evento para coordenadas do canvas (sem clamping) | Para posicionamento de texto |
| `annCanvasXYClamped(e)` | Converte + clamp aos limites do canvas | Para formas (evita saírem do canvas) |
| `annCR(ctx, pts, closed)` | Interpola e renderiza um desenho livre usando o algoritmo **Catmull-Rom** (spline cúbica). Recebe o contexto canvas (`ctx`), um array de pontos `[{x,y}]` (`pts`) e um booleano `closed`. Produz curvas suaves que passam exatamente por todos os pontos sem overshooting. Chamada em dois momentos: no preview em tempo real durante o `pointermove` (via `annPath`) e no salvamento final do traço via `annDrawShape`. **Não chamar diretamente** — usar `annDrawShape` ou `annRedraw`. |
| `rdp(pts, eps)` | Ramer-Douglas-Peucker — simplifica um path removendo pontos colineares | Inativa no fluxo de desenho desde a V23 (nunca chamada); a função órfã foi removida fisicamente do código na V25 (commit D3), por decisão do mantenedor. Se suavização de traço livre for necessária em versão futura, reimplementar em contexto com decisão documentada. |

### Motor de anotação: seleção, edição e desfazer

| Comportamento | Descrição e Invariantes |
|---|---|
| **Selecionar** | Ativa por padrão ao abrir imagem com anotações existentes (se vazia, ativa `free`). Permite clicar numa forma para selecioná-la. Exibe caixa de seleção sólida e fina (não mais tracejada) e botão apagar (✕). A seleção limpa ao confirmar ou trocar para texto. O ícone "T" fica na cor de destaque/accent (cor primária) quando a ferramenta texto está ativa **OU** quando há uma anotação de texto selecionada (através da classe `.ann-txt-selected`). |
| **Mover (Arrastar)** | A anotação selecionada pode ser movida arrastando-a (o arrasto começa no primeiro clique sobre a forma). A caixa acompanha em tempo real; o botão ✕ é oculto durante o arrasto e reaparece ao soltar. O **botão direito** e o **do meio** agarram e movem em qualquer ferramenta, sem desenhar e sem o menu de contexto nativo (ver «Botões direito e do meio»). |
| **Seta** | Uma seta selecionada não tem caixa: tem uma alça redonda em cada ponta (`'p1'` no início, `'p2'` na ponta), e cada alça move só a sua ponta. O ✕ fica ao lado do meio da seta, a 28 px das alças (`annArrowDelPoint`). |
| **Shift** | Ao desenhar e ao redimensionar: retângulo quadrado, elipse círculo, seta e traço livre em passos de 45° (`annShiftPoint`, D-0093). |
| **Marca-texto** | Um traço livre com o campo `hl` (`'soft'` ou `'solid'`), pontas retas e larguras de `ANN_HL_SIZES` (`annStrokeStyle`). As opções «Translúcido» e «Sólido» ficam acima da ferramenta (D-0102). |
| **Opções das ferramentas** | Cada ferramenta com opções fica num `.ann-tool-wrap`, com as opções num `.ann-flyout` acima dela. `annOpenFlyout` abre (duplo clique, 1 s apertado ou seta para cima), `annCloseFlyout` fecha (Esc, clique ou foco fora, troca de ferramenta; escolher uma opção não fecha). `annFill` guarda «Preenchido» do retângulo e do círculo, e a anotação ganha o campo `fill: true` (D-0102). Toda bandeja termina com `.ann-size-btn` (− e +, que chamam o `onclick` de `#ann-thickness-down` e `#ann-thickness-up`) e `.ann-size-val`, que `annSyncSizeVal` preenche: o tamanho da anotação selecionada ou o da ferramenta, um ponto por passo ou o número do texto. |
| **Botões direito e do meio** | Sobre uma anotação, em qualquer ferramenta menos o Recortar, selecionam-na, com as alças e o ✕, e já a arrastam. A barra passa ao Selecionar, e `annTempSelectFrom` guarda a ferramenta de antes; `annEndTempSelect` volta a ela num clique fora das anotações ou ao apagar a anotação (D-0103). No Recortar, só agarram e movem. |
| **Ctrl** | Com o Ctrl (Cmd no Mac) apertado, qualquer ferramenta funciona como o Selecionar; `annCtrlHeld` guarda o estado, `annQuasiSelect` acende o botão Selecionar enquanto ele dura, e `annCtrlUp` tira a seleção ao soltar a tecla (D-0101). `annHandleCursor` dá a cada alça o cursor do lado que ela puxa, girado com o texto. |
| **Redimensionar** | A caixa de seleção possui quatro alças pequenas e arredondadas nos cantos. Funcionam nas duas direções. Textos sofrem redimensionamento por escala contínua visual ao puxar pelas alças. |
| **Editar Propriedades** | Com anotação selecionada: os botões −/+ ajustam espessura (formas) ou tamanho da fonte (texto); no texto, a ferramenta Texto fica com o tamanho novo. A paleta de cores altera a cor da anotação selecionada. Níveis de espessura escalam agora em `[1, 2, 4, 6, 8, 12]`. |
| **Apagar** | O botão ✕ (reutiliza classe `.t-del`) ou a tecla `Delete` apagam a anotação selecionada. O ✕ e a caixa aparecem logo ao selecionar (sem precisar arrastar). |
| **Desfazer / Refazer** | **REESCRITO (Snapshot Model):** Utiliza duas pilhas de estado completas (`annUndoStack` e `annRedoStack`). `annHistory` é a fonte única da verdade. Toda mutação chama `annPushUndo()` (usa `annCommitUndo` + `annCloneState`) **ANTES** de alterar o `annHistory`. `annCommitUndo` ignora snapshots idênticos ao topo (deduplicação introduzida na D18). `annDoUndo` e `annDoRedo` são `async`. Detectam mudanças em `rot` e `crop` no snapshot. Se `rot` mudou, regeneram o bitmap base com `getRotatedBlob(origBlob, _prev.rot)` e atualizam `annCurrentRotation`. Se `crop` mudou, trocam a imagem base entre `o.blob` e `origBlob` e redimensionam o canvas. Se o snapshot tiver `pcrop`, restaura também a `o.cropBox` persistida. Nova ação limpa `annRedoStack`. Movimentos/redimensionamentos só geram histórico se houve mudança efetiva (via flags `annDragDirty` / `annResizeDirty`). O histórico de desfazer é por sessão e fica apenas em memória (reseta ao recarregar a página). Ao reentrar numa imagem salva, a pilha é semeada passo a passo para permitir desfazer as anotações existentes até o original. Teto de memória: `ANN_HISTORY_MAX = 50`. **Invariante Crítica:** NÃO reintroduzir o modelo antigo de pilha única com flags como `_isMoveUndo` (causava bugs graves de ordem temporal).<br><br>**Nota:** `setAnnDirty(true)` é chamado em todo caminho de mutação junto ao `annPushUndo()`, acionando o timer de auto-save. `annIsDirty`/`setAnnDirty` (controle de salvar e alertar ao fechar) e `annDragDirty`/`annResizeDirty` (flags efêmeros por gesto para o undo) são sistemas distintos que coexistem — um não substitui o outro. |

**Ferramenta «Girar 90°»**
Botão `ann-rotate-btn` na barra de ferramentas do editor. Cada clique roda a imagem 90° no
sentido horário: recalcula o bitmap via canvas temporário, atualiza
`annCurrentRotation = (annCurrentRotation + 90) % 360`, redimensiona o canvas
(largura e altura trocam), recalcula coordenadas de todas as anotações e
pilhas undo/redo com a matriz de rotação 90° e transforma também a caixa de corte ativa (`annCropBox`) e guardada (`o.cropBox`). Chama `annPushUndo()` antes da
rotação para permitir Ctrl+Z. Não-destrutivo: `origBlob` mantém a orientação
original.

**Ferramenta «Recortar»**
Ferramenta `annSetTool('crop')`. Comportamento:
- **Primeira ativação (sem cropBox salvo):** define `annCropBox = {0, 0, w, h}` abrangendo toda a imagem; mostra máscara escurecida (60%) fora da área selecionada; 4 alças em "L" nos cantos para ajuste.
- **Reativação (com cropBox salvo):** expande o canvas para as dimensões do `origBlob`, com a rotação aplicada, e desloca as coordenadas +cx/+cy. Mostra a área de crop anterior, para reajustar ou recuperar áreas cortadas.
- **Salvar (`ann-save`):** grava o novo `o.blob` combinando imagem + anotações (`annRenderSaved`), persiste `o.cropBox = {cX, cY, fW, fH}` no IDB, reverte coordenadas -cx/-cy (`annSaveCrop`), chama `annDeactivate()`.
- **`annCropBox`**: estado ativo do recorte em memória (`{x, y, w, h}`) durante a edição. Null fora do modo crop.
- **Invariante:** `origBlob` nunca é cortado. Todo recorte é reversível.

### Funções auxiliares do editor

| Função | O que faz |
|---|---|
| `annEndTempSelect()` | Sai do Selecionar aberto pelo botão direito ou do meio: tira a seleção e volta a `annTempSelectFrom`. Devolve `true` quando voltou (D-0103) |
| `annSizeStep(dir)` | Um passo do − (`-1`) ou do + (`1`), da barra ou de uma bandeja: a anotação selecionada primeiro, senão a ferramenta |
| `annTextStep(v, dir)` | O passo de `ANN_TEXT_SIZES` acima ou abaixo do tamanho `v`, mesmo fora dos passos (D-0105) |
| `annSyncSizeVal()` | Escreve o tamanho atual depois do − e do + de cada bandeja: um ponto, ou o número do texto |
| `annPress(id, on)` | Liga ou desliga `active` e `aria-pressed` de um botão de opção |
| `annSyncHlBtns()` | Acerta «Translúcido» e «Sólido» do marca-texto, e a ponta cheia no ícone da ferramenta |
| `annSyncFillBtns()` | Acerta «Contorno» e «Preenchido» do retângulo e do círculo, e o ícone cheio da ferramenta |
| `annSyncSwatches()` | Marca na paleta a cor de `annCurrentColor` |
| `annColorKey(t)` | `'hl'` para o marca-texto, `'line'` para as outras: a chave de `annColorBy` |
| `annSelectCursorAt(p)` | O cursor do Selecionar no ponto `p`: o de uma alça, o de mover sobre uma anotação, ou o padrão. Usada com o Ctrl apertado |
| `annToolCursor()` | O cursor da ferramenta atual: `text`, `default` (Selecionar) ou `crosshair` |
| `annIsStroke()` | `true` no desenho livre e no marca-texto, os dois traços livres |
| `annShiftKind(t)` | `'box'` no retângulo e no círculo, `'line'` nas outras: o modo do `annShiftPoint` |
| `upperKeepCaret(f)` | Passa o valor do campo para maiúsculas sem mexer no cursor (D-0096) |
| `showMemOnlyBanner()` | Mostra a faixa «Capturas só nesta aba» (`role="alert"`), uma vez por página, chamada pelo `keepInTab` |

### Funções do Admin Gate

| Função | O que faz | Notas |
|---|---|---|
| `deactivateAdmin()` | Oculta os botões admin (⚙️/💾) e sai do modo administrador | Definida dentro de `initAdminGate` e exposta como `window._deactivateAdmin`. Chamada por `closeSettingsModal` e pelo gate manual. **Não pertence ao motor de anotação** — é do Admin Gate (6 cliques no logo). |

### Funções de estado de anotação

| Função | O que faz | Notas |
|---|---|---|
| `setAnnDirty(val)` | Define `annIsDirty` e controla visibilidade do botão fechar modal | Esconde `img-modal-close` quando `annActive && annIsDirty` |
| `hasUnsavedAnnotations()` | Retorna `true` se há anotações não guardadas (`annActive && annIsDirty`) | Usada por `closeImgModal`, `imgModalNav` e backdrop click |
| `triggerUnsavedAlert()` | Anima botões Confirmar/Cancelar com pulse para alertar o usuário. Liga também a classe `ann-await` na barra: os outros botões ficam com `--opacity-dimmed` e sem clique durante `ANN_AWAIT_MS` | Chamada por `closeImgModal`, `imgModalNav` e o clique no fundo, quando há anotações pendentes. Um novo aviso reinicia o tempo |
| `clearAnnAwait()` | Tira a classe `ann-await` e cancela o temporizador | Chamada pelo temporizador, pelo `pointerdown` no canvas (continuar editando) e por `annDeactivate`, que cobre o Cancelar e o Confirmar |

### Funções de segurança

| Função | Assinatura | O que faz |
|---|---|---|
| `escapeHTML(s)` | `(string) → string` | Escapa `& < > " ' \`` para entidades HTML seguras |

---

## 8. Fluxos de comportamento

### Fluxo completo de captura de imagem (Ctrl+V)

```
Usuário pressiona Ctrl+V
      │
      ▼
Listener 'paste' verifica:
  - activeElement é INPUT, TEXTAREA ou editável? → devolver ao elemento nativo
      │
      ▼
Caminho 1: clipboardData.files (arquivos copiados do sistema)
  → captureFile(f) para cada um, e fim
      │
      ▼
Caminho 2: pasteItems(Array.from(items)), com for...of: primeiro as imagens, depois os outros arquivos
      │
      ├── Tipo image/* encontrado
      │         ↓
      │   captureFile(f)        → canDrawImage(): o navegador desenha a imagem?
      │         ↓                  não → captureDoc() e aviso (HEIC, TIFF, RAW)
      │   captureImg(blob)
      │         ↓
      │   ensureSession()       → cria sessão se não existe (com mutex)
      │         ↓
      │   Gerar label único     → verificar contra images[] e removed[]
      │         ↓
      │   idbPut('images', o)   → salvar em IndexedDB
      │         ↓                  falhou → keepInTab(): fica só na aba, faixa «Capturas só nesta aba» (uma vez)
      │         ↓
      │   renderThumb(o)        → inserir card na grelha
      │         ↓
      │   isDirty=true → triggerSave() → saveSession()
      │
      ├── Tipo file (não imagem) encontrado
      │         ↓
      │   captureDoc(blob, name, type)  [mesmo fluxo, tabela 'documents']
      │
      └── Nenhum arquivo — pasteText() verifica o texto
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

## 9. Variáveis de estado global

Estas variáveis existem no escopo do IIFE e representam o estado em memória da sessão atual.

| Variável | Tipo | Descrição |
|---|---|---|
| `sessId` | string \| null | ID da sessão ativa (`null` = estado pristine) |
| `sessObj` | object \| null | Objeto completo da sessão ativa |
| `images` | array | Imagens ativas da sessão (espelho em memória do IndexedDB). **Nota:** ao carregar sessão, items sem Blob válido são filtrados automaticamente (`blob instanceof Blob && blob.size > 0`) para proteger ambientes Safari/WebView onde blobs podem deserializar como `{}`. |
| `docs` | array | Documentos ativos da sessão |
| `removed` | array | Imagens nos «Removidos» |
| `removedDocs` | array | Documentos nos «Removidos» |
| `isDirty` | boolean | `true` = há alterações não guardadas |
| `sbExp` | boolean | `true` = sidebar de histórico está expandida |
| `_db` | IDBDatabase | Handle da base de dados IndexedDB |
| `_ensurePromise` | Promise \| null | Mutex de `ensureSession()` — evita race conditions |
| `_vbLabelDirty` | object | `{user: bool, equip: bool}` — track se o admin editou rótulos no VB |
| `sysColors` | object | Cores atuais `{main, fg, tStart, tAccent, tEnd}`. `main` e `fg` são a cor principal e a cor do texto sobre ela, usadas no contraste automático YIQ. O YIQ é um modelo de luminância que escolhe texto preto ou branco. `tStart`, `tAccent` e `tEnd` são as cores das 3 partes do título (vazio = herda). Inicializado a partir de `TOKEN_MAIN_COLOR`, `TOKEN_ACCENT_FG_OVERRIDE`, `TOKEN_TITLE_START_COLOR`, `TOKEN_TITLE_ACCENT_COLOR`, `TOKEN_TITLE_END_COLOR`. Lido por `applyTokens()`/`initVbSync()` e exportado pelo Quine. |
| `annActive` | boolean | `true` = modo de anotação ativo |
| `annTool` | string | Ferramenta ativa: `select` \| `rect` \| `circle` \| `arrow` \| `free` \| `highlight` \| `text` \| `crop` |
| `annHistory` | array | Fonte única da verdade das formas atuais no canvas; cada entrada: `{type, x1, y1, ...}` |
| `annUndoStack` | array | Pilha de snapshots compostos `{h, rot, crop, pcrop}`: `h` = deep clone de `annHistory`, `rot` = `annCurrentRotation`, `crop` = deep clone de `annCropBox` ou `null`, `pcrop` = clone da `o.cropBox` persistida ou `null`. O formato composto permite restaurar rotação e recorte além das anotações. Máximo `ANN_HISTORY_MAX` (50) |
| `annRedoStack` | array | Pilha de snapshots para refazer; limpa sempre que uma nova ação gera um undo |
| `annSelectedIdx` | number | Índice em `annHistory` da anotação selecionada; `-1` = nenhuma seleção |
| `annDragDirty` / `annResizeDirty` | boolean | Flags transitórias para identificar se o gesto contínuo gerou mutação de coordenadas antes do undo |
| `annCurrentColor` | string | Cor ativa da barra de anotação (hex) |
| `annSizeIdx` | number | Índice em `ANN_SIZES=[1,2,4,6,8,12]` (ou `ANN_HL_SIZES`) — espessura da ferramenta atual |
| `annSizeByTool` | object | O índice guardado de cada ferramenta que desenha; começa em 2 (4 px) nas linhas e em 1 (12 px) no marca-texto (D-0104) |
| `annColorBy` | object | `{ hl, line }`: a cor do marca-texto, que começa no amarelo, e a das outras ferramentas (D-0104) |
| `annTempSelectFrom` | string \| null | A ferramenta que o botão direito ou o do meio deixou pelo Selecionar; volta com um clique fora ou ao apagar (D-0103) |
| `annTextBold` | boolean | Negrito ativo na ferramenta texto (padrão: `true`) |
| `annTextItalic` | boolean | Itálico ativo na ferramenta texto |
| `annTextSize` | number | Tamanho da letra da ferramenta Texto (px), 24 ao abrir o editor; segue o − e o +, e o arraste das alças de um texto (D-0105) |
| `annEditingTextIdx` | number | Índice em `annHistory` do texto em edição via dblclick; `-1` = novo texto |
| `annTextClickTimer` | TimeoutID \| null | Timer de 220ms para distinguir single-click (novo texto) de dblclick (editar); escopo de módulo |
| `annSmoothLast` | object \| null | Último ponto suavizado pelo EMA no desenho livre; resetado em activate/deactivate/mouseup |
| `annCurrentRotation` | number | Rotação acumulada em graus (`0`, `90`, `180`, `270`) da imagem no editor; sincronizada com `o.rotation` ao salvar |
| `annCropBox` | object \| null | Área de recorte ativa `{x, y, w, h}` durante edição; `null` fora do modo crop |
| `longPressTimer` | number \| null | ID do `setTimeout` do long-press de reordenação; `null` quando inativo. Por container (`thumb-grid` e `doc-list`) dentro de `initReorder` |
| `annInitialState` | string \| null | JSON.stringify do `annHistory` ao ativar anotação — usado para detetar se houve alterações reais |
| `lastSaveAt` | number | Timestamp do último save automático para a status bar |
| `pdfFmt` | string | Modo de layout da página PDF ('vertical', 'horizontal', 'auto') |
| `zipModeActive` | boolean | Define se o modo ZIP está ativado |
| `modalIsTrash` | boolean | Indica se o modal de visualização provém dos «Removidos» |
| `modalItemId` | string | ID da imagem visualizada no modal |
| `imgZoomed` | boolean | Flag de imagem ampliada no modal |
| `imgScale` | number | Fator de zoom atual da imagem |
| `imgPanX` / `imgPanY` | number | Offsets de pan da imagem no modal |
| `imgPanning` | boolean | Flag de estado de pan (arrastamento) ativo |
| `imgStartX` / `imgStartY` | number | Coordenadas iniciais do pan |
| `annCtrlHeld` | boolean | Ctrl (Cmd no Mac) apertado no editor: qualquer ferramenta funciona como o Selecionar (D-0101) |
| `annShift` | boolean | Shift apertado no gesto atual, lido a cada evento de ponteiro e na própria tecla (D-0093) |
| `annPtr` | object \| null | A última posição do ponteiro no canvas, em px do canvas; dá o cursor ao apertar o Ctrl |
| `annHlSolid` | boolean | «Sólido» escolhido no marca-texto; chave `hl-solid` (D-0095) |
| `memOnly` | WeakSet | Os itens que o navegador não gravou e ficam só nesta aba (F-0063) |
| `memOnlyNoticeShown` | boolean | A faixa «Capturas só nesta aba» já apareceu nesta página |
| `idUpper` | boolean | Modo «Maiúsculas» atual; começa em `TOKEN_ID_UPPERCASE` e segue o interruptor do Visual Builder (D-0096) |
| `annSpaceHeld` | boolean | Barra de espaço pressionada no editor, com a imagem ampliada: arrastar move a imagem, em vez de desenhar |
| `annFill` | object | `{ rect, circle }`: `true` é «Preenchido» (D-0102) |
| `annFlyoutOpen` | Element \| null | As opções abertas de uma ferramenta (`.ann-flyout`), com `dataset.tool` |
| `annRotCenter` / `annRotStart` / `annRotStartAng` | object / number / number | Centro do texto, ângulo dele e ângulo do mouse no início do arrasto da alça de girar |
| `annTextPlace` | function \| null | Coloca de novo o campo de texto sobre o seu ponto da imagem, depois de um zoom ou de um pan |
| `trashUrls` | array | Lista de ObjectURLs das imagens nos «Removidos» |
| `annDrawing` | boolean | Estado de desenho em progresso na anotação |
| `annStart` | object | Coordenadas de início do traço de anotação |
| `annPath` | array | Lista de pontos desenhados na ferramenta 'free' |
| `annCommitText` | function | Callback para commitar campo de texto na anotação |
| `PRISTINE_HTML` | string \| null | Fonte primária do Quine — HTML original capturado via `fetch(location.href)` em `capturePristine()`; `null` até a primeira chamada. Fallback para `BOOT_HTML` se fetch falhar. Declarado dentro do bloco `ADMIN_JS`. |
| `_imgOverlayMdOnBackdrop` | boolean | Flag de gesture do modal de imagem — `true` se o `mousedown` ocorreu no backdrop (não num filho interativo); evita fechar o modal ao arrastar para fora |
| `_textOverlayMdOnBackdrop` | boolean | Flag de gesture do modal de documento — idem para o text modal |
| `_expOverlayMdOnBackdrop` | boolean | Flag de gesture do modal de Export |
| `textModalItemId` | string \| null | ID do documento atualmente aberto no text modal; `null` = modal fechado |
| `textModalIsTrash` | boolean | `true` se o documento aberto no text modal provém dos «Removidos» |
| `ANN_AWAIT_MS` | number (const) | `5000` — quanto tempo os outros botões da barra ficam apagados depois do aviso de anotações por salvar |
| `annAwaitTimer` | TimeoutID \| null | Temporizador do estado `ann-await`; `null` quando inativo |
| `ANN_SIZES` | array (const) | `[1, 2, 4, 6, 8, 12]` — espessuras de linha disponíveis na barra de anotação (px) |
| `ANN_HL_SIZES` | array (const) | `[8, 12, 18, 26, 36, 48]`: as larguras do marca-texto (px), nos mesmos seis passos do `ANN_SIZES` |
| `ANN_TEXT_SIZES` | array (const) | `[12, 14, 16, … 320, 400]` — os passos do − e do + no texto (px); `annTextStep` acha o próximo. O arraste das alças vai de `ANN_TEXT_MIN` (8) a `ANN_TEXT_MAX` (400) |
| `ANN_TEXT_LINE_RATIO` | number (const) | `1.3` — line-height ratio da ferramenta texto. Constante **única** usada nos dois lugares (line-height do `<textarea>` e do canvas em `annDrawShape`) para que o texto achatado seja igual ao que se vê ao escrever (WYSIWYG) |

---

### Os três sistemas de flags de estado "sujo"

Existem três sistemas de flags com escopos e ciclos de vida diferentes — **não são intercambiáveis**:

| Flag(s) | Escopo | Quem produz | Quem consome | Ciclo de vida |
|---|---|---|---|---|
| `isDirty` | Sessão inteira | Qualquer alteração de dados | `setInterval` auto-save 5s + `updateStatusBar()` | `true` quando dados mudam; `false` após `idbPut` |
| `annDragDirty` / `annResizeDirty` | Gesto de anotação | `pointermove` durante drag/resize | `pointerup` — decide se empurra snapshot para `annUndoStack` | Transitório: `false` no início, `true` se houve mutação, descartado após o snapshot |
| `annInitialState` | Sessão de anotação ativa | Atribuído na ativação | Comparado ao confirmar para detetar alterações reais | Criado ao ativar, comparado ao confirmar, destruído ao desativar |

> **Regra:** use `isDirty = true` para mudanças de dados da sessão; `annDragDirty`/`annResizeDirty` apenas para undo de gestos de anotação; não substitua `annInitialState` por um boolean simples.

## 10. Fluxo de trabalho de desenvolvimento para agentes

1. **Nunca sobrescrever o arquivo inteiro** — sempre edições incrementais e cirúrgicas
2. **Teste no navegador o que a mudança toca** (D-0084). O teste do Export User (§11, Parte B) continua manual, antes de cada versão.
3. **Após cada alteração significativa, atualizar:**
   - `README.md` — se for nova funcionalidade visível ao usuário
   - `design-tokens.md` — se for novo token CSS ou JS
   - `CHANGELOG.md` — sempre, com entrada na versão atual
4. **Codificação:** UTF-8 sem BOM
5. **Testar regressão mental:** Para cada alteração, verificar se os 3 contratos (zero-dep, Quine, XSS) continuam válidos
6. **Verificar markers:** Após qualquer edição ao HTML, confirmar que os 11 comment markers estão intactos
7. **Correr a verificação estática:** Após qualquer edição ao HTML, executar o `validate.sh` na pasta do projeto. É um conjunto de verificações mecânicas (grep + sintaxe) que dá sempre o mesmo resultado — uma IA pode confiar nele sem alucinar. **Não declarar a tarefa concluída se algum check falhar.** Isto não substitui o teste manual no navegador (ver Seção 11), mas detecta regressões estruturais antes disso.

   **Como executar** (o `validate.sh` é um script em Bash; este passo destina-se a agentes de IA):
   - Num ambiente com Bash (Linux, macOS, ou um agente de IA com terminal Bash), rode na pasta do projeto:
     ```bash
     bash validate.sh
     ```
   - Em Windows, o duplo clique **não** executa arquivos `.sh`. É preciso um terminal Bash (por exemplo, "Git Bash" ou WSL) e rode o mesmo comando: `bash validate.sh`.
   - Se não houver Bash disponível, fazer as mesmas verificações manualmente seguindo a Seção 11 (são contagens com `grep` e comparações de texto — nenhuma exige o navegador).

### O que o validate.sh verifica

O `validate.sh` executa 29 verificações mecânicas: 28 com regex, grep ou Python, e uma com o stylelint. Conferem os 3 contratos fundamentais (zero-dep, Quine, XSS) sem abrir o navegador.

**Critérios de Sucesso e Saída:**
- O critério correto de saída não é o número total de PASS, mas sim **"0 FAIL / exit code 0"**. Se houver 0 FAIL, a validação estática passou.
- **`[PASS]`**: O teste passou.
- **`[FAIL]`**: O teste falhou. Incrementar o contador e alterar o exit code final para `1`.
- **`[WARN]`**: Aviso não-bloqueante (ex: Complexidade Ciclomática excedida). Não incrementa FAIL nem altera o exit code.
- **`[SKIP]`**: O teste foi ignorado por ausência de dependências opcionais no sistema (ex: ausência do `node` ou `python`). Não afeta o resultado final.

> **Além dos 29 numerados há dois checks que só emitem `[WARN]` e não entram na contagem (D70):** a heurística de complexidade ciclomática (descrita abaixo) e a **contagem de checks**. A contagem compara o número declarado nesta seção com o `CHECKS_NUMERADOS` do script e avisa se forem diferentes. Existe porque a D24 corrigiu essa diferença. Ao acrescentar ou remover um check numerado, atualize os dois lugares.

**Os 29 Checks de Validação:**

1. **Comment markers (linhas grep)**: Verifica a integridade dos 11 locais de inserção de blocos dinâmicos do Quine. Falha indica corrupção da estrutura de export.
2. **Função definida: window.exportFile**: Casa a **sintaxe de definição** (`nome = function`), não a mera ocorrência do nome. Garante que o ponto de entrada do Quine existe como função.
3. **Função definida: capturePristine**: Idem. Garante que a função existe — **não** que a leitura do HTML original funcione; isso é o teste do Export User da §11 Parte B.
4. **Função definida: sanitizeForQuine**: Idem. Garante que a função existe — **não** que sanitize corretamente.
5. **Função definida: escapeHTML**: Idem. Garante que a função existe — **não** que esteja aplicada em todos os pontos de entrada, que é o que «proteção XSS» exigiria. Um check de presença não pode sustentar essa promessa; a cobertura real é matéria da §1.3.

> ⚠️ **O que os checks 2 a 5 provam, e o que não provam (D67).** Provam que a **sintaxe de definição não desapareceu** do arquivo. Não provam que a função roda — isso é o teste do Export User da `§11 Parte B` e o check 27. E não distinguem código de **contexto não executado**. Uma definição escrita num comentário **ou numa string literal** satisfaz o check; os dois casos foram medidos (D72). O âmbito é textual, não sintático. Isto é um limite **declarado, não um descuido**. Tirar os comentários de forma confiável exigiria um parser de JavaScript. O arquivo tem regex com aspas lá dentro (`/const TOKEN_MAIN_COLOR\s*=\s*'(?:[^'\\]|\\.)*'/`) e comentários com apóstrofos. **Os dois partem qualquer scanner ingênuo**: foi assim que a D54 corrompeu a contagem de complexidade. Escrever mais um scanner frágil para fechar este furo seria repetir o defeito que o projeto corrige o tempo todo.
6. **Span de titulo: ui-title-start**: Verifica o span obrigatório do título (parte 1).
7. **Span de titulo: ui-title-accent**: Verifica o span obrigatório do título (parte 2).
8. **Span de titulo: ui-title-end**: Verifica o span obrigatório do título (parte 3).
9. **APIs proibidas (eval/Function/write)**: Conta a ocorrência destas APIs. Deve ser estritamente 0 para mitigar riscos de segurança.
10. **Recursos externos http(s) (zero-dep)**: Bloqueia injeção de dependências externas (`cdn`, `googleapis`, `href="http...`). Deve ser 0 para a ferramenta funcionar sem internet.

> **Nota (D67):** este check visa **construtos de carregamento**, não a string `http`. As substrings `cdn.` e `googleapis` saíram. Faziam o check falhar sobre prosa inocente (um comentário que dizia «não usar `cdn.` de terceiros» dava `[FAIL]`) e não detectavam nada a mais. Medido: as 7 formas da matriz continuam todas detectadas sem elas, incluindo `href='//cdn.foo/x.css'`, que casa pela forma protocol-relative.
11. **Cabecalho de licenca MIT presente**: Verifica presença obrigatória dos direitos de autor do Capture Engine.
12. **TOKEN_SUBTITLE removido**: Verifica resíduo de funcionalidade descontinuada (deve ser 0).
13. **Modo PDF 'exact' removido**: Verifica resíduo de funcionalidade descontinuada (deve ser 0).
14. **Versão consistente no HTML**: Auto-detecta versão a partir do *boot message* e cruza com a versão declarada no *badge* visual e comentário VB. Falha indica versionamento inconsistente ou erro no processo de release.
15. **Versão: CHANGELOG = README**: a primeira entrada do `CHANGELOG.md` que não é `[Unreleased]` é a versão. A linha «Versão» de «Requisitos», no README, deve ser igual.
16. **Versão: CHANGELOG = HTML**: a mesma versão deve estar nas 3 referências de produto do HTML.
17. **Sintaxe JavaScript valida (node)**: Extrai todo script e roda `new Function()` para validar sintaxe de forma pura via Node. Se o node faltar, é dado como `[SKIP]`.
18. **TOKEN_MAIN_COLOR consistente (HTML vs design-tokens.md)**: confirma que a cor principal declarada no HTML bate com a documentada. FAIL = deriva de cor.
19. **Ferramentas de anotação no README**: lê os nomes no próprio HTML (o `title` de cada botão `data-tool` e do `#ann-rotate-btn`) e confirma cada um na linha «O editor tem N ferramentas» do README, sem diferenciar maiúsculas. A linha precisa ter uma frase só: uma explicação junto dela poderia repetir um nome e esconder uma ferramenta que falta. Não há lista para manter (D70, fechado em 2026-11-02). FAIL = ferramenta não documentada, ou nomes que não se leem no HTML.
20. **Guard de purge presente**: confirma que `if (!TOKEN_AUTO_PURGE_HOURS) return` existe no HTML. FAIL = risco de purge destrutivo com valor 0.
21. **Tokens com aspas simples**: confirma que nenhum TOKEN_* usa aspas duplas. FAIL = quebra do contrato de substituição do Quine.
22. **Declaração única de token (ZT1)**: confirma que cada TOKEN_* substituído pelo exportFile tem exatamente 1 declaração real. FAIL = risco de substituição silenciosamente errada (String.replace pega só a 1ª ocorrência).
23. **Inventário de z-index**: todo `z-index` usa um token `--z-*`, e o conjunto dos valores dos tokens deve ser exatamente o documentado em design-tokens.md §4. Falha se surgir valor novo, se um documentado desaparecer ou se houver um `z-index` literal.
24. **Durações de animação**: compara o CSS com os valores do design-tokens.md §5 (valores fixos esperados).
25. **Tamanho do arquivo**: valida se o tamanho do arquivo (admin) está dentro de uma faixa, como tripwire. A faixa é um limiar de validação e vive **apenas no `validate.sh`** — o README §12 dá só a ordem de grandeza («cerca de 400 KB») e não declara faixa nenhuma. Ao alterar o limiar, altere-o no `validate.sh`; não há segundo lugar para sincronizar.
26. **ZIP — flag UTF-8 (bit 11)**: confirma o bit 11 (`0x0800`) do *general purpose bit flag* nos dois cabeçalhos do `buildZIP` (local file header e central directory). FAIL = nomes de arquivo com acentos saem ilegíveis no descompressor (ver D21).
27. **Export User inicializa**: aplica os 4 regex de remoção do `exportFile` e avalia o JS resultante num shim de DOM onde `getElementById` devolve `null` para os IDs removidos. **É comparativo:** só dá FAIL se o artefato User abortar **e** o Admin não. Assim, um ID criado em runtime (`null` nos dois) não gera falso positivo, e um shim com defeito falha nos dois e dá `[WARN]`. Cobre código síncrono de nível de módulo; `init()` é `async` e não roda neste ambiente. FAIL = a cópia distribuída aos usuários finais não inicializa (ver D25).
28. **stylelint (modelo dos prompts)**: roda o stylelint com o `.stylelintrc.json` da raiz, cópia exata de `stylelint/.stylelintrc.json` do repositório `diogo-engenharia-software-agentes`, nas versões do README dessa pasta. FAIL = um valor visual fora dos tokens ou uma escrita fora do `stylelint-config-standard`. Sem `npx`, dá `[SKIP]`; na primeira vez, o `npx` baixa os pacotes.
29. **design-tokens.md = código**: cada linha ``| `--nome` | `valor` |`` das tabelas do `design-tokens.md` deve bater com o `:root` do HTML, e a coluna «Escuro» com o bloco `html.dark`. Cada token dos dois blocos precisa de uma linha. As linhas ``| `TOKEN_X` | tipo | `valor` |`` da §6 devem bater com a declaração `const`. FAIL = a tabela envelheceu ou um token novo ficou sem documentação.

**Cópias verificadas.** Estes fatos aparecem em dois lugares, e um check do `validate.sh` compara as duas cópias:

| Cópia | Dono | Check |
|---|---|---|
| Tabelas do `design-tokens.md` (tokens CSS e padrões dos `TOKEN_*`) | `capture-engine.html` | 29, 18, 23 e 24 |
| Linha «Versão» do README e as 3 referências de versão do HTML | `CHANGELOG.md` | 15 e 16 |
| Lista das ferramentas de anotação no README | `capture-engine.html` | 19 |

**Check adicional heurístico (Não contabiliza FAIL nem altera exit code):**
O `validate.sh` inclui um check heurístico (Python) que analisa funções do JS inline e emite `[WARN]` para funções com > 15 pontos de decisão (`if/else/for/while/switch/case/&&/||/?`). As funções que disparam WARN são candidatas a refatoração futura — não são erros e não bloqueiam a validação.

Cada palavra conta só na forma que tem no código: `if (`, `for (`, `while (` e `switch (` com o parêntese, `else` logo depois de `}`, `;` ou `)`, e `case` seguido de aspas ou número. Assim, o inglês dos comentários não muda os números (D-0092). Os comentários não são removidos: um removedor quebraria nas expressões regulares do arquivo (D67, D72).

#### Pontos de maior risco de regressão

Rode `bash validate.sh` e leia as linhas `[WARN] Funcao '…' com CC n`: são as funções com mais pontos de decisão, e a saída do script é a lista atual. **Não é uma lista de defeitos.** É o mapa de onde uma edição tem mais probabilidade de quebrar alguma coisa. As divergências entre código e documentação das auditorias da V26 concentraram-se nestas funções. A lista não é copiada aqui, porque uma cópia sem comparação envelhece a cada versão.

**Como usar isto:** antes de editar qualquer função dessa lista, leia a seção correspondente do motor (§4, §7) e confirme as invariantes documentadas. Depois da edição, o `validate.sh` detecta regressões estruturais, mas **não** detecta regressões de comportamento — estas exigem a Parte B do checklist (§11).

> ⚠️ **Armadilha do medidor — apóstrofos em comentários.** O analisador de complexidade **não ignora comentários** e trata `'` como abertura de string. Um número ímpar de apóstrofos num comentário (ex.: «e'», «d'») deixa o analisador dentro de uma string falsa. A contagem de chaves corrompe-se a partir daí: as funções ficam com o nome errado, e os valores **descem**. Sintoma: acrescentar código e ver o CC baixar. Aconteceu na D54 e custou uma investigação. Escreva comentários sem apóstrofos, ou em número par.
>
> **Nota:** a heurística conta pontos de decisão, não complexidade real percebida. Uma função pode ter CC alto por ter muitos ramos triviais. A lista ordena risco relativo e não é veredicto de qualidade.

---

### Exemplos práticos de extensão

As regras de §0–§9 descrevem o **que não fazer**. Esta seção mostra o **como fazer** para as duas tarefas de extensão mais comuns, do início ao fim.

---

#### Exemplo A — Adicionar novo TOKEN_*

**Cenário:** adicionar `TOKEN_SHOW_LOGO` (boolean) que controla a visibilidade do logo.

**Passo 1 — Declarar no bloco TOKENS** (junto aos outros `TOKEN_*`):
```js
const TOKEN_SHOW_LOGO = true;
```

**Passo 2 — Usar no código** (ex: em `applyTokens()`):
```js
document.getElementById('app-logo').style.display = TOKEN_SHOW_LOGO ? '' : 'none';
```

**Passo 3 — Integrar no Visual Builder** (se editável pelo admin):
- Adicionar campo HTML na aba correta do modal VB
- Registrar handler em `initVbSync()` seguindo o padrão dos campos existentes
- Sincronizar em `applyTokens()` para refletir o valor atual no VB

**Passo 4 — Quine cobre automaticamente:** `sanitizeForQuine()` processa todos os `TOKEN_*` por regex — nenhuma alteração necessária nessa função.

**Passo 5 — Atualizar docs:**
- `README.md §7.4` — nova linha na tabela de tokens
- `design-tokens.md` — se for token de design visual
- `CHANGELOG.md` — entrada na versão atual

**Passo 6 — Validar:**
```bash
bash validate.sh  # deve retornar 0 FAIL / exit code 0
```

> ⚠️ **Formato obrigatório:** `const TOKEN_NOME = 'valor'`. Usar `let`, TypeScript ou template literals quebra a regex do Quine Engine.

---

#### Exemplo B — Adicionar nova ferramenta de anotação

**Cenário:** adicionar a ferramenta "Linha reta" ao motor de anotação.

**Passo 1 — Adicionar botão na barra de ferramentas (HTML)** (fora dos blocos `ADMIN_*`):
```html
<button id="ann-tool-line" class="ann-tool-btn" title="Linha">—</button>
```

**Passo 2 — Registrar o tool name** em `initAnnotation()` seguindo o padrão de `rect`, `circle`, `arrow`, `free`, `text`.

**Passo 3 — Implementar Pointer Events** em `initAnnotation()`:
- `pointerdown` — registrar ponto inicial
- `pointermove` — redesenhar a pré-visualização
- `pointerup` — confirmar e salvar snapshot

**Passo 4 — Salvar snapshot antes de confirmar** (crítico para undo/redo):
```js
// Antes de modificar o canvas definitivamente:
annPushUndo();
// annPushUndo() captura o snapshot {h: clone profundo de annHistory, rot: rotação atual, crop: cropBox atual, pcrop: cropBox persistida}
// NÃO usar getImageData — modelo de pilha antiga, explicitamente proibido em §7
if (annUndoStack.length > 50) annUndoStack.shift(); // máximo 50 passos
annRedoStack.length = 0; // limpar redo ao iniciar novo traço
```

**Passo 5 — NÃO colocar dentro de** `/* ADMIN_JS_START */` — anotação deve funcionar para usuários finais.

**Passo 6 — Validar e testar:**
- `bash validate.sh` → 0 FAIL / exit code 0
- Teste manual Parte B §11: undo/redo com Ctrl+Z / Ctrl+Y na nova ferramenta

> ⚠️ **Não usar** `mousedown`/`touchstart` — todo o motor usa exclusivamente Pointer Events para compatibilidade cross-device.

---

## 11. Checklist de validação — antes de declarar completo

Nenhuma tarefa está concluída sem validar todos os pontos abaixo:

A validação tem **duas partes**:
- **Parte A — sem navegador:** verificações mecânicas e de leitura de código. O `validate.sh` faz as mecânicas: markers, funções do Quine, partes do título, APIs proibidas, zero-dependência e sintaxe JS (ver a Seção 10, «Como executar»). As restantes confirmam-se lendo o código.
- **Parte B — teste no navegador:** comportamento que só se confirma a abrir e a usar a aplicação. O agente pode fazer estes testes, por exemplo com o Playwright (D-0084). O «Teste do Export User» é sempre feito por quem mantém o projeto, antes de cada versão.

---

### Parte A — Verificações sem navegador

**Segurança:**
- [ ] `escapeHTML()` aplicado a todos os dados do usuário inseridos via `innerHTML`
- [ ] `sanitizeForQuine()` aplicado antes de tokens serem injetados no arquivo exportado
- [ ] Sem `eval()`, `Function()`, ou `document.write()`

**Integridade do Quine:**
- [ ] Todos os 11 comment markers estão intactos (verificar com `grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" capture-engine.html` → deve retornar 11)
- [ ] `window.exportFile()`, `capturePristine()` e `sanitizeForQuine()` não foram movidos
- [ ] Formato das declarações `const TOKEN_* = 'valor'` preservado
- [ ] Os 3 spans de título (`#ui-title-start`, `#ui-title-accent`, `#ui-title-end`) existem no HTML
- [ ] `exportFile()` substitui `TOKEN_TITLE_END` via regex (além de START e ACCENT)
- [ ] Campo `cfg-title-end` existe no VB (Tab Interface)

**Unicidade:**
- [ ] Sem nomes duplicados possíveis em capturas de tela ou documentos
- [ ] A deduplicação verifica contra listas ativas **e** «Removidos» (verificar: `captureImg`, `captureDoc`, `restoreImg`, `restoreDoc`, `setLabel`, `setDocName`)
- [ ] Comparação de nomes é case-insensitive

**Internacionalização:**
- [ ] Sem strings hardcoded em inglês visíveis ao usuário
- [ ] Sem strings hardcoded em PT-PT (regionalismo) — usar PT neutro

**Estrutura da Anotação (ler o código, após qualquer edição ao annotation engine):**
- [ ] `annTextClickTimer` declarado no escopo de módulo (antes de `initAnnotation`)
- [ ] `annSmoothLast` declarado no escopo de módulo
- [ ] `annDeactivate()` faz `clearTimeout(annTextClickTimer)` e `annSmoothLast=null`
- [ ] `annRedraw()` usa `forEach((h,_ri) => { if(_ri===annEditingTextIdx) return; ... })`
- [ ] `annDrawShape` usa `ctx.textBaseline='top'` e repõe `'alphabetic'` no final; o texto é desenhado **linha a linha** (split por `\n`) com `lineH = fontSize × ANN_TEXT_LINE_RATIO` (mesma constante do line-height do `<textarea>`)
- [ ] `closeSettingsModal` chama `window._deactivateAdmin()`
- [ ] `window._deactivateAdmin` é atribuído dentro de `initAdminGate`
- [ ] `annDrawShape` é função de draw pura — não contém `annIsDirty = true` nem manipulação do DOM (side effects pertencem ao caller)

**Documentação:**
- [ ] Se foi adicionada ou removida uma função de inicialização, verificar se o diagrama `boot()` na Seção 15 do `README.md` foi atualizado
- [ ] Se foi adicionada uma variável de estado global, verificar se foi incluída na tabela da Seção 9
- [ ] Se mudou o comportamento de um motor (anotação, Quine, PDF/ZIP, sessões), confirme que o `README.md`, o `design-tokens.md` e o `AGENTS.md` descrevem o comportamento **atual**. *(Já aconteceu: a anotação foi reescrita na V23, e os três documentos ainda descreviam o pipeline antigo. A suavização Laplaciana e o RDP saíram na V23, mas a variável `annSmoothLast` ficou ativa. Confira sempre que mexer num motor.)*

---

### Parte B — checklist de teste manual no navegador

Esta é a lista **única e completa** de testes que exigem abrir a aplicação. Não depende de outros documentos — tudo o que precisa ser confirmado no navegador está aqui.

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
- [ ] O traço salvo é igual ao que se viu na tela — sem arredondar, sem alisar e sem fechar o contorno sozinho
- [ ] Curvas mantêm as quinas suaves depois de soltar (não ficam pontudas)
- [ ] Retângulo, círculo e seta desenham por arrasto
- [ ] Texto: colocar (Enter insere uma linha nova; clicar fora ou Confirmar grava; Escape cancela), reeditar com duplo-clique, mudar cor / negrito / itálico
- [ ] Desfazer / Refazer (Ctrl+Z / Ctrl+Y)
- [ ] "Confirmar" funde a anotação na imagem; "Cancelar" descarta
- [ ] Tentar fechar o modal com anotações por salvar → botões Confirmar/Cancelar pulsam, e o resto da barra fica meio transparente e sem clique por 5 s
- [ ] Durante esse aviso, um clique na imagem desfaz o estado antes dos 5 s
- [ ] Texto: o «Girar 90°» gira também o texto
- [ ] Texto: o botão de duas setas acima do texto selecionado gira o texto e prende em 90° quando passa perto; o texto girado redimensiona e reedita girado
- [ ] Botão direito ou do meio numa anotação, numa ferramenta de desenho: fica selecionada, com o ✕, e o Selecionar aceso; um clique fora, o ✕ ou o Delete voltam à ferramenta de antes sem desenhar
- [ ] Espessura por ferramenta: o desenho livre, o retângulo, o círculo e a seta começam em 4 px, o marca-texto em 12 px e no amarelo; trocar de ferramenta e voltar mantém o passo e a cor de cada uma
- [ ] Texto: o + vai até 400 e o − até 12; arrastar a alça de um texto muda o número da bandeja do Texto
- [ ] Com duas imagens ou mais, as setas ← → no editor, dentro e fora de uma bandeja, não trocam de imagem nem fecham o editor (F-0083)
- [ ] Esc com anotações por salvar: o aviso aparece, e nada se perde (F-0088); Esc no meio de um arraste, depois outra imagem e Ctrl+Z: nada da imagem anterior volta (F-0084)
- [ ] Em 360 e 375 px de largura, a barra do editor e as bandejas cabem na tela (F-0085)
- [ ] Opções das ferramentas: o duplo clique e o botão apertado por 1 s abrem as opções, lado a lado, acima de cada ferramenta que desenha; o − e o + da bandeja mudam o tamanho mostrado depois deles e o da barra; um clique simples só escolhe a ferramenta; a seta para cima abre pelo teclado e o Esc fecha sem fechar o editor
- [ ] Retângulo e círculo «Preenchido»: a forma sai cheia na cor; escolher a opção com uma forma selecionada a muda, e o Ctrl+Z desfaz
- [ ] Zoom no editor (roda e botões + e −): um traço feito a 200 % cai debaixo do cursor
- [ ] Zoom no editor: Espaço + arrastar e o botão do meio movem a imagem sem desenhar; o campo de texto aberto e o botão ✕ acompanham o zoom

**Reordenação (reescrita com Pointer Events / FLIP na V23):**
- [ ] Arrastar imagens para reordenar é **estável** (não salta nem pisca), com mouse
- [ ] Se possível, testar também em **tela de toque**
- [ ] Um **clique simples** ainda abre o item (não confunde clique com arrasto)
- [ ] Arrastar documentos na lista também reordena

**Visual e tema:**
- [ ] Imagens com cantos retos; botões e cards de texto com cantos arredondados
- [ ] O arquivo abre **sem erros no console** (F12)
- [ ] Dark mode funciona **sem flash branco** ao abrir (anti-FOUC)

**Export (testar o ciclo real):**
- [ ] PDF gera com imagens; fica **desativado** quando há documentos na sessão
- [ ] ZIP empacota imagens + documentos
- [ ] **Export Admin** → a cópia mantém o painel de administração e a capacidade de re-exportar

---

#### Teste do Export User — obrigatório em toda a release

> ⚠️ **AVISO CRÍTICO — este é o teste que faltou durante 15 versões:** entre a V11 e a V25, o Export User produziu um arquivo que **nunca inicializava** (ver changelog D25). Não foi detectado porque o `validate.sh` só valida o arquivo de administrador, e nunca o produto do export. Os itens antigos deste checklist só conferiam o que devia estar **ausente** (botões de admin, Visual Builder, logs), e um artefato morto cumpre isso. **Nunca substituir este bloco por verificações de ausência.**

Executar **sempre**, com o arquivo realmente gerado pelo botão Export — nunca com o `capture-engine.html` de desenvolvimento:

1. [ ] Fazer **Export User** pela aplicação e guardar o arquivo
2. [ ] Abrir esse arquivo no navegador e pressionar **F12 → Console**
3. [ ] **Zero erros no console, sem exceção.** Um `TypeError: Cannot read properties of null` é a assinatura exata do defeito D25: o IIFE abortou e a aplicação está morta por baixo de uma interface que parece normal.
   - O Export User não tem o bloco `ADMIN_JS`, por isso não chama o `capturePristine()` nem faz o `fetch(location.href)`. Aberto por `file://` ou servido por `http(s)`, o console fica sem erro nenhum.
   - O par `Access to fetch at 'file:///…' … CORS` e `[CE] Quine fallback: BOOT_HTML` é normal só no `capture-engine.html` principal e no Export Admin abertos por `file://` (§1.2). **Num Export User, esse par reprova o passo:** quer dizer que o bloco `ADMIN_JS` não foi removido.
4. [ ] **A aplicação responde:** colar uma imagem (Ctrl+V) e confirmar que ela aparece na grade
5. [ ] **A sessão persiste:** escrever no campo User, recarregar a página, e confirmar que a sessão está no histórico
6. [ ] Confirmar que as configurações (cor, nome, rodapé) foram aplicadas
7. [ ] Confirmar que **não** há botões de admin nem Visual Builder

> ⚠️ **O protocolo em que roda o teste muda o artefato — declare qual usou.** Em `http(s)` o Export Admin sai **byte a byte igual** ao `capture-engine.html` de origem. Em `file://` o `fetch` falha, e o Quine exporta o `BOOT_HTML`, o `document.documentElement.outerHTML` capturado ao abrir. É HTML equivalente, mas **re-serializado pelo navegador**: tags SVG auto-fechadas passam a ter fechamento explícito, e atributos multi-linha colapsam. Medido na V26: `316.308` bytes / `eab02cb0` em `http(s)`, contra `316.354` / `f94ac992` em `file://`. **Ambos são pontos fixos:** G1 = G2 = G3 dentro de cada protocolo, e todas as gerações abrem vivas. Não há deriva a acumular — mas os dois números não são o mesmo número, e um registro que não diga qual protocolo usou não é reproduzível.

> **Por que os passos 4 e 5 não são dispensáveis:** no defeito D25, a interface aparecia inteira, com «Pronto» na barra de estado, porque isso é HTML estático. Só a interação revela que nada está ligado. Uma inspeção visual passa; colar uma imagem não.

> ℹ️ **Nota:** o check 27 do `validate.sh` simula a remoção e detecta esta classe de defeito. Só cobre o código síncrono de nível de módulo, porque o `init()` é `async`. **Não substitui este teste.**

**Multi-aba:**
- [ ] Abrir o arquivo numa segunda aba do mesmo navegador → **carrega normalmente** (sem tela de erro vermelha); ambas as abas funcionam e compartilham a mesma base de dados

---

## 12. Versões e changelog

**Formato do changelog:** o `CHANGELOG.md` segue o [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). Cada versão é uma entrada `## [X.Y.Z] - AAAA-MM-DD`, com as categorias Adicionado, Modificado, Removido e Corrigido. O trabalho ainda sem versão fica em `## [Unreleased]`.

As entradas `[V7]` a `[V27]` são anteriores a este formato e usam outras categorias. Ficam como estão, porque são registro datado.

**Versões:** SemVer a partir de 28.0.0 (D-0078).
- Major: quem distribui a ferramenta precisa refazer algo (um `TOKEN_*`, o formato do export, o schema do IndexedDB).
- Minor: uma funcionalidade nova.
- Patch: uma correção sem mudança para quem distribui.

As tags `v1` a `v27` ficam como estão. As tags novas são leves e chamam-se `vX.Y.Z`.

**Onde a versão aparece.** O `CHANGELOG.md` é o dono. Quatro lugares repetem a versão, e o `validate.sh` confere-os (checks 14 a 16):
- a linha «Versão» de «Requisitos», no README;
- no HTML, o comentário `<!-- VISUAL BUILDER MODAL (X.Y.Z) -->`, o badge `>X.Y.Z</span>` do Visual Builder e a mensagem `SysLogger.info('Capture Engine X.Y.Z Ready')`.

Nenhum título de documento leva a versão. **Motivo:** cada cópia a mais é um lugar onde a versão envelhece sem aviso.

**Fechar uma versão:**
1. Troque `## [Unreleased]` por `## [X.Y.Z] - AAAA-MM-DD`.
2. Mude a linha «Versão» do README e as 3 referências do HTML. A imagem `docs/images/admin-mode.png` mostra o número da versão no Visual Builder: gere-a de novo com o `gerar.py` do repositório dos prompts, e confira as duas com `--verificar`.
3. Rode `bash validate.sh`, que deve dar 0 FAIL.
4. Antes do commit, quem mantém o projeto faz o «Teste do Export User» da §11, Parte B, com o arquivo já com a versão nova.
5. Faça um commit só com estas mudanças e a linha do teste do Export User no changelog: `docs(changelog): versão X.Y.Z`. Um commit só para o teste não é preciso.
6. Crie a tag leve nesse commit: `git tag vX.Y.Z`. O push da tag pede a palavra CONFIRMO de quem mantém o projeto.
7. Publique a release da tag com o `capture-engine.html` anexado: `gh release create vX.Y.Z capture-engine.html --title "X.Y.Z" --notes-file <entrada do changelog>`. O botão «Download» do README baixa o arquivo da release mais recente. Publicar pede o mesmo CONFIRMO. Depois, confira que o arquivo do botão é igual ao do commit da tag.

**Motivo da tag no protocolo:** a V26 saiu sem tag, e seis auditorias não o detectaram. Este protocolo não falava de tags, e uma auditoria só encontra o que o protocolo manda procurar.

> [!CAUTION]
> **Nenhuma versão fecha sem o teste do Export User.**
> Da V11 à V25, o Export User gerou um arquivo que não inicializava, e ninguém notou. O teste custa dois minutos.

**Numeração dos checks:** os comentários do `validate.sh` numeram os checks de outra forma que a lista da §10 (D69). Ao citar um check, diga de que lista fala.

---

## 13. Decisões, pendentes e IDs

Estas decisões foram explicitamente confirmadas pelo proprietário do projeto e **não devem ser revertidas sem aprovação**:

| # | Decisão | Motivo |
|---|---|---|
| D1 | **Botão PDF desativado quando há imagens + documentos** | PDF é exclusivo de imagens. Quando há docs na sessão, o usuário deve usar o ZIP. |
| D2 | **Modal do Visual Builder não fecha ao clicar fora** | O VB é de uso exclusivo Admin e requer fechamento explícito pelo botão ✕ para evitar perda de configurações acidentais. |
| D-0097 | **O Esc também não fecha o Visual Builder; o ✕ é alcançado pelo teclado** | Completa a D2: o Visual Builder fecha só pelo ✕, com o mouse ou com Tab até ele e Enter. Os outros modais fecham com Esc. Origem: pedido do dono, 2026-11-05 (F-0077). |
| D3 | **setInterval de 5 segundos mantido no auto-save** | Cobre os eventos `isDirty=true` dos controles contínuos do VB (seletores de cor, campos hex, sliders, radios, toggles, campos de texto). Esses eventos `input` não chamam `triggerSave()` na hora. Sem o interval, alterações no VB perdem-se se o navegador for fechado dentro da janela de 5s. |
| D4 | **Placeholder "Imagem N" não atualiza após drag-and-drop** | O placeholder é decorativo (hint visual). Não representa numeração oficial — a legenda editável é o campo `label`. |
| D5 | **triggerSave() sem await em closeSettingsModal** | Risco de perda de dados aceito. O setInterval de 5s garante persistência antes de fechar o navegador em uso normal. |
| D6 | **TOKEN_TITLE_END com 3 spans independentes no brand-name + amostras de cor individuais** | Permite construir títulos como `C P C` (letras a cores alternadas) com espaços controlados manualmente. Cada span tem cor independente configurável via `TOKEN_TITLE_START_COLOR`, `TOKEN_TITLE_ACCENT_COLOR`, `TOKEN_TITLE_END_COLOR`. Vazio = herda cor do contexto. Duplo clique no swatch para repor automático. |
| D7 | **Apagar sessão é imediato e permanente, sem diálogo de confirmação** | Não há uma única chamada a `confirm()` em todo o produto — é coerência deliberada, não esquecimento no botão da sidebar. A barra «Removidos» cobre itens individuais (imagens e documentos), que é onde a recuperação tem valor prático; sessões inteiras são apagadas por decisão explícita do usuário no ✕ da sidebar. **Não reintroduzir confirmação sem aprovação do proprietário** — foi levantado em auditoria e mantido conscientemente. |
| D8 | **Escape descarta anotações não salvas sem alertar, ao contrário do ✕ e do clique fora** | Escape é o atalho de teclado equivalente ao botão **Cancelar**, e cancelar descarta por definição. Os outros dois caminhos de fechamento (✕ e backdrop) passam por `hasUnsavedAnnotations()` e disparam `triggerUnsavedAlert()` porque aí a intenção é fechar o modal, não cancelar a edição. A divergência é intencional e reflete intenções diferentes. **Não uniformizar os três caminhos sem aprovação do proprietário.** |
| D-0077 | **`Desfazer` e `Refazer` mantêm sempre o mesmo aspecto, mesmo quando não há nada para desfazer** | Ao reabrir uma imagem, o `annUndoStack` recomeça vazio, porque as anotações já foram confirmadas ao guardar. O `annRedoStack` volta do IndexedDB. Os dois botões não refletem esse estado: apresentam-se sempre com o mesmo estilo e o clique não produz efeito nem aviso. **Medido:** `visivel=true`, `disabled=false`, `opacidade=1` e `cursor=pointer`, e dois cliques não alteram o canvas nem o IndexedDB. Não foi corrigido por decisão do proprietário. A barra de anotação tem três estados (normal, `:hover`, `.active`) e **nenhum estilo `disabled`**. Desativar os botões deixava-os iguais à vista, e trocava uma falha silenciosa por outra. Corrigir a sério exigiria desenhar um quarto estado visual, o que é decisão de design e não correção. A capacidade de remover anotações não se perde: seleciona-se a anotação e apaga-se. Origem: D75 (sétima auditoria). Antes registrada como D9, ID que já era do commit `a5656f5`. |
| D-0078 | **Versões em SemVer a partir de 28.0.0** | O critério de major, minor e patch está na §12. As tags `v1` a `v27` e as entradas `[V7]` a `[V27]` ficam. Origem: auditoria de 2026-10-31, decisão 1. |
| D-0079 | **Purge às 48 horas e sem backup automático** | Por privacidade: para guardar, o usuário exporta PDF ou ZIP. Origem: `CHANGELOG.md`, «Decisões mantidas» da V23. |
| D-0080 | **O aviso de quota fica por cima da barra do topo, em `#b91c1c` e branco** | É um aviso que não pode ser ignorado. As duas cores são os tokens `--color-banner-critical` e `--color-white` (até a 28.6.3, literais no JavaScript). Origem: `CHANGELOG.md`, D23. |
| D-0081 | **Sem o botão «Nova Sessão»** | Abrir uma sessão numa janela separada só fazia sentido com o launcher `CaptureEngineApp.vbs`. Fora dele, abria várias instâncias sem necessidade. Origem: `CHANGELOG.md`, V18. |
| D-0082 | **Tamanhos de fonte, espaços e cortes do layout em `rem`** | O texto acompanha o tamanho de letra escolhido no navegador. Com a letra padrão (16 px), nenhum pixel muda. Revoga a regra antiga «Usar `px`» do §2.2. Origem: auditoria de 2026-10-31, decisão 2. |
| D-0083 | **Entradas antigas do changelog: as palavras seguem a tabela, as frases ficam** | As formas de Portugal e os anglicismos da lista são trocados também nas entradas `[V7]` a `[V27]`. As frases longas antigas ficam, porque são registro datado. Origem: auditoria de 2026-10-31, decisão 4. |
| D-0084 | **O agente testa no navegador o que muda** | Uma regra antiga mandava o agente nunca abrir o navegador. O teste do Export User (§11, Parte B) continua manual, antes de cada versão. Origem: auditoria de 2026-10-31, decisão 5. |
| D-0085 | **Comentários de código em inglês: o `validate.sh` já, o HTML depois** | Os comentários do HTML ficam perto dos marcadores do Quine e vão num plano próprio (F-0029, em «Pendentes»). Origem: auditoria de 2026-10-31, decisão 7. |
| D-0086 | **O prefixo `-webkit-backdrop-filter` fica** | O Safari anterior à versão 18 só aplica o desfoque com o prefixo. É a única exceção ao stylelint, marcada com `stylelint-disable-next-line` na regra de `#zoom-ui`, `#img-nav-prev` e `#img-nav-next`. Origem: auditoria de 2026-10-31, passo 72 do plano. |
| D-0087 | **O chevron «›» dos botões .pdf e .zip fica** | Aparece só com o botão ativo e some no estado «Concluído». Num botão preenchido, lê-se como «seguir em frente», perto da ação. Alternativas estudadas na 28.4.0 e na 28.5.0: ícone de baixar (pesado), contagem de páginas e arquivos, «.pdf»/«.zip» (redundante depois da mudança de nome) e o visto (diz «feito» antes de exportar e enfraquece o aviso de sucesso). Fecha a P-0002. Origem: pedido do dono, 2026-11-01 (28.5.0). |
| D-0088 | **«Teste do Export User», e não «prova de vida»** | O nome antigo não dizia o que se testa e enchia a lista de commits. O changelog até a 28.5.2 usa «prova de vida»: é o mesmo teste. A partir da 28.5.3, o teste entra no commit da versão, sem commit próprio. Origem: pedido do dono, 2026-11-01. |
| D-0089 | **A dica das zonas vazias diminui até 800 px de altura** | Ícone de 40 px e texto de 13 px nas telas de notebook (28.5.3). Não é um modo compacto: não muda a barra lateral, e foi pedida para a dica chamar menos atenção, e não para caber. Origem: pedido do dono, 2026-11-01; confirmado no plano da auditoria do mesmo dia. |
| D-0090 | **As frases longas das entradas publicadas do changelog ficam** | Estende a D-0083 a toda entrada com versão, também as 28.x. **Motivo:** o changelog é registro datado; reescrever uma entrada publicada muda o que se disse naquela data. As palavras ainda seguem a tabela. Origem: plano da auditoria de 2026-11-01. |
| D-0092 | **A complexidade conta a forma de código das palavras** | O check 10 contava `if`, `else`, `for` e as outras como palavras soltas, também nos comentários. Com os comentários em inglês, avisava `annDoUndo` e `annDoRedo`, que não tinham mudado (A-03). Agora conta só a forma que a palavra tem no código. Medido em 207 funções com código igual na 28.6.3 e na 28.6.4: 6 mudavam de número só pelos comentários, e nenhuma muda agora. Os comentários continuam sem ser removidos (D67, D72), e a armadilha dos apóstrofos continua valendo. Origem: auditoria de regressão de 2026-11-02. |
| D-0093 | **Shift nas ferramentas do editor** | Ao desenhar e ao redimensionar, o Shift deixa o retângulo quadrado e a elipse círculo, e a seta e o desenho livre em passos de 45° a partir do ponto fixo. O estado do Shift é lido a cada evento de ponteiro e na própria tecla. Origem: pedido do dono, 2026-11-04. |
| D-0094 | **«Diminuir» e «Aumentar» no lugar de «Espessura menor» e «Espessura maior»** | Os dois botões têm o mesmo nome em todas as ferramentas: mudam a espessura do traço ou, no texto, o tamanho da letra. Antes, o nome mudava entre «Espessura» e «Texto». Origem: pedido do dono, 2026-11-04. |
| D-0095 | **Marca-texto translúcido ou sólido, e não as ferramentas tarja e desfocar** (o modo da barra foi substituído pela D-0102) | Uma ferramenta só esconde ou destaca: «Translúcido» (40 % de opacidade) deixa ler o que está por baixo, e «Sólido» cobre. O traço é um traço livre com o campo `hl` (`'soft'` ou `'solid'`), pontas retas e uma escala de larguras própria (`ANN_HL_SIZES`); por isso herda a seleção, o mover, o redimensionar, o girar e o desfazer. As opções ficam acima da ferramenta (D-0102), e o − e o + da bandeja mudam a espessura, como nas outras ferramentas. Em 2026-11-06, o − e o + mudaram a opacidade do marca-texto no lugar das duas opções; o dono voltou atrás no mesmo dia, porque o − e o + mudavam de sentido só nesta bandeja e a espessura saía dela. Não usa `multiply`: o canvas das anotações fica por cima da imagem, e a gravação ficaria diferente da tela. Origem: pedido do dono, 2026-11-04 e 2026-11-05. |
| D-0099 | **Cena do GIF do editor: neutra, sem datas, e a seta sai de dentro da janela** | A captura é uma área de trabalho com o programa fictício «Orbita», uma DLL selecionada e uma notificação de erro, só com palavras iguais no Brasil e em Portugal. O GIF começa no visualizador: clica em «Editar», escolhe a Seta, e a seta de 4 px sai do painel da esquerda e termina na DLL. Termina com as ferramentas abertas, sem salvar. Substitui a frase da D-0091 sobre a seta partir do canto de baixo à esquerda. Origem: pedido do dono, 2026-11-05. |
| D-0100 | **O botão do meio também agarra uma anotação** (a parte em que a anotação não fica selecionada foi substituída pela D-0103) | Em qualquer ferramenta, o botão do meio sobre uma anotação faz o mesmo que o botão direito: agarra e move. Num lugar sem anotação, continua a mover a imagem ampliada. Fora do Selecionar, a anotação agarrada não fica selecionada ao soltar, porque as alças só funcionam no Selecionar (F-0082). Origem: pedido do dono, 2026-11-05. |
| D-0105 | **Texto de 12 a 400, e o arraste muda o tamanho da ferramenta** | O − e o + do texto andam em 20 passos, de 12 a 400 (`ANN_TEXT_SIZES`), a partir do tamanho que estiver, mesmo fora dos passos. O arraste das alças de um texto vai de 8 a 400, e o tamanho novo vale para a ferramenta Texto: aparece na bandeja e no próximo texto, como a cor de uma anotação selecionada já valia para a ferramenta. Antes: de 14 a 48 nos passos e de 8 a 96 no arraste. Origem: pedido do dono, 2026-11-06. |
| D-0104 | **Cada ferramenta guarda a sua espessura; o marca-texto, a sua cor** | O desenho livre, o retângulo, o círculo e a seta começam um passo acima, com 4 px; o marca-texto fica nos 12 px. Cada ferramenta guarda o seu passo (`annSizeByTool`), e a bandeja mostra o dela; antes, um passo só valia para todas. O marca-texto começa no amarelo e guarda a sua cor; as outras ferramentas dividem a delas (`annColorBy`). Origem: pedido do dono, 2026-11-06. |
| D-0103 | **O botão direito e o do meio selecionam** | Sobre uma anotação, em qualquer ferramenta menos o Recortar, o botão direito ou o do meio a selecionam, com as alças e o ✕, e já podem arrastá-la. A barra passa ao Selecionar e guarda a ferramenta de antes em `annTempSelectFrom`; um clique fora das anotações, ou apagar a anotação com o ✕ ou o Delete, volta a ela sem desenhar. Escolher outra ferramenta na barra esquece a de antes. Substitui a parte da D-0100 e do F-0082 em que a anotação não ficava selecionada ao soltar. Origem: pedido do dono, 2026-11-06. |
| D-0102 | **As opções de uma ferramenta sobem acima dela** | Todas as ferramentas que desenham têm um ponto logo acima do botão, do lado de fora. Com as opções abertas, o ponto fica na cor primária, no meio do vão, e faz a ligação entre a ferramenta e a bandeja, sem bico. Um duplo clique, ou o botão apertado por 1 s, abre as opções numa bandeja escura logo acima, lado a lado como a barra, sempre na mesma ordem, com a primeira em cima da ferramenta: uma opção nunca muda de lugar, em botões padrão do editor, do mesmo tamanho, cada um com um tooltip curto; pelo teclado, a seta para cima abre e as setas para os lados andam entre elas. Os ícones reaproveitam os da barra: o quadrado e o círculo vazios e cheios, o quadrado meio cheio para «Translúcido», e o B e o I. Substitui os modos da barra do texto e do marca-texto, com o botão ←: a barra não muda mais de forma. O retângulo e o círculo ganham «Contorno» e «Preenchido». Toda bandeja termina com o tamanho: − e + soltos, sem caixa, e o tamanho atual depois deles (um ponto que cresce por passo, ou o número do texto); a caixa fica só nas opções, que são uma escolha, e os sinais soltos só ajustam um valor. O desenho livre e a seta têm uma bandeja só com o tamanho. O − e o + da barra ficam. Origem: pedido do dono, 2026-11-05. |
| D-0101 | **Ctrl (Cmd no Mac): o Selecionar por um momento** | Com o Ctrl apertado, o clique esquerdo em qualquer ferramenta, menos o Recortar, vai para o Selecionar: seleciona, move e redimensiona pelas alças. A seleção fica enquanto a tecla está apertada e some ao soltar, para não deixar alças que a ferramenta atual não usa. Enquanto isso, o botão Selecionar fica aceso no lugar da ferramenta, como ao agarrar com o botão direito ou o do meio. Origem: pedido do dono, 2026-11-05. |
| D-0098 | **Os botões secundários do visualizador seguem a regra das ferramentas do editor** | «Download» e «Restaurar» têm a classe `.btn-viewer`, que entra nas mesmas duas regras de `#img-modal-overlay .ann-btn` (normal e `:hover`), com os tokens `--color-viewer-control*`. Uma mudança nessas cores muda os dois. «Editar» segue só o `.btn-send`, como «.pdf» e «.zip». Os três medem 120 × 36 px. Antes, uma regra própria do «Download» nunca valia, por causa do `style` inline (F-0080). Origem: pedido do dono, 2026-11-05. |
| D-0096 | **Identificação: «Maiúsculas» ou texto livre** | `TOKEN_ID_UPPERCASE` (padrão `true`, interruptor «Maiúsculas» no Visual Builder, aba Histórico). Ligado, o próprio valor dos dois campos vira maiúsculas ao digitar, com `toLocaleUpperCase('pt')`, sem mexer no cursor e fora de uma composição; uma sessão antiga aberta tem o valor convertido. Desligado, o texto e o nome da sessão ficam como foram digitados. O placeholder mostra o rótulo como foi escrito: o CSS deixou de usar `text-transform`. Antes, o valor só parecia maiúsculo. Origem: pedido do dono, 2026-11-04 e 2026-11-05. |
| D-0091 | **O GIF do editor é refeito com o editor** (as frases sobre onde a seta parte e sobre o visualizador depois de salvar foram substituídas pela D-0099) | O GIF de destaque do README §6.3 (`docs/images/annotation-arrow.gif`) mostra o editor, a barra de ferramentas e o visualizador depois de salvar. Uma mudança numa dessas partes grava o GIF de novo no mesmo commit, com o `gif.py` do repositório dos prompts (preparo `capture-engine-editor-arrow`), e confere com `--verificar`. A seta parte do canto de baixo à esquerda. Assim, o cursor atravessa a barra pelo vão entre Selecionar e Girar 90°. Por cima de um botão, o efeito de passar o mouse mudaria de uma gravação para outra. Fecha a P-0001. Origem: plano dos pendentes, 2026-11-02. |

### Pendentes

O que ficou para depois, com o ID e a origem.

| ID | O quê | Origem |
|---|---|---|
| F-0073 | O Safari continua marcado como não testado em «Requisitos». Fecha com a lista de teste no iPhone, feita pelo dono na página publicada da 28.7.0. | Auditoria de 2026-11-04 |
| F-0074 | Frases com mais de 30 palavras no `AGENTS.md` (7 a 8, contagem automática). | Auditoria de 2026-11-04 |
| F-0089 | Uma seta curta, de cerca de 30 px, não se move pelo meio no Selecionar: as alças das pontas cobrem a seta inteira, e o arraste pega a da ponta. Correção pensada: a alça mais próxima, com o raio limitado a um terço do comprimento. | Auditoria de 2026-11-06 |
| F-0090 | As ferramentas com opções dizem `aria-haspopup="true"` (um menu), mas a bandeja é um grupo; e nenhuma ferramenta tem `aria-pressed`, então o leitor de tela não ouve qual está ativa. | Auditoria de 2026-11-06 |

### IDs

Os IDs novos seguem o formato `D-0001` (decisão), `P-0001` (pendente que não veio de uma auditoria) e `F-0001` (achado de auditoria). O ID vai no fim do título do commit, entre parênteses. Os IDs antigos ficam como estão:

| Formato | O que é | Onde aparece |
|---|---|---|
| `D1`–`D8` | Decisões do proprietário | Esta seção |
| `D9`–`D76` | Entradas do changelog: correções, triagens e registros. O `D9` é o commit `a5656f5` (guarda de blob nos «Removidos» e aviso de IndexedDB indisponível) | `CHANGELOG.md` e títulos de commit |
| `M1`–`M6`, `M-1`, `B8`, `B-1`–`B-3` | Achados das auditorias externas da V26 | `CHANGELOG.md`, entrada `[V26]` |
| `G1`–`G3` | Gerações sucessivas do Export Admin num teste do Export User | `CHANGELOG.md`, entrada `[V26]` |
| `V7`–`V27` | Versões anteriores ao SemVer | `CHANGELOG.md` e tags `v1` a `v27` |
| `A-01`–`A-03`, `O-01`–`O-02` | Achados (`A-`) e observações (`O-`) da auditoria de regressão de 2026-11-02. Os `A-` e a `O-02` foram corrigidos na 28.6.5; a `O-01` ficou como está. Não contam para a numeração de `F-` | `CHANGELOG.md`, entrada `[28.6.5]`, e títulos de commit |

Os IDs antigos contam para a numeração da mesma letra: depois do `D76`, a decisão seguinte foi a `D-0077`.

---

## 14. Disaster recovery técnico

**Modelo de armazenamento (confirmado por bateria de testes — Windows 11 25H2, Edge 148, Chrome 148):**

A base de dados é aberta com `indexedDB.open('CaptureEngineDB', 2)` — **sem nome de arquivo nem caminho**. No Windows com Edge/Chrome, todos os arquivos `file://` compartilham a mesma *origin*, por isso a base é, na prática, **compartilhada por perfil de navegador**. Consequências confirmadas:

| Condição | Encontra os dados? |
| --- | --- |
| Mesmo perfil, qualquer arquivo/pasta/disco | **SIM** |
| Arquivo renomeado | **SIM** |
| Versão/produto diferente (ex.: "Evidence Collector" V1/V2 vê sessões da "Capture Engine" V3) | **SIM** — todos usam `CaptureEngineDB` |
| Caminho com espaços/caracteres especiais | **SIM** |
| ZIP extraído para pasta | **SIM** |
| Abrir de dentro do ZIP (sem extrair) | **NÃO** |
| Janela anônima/privada | **NÃO** |
| Outro perfil do navegador | **NÃO** |
| Outro navegador (Edge ↔ Chrome) | **NÃO** |
| Mesma conta/perfil **em outra máquina** (sync ligado) | **NÃO** — IndexedDB não é sincronizado |

> **Âmbito dos testes:** esta matriz foi confirmada no Windows 11, com o Edge 148 e o Chrome 148. O Firefox 151.0.4 foi testado à mão, com o mesmo resultado na recuperação; o Safari não foi testado. A matriz por navegador é a do README §13, que é o dono dela.

**Pontos-chave:**
- O que decide o acesso é o **perfil de navegador**, não o nome/pasta/versão do arquivo.
- Os dados são **locais à máquina**. O sync do Chrome leva favoritos/senhas, mas **não** o IndexedDB (confirmado por teste: conta sincronizada em outro PC → histórico vazio).
- **Isolamento por ambiente:** dentro de uma VDI (perfil próprio e isolado), as sessões ficam contidas nessa VDI. Fora das VDIs, no perfil local pessoal, todas as sessões compartilham a mesma base. *Ambientes com roaming de perfil gerenciados pela TI poderiam alterar isto (os dados seguiriam o usuário) — não confirmado, depende da infraestrutura.*

**Recuperação prática:** se o `capture-engine.html` for apagado, basta abrir **qualquer** cópia da ferramenta no **mesmo perfil do mesmo navegador** — as sessões reaparecem. Nome e pasta são irrelevantes.

**Extração de Emergência (DevTools):** se a lógica do HTML estiver inoperável e for preciso extrair os dados puros:

1. Abra qualquer cópia da ferramenta no perfil correto e pressione **F12** (DevTools).
2. Navegue até **Application** (Chrome/Edge) ou **Storage** (Firefox) → **IndexedDB** → **CaptureEngineDB**.
3. Clique em **`images`** ou **`documents`** para ver os registros. Cada linha é um item.
4. Para exportar um arquivo individual:
   - Clique no registro pretendido para o expandir.
   - Localize o campo **`blob`** — aparece como `Blob {size: XXXXX, type: "image/png"}`.
   - Clique com o botão direito no valor do blob → **"Save as..."** (Chrome/Edge) ou copie via console (ver abaixo).
5. Se a opção "Save as" não estiver disponível, use o console (tab **Console**):
   ```js
   // Substituir 'images' pelo nome da store e o ID pelo valor real
   const req = indexedDB.open('CaptureEngineDB', 2);
   req.onsuccess = e => {
     const db = e.target.result;
     const tx = db.transaction('images', 'readonly');
     const store = tx.objectStore('images');
     store.getAll().onsuccess = ev => {
       ev.target.result.forEach((item, i) => {
         // item.blob e' a imagem COMO ESTA: se foi anotada, girada ou recortada,
         // e' o PNG regenerado pelo ann-save. item.origBlob so existe quando houve
         // edicao, e guarda o original intacto. Extrair ambos — este procedimento
         // e' o recurso para obter os dados puros, e o puro e' o origBlob. Ver D55.
         // Documento: o name ja traz a extensao. Imagem: a extensao vem do tipo do blob.
         const ext = b => ({ 'image/png': '.png', 'image/jpeg': '.jpg', 'image/gif': '.gif', 'image/webp': '.webp' })[b.type] || '';
         const base = item.name || item.label || 'imagem-' + i;
         const saidas = [[item.blob, base]];
         if (item.origBlob) saidas.push([item.origBlob, base + '-ORIGINAL']);
         saidas.forEach(([blob, nome]) => {
           const a = document.createElement('a');
           a.href = URL.createObjectURL(blob);
           a.download = item.name ? nome : nome + ext(blob);
           a.click();
         });
       });
     };
   };
   ```
   Este script faz download de todas as imagens da store, cada uma com a extensão do seu formato. Para documentos, troque `'images'` por `'documents'` nas duas linhas da transação: o nome sai como foi gravado (ex.: `relatorio.pdf`).

**Diagnosticar quota esgotada** (confirmar o uso real quando o banner vermelho de armazenamento aparece — ver `§6`; a interface **avisa**, ao contrário do que esta seção afirmava até a V26):
```js
// No console (F12 -> Console):
navigator.storage.estimate().then(e =>
  console.log(
    'Usado:', (e.usage / 1024 / 1024).toFixed(1) + ' MB',
    '| Disponivel:', (e.quota / 1024 / 1024).toFixed(1) + ' MB',
    '| Uso:', ((e.usage / e.quota) * 100).toFixed(1) + '%'
  )
);
```
Acima de 80 % de uso, a quota pode causar falhas na gravação. **Solução:** exporte (PDF ou ZIP) e apague as sessões antigas no histórico.

**Listar sessões com nome, usuário e data** (para saber qual sessão extrair com o script abaixo):
```js
const req = indexedDB.open('CaptureEngineDB', 2);
req.onsuccess = e => {
  const db = e.target.result;
  db.transaction('sessions', 'readonly')
    .objectStore('sessions')
    .getAll().onsuccess = ev => {
      ev.target.result.forEach(s =>
        console.log(
          'ID:', s.id,
          '| Nome:', s.name || '(sem nome)',
          '| User:', s.user || '-',
          '| Criado:', new Date(s.createdAt).toLocaleString()
        )
      );
    };
};
```

**Extrair imagens de uma sessão específica** (com o ID obtido no script acima):
```js
const SESSION_ID = 'COLE_O_ID_AQUI'; // ID do console.log acima
const req2 = indexedDB.open('CaptureEngineDB', 2);
req2.onsuccess = e => {
  const db = e.target.result;
  const idx = db.transaction('images', 'readonly')
    .objectStore('images').index('sessionId');
  idx.getAll(SESSION_ID).onsuccess = ev => {
    ev.target.result.forEach((item, i) => {
      // item.blob e' a imagem COMO ESTA: se foi anotada, girada ou recortada,
      // e' o PNG regenerado pelo ann-save. item.origBlob so existe quando houve
      // edicao, e guarda o original intacto. Extrair ambos — este procedimento
      // e' o recurso para obter os dados puros, e o puro e' o origBlob. Ver D55.
      const ext = b => ({ 'image/png': '.png', 'image/jpeg': '.jpg', 'image/gif': '.gif', 'image/webp': '.webp' })[b.type] || '';
      const base = item.label || 'imagem-' + i;
      const saidas = [[item.blob, base]];
      if (item.origBlob) saidas.push([item.origBlob, base + '-ORIGINAL']);
      saidas.forEach(([blob, nome]) => {
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = nome + ext(blob);
        a.click();
      });
    });
  };
};
```


> **Nota:** A única salvaguarda confiável é **exportar (PDF/ZIP)** o material importante. Não existe backup automático dos dados — é uma decisão de design (privacidade), não uma falha.
