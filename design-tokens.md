# Design Tokens · Capture Engine V26

> Especificação completa do design system — a linguagem visual que define como a interface se vê, se comporta e se sente.

---

## O que são Design Tokens e por que existem?

Um **design token** é um nome simbólico para um valor visual. Em vez de escrever `#0ea5e9` diretamente no CSS, usamos `var(--accent)`. Em vez de escrever `36px` em cada botão, os botões têm sempre `height: 36px` por convenção documentada.

**Por que usar tokens?**

1. **Consistência** — Mudar a cor principal em um lugar (`--accent`) muda em toda a interface automaticamente
2. **Personalização via Quine** — O admin muda a cor pelo Visual Builder; o Quine Engine substitui o valor no arquivo exportado
3. **Dark mode sem duplicação** — Os tokens têm valores diferentes em `:root` (light) e `body.dark` (dark); o CSS que usa os tokens não precisa saber em que modo está
4. **Legibilidade** — `color: var(--text-muted)` diz o que faz; `color: #6b6a66` não

**Dois tipos de tokens:**
- **Tokens CSS** — definidos como variáveis CSS (`:root { --token: valor }`) — usados em `var(--token)` no CSS
- **Tokens JavaScript** — definidos como `const TOKEN_*` no início do script — controlam o comportamento e são substituídos pelo Quine na exportação

---

## 1. Paleta de Cores

### Como o sistema de cores funciona

A paleta tem dois grupos:
- **Cores base** (não mudam entre light/dark): `--accent`, `--color-green`, `--color-red`, `--color-yellow` — mantêm o mesmo matiz mas adaptam-se ao fundo
- **Cores adaptativas** (mudam entre light/dark): `--bg`, `--surface`, `--border`, `--text`... — invertem ou ajustam conforme o modo

### Light Mode (`:root` — padrão)

| Token | Hex | Uso na interface |
|---|---|---|
| `--bg` | `#f4f3f0` | Fundo geral — off-white (não branco puro) para suavizar o contraste com a superfície branca dos painéis |
| `--surface` | `#ffffff` | Superfície de painéis, cards, modais — branco puro para contraste com o fundo |
| `--border` | `#dddcd880` | Bordas sutis, linhas de separação — estruturam sem poluir (alpha 50%) |
| `--border-strong` | `#b5b3ae` | Bordas com mais presença — elementos de estado ativo ou hover |
| `--text` | `#1a1917` | Texto principal — quase preto (nunca `#000000` puro — muito agressivo) |
| `--text-muted` | `#6b6a66` | Texto secundário — datas, legendas, metadados menos importantes |
| `--accent` | `#e86b2e` | Cor de destaque principal personalizada — botões, links, elementos ativos |
| `--accent-fg` | `#ffffff` | Texto legível sobre fundo accent — contraste calculado para #e86b2e — verificar WCAG AA se aplicado em texto de corpo |
| `--accent-hover` | `#d4450f` | Accent escurecido para hover |
| `--color-green` | `#22c55e` | Sucesso, confirmação, estado "Gravado" |
| `--color-red` | `#ef4444` | Erro, remoção, ações destrutivas |
| `--color-yellow` | `#eab308` | Aviso, expiração próxima |

### Dark Mode (`body.dark`)

| Token | Hex | Nota |
|---|---|---|
| `--bg` | `#121212` | Quase preto — padrão Material Dark |
| `--surface` | `#1e1e1e` | Ligeiramente mais claro que o fundo — cria profundidade sem bordas |
| `--border` | `#33333380` | Borda escura sutil (alpha 50%) |
| `--border-strong` | `#555555` | Borda escura mais visível |
| `--text` | `#e4e4e4` | Quase branco (nunca `#ffffff` puro — agressivo em fundos escuros) |
| `--text-muted` | `#9a9a9a` | Cinza médio para elementos secundários |

> **Regra do dark mode:** Ativa-se *exclusivamente* via classe CSS `body.dark`. A media query `prefers-color-scheme` é usada **apenas em JavaScript** (`initTheme`) como fallback na primeira abertura, quando não há preferência salva em `localStorage`. Depois de o usuário alternar manualmente, a escolha fica persistida. Isto dá controle total ao usuário.

> **Anti-FOUC:** Existe um script síncrono imediatamente após `<body>` que aplica `body.dark` *antes* de qualquer pintura do DOM. Sem isto, o usuário em dark mode veria um flash branco ao abrir a app.

---

## 2. Cores Semânticas — Estados de Feedback

Estas variáveis definem estados de sucesso, erro e aviso de forma completa (fundo + borda + texto) para que qualquer alerta fique consistente sem definir três cores manualmente.

| Estado | Token de fundo | Token de borda | Token de texto |
|---|---|---|---|
| **Sucesso** | `--success-bg` | `--success-border` | `--success-text` |
| **Erro** | `--error-bg` | `--error-border` | `--error-text` |
| **Aviso** | `--warn-bg` | `--warn-border` | `--warn-text` |

**Valores Light / Dark:**

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

*Em dark mode, os fundos usam `rgba` com opacidade ~0.08 — a cor semântica fica sobreposta ao fundo escuro com baixa saturação, em vez de um bloco de cor sólido.*

### 2.1 Cores literais fora do sistema de tokens — exceções declaradas

O contrato do projeto proíbe valor visual hardcoded. Existem, ainda assim, cores escritas como literais no `capture-engine.html`. **Todas são intencionais**, e estão listadas aqui para que auditorias automáticas e revisões futuras parem de as reportar como violação — um `grep` por `background:#` não distingue intenção de esquecimento, e duas auditorias independentes já as assinalaram.

| Cor | Onde | Por que é literal |
|---|---|---|
| `#b91c1c` | Fundo dos banners críticos `#ce-quota-banner` e `#ce-storage-banner` | Vermelho de alerta escolhido para estes dois avisos. Não corresponde a `--color-red` (`#ef4444`), que é mais claro; o tom mais escuro foi preferido para o bloco de fundo sólido de largura total. Não tem token próprio por decisão do proprietário. |
| `#ef4444` `#f97316` `#eab308` `#22c55e` `#3b82f6` `#a855f7` `#1a1a1a` `#f0f0f0` — os 8 swatches, enumerados (**não escrever «e restantes»**: o comando de verificação no fim desta secção compara listas literais e um apanha-tudo torna-o cego) | Atributos `data-color` da paleta de anotação | **Não são cor de interface — são dados.** O valor é gravado dentro do objeto de anotação no IndexedDB e usado depois para redesenhar a forma. Uma `var(--x)` ficaria persistida como texto no banco, ou exigiria resolução no momento da escrita. Têm de ser literais. |
| `#ef4444` `#22c55e` `#eab308` | Strings de estilo do `SysLogger` (`console.log('%c…')`) | O console do DevTools **não resolve** custom properties da página. Não há alternativa técnica. |
| `#ef4444` | `style` inline do botão `#ann-cancel` | Decisão do proprietário. O botão vizinho `#ann-save` usa `var(--color-green)`; o valor literal aqui produz exatamente o mesmo resultado renderizado que `var(--color-red)` produziria (`rgb(239, 68, 68)`), pelo que não há divergência visual — apenas de escrita. Mantido como está. |
| `#ef4444` | `let annCurrentColor = '#ef4444'` | Cor inicial da anotação. **É dado, não interface** — mesma razão dos swatches: o valor é persistido no IndexedDB. |
| `#fff` `#ffffff` | Texto e ícones sobre preenchimentos de cor sólida: banners críticos, `.btn-send:disabled`, `#btn-admin-save.admin-active`, `.spinner`, `.count-badge`, `.t-del`, `#trash-badge`, `.ann-swatch.active` | Branco puro sobre fundo saturado. Não há token de branco puro no sistema — o `--text` nunca é `#ffffff`, por decisão documentada na §1 — e usar `--text` aqui inverteria o contraste em modo claro. |
| `#ffffff` `#e0e0e0` `#2a2a2a` `#3f3f3f` `#363636` `#555555` `#121212` `#fff` | Chrome do modal de imagem: `#img-modal-overlay` e descendentes (`.modal-title`, `.modal-close`, `#ann-toolbar`, `.ann-btn` e variantes, `#img-modal-dl`) | **O modal de imagem não tem variante clara** — não existe nenhuma regra `body:not(.dark) #img-modal-overlay` no arquivo. É uma superfície de visualização deliberadamente escura, para a imagem ser avaliada contra chrome neutro em qualquer tema. Os tokens invertem com o modo; estes valores não podem inverter. Alguns coincidem com tokens (`#555555` = `--border-strong`, `#121212` = `--bg` do modo escuro): a coincidência é do valor, não da intenção. |
| `#16a34a` | `#btn-admin-save.admin-active:hover` | Verde mais escuro para o estado hover. O estado base usa `var(--color-green)`; não existe token de variante escurecida no sistema. |
| `#e86b2e` | Declaração do `TOKEN_MAIN_COLOR`; atributos `value=` dos inputs `#cfg-cor-hex` e `#cfg-cor-principal`; fallback quando `getComputedStyle(--accent)` devolve vazio | **É o valor padrão do próprio token** (§6). Um `var(--accent)` aqui seria circular: o `--accent` deriva deste valor. Os dois `value=` do Visual Builder têm de espelhar o padrão para o picker abrir na cor certa antes de qualquer JS correr. |
| `#ffffff` `#1a1a1a` | `#tb-brand-icon svg` e a sua variante `body:not(.dark)` | Ícone da marca com cor fixa por tema, definida diretamente em vez de por token. |
| `#1a1917` `#ffffff` | Cálculo YIQ de contraste (`fg = (yiq >= 128) ? … : …`) | Escolha de legibilidade sobre um acento **arbitrário** definido pelo usuário no Visual Builder — o resultado não é conhecido em tempo de escrita, portanto não pode vir de um token. Já descrito na §6; repetido aqui para que o `grep` desta secção não o reporte. |
| `#35a800` `#ffd82b` | `stop-color` do `<linearGradient id="ce_accent">` no logo SVG inline | Stops de gradiente da identidade visual. SVG inline não resolve custom properties em `stop-color` de forma fiável entre browsers. |
| `#000000` | `<meta name="theme-color">` e `<meta name="msapplication-TileColor">` | Metatags lidas pelo browser e pelo sistema operativo **antes de o CSS existir**. Custom properties não se aplicam a metatags. |

> **Regra para quem edita:** acrescentar uma cor literal nova **fora** desta tabela é violação do contrato. Se for genuinamente necessária, acrescente aqui a linha com a justificação — caso contrário, use um token.

> **Como verificar que esta tabela continua completa** — a versão anterior enumerava 5 categorias e o código tinha 9; a lacuna sobreviveu a duas auditorias porque ninguém comparou as duas listas mecanicamente. O comando abaixo faz essa comparação e deve devolver vazio:
>
> ```bash
> comm -23 \
>   <(grep -vE '^[[:space:]]*--[a-z-]+[[:space:]]*:' capture-engine.html | grep -oE '#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b' | tr 'A-F' 'a-f' | sort -u) \
>   <(sed -n '/^### 2.1/,/^## 3\./p' design-tokens.md | grep -oE '#[0-9a-fA-F]{6}\b|#[0-9a-fA-F]{3}\b' | tr 'A-F' 'a-f' | sort -u)
> ```
>
> O `grep -v` tem de filtrar **linhas**, antes de extrair as cores — as declarações de custom property (`--bg: #1e1e1e`) definem a paleta e não são exceções. Filtrar depois da extração não faz nada, porque nessa altura já não há contexto de linha para casar.
>
> Qualquer linha devolvida é uma cor no código que esta secção não declara.

---

## 3. Layout e Forma

### Tipografia — Fonte do sistema

A interface usa `'Segoe UI', Arial, sans-serif` — a fonte nativa do Windows/Mac/Linux. Sem fontes externas (sem Google Fonts, sem CDN), para garantir o funcionamento 100% offline e para que a interface se pareça "em casa" no sistema operacional de cada usuário.

### Raio de Canto — A escala de arredondamento

Existe uma escala de 5 níveis, cada um com um propósito específico:

| Token | Valor | Onde usar |
|---|---|---|
| `--radius-xxs` | `3px` | Badges, etiquetas de tamanho — micro-elementos |
| `--radius-xs` | `4px` | Inputs, chips de seleção — elementos pequenos interativos |
| `--radius-sm` | `6px` | Botões, cards de documentos — elementos de ação principais |
| `--radius-md` | `8px` | Painéis internos, caixas — contentores secundários |
| `--radius-lg` | `12px` | Modais e diálogos — elementos de maior destaque visual |

> **Exceção geométrica — imagens:** Os elementos `.t-item` e `.t-label` têm `border-radius: 0` (cantos retos — comunicam precisão e formalidade). O `.t-wrap` (wrapper do thumbnail) tem `border-radius: var(--radius-sm)` (6px) para suavizar visualmente a moldura da imagem na grelha, mantendo o card exterior reto. Botões e cards textuais ficam arredondados para parecerem interativos e acessíveis.

### Medidas fixas de layout

| Token CSS | Valor | Uso |
|---|---|---|
| `--top-bar-h` | `64px` | Altura estrita da barra de cabeçalho — consistente em todas as telas |
| `--thumb-size` | `140px` | Tamanho da caixa de thumbnail — todos os thumbs têm a mesma área |

---

## 4. Z-Index Stack — Quem fica à frente de quem

A pilha **não é uma escala global única** — os valores estão agrupados por *stacking context*. Valores baixos (10–300) só competem dentro do seu próprio contexto (ex.: controles internos do modal de imagem); os altos (9999, 99999) são globais.

| Nível | Z-index | Onde / propósito | Contexto |
|---|---|---|---|
| Base | `0` (implícito) | Conteúdo normal (grelha, listas, painéis) | global |
| Local | `10` | Empilhamento local: placeholders de arrasto, pequenos overlays | local |
| Arrasto | `50` | Item a ser arrastado (`.t-item/.d-item.dragging`) acima dos vizinhos | local |
| Controles do modal de imagem | `100` | Barra de zoom (`#zoom-ui`) e setas (`#img-nav-prev/next`) sobre a imagem | dentro do modal |
| Overlay de texto da anotação | `200` | `#ann-text-overlay` sobre o canvas | dentro do modal |
| Botão apagar anotação | `300` | Botão `✕` acima do overlay de texto | dentro do modal |
| Backdrop da sidebar mobile | `1999` | `#sb-mobile-overlay` (fundo escurecido) | mobile |
| Sidebar mobile | `2000` | `#sidebar` acima do seu próprio backdrop | mobile |
| Modais | `9999` | `.modal-overlay`, `.sb-overlay`, `#mobile-paste-fab` | global |
| Banners críticos | `99999` | Quota/armazenamento — **acima dos modais** de propósito, para um aviso crítico nunca ficar escondido | global |

**Regra de governança:** qualquer novo valor de `z-index` deve ser adicionado **a esta tabela, ao `agents.md §2.2` e ao conjunto permitido no `validate.sh`** (que falha se aparecer valor não documentado).

---

## 5. Animações

| Animação | O que faz | Duração | Onde é usada |
|---|---|---|---|
| `spin` | Rotação contínua | Contínua | Spinner nos botões PDF/ZIP durante o processamento |
| `fadeIn` | Entrada com opacidade 0→1 | 200ms | Novos thumbnails e documentos ao serem adicionados |
| `modalIn` | Escala `0.96→1` + opacidade | 200ms | Entrada suave de todos os modais |
| `fadeInTab` | Opacidade rápida | 250ms | Transição entre abas do Visual Builder |

*Todas as animações são curtas (200–250ms) e sem inércia. O objetivo é dar feedback imediato — não criar uma experiência cinematográfica que atrase a interação.*

---

## 6. Tokens JavaScript (SSOT — Single Source of Truth)

Estes tokens estão declarados como `const` no topo do IIFE do JavaScript. São a **fonte de verdade** para a configuração: o Visual Builder lê estes valores ao abrir, e o Quine Engine os substitui ao exportar.

| Token | Tipo | Valor padrão | Alterável no VB | Aba VB |
|---|---|---|---|---|
| `TOKEN_TITLE_START` | `string` | `'Capture '` | ✅ | Interface → "Texto Inicial" |
| `TOKEN_TITLE_ACCENT` | `string` | `'Engine'` | ✅ | Interface → "Texto em Destaque" |
| `TOKEN_TITLE_END` | `string` | `''` | ✅ | Interface → "Texto Final" (terceira parte do título; espaços manuais) |
| `TOKEN_TITLE_START_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do Texto Inicial (vazio = herda cor do texto) |
| `TOKEN_TITLE_ACCENT_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do Texto em Destaque (vazio = herda cor accent) |
| `TOKEN_TITLE_END_COLOR` | `string` | `''` | ✅ | Interface → swatch de cor do Texto Final (vazio = herda cor do texto) |
| `TOKEN_MAIN_COLOR` | `string` | `'#e86b2e'` | ✅ | Interface → color picker principal |
| `TOKEN_ACCENT_FG_OVERRIDE` | `string` | `''` | ✅ | Interface → color picker de texto |
| `TOKEN_FOOTER_TEXT` | `string` | `'© {YEAR} • CAPTURE ENGINE • DIOGO CARVALHO'` | ✅ | Interface → "Texto do Rodapé" |
| `TOKEN_SHOW_SESSION_USER` | `bool` | `true` | ✅ | Histórico → toggle "Campo 1" |
| `TOKEN_SHOW_SESSION_PC` | `bool` | `true` | ✅ | Histórico → toggle "Campo 2" |
| `TOKEN_USER_LABEL` | `string` | `''` | ✅ | Histórico → "Rótulo — Campo 1" |
| `TOKEN_EQUIP_LABEL` | `string` | `''` | ✅ | Histórico → "Rótulo — Campo 2" |
| `TOKEN_JPEG_QUALITY` | `float` | `0.92` | ✅ | Captura → "Qualidade do PDF" |
| `TOKEN_MAX_IMG_DIMENSION` | `int` | `0` | ✅ | Captura → dimensão máxima |
| `TOKEN_AUTO_PURGE_HOURS` | `int` | `48` | ✅ | Captura → horas até purge automático. **ℹ️ Valor 0 desativa o purge** (guard `if (!TOKEN_AUTO_PURGE_HOURS) return` — nenhuma sessão é apagada). Valores suportados pelo Visual Builder: 8, 24, 48 (horas) e 0 (Nunca/desativado). Valores arbitrários editados à mão no token não são preservados pelo reexport do Visual Builder — ver nota no README §6.4. |
| `TOKEN_DEBUG_MODE` | `bool` | `true` | ❌ | Sem UI — desativado automaticamente em Export User |

### Notas sobre tokens específicos

**`TOKEN_TITLE_END` (adicionado na V23):**
Terceira parte do título da aplicação. Renderizado como `<span id="ui-title-end">` com `font-weight: 600`. A cor é controlada por `TOKEN_TITLE_END_COLOR` (vazio = herda cor do texto). Espaços entre partes do título são manuais — incluir no valor do token.

**`TOKEN_ACCENT_FG_OVERRIDE` (vazio = automático):**
Quando vazio (`''`), o motor calcula automaticamente se o texto sobre a cor accent deve ser branco ou preto. O algoritmo usado é **YIQ** — uma ponderação perceptual dos canais RGB calibrada para a sensibilidade do olho humano:

```
yiq = (R × 299 + G × 587 + B × 114) / 1000
yiq ≥ 128  →  texto escuro (#1a1917)
yiq < 128  →  texto branco (#ffffff)
```

O limiar 128 divide a escala 0–255 ao meio. Para cores de baixo contraste intrínseco (ex: amarelo `#eab308` — yiq ≈ 176, texto escuro; ciano `#06b6d4` — yiq ≈ 133, texto escuro; laranja `#f97316` — yiq ≈ 145, texto escuro), o resultado automático pode não atingir os rácios WCAG AA (4.5:1 para texto normal). Nestes casos, preencher `TOKEN_ACCENT_FG_OVERRIDE` com a cor desejada. Preencher apenas se o cálculo automático não produzir o contraste desejado.

**`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL` (vazio = padrão visual):**
Um valor vazio significa "usar o padrão visual" (`User` / `Equipamento`). O Visual Builder mostra estes termos como placeholder, mas o token fica em `''`. Exportar sem editar estes campos preserva a flexibilidade — o motor usa o padrão correto conforme o contexto. A flag `_vbLabelDirty` controla se o admin editou ativamente estes campos.

**`TOKEN_JPEG_QUALITY` (0.70 a 0.95):**
Afeta apenas a geração do PDF — os arquivos originais na sessão ficam sempre em PNG. Valores abaixo de 0.70 produzem artefatos JPEG visíveis em screenshots com texto. Valores acima de 0.95 aumentam o tamanho do PDF sem benefício visual perceptível.

> **Clamp automático no Visual Builder:** O VB aplica `Math.min(0.95, Math.max(0.70, rawJq / 100))` ao valor introduzido — valores fora do intervalo são silenciosamente corrigidos para o limite mais próximo. A edição manual direta do token no código-fonte não tem este guard. Comportamento com valores fora de `[0.70, 0.95]` editados diretamente: o valor é passado sem clamp para `canvas.toBlob(type, quality)`. O standard HTML define que valores fora de `[0, 1]` fazem o browser usar a qualidade padrão da implementação (tipicamente ~0.92); valores no intervalo `[0, 1]` mas fora de `[0.70, 0.95]` são aceitos sem erro — apenas produzem os artefatos ou o desperdício de espaço documentados acima.

**`TOKEN_MAX_IMG_DIMENSION` (0 = sem limite):**
Afeta **apenas a geração do PDF**, tal como `TOKEN_JPEG_QUALITY`. Se definido (ex: `1920`), qualquer imagem com dimensão superior é reduzida ao gerar o PDF, preservando a proporção. É lido num único ponto do código — `imgToJPEG()`, chamada exclusivamente por `generatePDF()`.

> ⚠️ **Importante — não reduz o armazenamento:** `captureImg()` grava sempre o blob **original**, sem redimensionar. Este token não diminui o consumo de quota do IndexedDB e não serve como mitigação para esgotamento de armazenamento. Para isso, o caminho é exportar (PDF ou ZIP) e apagar sessões antigas.
>
> Até à V26, esta secção afirmava que a imagem era «redimensionada antes de ser armazenada», e o `README §9` recomendava o token como forma de prevenir perda de dados por quota. Ambas as afirmações eram falsas: um administrador que o configurasse para esse fim não obtinha redução nenhuma, e continuava exposto à perda que o conselho pretendia evitar. Optou-se por corrigir a documentação e não o código — redimensionar na captura destruiria o original de forma irreversível, o que numa ferramenta de recolha de provas é perda de evidência.

> **Comportamento sem-op:** Se a imagem já tiver ambas as dimensões iguais ou inferiores ao limite configurado, nenhum redimensionamento ocorre — a imagem entra no PDF tal como está.

### Como o Quine usa estes tokens

O Quine substitui valores por regex no código-fonte:
```js
// O Quine procura um padrão flexível, por exemplo:
html.replace(/const TOKEN_MAIN_COLOR\s*=\s*'[^']*'/, "const TOKEN_MAIN_COLOR = '#ff6600'")
```

**Por isso, o formato exato deve seguir a sintaxe:**
- `const` (não `let` ou `var`)
- `TOKEN_NOME` *(placeholder — representa qualquer nome real de token, ex: `TOKEN_MAIN_COLOR`)*
- `=` (espaços à volta são suportados e recomendados para legibilidade)
- `'valor'` (aspas simples, não duplas)

---

## 7. Anatomia dos Componentes

### Barra de Topo

```
┌────────────────────────────────────────────────────────────────┐
│  [⬚] Capture Engine                         [⚙] [💾] [🌙]   │
│   ↑ logo + brand name                         ↑ tb-actions    │
└────────────────────────────────────────────────────────────────┘
  height: 64px (--top-bar-h)
  Os botões [⚙] [💾] são ADMIN_BUTTONS — removidos em exports User
```

### Layout Principal

```
┌──────────────────────────────────────────────────────────────────────┐
│ BARRA DE TOPO (64px)                                                  │
├──────────────┬────────────────────────────┬──────────────────┬───────┤
│ LEFT SIDEBAR │  PAINEL IMAGENS            │  PAINEL DOCS     │ SB    │
│              │  [▲ IMAGENS  ] [count]     │  [≡ DOCUMENTOS ] │  ☰   │
│ [User     ]  │  ┌──────────────────────┐  │  ┌────────────┐  │       │
│ [Equipam. ]  │  │  drop zone / grid    │  │  │ doc list   │  │       │
│              │  │  (thumbnails 140px)  │  │  └────────────┘  │       │
│ [Auto]       │  └──────────────────────┘  │                  │       │
│ [A4V][A4H]   │                            │                  │       │
│              │                            │                  │       │
│ [PDF] [ZIP]  │                            │                  │       │
├──────────────┴────────────────────────────┴──────────────────┴───────┤
│ TRASH BAR  [🗑 Removidos  3]  ← expande ao clicar                    │
├───────────────────────────────────────────────────────────────────────┤
│ RODAPÉ  © 2026 • CAPTURE ENGINE • DIOGO CARVALHO     (opacity: 0.5)  │
└───────────────────────────────────────────────────────────────────────┘
```

### Modal de Imagem (`#img-modal-overlay`)

```
┌──────────────────────────────────────────────────────────┐
│  Visualizar imagem — imagem-1.png                   [×]  │
│   ↑ .modal-title (16px, centrado)               ↑ 32px  │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│  │                                                    │  │
│  │                    [Imagem]                        │  │
│  │                                                    │  │
│  │                               [ − ] 100% [ + ]    │  │  ← #zoom-ui
│  └────────────────────────────────────────────────────┘  │    visível
├──────────────────────────────────────────────────────────┤    apenas zoom > 100%
│  [Restaurar]  [Download]           1920 × 1080 · 245 KB  │
└──────────────────────────────────────────────────────────┘
```

*A barra `#zoom-ui` usa glassmorphism: `background: rgba(25,25,25,0.7)` + `backdrop-filter: blur(10px)`. Flutua sobre a imagem com texto sempre a `#fff` independentemente do conteúdo por baixo.*

*O fechamento por clique no backdrop está bloqueado quando zoom > 100% — evita fechamentos acidentais durante o panning.*

### Modal de Documento (`#text-modal-overlay`)

```
┌──────────────────────────────────────────────────────────┐
│  Visualizar documento — relatorio.txt               [×]  │
├──────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐  │
│  │ Texto: área de texto com fonte monoespaçada        │  │  ← modo texto
│  │ (Consolas, Monaco, monospace)                      │  │    (TXT, CSV, JSON...)
│  └────────────────────────────────────────────────────┘  │
│
│  OU, para arquivos binários (PDF, DOCX, etc.):          │
│
│  ┌────────────────────────────────────────────────────┐  │
│  │           [ícone]  PDF                             │  │  ← modo binário
│  │   Faça download para visualizar o documento        │  │    (textarea oculta)
│  └────────────────────────────────────────────────────┘  │
├──────────────────────────────────────────────────────────┤
│  [Restaurar]  [Copiar Texto]  [Download]                  │
│   ↑ só se na lixeira  ↑ oculto em modo binário           │
└──────────────────────────────────────────────────────────┘
```

**Como o motor decide entre modo texto e modo binário:**
- MIME type começa com `text/` → modo texto (visualizável inline)
- MIME type é `application/json`, `application/xml`, etc. → modo texto
- Qualquer outro MIME type → modo binário (download apenas)

---

## 8. Tipografia — Tabela de Referência

| Elemento | Tamanho | Peso | Notas |
|---|---|---|---|
| Nome da marca (topo) | `20px` | `600` | Logo principal |
| Section titles (labels uppercase) | `11px` | `600` | `letter-spacing: 0.6px` |
| Texto geral | `14px` | `400` | Body text |
| Botões `.btn-send` | `13px` | `600` | Altura `36px` |
| Ícones em botões | `14px` | — | `stroke-width: 2` |
| Ícones de cabeçalho `.blk-hdr svg` | `16px` | — | |
| Títulos de bloco `.blk-hdr-title` | `11px` | `600` | Uppercase |
| Badges `.count-badge`, `#trash-badge` | `11px` | `700` | |
| Item de histórico — nome | `12px` | `400` | |
| Item de histórico — data | `11px` | `400` | `--text-muted` |
| Título de modal `.modal-title` | `16px` | `600` | Centrado horizontalmente |
| Input de documento `.d-input` | `13px` | `400` | **Sem negrito** — não é um título, é um nome de arquivo |
| Legenda de imagem `.t-label` | `11px` | `400` | **Sem negrito** — discreta, não distrai da imagem |
| Links de ação `.pick-link` | `13px` | `400` | Em empty states |

---

## 9. Padrão de Botões em Modais

| Ação | Estilo | Cor | Quando aparece |
|---|---|---|---|
| **Restaurar** | Fill accent | `var(--accent)` + branco | Apenas se o item está na lixeira |
| **Copiar Texto** | Fill accent | `var(--accent)` + branco | Apenas em documentos de texto (não binários) |
| **Download** | Outline | `var(--surface)` + `var(--text)` + `var(--border)` | Sempre — ativos e na lixeira |
| **Confirmar** (anotação) | Fill verde | `var(--color-green)` | No modo de anotação |
| **Cancelar** (anotação) | Outline | `var(--surface)` + `var(--text)` + `var(--border)` | No modo de anotação |

---

## 10. Responsividade

A interface tem dois breakpoints de adaptação:

### `max-width: 900px` — Tablets e smartphones em paisagem

- Layout muda de horizontal para vertical (painéis empilhados)
- A sidebar de histórico (desktop: coluna lateral direita) transforma-se em um **modal centralizado** em vez de drawer lateral — aumenta a área de toque e facilita uso com o polegar
- O botão de histórico fica na barra de topo
- FAB mobile (`#mobile-paste-fab`) fica visível — botão flutuante para colar do clipboard
- `pointer-events: auto` e `touch-action: manipulation` garantem que 100% da superfície de cada card responde a toque

### `max-width: 480px` — Smartphones em retrato

- Padding e margens reduzidos para maximizar área útil
- Todos os elementos comprimem proporcionalmente

**Body Scroll Lock:** Quando o modal de histórico abre em mobile, `document.body.style.overflow = 'hidden'` previne que o conteúdo de fundo role. Ao fechar, o scroll é restaurado.

---

## 11. Comportamento de Bordas

Uma das decisões de design mais impactantes foi padronizar *quando* as bordas aparecem e desaparecem. Bordas que surgem apenas no hover criam layout shift (o elemento "salta" 1px quando o cursor passa).

### Botões de Captura ("Adicionar Imagem" / "Adicionar Documento")

| Estado | Borda |
|---|---|
| **Repouso** | `1px solid var(--border-strong)` — sempre visível, cinzenta |
| **Hover** | `border-color: var(--accent)` — transição suave para a cor accent |
| **Regra** | A borda **nunca desaparece**. Elimina layout shift. |

### Botões de Export ZIP em Modo ZIP Ativo (`.btn-zip-cta`)

| Estado | Borda |
|---|---|
| **Repouso** | `1px solid var(--accent)` — accent permanente |
| **Hover** | Fundo sutil `color-mix(in srgb, var(--accent) 6%, transparent)` + texto mais escuro |
| **Regra** | A borda accent **não desaparece** ao sair com o cursor. |

### Chips de Modo (Auto / A4 Vertical / A4 Horizontal)

| Estado | Borda | Texto |
|---|---|---|
| **Selecionado — repouso** | `1px solid var(--border-strong)` | `var(--text)` |
| **Selecionado — hover** | `border-color: var(--accent)` | `var(--text)` |
| **Não selecionado — qualquer estado** | `border: none` | `var(--text-muted)` |

*Chips inativos são sem borda em todos os estados — comunica claramente "este não está selecionado".*

### FAB Mobile (`#mobile-paste-fab`)

| Estado | Visual |
|---|---|
| **Repouso** | Ícone `var(--text-muted)`, borda `var(--border-strong)` — neutro, discreto |
| **Hover** | Ícone `var(--text)`, borda `var(--text-muted)` — reforço sutil |
| **`:active` (toque)** | Ícone e borda em `var(--accent)` — feedback preciso no momento do toque |

*O accent aparece só no `:active` (não no `:hover`) porque em mobile não há estado hover real — o dedo ou toca ou não toca.*


---

## Annotation Engine — Constantes e Estado

### Constantes de Traço

| Constante | Valor | Descrição |
|---|---|---|
| `ANN_SIZES` | `[1, 2, 4, 6, 8, 12]` | Espessuras de linha disponíveis (px, coordenadas canvas). Escala de 6 níveis (do mais fino ao mais grosso). |
| `ANN_TEXT_SIZES` | `[14, 18, 24, 36, 48]` | Tamanhos de fonte disponíveis (px canvas); index 2 = 24px padrão |
| `ANN_TEXT_LINE_RATIO` | `1.3` | Line-height ratio do texto. Constante **única** usada no `line-height` do `<textarea>` editor **e** no render do canvas (`annDrawShape`) — garante que o texto multilinha achatado é igual ao que se vê a escrever (WYSIWYG) |

### Variáveis de Estado da Anotação

| Variável | Padrão | Descrição |
|---|---|---|
| `annTool` | `'rect'` | Ferramenta ativa: `select` / `rect` / `circle` / `arrow` / `free` / `text` / `crop` |
| `annSizeIdx` | `1` (2px) | Índice em `ANN_SIZES` — espessura de linha |
| `annTextSizeIdx` | `2` (24px) | Índice em `ANN_TEXT_SIZES` — tamanho de fonte |
| `annTextBold` | `true` | Negrito ativo na ferramenta texto |
| `annTextItalic` | `false` | Itálico ativo na ferramenta texto |
| `annEditingTextIdx` | `-1` | Índice em `annHistory` do texto em reedição; `-1` = novo texto |
| `annTextClickTimer` | `null` | Timer 220ms para distinguir single-click de dblclick |
| `annSmoothLast` | `null` | Último ponto EMA no desenho livre (α=0.35); reset em activate/deactivate/mouseup |

### Tokens CSS do Motor de Reordenação

Estas variáveis CSS controlam a aparência do placeholder de arrasto (o espaço vazio que aparece durante a reordenação de itens). **Requerem edição direta do `capture-engine.html`** — não são expostas no Visual Builder e não viajam com o Export (o Quine não substitui variáveis CSS, apenas tokens `TOKEN_*`).

| Token CSS | Valor padrão (via `color-mix`) | Descrição |
|---|---|---|
| `--drop-ph-bg` | `color-mix(in srgb, var(--text) 5%, transparent)` | Cor de fundo do placeholder de arrasto — área muito sutil que indica onde o item irá cair. Alterável apenas por desenvolvedor com acesso ao código-fonte. |
| `--drop-ph-border` | `color-mix(in srgb, var(--text) 8%, transparent)` | Cor da borda do placeholder de arrasto. Ligeiramente mais visível que o fundo para delimitar a área. Alterável apenas por desenvolvedor com acesso ao código-fonte. |

### Formato de Entradas em `annHistory`

Cada entrada é um objeto com pelo menos `{type, color, lw}` e campos adicionais por tipo:

| `type` | Campos obrigatórios | Notas |
|---|---|---|
| `rect` | `x1, y1, x2, y2` | Coordenadas dos dois cantos opostos |
| `circle` | `x1, y1, x2, y2` | Bounding box da elipse |
| `arrow` | `x1, y1, x2, y2` | Origem → destino da seta |
| `free` | `pts: [{x,y}]`, `closed` (sempre `false` desde a V23) | Salvo com **os mesmos pontos do preview** (`annPath`) — sem simplificação RDP e sem fechamento automático do contorno. Ver changelog V23. |
| `text` | `x1, y1, txt, bold, italic, fontSize` | `txt` pode conter `\n` (multilinha) — `annDrawShape` desenha linha a linha com `lineH = fontSize × ANN_TEXT_LINE_RATIO`. `textBaseline='top'`; `x1/y1` = canto superior esquerdo da 1.ª linha |


---

*Capture Engine V26 · Especificações de Design Tokens*
