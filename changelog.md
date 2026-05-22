# Changelog · Capture Engine

> Registo completo de todas as atualizações, otimizações e correções do Capture Engine, alinhado com as especificações de excelência de interface e integridade arquitetural.

---
## [V13] — 2026-05-22

### Adicionado
- **Menu Dinâmico de Opções ZIP (Alinhamento de Identidade):** Conversão dos botões de exportação (PDF e ZIP) em botões dinâmicos de opção estilo outline (`btn-outline`) quando o modo ZIP é ativo, mimetizando a experiência dos chips ativos/inativos.
- **Harmonização Estética da Barra Lateral:** Unificação dos fundos, bordas e comportamentos dos botões sob a secção de exportação com os botões superiores de captura, adotando fundo transparente e ativação de bordas na cor primária (`var(--accent)`) apenas em estado hover/focus, preservando as dimensões espaciais para eliminar qualquer oscilação (layout shift).
- **Tipografia em Caixa Alta (Uppercase):** Enforcamento automático via CSS (`text-transform: uppercase`) das etiquetas textuais do menu ZIP de opções.

### Corrigido
- **Mitigação de Exceção Silenciosa em Modal de Texto:** Reparação do bug crítico (ReferenceError) no tratamento de erros do modal de cópia de texto, assegurando o uso correto do botão na secção `catch`.
- **Integridade da Base de Dados:** Correção do ciclo de expiração (*purge*) das sessões no `IndexedDB`. O sistema passa a basear a idade na data da última atualização (`updatedAt`) em vez da data de criação (`createdAt`). Adicionado *fallback* resiliente para salvaguardar a operação da base de dados caso a inicialização primordial falhe.
- **Unicidade Assíncrona Total (Zero-Collision):** Extensão da dedupicação nativa para garantir que nomes de `screenshots` ou `textos` colados não entram em conflito quer com arquivos ativos quer com arquivos presentes nos removidos (`Trash Bar`). Adição da lógica de decomposição de sufixos `-\d+` no caso de edições manuais.
- **Normalização UTF-8 em Arquivos ZIP:** Aplicação técnica da rotina `normalize('NFD')` no empacotamento ZIP, garantindo que acentos gráficos severos não convertem os nomes exportados para strings vazias.
- **Isolamento de Escape em Modo de Anotação:** A tecla `Escape` atua agora estritamente no cancelamento da ferramenta de desenho se a janela de anotação estiver ativa, impedindo o fecho abrupto do visualizador inteiro e perda do progresso visual.
- **Extensões Corretas via Mobile Paste FAB:** Restruturação do *File Object* dinâmico do botão `Mobile Paste` para incorporar corretamente extensões (`.png`, `.jpg`, `.webp`) adequadas ao formato inferido do MIME type.
- **Reatividade Visual no Visual Builder:** Correção lógica que garante a exibição e oclusão imediata da barra secundária (`id-section-wrap`) quando os campos "User" e "Equipamento" são desativados nos settings ao vivo.
- **Sincronização de Painéis Flutuantes:** A rotina de `closeImgModal` inclui agora o fecho implícito do mini-modal de texto inline do motor de anotações (caso exista), mantendo o DOM escrupulosamente limpo.
- **Manutenção de Documentação (Gold Standard):** Alinhamento perfeito dos *fallback tokens* da rotina de *Visual Builder* para coincidirem com as etiquetas padrão PT (`User` e `Equipamento`), mitigando ambiguidades case-sensitive.
- **Libertação Silenciosa de ObjectURLs:** Aplicação da função simétrica de revogação (`revokeObjectURL`) no `onerror` da injeção de imagens de pré-visualização.
- **Padronização Ortográfica V13:** Eliminação de regionalismos ("ficheiros") nos balões de informação do botão ZIP, em prol do padrão neutro português standard ("arquivos").

---

## [V12] — 2026-05-22

### Adicionado
- **Motor de Navegação de Imagens (Zoom-to-Pointer FAANG):** Refatoração integral do visualizador de screenshots. Adicionado suporte a Scroll/Wheel (ou Pinch no trackpad) com física de deslocação focal para o cursor do rato e limites flexíveis de 20% a 1000% sem perda de estado.
- **Glassmorphism Zoom UI:** Introdução de pílula flutuante (barra de controlo) translúcida (`backdrop-filter`) com botões táteis dinâmicos (+, -, Reset a 100%) ativada estritamente quando a imagem desvia da sua escala original.
- **Modal Mobile Centralizado de Histórico:** Transformação estrutural da gaveta (drawer) lateral da versão móvel num Modal de Alta Densidade posicionado centralmente (`fixed` + `transform: translate`), aumentando os *touch targets* e harmonizando a escala visual.
- **Isolamento de Estado (Body Scroll Lock):** Inserção de bloqueio dinâmico do `document.body.style.overflow` quando o Modal de Histórico está ativo, impedindo a rolagem indesejada do conteúdo base.
- **Configuração de Etiquetas Customizáveis:** Ampliação do *Visual Builder* para permitir alteração em tempo real das etiquetas e *placeholders* "User" e "Equipamento", materializada com dois novos tokens SSOT no *Quine Engine* (`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL`).
- **Nomenclatura Cronológica com Preenchimento Lógico:** Modificada a mecânica de nomeação por *fallback* para históricos não identificados. Substituição de `Sessão-X` pelo formato rígido padronizado com zeros à esquerda (`#0001`, `#0002`).

### Corrigido
- **Mitigação de Falha Silenciosa no Clipboard (Zero-Trust Loop):** Reparação de bug obscuro no motor WebKit/Edge onde colar objetos (`Ctrl+V`) originava um erro assíncrono indetetável de `DataTransferItemList is not iterable`. Substituído por iteração clássica forçada num vetor nativo `Array`, restaurando a leitura blindada da área de transferência.
- **Bloqueio Defensivo de Modal em Zoom:** Adicionada interdição no evento de clique do overlay (`#img-modal-overlay`). Caso a imagem esteja ampliada, o utilizador já não fecha a janela inadvertidamente ao falhar um arrastamento de `pan`. Exige agora clique forçado no 'X', tecla Escape, ou reposição a 100%.
- **Mitigação Crítica de Eventos Fantasma (Pointer-Events):** Resolução cirúrgica (1 linha) num vazamento de eventos de toque no CSS Mobile. O bloco `#sb-content` invisível estava configurado forçadamente com `pointer-events: auto`, provocando a interceção de cliques da área de exibição e alterando sessões invisivelmente. Modificado para reagir apenas quando o modal está aberto (`.mobile-open`).
- **Normalização Semântica e Coerência de Cursor:** Substituição transversal da terminologia nativa `Sessões/Sessão` para `Histórico` em toda a aplicação. Remoção de cursor forçado `zoom-in` em idle para manter a seta padrão neutral consoante exigência de UI minimalista.
- **Consistência de Ícones em Telas Pequenas:** Troca do SVG da barra lateral em smartphones pelo ícone de "Relógio", uniformizando-o com o botão principal do desktop.

---

## [V11] — 2026-05-20

### Adicionado
- **Isolamento Estrutural da Sidebar:** Refatoração arquitetural (colocando o Trash Bar numa coluna direita), permitindo à barra lateral esquerda expandir a 100% da altura da janela, eliminando cortes em ecrãs verticais curtos.
- **Compressão Fluida Vertical:** Implementação de `flex-shrink: 1` e cálculos fluidos (`clamp` com `vh`) nas media queries para colapso elástico ultra-suave. A interface absorve a redução drástica da janela sem ativar scrolls prematuramente.
- **Harmonização Flex FAANG:** Spacing dinâmico estendido para garantir que a interface respire muito mais em resoluções com espaço abundante de altura, mantendo-se perfeitamente ancorada ao topo.

### Corrigido
- **Vazamento de Dados de Sessão:** Resolução na função `loadSession()`. Valores em memória vazavam para campos não preenchidos de sessões antigas, corrigido com atribuição incondicional via falback nulo.
- **Congelamento Visual de Datas:** A barra de histórico exibia todas as sessões com a mesma hora (hora de último auto-save). Substituído logicamente e de forma restrita para exibição do `createdAt` puro.
- **Inconsistência Tipográfica do Histórico:** Aplicada lógica de espelhamento DOM in-stream em `toUpperCase()`. Isto impede que nomes de sessões que apareciam visualmente maiúsculas via CSS fossem guardados internamente e exibidos lateralmente com capitalização quebrada, alinhando simultaneamente o fallback padrão (`SESSÃO-N`).

---

## [V10] — 2026-05-19

### Adicionado
- **Content Security Policy Metatag:** Hardening local robusto no head restringindo injeções de script/estilo no motor SPA offline.
- **Mini-Modal de Texto Inline para Anotador:** Substituição da função bloqueante `prompt()` nativa por um mini-modal `#ann-text-overlay` estilizado com focagem automática rápida e atalhos de teclado Enter/Escape.
- **Controlo de Consola por Token:** Introdução de `TOKEN_DEBUG_MODE` para controlo de outputs operacionais, o qual é desativado de forma automática em exports de utilizador para purgar logs informativos em produção.

### Corrigido
- **Mitigação de Path Traversal e Colisão (ZIP):** Sanitização estrita de delimitadores de diretórios (`/`, `\`, `../`) em arquivos exportados e algoritmo de deduplicação cross-lista para evitar sobrescritas silenciosas em sistemas operacionais durante extração.
- **Resolução de Callback de Regex (Quine):** Substituição de strings simples por funções callback de substituição nos métodos `.replace` do Quine, neutralizando injeções acidentais de caracteres especiais (`$`) que corrompam o HTML gerado.
- **Estabilização de Pristine Fallback:** Uso da constante estática `BOOT_HTML` no fallback do Quine caso o fetch local falhe (e.g. sob protocolo `file://`), impedindo exportação de DOMs mutados em runtime.
- **Proteção do StatusBar contra innerHTML:** Isolamento de injeção dinâmica no status bar utilizando criação explícita e concatenação programática de nós de texto em vez de interpolações perigosas em `innerHTML`.
- **Prevenção de Downgrade de IDB e NaN em JPEG:** Inclusão de tratamentos `onblocked` no IndexedDB e sanitizações de coerência com `isFinite()` na qualidade do exportador JPEG.

---

## [V9] — 2026-05-19

### Adicionado
- **Rodapé de Créditos Institucionais:** Integração do rodapé de créditos oficial (`© 2026 • CAPTURE ENGINE • DIOGOCARVALHOINFO.COM`) alinhado no rodapé da aplicação.
- **Estilo de Crédito Ultra-Sutil:** Definido a opacidade de 50% (`opacity: 0.5`) e `pointer-events: none` para garantir invisibilidade tátil operacional sem perturbar cliques.
- **Estados Visuais de Sessão:** Implementados estados `.active` e `:hover` altamente harmonizados na barra lateral esquerda (Sessões Anteriores) utilizando `var(--bg)` de modo a combinar perfeitamente com os campos de identificação de usuário e máquina.
- **Centralização de Modais Global:** Configuração das modais (`.modal-hdr`) para centralizar os títulos de forma síncrona com botões fechar circulares absolutos à direita.
- **Persistência SPA Completa:** Mecanismo SPA que mantém a barra lateral aberta e estendida ao navegar entre sessões antigas, melhorando radicalmente a velocidade de trabalho.

### Corrigido
- **Prevenção de FOUC (Anti-Flicker):** Correção do "piscar de tema" (FOUC). Substituição do carregamento tardio por um micro-script síncrono injetado logo após a tag `<body>` para aplicar a classe `.dark` antes de qualquer renderização gráfica do ecrã.
- **Inputs de Identificação Sem Bordas:** Remoção de bordas inline residuais e listeners mouseover/mouseout nos inputs de identificação (**User** e **Equipamento**), retornando o comportamento limpo sem bordas (borda visível apenas com box-shadow no foco).
- **Limpeza do Visualizador de Imagem:** Exclusão das setas de controle físicas (chevrons) no overlay da imagem do visualizador, mantendo a área com design minimalista ultra-limpo (e a navegação por setas do teclado preservada).
- **Estabilidade Visual na Remoção:** Ajuste do layout de remoção de sessões antigas. O botão de remoção agora permanece em fluxo oculto invisível quando inativo para evitar pulos/quebras de linhas de texto.
- **Segurança de Sincronização do IDB:** Automatização de recarregamento limpo caso a sessão ativa atual seja apagada pelo utilizador através do painel lateral.

---

## [V8] — 2026-05-18

### Adicionado
- **Gold Standard Convergence:** Ajustes minuciosos nas proporções visuais da UI para total simetria com o *SDE V48 Gold Standard*.
- **Cantos Perfeitamente Retos (Imagens):** Aplicação de `border-radius: 0` e remoção de divisórias rígidas nas legendas (`.t-label`) exclusivamente em cartões de evidências gráficas.
- **Design System Premium Borderless:** Remoção de bordas visíveis em painéis e cartões de documentos, permitindo que flutuem organicamente sobre o fundo.
- **Lixeira Unificada (Trash Bar):** Integração dos botões de restauro e download direto no rodapé de remoção de documentos e imagens.

### Corrigido
- **Prevenção de Colisão Militar (ZIP):** Resolução inteligente de nomes duplicados em capturas sequenciais (`imagem-1`, `imagem-2`) e remoção de prefixos `001-` nos arquivos ZIP exportados para evitar problemas de compatibilidade nos SO.

---

## [V7] — 2026-05-15

### Adicionado
- **IndexedDB Multi-Store Engine:** Implementação do banco de dados local com 5 tabelas separadas para total controle assíncrono do histórico de capturas.
- **Visualizador de Texto Modal:** Área interativa para visualização de logs com isolamento de arquivos binários (mensagens centradas de erro amigável).
- **Anotador Vetorial Estendido:** Desenho vetorial sobre screenshots (círculos, retângulos, setas, texto livre) com achatamento lossless direto em PNG.

---

*Capture Engine · FAANG Standards · Zero-Dependency Quine System*
