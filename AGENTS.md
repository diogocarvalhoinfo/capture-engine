# Regras para agentes

Regras para quem edita este projeto, pessoa ou IA, com a decisão de cada uma.

Toda mudança no `capture-engine.html` preserva os marcadores do Quine e passa no `validate.sh`, com 0 FAIL, antes do commit.

## 1. Donos dos fatos

| Fato | Dono |
|---|---|
| A versão do produto | o topo do [`CHANGELOG.md`](CHANGELOG.md) |
| O uso, o comportamento visível e as limitações | o [`README.md`](README.md) |
| A árvore de arquivos e os diagramas da arquitetura | o README, seções "Estrutura de arquivos" e "Arquitetura" |
| Os valores visuais e os `TOKEN_*` | o `capture-engine.html`; o [`design-tokens.md`](design-tokens.md) é uma cópia verificada |
| As verificações antes do commit | o [`validate.sh`](validate.sh); cada check está descrito no comentário dele |
| Os testes dos fluxos críticos | o `fluxos/capture-engine.py` do repositório de referência (D-0177) |
| O ícone de cada conceito | o `icones.md` do repositório de referência |
| O armazenamento do navegador, as regras, as decisões e os pendentes | este arquivo |

**Quem lê o README:** quem usa a ferramenta e quem a administra. Por isso, o README segue a regra do texto para quem usa: a palavra em português vem primeiro. (D-0175)

## 2. O que muda junto

**Cópias verificadas.** Estes fatos aparecem em dois lugares, e um check do `validate.sh` compara as duas cópias. Os números são os da lista dos comentários do `validate.sh`.

| Cópia | Dono | Check |
|---|---|---|
| Tabelas do `design-tokens.md` (tokens CSS e padrões dos `TOKEN_*`) | `capture-engine.html` | 11, 23, 24 e 29 |
| Linha "Versão" do README e as 3 referências de versão do HTML | `CHANGELOG.md` | 8 e 8b |
| Linha das ferramentas de anotação no README ("O editor tem N ferramentas") | `capture-engine.html` | 12 |
| Fecho do README, aviso de autoria do topo do HTML e linha de copyright do `LICENSE` | um ao outro | 35 |
| Imagens, GIF, cartões e diagramas do README | os dados nos comentários do README | 34 |

**Mudam no mesmo commit:**
- **Um `TOKEN_*` novo:** a declaração `const TOKEN_X = 'valor'`, o campo do Visual Builder, a sincronização em `initVbSync()` e `applyTokens()`, a linha da seção 6 do `design-tokens.md` e, se quem administra o vê, a aba no README.
- **Uma ferramenta de anotação nova:** o botão fora dos blocos `ADMIN_*`, o registro em `annSizeByTool`, `annColorKey`, `annShiftKind` e `annDrawShape`, e a linha das ferramentas no README.
- **Uma parte nova do código ou uma gravação nova no IndexedDB:** a árvore e o diagrama de componentes da seção "Arquitetura" do README, gerado pelo `diagramas.py`.
- **Uma função nova chamada pelo `init()` ou pelo `boot()`:** a árvore "Como os componentes se ligam", na seção "Arquitetura" do README.
- **Uma tela que muda:** a imagem anotada ou o GIF que a mostram, gerados de novo pelo `gerar.py` ou pelo `gif.py`.
- **Um check numerado novo no `validate.sh`:** o `CHECKS_NUMERADOS` do script e a contagem na seção 3, "Validação", deste arquivo.
- **A versão:** os 4 lugares da seção 5, "Fechar uma versão".

## 3. Regras

### Arquivo único e sem internet

- Escreva todo o JavaScript, o CSS e os ícones dentro do `capture-engine.html`, sem CDN, fonte externa nem `fetch` para fora; o único `fetch` é o `fetch(location.href)` do Quine. (D-0176)
- Ao acrescentar um recurso, embuta-o, e não relaxe a CSP. A CSP recusa primeiro, e o sintoma aparece no console, não na tela. (D-0176)
- Não aperte o `connect-src 'self'` da CSP. Sem ele, o `fetch` do Quine falha em silêncio, e a cópia exportada sai do `BOOT_HTML`, desatualizada. (D-0176)
- Não use `eval()`, `Function()` nem `document.write()`. (D-0176)
- Edite em trechos, sem reescrever o arquivo inteiro, em UTF-8 sem BOM, com a formatação automática desligada para `.html`. Um formatador corrompe os marcadores do Quine. (D-0176)
- Teste no navegador um perfil sem extensões. Uma extensão que muda a página entra no `BOOT_HTML`. (D-0176)

<details>
<summary>A CSP e o que cada diretiva impõe</summary>

```html
<meta http-equiv="Content-Security-Policy"
  content="default-src 'self' blob: data:; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src blob: data:; connect-src 'self';">
```

| Diretiva | O que impõe |
|---|---|
| `default-src 'self' blob: data:` | Vale para os tipos sem diretiva própria (`font-src`, `media-src`, `frame-src`). |
| `script-src 'unsafe-inline'` | Permite o JavaScript embutido, que um arquivo único precisa. Sem `'self'`, um `<script src>` de fora não carrega. Os nonces e os hashes não servem: o Quine muda o arquivo a cada exportação. |
| `style-src 'unsafe-inline'` | O mesmo para o CSS. |
| `img-src blob: data:` | As capturas vivem como `blob:` e `data:`; uma `<img src="https://…">` é bloqueada. |
| `connect-src 'self'` | Mantém o `fetch(location.href)` do Quine. |

Os scanners de segurança marcam o `unsafe-inline` como aviso. No arquivo único, é a única forma de o script da própria aplicação executar.

</details>

### Quine

- Preserve os 11 marcadores do Quine: `grep -c "ADMIN_BUTTONS_START\|ADMIN_BUTTONS_END\|ADMIN_EDIT_START\|ADMIN_EDIT_END\|ADMIN_JS_START\|ADMIN_JS_END\|EXPORT MODAL\|FIM EXPORT MODAL" capture-engine.html` devolve 11. São 8 textos, em 4 pares, mais uma linha em `boot()`, uma em `sanitizeForQuine()` e uma em `exportFile()`. (D-0176)
- Não ponha nos blocos `ADMIN_*` o que quem usa precisa: a cópia "User" os remove. (D-0176)
- Não mova `window.exportFile()`, `capturePristine()`, `sanitizeForQuine()` nem o `BOOT_HTML` para fora do bloco `ADMIN_JS`. (D-0176)
- Declare cada token como `const TOKEN_X = 'valor'`, com aspas simples, sem `let` nem template literal: a regex do Quine casa só essa forma. (D-0176)
- Em uma regex nova que lê o valor de um token, use `'(?:[^'\\]|\\.)*'`, e nunca `'[^']*'`. A forma curta para no primeiro apóstrofo escapado e quebra a cópia da segunda geração. (D40)
- Passe os valores dos tokens por `sanitizeForQuine()` antes de os gravar na cópia. Ela põe um espaço de largura zero nos 8 marcadores e escapa o apóstrofo. (D-0176)
- Teste o Quine com um servidor que entrega o arquivo sem mudança, como o `python -m http.server`. Um servidor que gera o HTML faz a cópia sair do que ele devolveu. (D-0176)
- Por `file://`, o `fetch` falha e a cópia sai do `BOOT_HTML`, serializado de novo pelo navegador. Por `http(s)`, a cópia "Administrador" sai igual ao arquivo, byte a byte. Ao registrar um teste, diga o protocolo. (D-0176)

### Segurança

- Passe todo dado do usuário por `escapeHTML()` antes de um `innerHTML`: nome de sessão, legenda, nome de documento, conteúdo colado. Um texto colado de um chamado pode trazer HTML de um cliente. (D-0176)
- Monte o conteúdo de fora exibido como HTML (Markdown, CSV, HTML) no visualizador isolado, sem acesso aos dados do app nem à internet. (D-0176)

### Nomes

- Crie cada id com `genId(prefixo)`: `{prefixo}_{Date.now()}_{5 caracteres base36}`. (D26)
- Evite nomes repetidos na sessão contra as duas listas, a ativa e a dos "Removidos", sem diferenciar maiúsculas. Incremente o número do fim (`imagem-1` → `imagem-2`), e nunca crie `imagem-1-1`; um nome sem número ganha `-1`. (D26)
- Ao renomear um documento, mantenha a extensão original. (D26)
- O número de uma sessão sem nome (`#0001`) é a posição dela entre as que existem e muda quando uma mais antiga é apagada. Não o use como referência fora da ferramenta. (D-0176)

### Sessões

- Comece uma sessão nova a cada abertura. Na tela de toque, o `reopenLastSession()` volta à última, e "Atualizar" começa outra. (D-0113)
- Crie a sessão só no `ensureSession()`, na primeira interação. Nunca a crie no `deleteSessionId()`: quem apaga a última sessão escolhe a tela vazia. (D7)
- Ao apagar a sessão ativa, guarde a vizinha antes de apagar e abra-a depois; sem vizinha, limpe a tela sem criar sessão. (D7)
- Grave na hora a digitação em "Quem" e "O que", sem esperar os 5 segundos do `setInterval`. (D3)

### Código

- Mantenha o script em uma IIFE com `'use strict'`. Uma função chamada por um `onclick` do HTML fica em `window`. (D-0176)
- Escreva no console só pelo `SysLogger`. O `info` e o `warn` só aparecem com `TOKEN_DEBUG_MODE`; o `error` aparece sempre, por isso use-o só para falhas reais. (D-0176)
- Use só Pointer Events, e não `mousedown` nem `touchstart`. (D-0176)
- Escreva os comentários do código em inglês e sem apóstrofos. A heurística de complexidade do `validate.sh` lê os comentários, e um apóstrofo abre uma string falsa e corrompe a contagem. (D-0085, D54)
- No editor, guarde o passo de desfazer com `annPushUndo()`, até 50 passos, e não com `getImageData`. (D-0176)

### CSS e tema

- Escreva os tamanhos de fonte, os espaços e os cortes do layout em `rem`, pelos tokens `--text-*` e `calc(var(--spacing) * n)`. Bordas, alturas, larguras e ícones podem ficar em `px`. (D-0082)
- Em telas grandes, a interface cresce com `zoom: var(--app-zoom)` no `html`. Uma medida em `vw` ou `vh` divide-se por `var(--app-zoom)`, e uma posição medida na tela que vai para um estilo em `px` divide-se por `uiZoom()`. (D-0082)
- Ligue o tema escuro pela classe `dark` no `<html>`, e não por `@media (prefers-color-scheme)` no CSS. Só o JavaScript lê a preferência do sistema, na primeira abertura. O bloco `html.dark` só redefine tokens. (D-0176)
- Use um token `--z-*`, na escala do Bootstrap, em cada `z-index`. (D-0176)

### Idioma

- **Documentação** (README, `AGENTS.md`, `CHANGELOG.md`, `design-tokens.md`, commits): português neutro, com a tabela de palavras dos prompts. Um termo da interface aparece como está, entre aspas retas ("User").
- **Interface:** português neutro, porque a ferramenta serve equipes de qualquer país de língua portuguesa. (D-0176)
- **Código:** inglês, nos ids, classes, tokens, variáveis, funções e comentários. (D-0085)
- **Palavras de propósito na interface:**
  - "Quem" e "O que" são os rótulos padrão da identificação. (D-0107)
  - "User" fica só como nome da cópia "User" e da opção do botão de exportar. (D-0176)
  - "Histórico", e não "Sessões", e "Primeiro campo" e "Segundo campo" no Visual Builder. (D-0176)

### Versões e changelog

- Escreva o `CHANGELOG.md` no [Keep a Changelog 1.1.0](https://keepachangelog.com/pt-BR/1.1.0/), com as categorias Adicionado, Modificado, Obsoleto, Removido, Corrigido e Segurança, nessa ordem e só as que têm entradas. As entradas `[V7]` a `[V27]` usam outras categorias e ficam como estão. (D-0078)
- Numere as versões em SemVer desde a 28.0.0. Major é quando quem distribui precisa refazer algo: um `TOKEN_*`, o formato da exportação, o schema do IndexedDB. Minor é uma funcionalidade nova, e patch, uma correção. As tags `v1` a `v27` ficam; as novas são leves e chamam-se `vX.Y.Z`. (D-0078)

### Validação

- Execute `bash validate.sh` antes de cada commit; precisa dar 0 FAIL. No Windows, use o Git Bash ou o WSL. O `--rapido` pula os testes de fluxo. (D-0084)
- O `validate.sh` executa 35 verificações mecânicas: 32 com regex, grep ou Python, uma com o stylelint, uma com os geradores do README e uma com os testes de fluxo nos navegadores. Os checks 32 a 34 usam o clone do repositório de referência; sem ele, não executam. Os números dos comentários do script não são os de uma lista antiga deste arquivo; cite o check pelo comentário. (D69)
- Leia o `[WARN]` de complexidade como o mapa de onde uma edição quebra mais fácil, e não como defeito. Antes de editar uma dessas funções, leia a regra do motor dela. (D-0092)
- Teste no navegador o que a mudança toca, com o Playwright ou à mão. (D-0084)
- O check do Export User (o `validate.sh` simula a cópia "User") só cobre o código síncrono; não substitui o teste da seção 5. (D25)
- Depois de editar o motor de anotação, confira no código:
  - o `annTextClickTimer` e o `annSmoothLast` declarados no escopo do módulo, e zerados no `annDeactivate()`;
  - o `annDrawShape` sem efeitos colaterais (sem `annIsDirty` nem DOM), com `textBaseline='top'` e o texto desenhado linha a linha, com `ANN_TEXT_LINE_RATIO`;
  - o `closeSettingsModal` chamando o `window._deactivateAdmin()`, atribuído no `initAdminGate`.

## 4. Armazenamento do navegador

### IndexedDB

**Nome da base de dados:** `CaptureEngineDB`

> [!NOTE]
> **A base é por origem.**
> O IndexedDB é separado por origem: protocolo, host e porta. A mesma `CaptureEngineDB` aberta por `file://`, `http://localhost:8080` e `https://<user>.github.io` são três bases isoladas, mesmo no mesmo perfil. Dentro de `file://`, o caminho do arquivo não muda a origem. Por isso, a ferramenta publicada e o arquivo local têm históricos separados.
**Versão do schema:** `3` (`DB_VERSION`), desde a 29.0.0 (D-0127).

- **O que a versão 3 muda:** nenhum dado guardado. Ela marca que um registro de `images` pode ter um PDF (`kind`) e imagens coladas no editor (`annBlobs`), que uma 28.x leria errado. Por isso uma cópia 28.x não abre mais a base.
- **O que uma cópia 28.x faz depois:** o `open` com a versão 2 falha (`VersionError`), e aparece a faixa "Armazenamento indisponível". O Histórico fica vazio, e uma captura nova fica "Só nesta aba". Ela não lê nem apaga nada; a 29 reaberta mostra tudo como estava. Medido no Chrome 156, com a cópia exportada da 28.7.3.
- **Aba antiga aberta:** se uma aba 28.x está aberta quando a 29 abre, a atualização espera, e a 29 mostra a faixa "Feche as outras abas". Ao fechar a aba antiga, a atualização termina, e a faixa some. Uma aba aberta quando uma versão futura atualizar a base fecha a conexão e pede para recarregar (`onversionchange`).
- **Caminho de volta:** não há como voltar a base para a versão 2. Para voltar a uma 28.x, exporte antes as sessões na 29, em PDF ou ZIP. Depois, apague os dados do site no navegador e abra a 28.x, que começa vazia.

> [!IMPORTANT]
> **Mudar uma tabela que já existe pede migração.**
> O `onupgradeneeded` usa `if (!db.objectStoreNames.contains(...))`, e acrescentar uma tabela nova é seguro. Mudar os campos de uma tabela que existe não é: o `onupgradeneeded` não executa para quem já está no `DB_VERSION` atual. Suba o `DB_VERSION` e escreva a migração dentro do `onupgradeneeded`.

### Como migrar o schema em segurança

**Caso A — Adicionar uma nova object store (seguro, sem migração destrutiva)**

Incrementar a versão e adicionar a store com `contains` guard — usuários existentes passam pelo `onupgradeneeded` e recebem a nova store; stores existentes e dados não são tocados:

```js
// Alterar: indexedDB.open('CaptureEngineDB', 3)  →  indexedDB.open('CaptureEngineDB', 4)
const r = indexedDB.open('CaptureEngineDB', 4);
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
// Alterar: indexedDB.open('CaptureEngineDB', 3)  →  indexedDB.open('CaptureEngineDB', 4)
const r = indexedDB.open('CaptureEngineDB', 4);
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
| `id` | string | sim | ID único gerado por `genId('sess')` — chave primária |
| `name` | string | não | Nome da sessão derivado de `session-user` + `session-pc` (maiúsculas, separados por `-`, via initSessionSync). Ambos vazios = usa fallback #XXXX |
| `user` | string | não | Valor do primeiro campo (ex: "João Silva") |
| `pc` | string | não | Valor do segundo campo (ex: "PC-001") |
| `createdAt` | number | sim | Timestamp Unix (ms) da criação — imutável após criação |
| `updatedAt` | number | sim | Timestamp Unix (ms) da última atividade — atualizado a cada save |

### Tabela: `images`

Índices: `sessionId`, `order`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | sim | ID único gerado por `genId('img')` — chave primária |
| `sessionId` | string | sim | ID da sessão a que pertence |
| `blob` | Blob | sim | Dados binários da imagem (PNG, JPEG, WEBP, GIF) |
| `label` | string | sim | Nome/legenda da imagem (ex: `imagem-1`) — único dentro da sessão |
| `defLabel` | string | não | O nome que a imagem recebeu ao entrar: `imagem-N`, ou o nome do arquivo de um PDF. Um nome apagado volta a ele (D-0161). Imagens anteriores à 29.7.0 não o têm e recebem o primeiro `imagem-N` livre |
| `order` | number | sim | Posição na grade — define a ordem de exibição e export. **Único, mas não necessariamente contíguo.** Novos valores vêm de `nextOrder(arr)` = `max(order)+1`, nunca de `arr.length`: `delImg`/`delDoc` não renumeram os restantes, por isso o `length` colidiria com um `order` existente (ver D45). As lacunas são normais e desaparecem no primeiro reordenamento, que renumera densamente |
| `addedAt` | number | sim | Timestamp Unix (ms) de quando foi capturada |
| `origBlob` | Blob | não | Imagem **original** antes da anotação. Criada por `ann-save` na primeira vez que se confirma uma anotação; usada por `annActivate` como fundo do canvas ao reeditar. Removida (e `blob` reposto ao original) se todas as anotações forem apagadas **e não houver redo pendente** (`annRedoStack` vazio). Presente apenas em imagens anotadas. |
| `annHistory` | array | não | Stack de formas anotadas (`{type, x1, y1, ...}`; um traço do marca-texto é `{type: 'free', hl: 'soft' \| 'solid', pts, ...}`) persistida com a imagem para reedição posterior (anotação **não-destrutiva**). Presente apenas em imagens anotadas; removida quando fica vazia. |
| `annBlobs` | object | não | As imagens coladas no editor (D-0133), `{ id: Blob }`. A anotação `{ type: 'image', id, x1, y1, x2, y2, ar, rot }` guarda só o `id`. **Motivo:** as pilhas de desfazer copiam o estado em JSON, até 50 vezes. O "Aplicar alterações" grava só os blobs que o `annHistory` ou o `annRedoStack` ainda usam (`annKeepBlobs`). Presente apenas em imagens com uma imagem colada. |
| `annRedoStack` | array | não | Pilha de **refazer** persistida: snapshots `{h, rot, crop, pcrop}` (até `ANN_HISTORY_MAX` = 50) para que o redo sobreviva a salvar+reabrir. Restaurada por `annActivate`, gravada por `ann-save`. Invalidada (gravada vazia) por qualquer nova mutação via `annCommitUndo`. Presente apenas em imagens anotadas com redo pendente. **Limitação:** redo que atravessa rotação/crop é aproximado — a semeadura do undo achata `rot`/`crop`. |
| `rotation` | number | não | Rotação acumulada em graus (`0`, `90`, `180`, `270`). Aplicada ao bitmap de exibição mas não ao `origBlob` — o original permanece intacto. Removida se igual a `0` e sem outras modificações. |
| `cropBox` | object | não | Área de recorte ativa: `{x, y, w, h}` em pixels relativos ao `origBlob`. Não-destrutivo — o `origBlob` nunca é cortado. Removido se o crop cobrir a imagem inteira. |
| `firstBlob` | Blob | não | A foto como foi capturada, guardada quando os Cantos livres ou o Endireitar gravam na foto (D-0138). O Desfazer do editor chega a ela (D-0140). "Aplicar alterações" nela a devolve ao `origBlob` e apaga o campo. Presente apenas em fotos com perspectiva desfeita ou endireitadas. |
| `kind` | string | não | `'pdf'` em um PDF que a pessoa arrastou de Documentos para Imagens (D-0132). O `blob` é o PDF como estava, com o tipo `application/pdf`, e o `label` é o nome sem ".pdf". Sem anotação, rotação nem recorte. Ausente nas imagens. |

### Tabela: `documents`

Índices: `sessionId`, `order`

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `id` | string | sim | ID único gerado por `genId('doc')` — chave primária |
| `sessionId` | string | sim | ID da sessão a que pertence |
| `blob` | Blob | sim | Dados binários do documento |
| `name` | string | sim | Nome do arquivo com extensão (ex: `relatorio.pdf`) — único dentro da sessão |
| `type` | string | sim | MIME type (ex: `text/plain`, `application/pdf`) |
| `size` | number | sim | Tamanho em bytes |
| `order` | number | sim | Posição na lista (0-based) |
| `addedAt` | number | sim | Timestamp Unix (ms) |

### Tabelas: `removed_images` e `removed_documents`

Mesmos campos das tabelas ativas, com adição de:

| Campo | Tipo | Descrição |
|---|---|---|
| `removedAt` | number | Timestamp Unix (ms) de quando foi movido para os "Removidos" |

**Nota:** a barra "Removidos" **ordena por `removedAt`**, não por `order`. O campo `order` continua presente nos registros movidos para os "Removidos" — `delImg`/`delDoc` fazem `splice` do array e acrescentam `removedAt`, sem apagar o `order` anterior. Até a V26 esta nota dizia que os itens "não têm" o campo; têm, apenas não é usado para os ordenar. O valor antigo é ignorado na restauração, que atribui uma ordem nova.

### Chaves do localStorage

O sistema utiliza localStorage para preferências que devem sobreviver a diferentes abas ou arquivos na mesma origem:
- `theme`: Controla o modo visual. Valores possíveis: `'dark'`, `'light'` ou `null` (neste caso cai para a preferência do OS).
- `hl-solid`: a escolha do marca-texto. `'1'` é "Sólido"; `'0'` ou `null` é "Translúcido", o padrão (D-0095).
- `fill-rect` e `fill-circle`: a escolha do retângulo e do círculo. `'1'` é "Preenchido", `'b'` é "Desfocado"; `'0'` ou `null` é "Contorno", o padrão (D-0102).
- `text-bg`: a escolha do texto. `'1'` é "Com fundo"; `'0'` é "Fundo transparente".
- *Histórico:* A chave `ec_pending_session` foi utilizada em versões antigas e removida na V17.
- `ce-last-session`: o id da última sessão aberta. Em uma tela de toque, a ferramenta volta a ela ao abrir; o botão "Atualizar" apaga a chave antes de recarregar. No computador, a chave é gravada mas não é lida (D-0113).
Limpar o localStorage apenas reseta preferências visuais. Limpar o IndexedDB apaga os dados reais das sessões.

### Auto-save e purge

**Auto-save e Falhas Assíncronas:** `setInterval` de 5 segundos no `boot()` chama `saveSession()` se `isDirty === true`. A função `triggerSave()` é chamada na digitação. Se o navegador for fechado durante a janela de latência ou a transação falhar, as últimas mutações perdem-se.

**Esgotamento de Quota:** Se o limite de disco do navegador for atingido, a gravação de novos blobs falha nativamente. `idbTx` e `idbDelBatch` inspecionam o erro da transação e também o erro que o `put` ou o `delete` lança na hora. Em um `QuotaExceededError`, e só nele, chamam `showQuotaBanner()`, que injeta um aviso vermelho fixo no topo (`id="ce-quota-banner"`, camada `--z-toast`). O aviso é criado em runtime e **não** está no HTML estático. Diz que as capturas deixaram de ser gravadas e recomenda exportar já. Tem um botão ✕, e volta na falha seguinte, porque a guarda testa se o elemento existe. `SysLogger.error` registra a exceção no console em qualquer caso. A sessão já salva e os itens antigos permanecem íntegros no DB.

> **Correção histórica:** até a V26 esta seção afirmava que "a aplicação falha silenciosamente na interface para não causar pânico de UX". Era falso e contradizia o README. O banner existe desde a correção D9 (commit `a5656f5`).

**Purge:** `purgeExpired()` é chamada uma vez por `init()` (carregamento da página). Sessões fora do prazo de 48h (ou o valor de `TOKEN_AUTO_PURGE_HOURS`) só são removidas na próxima inicialização. Abas mantidas abertas por dias sem recarregar não ativam o purge — a quota do IndexedDB pode esgotar antes da próxima inicialização. Apaga também todos os itens associados (imagens, documentos, removidos das duas categorias).

> **Risco de redistribuição:** Se redistribuir com um valor de `TOKEN_AUTO_PURGE_HOURS` menor do que o anterior (ex: de 48h para 24h), sessões que antes sobreviveriam são purgadas na próxima abertura. O comportamento é correto (o código usa sempre o valor atual do token), mas pode surpreender usuários com sessões em curso. Comunicar a mudança antes de redistribuir.

**Múltiplas instâncias (multi-aba permitido):** O `onblocked` apenas registra um aviso no console — **não** bloqueia a interface. Em versões anteriores mostrava uma tela de erro vermelha que substituía o `body`; esse bloqueio foi removido na V23 (a pedido do proprietário). Várias abas compartilham a mesma base `CaptureEngineDB`; a ressalva conhecida é a gravação concorrente na mesma sessão (a última gravação prevalece). Ver o README, "Limitações conhecidas".

### Recuperar os dados

**Modelo de armazenamento (confirmado por bateria de testes — Windows 11 25H2, Edge 148, Chrome 148):**

A base de dados é aberta com `indexedDB.open('CaptureEngineDB', 3)` — **sem nome de arquivo nem caminho**. No Windows com Edge/Chrome, todos os arquivos `file://` compartilham a mesma *origin*, por isso a base é, na prática, **compartilhada por perfil de navegador**. Consequências confirmadas:

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

> **Âmbito dos testes:** esta matriz foi confirmada no Windows 11, com o Edge 148 e o Chrome 148. O Firefox 151.0.4 foi testado à mão, com o mesmo resultado na recuperação. No Safari do iPhone (iOS 26.5), no site publicado, as sessões voltaram depois de fechar o Safari; o atalho na Tela de Início tem uma base própria. O Safari do Mac não foi testado. As versões testadas estão no changelog.

**Pontos-chave:**
- O que decide o acesso é o **perfil de navegador**, não o nome/pasta/versão do arquivo.
- Os dados são **locais à máquina**. O sync do Chrome leva favoritos/senhas, mas **não** o IndexedDB (confirmado por teste: conta sincronizada em outro PC → histórico vazio).
- **Isolamento por ambiente:** dentro de uma VDI (perfil próprio e isolado), as sessões ficam contidas nessa VDI. Fora das VDIs, no perfil local pessoal, todas as sessões compartilham a mesma base. *Ambientes com roaming de perfil gerenciados pela TI poderiam alterar isto (os dados seguiriam o usuário) — não confirmado, depende da infraestrutura.*

**Recuperação prática:** se o `capture-engine.html` for apagado, abra qualquer cópia da ferramenta no mesmo perfil do mesmo navegador, e as sessões reaparecem. O nome e a pasta não importam.

**Extração de Emergência (DevTools):** se a lógica do HTML estiver inoperável e for preciso extrair os dados puros:

1. Abra qualquer cópia da ferramenta no perfil correto e pressione **F12** (DevTools).
2. Navegue até Application (Chrome e Edge) ou Storage (Firefox), depois IndexedDB e `CaptureEngineDB`.
3. Clique em **`images`** ou **`documents`** para ver os registros. Cada linha é um item.
4. Para exportar um arquivo individual:
   - Clique no registro pretendido para o expandir.
   - Localize o campo **`blob`** — aparece como `Blob {size: XXXXX, type: "image/png"}`.
   - Clique com o botão direito no valor do blob → **"Save as..."** (Chrome/Edge) ou copie via console (ver abaixo).
5. Se a opção "Save as" não estiver disponível, use o console (tab **Console**):
   ```js
   // Substituir 'images' pelo nome da store e o ID pelo valor real
   const req = indexedDB.open('CaptureEngineDB'); // sem número: abre a versão que existir
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

**Diagnosticar quota esgotada** (confirmar o uso real quando o banner vermelho de armazenamento aparece — ver "Auto-save e purge", acima; a interface **avisa**, ao contrário do que esta seção afirmava até a V26):
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
Acima de 80% de uso, a quota pode causar falhas na gravação. **Solução:** exporte (PDF ou ZIP) e apague as sessões antigas no histórico.

**Listar sessões com nome, usuário e data** (para saber qual sessão extrair com o script abaixo):
```js
const req = indexedDB.open('CaptureEngineDB'); // sem número: abre a versão que existir
req.onsuccess = e => {
  const db = e.target.result;
  db.transaction('sessions', 'readonly')
    .objectStore('sessions')
    .getAll().onsuccess = ev => {
      ev.target.result.forEach(s =>
        console.log(
          'ID:', s.id,
          '| Nome:', s.name || '(sem nome)',
          '| Quem:', s.user || '-',
          '| Criado:', new Date(s.createdAt).toLocaleString()
        )
      );
    };
};
```

**Extrair imagens de uma sessão específica** (com o ID obtido no script acima):
```js
const SESSION_ID = 'COLE_O_ID_AQUI'; // ID do console.log acima
const req2 = indexedDB.open('CaptureEngineDB'); // sem número: abre a versão que existir
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

A única proteção é exportar em PDF ou ZIP o que importa: não há cópia de segurança automática.

## 5. Fechar uma versão

1. Troque `## [Unreleased]` por `## [X.Y.Z] - AAAA-MM-DD`.
2. Atualize a versão nas cópias que o `validate.sh` confere: a linha "Versão" do README e, no HTML, o comentário `<!-- VISUAL BUILDER MODAL (X.Y.Z) -->`, o selo `>X.Y.Z</span>` do Visual Builder e o `SysLogger.info('Capture Engine X.Y.Z Ready')`. Gere de novo o `docs/images/admin-mode.png`, que mostra o número da versão, com o `gerar.py`.
3. Execute o `bash validate.sh`, que deve dar 0 FAIL.
4. Faça o teste no navegador da lista abaixo, com o "Teste do Export User", e escreva o resultado na entrada do changelog.
5. Faça o commit `docs(changelog): versão X.Y.Z`.
6. Crie a tag leve `vX.Y.Z` nesse commit.
7. Faça o push e publique a release, os dois com CONFIRMO: `gh release create vX.Y.Z capture-engine.html --title "X.Y.Z" --notes-file <resumo da entrada>`. As notas são o parágrafo de resumo da entrada e um link para ela. Depois, faça o download de `releases/latest/download/capture-engine.html` e confira com `cmp` que é igual ao do commit da tag.

> [!CAUTION]
> **Nenhuma versão fecha sem o teste do Export User.**
> Da V11 à V25, a cópia "User" não inicializava, e ninguém notou, porque só se conferia o que devia faltar nela. (D25)

### Teste no navegador

A lista dos testes que pedem a aplicação aberta. O agente pode fazê-los com o Playwright (D-0084).

**Ciclo de vida da sessão:**
- [ ] Abrir o arquivo → interface limpa, campos vazios, histórico vazio
- [ ] Digitar no campo "Quem" → estado "Gravado" aparece **sem aguardar 5 segundos**
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
- [ ] Del ou "Remover" no visualizador mostram a imagem seguinte, ou a anterior se era a última; com a última imagem removida, o visualizador fecha (D-0172)
- [ ] Nos "Removidos", o botão "Restaurar" e o do menu fazem o mesmo, com os itens que restam nos "Removidos" (D-0172)

**Anotação — comportamento (motor reescrito na V23, testar com atenção):**
- [ ] Desenho à mão livre **não pisca** durante o desenho
- [ ] O traço salvo é igual ao que se viu na tela — sem arredondar, sem alisar e sem fechar o contorno sozinho
- [ ] Curvas mantêm as quinas suaves depois de soltar (não ficam pontudas)
- [ ] Retângulo, círculo e seta desenham por arrasto
- [ ] Texto: colocar (Enter insere uma linha nova; clicar fora ou "Aplicar alterações" grava; Escape cancela), reeditar com duplo-clique, mudar cor / negrito / itálico
- [ ] Desfazer / Refazer (Ctrl+Z / Ctrl+Y)
- [ ] "Aplicar alterações" funde a anotação na imagem; "Descartar alterações" descarta
- [ ] Tentar fechar o modal com anotações por salvar → "Aplicar alterações" e "Descartar alterações" pulsam, e a foto escurece. O resto da barra fica meio transparente até o próximo clique
- [ ] Durante esse aviso, um clique na imagem, no título ou na barra volta à edição; "Descartar alterações" e "Aplicar alterações" fazem a ação deles
- [ ] Texto: o "Girar 90°" gira também o texto
- [ ] Texto: o botão de duas setas acima do texto selecionado gira o texto e prende em 90° quando passa perto; o texto girado redimensiona e reedita girado
- [ ] Botão direito ou do meio em uma anotação, em uma ferramenta de desenho: fica selecionada, com o ✕, e o Selecionar aceso. Um clique fora, o ✕ ou o Delete voltam à ferramenta de antes sem desenhar
- [ ] Espessura por ferramenta: o desenho livre, o retângulo, o círculo e a seta começam em 4 px, o marca-texto em 12 px e no amarelo. Trocar de ferramenta e voltar mantém o passo e a cor de cada uma
- [ ] Texto: o + vai até 400 e o − até 12; arrastar a alça de um texto muda o número da bandeja do Texto
- [ ] Com duas imagens ou mais, as setas ← → no editor, dentro e fora de uma bandeja, não trocam de imagem nem fecham o editor (F-0083)
- [ ] Esc com anotações por salvar: o aviso aparece, e nada se perde (F-0088).
- [ ] Esc no meio de um arrasto, depois outra imagem e Ctrl+Z: nada da imagem anterior volta (F-0084)
- [ ] Em 360 e 375 px de largura, a barra do editor e as bandejas cabem na tela (F-0085)
- [ ] Opções das ferramentas: um clique (ou toque) na ferramenta já escolhida, o duplo clique e o botão apertado por 1 s abrem as opções. Elas ficam lado a lado, acima de cada ferramenta que desenha. O − e o + da bandeja mudam o tamanho mostrado depois deles e o da barra. Um clique em uma ferramenta não escolhida só a escolhe, e um novo clique na escolhida fecha a bandeja. A seta para cima abre pelo teclado, e o Esc fecha sem fechar o editor
- [ ] Retângulo e círculo "Preenchido": a forma sai cheia na cor; escolher a opção com uma forma selecionada a muda, e o Ctrl+Z desfaz
- [ ] Zoom no editor (rolagem do mouse e botões + e −): um traço feito a 200% cai debaixo do cursor
- [ ] Zoom no editor: Espaço + arrastar e o botão do meio movem a imagem sem desenhar; o campo de texto aberto e o botão ✕ acompanham o zoom

**Reordenação (reescrita com Pointer Events / FLIP na V23):**
- [ ] Arrastar imagens para reordenar é **estável** (não salta nem pisca), com mouse
- [ ] Se possível, testar também em **tela de toque**
- [ ] Um **clique simples** ainda abre o item (não confunde clique com arrasto)
- [ ] Arrastar documentos na lista também reordena
- [ ] Segurar uma imagem perto da borda de baixo ou de cima rola a lista, ou a página no telefone. A imagem chega a um lugar que estava fora da tela (D-0171)

**Visual e tema:**
- [ ] Imagens com cantos retos; botões e cards de texto com cantos arredondados
- [ ] O arquivo abre **sem erros no console** (F12)
- [ ] Dark mode funciona **sem flash branco** ao abrir (anti-FOUC)

**Export (testar o ciclo real):**
- [ ] PDF gera com imagens; fica **desativado** quando há documentos na sessão
- [ ] ZIP empacota imagens + documentos
- [ ] **Export Admin** → a cópia mantém o painel de administração e a capacidade de reexportar

#### Teste do Export User — obrigatório em toda a release

Executar **sempre**, com o arquivo realmente gerado pelo botão Export — nunca com o `capture-engine.html` de desenvolvimento:

1. [ ] Fazer **Export User** pela aplicação e guardar o arquivo
2. [ ] Abrir esse arquivo no navegador e pressionar **F12 → Console**
3. [ ] **Zero erros no console, sem exceção.** Um `TypeError: Cannot read properties of null` é a assinatura exata do defeito D25. Ele mostra que o IIFE abortou: a aplicação está morta por baixo de uma interface que parece normal.
   - O Export User não tem o bloco `ADMIN_JS`, por isso não chama o `capturePristine()` nem faz o `fetch(location.href)`. Aberto por `file://` ou servido por `http(s)`, o console fica sem erro nenhum.
   - O par `Access to fetch at 'file:///…' … CORS` e `[CE] Quine fallback: BOOT_HTML` é normal só no `capture-engine.html` principal e no Export Admin abertos por `file://` (seção 3, "Quine"). **Em um Export User, esse par reprova o passo:** quer dizer que o bloco `ADMIN_JS` não foi removido.
4. [ ] **A aplicação responde:** colar uma imagem (Ctrl+V) e confirmar que ela aparece na grade
5. [ ] **A sessão persiste:** escrever no campo "Quem", recarregar a página, e confirmar que a sessão está no histórico
6. [ ] Confirmar que as configurações (cor, nome, rodapé) foram aplicadas
7. [ ] Confirmar que **não** há botões de admin nem Visual Builder

> **Por que os passos 4 e 5 não são dispensáveis:** no defeito D25, a interface aparecia inteira, com "Pronto" na barra de estado, porque isso é HTML estático. Só a interação revela que nada está ligado. Uma inspeção visual passa; colar uma imagem não.

**Multi-aba:**
- [ ] Abrir o arquivo em uma segunda aba do mesmo navegador → **carrega normalmente** (sem tela de erro vermelha); ambas as abas funcionam e compartilham a mesma base de dados

## 6. Decisões

Estas decisões foram confirmadas pelo dono do projeto e não se revertem sem a aprovação dele. As antigas ficam com o texto que tinham.

- **D1:** O .pdf leva tudo o que está em Imagens; desativado quando há documentos. O .pdf leva tudo o que está em Imagens: as fotos e as páginas de cada PDF que está ali, no lugar do cartão, na ordem da grade (reescrita na 29.1.0, D-0132). Quando há documentos na sessão, o .pdf fica desativado, e o usuário usa o ZIP.
- **D2:** Modal do Visual Builder não fecha ao clicar fora. O VB é de uso exclusivo Admin e requer fechamento explícito pelo botão ✕ para evitar perda de configurações acidentais.
- **D3:** setInterval de 5 segundos mantido no auto-save. Cobre os eventos `isDirty=true` dos controles contínuos do VB (seletores de cor, campos hex, sliders, radios, toggles, campos de texto). Esses eventos `input` não chamam `triggerSave()` na hora. Sem o interval, alterações no VB perdem-se se o navegador for fechado dentro da janela de 5s.
- **D4:** Placeholder "Imagem N" não atualiza após drag-and-drop. O placeholder é decorativo (hint visual). Não representa numeração oficial — a legenda editável é o campo `label`.
- **D5:** triggerSave() sem await em closeSettingsModal. Risco de perda de dados aceito. O setInterval de 5s garante persistência antes de fechar o navegador em uso normal.
- **D6:** TOKEN_TITLE_END com 3 spans independentes no brand-name + amostras de cor individuais. Permite construir títulos como `C P C` (letras a cores alternadas) com espaços controlados manualmente. Cada span tem cor independente configurável via `TOKEN_TITLE_START_COLOR`, `TOKEN_TITLE_ACCENT_COLOR`, `TOKEN_TITLE_END_COLOR`. Vazio = herda cor do contexto. Duplo clique no swatch para repor automático.
- **D7:** Apagar sessão é imediato e permanente, sem diálogo de confirmação. Não há uma única chamada a `confirm()` em todo o produto — é coerência deliberada, não esquecimento no botão da sidebar. A barra «Removidos» cobre itens individuais (imagens e documentos), que é onde a recuperação tem valor prático; sessões inteiras são apagadas por decisão explícita do usuário no ✕ da sidebar. **Não reintroduzir confirmação sem aprovação do proprietário** — foi levantado em auditoria e mantido conscientemente.
- **D8:** **Escape descarta anotações não salvas sem alertar, ao contrário do ✕ e do clique fora** (substituída em 2026-11-06 pela correção da F-0088: o Esc mostra o aviso, como o ✕ e o clique fora). Escape é o atalho de teclado equivalente ao botão **Descartar alterações**, e descartar apaga as alterações por definição. Os outros dois caminhos de fechamento (✕ e backdrop) passam por `hasUnsavedAnnotations()` e disparam `triggerUnsavedAlert()` porque aí a intenção é fechar o modal, não cancelar a edição. A divergência é intencional e reflete intenções diferentes. **Não uniformizar os três caminhos sem aprovação do proprietário.**
- **D-0077:** `Desfazer` e `Refazer` mantêm sempre o mesmo aspecto, mesmo quando não há nada para desfazer. Ao reabrir uma imagem, o `annUndoStack` recomeça vazio, porque as anotações já foram confirmadas ao guardar. O `annRedoStack` volta do IndexedDB. Os dois botões não refletem esse estado: apresentam-se sempre com o mesmo estilo e o clique não produz efeito nem aviso. **Medido:** `visivel=true`, `disabled=false`, `opacidade=1` e `cursor=pointer`, e dois cliques não alteram o canvas nem o IndexedDB. Não foi corrigido por decisão do proprietário. A barra de anotação tem três estados (normal, `:hover`, `.active`) e **nenhum estilo `disabled`**. Desativar os botões deixava-os iguais à vista, e trocava uma falha silenciosa por outra. Corrigir a sério exigiria desenhar um quarto estado visual, o que é decisão de design e não correção. A capacidade de remover anotações não se perde: seleciona-se a anotação e apaga-se. Origem: D75 (sétima auditoria). Antes registrada como D9, ID que já era do commit `a5656f5`.
- **D-0078:** Versões em SemVer a partir de 28.0.0. O critério de major, minor e patch está na §12. As tags `v1` a `v27` e as entradas `[V7]` a `[V27]` ficam. Origem: auditoria de 2026-10-31, decisão 1.
- **D-0079:** Purge às 48 horas e sem backup automático. Por privacidade: para guardar, o usuário exporta PDF ou ZIP. Origem: `CHANGELOG.md`, «Decisões mantidas» da V23.
- **D-0080:** O aviso de quota fica por cima da barra do topo, em `#b91c1c` e branco. É um aviso que não pode ser ignorado. As duas cores são os tokens `--color-banner-critical` e `--color-white` (até a 28.6.3, literais no JavaScript). Origem: `CHANGELOG.md`, D23.
- **D-0081:** Sem o botão «Nova Sessão». Abrir uma sessão numa janela separada só fazia sentido com o launcher `CaptureEngineApp.vbs`. Fora dele, abria várias instâncias sem necessidade. Origem: `CHANGELOG.md`, V18.
- **D-0082:** Tamanhos de fonte, espaços e cortes do layout em `rem`. O texto acompanha o tamanho de letra escolhido no navegador. Com a letra padrão (16 px), nenhum pixel muda. Revoga a regra antiga «Usar `px`» do §2.2. Origem: auditoria de 2026-10-31, decisão 2.
- **D-0083:** Entradas antigas do changelog: as palavras seguem a tabela, as frases ficam. As formas de Portugal e os anglicismos da lista são trocados também nas entradas `[V7]` a `[V27]`. As frases longas antigas ficam, porque são registro datado. Origem: auditoria de 2026-10-31, decisão 4.
- **D-0084:** O agente testa no navegador o que muda. Uma regra antiga mandava o agente nunca abrir o navegador. O teste do Export User (§11, Parte B) continua manual, antes de cada versão. Origem: auditoria de 2026-10-31, decisão 5.
- **D-0085:** Comentários de código em inglês: o `validate.sh` já, o HTML depois. Os comentários do HTML ficam perto dos marcadores do Quine e vão num plano próprio (F-0029, em «Pendentes»). Origem: auditoria de 2026-10-31, decisão 7.
- **D-0086:** O prefixo `-webkit-backdrop-filter` fica. O Safari anterior à versão 18 só aplica o desfoque com o prefixo. É a única exceção ao stylelint, marcada com `stylelint-disable-next-line` na regra de `#zoom-ui`, `#img-nav-prev` e `#img-nav-next`. Origem: auditoria de 2026-10-31, passo 72 do plano.
- **D-0087:** O chevron «›» dos botões .pdf e .zip fica. Aparece só com o botão ativo e some no estado «Concluído». Num botão preenchido, lê-se como «seguir em frente», perto da ação. Alternativas estudadas na 28.4.0 e na 28.5.0: ícone de baixar (pesado), contagem de páginas e arquivos, «.pdf»/«.zip» (redundante depois da mudança de nome) e o visto (diz «feito» antes de exportar e enfraquece o aviso de sucesso). Fecha a P-0002. Origem: pedido do dono, 2026-11-01 (28.5.0).
- **D-0088:** «Teste do Export User», e não «prova de vida». O nome antigo não dizia o que se testa e enchia a lista de commits. O changelog até a 28.5.2 usa «prova de vida»: é o mesmo teste. A partir da 28.5.3, o teste entra no commit da versão, sem commit próprio. Origem: pedido do dono, 2026-11-01.
- **D-0089:** A dica das zonas vazias diminui até 800 px de altura. Ícone de 40 px e texto de 13 px nas telas de notebook (28.5.3). Não é um modo compacto: não muda a barra lateral, e foi pedida para a dica chamar menos atenção, e não para caber. Origem: pedido do dono, 2026-11-01; confirmado no plano da auditoria do mesmo dia.
- **D-0090:** As frases longas das entradas publicadas do changelog ficam. Estende a D-0083 a toda entrada com versão, também as 28.x. **Motivo:** o changelog é registro datado; reescrever uma entrada publicada muda o que se disse naquela data. As palavras ainda seguem a tabela. Origem: plano da auditoria de 2026-11-01.
- **D-0091:** **O GIF do editor é refeito com o editor** (as frases sobre onde a seta parte e sobre o visualizador depois de salvar foram substituídas pela D-0099). O GIF de destaque do README §6.3 (`docs/images/annotation-arrow.gif`) mostra o editor, a barra de ferramentas e o visualizador depois de salvar. Uma mudança numa dessas partes grava o GIF de novo no mesmo commit, com o `gif.py` do repositório dos prompts (preparo `capture-engine-editor-arrow`), e confere com `--verificar`. A seta parte do canto de baixo à esquerda. Assim, o cursor atravessa a barra pelo vão entre Selecionar e Girar 90°. Por cima de um botão, o efeito de passar o mouse mudaria de uma gravação para outra. Fecha a P-0001. Origem: plano dos pendentes, 2026-11-02.
- **D-0092:** A complexidade conta a forma de código das palavras. O check 10 contava `if`, `else`, `for` e as outras como palavras soltas, também nos comentários. Com os comentários em inglês, avisava `annDoUndo` e `annDoRedo`, que não tinham mudado (A-03). Agora conta só a forma que a palavra tem no código. Medido em 207 funções com código igual na 28.6.3 e na 28.6.4: 6 mudavam de número só pelos comentários, e nenhuma muda agora. Os comentários continuam sem ser removidos (D67, D72), e a armadilha dos apóstrofos continua valendo. Origem: auditoria de regressão de 2026-11-02.
- **D-0093:** Shift nas ferramentas do editor. Ao desenhar e ao redimensionar, o Shift deixa o retângulo quadrado e a elipse círculo, e a seta e o desenho livre em passos de 45° a partir do ponto fixo. O estado do Shift é lido a cada evento de ponteiro e na própria tecla. Origem: pedido do dono, 2026-11-04.
- **D-0094:** «Diminuir» e «Aumentar» no lugar de «Espessura menor» e «Espessura maior». Os dois botões têm o mesmo nome em todas as ferramentas: mudam a espessura do traço ou, no texto, o tamanho da letra. Antes, o nome mudava entre «Espessura» e «Texto». Origem: pedido do dono, 2026-11-04.
- **D-0095:** **Marca-texto translúcido ou sólido, e não as ferramentas tarja e desfocar** (o modo da barra foi substituído pela D-0102). Uma ferramenta só esconde ou destaca: «Translúcido» (40 % de opacidade) deixa ler o que está por baixo, e «Sólido» cobre. O traço é um traço livre com o campo `hl` (`'soft'` ou `'solid'`), pontas retas e uma escala de larguras própria (`ANN_HL_SIZES`); por isso herda a seleção, o mover, o redimensionar, o girar e o desfazer. As opções ficam acima da ferramenta (D-0102), e o − e o + da bandeja mudam a espessura, como nas outras ferramentas. Em 2026-11-06, o − e o + mudaram a opacidade do marca-texto no lugar das duas opções; o dono voltou atrás no mesmo dia (D-0106, descartada), porque o − e o + mudavam de sentido só nesta bandeja e a espessura saía dela. Não usa `multiply`: o canvas das anotações fica por cima da imagem, e a gravação ficaria diferente da tela. Origem: pedido do dono, 2026-11-04 e 2026-11-05.
- **D-0096:** Identificação: «Maiúsculas» ou texto livre. `TOKEN_ID_UPPERCASE` (padrão `true`, interruptor «Maiúsculas» no Visual Builder, aba Histórico). Ligado, o próprio valor dos dois campos vira maiúsculas ao digitar, com `toLocaleUpperCase('pt')`, sem mexer no cursor e fora de uma composição; uma sessão antiga aberta tem o valor convertido. Desligado, o texto e o nome da sessão ficam como foram digitados. O placeholder mostra o rótulo como foi escrito: o CSS deixou de usar `text-transform`. Antes, o valor só parecia maiúsculo. Origem: pedido do dono, 2026-11-04 e 2026-11-05.
- **D-0097:** O Esc também não fecha o Visual Builder; o ✕ é alcançado pelo teclado. Completa a D2: o Visual Builder fecha só pelo ✕, com o mouse ou com Tab até ele e Enter. Os outros modais fecham com Esc. Origem: pedido do dono, 2026-11-05 (F-0077).
- **D-0098:** Os botões secundários do visualizador seguem a regra das ferramentas do editor. «Download» e «Restaurar» têm a classe `.btn-viewer`, que entra nas mesmas duas regras de `#img-modal-overlay .ann-btn` (normal e `:hover`), com os tokens `--color-viewer-control*`. Uma mudança nessas cores muda os dois. «Editar» segue só o `.btn-send`, como «.pdf» e «.zip». Os três medem 120 × 36 px. Antes, uma regra própria do «Download» nunca valia, por causa do `style` inline (F-0080). Origem: pedido do dono, 2026-11-05.
- **D-0099:** Cena do GIF do editor: neutra, sem datas, e a seta sai de dentro da janela. A captura é uma área de trabalho com o programa fictício «Orbita», uma DLL selecionada e uma notificação de erro, só com palavras iguais no Brasil e em Portugal. O GIF começa no visualizador: clica em «Editar», escolhe a Seta, e a seta de 4 px sai do painel da esquerda e termina na DLL. Termina com as ferramentas abertas, sem salvar. Substitui a frase da D-0091 sobre a seta partir do canto de baixo à esquerda. Origem: pedido do dono, 2026-11-05.
- **D-0100:** **O botão do meio também agarra uma anotação** (a parte em que a anotação não fica selecionada foi substituída pela D-0103). Em qualquer ferramenta, o botão do meio sobre uma anotação faz o mesmo que o botão direito: agarra e move. Num lugar sem anotação, continua a mover a imagem ampliada. Fora do Selecionar, a anotação agarrada não fica selecionada ao soltar, porque as alças só funcionam no Selecionar (F-0082). Origem: pedido do dono, 2026-11-05.
- **D-0101:** Ctrl (Cmd no Mac): o Selecionar por um momento. Com o Ctrl apertado, o clique esquerdo em qualquer ferramenta, menos o Recortar, vai para o Selecionar: seleciona, move e redimensiona pelas alças. A seleção fica enquanto a tecla está apertada e some ao soltar, para não deixar alças que a ferramenta atual não usa. Enquanto isso, o botão Selecionar fica aceso no lugar da ferramenta, como ao agarrar com o botão direito ou o do meio. Origem: pedido do dono, 2026-11-05.
- **D-0102:** As opções de uma ferramenta sobem acima dela. Todas as ferramentas que desenham têm um ponto logo acima do botão, do lado de fora. Com as opções abertas, o ponto fica na cor principal, no meio do vão, e faz a ligação entre a ferramenta e a bandeja, sem bico. Um clique na ferramenta já escolhida, um duplo clique ou o botão apertado por 1 s abrem as opções numa bandeja escura logo acima, lado a lado como a barra, sempre na mesma ordem, com a primeira em cima da ferramenta: uma opção nunca muda de lugar, em botões padrão do editor, do mesmo tamanho, cada um com um tooltip curto; pelo teclado, a seta para cima abre e as setas para os lados andam entre elas. Os ícones reaproveitam os da barra: o quadrado e o círculo vazios e cheios, o xadrez para «Translúcido» (D-0108), e o B e o I. Substitui os modos da barra do texto e do marca-texto, com o botão ←: a barra não muda mais de forma. O retângulo e o círculo ganham «Contorno» e «Preenchido». Toda bandeja termina com o tamanho: − e + soltos, sem caixa, e o tamanho atual depois deles (um ponto que cresce por passo, ou o número do texto); a caixa fica só nas opções, que são uma escolha, e os sinais soltos só ajustam um valor. O desenho livre e a seta têm uma bandeja só com o tamanho. O − e o + da barra ficam. Origem: pedido do dono, 2026-11-05. Com o Texto, a bandeja fica aberta enquanto o campo de texto está aberto (F-0101). O clique na ferramenta já escolhida entrou em 2026-11-06, porque no telefone o duplo toque e o toque longo não abriam a bandeja.
- **D-0103:** O botão direito e o do meio selecionam. Sobre uma anotação, em qualquer ferramenta menos o Recortar, o botão direito ou o do meio a selecionam, com as alças e o ✕, e já podem arrastá-la. A barra passa ao Selecionar e guarda a ferramenta de antes em `annTempSelectFrom`; um clique fora das anotações, ou apagar a anotação com o ✕ ou o Delete, volta a ela sem desenhar. Escolher outra ferramenta na barra esquece a de antes e tira a seleção; uma ferramenta do mesmo tipo a mantém, e as opções dela mudam a anotação (F-0091). Substitui a parte da D-0100 e do F-0082 em que a anotação não ficava selecionada ao soltar. Origem: pedido do dono, 2026-11-06.
- **D-0104:** Cada ferramenta guarda a sua espessura; o marca-texto, a sua cor. O desenho livre, o retângulo, o círculo e a seta começam um passo acima, com 4 px; o marca-texto fica nos 12 px. Cada ferramenta guarda o seu passo (`annSizeByTool`), e a bandeja mostra o dela; antes, um passo só valia para todas. O marca-texto começa no amarelo e guarda a sua cor; as outras ferramentas dividem a delas (`annColorBy`). Origem: pedido do dono, 2026-11-06.
- **D-0105:** Texto de 12 a 400, e o arrasto muda o tamanho da ferramenta. O − e o + do texto andam em 20 passos, de 12 a 400 (`ANN_TEXT_SIZES`), a partir do tamanho que estiver, mesmo fora dos passos. O arraste das alças de um texto vai de 8 a 400, e o tamanho novo vale para a ferramenta Texto: aparece na bandeja e no próximo texto, como a cor de uma anotação selecionada já valia para a ferramenta. Antes: de 14 a 48 nos passos e de 8 a 96 no arrasto. Origem: pedido do dono, 2026-11-06.
- **D-0106:** (Descartada) O − e o + do marca-texto mudam a opacidade. Proposta e desfeita em 2026-11-06: o − e o + mudavam de sentido só nessa bandeja, e a espessura saía dela. O marca-texto ficou com «Translúcido» e «Sólido» (D-0095). O ID fica reservado, para não ser usado de novo.
- **D-0107:** «Quem» e «O que» na identificação. Os rótulos padrão dos dois campos, no lugar de «User» e «Equipamento», porque dizem o que escrever em cada campo, com as mesmas palavras no Brasil e em Portugal. O administrador troca os dois no Visual Builder. «User» fica como nome do perfil «Export User». Origem: pedido do dono, 2026-11-06.
- **D-0108:** O ícone da ferramenta mostra a escolha. O retângulo e o círculo mostram a forma cheia com «Preenchido»; o marca-texto, a ponta cheia com «Sólido»; o T do Texto fica mais grosso com «Negrito» e inclinado com «Itálico», também o de um texto selecionado; o desenho livre e a seta mostram a espessura. «Translúcido» tem o ícone de xadrez, o desenho comum da transparência. Aceso, o T fica escuro como as outras ferramentas. Origem: pedido do dono, 2026-11-06.
- **D-0109:** No telefone, as ferramentas, o 90° e o Recortar numa linha só. Em telas de até 480 px, a primeira linha do editor não quebra: as margens dos lados passam de 36 a 12 px e o vão de 6 a 4 px, e os 9 botões de 36 px cabem em 393 px. Numa tela mais estreita, os botões encolhem até 30 px, em vez de mandar o 90° e o Recortar para uma linha própria. No computador, nada muda. Origem: pedido do dono, 2026-11-07, depois do teste no iPhone.
- **D-0110:** (Substituída pela D-0112) O ✕ do visualizador com desenho por salvar: some no toque, fica com o mouse. Numa tela de toque, o ✕ some enquanto o desenho não foi salvo, porque um dedo fecha sem querer. Com o mouse, o ✕ fica à vista, e o clique nele faz «Aplicar alterações» e «Descartar alterações» pulsarem, como o Esc e o clique fora da foto, sem fechar. Origem: pedido do dono, 2026-11-07.
- **D-0111:** (Substituída pela D-0113) No toque, a aba recarregada reabre a sessão dela. O Safari do iPhone recarrega uma aba deixada em segundo plano, e a ferramenta abria uma sessão nova, vazia (F-0109). O id da sessão da aba fica no `sessionStorage`, que pertence à aba e sobrevive ao recarregamento. Numa tela de toque, o `init()` reabre essa sessão. Uma aba nova e o botão «Atualizar» continuam a começar uma sessão nova, e no computador o recarregamento também. Origem: pedido do dono, 2026-11-07.
- **D-0112:** O ✕ do visualizador sempre à vista. Em qualquer tela, o ✕ fica à vista enquanto se edita. Com desenho por salvar, o clique ou o toque nele não fecha: o «Descartar alterações» e o «Aplicar alterações» pulsam, como com o Esc e com o clique fora da foto. Substitui a D-0110, em que o ✕ sumia numa tela de toque. **Motivo:** no telefone, o ✕ que sumia parecia um defeito. Origem: pedido do dono, 2026-11-07.
- **D-0113:** No toque, a ferramenta volta à última sessão. Numa tela de toque, abrir o site volta à última sessão aberta, a qualquer hora, também depois de fechar o Safari ou numa aba nova, como os apps de um telefone. O id fica no `localStorage` (`ce-last-session`). O botão «Atualizar», com a mesma seta circular do computador, começa outra sessão. Um ícone de documento com + foi testado e recusado pelo dono: a seta é a que quem usa no computador já conhece. No computador, cada abertura continua a começar uma sessão nova, porque cada abertura é um caso novo, às vezes num computador partilhado. Substitui a D-0111, que usava o `sessionStorage`: o iOS apaga-o ao fechar o Safari, e a sessão não voltava (visto pelo dono no iPhone). Origem: pedido do dono, 2026-11-07, que escolheu o comportamento dos apps do Google, da Microsoft e da Apple em vez de um tempo-limite.
- **D-0114:** O «Erro» do PDF e do ZIP fica aceso até o próximo clique. Antes, o vermelho «Erro» sumia sozinho em 2,5 s, e quem olhava para outro lado não via a falha. Agora fica aceso como o verde «Concluído», pelo `holdSuccess()`, até um clique, uma tecla, um colar ou um soltar na página. O «Concluído» tem o círculo com ✓; o «Erro» ganha o círculo com ✕.
- **D-0115:** No iPhone, o ícone da Tela de Início não tem borda branca e o nome é «Capture Engine». O `apple-touch-icon` tinha os cantos arredondados e 1 px transparente em volta. O iPhone preenche a transparência de branco e arredonda o ícone por conta própria, então aparecia uma borda branca. Agora o ícone é um quadrado preto, sem transparência. O nome sugerido ao adicionar vinha do `short_name` do manifesto, «Capture». Agora o `short_name` e a nova `<meta name="apple-mobile-web-app-title">` dizem «Capture Engine».
- **D-0116:** A página não amplia com dois dedos; só a foto do visualizador amplia. O viewport mantém `maximum-scale=1,user-scalable=no`. **Motivo:** a pinça amplia só a foto do visualizador (F-0107), nunca a interface; sem o bloqueio, a pinça ampliava a tela inteira, e o ✕ saía da tela. O Safari do iPhone ignora o bloqueio, e por isso o visualizador tem a sua própria pinça. O custo aceito: no Chrome do Android, quem precisa de letra maior não amplia a página com dois dedos (WCAG 1.4.4); o tamanho de letra do navegador continua a valer, porque os textos estão em `rem` (D-0082). Fecha o F-0113, aceito por escolha. Origem: DECISOES-PENDENTES, decisão 26, 2026-11-08.
- **D-0117:** **A lixeira no lugar do ✕ ao remover** (substituída em parte pela D-0137, na anotação do editor, e pela D-0144, na cor da lixeira das miniaturas). O ícone de remover é a lixeira do cabeçalho dos «Removidos» (`TRASH_SVG`, classe `.trash-icon`), nas linhas de documento, nas miniaturas e na anotação selecionada do editor. **Motivo:** o ✕ fica só para fechar e cancelar, e a lixeira diz para onde o item vai. Nas linhas, a lixeira é cinza e fica vermelha ao apontar, sobre o fundo de destaque. Sobre uma foto, um quadrado escuro (`--color-viewer-floating`) com a lixeira, vermelho ao apontar, porque o ícone solto sumiria numa foto de qualquer cor. Os botões têm 24 px (F-0122), e o restaurar da miniatura usa a mesma seta circular do botão «Restaurar» (F-0121). Origem: DECISOES-PENDENTES, decisão 9, 2026-11-08.
- **D-0118:** «Eliminar sessão», com o ✕ e sem janela de confirmação. O botão de apagar uma sessão no Histórico continua o ✕, agora com o nome «Eliminar sessão», no lugar de «Excluir», e com 24 px (32 px no telefone). A D7 fica: elimina na hora, sem janela. **Motivo:** a sessão não vai para os «Removidos», por isso não leva a lixeira nem a palavra «Remover», que são dos itens que voltam. «Excluir» quer dizer «deixar de fora» em Portugal. Fecha o F-0117. Origem: DECISOES-PENDENTES, decisão 1, 2026-11-08.
- **D-0119:** A informação do item na linha do título. No visualizador, o título é o nome com a extensão, como o Download o grava («imagem-1.png»), e logo depois vem a informação, menor e cinza («1600×900 · 6,3 KB»); no modal de texto, o tamanho. O nome corta com reticências antes da informação, que nunca quebra. A linha que ficava entre a imagem e a barra saiu, e também a linha embaixo dos botões do modal de texto, que repetia o nome. A legenda da miniatura mostra a extensão; ao editar, só o nome muda, e a extensão fica, como nos documentos. **Motivo:** o alto da tela fica livre, e nada fica entre as bandejas e a barra do editor. Origem: DECISOES-PENDENTES, decisão 10, 2026-11-08.
- **D-0120:** Tamanhos com vírgula, e o número junto da unidade. O `fmtSize` escreve «6,3 KB»: vírgula decimal, que os dois países usam, e um espaço que não quebra (`\u00a0`) entre o número e a unidade, para «6,3» e «KB» nunca ficarem em linhas diferentes. Vale na barra de estado, nas linhas de documento, no visualizador e no modal de texto. Origem: DECISOES-PENDENTES, decisões 11 e 18, 2026-11-08.
- **D-0121:** **Texto «Com fundo»** (substituída em parte pela D-0141: o fundo é o padrão, e o transparente é uma opção). A bandeja do Texto fica Negrito, Itálico, «Com fundo», e depois o tamanho. Com «Com fundo», o texto ganha um retângulo na cor escolhida atrás das linhas, e a letra fica escura ou branca pelo mesmo cálculo YIQ dos botões do app (`annOnColor`). A anotação guarda `bg: true`; a escolha fica no navegador (`text-bg`), e o T da ferramenta mostra um quadrado suave. Origem: DECISOES-PENDENTES, pedido N1, 2026-11-08.
- **D-0122:** O − e o + logo depois das ferramentas, no computador. Acima de 480 px, o − e o + da barra ficam depois do Selecionar, antes do 90° e do Recortar. Até 480 px, a linha das ferramentas está cheia (D-0109), e eles ficam depois das cores, como antes. O lugar muda em tempo de execução, depois do `BOOT_HTML`; o arquivo exportado guarda o lugar antigo. Origem: DECISOES-PENDENTES, pedido N3, 2026-11-08.
- **D-0123:** Um visualizador para tudo. O modal de texto ganha a moldura do visualizador de imagem: o fundo escuro, o título branco com a informação, o ✕ e os botões escuros (`.btn-viewer`, D-0098), com «Copiar texto» nos tipos de texto. No meio, uma página na cor do cartão (`.doc-page`) mostra o tipo: o texto; o Markdown formatado; o CSV numa tabela; e o HTML num `iframe` com `srcdoc` e `sandbox="allow-scripts allow-modals allow-forms"`, sem `allow-same-origin`. As três vistas são montadas com elementos e `textContent`, nunca com `innerHTML` do arquivo. O HTML aberto não alcança o armazenamento do app (dá `SecurityError`) e herda a CSP, sem internet (decisão 6). Origem: DECISOES-PENDENTES, decisões 6 e 19, e DECISOES §6, 2026-11-08.
- **D-0124:** «Copiado», como o «Concluído». O «Copiar texto» mostra «Copiado», sem exclamação, com o círculo e o ✓ e o verde de `.st-success`; numa falha, «Erro», com o círculo e o ✕ e o vermelho de `.st-error`. Volta ao normal em 1,5 s, porque copiar não sai da tela, ao contrário do .pdf e do .zip (D-0114). Fecha o F-0116. Origem: DECISOES-PENDENTES, decisão 27, 2026-11-08.
- **D-0125:** O editor de texto mínimo. Nos documentos de texto (também Markdown, CSV e HTML), «Editar» mostra o texto puro, editável, no lugar da página, e o rodapé troca para «Descartar alterações» (✕ vermelho) e «Aplicar alterações» (verde), como no editor de imagem. O «Aplicar alterações» grava o texto no mesmo documento, e o tamanho muda na linha. Com mudança por salvar, o Esc, o ✕ e o clique fora fazem os dois pulsarem, e nada fecha. Nos «Removidos», não há «Editar». Origem: DECISOES-PENDENTES, decisão 15, 2026-11-08.
- **D-0126:** A lista de um arquivo compactado. Um .zip, .tar, .tar.gz, .tgz ou .rar abre no visualizador com a lista de nomes, tamanhos e datas, lida dos cabeçalhos, sem extrair nada (`archiveList`). O .tar.gz passa pelo `DecompressionStream` do navegador. Um .rar com os cabeçalhos cifrados mostra «Lista protegida por senha». O .7z mostra «Lista não disponível», porque guarda a lista de arquivos comprimida, e ler essa lista pediria um descompressor LZMA embutido. Origem: DECISOES §6, 2026-11-08.
- **D-0127:** O banco na versão 3. A 29.0.0 abre a `CaptureEngineDB` na versão 3, sem mudar nenhum dado guardado. O número impede que uma cópia 28.x abra uma base com registros que ela leria errado (o PDF em Imagens e as imagens coladas no editor). Uma cópia 28.x aberta depois no mesmo navegador mostra «Armazenamento indisponível» e não toca em nada (medido). O caminho de volta está no §6. Origem: DECISOES-PENDENTES, decisão 8, 2026-11-08.
- **D-0128:** **Marcar item a item, e o tipo em cor** (substituída em parte pela D-0135, na regra de quando a caixa aparece). Cada imagem e cada documento tem uma caixa de marcar (`.item-check`); nas imagens, no canto de cima à esquerda. Ela aparece com o mouse em cima, quando há algo marcado, e sempre no toque. O item marcado ganha a borda na cor principal e o fundo `--color-selected`. Esc, ou um clique ou toque fora dos itens, desmarca tudo. Não há arrastar para marcar nem Ctrl+A: o arrastar continua só a mudar a ordem. Nas linhas de documento, o tipo vira uma etiqueta colorida (`--color-file-*`) no lugar do ícone, e um PDF mostra as páginas, lidas do arquivo sem o pdf.js. Origem: DECISOES-PENDENTES, decisões 13 e 14, 2026-11-08.
- **D-0129:** O menu do clique direito. Um só menu (`ctxOpen`), com a forma do painel claro (`--color-card`, borda `--color-border`, `--radius-lg`, `--shadow-settings`) e a camada `--z-popover`; a cor segue o tema. Atalho à direita, em cinza; uma linha entre os grupos; «Remover» fica vermelho ao apontar, com o ícone e o atalho. Itens: numa imagem, Abrir, Editar, Copiar imagem (Ctrl+C), Duplicar, Renomear (F2), Download e Remover (Del); num documento, os mesmos, sem Copiar, e Editar só nos de texto; com vários marcados, o menu único da D-0136; numa área vazia, Adicionar imagem, ou Adicionar documento e Nova nota de texto. Duplicar põe a cópia logo abaixo, pela regra de nomes. O download dos marcados leva a quantidade e a palavra na frente («4-IMAGENS-», «2-PDFS-», «5-ITENS-»). Shift+F10 e a tecla de menu abrem o menu pelo teclado. Origem: DECISOES-PENDENTES, decisões 12, 16 e 23, 2026-11-08.
- **D-0130:** O PDF abre no leitor do próprio navegador. Na 29.x, o visualizador mostra o PDF num `iframe` com `src` de um endereço `blob:` (`openTextModal`, classe `.view-pdf`). A CSP já aceita esse endereço pelo `default-src`, por isso nada nela muda. O endereço é liberado ao fechar e ao abrir outro documento (`pdfViewDrop`). A barra do leitor é a do navegador, e o título dela mostra o código do endereço, e não o nome do arquivo. No iPhone, o Safari pode mostrar só a primeira página; não foi medido, e está no README. Origem: DECISOES §7, decisão 7, 2026-11-08; aprovado pelo dono com fotos, 2026-11-08.
- **D-0131:** O submenu do menu do clique direito. Um item com submenu leva a seta › à direita, em cinza, e abre outro `.ctx-menu` (classe `.ctx-sub`), com a mesma forma, ao lado do item. Sem espaço à direita, abre à esquerda; sem espaço dos dois lados, como no telefone, abre embaixo do item. Abre com o mouse em cima, com o toque e com a seta para a direita; a seta para a esquerda e o Esc voltam ao item. Os valores das linhas ficam à direita, em cinza, com «…» enquanto são medidos. Uma linha que não serve fica desligada, em cinza (`.ctx-item:disabled`), e não some. O primeiro uso é «Diminuir o tamanho» do PDF: «Redução leve», «Redução equilibrada» e «Redução máxima» (até a 29.2.0, Leve, Equilibrado e Máximo; nomes do dono, 2026-11-09), com o tamanho real de cada cópia; num PDF sem foto JPEG, as três linhas ficam desligadas. Origem: DECISOES §2.3 e §3.3, decisão 12; aprovado pelo dono com fotos, 2026-11-08.
- **D-0132:** O PDF em Imagens. Arrastar um PDF de Documentos para Imagens o move para lá, e arrastar de volta o devolve, com os bytes iguais. O `initReorder` mostra um segundo espaço de soltar (`phx`) na outra lista enquanto o item flutua por cima dela; só um PDF cruza. O registro vai para a loja `images`, com `kind: 'pdf'` (§6). O cartão mostra o ícone na cor da etiqueta do PDF e «PDF · N páginas». O título do bloco fica «Imagens e PDF» enquanto houver um PDF ali, e a contagem fica «3 imgs · 1 PDF · 6 docs · 12,3 MB». Clicar abre o leitor de documentos (D-0130). O menu é o mesmo de um PDF em Documentos (D-0145), sem Editar nem Copiar imagem. As setas do visualizador de imagem pulam os PDFs. Origem: DECISOES §5, decisões 17 e 18, 2026-11-08.
- **D-0133:** Colar por cima da imagem. Com o editor de imagem aberto, o Ctrl+V cola a imagem da área de transferência como uma anotação nova, `type: 'image'`, no meio da foto (ou do recorte), no tamanho natural, ou na metade da foto quando é maior. Ela entra marcada, com o Selecionar. Move-se, muda de tamanho pelos cantos sem perder a proporção, sai com o Delete e volta com o Desfazer. O Girar 90° gira a imagem colada junto com a foto. O blob fica no campo `annBlobs` do registro (§6); a anotação guarda só o id. A imagem colada não vira miniatura na grade; ao confirmar, é gravada na foto, como as outras anotações. Fora do editor, o Ctrl+V continua a capturar. Origem: pedido N4, DECISOES §2.6, aprovado; 2026-11-08.
- **D-0134:** Camadas, na bandeja do Selecionar. O Selecionar ganha o ponto e uma bandeja com dois ícones: «Trazer para frente» (Ctrl+], com o quadrado do meio cheio) e «Enviar para trás» (Ctrl+[). Ctrl+Shift+] e Ctrl+Shift+[ levam ao topo e ao fundo, sem ícone. A tecla vale pelo código (`BracketRight`, `BracketLeft`), em qualquer teclado. Vale para qualquer anotação marcada, e cada mudança tem Desfazer. A bandeja do Selecionar não tem o − e o +, porque ele não tem tamanho. Origem: pedido N4, DECISOES §2.6, aprovado; 2026-11-08.
- **D-0135:** A caixa de marcar só aparece depois de «Marcar». A caixa de marcar (`.item-check`) fica escondida, sem ocupar lugar nem receber clique, até haver algo marcado. O menu do clique direito de cada item ganha «Marcar», ou «Desmarcar» quando o item já está marcado (`markToggle`). Com algo marcado, as caixas de todos os itens aparecem, para marcar os outros com um clique. O Esc, um clique fora dos itens ou desmarcar o último as escondem de novo. Substitui a regra da D-0128 que mostrava a caixa com o mouse em cima e sempre no toque. **Motivo:** a caixa sempre à vista atrapalhava. O Esc também passa a desmarcar com o foco numa caixa (`typingInField` não conta uma caixa de marcar como campo de digitar). A caixa fica num `label` (`.item-check-hit`) 10 px maior de cada lado, com margem negativa: a mesma caixa na tela, e uma área de clique de 36 px (medido: zero pixels diferentes). Origem: pedido do dono, 2026-11-08.
- **D-0136:** O menu dos marcados é o mesmo em qualquer item. Com vários itens marcados, o clique direito em qualquer um deles abre o mesmo menu (`markedGroups`): «Juntar em um PDF» quando todos são PDFs (em Documentos ou em Imagens); «Download .pdf» só quando nenhum está em Documentos (D1); «Download .zip» e «Remover» sempre. Antes, o menu mudava com o item clicado: a imagem mostrava o .pdf, e o documento não. Origem: pedido do dono, 2026-11-08.
- **D-0137:** O ✕ apaga a anotação do editor. A anotação selecionada no editor tem o ✕ «Apagar» no canto, e não a lixeira. **Motivo:** uma anotação apagada não vai para os «Removidos»; volta só com o Desfazer. A lixeira fica para o que vai para os «Removidos» (D-0117). O ✕ é o de antes da D-0117: um quadrado vermelho cheio (`--color-red-500`) de 18 px, sempre visível, com o caractere ✕ em branco, e uma área de clique 10 px maior de cada lado (`::after`, regras pelo id `#ann-shape-del-btn`). Origem: pedido do dono, 2026-11-08 (o desenho cheio, no mesmo dia).
- **D-0138:** Recortar: Cantos livres e Endireitar, gravados na foto. A bandeja do Recortar tem Retângulo (o de hoje, o padrão), Cantos livres e Endireitar, sem o − e o +. Sair do Recortar volta ao Retângulo. **Cantos livres:** quatro bolinhas começam no papel achado (D-0139), ou nas pontas da foto; o «Aplicar alterações» desfaz a perspectiva por homografia (`annHomography`, `annWarpQuad`), pixel a pixel, com amostragem bilinear, num retângulo com os lados mais longos do quadrilátero. **Endireitar:** arrastar em qualquer lugar da foto a gira em volta do centro, sobre uma grade, e a bolinha no alto fica como dica (P2, 2026-11-08); de −45° a 45°, com o 0° preso perto dele; a foto gira por CSS na prévia, cortada na moldura, e o que o «Aplicar alterações» vai cortar fica escuro. O ângulo aparece embaixo da alça só enquanto arrasta. O «Aplicar alterações» gira e guarda o maior retângulo com a proporção da foto, sem canto vazio (`annLevelCanvas`). **Os dois gravam na foto ao confirmar** (`annSaveMode`): a foto com as anotações passa pela conta e vira a foto nova, sem `origBlob`, anotações, rotação nem recorte guardados; a foto como foi capturada fica em `firstBlob`, e o Desfazer volta a ela (D-0140). **Motivo:** uma perspectiva desfeita não leva um retângulo a outro retângulo, e as anotações não teriam como continuar objetos. O Recortar retângulo continua não destrutivo. Medido no Chrome: 0,4 s numa foto de 12 MP com Cantos livres. Origem: DECISOES §8, 2026-11-08.
- **D-0139:** Os Cantos livres começam no papel achado. Ao escolher Cantos livres, o app procura o papel na foto (`paperFind`): reduz a foto a 480 px, passa a cinza, separa o claro do escuro pelo limiar de Otsu (`paperOtsu`), fica com a maior região clara (`paperBlob`) e tira os 4 cantos pelos extremos de x+y e x−y (`paperCorners`). As bolinhas começam nesses cantos, e a pessoa ainda pode arrastá-las. Sem um papel claro (uma região de menos de 12 % ou de mais de 97 % da foto), elas começam nas pontas da foto. Medido antes, numa cópia fora do repositório: 2,3 KB a mais no arquivo, 7 ms numa foto de 12 MP, e 12 ms com a CPU 4× mais lenta; cantos a até 12 px dos verdadeiros numa foto de 4000 px. No app, o clique em Cantos livres numa foto de 12 MP leva de 58 a 74 ms. Só papel mais claro que o fundo é achado. Origem: decisão 25, com o sim do dono depois da medida, 2026-11-08.
- **D-0140:** O Desfazer chega à foto como foi capturada. Ao abrir o editor numa foto já editada, o fundo da pilha do Desfazer é a foto como foi capturada (`first: true`): sem anotações, giro, recorte, perspectiva ou endireitamento. O Ctrl+Z tira primeiro as anotações e depois volta a ela, também depois de confirmar e reabrir; o Ctrl+Y refaz. O fundo vem de `firstBlob`, ou do `origBlob` (`annUseFirst`). «Aplicar alterações» nesse ponto guarda a foto inicial: o arquivo capturado, igual byte a byte, e o Refazer continua disponível ao reabrir (`annForgetIfUntouched`, F-0128). Sair sem confirmar devolve o `cropBox` guardado (`annOpenCrop`), porque um Desfazer o muda em memória. Cada recarga do fundo tem um número (`annBgSeq`), e uma que termina depois de outra mais nova não muda a imagem. Sem giro, recorte nem `firstBlob`, o degrau sem anotações já é a foto capturada: ele vira o fundo, em vez de ganhar um degrau igual por baixo, e nenhum Ctrl+Z ou Ctrl+Y fica sem efeito (F-0140, 2026-11-10). No Recortar, abrir a ferramenta não grava degrau: o primeiro arrasto da caixa grava (`annCropFresh`), e um degrau sem caixa mostra a foto inteira com as linhas (F-0141, 2026-11-10). **Motivo:** dar à pessoa a segurança de errar e voltar. Origem: pedido do dono, 2026-11-08.
- **D-0141:** O texto com fundo é o padrão, e o transparente é uma opção. A bandeja do Texto fica Negrito, Itálico, «Com fundo» e «Fundo transparente», e depois o tamanho. As duas últimas são uma escolha só (uma fica acesa), como Contorno e Preenchido. «Com fundo» é o padrão; a escolha fica no navegador (`text-bg`, «0» para o transparente), e um navegador sem escolha começa com fundo. A opção vale também para o texto que está sendo digitado. Textos já feitos não mudam. Origem: pedido do dono, 2026-11-08.
- **D-0142:** A bandeja também abre arrastando a ferramenta para cima, e uma aberta serve para as outras. Além do clique na ferramenta escolhida, do duplo clique e do botão apertado por 1 s (D-0102): apertar uma ferramenta e subir mais de 12 px abre a bandeja, no mouse e no toque (`touch-action: none` nos botões com bandeja), e soltar sobre uma opção a escolhe; descer mais de 12 px fecha a bandeja aberta. Com o botão ainda apertado, passar sobre outra ferramenta abre a bandeja dela; com uma bandeja aberta, o mouse sobre outra ferramenta também troca para a dela, como numa barra de menus. Sem bandeja aberta, passar o mouse não abre nada. Uma opção da bandeja de outra ferramenta escolhe essa ferramenta antes (um ouvinte em captura em cada `.ann-flyout`). **Motivo:** o dono testou as duas formas; abrir ao passar o mouse não existe no toque, abre sem querer ao atravessar a barra e cobre a foto. Origem: pedido do dono, 2026-11-08 e 2026-11-09.
- **D-0143:** O menu do clique direito numa anotação do editor. Um clique com o botão direito numa anotação, sem mover mais de 4 px entre apertar e soltar (`annRightAt`), abre o menu: «Trazer para frente» (Ctrl+]), «Enviar para trás» (Ctrl+[), «Duplicar» (uma cópia 16 px de tela para baixo e para a direita, marcada, com Desfazer; `annDupSelected`) e, depois de uma linha, «Apagar» (Del), com o ✕. Arrastar com o botão direito continua movendo a anotação (D-0103), sem abrir o menu. Dentro do editor, o menu é escuro (`.ctx-dark`, com os tokens `--color-viewer-*`), como pede a decisão 12. Origem: pedido do dono, 2026-11-08.
- **D-0144:** A lixeira das miniaturas é vermelha cheia. O botão de remover das miniaturas (`.t-del`) é um quadrado vermelho cheio (`--color-red-500`) com a lixeira branca, e não mais o quadrado escuro que ficava vermelho ao apontar. Continua aparecendo com o mouse em cima ou com o foco. Origem: pedido do dono, 2026-11-09.
- **D-0145:** O menu de um PDF é o mesmo em Documentos e em Imagens. O cartão de um PDF em Imagens tem o menu de um PDF em Documentos: Abrir, Duplicar, Renomear (F2), Marcar · Diminuir o tamanho › · Download, Remover (Del). A cópia menor do «Diminuir o tamanho» fica na mesma coluna do original, logo depois dele. **Motivo:** o arquivo é o mesmo nas duas colunas, e o menu não pode mudar com a coluna. Origem: pedido do dono, 2026-11-09.
- **D-0150:** Os commits anteriores a 2026-06-12 ficam como estão, fora do Conventional Commits. São 60 de 449 commits, todos até 2026-06-11, e são histórico publicado: reescrevê-los pediria um force-push. Os commits desde 2026-06-12 seguem o padrão. Origem: F-0138, auditoria de 2026-11-09, com o sim do dono no mesmo dia.
- **D-0151:** O ícone do PDF tem a página branca e «PDF» pequeno. O desenho de antes, em `pdfFace`, com 40 px e o contorno em `--color-file-pdf`, passa a ter a página e a dobra em `--color-annotation-white` (`#f0f0f0`) e «PDF» em `--color-file-pdf`, peso 700, `font-size` 4,6 no `viewBox` de 24 (cerca de 8 px), centrado na parte de baixo da página. O dono recusou o vermelho mais vivo da imagem de exemplo, o texto grande, «.pdf», o branco puro (forte demais) e o branco a 70 % (cinza no tema escuro). Origem: pedido do dono, aprovado por foto em 2026-11-09.
- **D-0152:** Outra cor: o círculo arco-íris, o conta-gotas e o campo HEX. Depois das 8 cores, um círculo cheio com as cores do arco-íris (`#ann-color-custom`, um `conic-gradient` de tokens, com `background-origin: border-box` para não repetir sob a borda). O clique abre a bandeja `#ann-fly-color`, no padrão das outras, com o conta-gotas (`annEye`), uma amostra da cor e o campo `#ann-hex`. O conta-gotas começa desligado (D-0164). Com o conta-gotas, a foto ganha a mira, e a lupa `#ann-loupe` mostra a cor e o código sob o ponteiro. Um clique ou um toque na foto pega a cor do pixel, da foto e das anotações juntas (`annEyeSample`, lido do canvas), não desenha nada e fecha a bandeja. Um código válido no campo vale na hora (`annApplyColor`), e o Enter fecha a bandeja. A cor vai para a anotação selecionada ou para a ferramenta, como um clique nas 8 cores. Uma cor fora das 8 fica no círculo, lisa e com o anel de cor ativa (`annSyncSwatches`), e um novo clique nele a escolhe e abre a bandeja. O círculo abre a bandeja também como uma ferramenta (D-0142): apertar e arrastar para cima, no mouse e no toque, arrastar para baixo fecha, a seta para cima abre, e passar por ele arrastando a partir de uma ferramenta abre a dele. Com uma bandeja aberta, o mouse sobre o círculo abre a bandeja dele, e de volta sobre uma ferramenta abre a dela, como numa barra de menus. Abrir assim, ou arrastando, não escolhe a cor do círculo: só o clique escolhe. Como abre opções, o círculo tem o ponto das ferramentas (D-0102), em `.ann-color-wrap::after`: na linha dos pontos delas no computador, e no espaço entre as fileiras no telefone; aberto, na cor principal. **Motivo:** a API `EyeDropper` só existe no Chrome e no Edge, e o canvas funciona em qualquer navegador, também no telefone. Origem: pedido do dono, aprovado por foto em 2026-11-09.
- **D-0153:** Os botões dos editores chamam-se «Descartar alterações» e «Aplicar alterações». No editor de imagem (`ann-cancel`, `ann-save`) e no editor de texto (`text-edit-cancel`, `text-edit-save`), o ✕ vermelho e o disquete verde mostram esses nomes no tooltip, no lugar de «Cancelar» e «Confirmar». Os dois editores mudam juntos, porque são o mesmo conceito, e os documentos usam os nomes novos. **Motivo:** o nome diz o que acontece com as alterações. Origem: pedido do dono, 2026-11-09.
- **D-0154:** O manifesto recebe o endereço da página como `start_url`, `id` e `scope`. O manifesto fica no `<head>`, em `data:` e em base64 (`#app-manifest`), e não tem `start_url`. Sem ele, o Edge e o Chrome recusam o app (`start-url-not-valid`) e não mostram «Instalar app» na barra de endereço; só o menu ⋯ instala. Um script logo depois do `<link>` lê o manifesto e, em `http:` ou `https:`, grava os três campos com o endereço da página, sem a busca e sem o `#`. O endereço não fica escrito no arquivo, porque o mesmo arquivo roda em qualquer endereço. Em `file://`, nada muda: o app nunca foi instalável assim. O script também lê o manifesto já reescrito. Assim, uma cópia feita pelo `BOOT_HTML` (§1.2), que serializa o DOM, ganha o endereço novo onde for aberta. **Medido** no Edge 157 e no Chrome 156, pelo `Page.getInstallabilityErrors`, em localhost: o erro some, também numa cópia serializada aberta em outra pasta. Origem: P-0004, pedido do dono, 2026-11-09.
- **D-0155:** O menu do clique direito no visualizador de imagem. O clique direito na imagem aberta, fora do editor, abre o menu do app (`viewerMenu`), escuro como o das anotações (D-0143): Editar, Copiar imagem (Ctrl+C), Duplicar, Renomear (F2), Download e Remover (Del). É o menu do cartão sem «Abrir» e sem «Marcar». Nos «Removidos», só Restaurar (ícone novo `restore` no `MI`) e Download. Os atalhos valem com o visualizador aberto, e a tecla de menu e Shift+F10 abrem o menu sobre a imagem. Renomear edita o nome no título, sem a extensão; Enter ou um clique fora gravam, e Esc desfaz. Remover fecha o visualizador e manda a imagem para «Removidos». No telefone, um toque longo de 500 ms na imagem abre o menu, também no iPhone, onde o Safari não tem o evento `contextmenu`; mover mais de 10 px ou um segundo dedo cancela. O `-webkit-touch-callout: none` tira o menu do Safari da imagem. Com um menu aberto, as teclas ficam nele (`stopPropagation`): o Esc e as setas não chegam ao visualizador, e o clique fora fecha só o menu (`viewerMenuDismiss`). **Motivo:** o menu do navegador falhava, porque o endereço `blob:` da imagem é revogado depois de carregar. Origem: P-0006, pedido do dono, aprovado por foto em 2026-11-10.
- **D-0156:** O seletor de cor: quadrado de tons e barra de cores. Na bandeja «Outra cor» (D-0152), o círculo ao lado do campo HEX é um botão (`#ann-hex-preview`, `aria-expanded`). O clique abre, acima do conta-gotas, o `#ann-picker`: o quadrado `#ann-sv` (saturação na horizontal, brilho na vertical) e a barra `#ann-hue` (o matiz, de 0° a 360°), em HSV. Os marcadores andam 7 px para dentro das bordas e nunca saem delas. Ao abrir, a bandeja guarda a largura que tinha (`offsetWidth`). Arrastar, no mouse ou no toque, mostra a cor no círculo da bandeja, no campo HEX e no círculo da barra de ferramentas (`annSyncSwatches`). Soltar aplica a cor, na ferramenta ou na anotação selecionada, com um desfazer só. As setas movem 1 %, e com Shift 10 %; soltar a tecla aplica. Um código digitado, o conta-gotas e a abertura da bandeja levam os marcadores à cor (`annPkFrom`); um cinza mantém o matiz de antes. Fechar a bandeja fecha o seletor. Os botões da bandeja de cor não trocam a ferramenta: antes, o conta-gotas e o círculo trocavam para «color», que não existe, e a seleção se perdia. No telefone, o campo HEX tem 80 px, porque os campos usam letra de 16 px. **Motivo:** o padrão do Chrome e do Figma, escolhido pelo dono entre três esboços. Origem: P-0007, pedido do dono, aprovado por foto em 2026-11-10.
- **D-0157:** O tamanho do arquivo vai até 600 KB, e o que entra precisa servir. O check 25 do `validate.sh` aceita de 300 000 a 600 000 bytes; antes, até 520 000. A 29.6.0 chegou a 519 661 bytes, e o P-0005 (Desfocado) não caberia. **Motivo:** o arquivo cresce com o uso, e é baixado uma vez para rodar sem internet; 80 KB a mais não pesam para quem usa. O limite continua um alarme contra um salto inesperado, não uma meta. **Orientação do dono:** nada de funções desnecessárias. O crescimento vem dos pedidos, e de tempos em tempos uma auditoria procura funções, cores e trechos duplicados ou redundantes para enxugar o código. Origem: pedido do dono, 2026-11-10.
- **D-0158:** Frases de até 30 palavras nos documentos vivos; o CHANGELOG antigo fica. O `AGENTS.md`, o README, o `design-tokens.md` e as entradas novas do `CHANGELOG.md` não têm frase com mais de 30 palavras, contadas fora de tabelas e de código. As entradas do `CHANGELOG.md` até a 29.4.1 ficam como estão, cerca de 280 frases longas. **Motivo:** são registro datado, como as entradas `[V7]` a `[V27]` (§12), e reescrevê-las mudaria o histórico sem ganho para quem usa. No `design-tokens.md`, o comando de conferência das cores literais saiu de dentro da citação, para ser lido como código. Fecha o F-0074, o F-0132 e o F-0135. Origem: pedido do dono para tratar todos os pendentes, 2026-11-10.
- **D-0159:** Curvas e a fonte do modal de texto em tokens; o texto da anotação fica com fontes genéricas. As seis transições com `cubic-bezier` escrito à mão usam tokens: `--ease-in-out` (a barra lateral), `--ease-emphasized` (a reordenação), `--ease-out-soft` (a barra «Removidos» e a barra lateral estreita) e `--ease-out-expo` (o zoom do visualizador). O modal de texto usa `--font-mono`. **Medido** no Edge 157, a 1536 e a 800 px: as curvas calculadas são as mesmas, e o texto do modal não muda nenhum pixel. O `sans-serif` e o `serif` genéricos do texto da anotação ficam: o canvas desenha o texto com `ctx.font`, que não lê tokens, e o campo e as letras das opções precisam da mesma fonte que o desenho. O `--font-sans` (Segoe UI) mudaria a letra. Fecha o F-0120. Origem: pedido do dono para tratar todos os pendentes, 2026-11-10.
- **D-0160:** Desfocado, a terceira opção do Retângulo e do Círculo. Na bandeja das duas ferramentas: Contorno, Preenchido e Desfocado (`ann-rect-blur`, `ann-circle-blur`). A escolha fica em `annFill[t]`, que vale `false`, `true` ou `'blur'`, e o navegador a guarda como `0`, `1` ou `b`. A forma leva `fill: true` e `blur: true`, e por isso o clique dentro dela a seleciona. O `annDrawBlur` copia a região da foto e das anotações de baixo, reduz pela metade até blocos de cerca de 1/80 da foto (12 px no mínimo) e amplia com suavização, recortada no retângulo ou na elipse. Reduzir pela metade tira a média de 2 × 2 pixels em qualquer navegador: numa redução só, o Safari pula pixels e deixa manchas de letra. Não usa `ctx.filter`, que o Safari não tem. Na anotação selecionada, trocar a opção troca a forma, com um desfazer. **Medido** no Edge 157, no Chrome 156 e no WebKit: sob a forma, a variação dos pixels da foto salva cai a menos de um terço, e fora dela nada muda. **Motivo:** esconder um dado antes de exportar. A foto salva leva só a versão desfocada; o original fica no `origBlob`, que não se exporta. Origem: P-0005, pedido do dono, aprovado por foto em 2026-11-10.
- **D-0161:** Clique duplo no título renomeia; um nome apagado volta ao nome de entrada. No visualizador, o clique duplo no `#img-modal-title` chama o `viewerRename`, como o F2 e o «Renomear» do menu (D-0155); nos «Removidos», não edita. Um nome apagado, no título ou no cartão, volta ao `defLabel`: o nome que a imagem recebeu ao entrar, guardado pelo `captureImg` e pelo `addPdfImage`. Sem `defLabel`, numa imagem anterior à 29.7.0, recebe o primeiro `imagem-N` livre. Se o nome de entrada já for de outra imagem, a numeração do `setLabel` acha um livre. Antes, um nome apagado mantinha o nome modificado. **Motivo:** desfazer um nome sem lembrar como era. Origem: pedido do dono, 2026-11-10.
- **D-0162:** Ctrl+A seleciona todas as anotações, e o Delete as apaga. No editor, fora de um campo de texto, o Ctrl+A liga o `annAllSel`: cada anotação ganha a caixa de seleção, sem alças. O Delete apaga todas, com um desfazer só (`annAllKey`). O Esc, um clique na foto, outra ferramenta, o Ctrl+Z, o Ctrl+Y e sair do editor desfazem a seleção. O `preventDefault` impede o navegador de selecionar o texto da página, também no visualizador. Num campo de texto, o Ctrl+A continua a selecionar o texto do campo. **Motivo:** apagar tudo de uma vez; antes, o Ctrl+A selecionava a interface inteira, e a seleção não saía. Origem: pedido do dono, aprovado por foto em 2026-11-10.
- **D-0163:** O botão direito move o texto que está sendo digitado. Enquanto se digita, o campo `#ann-text-input` fica sobre o canvas e recebia o botão direito. Agora o botão direito ou o do meio sobre ele chamam o `annDownGrab`, como no canvas (D-0103): o texto é confirmado e o arrasto começa na hora. Um clique direito parado abre o menu da anotação (D-0143). No Safari do Mac, o menu abre ao apertar o botão, e o arrasto com o botão direito não funciona, nem no texto nem nas outras anotações. **Motivo:** mover o bloco sem sair do texto antes. Origem: pedido do dono, aprovado por foto em 2026-11-10.
- **D-0164:** O conta-gotas começa desligado. Ao abrir «Outra cor», o conta-gotas fica desligado (substitui o «já ligado» da D-0152). Um clique o liga, e ele fica ligado até a pessoa pegar uma cor na foto; aí desliga, e a bandeja fecha. **Motivo:** quem abre a bandeja para digitar um código ou usar o seletor não quer a mira na foto. Origem: pedido do dono, aprovado por foto em 2026-11-10.
- **D-0165:** O aviso de anotações por salvar tem um balão de texto. No aviso (`triggerUnsavedAlert`), um balão no estilo do tooltip (`.ce-tip.on-dark`, `#ann-await-tip`, `role="status"`) diz «Aplique ou descarte as alterações». Ele fica centrado acima de «Descartar alterações» e «Aplicar alterações» (`annAwaitTip`) e some com o aviso (`clearAnnAwait`). Durante o aviso, o tooltip de passar o mouse não aparece, para não cobrir o balão. Os botões ficam no lugar: centralizá-los mudaria a barra, que no telefone já tem três fileiras. **Motivo:** o escurecimento sozinho não dizia o que fazer. Origem: pedido do dono, aprovado por foto em 2026-11-10.
- **D-0166:** No telefone, o toque longo seleciona a anotação, e o texto da interface não se seleciona. No editor, 500 ms de toque parado sobre uma anotação, com qualquer ferramenta menos o Selecionar e o Recortar, chamam o `annDownGrab`, como o botão direito (D-0103). O traço ou o texto que a ferramenta tinha começado é descartado, e o arrasto move a anotação. Mover mais de 10 px, soltar ou um segundo dedo cancelam. O `body` tem `user-select: none`, e os campos (`input`, `textarea`, `[contenteditable]`) voltam a `text`. O Safari do iPhone lê só o `-webkit-user-select`, por isso o prefixo fica, com o aviso ao stylelint. **Motivo:** antes, o toque longo começava a seleção de texto do navegador, que pintava a interface inteira, como um Ctrl+A. **Medido** no Chromium e no WebKit, com toque simulado. Origem: pedido do dono, 2026-11-10.
- **D-0167:** No telefone, dois toques valem como clique duplo. O `onDoubleTap` trata dois toques em até 350 ms, a menos de 30 px, como um clique duplo, porque o telefone nem sempre envia o `dblclick`. Vale no título do visualizador, que passa a editar o nome (D-0161), e no canvas, onde edita o texto anotado com o Texto ou o Selecionar (`annDblText`). Com o Texto, o primeiro toque espera 350 ms antes de abrir um texto novo, para dar lugar ao segundo; com o mouse, continuam 220 ms. O `dblclick` que o navegador ainda mande logo depois é ignorado (`annTapAt`). O `stopPropagation` fica só no `dblclick`: no toque, ele impedia o `pointerup` de encerrar o toque longo da D-0166, que confirmava o texto 500 ms depois. Origem: pedido do dono, 2026-11-10.
- **D-0168:** A imagem mostrada guarda o seu endereço `blob:`. O visualizador, o editor e as miniaturas revogavam o endereço da imagem assim que ela carregava. O Safari do iPhone pode carregar de novo uma imagem que está na tela, e com o endereço revogado ela aparecia quebrada, com «Pré-visualização» e o «?». Agora o `modalImgSrc` dá o endereço à imagem do visualizador e revoga o anterior só quando um novo toma o lugar dele, ou ao fechar. As miniaturas fazem o mesmo. As esperas de carregamento do editor (`modalImgLoad`, o giro) terminam também no erro, e não prendem mais o editor. **Medido** no WebKit e no Edge: antes, uma nova leitura do endereço da imagem na tela falhava no visualizador, no editor e na miniatura; agora funciona. Origem: fotos do dono no iPhone, 2026-11-10.
- **D-0169:** O ✕ de uma anotação só apaga com um toque que começa nele. No telefone, um toque numa anotação a seleciona, e o ✕ aparece no canto dela. O clique que o navegador gera desse toque podia cair no ✕, que acabava de surgir sob o dedo, e apagava a anotação. Agora o ✕ só apaga se o `pointerdown` foi nele (`_annDelDown`); o Enter do teclado, sem toque, continua a apagar. Numa anotação muito pequena na tela do telefone, o ✕ ainda cobre parte dela, e um toque ali apaga. Origem: achado no teste do pedido D-0167, 2026-11-10.
- **D-0170:** Os blobs da sessão aberta ficam em memória. O Safari (WebKit) liga um blob lido do IndexedDB ao registro gravado. Quando esse registro é gravado de novo ou apagado, o blob não se lê mais (`NotFoundError`). Ao reabrir o editor de uma imagem já editada, o fundo limpo vem do `origBlob`, lido do banco ao carregar a sessão. O «Aplicar alterações» anterior regravou o registro, e o fundo aparecia quebrado, com «Pré-visualização» e o «?». O endereço não estava revogado, e a D-0168 não cobria este caminho. Agora o `loadSession` copia para a memória, uma vez, cada blob da sessão (`blob`, `origBlob`, `firstBlob` e `annBlobs`), com o `blobsInMemory`. A mesma causa fazia o ZIP dar «Erro» depois de renomear uma imagem, e a imagem removida ficar quebrada nos «Removidos» (F-0149). **Custo:** as fotos da sessão aberta ocupam memória do navegador, e abrir a sessão lê cada uma uma vez. **Medido** no WebKit e no Chromium do Playwright, com o banco em disco e toque simulado. Antes, no WebKit, o editor reaberto mostrava 0 × 0 e o ZIP dava «Erro»; agora, 800 × 800, e o ZIP sai. Não foi testado num iPhone de verdade. Origem: foto do dono no iPhone, 2026-11-11.
- **D-0171:** O arrasto rola a lista perto da borda. Ao arrastar uma imagem ou um documento, a lista não rolava, e era preciso soltar, rolar e pegar de novo. Agora, com o item preso a até 48 px da borda de cima ou de baixo da lista, ou além dela, a lista rola até 16 px por quadro. Vale também com o ponteiro ao lado da lista, num arrasto em diagonal; só um PDF sobre a outra lista não a rola (F-0151, 2026-11-11). Quando a lista não rola mais, como no telefone, rola a página, junto à borda da tela. A rolagem continua com o ponteiro parado, e o lugar do item é recalculado a cada passo. No toque, o arrasto depois do toque longo também não rolava a página nem andava, porque o navegador cancelava o gesto (F-0150). **Medido** no Chromium e no WebKit do Playwright, com 16 imagens. Antes, a grade ficava parada em 0 de 610 px, e a imagem caía no meio. Agora, ela rola até o fim e volta ao alto, e a imagem vai para a última posição. O toque foi simulado pelo CDP do Chromium, e não num telefone de verdade. Origem: pedido do dono, com foto, 2026-11-11.
- **D-0172:** Remover ou restaurar no visualizador mostra a imagem seguinte. O Del e o «Remover» do menu do clique direito mandam a imagem aberta para os «Removidos» e mostram a seguinte da grade. Nos «Removidos», o botão «Restaurar» e o do menu devolvem a imagem à grade e mostram a seguinte dos «Removidos». Se ela era a última, mostram a anterior. Sem nenhuma imagem na lista, o visualizador fecha. Os PDFs em Imagens ficam de fora, como nas setas ← →. Antes, o visualizador fechava a cada remoção ou restauração, e era preciso abrir a próxima imagem pela grade. **Medido** no Chromium e no WebKit do Playwright, com 3 imagens em cada lista. Del ou o botão «Restaurar» na segunda mostram a terceira. O «Remover» ou o «Restaurar» do menu na última mostram a primeira, e a remoção ou a restauração final fecha. Origem: pedido do dono, 2026-11-11.
- **D-0173:** A espessura do traço e o tamanho do texto seguem a imagem. Os passos de `ANN_SIZES` e `ANN_HL_SIZES` e o tamanho inicial do texto multiplicam-se por `annScaleF`: o lado menor da imagem dividido por 1080, nunca abaixo de 1. Uma captura de tela comum não muda; uma foto de 3024 × 4032 desenha 2,8 vezes mais grosso, e o mesmo passo parece igual na tela. As anotações salvas guardam a espessura em pixels da imagem e não mudam. O − e o + de uma anotação selecionada acham o passo mais próximo (`annStepOf`). Origem: pedido do dono, 2026-11-13.
- **D-0174:** O anel de foco escurece a cor principal no tema claro. A cor `#e86b2e` dava 2,88:1 sobre o fundo claro, e a WCAG 2.2 pede 3:1 a um indicador de foco. No claro, o `--color-ring` mistura 85% da cor principal com 15% da cor do texto: `#c95f2b`, com 3,67:1. No escuro, fica a cor principal, com 5,86:1. Custo: uma cor principal muito clara, escolhida no Visual Builder, pode ficar abaixo de 3:1. Medido com o Tab no Edge, no Firefox e no WebKit. Origem: F-0161, 15 de novembro de 2026.
- **D-0175:** o README fala com quem usa e com quem administra a ferramenta, e não com quem edita o código. A palavra em português vem primeiro, e os nomes do código ficam nas seções "Estrutura de arquivos" e "Arquitetura". Custo: os termos técnicos em inglês da lista dos prompts não entram no texto para quem usa. Origem: a migração para os prompts 8.0.1, 15 de novembro de 2026 (F-0156).
- **D-0176:** as regras do arquivo único, do Quine e da sanitização vêm dos três contratos do motor. O arquivo é a aplicação inteira e funciona sem internet; o arquivo copia a si mesmo com a configuração; um dado do usuário nunca chega ao DOM sem `escapeHTML()`. Quebrar o primeiro deixa a ferramenta morta sem internet; o segundo, a cópia exportada corrompida; o terceiro abre um XSS com dados de clientes. Custo: nenhum recurso de fora, e cada edição conferida pelo `validate.sh`. Origem: as "Regras absolutas" do projeto, registradas como decisão em 15 de novembro de 2026 (F-0156).
- **D-0177:** Na raiz, só o produto, a documentação e as ferramentas que o padrão exige. Quem clona o capture-engine recebia arquivos sem contexto. A raiz guarda o produto, a documentação, o `validate.sh`, o `.stylelintrc.json` e o `.gitattributes`; um arquivo novo na raiz precisa de uma decisão própria. Os testes dos fluxos críticos ficam no repositório dos prompts, em `fluxos/capture-engine.py` (repositório de referência, D-0037), e o check 30 do `validate.sh` os chama pelo clone. Custo: sem o clone, os testes não executam. Origem: o dono, 15 de novembro de 2026.
- **D-0179:** o capture-engine não tem ícones animados nem a opção "Ícones animados", uma exceção à D-0034 e à D-0028 dos prompts 8.0.1. O dono testou os gestos em 15 de novembro de 2026: crescer desfocava o traço, subir não ficou bom, e a animação não foi aprovada. Ao passar o mouse, os ícones só mudam de cor. Custo: o projeto diverge dos prompts nesse ponto. Origem: o dono, na correção da F-0160; a D-0178, que descrevia a animação, foi desfeita.

## 7. Pendentes

Nenhum pendente aberto.

## 8. IDs

Os IDs novos seguem o formato `D-0001` (decisão), `P-0001` (pendente que não veio de uma auditoria) e `F-0001` (achado de auditoria). O ID vai no fim do título do commit, entre parênteses. Os IDs antigos ficam como estão:

| Formato | O que é | Onde aparece |
|---|---|---|
| `D1`–`D8` | Decisões do proprietário | Esta seção |
| `D9`–`D76` | Entradas do changelog: correções, triagens e registros. O `D9` é o commit `a5656f5` (guarda de blob nos "Removidos" e aviso de IndexedDB indisponível) | `CHANGELOG.md` e títulos de commit |
| `M1`–`M6`, `M-1`, `B8`, `B-1`–`B-3` | Achados das auditorias externas da V26 | `CHANGELOG.md`, entrada `[V26]` |
| `G1`–`G3` | Gerações sucessivas do Export Admin em um teste do Export User | `CHANGELOG.md`, entrada `[V26]` |
| `V7`–`V27` | Versões anteriores ao SemVer | `CHANGELOG.md` e tags `v1` a `v27` |
| `A-01`–`A-03`, `O-01`–`O-02` | Achados (`A-`) e observações (`O-`) da auditoria de regressão de 2026-11-02. Os `A-` e a `O-02` foram corrigidos na 28.6.5; a `O-01` ficou como está. Não contam para a numeração de `F-` | `CHANGELOG.md`, entrada `[28.6.5]`, e títulos de commit |

Os IDs antigos contam para a numeração da mesma letra: depois do `D76`, a decisão seguinte foi a `D-0077`.

Os números `D-0146` a `D-0149` não existem neste repositório. Foram usados em um trabalho local com o pdf.js, cancelado pelo dono em 2026-11-09, e não se reutilizam: depois da `D-0145` vem a `D-0150`.

O `P-0003` (extrair as imagens de um PDF pelo clique direito) foi descartado pelo dono em 2026-11-09. Muitos PDFs são de texto, e mostrá-los como imagem pede um renderizador como o pdf.js. O número não se reutiliza: a pendente seguinte foi a `P-0004`.
