# Changelog · Capture Engine

> Registo completo de todas as atualizações, otimizações e correções do Capture Engine, alinhado com as especificações de excelência de interface e integridade arquitetural.

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
