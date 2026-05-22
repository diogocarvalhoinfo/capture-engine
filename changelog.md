# Changelog · Capture Engine

> Registo completo de todas as atualizações, otimizações e correções do Capture Engine, alinhado com as especificações de excelência de interface e integridade arquitetural.

---

## [V12] — 2026-05-22

### Adicionado
- **Modal Mobile Centralizado de Histórico:** Transformação estrutural da gaveta (drawer) lateral da versão móvel num Modal de Alta Densidade posicionado centralmente (`fixed` + `transform: translate`), aumentando os *touch targets* e harmonizando a escala visual.
- **Isolamento de Estado (Body Scroll Lock):** Inserção de bloqueio dinâmico do `document.body.style.overflow` quando o Modal de Histórico está ativo, impedindo a rolagem indesejada do conteúdo base.
- **Configuração de Etiquetas Customizáveis:** Ampliação do *Visual Builder* para permitir alteração em tempo real das etiquetas e *placeholders* "User" e "Equipamento", materializada com dois novos tokens SSOT no *Quine Engine* (`TOKEN_USER_LABEL` e `TOKEN_EQUIP_LABEL`).
- **Nomenclatura Cronológica com Preenchimento Lógico:** Modificada a mecânica de nomeação por *fallback* para históricos não identificados. Substituição de `Sessão-X` pelo formato rígido padronizado com zeros à esquerda (`#0001`, `#0002`).

### Corrigido
- **Mitigação Crítica de Eventos Fantasma (Pointer-Events):** Resolução cirúrgica (1 linha) num vazamento de eventos de toque no CSS Mobile. O bloco `#sb-content` invisível estava configurado forçadamente com `pointer-events: auto`, provocando a interceção de cliques do ecrã e alterando sessões invisivelmente. Modificado para reagir apenas quando o modal está aberto (`.mobile-open`).
- **Normalização Semântica:** Substituição transversal da terminologia nativa `Sessões/Sessão` para `Histórico` em toda a aplicação (Visual Builder, labels SVG nativos e textos de cabeçalho).
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
- **Mitigação de Path Traversal e Colisão (ZIP):** Sanitização estrita de delimitadores de diretórios (`/`, `\`, `../`) em ficheiros exportados e algoritmo de deduplicação cross-lista para evitar sobrescritas silenciosas em sistemas operativos durante extração.
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
- **Prevenção de Colisão Militar (ZIP):** Resolução inteligente de nomes duplicados em capturas sequenciais (`imagem-1`, `imagem-2`) e remoção de prefixos `001-` nos ficheiros ZIP exportados para evitar problemas de compatibilidade nos SO.

---

## [V7] — 2026-05-15

### Adicionado
- **IndexedDB Multi-Store Engine:** Implementação do banco de dados local com 5 tabelas separadas para total controle assíncrono do histórico de capturas.
- **Visualizador de Texto Modal:** Área interativa para visualização de logs com isolamento de ficheiros binários (mensagens centradas de erro amigável).
- **Anotador Vetorial Estendido:** Desenho vetorial sobre screenshots (círculos, retângulos, setas, texto livre) com achatamento lossless direto em PNG.

---

*Capture Engine · FAANG Standards · Zero-Dependency Quine System*
