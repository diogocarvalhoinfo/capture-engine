# Capture Engine · V15

> Uma ferramenta para capturar, organizar e exportar screenshots e documentos — funciona 100% offline, sem instalar nada, sem internet, sem servidores. Abre no browser como qualquer página web.

---

## O que é o Capture Engine?

Imagine uma pasta inteligente que vive dentro de um único arquivo HTML. Você abre esse arquivo no browser, cola screenshots e documentos, organiza tudo, e exporta como PDF ou ZIP — sem nunca precisar de internet ou de instalar programas.

**Para que serve, na prática:**

| Situação | Como o CE ajuda |
|---|---|
| Suporte técnico / Service Desk | Junta screenshots de erros, logs e configurações num único PDF para o ticket |
| Área jurídica | Compila documentos e evidências antes de os enviar ao advogado |
| Uso pessoal | Agrupa prints para subir num portal, chamado ou formulário |
| Ambiente restrito (banco, governo) | Funciona sem internet, sem CDN, sem registo de dados externos |

---

## Como funciona em termos simples?

O Capture Engine é **um único arquivo HTML** que contém tudo dentro de si: o visual, a lógica, e a capacidade de se guardar e de se re-exportar. Não depende de nenhum servidor, nenhuma biblioteca externa, nenhuma ligação à internet.

Os seus dados ficam guardados localmente no browser (numa base de dados chamada IndexedDB — o mesmo lugar onde o browser guarda dados offline de sites). Nada sai do seu computador.

Quando exporta, o motor gera o PDF ou o ZIP diretamente no browser, em memória — sem enviar nenhum byte para qualquer servidor.

---

## Primeiros passos

1. **Abrir** — Faça duplo clique em `capture-engine.html` (ou use o `CaptureEngineApp.vbs` no Windows para uma experiência em janela isolada)
2. **Identificar a sessão** *(opcional)* — Escreva o nome do utilizador e do equipamento nos campos do lado esquerdo
3. **Capturar** — Cole screenshots com `Ctrl+V`, arraste arquivos para a zona de drop, ou clique em "Adicionar Imagem" / "Adicionar Documento"
4. **Organizar** — Arraste os itens para reordenar; clique num item para o ver ou anotar
5. **Exportar** — Clique em **PDF** (só imagens, numa página por imagem) ou **ZIP** (imagens + documentos juntos)

> **Dica:** Cada vez que abre o arquivo começa uma sessão nova em branco. As sessões anteriores ficam guardadas e acessíveis na barra lateral direita (ícone de relógio).

---

## Arquitetura — O que está dentro do arquivo

```
capture-engine.html  ← O arquivo único que é tudo
│
├── <style>          ← Visual: cores, tamanhos, dark mode, animações
│
├── <body>           ← Estrutura: barra de topo, painéis, sidebar, modais
│
└── <script>         ← Lógica (isolada, sem poluir o espaço global)
    │
    ├── SysLogger    ← Regista eventos na consola do browser (apenas em modo debug)
    ├── TOKENS       ← Configurações personalizáveis (cor, título, rodapé, etc.)
    ├── IndexedDB    ← Base de dados local do browser (5 tabelas)
    ├── Session Mgr  ← Cria, guarda e apaga sessões de trabalho
    ├── Capture      ← Recebe imagens e documentos (clipboard, drag-drop, picker)
    ├── Reorder      ← Drag-and-drop para reorganizar a ordem dos itens
    ├── Annotation   ← Desenha círculos, setas e texto diretamente nas imagens
    ├── Text Viewer  ← Abre e mostra documentos de texto dentro da app
    ├── PDF Engine   ← Gera PDFs sem bibliotecas externas, em puro JavaScript
    ├── ZIP Engine   ← Gera ZIPs sem bibliotecas externas, em puro JavaScript
    ├── Visual Builder ← Painel de configuração do administrador (oculto por defeito)
    ├── Quine Engine ← Permite ao arquivo re-exportar uma cópia de si próprio
    └── Admin Gate   ← Ativa o modo administrador (6 cliques no logo)
```

### O conceito de Quine — porque o arquivo se exporta a si próprio

Um **Quine** é um programa capaz de produzir uma cópia exata de si próprio como output. O Capture Engine usa este conceito para permitir que o administrador exporte versões personalizadas da ferramenta:

- **Export Admin** → Cópia idêntica com o Visual Builder incluído. O admin pode continuar a reconfigurar e re-exportar.
- **Export User** → Cópia limpa, sem painel de administração, sem opção de re-exportar. Ideal para distribuir a utilizadores finais.

O arquivo lê o seu próprio código-fonte via `fetch(location.href)`, substitui os tokens de configuração com os valores atuais, e faz o download do resultado — tudo sem servidor.

---

## Tokens de Configuração

Os **tokens** são as variáveis de personalização da ferramenta. O administrador pode alterá-los pelo Visual Builder (6 cliques no logo → ⚙️). As alterações só ficam permanentes quando se faz um **Export Admin/User**.

| Token | Valor por defeito | O que controla |
|---|---|---|
| `TOKEN_TITLE_START` | `Capture` | Primeira parte do nome no topo |
| `TOKEN_TITLE_ACCENT` | `Engine` | Segunda parte (em destaque colorido) |
| `TOKEN_SUBTITLE` | *(vazio)* | Subtítulo abaixo do nome |
| `TOKEN_MAIN_COLOR` | `#0ea5e9` | Cor principal de destaque |
| `TOKEN_ACCENT_FG_OVERRIDE` | *(vazio)* | Cor do texto sobre o destaque (auto se vazio) |
| `TOKEN_FOOTER_TEXT` | `© {YEAR} • CAPTURE ENGINE` | Rodapé institucional (`{YEAR}` é substituído pelo ano atual) |
| `TOKEN_SHOW_SESSION_USER` | `true` | Mostra/oculta o campo "User" na sessão |
| `TOKEN_SHOW_SESSION_PC` | `true` | Mostra/oculta o campo "Equipamento" na sessão |
| `TOKEN_USER_LABEL` | *(vazio → "User")* | Rótulo personalizado do campo User |
| `TOKEN_EQUIP_LABEL` | *(vazio → "Equipamento")* | Rótulo personalizado do campo Equipamento |
| `TOKEN_JPEG_QUALITY` | `0.92` | Qualidade das imagens no export PDF (0.70 a 0.95) |
| `TOKEN_MAX_IMG_DIMENSION` | `0` | Redimensiona imagens antes do export (0 = sem limite) |
| `TOKEN_AUTO_PURGE_HOURS` | `48` | Horas até uma sessão inativa ser apagada automaticamente |
| `TOKEN_DEBUG_MODE` | `true` | Liga logs detalhados na consola (desativado em exports de User) |

---

## Perfis de Export

### Export Admin
Mantém todos os controles de administração. O arquivo resultante pode ser reconfigurado e re-exportado novamente. Use para distribuir a outros admins ou para fazer backup da configuração atual.

### Export User
Remove o painel de administração, o Visual Builder e a capacidade de re-exportar. O utilizador final recebe uma ferramenta limpa, focada apenas em capturar e exportar evidências. Não tem como alterar configurações ou saber que existe um modo admin.

---

## Base de Dados Local (IndexedDB)

O browser guarda tudo automaticamente em 5 tabelas separadas:

| Tabela | O que guarda |
|---|---|
| `sessions` | Metadados de cada sessão (nome, user, equipamento, datas) |
| `images` | Screenshots capturados (arquivos PNG/JPEG/WEBP em binário) |
| `documents` | Documentos e textos capturados |
| `removed_images` | Imagens movidas para a lixeira (antes de apagar definitivamente) |
| `removed_documents` | Documentos movidos para a lixeira |

**Auto-save:** A app grava automaticamente a cada 5 segundos se houver alterações. Qualquer digitação nos campos User ou Equipamento grava imediatamente (sem esperar os 5 segundos).

**Purge automático:** Ao abrir a aplicação, sessões com mais de 48 horas sem atividade são apagadas automaticamente (configurável via `TOKEN_AUTO_PURGE_HOURS`).

---

## Funcionalidades em Detalhe

### Captura Inteligente

A app aceita conteúdo de três formas:
- **Ctrl+V** — Cola o que estiver no clipboard (imagem ou texto)
- **Drag & Drop** — Arrasta qualquer arquivo para a zona de drop correspondente
- **Picker** — Botões "Adicionar Imagem" / "Adicionar Documento" abrem o seletor de arquivos

**Nomeação automática sem colisões:** Ao colar a segunda imagem, a app não sobrescreve a primeira — atribui automaticamente `imagem-2`, `imagem-3`, etc. O mesmo para documentos de texto: `texto-1.txt`, `texto-2.txt`. Renomeações manuais seguem a mesma lógica — nunca geram nomes duplicados nem padrões esquisitos como `imagem-1-1`.

### Visualizador de Imagens (Zoom & Pan)

Ao clicar numa imagem, abre um visualizador com:
- **Zoom com roda do rato** centrado na posição do cursor (20% a 1000%), sem delay
- **Pan** (arrastar) quando a imagem está ampliada
- **Barra de controlo flutuante** que aparece apenas quando o zoom está ativo, com botões +/−/Reset

### Anotação de Imagens

O botão de anotação abre um canvas transparente sobre a imagem. Ferramentas disponíveis:
- Círculo, Retângulo, Seta, Desenho Livre, Texto
- Color picker e seletor de espessura de traço
- **Confirmar** achata as anotações diretamente na imagem original (PNG sem perdas)

### Lixeira (Trash Bar)

Itens removidos não são apagados imediatamente — vão para a lixeira na barra inferior. Pode restaurá-los ou apagá-los definitivamente. Útil para recuperar screenshots removidos por engano.

### Export PDF

Comprime todas as imagens da sessão em JPEG (qualidade configurável) e gera um PDF com uma imagem por página. Três modos de página:
- **Auto** — Detecta orientação de cada imagem (retrato ou paisagem) individualmente
- **A4 Vertical** — Força todas as páginas em retrato
- **A4 Horizontal** — Força todas as páginas em paisagem

> O botão PDF fica desativado automaticamente quando há documentos na sessão — o motor PDF processa apenas imagens. Para sessões mistas (imagens + documentos), use o ZIP.

### Export ZIP

Empacota tudo — imagens e documentos — num único arquivo ZIP. Os arquivos ficam com os nomes das legendas limpas (ex: `imagem-1.png`, `relatorio.pdf`), sem prefixos numéricos que causem problemas em sistemas operativos.

### Sessões e Histórico

Cada abertura do arquivo cria uma sessão nova em branco. O histórico de sessões anteriores fica acessível na barra lateral (ícone de relógio). Sessões sem nome são identificadas cronologicamente como `#0001`, `#0002`, etc.

Ao apagar a sessão ativa, a app navega automaticamente para a sessão adjacente. Se não houver mais sessões, o interface regressa ao estado limpo inicial.

---

## Segurança e Privacidade

| Característica | Detalhe |
|---|---|
| **Zero-dependency** | Sem CDNs, sem bibliotecas externas — nada a carregar da internet |
| **Air-gapped** | Funciona 100% offline; nenhum dado sai do seu computador |
| **XSS Protection** | Todo o texto inserido pelo utilizador é sanitizado antes de aparecer no tela |
| **Admin Gate oculto** | O painel de admin ativa-se apenas com 6 cliques no logo — invisível para utilizadores comuns |

---

## Requisitos

- Browser moderno: Chrome 90+, Edge 90+, Firefox 90+
- Sem internet, sem servidor, sem instalação

---

## Estrutura de Arquivos

```
V15/
├── capture-engine.html      ← A aplicação completa (abrir este)
├── CaptureEngineApp.vbs     ← Launcher Windows (abre em janela isolada)
├── CaptureEngineApp.vbs.md  ← Documentação técnica do launcher
├── readme.md                ← Este guia geral
├── changelog.md             ← Registo de todas as versões e alterações
├── agents.md                ← Regras operacionais para agentes IA que editam o código
└── design-tokens.md         ← Especificação completa do design system
```

---

*Capture Engine V15 · Design de Excelência FAANG · Air-gapped ready*
