# Capture Engine · V13

> Motor de captura e exportação de evidências — zero-dependency, air-gapped, single-file HTML Quine.

---

## Visão Geral

O **Capture Engine (CE)** é uma aplicação irmã do *Service Desk Engine*, desenhada para capturar, organizar e exportar screenshots e documentos como **PDF** ou **ZIP** — sem dependências externas, sem CDN, sem backend.

Casos de uso:
- **Service Desk** — Coleta de evidências para chamados/tickets (screenshots, logs, configurações)
- **Jurídico** — Compilação de documentos antes do envio
- **Uso pessoal** — Juntar screenshots/documentos para upload em portais ou chamados técnicos

---

## Arquitetura

```
capture-engine.html    ← Arquivo único (Quine Engine)
├── <style>            ← CSS Design System (variáveis, dark mode, componentes borderless)
├── <body>             ← HTML Skeleton (top bar, painéis, sidebar, modais)
└── <script>           ← JavaScript Engine (IIFE isolado)
    ├── SysLogger      ← Logging estruturado para console
    ├── TOKENS         ← Configuração injetável via Quine
    ├── IndexedDB      ← 5 object stores (sessions, images, documents, removed_*)
    ├── Session Mgr    ← CRUD de sessões com auto-save a cada 5s
    ├── Capture        ← Ctrl+V (clipboard), drag-drop, file picker com auto-sequenciamento
    ├── Reorder        ← Drag-and-drop nativo para reordenação
    ├── Annotation     ← Canvas overlay (círculo, retângulo, seta, desenho livre, texto)
    ├── Text Preview   ← Visualizar texto com deteção de binários e cópia
    ├── PDF Engine     ← Gerador PDF raw (JPEG via Canvas, Auto/A4V/A4H)
    ├── ZIP Engine     ← Gerador ZIP raw (CRC32, armazenamento de documentos limpos e únicos)
    ├── Visual Builder ← Modal de configuração com 4 abas
    ├── Quine Engine   ← Auto-mutação HTML com strip markers
    └── Admin Gate     ← 6 cliques no logo = modo admin
```

---

## Tokens de Configuração (SSOT)

| Token | Tipo | Default | Descrição |
|---|---|---|---|
| `TOKEN_TITLE_START` | string | `'Capture'` | Parte inicial do título |
| `TOKEN_TITLE_ACCENT` | string | `'Engine'` | Parte em destaque do título |
| `TOKEN_TITLE_END` | string | `''` | Sufixo opcional |
| `TOKEN_SUBTITLE` | string | `''` | Subtítulo abaixo do logo |
| `TOKEN_MAIN_COLOR` | hex | `'#0ea5e9'` | Cor principal da interface |
| `TOKEN_ACCENT_FG_OVERRIDE` | hex | `''` | Override da cor de texto sobre destaque |
| `TOKEN_SHOW_SESSION_USER` | bool | `true` | Mostrar campo User |
| `TOKEN_SHOW_SESSION_PC` | bool | `true` | Mostrar campo Equipamento |
| `TOKEN_USER_LABEL` | string | `'User'` | Customização do rótulo/placeholder para o campo User |
| `TOKEN_EQUIP_LABEL` | string | `'Equipamento'` | Customização do rótulo/placeholder para o campo Equipamento |
| `TOKEN_JPEG_QUALITY` | float | `0.92` | Qualidade JPEG no export PDF (0.70–0.95) |
| `TOKEN_MAX_IMG_DIMENSION` | int | `0` | Dimensão máxima de redimensionamento (0=original) |
| `TOKEN_AUTO_PURGE_HOURS` | int | `48` | Horas para purge automático de sessões |
| `TOKEN_DEBUG_MODE` | bool | `true` | Ativa console logs de desenvolvimento (removido em exports do usuário) |
---

## Perfis de Exportação (Quine)

### Administrador
- Mantém Visual Builder, Admin Gate e Export Modal
- Permite re-exportar e reconfigurar tokens
- Markers preservados: `ADMIN_BUTTONS`, `ADMIN_EDIT`, `ADMIN_JS`, `EXPORT MODAL`

### User
- Interface limpa, sem opções de administração
- Markers stripped: todos os blocos `ADMIN_*` e `EXPORT MODAL` removidos
- Arquivo resultante é read-only (sem capacidade de re-exportar)

---

## IndexedDB Schema

| Store | Key | Indexes | Descrição |
|---|---|---|---|
| `sessions` | `id` | `createdAt` | Metadados da sessão |
| `images` | `id` | `sessionId`, `order` | Screenshots capturados (blob PNG/JPEG) |
| `documents` | `id` | `sessionId`, `order` | Documentos/logs (blob genérico) |
| `removed_images` | `id` | `sessionId` | Imagens movidas para removidos |
| `removed_documents` | `id` | `sessionId` | Documentos movidos para removidos |

---

## Funcionalidades

### Captura Inteligente & Sequencial (Prevenção de Colisões)
- **Ctrl+V** — Cola screenshots ou textos do clipboard.
- **Drag & Drop** — Arrasta documentos ou screenshots diretamente para as respectivas zonas.
- **File Picker** — Seleção de documentos ou screenshots locais.
- **Unicidade de Documentos:**
  - Textos colados são nomeados automaticamente como `texto-1.txt`, `texto-2.txt`, etc.
  - Screenshots colados/capturados são nomeados e etiquetados como `imagem-1`, `imagem-2`, etc.
  - O motor detecta e incrementa automaticamente os números finais (evitando padrões duplicados como `texto-1-1.txt` ou loops de substituição no ZIP).
  - Renomeações manuais redundantes são resolvidas de forma idêntica.
- **Mobile Paste FAB:** Botão flutuante exclusivo para dispositivos móveis (tom verde) que utiliza a `Clipboard API` nativa para colar textos ou imagens da área de transferência quando não há acesso a atalhos de teclado.
- **Leitura Blindada de Clipboard:** Conversão de segurança `Zero-Trust` (Array vs Iterable) em inputs de clipboard, garantindo colagem perfeita (`Ctrl+V`) mesmo em motores legacy que silenciam erros de leitura de `DataTransferItemList`.

### Motor de Navegação de Imagens (FAANG)
- **Zoom-to-Pointer com Roda do Rato:** O visualizador de imagens suporta ampliação fluida focada diretamente na coordenada do rato, desde 20% a 1000%, emulando perfeitamente mapas digitais. Ausência completa de delay e física sem inércia não intencional.
- **Glassmorphism UI:** Quando o zoom está ativo, uma barra translúcida elegante surge na zona inferior com controlos rápidos de escala, utilizando desfoque nativo do sistema e bordas premium.
- **Bloqueio de Fuga:** Ampliar uma imagem tranca temporariamente a saída via clique no cenário (`backdrop`), protegendo contra fechos não intencionais durante o arrastamento (*panning*).

### Organização & Visual Estético
- **Gold Standard Convergence:** Tipografia, ícones e componentes alinhados com o SDE V48 Gold Standard — botões `36px`, ícones `14-16px`, modais com título `16px` e close `32px` circular.
- **Design System Premium Borderless:** Painéis e cards de documentos utilizam margens transparentes livres de bordas rígidas, flutuando de forma orgânica no fundo.
- **Geometria Técnica de Imagens:** Bordas quadradas (`border-radius: 0`) e ausência de divisórias rígidas nas legendas, aplicadas exclusivamente aos cartões de imagens.
- **Drag-and-drop reorder** — Reordenação nativa e intuitiva de elementos.
- **Removidos (Trash Bar)** — Ícones SVG inline semânticos (16px). Itens excluídos são enviados para a barra inferior, permitindo restauro rápido ou eliminação definitiva.
- **Left Sidebar Scrollável** — Scroll invisível (`scrollbar-width: none`) sem compressão de conteúdo. Chips de layout ocupam sempre uma única linha.
- **Prevenção de FOUC (Anti-Flicker):** Carregamento síncrono do Dark Mode logo após a tag body, eliminando completamente a cintilação ou "flash branco" indesejado ao iniciar à noite.
- **Créditos Integrados (Gold Standard):** Rodapé de rodagem institucional (`© 2026 • CAPTURE ENGINE • DIOGOCARVALHOINFO.COM`) incorporado à base da interface a 50% de opacidade sem prejudicar a área útil.

### Visualizador de Texto Integrado
- **Modal View (`#text-modal-overlay`):** Ao clicar num card de texto (ativo ou removido), abre um visualizador com fonte monoespaçada (`Consolas`, `Monaco`).
- **Deteção de Binários:** Documentos não-textuais (PDF, DOCX, etc.) mostram ícone SVG com extensão e mensagem informativa centrada, em vez de conteúdo corrompido.
- **Ações Rápidas:**
  - **Copiar Texto:** Envia o conteúdo do texto para o clipboard com feedback de botão animado de sucesso.
  - **Download:** Disponível tanto para documentos ativos como removidos.
  - **Restaurar:** Botão disponível quando o texto está nos removidos, movendo-o imediatamente de volta para a lista principal.

### Anotação de Imagens
- **5 ferramentas**: Círculo, Retângulo, Seta, Desenho Livre e Texto.
- **Personalização:** Color picker e seletor de espessura de traço.
- **Confirmar:** Salva as anotações achatando-as diretamente sobre o screenshot original de forma vetorial em PNG lossless.
- **Download na Lixeira:** O botão Download está disponível tanto para imagens ativas como removidas.

### Exportação Otimizada
- **PDF** — Imagens compactadas em JPEG (qualidade configurável). Suporta formatos Auto (misto), A4 Vertical e A4 Horizontal.
- **ZIP** — Empacota screenshots e documentos brutos com extensões correctas por tipo MIME (PNG, JPG, WEBP, GIF, AVIF, BMP). Os screenshots usam os nomes das legendas limpos (ex: `imagem-1.png`, `imagem-2.webp`) sem prefixos numéricos `001-`, prevenindo erros de extração nos sistemas operacionais.

### Sessões
- **Auto-save** a cada 5 segundos no IndexedDB.
- **Restore automático** — Sessão anterior é recarregada automaticamente ao abrir, incluindo campos User e Equipamento.
- **Navegação SPA Persistente:** Ao trocar de sessão na barra lateral, o painel mantém-se estendido e exibe o estado ativo/selecionado no hover/click com cores de transição harmónicas (padrão V13).
- **Sessões Anteriores (Histórico):** Históricos sem título agora são nomeados cronologicamente com zeros à esquerda (`#0001`, `#0002`, etc.), garantindo uma identificação clara e neutra.
- **Segurança de Deleção:** Eliminar a sessão atualmente ativa aciona um recarregamento limpo automático da interface para manter o IndexedDB perfeitamente íntegro.
- **Purge automático** de sessões expiradas ao iniciar.

---

## Segurança

- **Zero-dependency** — Sem CDNs ou scripts externos, garantindo privacidade militar.
- **Air-gapped** — Opera 100% localmente e offline.
- **XSS Prevention** — Codificação estrita com `escapeHTML()` de todos os dados renderizados no DOM.
- **Quine sanitization** — `sanitizeForQuine()` evita a cannibalização de blocos de marcação durante a auto-mutação.
- **Admin Gate** — Painel oculto ativado por 6 cliques no logo da marca.

---

## Requisitos

- Navegador moderno (Chrome 90+, Edge 90+, Firefox 90+)
- Suporte a IndexedDB, Canvas API, Clipboard API
- Sem necessidade de servidor ou internet

---

## Estrutura de Arquivos

```
V13/
├── capture-engine.html   ← Motor principal (single-file)
├── readme.md             ← Este arquivo (Guia Geral)
├── changelog.md          ← Registro de atualizações e versões
├── agents.md             ← Regras operacionais para agentes IA
└── design-tokens.md      ← Especificação de Design Tokens e Estilos
```

---

*Capture Engine V13 · Design de Excelência FAANG · Air-gapped ready*
