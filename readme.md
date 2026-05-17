# Capture Engine · v1.0

> Motor de captura e exportação de evidências — zero-dependency, air-gapped, single-file HTML Quine.

---

## Visão Geral

O **Capture Engine (CE)** é uma aplicação irmã do *Service Desk Engine*, desenhada para capturar, organizar e exportar screenshots e documentos como **PDF** ou **ZIP** — sem dependências externas, sem CDN, sem backend.

Casos de uso:
- **Service Desk** — Recolha de evidências para tickets (prints de ecrã, logs, configurações)
- **Jurídico** — Compilação de documentos antes de envio
- **Uso doméstico** — Juntar imagens/documentos para upload em portais governamentais

---

## Arquitectura

```
capture-engine.html    ← Ficheiro único (Quine Engine)
├── <style>            ← CSS Design System (variáveis, dark mode, componentes)
├── <body>             ← HTML Skeleton (top bar, painéis, sidebar, modais)
└── <script>           ← JavaScript Engine (IIFE isolado)
    ├── SysLogger      ← Logging estruturado para consola
    ├── TOKENS         ← Configuração injectável via Quine
    ├── IndexedDB      ← 5 object stores (sessions, images, documents, removed_*)
    ├── Session Mgr    ← CRUD de sessões com auto-save a cada 5s
    ├── Capture        ← Ctrl+V, drag-drop, file picker
    ├── Reorder        ← Drag-and-drop nativo para reordenação
    ├── Annotation     ← Canvas overlay (círculo, rectângulo, seta, freehand, texto)
    ├── PDF Engine     ← Gerador PDF raw (JPEG via Canvas, formato exacto/A4)
    ├── ZIP Engine     ← Gerador ZIP raw (CRC32, store method)
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
| `TOKEN_SHOW_SESSION_USER` | bool | `true` | Mostrar campo utilizador |
| `TOKEN_SHOW_SESSION_PC` | bool | `true` | Mostrar campo computador |
| `TOKEN_JPEG_QUALITY` | float | `0.92` | Qualidade JPEG no export PDF (0.70–0.95) |
| `TOKEN_MAX_IMG_DIMENSION` | int | `0` | Dimensão máxima de redimensionamento (0=original) |
| `TOKEN_AUTO_PURGE_HOURS` | int | `48` | Horas para purge automático de sessões |

---

## Perfis de Exportação (Quine)

### Administrador
- Mantém Visual Builder, Admin Gate e Export Modal
- Permite re-exportar e reconfigurar tokens
- Markers preservados: `ADMIN_BUTTONS`, `ADMIN_EDIT`, `ADMIN_JS`, `EXPORT MODAL`

### Utilizador
- Interface limpa, sem controlos de administração
- Markers stripped: todos os blocos `ADMIN_*` e `EXPORT MODAL` removidos
- Ficheiro resultante é read-only (sem capacidade de re-exportar)

---

## IndexedDB Schema

| Store | Key | Indexes | Descrição |
|---|---|---|---|
| `sessions` | `id` | `createdAt` | Metadados da sessão |
| `images` | `id` | `sessionId`, `order` | Imagens capturadas (blob PNG) |
| `documents` | `id` | `sessionId`, `order` | Documentos/logs (blob genérico) |
| `removed_images` | `id` | `sessionId` | Imagens movidas para lixo |
| `removed_documents` | `id` | `sessionId` | Documentos movidos para lixo |

---

## Funcionalidades

### Captura
- **Ctrl+V** — Cola screenshot do clipboard
- **Drag & Drop** — Arrasta ficheiros para a zona correspondente
- **File Picker** — Selecção manual via botão "escolher"
- Texto colado sem imagem é guardado como `texto-colado.txt`

### Organização
- **Drag-and-drop reorder** — Reordena thumbnails e documentos
- **Renomear** — Clique no label da thumbnail para editar
- **Lixo** — Itens removidos ficam na trash bar (restauráveis)

### Anotação
- **5 ferramentas**: Círculo, Rectângulo, Seta, Freehand, Texto
- **Color picker** + **slider de espessura**
- **Undo** — Desfaz última anotação
- **Guardar** — Achata canvas sobre a imagem original (PNG lossless)

### Exportação
- **PDF** — Imagens convertidas para JPEG no export (qualidade configurável). 3 formatos: Exacto, A4 Vertical, A4 Horizontal
- **ZIP** — Imagens em formato original + documentos. CRC32 nativo

### Sessões
- **Auto-save** a cada 5 segundos via IndexedDB
- **Restore banner** ao abrir — oferece retomar sessão anterior
- **Sidebar** — Lista sessões anteriores, permite abrir em nova aba ou excluir
- **Purge automático** — Remove sessões expiradas ao iniciar

---

## Segurança

- **Zero-dependency** — Nenhum CDN, nenhuma biblioteca externa
- **Air-gapped** — Funciona 100% offline
- **XSS Prevention** — `escapeHTML()` aplicado a todos os inputs do utilizador
- **Quine sanitization** — `sanitizeForQuine()` previne injecção de markers
- **Admin Gate** — Botões admin ocultos, activados por 6 cliques no logo (3 rápidos para desactivar)
- **IIFE Isolation** — Todo o JS envolto em Immediately Invoked Function Expression

---

## Requisitos

- Navegador moderno (Chrome 90+, Edge 90+, Firefox 90+)
- Suporte a IndexedDB, Canvas API, Clipboard API
- Sem necessidade de servidor, internet ou instalação

---

## Estrutura de Ficheiros

```
EV/V3/
├── capture-engine.html   ← Motor principal (single-file)
├── readme.md             ← Este ficheiro
├── agents.md             ← Regras operacionais para agentes IA
└── design-tokens.md      ← Especificação do design system
```

---

*Capture Engine v1.0 · Built with zero dependencies · Air-gapped ready*
