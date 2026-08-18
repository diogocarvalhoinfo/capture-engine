# Changelog · Capture Engine

> Histórico de versões desde a V7 (base da arquitetura atual; V1–V6 anteriores à arquitetura Quine). Cada entrada explica **o que mudou**, **porquê mudou**, e **o impacto real** para o usuário.
> Formato: `### Adicionado` — nova funcionalidade. `### Modificado` — comportamento existente alterado. `### Corrigido` — bug eliminado.

---

## [V26] — 2026-08-16

Versão de correção, originada de quatro auditorias independentes sobre a V25. O achado central: o **Export User nunca produziu um arquivo funcional** — defeito presente desde pelo menos a V11 e nunca detectado, porque a validação estática cobre o arquivo de administrador e não o produto do export.

### Validação da release

**Prova de vida dos dois exports — executada sobre o estado final (D63, completada na D64).** O `agents.md §12` torna-a obrigatória antes de fechar uma release. Na publicação da V26 foi conscientemente saltada, e a pendência ficou aberta enquanto entraram mais correções, várias delas em código. Corrida agora sobre o estado do commit `8708455`, com o artefato gerado pelo **botão Export da própria aplicação** — nunca com o `capture-engine.html` de desenvolvimento, como o procedimento exige.

| Passo | Resultado |
|---|---|
| Export User pelo botão | `CAPTURE-ENGINE-06h21m-18-ago-2026.html`, 298.376 bytes |
| Zero erros na consola | ✅ — assinatura do defeito D25 (`Cannot read properties of null`) **ausente** |
| A aplicação responde | ✅ imagem colada aparece na grade |
| A sessão persiste | ✅ a sessão fica no histórico e reabre íntegra — **o campo não sobrevive à recarga, e não devia**: a aplicação arranca sempre limpa, por desenho |
| Configurações aplicadas | ✅ rodapé `© 2026 • CAPTURE ENGINE • DIOGO CARVALHO`, acento `#e86b2e`, título |
| Sem admin nem Visual Builder | ✅ `btn-admin-config`, `vb-overlay` e `export-overlay` todos ausentes |
| Multi-aba | ✅ 2.ª aba carrega e responde; a 1.ª continua a aceitar imagens depois disso; ambas partilham a mesma base |

Os passos de **interação** são os que o procedimento marca como não dispensáveis: no defeito D25 a interface renderizava por completo, porque isso é HTML estático, e só a interação revelava que nada estava ligado. O rodapé é o sinal mais informativo dos três de configuração — é escrito pelo `applyTokens`, a função que a D25 teve de corrigir com guardas por grupo em vez de `return` antecipado, precisamente por escrever coisas de administração e de utilizador de forma entrelaçada. Estar correto no artefato User mostra que essa correção continua de pé.

**Duas correções ao próprio teste, na primeira passagem:** o passo das configurações devolveu `null` para o rodapé por o seletor estar errado — não estava a verificar coisa nenhuma —, e a linha «a 1.ª aba continua viva» era uma afirmação fixa, não uma medição. Ambos refeitos: o rodapé passou a ser comparado com o valor esperado do token, e a 1.ª aba prova estar viva por continuar a aceitar imagens **depois** de a 2.ª abrir.

**Export Admin e cadeia de re-export (D64).** A linha «Export Admin → a cópia mantém o painel de administração e a capacidade de re-exportar» do mesmo checklist **não tinha sido executada** quando a D63 foi registada; a lacuna foi apanhada pelo proprietário ao rever o registo. É a verificação mais relevante depois de alterações ao `capture-engine.html` — a **D40** existiu precisamente porque a segunda geração de export morria, e a D52 e a D54 desta ronda tocaram no arquivo.

| | bytes | md5 |
|---|---|---|
| `capture-engine.html` (fonte) | 316.308 | `eab02cb0` |
| Export Admin (G1) | 316.308 | `eab02cb0` |
| Re-export a partir de G1 (G2) | 316.308 | `eab02cb0` |
| Re-export a partir de G2 (G3) | 316.308 | `eab02cb0` |
| Export User feito a partir de G1 | 298.376 | `394c5e28` |

**Servido por `http(s)`, o Export Admin é byte-idêntico à fonte e mantém-se idêntico ao longo de três gerações encadeadas.** ⚠️ **A condição não é decorativa e faltava aqui — ver D66:** em `file://`, que o `README §10` declara ser o modo de uso pretendido, o `fetch` é bloqueado por CORS, o Quine exporta o `BOOT_HTML`, e o artefato sai com `316.354` bytes / `f94ac992` — HTML equivalente, re-serializado pelo browser. Também aí é ponto fixo (G1 = G2 = G3, todas vivas), mas **noutro ponto**. A tabela acima é a do protocolo `http(s)`. Cada geração foi aberta em browser e exercitada com interação real, não apenas inspecionada: G1, G2 e G3 aceitam imagens, mantêm o painel de administração e a `window.exportFile`, e preservam rodapé e acento. O último passo cobre o caminho que um administrador percorre em produção: gerar o artefato de utilizador a partir de uma cópia já exportada — vivo, e sem `btn-admin-config`, `vb-overlay` ou `export-overlay`.

Zero erros de consola em qualquer das cinco aberturas.

### Corrigido

**`agents.md` — três imprecisões na documentação de leitura obrigatória (D69):**

- **A semântica do `BOOT_HTML` estava invertida (M5).** Dois avisos técnicos da `§1.2` diziam que, sem ele ou com um servidor dinâmico, «o Quine exportaria **o DOM mutado pelo runtime** (com contadores atualizados, legendas editadas)». Nenhum dos cenários produz isso. O DOM é lido **uma única vez**, no arranque — `documentElement.outerHTML` ocorre exatamente uma vez no arquivo — e é precisamente isso que o `BOOT_HTML` é. Com um servidor dinâmico exportar-se-ia o que o servidor devolveu; sem `BOOT_HTML` e com o `fetch` a falhar, o `PRISTINE_HTML` ficaria `null` e o export **abortaria** pelo guard `if (!PRISTINE_HTML) … return`. A formulação apresentava o `BOOT_HTML` como defesa contra a mutação do DOM quando ele **é** a serialização do DOM: o que o protege é o *momento* em que é tirado.
- **Resíduo da D60 (M6).** A `§12` ainda dizia «presença das **7 ferramentas** de anotação»; o array testado tem 8 entradas, o script imprime `(8/8)`, e a `§10` do mesmo documento já dizia 8. A D60 atualizou a `§10` e a âncora do `validate.sh` e não chegou à `§12` — **sexta ocorrência** de corrigir onde se procurou.
- **Duas numerações em conflito para os mesmos checks (M6).** A mesma nota citava «checks #11 e #12», que são os números dos comentários internos do `validate.sh`, enquanto a `§10` numera as mesmas verificações como 18 e 19 na lista de 27. Quem procurasse «o check 12» encontrava coisas diferentes conforme o documento. Fica declarado que existem duas numerações e que se deve dizer de qual se fala.
- **A tabela da CSP escrita na D50 repetia o erro que a D62 corrigiu (B8).** A linha do `default-src` dizia «Nenhum recurso de outra origem carrega», o que sugere uma regra única que cobre tudo. Não cobre: `script-src`, `style-src`, `img-src` e `connect-src` **substituem-no** para os respetivos tipos. É exatamente a confusão que a D62 tinha corrigido no README — e que ficou por corrigir na tabela que eu próprio escrevera duas entradas antes.

**Três afirmações falsas escritas pela própria ronda anterior (D68):** a quinta auditoria reproduziu as três. Nenhuma alterava código — todas eram justificações no changelog, escritas com a palavra «Contado» ou «Reproduzido», que é precisamente o que convida um leitor a confiar sem verificar.

- **«campo User sobrevive à recarga» (M3).** Falso, e o checklist da `§11 Parte B` está correto onde o resumo não estava: o passo 5 pede «confirmar que **a sessão está no histórico**». Medido: antes da recarga o campo tem `PERITO-M3` e há 1 miniatura; depois, campo vazio e 0 miniaturas; o IndexedDB mantém a sessão intacta e reabri-la pelo histórico devolve o campo e a miniatura. **A aplicação arranca sempre limpa, por desenho** (`agents.md`: «Abrir o arquivo → interface limpa, campos vazios»). O resumo trocou o critério por um mais forte e falso — quem reproduzisse a prova de vida a partir dele concluiria que houve regressão.
- **«a barra de anotação tem 17 botões» (M4).** Medido no DOM vivo: **24**, 22 visíveis. A minha enumeração omitiu os **8 swatches de cor**, que são `<button>` de pleno direito, e incluiu o `ann-toggle`, que não pertence à barra e está oculto durante a anotação. A aritmética fecha: `17 − 1 + 8 = 24`. **O texto que ficou no README está correto** — «8 afordâncias de desenho» —; o erro vivia só na justificação, e é a mesma classe de defeito que a entrada estava a corrigir.
- **«`imgToJPEG` só existe dentro de `generatePDF`» (B4).** São funções **irmãs de topo**, linhas 5456 e 5457. A medição estava certa e a conclusão também — o token nunca toca no armazenamento —, mas a frase descreve um aninhamento que não existe. Passa a «só é **chamada** por `generatePDF`», que é o facto verificado.

O padrão comum às três é escrever a conclusão com a autoridade da medição sem que a frase diga exatamente o que foi medido. As três teriam sobrevivido a qualquer releitura; só caíram porque alguém as foi reproduzir.

**`validate.sh` — três defeitos nos checks que a ronda anterior endureceu (D67):** a D58 e a D59 melhoraram checks reais, mas cada uma deixou um defeito próprio, e a quinta auditoria reproduziu os três.

- **Falsos positivos sobre prosa (M1).** O padrão da D58 herdou do antigo as substrings nuas `cdn.` e `googleapis`. Um comentário a dizer «não usar `cdn.` de terceiros» dava `[FAIL]`. **Medido antes de remover:** as 7 formas da matriz continuam todas apanhadas sem elas — incluindo `href='//cdn.foo/x.css'`, que casa pela forma protocol-relative — e os 3 casos de prosa passam a `[PASS]`. As substrings não detetavam nada que a estrutura não detetasse já.
- **O escape do ponto era um no-op (M2).** A D59 escreveu `sed 's/\./\./g'`, que substitui ponto por ponto. O `window.exportFile` entrava na regex com o ponto por escapar, onde casava qualquer caractere. Reproduzido: `windowZexportFile` satisfazia o check. Passou a ser feito em Python com `re.escape` — e agora `windowZexportFile` dá `[FAIL]`.
- **A contagem exibida era de linhas, não de ocorrências (B7).** `grep -cE` conta linhas; com o JS em linhas longas o número era sempre `1`, sugerindo uma unicidade que não estava a ser verificada. Reproduzido: duas definições de `escapeHTML` na mesma linha exibiam `(1)`; agora exibem `(2)`.

**Um furo que ficou por fechar, de propósito.** A auditoria mostrou que uma definição escrita **dentro de um comentário** satisfaz os checks 2 a 5. Tentei fechá-lo removendo comentários antes de casar, e o removedor falhou — pela mesma razão que já mordeu a D54: este arquivo tem literais de regex com aspas lá dentro e comentários com apóstrofos, e ambos partem qualquer scanner ingénuo. **Escrever mais um scanner frágil para fechar o furo seria repetir o defeito que passamos a vida a corrigir.** O limite fica declarado na `§10` do `agents.md`: estes checks provam que a sintaxe de definição não desapareceu, não que a função corre — isso é a prova de vida da `§11 Parte B` e o check 27.

**A prova de vida das D63/D64 não declarava o protocolo em que correu (D66):** os números registados — `316.308` bytes, md5 `eab02cb0`, idênticos em três gerações — foram medidos com a aplicação servida por `http://127.0.0.1`. O `README §10` declara que a ferramenta «foi desenhada para uso local (protocolo `file://`)» e o `§4` manda «fazer duplo clique em `capture-engine.html`». **Medi os dois:**

| Protocolo | Export Admin | md5 | G1 = G2 = G3 |
|---|---|---|---|
| `http(s)` | 316.308 bytes | `eab02cb0` | sim, e igual à fonte |
| `file://` | 316.354 bytes | `f94ac992` | sim, mas noutro ponto fixo |

A causa está no `BOOT_HTML`, que é `'<!DOCTYPE html>' + document.documentElement.outerHTML` **capturado no arranque**. Em `file://` o `fetch(location.href)` é recusado por CORS, o `capturePristine()` cai no fallback, e o que se exporta é a serialização do DOM feita pelo browser: `<circle …/>` passa a `<circle …></circle>`, atributos multi-linha colapsam, 5509 linhas passam a 5442. **Não há deriva** — a segunda serialização de um DOM já serializado é idêntica à primeira, e confirmei G1 = G2 = G3 com as três gerações vivas, painel de administração presente, rodapé e acento corretos.

Corrigido também o passo 3 do checklist da `§11 Parte B`, que exigia «zero erros no console» **sem exceção**. Em `file://` aparece sempre `Fetch API cannot load file:///…` seguido de `[CE] Quine fallback: BOOT_HTML`. O critério era impossível de cumprir no modo de uso declarado, o que convida a ignorá-lo — exatamente o oposto do que uma prova de vida obrigatória precisa. Passa a tolerar **esse par e mais nenhum**.

**`README §5.7` — a garantia do GIF que sobreviveu à D53 (D65):** a D53 corrigiu a mesma garantia na tabela de **Limitações** e deixou-a intacta na lista de funcionalidades do `§5.7`, três secções acima. A linha dizia «GIF animados no formato original, com animação intacta», sem qualquer ressalva — e contradizia a linha imediatamente anterior, que já declara «Imagens **anotadas, rodadas ou recortadas** como PNG novo».

O que torna esta ocorrência instrutiva é a entrada da própria D53, que escreveu «**Quarta ocorrência do mesmo padrão desta versão: corrigir onde se procurou**» — e voltou a fazê-lo na mesma frase em que o declarava. É a **quinta**. A varredura de irmãos foi feita sobre a tabela de Limitações e não sobre o documento.

Verificado que o comportamento em si está correto: a extensão no ZIP deriva de `img.blob.type`, portanto um GIF anotado sai nomeado `.png` e não como um `.gif` estático mal rotulado. O defeito era exclusivamente da garantia escrita.

**`README` — a mecânica da CSP estava descrita ao contrário (D62):** a linha atribuía o bloqueio de scripts externos ao `default-src`. O resultado afirmado está certo, mas pela razão oposta: quando o `script-src` está declarado, substitui o `default-src` para scripts, e como não nomeia nenhuma origem de URL — nem sequer a própria — recusa tudo o que não seja inline. É **mais** restritivo do que o `default-src` sozinho daria. A D50 documentou a mecânica correta no `agents.md`; esta entrada alinha o README, que até aqui divergia dele.

**`README` — o custo do `origBlob` faltava onde mais importa (D61):** a secção que ensina a gerir quota afirma «não existe forma de reduzir o espaço que cada captura ocupa», o que é verdade para a captura. Omitia que confirmar a primeira anotação, rotação ou recorte acrescenta um **segundo** blob ao mesmo registo — o original preservado para poder desfazer — aproximadamente duplicando o custo. É informação relevante precisamente na secção sobre quota.

**`README` — «8 botões no editor» (D60):** a taxonomia introduzida pela D31 (7 ferramentas + 1 ação) está correta e é a informação útil; a formulação é que era falsa. **Contado no DOM vivo, com o modo de anotação aberto:** a barra tem **24 botões**, 22 deles visíveis — os 7 `data-tool`, os **8 swatches de cor**, mais rodar, desfazer, refazer, espessura (dois), negrito e itálico (só visíveis com a ferramenta de texto ativa), guardar e cancelar. O `ann-toggle` **não pertence à barra**. Passa a «8 afordâncias de desenho», com uma linha a declarar os restantes controlos. A âncora do check 19 no `validate.sh` foi atualizada em conjunto, por depender desta frase. **Reverificados os três ramos do check:** remover a ação dá FAIL na Rotação, remover uma ferramenta dá FAIL no Crop, e apagar a linha dá FAIL de lista ausente.

**`validate.sh` — «função presente» significava «o nome aparece algures» (D59):** os checks 2 a 5 contavam ocorrências do nome e davam PASS com qualquer uma — uma menção em comentário ou numa chamada bastava. **Reproduzido:** renomeando a definição de `escapeHTML` e deixando as 11 menções intactas, o check antigo dava `[PASS] (5)` e o novo dá `[FAIL] Funcao NAO DEFINIDA`. Passa a casar a sintaxe de definição, quer declaração quer atribuição — que é como a `window.exportFile` está escrita. Corrigidos também os rótulos no `agents.md`: «Garante a proteção XSS» era uma promessa que uma contagem de linhas não pode sustentar, e passa a declarar o que o check realmente prova.

**`validate.sh` — o check de zero-dependência prometia mais do que cobria (D58):** o padrão antigo não detetava atributos com aspas simples, `url()` em CSS, `@import`, `fetch()` para URL externo, nem URLs protocol-relative. **Medido:** de sete formas de injetar um recurso externo, o padrão antigo apanhava **uma**; o novo apanha as sete. O padrão passa a visar **construtos de carregamento** e não a string `http` — necessário porque o arquivo contém legitimamente http(s) no comentário de licença e no `xmlns` do SVG inline, e nenhum dos dois é carregado. Continua a dar 0 no arquivo limpo. A CSP continua a ser a defesa real; o que estava errado era a promessa do rótulo.

**`agents.md` — referência cruzada para informação inexistente (D57):** a descrição do check 25 dizia que o tamanho é validado «na faixa documentada no README §10 (~280–340 KB)». O README §10 dá apenas a ordem de grandeza («ronda os ≈ 300 KB») e não declara faixa nenhuma — os limites `280000-340000` existem só no `validate.sh`. Passa a declarar os números e a dizer onde vivem, para que alterar o limiar não mande ninguém procurar um segundo sítio que não existe.

**Changelog — a D32 contradizia a D34 dentro da mesma versão (D56):** a D32 declarava que o banner de armazenamento indisponível «continua **sem botão de fechar**»; a D34, mais abaixo na mesma secção, acrescentou-lhe o mesmo ✕. Lê-se bem como narrativa de duas iterações, mas quem consultar só a D32 fica com informação errada sobre o estado atual. A entrada passa a declarar-se superada e a apontar para a D34.

**`agents.md §14` — o procedimento de recurso perdia o original (D55):** os dois scripts de extração de emergência descarregavam `item.blob` e nunca mencionavam `origBlob`. O `AVISO CRÍTICO` da D44 é exato ao falar da **interface**, mas o `§14` é o procedimento oficial *fora* da interface, escrito para «extrair os dados puros» quando o HTML estiver inoperável. Quem o executasse obtinha o PNG anotado. Ambos os scripts passam a extrair os dois blobs, com o original sufixado `-ORIGINAL`. Sintaxe dos snippets verificada com `node --check`.

**Reordenação — o ecrã podia mentir sobre o que ficou gravado (D54):** o `initReorder` persiste a nova ordem com um `await idbPut` por registo, sem `try/catch`. A escrita não é atómica: se falhar a meio, o array em memória já está renumerado enquanto o IndexedDB ficou misto.

**Uma correção à classificação da auditoria:** ela descreveu o achado como «sem haver `catch` a sinalizá-la». A sinalização existe — o `idbTx` chama `showQuotaBanner()` e rejeita, uma camada abaixo de todos os chamadores. O utilizador **é** avisado. O defeito residual é outro e mais subtil: a rejeição ficava sem tratamento e a vista continuava a mostrar uma ordem que não sobreviveria à recarga.

Acrescentado `try/catch` que regista o erro e recarrega a sessão, repondo a vista a partir do que ficou mesmo gravado. **Reproduzido em browser real:** com o `put` do IndexedDB a lançar `QuotaExceededError`, o `catch` dispara, a base fica intacta em `[0,1,2]` e o ecrã volta a coincidir com ela. No caminho feliz o arrasto persiste e sobrevive à recarga, sem ordens duplicadas.

**Uma armadilha descoberta ao fazer isto, agora documentada no `§10`:** o medidor de complexidade do `validate.sh` não ignora comentários e trata o apóstrofo como abertura de string. O comentário que escrevi tinha três apóstrofos e a contagem **desceu** de 47 para 38 — acrescentar código e ver o CC baixar é o sintoma. Reescrito sem apóstrofos, aparecem os valores reais: `initReorder` 47→48 e `onUp` 15→16, ambos atualizados na tabela.

**`README` — a garantia do GIF sobreviveu à D44 (D53):** a D44 enumerou três sítios onde o ZIP prometia o original e corrigiu os três. Esta linha, na tabela de **Limitações**, garantia «O export ZIP inclui o arquivo GIF original com a animação intacta». Falso depois de anotar: o `ann-save` regenera a imagem em PNG a partir do canvas. Verificado que a extensão no ZIP vem de `img.blob.type`, portanto o arquivo sai corretamente nomeado `.png` — o defeito é só a garantia, não um ficheiro mal rotulado. A linha passa a separar os dois estados: sem edição e depois de editar. Quarta ocorrência do mesmo padrão desta versão: corrigir onde se procurou.

**Visual Builder — a copy contradizia a D31 no sítio onde ela mais importa (D52):** o campo «Dimensão máxima» descrevia-se como «Redimensionar imagens maiores que o limite». A D31 corrigiu três documentos e deixou intacto o texto que o administrador lê **enquanto configura**. Reproduzido: o `TOKEN_MAX_IMG_DIMENSION` só é lido dentro de `imgToJPEG`, e `imgToJPEG` só é **chamada** por `generatePDF` — o token nunca toca no armazenamento. Era exatamente o cenário que a D31 descreveu: «um administrador que o configurasse para reduzir consumo de disco não obtinha redução nenhuma». Passa a «Reduz as imagens acima do limite ao gerar o PDF; não afeta o que fica guardado». Verificado em browser real.

**`agents.md` — a CSP existia no produto e não existia na doc de leitura obrigatória (D50):** o `capture-engine.html` traz uma metatag `Content-Security-Policy` desde antes desta versão. O `README` descreve-a em três sítios; o `agents.md` — o documento que um agente lê **antes de editar** — não a mencionava nenhuma vez. Quem acrescentasse um recurso externo veria o browser recusá-lo sem encontrar na doc a razão.

Acrescentada à `§1.4` a metatag verbatim, uma tabela por diretiva, e o aviso que motiva a entrada: **`connect-src 'self'` é o que mantém o Quine vivo.** O `capturePristine()` faz `fetch(location.href)`; apertar essa diretiva para `'none'` não produz erro visível — o `fetch` falha, a função cai no fallback `BOOT_HTML`, e o export continua a produzir um arquivo estruturalmente válido, mas desatualizado. O `validate.sh` não apanha essa falha, precisamente por o artefato continuar válido. **Sem alteração de código nem de pixel.**

**`design-tokens.md §2.1` cobria 5 das 9 categorias de cor literal (D51):** a secção criada na D33 existe para cortar o ciclo de auditorias que reportam cores literais como violação do contrato. Não cumpria a função: o código tem 9 categorias e a tabela declarava 5. Medido — as ausentes eram o chrome do modal de imagem (`#e0e0e0`, `#2a2a2a`, `#3f3f3f`, `#363636`, `#555555`, `#121212`), o `#16a34a` do hover do `#btn-admin-save`, o `#e86b2e` do valor padrão do `TOKEN_MAIN_COLOR`, os stops do gradiente do logo SVG, o `#000000` das metatags de tema, e o cálculo YIQ de contraste.

Duas causas, ambas corrigidas na estrutura e não no leitor:

- A linha dos swatches dizia «`#ef4444` `#f97316` `#22c55e` `#eab308` **e restantes swatches**». O apanha-tudo tornava a tabela impossível de verificar mecanicamente — passou a enumerar os 8, com a instrução explícita de nunca voltar a escrever «e restantes».
- Não existia forma de comparar a tabela com o código. Acrescentado um comando `comm` que devolve exatamente as cores presentes no HTML e ausentes da secção; **devolve vazio no estado atual**. Fica documentada também a armadilha que apanhei ao escrevê-lo: filtrar as declarações de custom property tem de acontecer **por linha, antes** de extrair as cores — filtrar depois não faz nada, porque já não há contexto de linha.

Corrigida ainda a entrada da D33 acima, que afirmava «todas as cores». **Sem alteração de código nem de pixel.**

**`validate.sh` — o check de ferramentas passou a poder reprovar (D41):** a D29 declarou este check corrigido, mas a correção era ineficaz e as três auditorias apanharam-no. Dois defeitos: procurava cada termo no **README inteiro** com `grep -qi`, e a palavra «texto» ocorre 27 vezes noutros contextos — logo o termo mais importante nunca podia falhar; e a contagem exibida vinha de `ADMIN_TOOLS_ESPERADAS=8`, uma constante à parte que podia dessincronizar-se da lista.

A procura passou a ser feita **na linha que enumera as afordâncias** («botões no editor»), e a contagem deriva do próprio array (`${#ANN_TOOLS[@]}`). Demonstrado: removendo `texto (negrito B / itálico I)` da lista, o check agora dá `[FAIL] Ferramenta ausente da lista no README.md: 'texto'` — antes dava `[PASS] (8/8)`. Acrescentado também um FAIL para o caso de a própria linha desaparecer do README.

**Documentação — três divergências que a D30 não apanhou (D42):**

- **`agents.md §4` e `§7`, `createSession()`** — ambas diziam «Apenas em `init()` e `ensureSession()`». O `init()` **não** o chama: a única chamada está em `ensureSession()`. A afirmação contradizia a própria `§4`, que descreve o arranque como estado pristine **sem sessão criada**.
- **`agents.md §14`** — o cabeçalho do diagnóstico de quota ainda dizia «capturas desaparecem ao reabrir **sem aviso na UI**». A D30 corrigiu a afirmação equivalente na `§6` e não viu esta. A interface avisa desde a D9, com o banner vermelho.
- **`agents.md §6`** — dizia que itens na lixeira «**não têm** campo `order`». Têm: `delImg`/`delDoc` fazem `splice` e acrescentam `removedAt`, sem apagar o `order`. O que é verdade é que a lixeira **ordena por `removedAt`** e ignora aquele valor.

**`README §5.5` — botão de apagar definitivo que nunca existiu (D43):** a tabela da Lixeira documentava «Apagar definitivamente · Dentro do modal do item → botão de apagar permanente». Verificado no browser: o modal de um item na lixeira tem exatamente três botões — `Fechar`, `Restaurar` e `Download`. Não há apagar permanente em lado nenhum da interface. Linha removida e substituída por uma nota a declarar as duas únicas vias de saída da lixeira: restauro ou expiração da sessão.

**Documentação — o ZIP não leva o original de imagens editadas (D44):** o `README`, na secção de uso probatório, garantia «Exportação ZIP com os arquivos originais sem reprocessamento adicional». É verdade para imagens não editadas — verificado, os bytes do ZIP são idênticos aos do arquivo capturado. É **falso** assim que a imagem é anotada, rodada ou recortada: o `ann-save` regenera o PNG a partir do canvas, e o `generateZIP` lê `img.blob`, nunca `origBlob`.

**O que a investigação corrigiu numa auditoria anterior:** um dos relatórios classificou isto como `Crítico`, descrevendo-o como perda silenciosa de evidência — o original desapareceria. **Não desaparece.** Medido: numa imagem com anotação, o registo guarda `origBlob` com **exatamente** os bytes do original, ao lado do `blob` editado. O motor de anotação preserva-o corretamente para permitir reedição e desfazer. O achado é, portanto, `Médio` e de **contrato documental**, não de perda de dados.

**Decisão do proprietário: corrigir a documentação, não o código.** Exportar o original em vez do editado seria errado — perderia as anotações, que são o trabalho de perícia. Incluir ambos no ZIP foi considerado e recusado. O comportamento atual mantém-se: o ZIP leva o que se vê.

Ajustadas as três afirmações afetadas — a lista do `§5.7`, a garantia da secção probatória, e a descrição do `generateZIP` no `agents.md §7`, que agora regista explicitamente que a função nunca lê `origBlob`. Acrescentado um `AVISO CRÍTICO` na secção probatória com a consequência prática: **o original de uma imagem editada não é recuperável por nenhuma via da interface**, pelo que quem precise de integridade pixel-a-pixel tem de exportar o ZIP **antes** de editar.

**`agents.md §1.2` exibia o padrão de regex que a D40 eliminou (D48):** a nota «Proteção de colisão do regex» dava como exemplo `/const TOKEN_MAIN_COLOR\s*=\s*'[^']*'/` — exatamente o padrão que mata o artefato na segunda geração de export, e que o aviso crítico da `§1.3`, **27 linhas abaixo**, declara «sempre errado aqui». O documento contradizia-se dentro da mesma secção de leitura obrigatória, e o lado errado era o que um agente lê primeiro.

A D40 corrigiu o código e acrescentou o aviso na `§1.3`, mas não olhou para o exemplo da `§1.2`. Mesma classe da D30 e da D42: corrigir onde se procurou, não onde não se procurou. Verificado por comparação mecânica — o exemplo da doc e a regex do `exportFile` são agora byte a byte idênticos, e não resta nenhum outro exemplo com o padrão antigo na documentação.

**`README §8` — «preserva o PNG original intacto» era ambíguo (D49):** a quarta auditoria classificou esta frase como `Alto`, por contradizer a D44. **Testado e rebaixado para `Baixo`.**

A frase vive na linha sobre **transparência**, contrastando PDF (que achata com fundo branco) com ZIP. Medido com um PNG de 20.000 pixéis transparentes: sem anotar, o ZIP devolve o arquivo **byte a byte idêntico**; depois de anotar, o `origBlob` continua preservado e igual ao original, e **a transparência sobrevive ao re-encode** (19.754 pixéis com alfa 0). O que a frase afirma no seu contexto — ZIP não achata a transparência — é verdade, e continua verdade em imagens editadas.

O resíduo legítimo era a palavra «intacto», ambígua quanto a bytes. Reescrita para declarar as duas coisas separadamente: a transparência preserva-se sempre; a igualdade byte a byte só em imagens não editadas. Fica registado que a classificação `Alto` foi testada antes de ser aceite — a auditoria leu a frase fora do contexto em que ela vive.

**`validate.sh` — elimina a fragilidade que a D46 deixou (D47):** a D46 resolveu o furo cortando a linha em `A distinção é técnica`. Funcionava, mas acoplava o check a uma frase editorial: se alguém reescrevesse essa frase, o corte deixava de acontecer e o check **regressava em silêncio** ao comportamento defeituoso da D41 — voltaria a deixar passar a remoção de `Rotação`. Mesmo padrão que já mordeu três vezes: procurar num âmbito que contém texto irrelevante.

**Corrigida a estrutura, não o parser.** A linha do `README §5.3` foi dividida: a enumeração fica sozinha, e a explicação passou para a linha seguinte, indentada como sub-item. O check deixou de precisar de recortar seja o que for — lê a linha e ela contém apenas a lista.

Para a fragilidade não voltar por outra via, o check passou também a **verificar a estrutura**: se a prosa reaparecer na linha da enumeração, falha com `Linha das ferramentas tem prosa misturada (mover a explicacao para a linha seguinte)`. A degradação silenciosa converteu-se em falha alta com instrução.

Verificado com cinco mutações: intacto (PASS), sem `texto` (FAIL), sem `Rotação 90°` (FAIL), sem `Crop` (FAIL), e prosa refundida na mesma linha (FAIL, com a mensagem estrutural).

**`validate.sh` — o check de ferramentas ainda tinha um furo (D46):** a D41 restringiu a busca à linha que enumera as afordâncias, resolvendo o caso de `texto`. Mas a linha continua, depois da enumeração, com prosa explicativa que **repete termos**: «…a distinção é técnica: as 7 ferramentas são valores de `annTool`… **a rotação** executa e termina». Resultado: remover `— e **1 ação**, Rotação 90°.` da enumeração continuava a dar `[PASS] (8/8)`.

Foi o mesmo defeito da D29 reintroduzido à escala da linha — procurar num âmbito que contém texto irrelevante que casa. Encontrado pela quarta auditoria, que testou exatamente essa mutação.

**Correção:** a linha passa a ser cortada em `A distinção é técnica`, restringindo a busca à enumeração propriamente dita. Verificado com quatro mutações — intacto (PASS), sem `texto` (FAIL), sem `Rotação 90°` (FAIL), sem `Crop` (FAIL) —, cada uma a acusar o termo correto.

**Ordem dos itens deixava de ser determinística após apagar (D45):** os quatro sítios que atribuem `order` — `captureImg`, `captureDoc`, `restoreImg`, `restoreDoc` — usavam `arr.length`. Mas `delImg`/`delDoc` fazem `splice` do array **sem renumerar os restantes**, pelo que o `length` volta a coincidir com um `order` que ainda existe.

Com A(0), B(1), C(2), apagar o B deixa `length = 2` — e tanto restaurar o B como **capturar uma imagem nova** atribui `order = 2`, colidindo com o C. O `loadSession` ordena por `a.order - b.order`, e o empate resolve-se de forma diferente da ordem que estava no ecrã: **a ordem mudava sozinha ao reabrir a sessão**, e o PDF/ZIP exportado seguia a que estivesse em memória.

**Reproduzido em browser real** antes da correção: grade em `imagem-1, imagem-3, imagem-2`; após recarregar, `imagem-1, imagem-2, imagem-3`. No IndexedDB, `imagem-2(order=2)` e `imagem-3(order=2)`.

O gatilho mais provável não é apagar+restaurar — é **apagar e colar outra imagem**, que é rotina. E os documentos tinham exatamente o mesmo defeito.

**Correção:** helper `nextOrder(arr)` que devolve `max(order) + 1`, usado nos quatro sítios. Escolhido em vez de renumerar no delete por duas razões: renumerar exigiria N escritas separadas, **não atómicas** (`idbPut` não agrupa), e uma falha a meio — o modo de falha mais documentado desta app é esgotamento de quota — deixaria exatamente as ordens duplicadas que se pretendia corrigir; e o custo de apagar um item passaria a ser proporcional ao tamanho da sessão. O `max+1` escreve **um** registo e nunca colide.

As ordens ficam esparsas (`0, 3, 2, 4` no teste), o que é inofensivo: o `sort` não se importa com lacunas, e o motor de reordenação já renumera densamente (`obj.order = i`) a cada arrasto, pelo que qualquer lacuna desaparece no primeiro reordenamento.

**Verificado:** com o cenário completo — apagar do meio, restaurar, e capturar uma quarta imagem — zero ordens duplicadas, e a ordem passou a ser idêntica antes e depois de reabrir a sessão.

**Quine — o re-export produzia um arquivo morto quando um token continha apóstrofo (D40):** as 11 regexes de substituição de tokens de texto no `exportFile` usavam `'[^']*'`, padrão que **para no primeiro apóstrofo mesmo quando escapado**. O `sanitizeForQuine` escapa corretamente (`'` → `\'`), pelo que a **primeira** geração saía válida; mas ao re-exportar a partir dela, a regex encontrava o `\'` dentro da string e cortava a declaração a meio.

**Reproduzido de ponta a ponta em browser real**, com o `exportFile` da própria aplicação. Com o rodapé `Perícia d'Almeida - {YEAR}`:

| | Antes da D40 | Depois |
|---|---|---|
| Geração 1 | viva, rodapé correto | viva |
| Geração 2 | **morta** — `SyntaxError`, zero funções globais | viva |
| Geração 3 | — | viva |

A declaração corrompida era `const TOKEN_FOOTER_TEXT = 'Perícia d\'Almeida - {YEAR}'Almeida - {YEAR}';`. Por ser erro de sintaxe no parse, o bloco `<script>` inteiro não compilava: nem as funções declaradas antes do ponto de falha existiam — pior que a D25. O sintoma visível era o rodapé mostrar o valor **padrão** em vez do configurado, sinal de que o `applyTokens` nunca correra.

**Correção:** as 11 regexes passaram a `'(?:[^'\\]|\\.)*'`, que consome pares escapados como unidade. Verificado com apóstrofo isolado, barra invertida, ambos combinados, barra no fim da string e `{YEAR}` — todos sobrevivem a duas gerações com o valor exato preservado.

**Idade:** o padrão `'[^']*'` existe desde que há substituição de tokens. A cadeia de re-export nunca foi testada com um valor que contivesse apóstrofo — e o `agents.md §1.3` afirmava explicitamente que este caso funcionava, dando `O'Brien Tools` como exemplo. Funcionava uma geração. A nota foi corrigida com o aviso de que `'[^']*'` é sempre errado neste contexto, precisamente por passar em qualquer teste que exporte só uma vez.

**Export User produzia um arquivo que não inicializava (D25):** o artefato gerado pelo Export User — a cópia distribuída aos usuários finais — nunca chegou a funcionar. `exportFile(isUser=true)` remove os blocos `ADMIN_BUTTONS`, `ADMIN_EDIT`, `ADMIN_JS` e o do modal de export, mas o JavaScript que referencia esses elementos permanecia sem guarda em quatro pontos do arranque. O primeiro, `$('export-overlay').addEventListener(...)`, está em nível de módulo: `getElementById` devolvia `null`, o `TypeError` abortava o IIFE inteiro e `init()` nunca era chamado.

**Sintoma para o usuário final:** a interface renderizava por completo — logo, painéis, botões, e a barra de estado a dizer «Pronto» —, mas nada respondia. Sem base de dados, sem captura, sem export, sem erro visível. Pior do que uma página em branco, porque não sinalizava a avaria.

**Idade do defeito:** testando o artefato podado em cada versão histórica, aborta em **V11, V14, V15, V17, V18, V20, V21, V22, V23, V24 e V25**. Nunca funcionou. Na V11 abortava noutro ponto (`$('vb-overlay')`), pelo que a classe de defeito é anterior.

**Correção:** guardas de nulo nos quatro pontos, com estratégias diferentes conforme o contexto. `initVbSync()` e `initAdminGate()` recebem *early return* — são inteiramente admin, e sem os elementos não há nada a instalar. `applyTokens()` **não** pode ter early return: as escritas em `cfg-*` estão intercaladas com trabalho de que o usuário final depende (`sysColors`, `updateThemeColor()`, placeholders dos campos de sessão, rodapé), e sair cedo deixaria a app sem tema nem rótulos — por isso os três grupos de campos foram guardados individualmente com `_vbPresente`. Os handlers de `#export-overlay` e `#vb-overlay` recebem guarda local.

**Por que passou 15 versões despercebido:** o `validate.sh` valida o arquivo de administrador, nunca o produto do export; e a sintaxe do artefato podado é válida, pelo que até um check de sintaxe passaria — o defeito só aparece ao resolver IDs contra o DOM já podado. O checklist manual (`agents.md §11 Parte B`) manda verificar «Export User → o arquivo abre sem erros no console», mas exige gerar o artefato e abri-lo, passo que não era executado.

**Guard contra regressão:** novo check #27 no `validate.sh`. Aplica os mesmos 4 regex e avalia o JS num shim de DOM. É **comparativo** — só falha se o User abortar e o Admin não —, o que elimina falsos positivos de IDs criados em runtime e denuncia um shim defeituoso em vez de o deixar passar. Teria apanhado isto na V11.

**ZIP — colisão de nomes por maiúsculas/minúsculas (D26):** `dedupeZipName` usava um `Set` com comparação sensível a maiúsculas. Imagens e documentos são deduplicados a montante em **namespaces separados** (`images` contra `docs`), mas partilham **um único namespace** dentro do ZIP — logo uma imagem com legenda `Relatorio` e um documento chamado `relatorio.png` entravam ambos, como entradas distintas. Ao extrair no Windows ou no macOS, que são case-insensitive, um sobrescreve o outro ou a extração falha. Numa ferramenta cujo caso de uso declarado inclui recolha de provas, isso é perda silenciosa de evidência no momento da entrega. A deduplicação passou a usar chave em minúsculas, preservando a caixa original no nome exportado. Fecha a invariante que o `agents.md §3` já exigia para toda a deduplicação — e que era cumprida em todos os outros pontos (`captureImg`, `captureDoc`, `setLabel`, `setDocName`, `restoreImg`, `restoreDoc`) menos neste.

**ZIP — nomes de documento com caracteres inválidos no Windows (D27):** `safeDocName` neutralizava travessia de path mas não removia `< > : " | ? *`, que o Windows não aceita em nome de arquivo. Documentos capturados do sistema já trazem nomes válidos, pelo que o vetor era o **renomear dentro da aplicação**: escrever `relatorio:final.txt` gerava uma entrada de ZIP que o Explorer não extrai. As legendas de imagem nunca sofreram disto, porque `cleanLabel` opera por lista branca — era uma assimetria entre os dois caminhos de nomeação, e o `README §5.7` já justificava a remoção para as imagens com um argumento que se aplicava igualmente aos documentos. Acrescentada a remoção desses caracteres, dos caracteres de controlo, e de pontos ou espaços finais (que o Windows trunca silenciosamente). Espaços internos e hífens são preservados — não regridem a D21 nem os sufixos de deduplicação.

**Quine — token com `<script>` corrompia o arquivo exportado (D28):** `sanitizeForQuine()` escapava `\`, `'`, `\r`, `\n` e os 8 marcadores de bloco, mas não tratava sequências `<script` nem `</script`. Como os valores de token são injetados como strings JS **dentro** do `<script>` inline do artefato, um rodapé ou título que contivesse essas sequências — plausível ao colar de um trecho de código — terminava o elemento script e produzia um export estruturalmente corrompido, sem qualquer aviso. Violação silenciosa do Contrato 2 («o arquivo consegue copiar-se a si próprio»).

Neutralizado com `\x3C` no lugar do `<`, nas duas formas (abertura e fecho). Escapar apenas o `</script` não bastava: pelo spec do HTML, um `<script` no corpo do script leva o parser ao estado *double-escaped*, no qual o `</script>` verdadeiro deixa de fechar o elemento. Em runtime o valor volta a ser o texto original, pelo que o rodapé continua a mostrar exatamente o que foi escrito. O `README §10` afirmava proteção geral dos marcadores; era verdade para os 8 marcadores, incompleta como garantia.

**`validate.sh` — check de ferramentas não testava o que a doc afirmava (D29):** o `agents.md §10` descrevia o check como «confirma que as 7 ferramentas estão documentadas», mas a lista testada era `Rotação, Crop, selecionar, traço livre, retângulo, círculo, seta` — sete itens que **não** são os sete do enum `annTool` (`select|rect|circle|arrow|free|text|crop`): incluía `Rotação`, que é botão de ação e não valor de ferramenta, e **omitia `texto`**. A ferramenta de texto — a mais complexa do motor, alvo de toda a V24, com multilinha e WYSIWYG — podia desaparecer do README sem que a validação acusasse, e o script reportava `(7/7)` a dar por coberto algo que não estava. Lista corrigida para as 8 afordâncias reais da interface, agora com `texto` incluída, e a contagem exibida passou a ser derivada da lista em vez de estar hardcoded — não volta a divergir ao acrescentar ou remover uma entrada.

**Documentação — cinco afirmações do `agents.md` que o código contradizia (D30):** as duas auditorias convergiram no mesmo padrão: o defeito dominante deste repositório não é código errado, é documentação que afirma comportamento inexistente. Como o projeto instrui agentes a tratar o `agents.md` como fonte de verdade («Leia a Seção 0 e a Seção 1 antes de qualquer outra coisa»), cada afirmação falsa é uma instrução de manutenção defeituosa — capaz de levar um agente a «corrigir» código correto para o alinhar com doc errada. Todas as cinco foram verificadas contra o código antes de reescritas; cada correção regista o que se afirmava antes, para que a deriva fique rastreável.

- **§6, esgotamento de quota:** dizia que «a aplicação falha silenciosamente na interface». O banner existe desde a D9, é injetado em runtime por `showQuotaBanner()` a partir de `idbTx`/`idbDelBatch`, e a `§2.2` do próprio documento já o listava no z-index `99999`. Contradizia o `README §8` e a si mesma.
- **§7, `capturePristine()`:** dizia «Apenas em `exportFile()`». É chamada uma vez em `boot()`; o `exportFile` apenas lê `PRISTINE_HTML`. O diagrama do `README §13` sempre esteve correto.
- **§6, campo `exported`:** dizia que «passa a `true` quando `exportFile()` é chamado». A string ocorre **uma única vez** no arquivo, em `createSession()`, com valor `false`. Nunca houve lado de gravação.
- **§7, `pointercancel`:** dizia «repõe o item na posição original sem persistir alterações». Está registado com o mesmo handler do `pointerup`. Só é verdade para gestos que nunca ativaram o arrasto; num arrasto ativo, persiste a nova ordem com `idbPut`. Documentados agora os dois ramos.
- **§3.1, numeração `#000N`:** dizia «ordem de criação absoluta — não a posição atual na lista». É exatamente a posição entre as sessões existentes (`findIndex + 1`), sem contador persistido — apagar uma sessão antiga renumera as seguintes.

**Documentação — `TOKEN_MAX_IMG_DIMENSION`, taxonomia de ferramentas e decisões D7/D8 (D31):**

- **`TOKEN_MAX_IMG_DIMENSION`** — o `design-tokens.md` afirmava que a imagem era «redimensionada antes de ser armazenada» e o `README §9` recomendava o token como forma de prevenir perda de dados por quota. Ambas falsas: `captureImg()` grava o blob original, e o token é lido num único ponto, `imgToJPEG()`, chamada só por `generatePDF()`. Um administrador que o configurasse para reduzir consumo de disco não obtinha redução nenhuma e continuava exposto à perda que o conselho pretendia evitar. **Corrigida a documentação, não o código:** redimensionar na captura destruiria o original de forma irreversível, e numa ferramenta de recolha de provas isso é perda de evidência. Decisão do proprietário. As três menções (tabela de tokens do `README §6.4`, resolução de problemas do `§9`, e `design-tokens.md`) passaram a declarar que o token afeta apenas o PDF.
- **Taxonomia das ferramentas de anotação** — o `README §5.3` dizia «8 ferramentas» e incluía a Rotação 90°; o enum `annTool` tem 7 valores e não inclui rotação. Reescrito como «8 botões: 7 ferramentas + 1 ação», com a distinção técnica explicada — ferramenta fica ativa até se escolher outra, ação executa e termina. Resolve a divergência entre `README`, `agents.md §9` e o check do `validate.sh`.
- **Acessibilidade** — o cabeçalho «Estado atual (V25)» passou a «Estado avaliado na V25 (não reavaliado desde então)». Mudá-lo para V26 no bump alegaria uma reavaliação que não houve.
- **Decisões D7 e D8** registadas no `agents.md §13`: apagar sessão sem confirmação, e Escape a descartar anotações. Ambas foram levantadas como achados nas auditorias e **confirmadas como intencionais pelo proprietário**. Ficam documentadas com justificação para não voltarem a ser reportadas como defeito — e com a nota de que não devem ser alteradas sem aprovação.

**Banner de armazenamento indisponível alinhado ao de quota (D32):** existem **dois** banners críticos — `showQuotaBanner()` (quota esgotada) e `showStorageBanner()` (IndexedDB inacessível, ex.: janela privada). A D23 corrigiu apenas o primeiro e não reparou que tinha um gémeo, pelo que este manteve o emoji ⚠️, o travessão e `font-weight:600` em toda a linha. Agora seguem a mesma estrutura — diagnóstico em `<strong>`, hífen simples, consequência, remédio — e o mesmo vocabulário («gravadas», o verbo que a interface usa no estado «Gravado»):

| | Texto |
|---|---|
| Quota | **Armazenamento cheio** - as capturas deixaram de ser gravadas. Exporte agora (PDF ou ZIP) e apague sessões antigas no histórico. |
| Indisponível | **Armazenamento indisponível** - as capturas não serão gravadas. Verifique se o browser está em modo privado ou com restrições de armazenamento. |

A diferença de tempo verbal é deliberada e informativa: «deixaram de ser gravadas» descreve gravação que existia e parou; «não serão gravadas» descreve gravação que nunca chega a acontecer. Montagem passou a `createElement`/`createTextNode`, sem `innerHTML`. O banner de armazenamento indisponível ficou, **nesta iteração**, sem botão de fechar, ao contrário do de quota — a condição é permanente para a sessão e não há ação que a resolva sem reabrir o browser noutro modo. ⚠️ **Estado superado dentro da própria V26:** a D34, mais abaixo nesta secção, acrescentou-lhe o mesmo ✕. Quem consultar só esta entrada fica com informação errada sobre o estado atual. (D56)

**Documentação — cores literais declaradas como exceções (D33):** nova secção `design-tokens.md §2.1` a listar as cores escritas como literais no HTML, com a justificação de cada uma. ⚠️ **Esta entrada dizia «todas as cores» e era falsa** — a secção cobria 5 categorias e o código tinha 9. Corrigido na D51, com a lacuna medida e um comando de verificação para impedir que se repita. **Sem alteração de código nem de pixel.** O motivo é cortar um ciclo: as duas auditorias desta versão reportaram estas ocorrências como violação do contrato de Design Tokens, e qualquer auditoria futura repetiria — um `grep` por `background:#` não distingue intenção de esquecimento.

A investigação mostrou que a maioria **não é violação nenhuma**. A paleta de anotação não é cor de interface, é **dado**: o valor é gravado dentro do objeto de anotação no IndexedDB e reutilizado para redesenhar a forma, pelo que uma `var()` ficaria persistida como texto no banco. As cores do `SysLogger` vivem em strings de `console.log('%c…')`, e o console do DevTools não resolve custom properties. Restavam os banners (`#b91c1c`, sem token próprio) e o `#ann-cancel` — este último notável por o botão adjacente `#ann-save` usar `var(--color-green)`, o que expõe a inconsistência de escrita, ainda que o resultado renderizado seja idêntico ao do token. **Ambos mantidos por decisão do proprietário**, agora com o porquê registado.

A tabela fecha com a regra para quem editar depois: cor literal nova fora da lista é violação; se for necessária, acrescenta-se a linha com justificação.

**Banner de armazenamento indisponível ganhou botão de fechar (D34):** o banner é `position:fixed` em `top:0` e cobre **43,6px** — o suficiente para esconder por completo o logo, o alternador de tema e o botão de histórico, medido no browser. O de quota tem ✕ e permite recuperar esse acesso; este não tinha, pelo que a barra de topo ficava obstruída **durante toda a sessão, sem saída**.

A justificação anterior — «a condição é permanente, não há ação que a resolva» — explica por que não há remédio a sugerir, mas não justifica tornar a obstrução irremovível. São coisas distintas: o aviso continua impossível de **ignorar** (aparece a cada abertura, em vermelho, no topo), e deixa de ser impossível de **remover** depois de lido. Acrescentado o mesmo ✕ do banner de quota — 24×24, confirmado idêntico por medição —, e o banner passa de 43,6 para 48px pela mesma razão que o outro.

**Acessibilidade — os dois primeiros atributos ARIA do produto (D35):** o levantamento mostrou que o `capture-engine.html` tinha **zero** `role`, `aria-label`, `aria-live` ou `aria-hidden`. A lacuna não era pontual nos banners — era total. Acrescentados `role="alert"` aos dois banners críticos e `aria-label="Fechar aviso"` aos respetivos botões ✕ (que continham apenas o glifo, sem nome acessível).

O critério para parar aqui e não ir mais longe: os banners são as **únicas** mensagens que aparecem sem ação do usuário e que sinalizam risco de perda de dados. Sem `role="alert"`, um leitor de tela não os anuncia — o usuário não fica a saber que as capturas deixaram de ser gravadas. É o ponto de maior retorno por atributo em todo o produto. Qualquer coisa além disso seria uma passagem completa de acessibilidade, que é trabalho de outra dimensão.

O `README` foi atualizado para declarar **exatamente** o que existe — uma tabela com os dois `role` e os dois `aria-label`, e a frase «nenhum outro elemento da interface tem marcação ARIA. Isto não é um esforço de acessibilidade — é a cobertura mínima do único ponto onde a ausência dela custa dados ao usuário». A honestidade da declaração de acessibilidade é um ponto forte do projeto e não podia ser diluída por uma melhoria parcial.

**Documentação — apagar sessão é irreversível e não estava avisado ao usuário (D36):** a decisão D7 (sem diálogo de confirmação, coerente com as zero chamadas a `confirm()` em todo o produto) ficou registada no `agents.md §13`, que é documentação **interna para quem desenvolve**. O `README` — o documento que o usuário final lê — não continha aviso nenhum. A secção da Lixeira descrevia a rede de segurança para itens sem esclarecer que ela **não cobre sessões**: apagar uma sessão remove-a com todo o conteúdo, incluindo o que estava na lixeira dela, sem confirmação e sem forma de desfazer. Acrescentado o aviso no formato `AVISO CRÍTICO` do projeto, com a recomendação de exportar antes. Nenhuma alteração de comportamento — a D7 mantém-se.

**Documentação — pontos de maior risco de regressão listados (D37):** as 14 funções acima do limiar de complexidade que o próprio projeto definiu (`initReorder` 47, `annSetTool` 34, `initVbSync` 29, `annShowTextInput` 29, `initClipboard` 28, `applyTokens` 26…) só eram visíveis a quem corresse o `validate.sh`. Passaram a estar tabeladas no `agents.md §10`, extraídas da saída real do script e não escritas de memória.

Não é uma lista de defeitos — o próprio script classifica estes avisos como não-bloqueantes, e continuam a sê-lo. É o mapa de onde uma edição tem maior probabilidade de partir algo, e a sua utilidade ficou demonstrada nesta versão: as divergências entre código e documentação encontradas nas auditorias concentraram-se **nestas mesmas funções**. Um agente que edite `initReorder` sem saber que é o ponto mais denso do arquivo corre risco desproporcionado.

Acompanha a nota de que a heurística conta pontos de decisão e não complexidade percebida — ordena risco relativo, não emite veredicto de qualidade — e a instrução de regenerar a tabela após alterações significativas.

**Documentação — limites do motor ZIP declarados (D38):** `buildZIP` escreve o formato ZIP clássico, sem ZIP64: a contagem de entradas no EOCD usa `u16(files.length)` e os tamanhos e deslocamentos usam `u32`. Os limites reais são portanto **65.535 arquivos** e **~4 GB** por arquivo e no total. As funções `u16`/`u32` aplicam máscaras (`v & 0xFF`, `(v >> 8) & 0xFF`…), pelo que um valor acima do limite **trunca em silêncio**: o ZIP seria gerado e descarregado, mas corrompido, sem erro na interface nem no console.

A probabilidade é baixa — a memória do browser esgota-se ao montar o pacote muito antes de se atingirem esses números. Fica declarado na secção de Limitações precisamente por a falha ser silenciosa, que é o critério que a secção existe para cobrir. Nenhuma alteração de código: implementar ZIP64 não se justifica para um limite que a plataforma torna inalcançável.

**Checklist — prova de vida obrigatória do Export User (D39):** o `agents.md §11 Parte B` já mandava abrir a cópia exportada, mas todos os seus itens verificavam o que devia estar **ausente** — botões de admin, Visual Builder, logs no console. **Um artefato morto satisfaz os três trivialmente.** Foi exatamente assim que a D25 sobreviveu 15 versões: o checklist era cumprido por um arquivo que não funcionava.

Substituído por um procedimento de 7 passos que não pode ser satisfeito por um arquivo inerte, com dois passos de **presença** que são o núcleo: colar uma imagem e confirmar que aparece na grade, e escrever no campo User, recarregar, e confirmar que a sessão está no histórico. Acompanha a explicação de por que a inspeção visual não basta — no defeito D25 a interface renderizava por completo, incluindo a barra de estado a dizer «Pronto», porque isso é HTML estático; só a interação revela que nada está ligado.

Acrescentado também um aviso no `§12` (Protocolo de Version Bump), que é onde se olha ao fechar uma release: nenhuma versão está pronta sem esta prova. E a nota de que o novo check #27 do `validate.sh` apanha esta classe de defeito automaticamente, mas cobre apenas código síncrono de nível de módulo — `init()` é `async` e não corre nesse ambiente, pelo que **não substitui** o teste manual.

**`validate.sh` — contador de checks desfasado (D24):** o script tem um mecanismo de autoconsistência (`CHECKS_NUMERADOS`) que compara o número de checks implementados com o número declarado no `agents.md §10` e emite `[WARN]` se divergirem. Ao introduzir o check #26 na D21, o `agents.md` foi atualizado para 26 mas o contador ficou em 25, pelo que o repositório em estado limpo passou a emitir `[WARN] Contagem de checks em agents.md desfasada (doc=26, real=25)`. Contador alinhado. **Como passou despercebido:** as verificações da própria D21 filtraram os `[WARN]` para reduzir ruído — o aviso caiu exatamente no filtro que o deveria ter mostrado.

---

## [V25] - 2026-06-06

- Mobile: desenho por toque via Pointer Events + touch-action:none no canvas de anotação
- Mobile: scroll lock em todos os modais fullscreen (imagem, documento, Visual Builder, sidebar)
- Mobile: botões de apagar e restaurar sempre visíveis em dispositivos touch (@media hover:none)
- Mobile: toolbar de anotação em 3 linhas responsivas
- Código: comentários de secção HTML padronizados para maiúsculo
- Visual: logo Símbolo SVG theme-aware (sem caixa, currentColor) + PWA completo (favicon SVG, apple-touch-icon, manifest com ícones base64) + cor de destaque #e86b2e (laranja)

Anotação iterativa: motor de interação enriquecido com suporte completo a seleção, edição, redimensionamento, movimento e um novo modelo de histórico (undo/redo).

### Adicionado

**Motor de Seleção e Edição (Anotação)** — agora é possível selecionar, mover, redimensionar e apagar anotações previamente desenhadas. A ferramenta "Selecionar" (ativa por padrão ao abrir anotações existentes) permite clicar numa forma para exibir uma caixa de seleção sólida e fina com quatro alças de redimensionamento e um botão de exclusão (✕). Suporta redimensionamento bidirecional contínuo (incluindo redimensionamento visual contínuo de texto). O ✕ e a tecla `Delete` apagam o item atual.

**Edição de Propriedades Pós-Desenho** — com uma anotação selecionada, os botões da barra de ferramentas alteram diretamente o objeto em vez de apenas mudar o próximo traço. Os botões −/+ ajustam a espessura ou tamanho de fonte, e a paleta altera a cor atual. Os níveis de espessura foram expandidos para seis opções: `[1, 2, 4, 6, 8, 12]`.

**Polimentos de UX (Anotação)** — o botão direito do mouse permite agarrar e mover anotações em qualquer ferramenta (sem desenhar, suprimindo o menu nativo). O ícone "T" fica na cor de destaque (accent) quando a ferramenta de texto está ativa OU quando uma anotação de texto encontra-se selecionada (`.ann-txt-selected`). A seleção anterior limpa automaticamente ao confirmar ou trocar para texto.

**Rotação de imagem 90°** — Novo botão "90°" na toolbar do editor. Rotação não-destrutiva em incrementos de 90°: `origBlob` permanece intacto e na orientação original; o campo `rotation` (0|90|180|270) regista o desvio no IndexedDB. As coordenadas das anotações existentes são recalculadas matematicamente para acompanhar a rotação.

**Recorte de imagem (Crop)** — Nova ferramenta de crop no editor com máscara escurecida (60%) e 4 alças em "L" nos cantos. Não-destrutivo: o recorte é guardado como `cropBox` no IndexedDB sem alterar `origBlob`. Ao reabrir a ferramenta, o canvas expande para a imagem original com a caixa a marcar o recorte anterior, permitindo reajustar ou recuperar áreas cortadas. As coordenadas das anotações são ajustadas em tempo real.

### Modificado

**Refinamento de Ícones PWA e Favicon — impacto: coerência visual e fundo isolado**
- O SVG do `<link rel="icon">` teve a sua caixa de fundo removida e *viewBox* aumentada, adaptando agora a cor do ícone (`#000000` ou `#ffffff`) aos temas claro e escuro do sistema operativo.
- O fundo embutido dos ícones PWA no `manifest.json` e do `apple-touch-icon` foi convertido do antigo cinzento (`#1a1a1a`) para preto puro (`#000000`), preservando rigorosamente a transparência original nos cantos exteriores e a suavização nas arestas da forma.
- Valor de `theme_color` e `background_color` globais (HTML e manifest) fixados em preto puro (`#000000`) para imersão nativa em PWA.

**Separador Visual (Anotação)** — Adicionada uma barra vertical (`|`) na barra de ferramentas do modo edição, separando os botões de ferramentas de desenho dos botões de acções estruturais (Rodar 90° e Recortar).

**Desfazer e Refazer (Modelo Snapshots de Estado)** — o sistema de undo/redo foi integralmente reescrito. Substitui a antiga pilha única baseada em eventos (que causava bugs de ordem ao intercalar ações) por um modelo de snapshots completos com dupla pilha (`annUndoStack` / `annRedoStack`, teto de 50). Toda mutação altera a fonte única (`annHistory`). Ações contínuas de mover/redimensionar só persistem se houve mudança efetiva (flags `annDragDirty` / `annResizeDirty`). Ao reentrar numa imagem salva, o histórico é "semeado" iterativamente, permitindo desfazer todas as ações até revelar a imagem original sem anotações.

**Logótipo e Favicon (V25, sessão 2026-06-10)** — O SVG do logo foi substituído pela variante Símbolo: sem caixa de fundo, quatro cantos em L preenchidos (`fill`) em vez de traços (`stroke`), com `fill="currentColor"` nos 3 cantos neutros e `fill="url(#ce_accent)"` no canto inferior direito (gradiente verde→amarelo). O CSS de `#tb-brand-icon` deixou de ter `background`, `border-radius` e `overflow`. Adicionadas duas regras de theming: `color: #ffffff` em dark mode (padrão) e `color: #1a1a1a` em `body:not(.dark)`, para que o logo use `currentColor` e adapte-se automaticamente ao tema activo. O favicon no `<head>` foi actualizado para o novo SVG. Adicionados `<link rel="apple-touch-icon">`, `<link rel="manifest">` com ícones e manifest embebidos como data URI (zero ficheiros externos), `<meta name="theme-color">` e `<meta name="msapplication-TileColor">`.

**Cor de destaque `--accent`** — valor final ajustado para `#e86b2e` (laranja suavizado -10% em relação ao `#e65616` inicial), aplicado em `--accent` e `TOKEN_MAIN_COLOR`. `--accent-hover` actualizado de `#0284c7` para `#d4450f`. Cor hardcoded em `#ann-text-input::selection` (2 ocorrências) actualizada para `rgba(232, 107, 46, 0.32)` em consistência.

### Corrigido

**Export — prefixo `SESSAO-SEM-TITULO` removido do nome do arquivo (D22):** sessões sem título produziam arquivos como `SESSAO-SEM-TITULO-13h29m-16-ago-2026.zip`. Eram 17 caracteres de prefixo constante antes da única parte que distinguia um export do outro — justamente a que o Explorer trunca primeiro em colunas estreitas. O nome também divergia da própria interface, que já identifica sessões sem título como `#0001` no histórico. **Correção:** `buildFilename()` deixou de ter o fallback; o prefixo passou a ser opcional e o hífen separador acompanha-o, produzindo `13h29m-16-ago-2026.zip`. O timestamp já identifica o export unicamente. Sessões **com** título mantêm o formato anterior sem qualquer alteração (`JOAO-PC001-13h29m-16-ago-2026.zip`), e o export do Quine — que passa o título da app via `baseName` — continua a gerar `CAPTURE-ENGINE-14h22m-11-jun-2026.html`. O segundo ramo de fallback (para nomes esvaziados pela sanitização, ex.: título só com pontuação) foi eliminado por ter deixado de ter função: cai agora no mesmo caminho de prefixo vazio.

**Banner de quota — texto e botão de fechar (D23):** o aviso de armazenamento esgotado dizia «novas capturas não estão sendo salvas», gerúndio PT-BR que divergia do vocabulário da própria interface — o estado de gravação chama-se «Gravado» e o `README` descrevia o mesmo evento com a construção PT-PT «não estão a ser guardadas». Três formas para o mesmo conceito. Texto reescrito para português neutro e alinhado ao verbo que a interface já usa: **«Armazenamento cheio - as capturas deixaram de ser gravadas. Exporte agora (PDF ou ZIP) e apague sessões antigas no histórico.»** Sem emoji: o sistema de iconografia do projeto é SVG inline, e o ⚠️ era a única peça fora dele, com renderização dependente do sistema operacional. O separador é hífen simples, não travessão. Encurtou de ~150 para ~124 caracteres, o que reduz a quebra de linha em telas estreitas. O diagnóstico passou a `<strong>` e o restante a peso normal (o banner inteiro era `font-weight:600`, pelo que nada se destacava); a montagem usa `createElement`/`createTextNode`, sem `innerHTML`. Paráfrase do `README §8` alinhada ao novo texto.

O botão ✕ era um retângulo deitado de ~28×22px: não tinha dimensões definidas, e o tamanho resultava do glifo mais `padding: 4px 10px` — assimétrico por construção. Agravado por `<button>` não herdar `font-size` do pai, usando a métrica padrão do browser. Corrigido com `width`/`height` de 24px, `padding:0`, `font-size` explícito e centragem por `inline-flex`, dando um quadrado perfeito com o mesmo raio de canto. O banner cresce ~4px em altura.

Sobreposição do banner sobre a barra de topo **mantida por decisão do proprietário** — é um aviso que não deve poder ser ignorado. As cores (`#b91c1c` / branco) também foram mantidas por decisão, apesar de continuarem hardcoded fora do `design-tokens.md`.

**ZIP — nomes com acentos saíam ilegíveis (D21):** um documento chamado `Diagnóstico Antônio.txt` aparecia dentro do ZIP como `Diagn+¦stico Ant+¦nio.txt` no Explorer do Windows e no WinRAR. **Causa:** o `buildZIP` já codificava os nomes em UTF-8 (`ENC.encode()`), mas gravava o *general purpose bit flag* dos dois cabeçalhos a zero. Pela especificação ZIP (APPNOTE.TXT §4.4.4), é o **bit 11 (`0x0800`)** que declara o nome como UTF-8; sem ele o descompressor é obrigado a interpretar os bytes como CP437/ANSI, e cada caractere acentuado — gravado em dois bytes — é desenhado como dois caracteres separados. **Correção:** o bit 11 passou a ser escrito no *local file header* e no *central directory*. Nenhum outro byte mudou: método continua STORE, CRC, tamanhos, offsets e EOCD intactos. **Impacto:** só os nomes eram afetados — o conteúdo dos arquivos sempre esteve íntegro e os ZIPs antigos continuam a abrir. Reexportar produz os nomes corretos.

Aproveitando a mesma correção, a limpeza de nomes de imagem (`cleanLabel`) deixou de remover os acentos. Antes fazia `normalize('NFD')` seguido da remoção dos diacríticos e de uma lista branca ASCII (`[^a-zA-Z0-9\-_ ]`), pelo que `Diagnóstico` virava `Diagnostico` — foi por isso que a falha só se manifestava nos documentos, cujo nome não passava por essa limpeza. Agora usa `normalize('NFC')` e uma lista branca ciente de Unicode (`[^\p{L}\p{N}\-_ ]/gu`), preservando acentos e alfabetos não-latinos. A forma da regra não mudou — continua a ser lista branca —, portanto `\ / : * ? " < > |`, pontos e caracteres de controle continuam a ser removidos, e a proteção contra path traversal mantém-se (`../../etc/passwd` → `etcpasswd`).

No mesmo passo, a legenda de imagem deixou de converter espaços em hífens: `.replace(/\s+/g, '-')` passou a `.replace(/\s+/g, ' ')`. O nome do documento nunca converteu espaços, pelo que o mesmo texto digitado produzia dois nomes diferentes conforme o tipo de item (`Diagnóstico-Antônio.png` contra `Diagnóstico Antônio.txt`) — divergência anterior a esta correção e não documentada em lado nenhum. Escolhido preservar o espaço nos dois, por menor surpresa: o nome do arquivo lê-se agora exatamente como o texto que se escreveu. A colapsagem de espaços repetidos e o `trim()` mantêm-se — só mudou o caractere de saída, não a normalização. Imagens e documentos passam a nomear de forma consistente.

`validate.sh` estendido a 26 checks: o novo check #26 confirma o bit 11 nos dois cabeçalhos, para que a correção não seja desfeita silenciosamente numa edição futura.

**Anotação — fundo deslocado em crop+rotação (D19):** o handler de rotação passou a transformar também a caixa de corte (antes só rotacionava as coordenadas das anotações), mantendo `o.cropBox` no espaço da base já rotacionada — a invariante que `annLoadCleanBg` assume. Estratégia não-destrutiva (Estratégia 1): `origBlob` fica intacto e o re-corte a partir do original continua possível depois de rotacionar. Cobre os dois referenciais: Caso A (em modo crop, `BH = altura da base exibida`) e Caso B (crop salvo fora do modo crop, `BH` derivado de `origBlob` — `origHeight` se a rotação for 0/180, senão `origWidth`). O snapshot de undo (`annCloneState`) passou a capturar o crop persistido (`pcrop`) e `annDoUndo`/`annDoRedo` restauram-no, mantendo `o.cropBox` coerente com `annCurrentRotation` ao desfazer/refazer a rotação. Resolve o fundo recortado da região errada ao reabrir e o caminho de corrupção de `o.blob` no re-save desse estado. Inclui ainda a correção de uma dessincronização que esta própria mudança expôs: a entrada no modo crop (`annSetTool`) passou a reconstruir a base com `annCurrentRotation` (rotação viva) em vez de `o.rotation` (guardada) — divergiam ao rotacionar várias vezes sem salvar e depois entrar no crop, deslocando o fundo. Dedupe da D18 intacta.

**Anotação/Docs — melhorias (D18):** dedupe de snapshots idênticos no undo (elimina passo de Desfazer sem efeito visível); limitação de undo/redo sobre crop/rotação pós-save documentada no README §5.3.

**Quine/Export — correções (D17):** fallback BOOT_HTML deixa de fixar dark mode; export preserva TOKEN_MAX_IMG_DIMENSION/TOKEN_AUTO_PURGE_HOURS personalizados (radios desmarcados quando o valor não é um preset).

**Documentação — correções de auditoria (D16):** tamanho do ficheiro, 9 níveis de z-index documentados, rdp reatribuído a V25, durações de animação, enum `crop`; `validate.sh` estendido a 25 checks (z-index, animações, tamanho).


**Resquícios de accent azul + tile PWA (D13)** — `.drop-zone.drag-over` (5%) e `.btn-zip-cta:hover` (6%) ainda usavam `rgba(14, 165, 233, …)`, azul remanescente da migração de accent; trocados por `color-mix(in srgb, var(--accent) …%, transparent)`, que acompanha o accent automaticamente. `msapplication-TileColor` alinhado de `#1a1a1a` para `#000000` (objetivo "PWA preto", em consistência com `theme-color` e o manifest). Docs `design-tokens.md` e `agents.md` alinhados à cor accent atual (laranja). Sem alteração de lógica de app.

**Refazer (Redo) sobrevive a salvar+reabrir (D12)** — o `annRedoStack` passou a ser persistido no IndexedDB (`o.annRedoStack`), restaurado por `annActivate` e gravado por `ann-save`. Antes, a pilha de refazer ficava apenas em memória e era zerada ao reabrir, pelo que o redo nunca funcionava depois de salvar. Corrigido também o caso em que desfazer o **único** desenho da imagem disparava o "reset total" do `ann-save` e apagava o redo recém-gravado — agora o reset só ocorre se `annRedoStack` também estiver vazio. Sem bump de schema IndexedDB (campo a nível de registro). **Limitação conhecida:** redo que atravessa rotação/crop é aproximado, pela mesma razão que a semeadura do undo achata `rot`/`crop`.

**Integração do Crop e Rotação no Desfazer (Undo/Redo)** — As ferramentas de corte e rotação passaram a integrar corretamente o sistema de snapshots. O motor agora deteta mudanças estruturais ao navegar no histórico (via Ctrl+Z ou botões) e recarrega instantaneamente a versão limpa (`origBlob`) com os parâmetros correspondentes de rotação e corte. Resolvido o bug onde reverter até à base ao abrir a sessão mantinha um recorte fantasma ativo.

**Prevenção do Ecrã Branco ("White Flash") no Carregamento** — O arquivo `index.html` (responsável pelo redirecionamento automático) foi reestruturado com CSS e script embutidos. O tema escuro (`dark mode`) é detetado de forma síncrona (verificando o `localStorage` e as preferências do sistema) antes de a página renderizar, eliminando completamente o piscar branco antes da abertura do motor.

**Performance mobile — deleção de arquivos:** eliminado freeze ao apagar múltiplos itens. `renderTrash()`, `updateCounters()` e `updateBtns()` consolidados num único ciclo com debounce de 50ms via `scheduleUIUpdate`; `triggerSave()` chamado uma única vez no fim desse ciclo. Transações IndexedDB em `deleteSessionId` e `purgeExpired` consolidadas por store em batch via `idbDelBatch` (uma transação em vez de N individuais).

**Reordenação no Mobile** — Restaurado o scroll vertical nativo em dispositivos de toque nas listas de imagens e documentos através de `touch-action: pan-y`. Um temporizador de toque longo (`LONG_PRESS_DELAY = 500ms`) foi introduzido para distinguir a rolagem da página do gesto intencional de arrastar e reordenar. Ao expirar o tempo, o scroll nativo é dinamicamente desabilitado no item (`touch-action: none`) para permitir a reordenação precisa, sendo restaurado ao final do gesto.

---

## [V24] — 2026-06-01

Ferramenta de Texto da anotação: suporte a **texto multilinha** e **redimensionamento ao vivo** do tamanho da fonte, com o texto a ficar achatado na imagem exatamente como aparece no editor (WYSIWYG — What You See Is What You Get).

### Adicionado

**Texto multilinha na anotação** — o editor de texto (`#ann-text-input`, dentro de `#ann-text-overlay`) passou de `<input type="text">` para `<textarea wrap="off">`. Agora é possível escrever **várias linhas** e o editor cresce em altura e largura à medida que se escreve (nova função `annAutosizeText()`: como `wrap="off"` não quebra linhas sozinho, mede a linha mais longa com `measureText` na fonte escalada e ajusta `width`/`height`). O render no canvas (`annDrawShape`, ramo `h.type === 'text'`) deixou de usar um único `fillText` (que ignora `\n`) e desenha **linha a linha** (`String(h.txt).split('\n')`). Foi introduzida a constante única `ANN_TEXT_LINE_RATIO = 1.3`, usada **tanto** no `line-height` do `<textarea>` **como** no canvas, garantindo que o que se vê a escrever é igual ao que fica gravado. Alinhamento vertical determinístico: a 1.ª linha é desenhada em `y1 + halfLeading`, com `halfLeading = (lineH − fontSize) / 2` e `lineH = fontSize × ANN_TEXT_LINE_RATIO`. A reedição por duplo-clique passou a testar o clique contra a **caixa completa** do texto (largura da linha mais comprida × número de linhas, com o mesmo `lineH`), permitindo reabrir o texto clicando em qualquer linha.

**Cursor da ferramenta Texto** — ao selecionar a ferramenta Texto, o cursor sobre o canvas de anotação passa de cruz (`crosshair`) para cursor de texto (`text` / I-beam), dando feedback imediato do modo ativo; volta a `crosshair` nas restantes ferramentas (definido em `annSetTool`).

### Modificado

**Enter deixou de confirmar o texto — passou a inserir nova linha** — na ferramenta Texto, removido o ramo `if (e.key === 'Enter') { e.preventDefault(); commit() }` do `onkeydown`. A confirmação acontece agora ao **clicar fora** do editor (`onblur`), ao clicar noutro ponto do canvas, ou no botão **Confirmar** (`#ann-save`). `Ctrl+B` / `Ctrl+I` e `Escape` (cancelar) mantêm-se inalterados.

### Corrigido

**Botões de tamanho −/+ fechavam o editor de texto e não redimensionavam ao vivo** — com texto em edição, clicar em `#ann-thickness-down` / `#ann-thickness-up` tirava o foco ao editor (disparando o commit) e mudava o tamanho apenas uma vez, sem refletir na caixa aberta. Corrigido aplicando o mesmo padrão já usado pelas swatches e pelos botões B/I: `mousedown` com `e.preventDefault()` quando o overlay de texto está visível (impede o blur/commit) e, no `onclick` (só no ramo `annTool === 'text'` e com o editor visível), atualização **ao vivo** do `font-size` e `line-height` do editor + reposicionamento, via `annTextLiveResize()` → `annAutosizeText()`, sem fechar. Fora do modo texto, os botões continuam a controlar a espessura do traço, sem qualquer alteração.

**Texto novo aparecia abaixo do cursor** — o ponto clicado corresponde ao **centro vertical** do cursor I-beam (`cursor: text`), mas a 1.ª linha ancorava pelo topo nesse ponto, fazendo o texto aparecer abaixo de onde se mirava. Corrigido em `annShowTextInput`: para texto novo (sem `prefill`), a âncora sobe meia linha — `canvasY -= ANN_TEXT_SIZES[annTextSizeIdx] × ANN_TEXT_LINE_RATIO / 2` (coords do canvas) — ficando a 1.ª linha **centrada** no ponto clicado, tanto no editor como no canvas (o `y1` gravado já leva o ajuste, por isso o WYSIWYG mantém-se). A reedição por duplo-clique (com `prefill`) preserva a âncora gravada, sem deslocamento.

**Ctrl+Z desfazia a anotação enquanto se escrevia texto** — o listener global de `keydown` tratava `Ctrl+Z`/`Ctrl+Y` como undo/redo da anotação mesmo com o foco no editor de texto, impedindo o desfazer nativo da digitação. Adicionado um guard: se `document.activeElement` for `INPUT`/`TEXTAREA`/`isContentEditable`, o bloco de undo/redo da anotação é ignorado (sem `preventDefault`), deixando o campo desfazer/refazer as letras nativamente. Fora de um campo de texto, o comportamento é igual ao anterior.

**Documentação** — `agents.md` §7 (`annShowTextInput` agora descreve o `<textarea>` multilinha e Enter=nova linha; `annDrawShape` o render linha a linha; nova função `annAutosizeText`), §9 (nova constante `ANN_TEXT_LINE_RATIO`) e §11 (checklist de `annDrawShape` estendida ao render multilinha); `readme.md` §5.3 (secção da ferramenta Texto: multilinha, Enter=nova linha, confirmar a clicar fora/Confirmar, resize ao vivo dos −/+).

**Documentação — auditoria universal (correções).** Após uma auditoria à documentação: documentados os motores **PDF** e **ZIP** em `agents.md` §7 (até aqui sem referência de funções); acrescentados os campos `origBlob`/`annHistory` ao esquema do `images` (`agents.md` §6 e `readme.md` §13); corrigida a descrição da anotação na `readme.md` §5.3 (de "permanente" para **não-destrutiva e reeditável**, com o original preservado); reposto o cabeçalho em falta `## 7. Segurança e privacidade` na `readme.md`; corrigida a posição do script anti-FOUC no diagrama da `readme.md` §13 (de `<head>` para logo após `<body>`); `design-tokens.md` actualizado (constante `ANN_TEXT_LINE_RATIO`, entrada `text` multilinha, afirmações subjectivas); siglas **EMA** e **FLIP** expandidas; tamanho do ficheiro (~190KB → ~198KB) corrigido.

## [V23] — 2026-05-31

Versão maior: correção de dois bugs de interação reportados pelo usuário (visíveis durante o uso, não no código estático) e substituição do mecanismo de reordenação.

### Modificado

**Documentação — auditoria universal (9 correções)**

- `agents.md` §11: removido item de checklist "Botão Nova Sessão" — botão eliminado na V17, item era falso negativo garantido em qualquer execução
- `agents.md` §2.5: documentada API completa do `SysLogger` (`info`/`warn` só com debug ativo; `error` sempre ativo)
- `agents.md` §7: adicionadas assinaturas e descrições de `idbPut`, `idbGet`, `idbAll`, `idbDel`, `idbIdx` — funções de IDB usadas em todo o motor mas ausentes da referência
- `agents.md` §7: documentadas `applyTokens()`, `initVbSync()` e `buildFilename()` — funções críticas presentes no diagrama de boot mas sem entrada na tabela de referência
- `agents.md` §6: campo `exported` da tabela `sessions` passou de "para referência futura" para descrição factual (quando é definido, que lógica o usa, que é informativo/reservado)
- `design-tokens.md`: `--drop-ph-bg` e `--drop-ph-border` corrigidos — descreviam-se como "ajustáveis sem Export" mas requerem edição direta do código-fonte; inacessíveis a admins via Visual Builder
- `readme.md` §2: perfil Desenvolvedor/Agente IA expandido com referência explícita e descritiva a `agents.md`

**Setas de navegação no visualizador de imagens** — adicionados botões ← → flutuantes no modal de imagem. Aparecem automaticamente quando há ≥2 imagens na sessão; ficam ocultos no modo de anotação (restaurados ao sair) e na lixeira com apenas 1 item. Estilo glassmorphism consistente com o zoom UI. Equivalentes às teclas ArrowLeft/ArrowRight já existentes (que foram mantidas).

**Corrigido: cliques rápidos nas setas de navegação ativavam o zoom** — o `#ann-viewport` tem um listener de `dblclick` que faz zoom ao clicar duas vezes na imagem. Cliques rápidos nos botões ← → propagavam até ao viewport e eram interpretados como duplo-clique. Corrigido adicionando um guard no handler de `dblclick` que ignora eventos originados nos botões de navegação (`e.target.closest('#img-nav-prev,#img-nav-next')`).

**`TOKEN_FOOTER_TEXT` — valor padrão atualizado para incluir o autor** — o texto do rodapé pré-preenchido no Visual Builder passou de `© {YEAR} • CAPTURE ENGINE` para `© {YEAR} • CAPTURE ENGINE • DIOGO CARVALHO`. Atualizado em `capture-engine.html`, `readme.md` e `design-tokens.md`.

**Botão "Anotar" renomeado para "Editar"** — o botão do modal de imagem (id `ann-toggle`) que abre o modo de anotação passou a chamar-se "Editar". Apenas o rótulo visível mudou; a função (`annActivate()`) e o comportamento são os mesmos. Atualizada a referência em `agents.md` §7.

**Ícone do botão "Editar" melhorado** — o lápis do botão `#ann-toggle` foi substituído por um traçado mais comprido, com a borracha arredondada no topo e a ponta menos afiada (estilo contorno, sem o triângulo cheio anterior). Apenas o SVG mudou; o comportamento é o mesmo. Verificado no browser.

**Bloqueio de multi-aba removido** — abrir o Capture Engine numa segunda aba do mesmo browser já não mostra a tela de erro vermelho que substituía a interface. O manipulador `onblocked` do IndexedDB passou a apenas registar um aviso discreto na consola. Várias abas partilham a mesma base de dados local; a única ressalva é não editar a mesma sessão em duas abas ao mesmo tempo (a última gravação prevalece). Documentação atualizada em `readme.md` §7, §8 e §10 e `agents.md` §6 e §11. *(Nota: testado o arranque da app em viewport mobile durante esta sessão — sem erros de JS, sem camadas a cobrir o ecrã; os handlers respondem.)*

### Corrigido (interação — após teste manual)

**Não era possível reordenar imagens no mobile (toque)** — a reescrita da reordenação na V23 (Pointer Events) exige `touch-action: none` nos itens para o browser não interpretar o gesto como scroll. Porém, a media query mobile (`max-width:900px`) forçava `touch-action: manipulation` em `.t-item` e `.t-wrap`, anulando isso — e só nas imagens (os documentos `.d-item` não eram afetados, por isso já reordenavam no toque). Corrigido: `.t-item` e `.t-wrap` passam a `touch-action: none` também em mobile. Verificado no browser que o valor calculado é agora `none` em viewport de 375px. O toque simples para abrir continua a funcionar (`touch-action: none` não impede o clique).

**Rodapé do Visual Builder não atualizava na app** — o campo "Texto do Rodapé" (`cfg-footer-text`) não tinha listener de `input` no `initVbSync`, ao contrário dos campos de cor, título e rótulos. O valor só era aplicado na exportação, nunca no preview ao vivo. Corrigido: adicionado o listener que atualiza `#footer-credits` ao editar (espelhando a substituição de `{YEAR}` do `applyTokens`). Verificado no browser: editar o campo altera o rodapé imediatamente.

### Documentação (2.ª auditoria de 2026-05-31 — correcções críticas, verificadas no código)

Quatro divergências identificadas numa segunda auditoria externa e confirmadas por leitura directa do `capture-engine.html`. Sem alterações de comportamento da app — apenas documentação e o script de validação.

- **`sysColors` — estrutura completada (`agents.md` §9).** A tabela documentava `{main, fg}`; o código (`capture-engine.html`) declara `{main, fg, tStart, tAccent, tEnd}` — os 3 campos de cor de título (`tStart`/`tAccent`/`tEnd`) estavam ausentes. Um agente a mexer no motor de título/cores tinha uma visão incompleta do estado global. Corrigido com a estrutura real e a sua origem (tokens) e consumidores (`applyTokens`/`initVbSync`/Quine).
- **`deactivateAdmin()` recategorizada (`agents.md` §7).** Estava listada na tabela "Funções de Anotação", mas pertence ao **Admin Gate** (oculta os botões ⚙️/💾; exposta como `window._deactivateAdmin`; chamada por `closeSettingsModal`). Movida para uma nova subsecção "Funções do Admin Gate".
- **Contradição sobre o Firefox reconciliada (`readme.md` §10 ↔ §11/§9).** A FAQ afirmava "experiência idêntica ao Chrome/Edge", contradizendo §11 ("não testado formalmente") e o modelo de recuperação da §9. A FAQ passou a indicar que captura/anotação/exportação funcionam, mas que a partilha e recuperação de dados `file://` só foi verificada em Chromium — e a recomendar Chrome/Edge para requisitos de recuperação.
- **`validate.sh` — número de versão deixou de ser hardcoded.** A verificação #8 tinha `V23` literal e quebraria (ou daria falso-positivo) no próximo version bump; além disso o protocolo de bump (`agents.md` §12) não a mencionava. Reescrita para **auto-detectar** a versão a partir do boot message (`Capture Engine Vxx Ready`) e confirmar que essa versão é consistente nas 3 referências de produto (comentário VB, badge, console). Resultado: o script nunca mais precisa de edição manual no bump e passa a **apanhar** referências de versão por substituir. Nota adicionada ao `agents.md` §12.

### Documentação (auditoria de 2026-05-31 — correcções de alta prioridade)

Três inconsistências de nível alto identificadas em auditoria externa e corrigidas no `design-tokens.md`. Sem alterações de comportamento — apenas a documentação passou a descrever o que o código faz.

- **`TOKEN_TITLE_END` — versão de introdução corrigida.** A nota dizia "ativo desde V22"; o token foi adicionado nesta versão (V23), conforme o próprio changelog regista em "Nova Funcionalidade". Corrigido para "adicionado na V23".
- **`TOKEN_JPEG_QUALITY` — comportamento fora do intervalo especificado.** A nota avisava que edição directa no código "não tem guard" mas não dizia o que acontecia. Documentado o comportamento real: valores fora de `[0, 1]` fazem o browser usar qualidade padrão da implementação (~0.92); valores dentro de `[0, 1]` mas fora de `[0.70, 0.95]` são aceites sem erro (produzem os artefactos ou desperdício de espaço já documentados).
- **`TOKEN_ACCENT_FG_OVERRIDE` — algoritmo de contraste automático especificado.** A nota dizia apenas "calcula baseando-se na luminância relativa" sem detalhar o algoritmo. Documentado o algoritmo real presente no código: **YIQ** com ponderação `R×299 + G×587 + B×114` e limiar 128 (≥128 → texto escuro `#1a1917`; <128 → texto branco `#ffffff`). Adicionados três exemplos de cores de baixo contraste onde o resultado automático pode não atingir WCAG AA.

### Documentação (auditoria de 2026-05-31)

Reconciliação da documentação com o código real, após auditoria. Sem alterações de comportamento — apenas a documentação passou a descrever o que o código faz hoje.

- **Comportamento de GIF animados por tipo de export documentado** (confirmado por teste do proprietário). `readme.md` §5.6, §5.7 e §8 actualizados: export **ZIP** preserva o arquivo GIF original com animação intacta; export **PDF** inclui apenas a primeira frame (a animação perde-se). A limitação anterior dizia apenas "tratado como imagem estática", sem distinguir os dois modos de export.
- **Protocolo de version bump reescrito com placeholders genéricos** (`agents.md` §12). A versão anterior usava `V23` e `V24` como exemplos concretos dentro das próprias instruções, o que tornava o protocolo auto-obsoleto a cada bump. Substituído por `VERSAO_ANTERIOR` / `VERSAO_NOVA`, tornando o protocolo permanentemente correcto independentemente da versão actual.
- **Migração de schema IndexedDB documentada com código executável** (`agents.md` §6). A nota existente avisava que a migração era necessária mas não instruía como fazê-la. Adicionados dois blocos de código: Caso A (adicionar nova store — seguro, sem migração de dados) e Caso B (alterar campos de store existente — requer iteração e reescrita), com regras críticas sobre o uso de `e.target.transaction` e atomicidade do `onupgradeneeded`.

- **Anotação (desenho livre) alinhada com o código V23.** O `readme.md` (§5.3), o `agents.md` (§7) e o `design-tokens.md` ainda descreviam o pipeline antigo (EMA + suavização Laplaciana + simplificação RDP + fecho automático a 12px). O código V23 mantém **apenas** a suavização EMA em tempo real; a Laplaciana e o auto-fecho foram removidos e o RDP deixou de ser chamado. A documentação foi corrigida nos três arquivos. Removida a referência à função `laplacian()`, que já não existe no arquivo.
- **Tabela de tokens do `readme.md` (§6.4) completada.** Faltavam três tokens que existem no código: `TOKEN_TITLE_START_COLOR`, `TOKEN_TITLE_ACCENT_COLOR` e `TOKEN_TITLE_END_COLOR`. Corrigido também o valor por padrão de `TOKEN_TITLE_START` para `'Capture '` (com o espaço final).
- **Texto duplicado removido.** No `readme.md` (§9) havia dois bullets repetidos após o aviso de recuperação; no `changelog.md` o parágrafo de introdução da V23 estava duplicado. Ambos limpos.
- **Cobertura de browser esclarecida na recuperação de dados.** O `readme.md` (§9) e o `agents.md` (§14) passaram a indicar que o modelo de partilha por perfil foi confirmado em Chromium/Windows; Firefox e Safari não foram testados formalmente.
- **Aviso de quota tornado claro.** O `readme.md` (§8) explica agora que o esgotamento de espaço falha sem aviso visível na tela (só na consola), e recomenda exportar com frequência em sessões grandes. Acrescentada nota sobre ausência de limite fixo de itens.
- **Anotação no código.** Adicionado comentário junto a `rdp()` no `capture-engine.html` a indicar que está definida mas inativa desde a V23.
- **Instruções de execução do `validate.sh`.** O `agents.md` (§10) passou a explicar como correr o script (ambiente Bash; em Windows via Git Bash/WSL) e a alternativa manual.
- **Nota de prevenção de deriva.** Adicionado item à checklist do `agents.md` (§11) para manter os três documentos sincronizados sempre que se altera um motor.
- **Checklist de validação reorganizada.** A Seção 11 do `agents.md` passou a ter duas partes claras: **A — verificações sem browser** (mecânicas via `validate.sh` + leitura de código) e **B — Checklist de Teste Manual no Browser**, agora única e completa (sessão, anotação, reordenação, visual/tema, export, multi-aba). Os testes de export, reordenação e comportamento da anotação, que antes estavam dispersos por vários documentos, ficaram reunidos num só sítio.
- **Linguagem.** Pequenos ajustes para linguagem mais clara e factual (ex.: "pasta inteligente", "sem perda de qualidade").
- **Toda a documentação convertida para PT neutro.** Os quatro `.md` e a string de erro de multi-aba na interface foram uniformizados: `ficheiro→arquivo`, `ecrã→tela`, `seção` (de `secção`), `utilizador→usuário`, `rato→mouse`, `registo→registro`, `anónimo→anônimo`, `deteção→detecção`, `contacto→contato`, `telemóvel→celular`, `aceder→acessar`, `comutar→alternar`, `gerido→gerenciado`, `noutras→em outras`, `premir→pressionar`, `predefinido→padrão` (com correção de concordância, ex.: "do ecrã"→"da tela"). Termos já neutros (`equipamento`, `máquina`, `botão`, `também`, `guardar`, `gravar`) foram mantidos. A tabela-glossário do `agents.md` (§2.1) preservou os exemplos PT-PT de propósito — são o "antes" que ilustra o que evitar.
- **Índice do `agents.md` completado.** Acrescentadas as Seções 13 (Decisões de Design) e 14 (Disaster Recovery), que existiam mas não constavam do índice.

### Corrigido (desenho à mão livre — fidelidade do traço)

> **Estado final (resumo):** RDP definido no código mas **não chamado** no fluxo de desenho. O traço livre é salvo com exactamente os mesmos pontos do preview (`annPath`), sem simplificação. A suavização activa é apenas o filtro EMA (α=0.35) em tempo real. Esta secção regista o percurso de decisões que levou a este estado.

**O traço salvo deixou de ser arredondado ao soltar — impacto: o resultado é igual ao que se vê a desenhar**
- Causa: ao soltar o mouse, o traço passava por uma suavização Laplaciana (2 iterações) antes de ser salvo, o que "alisava" e arredondava a forma em relação ao preview ao vivo.
- Correção: removida a suavização Laplaciana no `mouseup`. O traço é salvo com os mesmos pontos do desenho, renderizado pela mesma curva (`annCR`) usada no preview. Mantida apenas a simplificação RDP (agora com epsilon 1.0, mais suave), que reduz pontos redundantes sem alterar a forma — a pedido do usuário (manter arquivos leves sem perda visual).
- **Correção adicional (auto-fechar):** o traço ainda se alterava ao soltar quando a ponta ficava perto do início — o código marcava `closed = true` e a curva salva **fechava-se sozinha** (ligava ponta ao início), algo que não acontecia durante o desenho. A pedido do usuário, o auto-fechar foi **removido por completo**: o traço salvo fica sempre aberto, idêntico ao desenhado. Removido também o círculo-indicador de "fechar" do preview, que deixou de fazer sentido.
- **Correção final (quinas pontudas):** mesmo sem Laplaciana e sem auto-fechar, as quinas das curvas ficavam **suaves durante o desenho mas pontudas ao soltar**. Causa: a simplificação RDP removia os pontos intermédios das curvas; com menos pontos, a curva `annCR` fazia ângulos em vez de curvas. Como o traço já é filtrado em tempo real (só regista pontos a >5px de distância), o RDP poupava pouco e partia as curvas. **RDP removido do fluxo de desenho** (a função fica definida mas deixa de ser chamada): o traço é salvo com **exatamente os mesmos pontos** do preview (`annPath`), garantindo fidelidade total — o que se desenha é o que fica, quinas suaves incluídas.

### Corrigido

**Desenho à mão livre a piscar — impacto: traço estável durante o desenho**
- Causa: o manipulador de `mousemove` limpava e repintava o canvas inteiro (`annRedraw`) a cada evento de mouse, o que produzia cintilação entre o `clearRect` e o repintar, sobretudo com histórico grande ou muitos eventos por segundo.
- Correção: a acumulação de pontos do traço continua a acontecer a cada evento (precisão mantida), mas o **repintar do canvas passou a ser agendado via `requestAnimationFrame`**, coalescendo vários eventos num único repintar sincronizado com a tela. Adicionada também a limpeza do frame pendente (`cancelAnimationFrame`) no `mouseup` para o redraw final não ser sobreposto por um frame obsoleto. A matemática de suavização (EMA + Laplaciana + RDP) não foi alterada.

**Imagens a piscar e a saltar de posição ao arrastar — impacto: reordenação estável, com mouse e toque**
- Causa: a reordenação usava HTML5 drag-and-drop. Durante o `dragover`, mover o elemento arrastado no DOM (`insertBefore`/`appendChild`) alterava o que estava sob o cursor, o que voltava a disparar `dragover`/`dragleave` e reposicionava de novo — um ciclo de reposicionamento que continuava mesmo com o mouse imóvel.
- Correção: a reordenação foi **reescrita com Pointer Events**. O `initReorder` deixou de depender do mecanismo nativo de drag; passou a seguir o ponteiro diretamente, com um limiar de ~6px antes de iniciar o arrasto (um clique simples continua a abrir o item). Removidos os atributos `draggable` e os handlers `dragstart`/`dragend` dos thumbs e documentos. Adicionado `touch-action: none` aos itens para o arrasto funcionar também em telas de toque. A persistência da nova ordem no IndexedDB mantém-se igual.

**Correção de seguimento (mesmo ciclo):** após o primeiro teste, faltavam duas coisas no arrasto novo: (1) o `<img>` dentro de cada miniatura continuava a ser arrastável nativamente pelo browser, o que gerava uma *cópia fantasma* da imagem e impedia a reordenação — bloqueado agora via CSS (`-webkit-user-drag: none`, `pointer-events: none` na imagem) e em JS (`draggable=false` + cancelamento de `dragstart` nos itens); (2) a reordenação saltava de posição sem transição.

**Reordenação reescrita com a técnica FLIP (arrasto livre estilo celular):** numa segunda iteração, o arrasto passou a comportar-se como nas apps de iPhone/Android. O item arrastado sai do fluxo e **segue o cursor/dedo livremente** (via `transform`), flutuando por cima dos restantes (`z-index`, sombra, contorno). Os outros itens **deslizam suavemente** para abrir/fechar espaço, usando FLIP (First-Last-Invert-Play) com uma transição CSS (`transform 0.22s`). Ao largar, o item **anima até o lugar final** (snap suave) e só então a ordem é confirmada no DOM e gravada no IndexedDB. Mantida a supressão do clique-fantasma pós-arrasto e o limiar de ~6px que distingue clique de arrasto.

**Refinamento do arrasto (3.ª iteração, modelo placeholder):** a pedido, o arrasto passou a usar um **espaço reservado (placeholder)** em vez de reordenar os itens em tempo real. Comportamento final: ao segurar, o item **encolhe para 75%** (`transform: scale(0.75)`) e flutua em `position: fixed` a seguir o cursor (offset de pega corrigido para a escala); no destino aparece um **placeholder de área cinza muito suave** (tom derivado de `--text` via `color-mix`, ajustável pelas variáveis `--drop-ph-bg`/`--drop-ph-border`); os outros itens deslizam à volta do placeholder (FLIP a cada deslocação); e **só ao soltar** é que o item real assume a posição do placeholder e volta ao tamanho normal. Adicionada limpeza de transforms residuais dos irmãos no fim do gesto.

**Correção de flicker em fronteiras (4.ª iteração):** o placeholder oscilava (A→B→A) quando o cursor pairava junto à fronteira entre células, sobretudo perto da borda e na última linha. Três causas tratadas: (1) o cálculo do alvo passou a **excluir o próprio placeholder** (antes contava como célula e fazia o alvo alternar); (2) adicionada **histerese** — uma zona morta de ~18% à volta do centro de cada item, para o alvo só mudar quando o cursor passa o centro com margem, em vez de a cada micro-tremor; (3) reforçado o guard que ignora relocações que correspondem ao lugar atual do placeholder, evitando animações FLIP desnecessárias.

**Correção da causa-raiz do flicker (5.ª iteração):** mesmo com histerese, o placeholder ainda saltava para a posição errada (ex.: arrastar da posição 1 para a 5 punha o espaço vazio na 8). Causa real identificada: o cálculo do alvo media `getBoundingClientRect` dos itens **enquanto estes deslizavam** (animação FLIP em curso), apanhando posições intermédias e decidindo o alvo errado, o que disparava novo FLIP — um ciclo. Correção: o `targetBefore` passou a usar a **geometria de repouso** (`offsetLeft`/`offsetTop`/`offsetWidth`/`offsetHeight`), que é independente dos `transform` da animação, mais o scroll do contentor. O alvo deixa de depender de posições transitórias, eliminando o salto.

### Notas

- Esta versão precisa de **teste manual no browser** (desenhar à mão livre; arrastar imagens/documentos para reordenar; confirmar que um clique simples ainda abre o item; testar em mouse e, se possível, em toque). A verificação estática (`validate.sh`) confirma apenas a integridade estrutural — passou 15/15.
- O drop de **arquivos** vindos do sistema operativo para as zonas de imagens/documentos não foi alterado (continua a usar o mecanismo nativo, que é o adequado para esse caso).



Resultado de uma auditoria externa de documentação, com as decisões de intenção confirmadas pelo proprietário (Diogo Carvalho).

### Adicionado

**Licença MIT — impacto: a ferramenta pode ir para o GitHub e ser usada livremente por qualquer pessoa**
- Novo arquivo `LICENSE` (MIT, Copyright (c) 2026 Diogo Carvalho).
- Cabeçalho de copyright adicionado no topo do `capture-engine.html` (dentro de `<html>`, por isso é preservado pelo Quine em todos os exports). Garante que o aviso viaja mesmo quando só o `.html` é distribuído.
- Seção "Licença" adicionada ao `readme.md`, em linguagem simples.

**`validate.sh` — impacto: um agente de IA pode verificar a integridade sem abrir o browser e sem alucinar**
- Script de verificação estática (apenas grep + contagens + sintaxe via `node` se disponível): contagem de markers (=11), presença das funções Quine, spans de título, ausência de `eval/Function/document.write`, regra zero-dependência, cabeçalho de licença, ausência de código removido, sintaxe JS. Resultado determinístico (sempre igual para o mesmo arquivo). Documentado em `agents.md` (Seções 10 e 11).

### Removido

**`TOKEN_SUBTITLE` — impacto: menos código morto**
- Token "reservado" sem qualquer UI nem efeito. Removido da declaração, da `exportFile` (variável `sub` e respetiva substituição Quine) e da tabela em `design-tokens.md`.

**Modo PDF `'exact'` — impacto: remoção de ramo inalcançável**
- O modo `'exact'` (página = tamanho da imagem) não tinha nenhuma forma de ser ativado pela interface (os botões só produzem `auto`/`a4v`/`a4h`) e não estava associado ao controlo de qualidade do VB (esse é o `TOKEN_JPEG_QUALITY`). Ramo removido de `generatePDF`, e da documentação (`readme.md` §5.6, `agents.md` §8 e tabela de `pdfFmt`).

### Corrigido

**Documentação de recuperação de desastres — impacto: deixa de prometer algo que falha em vários cenários**
- A promessa "mesmo nome + mesma pasta → dados voltam" foi reescrita com as condições reais (confirmadas por teste): só funciona no **mesmo browser e mesmo perfil**, com o arquivo **extraído para uma pasta** (não aberto de dentro de um ZIP), e **não** funciona em janela anônima/privada. Atualizado em `readme.md` §9 e `agents.md` §14. *(Corrigido novamente na seção "modelo de armazenamento" mais abaixo: a bateria de testes provou que nome e pasta são irrelevantes — só o perfil de browser importa.)*

**Contradição da contagem de markers — impacto: instrução de integridade coerente**
- `agents.md` §5: o comentário do bloco `grep` dizia "Deve retornar 10"; corrigido para **11**, em linha com a Seção 11 e com o resultado real do `grep`. (A correção anunciada na V22.1 tinha ficado incompleta neste ponto.)

**Tamanho do arquivo no FAQ — impacto: número realista**
- `readme.md` §10: "140KB" corrigido para ~187KB (versão admin) com nota de que o Export User fica menor.

### Documentação — modelo de armazenamento (confirmado por testes)

Bateria de 13 testes executada pelo usuário em Windows 11 25H2 com Edge 148 e Chrome 148. Resultado: **o acesso aos dados é determinado pelo perfil de browser local**, não pelo nome/pasta/versão do arquivo (todos usam a mesma base `CaptureEngineDB`). Confirmado também que os dados são **locais à máquina** — não são sincronizados pela conta Google (mesmo perfil em outro PC = histórico vazio). A documentação de recuperação (README §9 e agents.md §14) foi reescrita para refletir o comportamento real e testado, substituindo a suposição anterior de que os dados eram "indexados pelo caminho do arquivo". Adicionada nota sobre isolamento natural por VDI e a possível exceção de ambientes com roaming de perfil. Protocolo e resultados documentados internamente (não incluídos no pacote distribuído).

### Documentação

- **Linguagem promocional neutralizada** (decisão do proprietário): "Auditoria FAANG/Militar", "Auditoria Zero Trust", "premium", "blindadas", referência a "padrões de grandes empresas (Google, Stripe, Notion, Apple, Microsoft)" e título "Gold Standard" da Seção 2.3 do `agents.md` substituídos por descrições factuais.
- **Modelo de ameaça XSS** explicitado em `agents.md` §1.3 (conteúdo de terceiros colado a partir de tickets de cliente).
- **Aviso de dados efémeros** em linguagem simples adicionado ao topo do `readme.md`.
- `readme.md` §12: estrutura de arquivos atualizada com `LICENSE` e `validate.sh`.

### Decisões mantidas (confirmadas pelo proprietário, sem alteração de comportamento)

- **Purge automático às 48h + sem backup automático** → comportamento **intencional** por privacidade. Para salvar, o usuário exporta PDF/ZIP. Apenas clarificado na documentação, não alterado.
- **Título com 3 partes e cores independentes** → **funcionalidade desejada** (ex.: "C" verde, "B" amarelo, "F" azul). Mantida; removida da lista de "complexidade desnecessária" da auditoria.



### Correções (auditoria de consistência documentação↔código)

**BUG #4 — delDoc selector sem especificidade de classe**
- `window.delDoc`: selector DOM corrigido de `[data-id="..."]` para `.d-item[data-id="..."]`
- Consistente com `delImg` que já usava `.t-item[data-id=...]`

**BUG #5 — Memory leak no modal de imagem (img.onerror ausente)**
- `openImgModal`: adicionado `img.onerror = function() { URL.revokeObjectURL(url); }`
- Object URL agora é libertado tanto em sucesso (`onload`) como em falha (`onerror`)

**INC #2 — Variável morta `_vbOverlayMdOnBackdrop` removida**
- Resíduo da versão anterior em que o VB fechava ao clicar fora
- Comportamento atual (fechar só pelo ✕) é intencional — ver Seção 13 do agents.md (Decisão D2)

**INC #3 — ZIP path traversal: sanitização de backslash Windows**
- `generateZIP`: adicionado `.replace(/\.\.\\/g, '')` para cobrir paths `..\` (Windows-style)
- Contexto de uso: ambiente bancário/corporativo multi-OS

**INC #5 — Blob validation ao carregar sessão (Safari/WebView)**
- `loadSession`: imagens e documentos são agora filtrados por `blob instanceof Blob && blob.size > 0`
- Protege contra Safari em modo privado e WebViews corporativos que deserializam Blobs como `{}`
- Sem esta proteção, `URL.createObjectURL({})` causava crash silencioso

### Nova Funcionalidade

**TOKEN_TITLE_END — Terceiro campo de título**
- HTML: `#tb-brand-name` refatorado de 1 span para 3 spans independentes (`#ui-title-start`, `#ui-title-accent`, `#ui-title-end`)
- Visual Builder (Tab Interface): novo campo "Texto Final" (`cfg-title-end`) com nota "espaços manuais"
- `initVbSync`: função `syncTitleSpans()` centraliza atualização live dos 3 campos
- `applyTokens`: inicializa e renderiza os 3 spans
- `exportFile` (Quine): substitui `TOKEN_TITLE_END` via regex (par com START e ACCENT)
- CSS: `#ui-title-accent` herda `opacity:0.5`, `#ui-title-end` herda `font-weight:600` e `opacity:1`
- Permite títulos como `CPC` (letras alternadas) ou `Service Desk Engine` com espaços manuais

### Decisões Documentadas (sem código alterado)

- **D1**: PDF desativado com imagens+docs — intencional (PDF é exclusivo de imagens)
- **D2**: VB não fecha ao clicar fora — intencional (proteção contra fecho acidental)
- **D3**: setInterval 5s mantido — cobre 16 eventos isDirty no VB sem triggerSave imediato
- **D4**: Placeholder "Imagem N" não atualiza após reorder — decorativo, não numeração oficial
- **D5**: triggerSave sem await em closeSettingsModal — risco aceite, coberto pelo interval

### Documentação

- `agents.md`: nova Seção 13 "Decisões de Design Documentadas" (D1-D6)
- `agents.md`: Seção 5 — nota sobre VB modal intencional
- `agents.md`: Seção 7 — lógica de `updateBtns()` documentada
- `agents.md`: Seção 9 — `_vbOverlayMdOnBackdrop` removida; nota sobre blob validation
- `agents.md`: Seção 11 — checklist atualizada com verificações TOKEN_TITLE_END
- `agents.md`: Seção 1.2 — TOKEN_TITLE_END documentado com exemplo de uso

## [V22] — 2026-05-30
### Adicionado

**Swatches de cor individuais para os 3 campos de título — impacto: permite criar títulos multicolor (ex: `C P C`) com cada parte numa cor independente**

Os campos "Texto Inicial", "Texto em Destaque" e "Texto Final" no Visual Builder têm agora cada um o seu próprio swatch de cor (circle picker), à imagem do padrão do Service Desk Engine. Duplo clique ou clique direito no swatch repõe a cor para automático (herda cor do contexto). Três novos tokens adicionados ao sistema:

- `TOKEN_TITLE_START_COLOR` — cor do Texto Inicial (vazio = herda `--text`)
- `TOKEN_TITLE_ACCENT_COLOR` — cor do Texto em Destaque (vazio = herda opacidade da accent)
- `TOKEN_TITLE_END_COLOR` — cor do Texto Final (vazio = herda `--text`)

Todos os 3 tokens são exportados pelo Quine em Export Admin e Export User. As CSS vars `--title-start-color`, `--title-accent-color`, `--title-end-color` são aplicadas dinamicamente. Quando vazias, a propriedade é removida do `documentElement` para herança natural.


### Corrigido

**Bug de deduplicação em `setLabel` — impacto: renomear imagem já não permite colisão com nomes na lixeira**

A função `setLabel` (renomear imagem ativa) verificava duplicados apenas contra `images[]`, ignorando `removed[]`. Era possível renomear uma imagem ativa para o mesmo nome de uma imagem na lixeira, violando a invariante de unicidade documentada no checklist ("deduplicação verifica contra listas ativas e lixeira"). A condição `while` foi corrigida para verificar ambas as listas, em paridade com `captureImg` e `restoreImg`.

### Documentação — Auditoria de Resiliência V22

Quatro divergências documentação/código identificadas e corrigidas:

- **`agents.md` — `genId` (Seção 3):** Formato documentado corrigido de `{prefix}_{entropia}` (2 partes, exemplo `img_1a2b3c4d5`) para o formato real de **3 partes**: `{prefix}_{Date.now()}_{5_chars_base36}` (ex: `img_1748611200000_a3f7k`). Adicionada explicação do papel de cada componente (timestamp para ordenação cronológica, base-36 para entropia contra colisões no mesmo milissegundo).
- **`agents.md` — Contagem de marcadores (Seção 5):** Adicionada nota explicativa que distingue **8 strings únicas de marcadores** (cobertura de `sanitizeForQuine`) de **10 ocorrências no HTML** (resultado do `grep -c` no checklist). Elimina a ambiguidade entre os dois números que apareciam sem contexto.
- **`agents.md` — Protocolo de Version Bump (Seção 12):** Corrigido de "2 locais dentro do `capture-engine.html`" para **3 locais**: comentário do Visual Builder, badge visual, e `SysLogger.info('Capture Engine Vxx Ready')`. Atualizada contagem de "5 locais vitais" para "5 arquivos (6 substituições no total)".
- **`agents.md` — Checklist (Seção 11):** Item de deduplicação agora é consistente com o comportamento real do código após a correção de `setLabel`.

### Auditoria de consistência — correções adicionais

**Bug `setDocName` — deduplicação incompleta (simétrico ao bug de `setLabel`)**

A função `setDocName` (renomear documento ativo) verificava duplicados apenas contra `docs[]`, ignorando `removedDocs[]`. O mesmo padrão de bug que existia em `setLabel` — prometido corrigido em V22 mas ainda presente nesta versão. Corrigido: condição `while` agora verifica `docs[]` e `removedDocs[]` em paridade com `captureDoc` e `restoreDoc`.

**Bug `annDrawShape` — side effects no branch `arrow`**

`annDrawShape` é uma função de desenho pura chamada por `annRedraw` (incluindo em undo/redo). O branch `type === 'arrow'` continha `annIsDirty = true` e manipulação de DOM (`btn-admin-save`, `btn-ann-close`) — side effects que não pertencem a uma função de draw. Consequência: abrir o modal de uma imagem com setas anotadas marcava imediatamente `annIsDirty = true` e exibia o botão de Export sem o usuário ter editado nada. Corrigido: side effects removidos do branch arrow; o estado dirty é gerenciado exclusivamente pelos event handlers de input (mouseup, commit text).

**`agents.md` — Contagem de markers: 10 → 11**

O `grep -c` real retorna 11 (não 10). Os 3 locais em `agents.md` que diziam 10 foram corrigidos para 11, e a nota explicativa expandida para detalhar as 4 categorias de linhas: 8 estruturais, 1 em `boot()`, 1 em `sanitizeForQuine`, 1 em `exportFile`.

**`agents.md` — Seção 9: 9 variáveis de estado adicionadas à tabela**

Variáveis ausentes da tabela de referência rápida adicionadas: `PRISTINE_HTML` (fonte primária do Quine), 4 flags de gesture de modal (`_imgOverlayMdOnBackdrop`, `_textOverlayMdOnBackdrop`, `_vbOverlayMdOnBackdrop`, `_expOverlayMdOnBackdrop`), `textModalItemId`, `textModalIsTrash`, `ANN_SIZES`, `ANN_TEXT_SIZES`.

**`design-tokens.md` — `TOKEN_NOME` clarificado**

`TOKEN_NOME` na seção de sintaxe era ambíguo (parecia um token real). Clarificado como placeholder de sintaxe.

---

## [V21] — 2026-05-30

### Corrigido

**Bug crítico do Quine Engine — impacto: configurações do administrador agora são corretamente aplicadas em todos os exports**

O regex de substituição de tokens de string no `exportFile()` usava o padrão `/const TOKEN_NOME='[^']*'/` (sem espaços em redor do `=`), enquanto as declarações reais no código têm o formato `const TOKEN_NOME = 'valor'` (com espaços). Consequência: todas as substituições de string — cor principal, título, texto do rodapé, rótulos de campos — falhavam silenciosamente. O arquivo exportado ignorava as configurações do Visual Builder e mantinha sempre os valores padrão. Corrigido com regex flexível `\s*=\s*` que aceita espaços opcionais; o output escreve sempre com espaços para consistência de leitura.

Tokens afetados: `TOKEN_MAIN_COLOR`, `TOKEN_ACCENT_FG_OVERRIDE`, `TOKEN_TITLE_START`, `TOKEN_TITLE_ACCENT`, `TOKEN_SUBTITLE`, `TOKEN_USER_LABEL`, `TOKEN_EQUIP_LABEL`, `TOKEN_FOOTER_TEXT`.

Tokens não afetados (usavam regex `=[^;]+` sem aspas, já funcionavam): `TOKEN_SHOW_SESSION_USER`, `TOKEN_SHOW_SESSION_PC`, `TOKEN_JPEG_QUALITY`, `TOKEN_MAX_IMG_DIMENSION`, `TOKEN_AUTO_PURGE_HOURS`, `TOKEN_DEBUG_MODE`.

### Documentação — Auditoria de Resiliência Operacional

Auditoria completa de consistência entre documentação e código. Todas as divergências identificadas foram corrigidas:

- **`agents.md`:** Contagem de markers corrigida de 8 para 10 (com nota sobre o segundo par `ADMIN_JS` em `boot()`); localização de `BOOT_HTML` corrigida para "dentro do bloco ADMIN_JS"; 15+ variáveis de estado global adicionadas à Seção 9 (`lastSaveAt`, `pdfFmt`, `zipModeActive`, `modalIsTrash`, `modalItemId`, variáveis de zoom/pan, variáveis de anotação em progresso); `idbTx` adicionada à tabela de funções críticas; schema de `localStorage` documentado (chave `theme`, histórico de `ec_pending_session`); modo PDF `exact` documentado na Seção 8.
- **`readme.md`:** Diagrama `boot()` corrigido — hierarquia invertida (`init → boot`, não `boot → init`) e lista de funções expandida de 7 para 18 chamadas reais; termos `Estado Pristine` e `initSessionSync` adicionados ao glossário; seção de Diagnóstico de Export adicionada para administradores; suporte Safari documentado (parcial, mitigado pelo fallback `BOOT_HTML`).
- **`design-tokens.md`:** Instrução de formato de tokens atualizada para refletir que espaços à volta do `=` são suportados e recomendados; referência a "V17" em `TOKEN_TITLE_END` corrigida para "a partir da V17".
- **`changelog.md`:** Nomenclatura "Zero Trust Audit" substituída por "Auditoria de Resiliência Operacional" em todas as ocorrências da V20.
- **`agents.md` — Checklist (Seção 11):** Corrigida referência residual a "8 markers" (deve ser 10); adicionada nova seção **Documentação** com dois itens preventivos: verificação do diagrama `boot()` sempre que uma função de inicialização for adicionada ou removida, e verificação da tabela de variáveis globais sempre que uma nova variável de estado for introduzida.

---

## [V20] — 2026-05-30

### Adicionado

**Melhorias na Lixeira (Trashbar) — impacto: gestão e recuperação rápida de arquivos apagados**
- **Botão de Restauro:** Adicionado um botão dedicado de restauro nos itens da lixeira, permitindo recuperar imagens ou documentos com apenas um clique.
- **Pré-visualização (Hover):** Arquivos na lixeira passam a exibir um ícone de inspecção ("olho") quando o cursor é posicionado sobre eles, melhorando a interatividade visual.

**Alerta visual ao fechar sem salvar — impacto: alerta de modificações pendentes**
- Introduzida uma animação de aviso fluida (*pulse* com escala a 1.08x) nos botões de "Confirmar" e "Cancelar", que é acionada caso o usuário tente fechar o modal com modificações pendentes por gravar.

### Modificado

**Estado Real de Modificação (annIsDirty) — impacto: bloqueios inteligentes apenas quando estritamente necessário**
- Introduzida uma flag de ciclo de vida em tempo real (`annIsDirty`) para detetar alterações efetivas feitas com o cursor. Isto substitui as pesadas comparações de base de dados, eliminando os falsos positivos que bloqueavam indevidamente o fecho imediato das imagens.

**Lógica de fecho dinâmico do modal de edição — impacto: proteção contra perda de dados**
- O botão de "Fechar" (`X`) no canto superior direito do modal desaparece dinamicamente assim que uma edição é iniciada. O botão permanece visível apenas se não houver modificações pendentes, canalizando o usuário para cliques seguros e prevenindo encerramentos acidentais.

**Padronização e UI dos botões de ação — impacto: aspeto visual mais uniforme e limpo**
- Removido o efeito de sombra (`box-shadow`) nos botões de ação, padronizando o design para um aspeto mais limpo, harmonioso e com maior destaque dentro da UI.
- Adicionado destaque visual refinado aos ícones de texto dentro do modo de anotação.
- Removido o comportamento de seleção acidental de texto (*highlight*) no ícone de "Excluir Sessões", tornando o clique na UI mais consistente.

**Limpeza automática (Purge) — impacto: base de dados resiliente em falhas isoladas**
- A funcionalidade de limpeza de sessões antigas (`purgeExpired`) foi reestruturada: a deleção individual de cada sessão isola-se em blocos `try/catch`, pelo que uma eventual corrupção num arquivo não interrompe a eliminação do restante lixo acumulado.
- As transações IndexedDB (`idbTx`) foram reforçadas para intercetar falhas nativas (`tx.onerror`) diretamente na raiz, prevenindo erros silenciosos.

### Corrigido

**Expansão da Lixeira (Trashbar) — impacto: UI responsiva e sem interrupções visuais**
- Aperfeiçoada a lógica de expansão do painel da lixeira: a animação de abertura é agora ininterrupta, crescendo na proporção exata do conteúdo e eliminando o *flicker* da barra de *scroll* que surgia por breves milissegundos.

**Gestão de Memória e Downloads (Object URLs) — impacto: downloads fiáveis e eficiência de RAM**
- Resolvido um bug crítico nos botões de download (`img-modal-dl` e `text-modal-dl`) herdado da V19. A URL do arquivo era revogada instantaneamente (`URL.revokeObjectURL`), cortando a ligação antes de o browser iniciar o download. Foi aplicado um desfasamento seguro de 1000ms.
- Eliminado um *memory leak* na rotina de conversão de imagens (`imgToJPEG`). Anteriormente, se o carregamento falhasse (`img.onerror`), a memória do *blob* nunca era liberta. A revogação ocorre agora de forma imediata na captura do erro.

### Auditoria de Resiliência Operacional

**Recuperação de Desastres e Expectativas — impacto: eliminação de risco de perda de dados e falsas expectativas**
- **Same-Origin Policy Documentada:** Adicionado alerta crítico para administradores garantirem a consistência do nome e pasta do arquivo nas atualizações enviadas aos usuários, prevenindo o reinício silencioso da base de dados e aparente perda de histórico.
- **Desambiguação do Export:** Definida explicitamente a regra de que os botões de Exportar NUNCA guardam os dados da sessão corrente (apenas a configuração).
- **Mecanismos de Esgotamento de Quota:** Documentado o comportamento passivo da aplicação ao esgotar o armazenamento do disco, de forma a acalmar os usuários num eventual desastre (as sessões anteriores ficam salvaguardas e ilesas).
- **Disaster Recovery e DevTools:** Adicionado aos manuais operacionais novos passos para recuperar dados bloqueados ou dados corrompidos usando apenas os recursos nativos e as premissas estritas do IndexedDB, e documentada a lógica oculta de contorno a bloqueios CORS do WebKit/Chromium em ambientes `file://` que justificam o `BOOT_HTML`.

**Finalização da Auditoria de Resiliência Operacional — impacto: correção final de inconsistências técnicas**
- **Quine Engine Token Regex:** O motor Quine foi ajustado (`\s*=\s*`) para suportar e escrever tokens com espaços ao redor do `=`, garantindo legibilidade do código-fonte sem quebrar o regex em exports futuros.
- **Boot Flow Corrigido:** O diagrama de arquitetura no `readme.md` foi corrigido para refletir a ordem real de execução: `init()` chama `boot()`, e não o inverso.
- **Suporte Safari:** Documentado o suporte parcial e as mitigações do Quine Engine para o browser Safari.
- **Modo PDF Exato:** Documentado formalmente o modo `exact` (geração de PDF à escala original) nos manuais `agents.md` e `readme.md`.
- **Contagem de Markers:** A documentação de validação (grep) foi atualizada de 8 para 10 markers, refletindo a duplicação natural do bloco `ADMIN_JS_START/END` no motor.
- **Glossário e Estado Global:** Documentados conceitos ausentes como `Estado Pristine` e variáveis de estado recém-descobertas no código base.

---

## [V19] — 2026-05-26

### Modificado

**Desenho livre — suavização equilibrada para mouses de baixa qualidade — impacto: traços suaves sem perder cantos definidos**

- EMA `alpha` ajustado de `0.55` para `0.35` — meio termo entre responsividade e suavização; permite desenhar formas com cantos (quadrados, retângulos) sem que as esquinas sejam demasiado arredondadas.
- Adicionada passagem de suavização **Laplaciana** (2 iterações) antes do RDP no `mouseup`, eliminando jitter residual sem deformar cantos.
- Epsilon do RDP ajustado de `1.5` para `1.8`.
- Raio de **fecho automático** do traço reduzido de 24px para **12px** — evita fechos acidentais ao passar perto do ponto inicial.

### Removido

**`CaptureEngineApp-Atalho.md` — removido do pacote — impacto: distribuição simplificada, sem método não fiável**

O guia de atalho Windows (`CaptureEngineApp-Atalho.md`) foi removido do pacote após confirmação de falhas em ambiente corporativo. O método `--app` do Edge é bloqueado por políticas GPO em organizações com hardening de browser, tornando o guia inútil e potencialmente confuso. O Capture Engine abre diretamente com duplo clique no `capture-engine.html` em qualquer sistema operativo — esse continua a ser o método oficial e único suportado.

### Adicionado

#### Ferramenta de Texto — Reformulação Completa
- **Fix: Salto de posição eliminado** — O texto agora é renderizado exatamente onde o cursor clicar. A causa era um erro de `textBaseline`: o canvas usava `alphabetic` (baseline na base dos caracteres) enquanto o input HTML era posicionado a partir do topo. Corrigido com `textBaseline = 'top'` no canvas e `top = screenY` no input.
- **Negrito (Ctrl+B)** — Toggle de negrito durante a digitação ou ao clicar no botão B na toolbar. Ativo por padrão.
- **Itálico (Ctrl+I)** — Toggle de itálico durante a digitação ou ao clicar no botão I na toolbar.
- **Tamanho de fonte variável** — Os botões −/+ de espessura, quando a ferramenta Texto está ativa, controlam o tamanho da fonte em 5 níveis: 14 · 18 · 24 · 36 · 48px (padrão: 24px).
- **Double-click para reeditar** — Clicar duas vezes em cima de um texto já colocado (antes de confirmar) reabre o campo de edição com o conteúdo original, mantendo cor, bold e itálico.
- **Cor ao reeditar** — Ao reeditar texto existente via double-click, clicar numa swatch atualiza a cor do texto em tempo real.

#### Ícone da Ferramenta Texto
- Substituído o ícone T "vazado" (com caule duplo e linha de base) por um T tipográfico com serifs em cima e baixo — mais harmonioso com os restantes ícones da toolbar.

### Melhorias Técnicas
- `annHistory` agora armazena `{bold, italic, fontSize}` por entrada de texto, permitindo fidelidade total na re-renderização.
- `annShowTextInput` refatorizado: aceita `prefillText` opcional para suportar edição de texto existente.
- Botões B/I aparecem automaticamente ao selecionar a ferramenta Texto e ocultam ao mudar para outra ferramenta.
- `annEditingTextIdx` rastreia se o usuário está a editar uma entrada existente ou a criar uma nova.

### Corrigido (pós-release)

#### Ferramenta Texto — Correções de Comportamento
- **Fix: Salto invertido (texto subia)** — O `<input>` mesmo com `padding:0` adicionava *internal leading* que deslocava o texto visível abaixo do topo do elemento. Corrigido forçando `line-height` e `height` do input ao valor de `scaledFontSize` — o texto fica encostado ao topo, alinhado com o `textBaseline='top'` do canvas.
- **Fix: Double-click criava novo texto em vez de editar** — O `mousedown` disparava antes do `dblclick` na sequência de eventos do browser (`mousedown → mouseup → click → mousedown → mouseup → click → dblclick`), chamando `annShowTextInput` com `annEditingTextIdx=-1` e destruindo a intenção de edição. Solução: single-click aguarda **220ms** via `setTimeout` antes de abrir input novo; o `dblclick` cancela o timer e toma conta da edição.
- **Fix: Cor não mudava durante edição de texto** — Clicar numa swatch disparava `blur` no input (perda de foco), fazendo `commit()` antes de a cor ser aplicada. Corrigido com `mousedown.preventDefault()` nas swatches, botões B e I **apenas quando o input está ativo** — o input mantém foco, `inp.style.color` atualiza em tempo real, e `inp.focus()` garante continuidade de digitação.
- **Fix: Perda de texto ao pressionar Escape durante edição** — O `dblclick` fazia `annHistory.splice(_i, 1)` imediatamente ao abrir o input. Se o usuário pressionasse Escape, o texto era apagado permanentemente. Corrigido: sem splice; `annRedraw()` passa a saltar o índice `annEditingTextIdx` (texto fica em "ghost" durante edição); Escape faz `annRedraw()` que o restaura.
- **Fix: Timer fantasma em `annDeactivate`** — `annTextClickTimer` era declarado dentro de `initAnnotation()`, tornando-o inacessível a `annDeactivate`. Ao fechar o modal durante os 220ms, o timer disparava `annShowTextInput` num overlay invisível. Corrigido: timer hoistado para scope de módulo; `annDeactivate` limpa-o explicitamente.

#### Visual Builder — Admin Gate
- **Fix: Ícones admin não desapareciam ao fechar o VB** — `deactivateAdmin()` estava encapsulada no closure de `initAdminGate`, inacessível a `closeSettingsModal`. Corrigido expondo-a como `window._deactivateAdmin`; `closeSettingsModal` chama-a ao fechar — ícones desaparecem imediatamente ao clicar no X.

#### Ferramenta Desenho Livre — Suavização (valores pré-V19, antes dos ajustes acima)
- **Fix: Linha tremia ao desenhar** — O `annPath` acumulava todos os pontos em bruto do mouse (threshold 3px), e o Catmull-Rom interpolava fiel e fielmente cada micro-tremor. Três camadas de correção:
  1. **EMA (Exponential Moving Average, α=0.55)** — cada ponto é misturado com o anterior (`0.55 × novo + 0.45 × último`) antes de entrar no path, eliminando tremor de alta frequência em tempo real.
  2. **Threshold 3px → 5px** — pontos mais próximos que 5px do anterior são descartados.
  3. **RDP no commit (ε=1.5px)** — ao soltar o mouse, o path é simplificado com Ramer-Douglas-Peucker antes de ser salvo em `annHistory`, removendo pontos colineares redundantes sem alterar a geometria visível.

> **Nota:** Estes valores de EMA (α=0.55) e RDP (ε=1.5px) foram os valores iniciais. Foram posteriormente ajustados para α=0.35 e ε=1.8px na seção "Modificado" acima.

---

## [V18] — 2026-05-25

### Modificado

**Sessão criada apenas na primeira interação real — impacto: abrir e fechar o programa sem usar não gera sessão no histórico**

Anteriormente, `init()` chamava `createSession()` de forma incondicional ao abrir o arquivo — uma sessão era escrita no IndexedDB mesmo que o usuário abrisse e fechasse o programa sem qualquer interação. Ao longo do tempo, isto acumulava sessões vazias no histórico. Agora `init()` não cria sessão. A criação acontece de forma lazy via `ensureSession()`, que é chamada automaticamente no primeiro evento real: digitar nos campos de sessão, colar uma imagem, arrastar um documento. Sessão sem interação = sessão inexistente.

Alterações técnicas:
- `init()`: removida chamada `await createSession()`
- `saveSession()`: retorna imediatamente se `sessId === null` (guard contra o intervalo de 5s sem sessão ativa)
- `ensureSession()` já existia e já era chamada por `captureImg`, `captureDoc` e `initSessionSync` — nenhuma alteração necessária nessas funções

**Remoção do launcher VBS — substituído por guia de atalho manual**

Os arquivos `CaptureEngineApp.vbs` e `CaptureEngineApp.vbs.md` foram removidos do pacote V18 por alerta de segurança (scripts VBS são bloqueados por políticas de segurança em ambientes corporativos e detetados como potencial ameaça por alguns antivírus). Substituídos pelo arquivo `CaptureEngineApp-Atalho.md` — guia passo a passo para criar um atalho Windows manualmente usando o parâmetro `--app` do Edge, sem nenhum script.

**Ícone de desenho livre — lápis em vez de caneta/pena**

O ícone do botão de desenho livre (modo Anotar) e do botão "Anotar" no modal de imagem foram substituídos por um lápis padrão (path `M17 3a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L17 3z`), mais reconhecível e intuitivo para a ação de desenho manual.

**Desenho livre suavizado com Bezier quadrático + point thinning**

O traço de desenho livre era renderizado com `lineTo` puro, produzindo linhas quebradas e tremidas especialmente em movimentos rápidos. Implementada suavização via curvas Bezier quadráticas: cada segmento usa o ponto médio entre dois pontos consecutivos como endpoint da curva, com o ponto original como ponto de controlo. Adicionado point thinning (pontos com distância < 3px são descartados) para reduzir ruído sem perder fidelidade. A mesma lógica aplica-se à re-renderização do histórico (`annDrawShape`).

### Corrigido

**Português neutro — correções de regionalismo PT-PT na interface**

- `title="Guardar"` (botão de confirmar anotação) → `title="Confirmar"` — mais preciso semanticamente e neutro
- `"Fecha-as e recarrega esta página"` (erro de IDB com múltiplas abas) → `"Feche-as e recarregue esta página"` — forma verbal mais neutra
- `title="Cor (Duplo clique para Automático)"` → `title="Cor (Clique duplo para Automático)"` — ordem natural em português brasileiro

---

## [V17] — 2026-05-25

### Modificado

**Remoção do botão e mecanismo de "Nova Sessão" — impacto: usuário não consegue abrir sessões em janelas separadas fora do launcher VBS**

O botão "Nova Sessão" (ícone de duplos quadrados sobrepostos na barra de topo) foi removido por decisão de produto. O fluxo de abrir uma nova sessão numa janela independente fazia sentido apenas em conjunto com o launcher `CaptureEngineApp.vbs`; fora desse contexto, o usuário podia inadvertidamente abrir múltiplas instâncias do Capture Engine no browser, cada uma com o seu próprio contexto de sessão, gerando confusão. A remoção garante que o fluxo de trabalho é sempre numa única janela, com navegação entre sessões feita pelo histórico interno.

Remoções associadas:
- HTML: bloco `<button id="btn-new-sess">` da barra de topo
- JS `boot()`: handler `_newSessLock` / `onclick` / `localStorage.setItem('ec_pending_session')` / `window.open()`

**Limpeza de código morto pós-remoção (auditoria V17)**

Após a remoção do botão de nova sessão, foram identificados e eliminados dois blocos de código que se tornaram dead code:

- `init()` — Bloco `ec_pending_session`: lia a chave `ec_pending_session` do localStorage para decidir se devia carregar uma sessão pendente em vez de criar uma nova. Como nada escreve mais nessa chave, o bloco de leitura + remoção + `loadSession` era código morto. Removido.

- `initPickers()` — Setups de `onclick` para `btn-img-pick` e `btn-doc-pick`: tentavam registar handlers de clique em IDs que nunca existiram no HTML (os botões usam `onclick` inline com `document.getElementById` diretamente). Os guards `if($('btn-img-pick'))` preveniam crashes mas o código era inoperante. Removidos. Os handlers `onchange` dos `<input type="file">`, que são a parte funcional real, foram preservados.

## [V16] — 2026-05-24

### Modificado

**Documentação completamente reescrita — impacto: onboarding sem dependência de conhecimento verbal**

Toda a documentação foi auditada, reorganizada e expandida seguindo práticas comuns de boa documentação técnica (glossário, perfis de usuário, fluxos reais, FAQ). As principais mudanças:

- `readme.md` — Expandido de guia funcional para documentação completa com glossário de termos técnicos, perfis de usuário (usuário final / administrador / desenvolvedor), fluxos reais, limitações conhecidas, FAQ, e schema da base de dados. Qualquer pessoa sem contexto prévio consegue entender o sistema sem perguntar aos criadores.

- `agents.md` — Expandido com schema completo do IndexedDB (campos, tipos, obrigatoriedade, índices), documentação de `ec_pending_session`, `BOOT_HTML`, `_ensurePromise`, `isDirty`, `_vbLabelDirty`, e `sysColors`. Adicionados fluxos de comportamento em diagrama (captura de imagem, Export User, apagar sessão ativa). Adicionada tabela de referência rápida de funções críticas. Adicionada documentação de variáveis de estado global.

- `design-tokens.md` — Adicionada explicação sobre como o motor decide entre modo texto e modo binário no modal de documento. Adicionadas notas detalhadas sobre `TOKEN_TITLE_END` (obsoleto mas preservado), `TOKEN_ACCENT_FG_OVERRIDE` (vazio = automático), e `TOKEN_USER_LABEL`/`TOKEN_EQUIP_LABEL` (vazio = padrão visual).

- `CaptureEngineApp.vbs.md` — Adicionada tabela de dados em disco criados pelo launcher, nota sobre suporte exclusivo Windows, e resolução de problema de Edge instalado em caminho não-padrão.

---

## [V15] — 2026-05-24

### Corrigido

**Race condition na criação de sessões — comportamento: sem impacto visível, mas dado potencialmente corrompido**

Ao colar imagem e texto simultaneamente (dois `Ctrl+V` muito rápidos), a aplicação podia criar duas sessões em paralelo em vez de uma. O usuário não notaria imediatamente — a interface parecia normal — mas a base de dados ficaria com uma sessão "fantasma" sem conteúdo. A causa: ambas as operações assíncronas verificavam `if(sessId)return` ao mesmo tempo, antes de qualquer uma ter terminado de criar a sessão. Adicionado um mutex (`_ensurePromise`) que garante que a segunda operação espera a primeira terminar.

**Quine Engine corrompido por certos textos em tokens — comportamento: export de User produzia arquivo quebrado**

Se o administrador colocasse o texto `EXPORT MODAL` ou `FIM EXPORT MODAL` em qualquer campo do Visual Builder (título, rodapé, etc.), o Quine Engine ao fazer Export de User interpretava esse texto como um marcador de código e removia a seção HTML correspondente do arquivo exportado. O resultado era um arquivo que abria sem o modal de exportação. A função `sanitizeForQuine()` já protegia outros marcadores (`ADMIN_*`) mas não estes dois. Adicionada proteção por zero-width space nos dois marcadores em falta.

**`restoreDoc` verificava apenas metade das listas na deduplicação — comportamento: nomes potencialmente inconsistentes após restauro**

Ao restaurar um documento da lixeira, a aplicação verificava colisões de nomes apenas contra os documentos ativos. A função equivalente para imagens (`restoreImg`) e para captura inicial (`captureDoc`) já verificavam contra ambas as listas (ativos + lixeira). Esta assimetria podia resultar em nomes de arquivos internamente não-únicos em sessões com muitos documentos movidos entre ativo e lixeira. Alinhado o comportamento de `restoreDoc` com o resto do motor.

**`purgeExpired` engolia erros de base de dados em silêncio — comportamento: sessões expiradas não apagadas, sem aviso**

O bloco `try{}catch(e){}` que apaga documentos removidos durante o purge de sessões expiradas capturava erros do IndexedDB mas não os registava em lado nenhum. Se a base de dados estivesse num estado inconsistente, o purge falhava e a pasta de `removed_documents` crescia indefinidamente sem que ninguém soubesse. Adicionado `SysLogger.warn` com a mensagem de erro para diagnóstico.

**Launcher VBS falhava em pastas com nomes acentuados — comportamento: aplicação não abria, sem mensagem de erro clara**

Se o arquivo estivesse numa pasta chamada `Área de Trabalho`, `Documentação`, ou qualquer pasta com caracteres portugueses acentuados, a URI `file:///` gerada pelo launcher ficava malformada. O Edge tentava abrir o URL inválido e ou mostrava página em branco ou página de erro genérica. A função `SecureURLEncode` passou a codificar em `%HH` qualquer caractere com código ASCII > 127.

---

## [V14] — 2026-05-24

### Adicionado

**Estado inicial em branco (Pristine State) — impacto: experiência mais limpa e previsível ao abrir**

Até à V13, ao abrir a aplicação sem histórico existente, uma sessão era criada automaticamente e aparecia imediatamente no histórico (mesmo vazia). O usuário via uma entrada `#0001` no histórico mesmo antes de fazer qualquer coisa. Agora a interface abre completamente em branco. A sessão só aparece no histórico no momento em que o usuário interage pela primeira vez (cola uma imagem, escreve o nome do usuário, etc.). Histórico limpo = mente limpa.

**Bordas permanentes nos botões de captura — impacto: sem layout shift, interface mais estável**

Os botões "Adicionar Imagem" e "Adicionar Documento" passaram a ter uma borda cinzenta sempre visível (mesmo em repouso), que transita para azul no hover. Antes, a borda só aparecia no hover, causando um "salto" de 1px no layout quando o cursor passava por cima. A borda permanente elimina esse salto — o elemento nunca muda de tamanho.

**Bordas permanentes nos botões de export ZIP — impacto: consistência visual no modo ZIP**

Os botões "Imagens em PDF" e "Imagens Separadas" (quando o modo ZIP está ativo) passaram a usar a classe `btn-zip-cta` com borda azul permanente. Antes, a borda desaparecia ao mover o cursor — o que criava inconsistência visual com os outros botões.

**Detecção automática do tema do sistema — impacto: respeita a preferência do OS na primeira abertura**

Se o usuário abre a aplicação pela primeira vez sem ter definido preferência de tema, a app passa a seguir o tema do sistema operativo (dark/light). Depois de o usuário alternar manualmente, essa escolha fica guardada e sobrepõe-se à preferência do OS.

### Modificado

**Ícone do botão "Nova Sessão" substituído — impacto: mais harmonia visual com os outros ícones da barra de topo**

O ícone de "quadrado com +" foi substituído pelo ícone de "duplos quadrados sobrepostos" (o mesmo SVG do botão "Imagens Separadas"). A razão foi puramente visual: o conjunto de ícones da barra de topo ficou mais coeso.

**FAB mobile em estado neutro — impacto: menos distração em mobile**

O botão flutuante de colar em mobile passou de sempre azul/accent para cinzento discreto em repouso. O azul só aparece no momento exato do toque (`:active`). Em mobile, um botão sempre azul chama atenção desnecessariamente — a cor deve sinalizar ação, não presença constante.

**Chips de seleção de modo (Auto/Vertical/Horizontal) — impacto: clareza visual sobre qual modo está ativo**

O chip selecionado passou a ter borda cinzenta permanente (que vai para azul no hover). Os chips não selecionados ficam sem borda em todos os estados. O contraste é claro: borda = ativo, sem borda = inativo.

**Auto-colapso da sidebar de histórico quando vazia — impacto: mais espaço disponível automaticamente**

Quando o histórico está completamente vazio e o usuário clica fora da sidebar, ela fecha sozinha. Antes ficava aberta mesmo sem conteúdo.

**Espaçamento da left sidebar otimizado — impacto: menos espaço morto em monitores grandes**

Os gaps e paddings internos da coluna esquerda foram reduzidos de valores maiores para valores `clamp` mais compactos. Em monitores de alta resolução, a versão anterior desperdiçava demasiado espaço vertical entre os campos.

### Corrigido

**Touch targets em mobile falhavam — comportamento: apenas 25% esquerdo dos cards respondia a toque**

Em telas com `max-width: 900px`, clicar/tocar num thumbnail de imagem só funcionava se o toque fosse no quarto esquerdo do card. O resto da área não respondia. A causa era um overlay CSS (`pointer-events: auto`) que intercetava os eventos antes de chegarem ao elemento correto. Corrigido com regras defensivas: `pointer-events: auto` + `touch-action: manipulation` nos elementos corretos, `pointer-events: none` forçado no overlay.

**Sessão reutilizada ao reabrir a app — comportamento: estado "sujo" ao abrir em vez de interface limpa**

Ao reabrir a aplicação, o `init()` verificava se havia uma sessão vazia no IndexedDB e reutilizava-a. O resultado era que dados da sessão anterior (nome do usuário, configurações) podiam persistir indevidamente. Agora `init()` chama sempre `createSession()` de forma incondicional (exceto quando há uma sessão pendente explícita via `localStorage`).

**Auto-save demorava 5 segundos após digitar — comportamento: primeiros caracteres podiam perder-se num crash**

O handler dos campos User e Equipamento marcava `isDirty=true` mas aguardava o intervalo de auto-save (5 segundos) para escrever no IndexedDB. Se a aplicação fechasse ou o browser crashasse nos primeiros 5 segundos, o texto perdia-se. Agora `triggerSave()` é chamado imediatamente a cada keystroke — a latência de escrita passa de até 5 segundos para imediata.

**Campos de texto não limpavam ao apagar sessão ativa — comportamento: texto fantasma visível após apagar**

Ao apagar a sessão atualmente ativa, os campos User, Equipamento e Nome mantinham os valores na tela. Visualmente parecia que ainda havia dados de sessão, quando na verdade não havia sessão nenhuma. Os três campos passaram a ser zerados explicitamente no reset.

**Nova sessão criada automaticamente após apagar — comportamento: apagar a última sessão criava imediatamente uma nova**

Após apagar a sessão ativa, o motor criava automaticamente uma nova sessão vazia que aparecia imediatamente no histórico. O usuário que apagou a última sessão intencionalmente ficava com `#0001` de volta no histórico sem ter pedido isso. A criação automática foi removida — o interface fica em branco e aguarda interação real.

**Navegação automática ao apagar sessão ativa — comportamento: tela ficava vazio mesmo com sessões adjacentes**

Ao apagar a sessão ativa com histórico existente, a interface ficava em branco em vez de navegar para a sessão adjacente. Reescrita a lógica: antes de apagar, o motor captura qual é a sessão vizinha (`allBefore[idx+1] || allBefore[idx-1]`), e após apagar navega automaticamente para ela. Se não houver vizinha, aplica o estado pristine completo.

**Fechar modal de imagem clicando no fundo não funcionava — comportamento: só o botão × fechava**

Clicar na área escura fora da imagem devia fechar o modal, mas não funcionava. A causa: o `.modal-box` ocupa `96vw × 94vh` com fundo transparente, e o `#ann-viewport` (o canvas de anotação) cobria toda a área de "fundo" e intercetava os cliques. Corrigido adicionando `#ann-viewport` como alvo válido de fecho por backdrop, sem afetar o bloqueio de fecho durante zoom ou anotação ativa.

**Sidebar mostrava texto errado ao limpar rótulos no Visual Builder — comportamento: limpeza não era refletida em tempo real**

Ao apagar o rótulo de "Campo 1" ou "Campo 2" no Visual Builder, o campo correspondente na sidebar não limpava — mantinha "User" ou "Equipamento" como texto fixo. O fallback `|| 'User'` no código da sidebar sobrepunha-se ao valor vazio. Removidos os fallbacks — a sidebar agora espelha exatamente o que está no Visual Builder, incluindo o estado vazio.

### Visual Builder — Melhorias UX

**Terminologia "evergreen" no Visual Builder — impacto: funciona para qualquer contexto de uso, não só Service Desk**

Os títulos das linhas do VB mudaram de referências hardcoded a "User" e "Equipamento" para "Campo 1", "Campo 2", "Rótulo — Campo 1" e "Rótulo — Campo 2". Uma organização que usa o CE para outro fim (ex: jurídico) não quer ver "Equipamento" hardcoded na interface de configuração.

**Fecho do Visual Builder apenas pelo × — impacto: sem perdas acidentais de configuração**

O Visual Builder deixou de fechar ao clicar no backdrop (área escura fora do modal). Fechar por clique acidental a meio de uma configuração era frustrante — todas as alterações não guardadas perdiam-se. Agora só o botão × fecha.

**Label "Qualidade PDF" clarificada — impacto: sem confusão sobre o que é comprimido**

O label passou de `"Qualidade PDF (JPEG)"` para `"Qualidade do PDF"`. A descrição foi atualizada para explicar que as imagens PNG originais são convertidas para JPEG internamente *apenas durante a geração do PDF* — os arquivos originais na sessão ficam sempre em PNG. Vários usuários confundiam esta compressão com uma degradação permanente dos originais.

---

## [V13] — 2026-05-22

### Adicionado

**Menu dinâmico de opções ZIP — impacto: clareza sobre as duas formas de exportar ZIP**

Ao clicar no botão ZIP quando há imagens na sessão, a interface revela dois botões de escolha: "Imagens em PDF" e "Imagens Separadas". Antes, estas opções eram menos óbvias. Os novos botões usam estilo outline com uppercase, estilo consistente com os chips de seleção de modo.

### Corrigido

**ReferenceError no modal de cópia de texto — comportamento: botão Copiar falhava silenciosamente**

Um erro de referência a variável (`ReferenceError`) no bloco `catch` do modal de cópia de texto fazia com que, se a cópia falhasse, o código de recuperação também falhasse. O usuário via o botão reagir mas nada acontecia e nenhuma mensagem de erro aparecia. Corrigido com referência correta ao elemento de botão.

**Purge baseado na data errada — comportamento: sessões ativas eram apagadas prematuramente**

O purge automático calculava a idade de uma sessão com base em `createdAt` (data de criação), não em `updatedAt` (data de última atividade). Uma sessão criada há 3 dias mas usada ontem seria apagada — o critério correto é a última atividade, não a criação. Corrigido para usar `updatedAt`.

**Colisões de nomes com itens na lixeira — comportamento: deduplicação incompleta permitia nomes duplicados internamente**

A deduplicação de nomes verificava apenas os itens ativos. Um item na lixeira com o mesmo nome de um item sendo capturado não era detetado. Em casos extremos podia causar conflitos no ZIP. Estendida a verificação para incluir sempre `removed_images` e `removed_documents`.

**Nomes com acentos vazios no ZIP — comportamento: arquivos com nomes acentuados apareciam sem nome no ZIP**

Ao criar o ZIP, nomes de arquivos com acentos (`imagem-ã.png`) eram processados sem `normalize('NFD')`, resultando em strings vazias ou corrompidas no ZIP dependendo do sistema operativo. Adicionada normalização NFD antes do empacotamento.

**Tecla Escape fechava o visualizador inteiro durante anotação — comportamento: perda de trabalho de anotação**

Pressionar Escape com o modo de anotação ativo e uma ferramenta de desenho selecionada devia apenas cancelar a ferramenta de desenho — não fechar o modal. Antes fechava tudo. Isolado o handler de Escape para agir apenas no contexto correto.

---

## [V12] — 2026-05-22

### Adicionado

**Motor de zoom com física "zoom-to-pointer" — impacto: experiência de visualização fluida e natural**

O visualizador de imagens foi reescrito do zero. O zoom com scroll/roda do mouse passa a centrar-se exatamente no ponto onde o cursor está — se amplia o canto superior direito, é esse canto que fica no centro. Antes o zoom centrava-se sempre no centro da imagem, forçando o usuário a fazer pan depois de cada zoom. Limites de 20% a 1000%. Barra de controlo flutuante com glassmorphism que aparece apenas quando o zoom é diferente de 100%.

**Modal de histórico centralizado em mobile — impacto: uso com o polegar muito mais fácil em smartphones**

Em telas pequenos (`max-width: 900px`), o histórico de sessões passou de drawer lateral para modal centralizado. A largura e altura do modal foram otimizadas para uso com o polegar — targets de toque maiores, posição central mais acessível.

**Body scroll lock no modal de histórico mobile — impacto: sem rolar o fundo acidentalmente**

Ao abrir o histórico em mobile, `document.body.overflow = 'hidden'` previne que o conteúdo principal role enquanto o usuário navega no modal. Ao fechar, o scroll é restaurado.

**Rótulos personalizáveis no Visual Builder — impacto: o CE funciona para qualquer domínio, não apenas Service Desk**

Adicionados dois novos tokens (`TOKEN_USER_LABEL`, `TOKEN_EQUIP_LABEL`) e dois campos no Visual Builder para renomear os labels "User" e "Equipamento". Uma clínica pode querer "Médico" e "Paciente"; um escritório jurídico pode querer "Advogado" e "Processo".

**Nomeação cronológica de sessões (#0001, #0002...) — impacto: histórico ordenado e sem ambiguidade**

Sessões sem nome digitado pelo usuário passaram de `Sessão-1` para `#0001`, `#0002`, etc. O formato com zeros à esquerda garante ordenação alfabética correta em qualquer sistema — `#0009` vem antes de `#0010`, ao contrário de `Sessão-9` vs `Sessão-10`.

### Corrigido

**Colar com Ctrl+V falhava em Edge/WebKit — comportamento: clipboard ignorado silenciosamente em certos browsers**

Em algumas versões do Edge e browsers baseados em WebKit, `DataTransferItemList` não é iterável com `for...of`. O loop de leitura do clipboard falhava silenciosamente sem colar nada. Substituído por iteração com índice numérico explícito (`for(let i=0; i<items.length; i++)`), que funciona em todos os browsers.

**Eventos fantasma bloqueavam a interface em mobile — comportamento: clicar na grelha de imagens mudava de sessão**

O `#sb-content` (a lista de sessões, invisível quando a sidebar está fechada) tinha `pointer-events: auto` mesmo quando não estava visível. Em mobile, a camada invisível intercetava cliques sobre a grelha de imagens e ativava sessões no histórico sem o usuário saber. Corrigido: `pointer-events: auto` apenas quando o modal está aberto (`.mobile-open`).

---

## [V11] — 2026-05-20

### Adicionado

**Sidebar esquerda em altura completa — impacto: sem cortes em janelas pequenas**

A sidebar esquerda passou a ocupar 100% da altura disponível. Em telas verticais curtos (janelas pequenas ou resoluções baixas), a versão anterior cortava o fundo da sidebar.

**Compressão vertical fluida — impacto: interface utilizável em qualquer tamanho de janela**

Usando `flex-shrink: 1` e `clamp` com `vh`, os elementos da sidebar esquerda comprimem-se suavemente quando a janela encolhe, antes de ativar scroll. Evita que os botões PDF/ZIP sejam cortados em janelas baixas.

### Corrigido

**Dados de sessão vazavam entre sessões — comportamento: campos mostravam texto de uma sessão anterior**

Ao navegar para uma sessão diferente, campos não preenchidos nessa sessão mostravam os valores da sessão anterior. A causa: a atribuição usava `|| 'valor_anterior'` em vez de atribuição incondicional. Corrigido com zeragem explícita antes de atribuir novos valores.

**Todas as sessões mostravam a mesma hora — comportamento: histórico inútil para ordenação temporal**

A lista de histórico exibia o horário do último auto-save (o mesmo para todas as sessões). A data mostrada passou a ser `createdAt` (data de criação da sessão), que nunca muda.

---

## [V10] — 2026-05-19

### Adicionado

**Content Security Policy — impacto: proteção adicional contra injeção de scripts**

Adicionada metatag CSP no `<head>` que restringe quais scripts e estilos podem ser carregados. Num arquivo que corre localmente com `file://`, esta é uma camada extra de defesa contra conteúdo injetado.

**Mini-modal de texto para anotações — impacto: adicionar texto nas imagens sem popups do sistema**

A ferramenta de texto no anotador usava `prompt()` — o popup nativo do browser que congela toda a interface e tem estilo diferente em cada browser. Substituído por um mini-modal interno (`#ann-text-overlay`) com estilo consistente, foco automático, e suporte a Enter/Escape.

**`TOKEN_DEBUG_MODE` — impacto: logs de debug invisíveis para usuários finais**

Adicionado token que controla se `SysLogger` escreve na consola do browser. Em exports de User, este token é automaticamente definido como `false` — os usuários finais nunca veem logs técnicos na consola.

### Corrigido

**Path traversal e colisões no ZIP — comportamento: arquivos podiam sobrescrever-se mutuamente**

Nomes de arquivos com `/`, `\`, ou `../` podiam criar estruturas de pastas não intencionais dentro do ZIP, ou sobrescrever arquivos uns com os outros. Adicionada sanitização de todos estes caracteres e verificação de unicidade cross-lista antes do empacotamento.

**Caracteres `$` corrompiam o HTML exportado pelo Quine — comportamento: arquivo exportado quebrado**

A função `.replace()` do JavaScript trata `$` no segundo argumento como referência especial a grupos de captura do regex. Um token com o valor `$1` ou `$$` corromperia silenciosamente o HTML gerado. Substituídas as strings de substituição simples por funções callback, que não têm este comportamento especial.

**Export do Quine com DOM mutado — comportamento: arquivo exportado diferente do original**

Se o Quine não conseguisse ler o arquivo original via `fetch(location.href)` (ex: quando corre em `file://` sem servidor), usava `document.documentElement.outerHTML` — o DOM atual, com todas as mutações de runtime (legendas editadas, contadores atualizados). O arquivo exportado ficava "sujo" com estado da sessão atual. Corrigido usando a constante estática `BOOT_HTML` como fallback — capturada antes de qualquer mutação.

---

## [V9] — 2026-05-19

### Adicionado

**Rodapé institucional — impacto: identificação da ferramenta em cada janela**

Adicionado rodapé com texto configurável via `TOKEN_FOOTER_TEXT`. O token `{YEAR}` é substituído automaticamente pelo ano atual. Opacidade 50% e `pointer-events: none` — presente mas discreto.

**Estados visuais de sessão na sidebar — impacto: sempre claro qual a sessão ativa**

A sessão ativa na sidebar passou a ter fundo `var(--bg)` (ligeiramente diferente do fundo da sidebar), distinguindo-a claramente das sessões inativas. Hover suave nos itens inativos.

**Persistência da sidebar aberta entre sessões — impacto: navegação mais rápida entre sessões**

Ao clicar numa sessão diferente no histórico, a sidebar permanece aberta. Antes fechava automaticamente a cada navegação, forçando o usuário a reabri-la para cada mudança de sessão.

### Corrigido

**FOUC (Flash of Unstyled Content) em dark mode — comportamento: flash branco ao abrir em modo escuro**

Ao abrir a aplicação em modo escuro, havia um flash branco momentâneo antes de o JavaScript aplicar a classe `.dark`. Corrigido com um script síncrono imediatamente após `<body>` que aplica `.dark` antes de qualquer pintura do DOM.

**Bordas residuais nos inputs de User e Equipamento — comportamento: borda visível em repouso que não devia estar**

Os campos User e Equipamento mostravam uma borda visível em repouso e tinham listeners `mouseover/mouseout` que alteravam o estilo. O design correto é sem borda em repouso, com `box-shadow` apenas no foco. Removidos os listeners e as bordas inline.

---

## [V8] — 2026-05-18

### Adicionado

**Cantos perfeitamente retos em imagens — impacto: imagens como evidências, não como decoração**

Thumbnails, wrappers e legendas de imagens passaram a ter `border-radius: 0`. A distinção visual é intencional: elementos de texto (botões, cards, modais) têm cantos arredondados — são interfaces amigáveis. Imagens têm cantos retos — são evidências técnicas, precisas e formais.

**Design borderless em cards de documentos — impacto: interface mais limpa, menos "tabular"**

Os cards de documentos (`.d-item`) passaram a ter `border: 1px solid transparent` em vez de borda visível. Os documentos flutuam sobre o fundo sem criar uma grelha rígida de linhas.

**Lixeira unificada (Trash Bar) — impacto: recuperação fácil de items removidos por engano**

A barra inferior de lixeira foi integrada com botões de restauro e download direto, sem precisar de abrir um modal separado para cada item.

### Corrigido

**Nomes duplicados e prefixos `001-` nos ZIPs — comportamento: ZIPs com arquivos incorretamente nomeados ou colisões**

Capturas sequenciais podiam gerar nomes duplicados em certos fluxos. O ZIP exportado incluía prefixos numéricos (`001-imagem-1.png`) desnecessários. Corrigido o algoritmo de deduplicação e removidos os prefixos — os nomes dos arquivos no ZIP são agora as legendas limpas das imagens.

---

## [V7] — 2026-05-17

### Base da Arquitetura Atual

Esta versão estabeleceu as fundações sobre as quais todo o motor assenta:

- **IndexedDB com 5 object stores:** `sessions`, `images`, `documents`, `removed_images`, `removed_documents` — persistência local, assíncrona, sem localStorage para dados grandes
- **Visualizador de texto modal:** Abre documentos de texto inline com área de texto monoespaçada; arquivos binários (PDF, DOCX) mostram mensagem amigável para download
- **Anotador vetorial:** Desenho sobre screenshots com círculos, retângulos, setas, texto livre — achatamento lossless direto em PNG (as anotações ficam permanentes na imagem)

---

*Capture Engine · Zero-Dependency Quine System*

