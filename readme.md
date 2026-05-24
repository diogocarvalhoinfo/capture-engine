# Capture Engine · V16

> Uma ferramenta para capturar, organizar e exportar screenshots e documentos — funciona 100% offline, sem instalar nada, sem internet, sem servidores. Abre no browser como qualquer página web.

---

## Índice

1. [O que é o Capture Engine](#1-o-que-é-o-capture-engine)
2. [Para quem é](#2-para-quem-é)
3. [Conceitos fundamentais](#3-conceitos-fundamentais)
4. [Início rápido](#4-início-rápido)
5. [Funcionalidades em detalhe](#5-funcionalidades-em-detalhe)
6. [Modo Administrador](#6-modo-administrador)
7. [Segurança e privacidade](#7-segurança-e-privacidade)
8. [Limitações conhecidas](#8-limitações-conhecidas)
9. [Resolução de problemas](#9-resolução-de-problemas)
10. [Perguntas frequentes](#10-perguntas-frequentes)
11. [Requisitos](#11-requisitos)
12. [Estrutura de arquivos](#12-estrutura-de-arquivos)
13. [Arquitetura interna](#13-arquitetura-interna)

---

## 1. O que é o Capture Engine

O Capture Engine é **um único arquivo HTML** que funciona como uma aplicação completa de captura e exportação de evidências digitais. Não precisa de instalação, não requer internet, e não envia nenhum dado para servidores externos.

Tudo o que você captura (screenshots, documentos, textos) fica guardado localmente no browser do seu computador. Quando exporta, o PDF ou ZIP é gerado diretamente no browser, em memória, sem sair do seu dispositivo.

**Em termos simples:** é uma pasta inteligente que vive num único arquivo. Você abre, cola ou arrasta arquivos, organiza, anota, e exporta — tudo sem internet.

### Casos de uso

| Situação | Como o Capture Engine ajuda |
|---|---|
| Suporte técnico / Service Desk | Junta screenshots de erros, logs e configurações num único PDF para o ticket |
| Área jurídica | Compila documentos e evidências antes de os enviar ao advogado |
| Uso pessoal | Agrupa prints para submeter num portal, chamado ou formulário |
| Ambientes restritos (banco, governo, saúde) | Funciona sem internet, sem CDN, sem registo de dados externos |
| Auditoria e conformidade | Evidências documentadas e exportadas sem sair do dispositivo |

---

## 2. Para quem é

O Capture Engine tem **três tipos de utilizadores** com responsabilidades diferentes:

### Utilizador Final
Usa a ferramenta para capturar, organizar e exportar. Não precisa de saber que existe um modo administrador. Recebe o arquivo `capture-engine.html` já configurado e pronto a usar.

**O que consegue fazer:** capturar imagens e documentos, anotar imagens, reordenar, exportar PDF ou ZIP.

**O que não consegue fazer:** alterar cores, títulos, ou configurações da ferramenta.

### Administrador
Configura a ferramenta para a sua organização — personaliza o nome, cores, campos e rodapé — e depois distribui a versão configurada aos utilizadores finais.

**O que consegue fazer:** tudo o que o utilizador final consegue, mais acesso ao painel Visual Builder (via 6 cliques no logo).

**O que não consegue fazer:** alterar o código-fonte diretamente.

### Desenvolvedor / Agente IA
Edita o código-fonte do `capture-engine.html` para adicionar funcionalidades, corrigir bugs ou adaptar o motor a novos requisitos. Leia o documento `agents.md` antes de qualquer modificação.

---

## 3. Conceitos fundamentais

Esta secção explica os termos técnicos usados em toda a documentação. Se encontrar um termo desconhecido, procure aqui primeiro.

### Quine
Um **Quine** é um programa capaz de produzir uma cópia exata de si próprio como output. O Capture Engine usa este conceito: ao fazer Export, o arquivo lê o seu próprio código-fonte, aplica as configurações atuais, e gera um novo arquivo HTML idêntico — mas com os tokens personalizados. Isto permite ao administrador distribuir versões configuradas sem precisar de servidores ou ferramentas externas.

### IndexedDB
**IndexedDB** é uma base de dados embutida no browser, semelhante a um disco local dentro do browser. O Capture Engine usa-a para guardar sessões, imagens e documentos automaticamente — sem servidor, sem ficheiros externos. Os dados persistem enquanto o utilizador não limpar os dados do browser.

**Importante:** Os dados do Capture Engine estão ligados ao browser e ao computador onde foram criados. Se limpar o histórico/cache do browser, os dados são apagados.

### Sessão
Uma **sessão** é um conjunto de trabalho — como um projeto ou pasta. Cada vez que abre o Capture Engine, começa uma sessão nova. Sessões anteriores ficam guardadas no histórico (ícone de relógio, lado direito).

### Token
Um **token** é uma variável de configuração do sistema. Por exemplo, `TOKEN_MAIN_COLOR` define a cor principal da interface. Os tokens são alterados pelo administrador no Visual Builder e ficam incorporados no arquivo HTML exportado.

### Visual Builder (VB)
O **Visual Builder** é o painel de configuração do administrador. É ativado com 6 cliques no logo no canto superior esquerdo. Permite alterar nome, cores, campos e rodapé da ferramenta sem editar código.

### Export Admin / Export User
Dois perfis de exportação do Quine Engine:
- **Export Admin** — gera uma cópia com todas as capacidades de administração. Outros admins podem reconfigurar e re-exportar.
- **Export User** — gera uma cópia limpa, sem painel de administração. Utilizadores finais recebem uma ferramenta focada apenas em capturar e exportar.

### Air-gapped
Um ambiente **air-gapped** (literalmente "com separação de ar") é um sistema sem acesso à internet — comum em bancos, hospitais e organismos governamentais. O Capture Engine foi desenhado especificamente para funcionar nestes ambientes: zero dependências externas.

### XSS (Cross-Site Scripting)
**XSS** é um tipo de ataque onde código malicioso é injetado numa página web. O Capture Engine sanitiza (limpa) todos os dados inseridos pelo utilizador antes de os apresentar, impedindo este tipo de ataque.

### IIFE (Immediately Invoked Function Expression)
Uma **IIFE** é um padrão JavaScript onde todo o código está encapsulado numa função que corre imediatamente. No Capture Engine, toda a lógica está dentro de uma IIFE — isto impede conflitos com outras variáveis ou scripts.

### FOUC (Flash of Unstyled Content)
**FOUC** é o flash momentâneo de conteúdo sem estilo que aparece antes de o JavaScript carregar (ex: fundo branco num utilizador de dark mode). O Capture Engine tem proteção anti-FOUC: aplica o tema antes de qualquer pintura do ecrã.

---

## 4. Início rápido

### Abrir a aplicação

**Método simples (qualquer sistema operativo):**
1. Faça duplo clique em `capture-engine.html`
2. O arquivo abre no browser padrão

**Método Windows com janela isolada:**
1. Faça duplo clique em `CaptureEngineApp.vbs`
2. O Capture Engine abre em modo de aplicação (sem barra de endereço, sem abas)
3. Um atalho é criado automaticamente na Área de Trabalho

### Fluxo básico de trabalho

```
1. Abrir → Interface limpa, sem dados (estado inicial)
           ↓
2. Identificar (opcional) → Escrever nome do utilizador e equipamento
           ↓
3. Capturar → Ctrl+V, arrastar arquivos, ou clicar "Adicionar Imagem"/"Adicionar Documento"
           ↓
4. Organizar → Arrastar itens para reordenar, clicar para ver ou anotar
           ↓
5. Exportar → PDF (imagens) ou ZIP (imagens + documentos)
```

### Dicas essenciais

- **Ctrl+V** cola qualquer coisa do clipboard: imagem, arquivo ou texto
- **Drag & Drop** funciona: arraste diretamente da Área de Trabalho ou do explorador de arquivos
- O histórico de sessões anteriores está no ícone de relógio (barra lateral direita)
- Itens removidos vão para a lixeira (barra inferior) — podem ser restaurados
- A aplicação guarda automaticamente a cada 5 segundos

---

## 5. Funcionalidades em detalhe

### 5.1 Captura de conteúdo

O Capture Engine aceita conteúdo de três formas:

| Método | Como usar | O que captura |
|---|---|---|
| **Ctrl+V** | Pressione Ctrl+V com a app em foco | Imagem do clipboard, arquivo copiado, ou texto |
| **Drag & Drop** | Arraste o arquivo para a área de destino | Qualquer arquivo |
| **Picker** | Clique em "Adicionar Imagem" ou "Adicionar Documento" | Qualquer arquivo pelo seletor do sistema |

**Tipos de arquivo aceites:**

| Categoria | Formatos |
|---|---|
| Imagens | PNG, JPEG, WEBP, GIF (capturadas como imagens) |
| Documentos de texto | TXT, CSV, XML, JSON, HTML, e outros formatos de texto simples (visualizáveis diretamente na app) |
| Documentos binários | PDF, DOCX, XLSX, e qualquer outro formato (guardados mas não visualizáveis inline — disponíveis para download) |

**Nomeação automática sem colisões:**
Ao colar a segunda imagem, a app não sobrescreve a primeira — atribui automaticamente `imagem-2`, `imagem-3`, etc. Renomeações manuais seguem a mesma lógica — nunca geram nomes duplicados.

**Comportamento do Ctrl+V por tipo de conteúdo:**
1. Se o clipboard contiver uma **imagem** → captura como imagem
2. Se o clipboard contiver um **arquivo não-imagem** → captura como documento
3. Se o clipboard contiver **texto** → captura como arquivo `.txt`

---

### 5.2 Visualizador de imagens (Zoom & Pan)

Ao clicar numa imagem, abre um modal com visualizador completo.

| Ação | Como fazer |
|---|---|
| **Abrir** | Clicar no thumbnail da imagem |
| **Zoom in/out** | Roda do rato (scroll), centrado na posição do cursor |
| **Pan (mover)** | Clicar e arrastar quando a imagem está ampliada |
| **Zoom com botões** | Botões +/−/Reset na barra flutuante (aparece quando zoom > 100%) |
| **Fechar** | Botão × ou clicar fora da imagem (apenas quando zoom = 100%) |

**Limites de zoom:** 20% (mínimo) a 1000% (máximo).

**Nota:** Quando a imagem está ampliada (zoom > 100%), clicar fora do modal não fecha a janela — isto evita fechos acidentais durante o panning.

---

### 5.3 Anotação de imagens

O botão de anotação (ícone de caneta, dentro do modal de imagem) abre um canvas transparente sobre a imagem.

**Ferramentas disponíveis:**
- **Círculo** — desenha um círculo no local do clique
- **Retângulo** — desenha um retângulo por arrasto
- **Seta** — desenha uma seta direcional
- **Desenho Livre** — traço livre com o rato
- **Texto** — abre um mini-campo de texto; confirmar com Enter, cancelar com Escape

**Controlos:**
- Color picker — escolhe a cor do traço
- Seletor de espessura — choose a espessura do traço

**Confirmar anotação:** O botão "Confirmar" achata as anotações diretamente na imagem original em PNG, sem perda de qualidade. Esta ação é permanente — as anotações ficam parte da imagem.

**Cancelar anotação:** Descarta todos os traços não confirmados e volta ao visualizador normal.

---

### 5.4 Reordenação

Todos os itens (imagens e documentos) podem ser reordenados por **drag & drop**:
- Em imagens: arraste o thumbnail para a posição desejada na grelha
- Em documentos: arraste o card para cima ou para baixo na lista

A nova ordem é guardada automaticamente.

---

### 5.5 Lixeira

Itens removidos não são apagados imediatamente — vão para a **Trash Bar** (barra inferior).

| Ação | Como fazer |
|---|---|
| **Ver itens removidos** | Clicar na barra "Removidos" na parte inferior |
| **Restaurar item** | Abrir o item na lixeira → botão "Restaurar" |
| **Apagar definitivamente** | Dentro do modal do item → botão de apagar permanente |

A lixeira persiste entre sessões — os itens removidos ficam até serem apagados definitivamente ou até a sessão expirar.

---

### 5.6 Export PDF

Gera um PDF com uma imagem por página.

**Modos de página disponíveis:**

| Modo | Comportamento |
|---|---|
| **Auto** | Detecta orientação de cada imagem individualmente (retrato ou paisagem) |
| **A4 Vertical** | Força todas as páginas em formato retrato |
| **A4 Horizontal** | Força todas as páginas em formato paisagem |

**Processo de geração:**
1. As imagens PNG originais são convertidas para JPEG em memória (qualidade configurável, padrão 92%)
2. O PDF é construído com uma imagem por página, maximizando a área útil
3. O arquivo é descarregado automaticamente

**Quando o botão PDF fica desativado:** Quando há documentos (não-imagens) na sessão. O motor PDF processa apenas imagens. Para sessões mistas, use o ZIP.

**Os arquivos originais não são alterados.** A conversão JPEG acontece apenas na memória, durante a geração do PDF. Os originais permanecem em PNG na sessão.

---

### 5.7 Export ZIP

Empacota todos os itens da sessão (imagens e documentos) num único arquivo ZIP.

**O que é incluído:**
- Imagens em PNG (no formato original, sem recompressão)
- Documentos em todos os formatos
- Nomes de arquivo limpos baseados nas legendas/nomes definidos (ex: `imagem-1.png`, `relatorio.pdf`)

**Opções de ZIP (quando há imagens na sessão):**
- **Imagens em PDF** — inclui as imagens como PDF + documentos separados
- **Imagens Separadas** — inclui tudo como arquivos individuais

---

### 5.8 Sessões e histórico

**Comportamento ao abrir:**
Cada abertura do Capture Engine começa com uma sessão nova em branco. A interface abre limpa — sem dados de sessões anteriores. Sessões anteriores ficam guardadas no histórico.

**Quando a sessão aparece no histórico:**
A sessão nova só aparece no histórico após a primeira interação real (colar uma imagem, escrever o nome do utilizador, arrastar um documento). Sessões sem interação não são guardadas.

**Identificação de sessão:**
- **Nome da sessão** — campo de texto livre no topo da sidebar esquerda
- **Campo User** — nome do utilizador que está a trabalhar (configurável)
- **Campo Equipamento** — nome do computador ou equipamento (configurável)
- Se não for preenchido nenhum nome, a sessão recebe um identificador automático (`#0001`, `#0002`, etc.)

**Purge automático:**
Sessões sem atividade há mais de 48 horas (configurável) são apagadas automaticamente ao abrir a aplicação. O critério é a data de **última atividade**, não a data de criação.

**Navegar entre sessões:**
1. Clicar no ícone de relógio (barra lateral direita)
2. Selecionar a sessão desejada na lista
3. A sessão atual é guardada antes de navegar

---

## 6. Modo Administrador

### 6.1 Ativar o modo administrador

O painel de administração não é visível por defeito. Para o ativar:

1. **Clicar 6 vezes seguidas no logo** (canto superior esquerdo)
2. Dois botões aparecem na barra de topo: ⚙️ (Visual Builder) e 💾 (Export)

O modo administrador não persiste entre aberturas — tem de ser ativado de novo cada vez que abre a aplicação.

### 6.2 O Visual Builder

O Visual Builder é o painel de configuração. Está dividido em três abas:

**Aba Interface:**
- Nome da ferramenta (texto inicial + texto em destaque)
- Cor principal (color picker)
- Cor do texto sobre a cor principal (auto-deteção se vazio)
- Texto do rodapé (`{YEAR}` é substituído pelo ano atual)

**Aba Histórico (Campos de Sessão):**
- Ativar/desativar Campo 1 (por defeito: "User")
- Ativar/desativar Campo 2 (por defeito: "Equipamento")
- Rótulo personalizado do Campo 1
- Rótulo personalizado do Campo 2

**Aba Captura:**
- Qualidade do PDF (0.70 a 0.95 — afeta apenas a geração de PDF, não os originais)
- Dimensão máxima de redimensionamento de imagens (0 = sem limite)
- Horas até purge automático de sessões

**Nota importante:** As alterações feitas no Visual Builder são **temporárias** até ser feito um Export. Ao fechar e reabrir o arquivo, as configurações voltam ao padrão guardado no arquivo.

### 6.3 Guardar configurações (Export)

O botão 💾 abre o painel de Export com duas opções:

**Export Admin:**
- Gera uma cópia do arquivo com as configurações atuais
- Mantém o painel de administração e a capacidade de re-exportar
- Use para distribuir a outros administradores ou como backup da configuração

**Export User:**
- Gera uma cópia limpa do arquivo com as configurações atuais
- Remove o painel de administração, o Visual Builder e a capacidade de re-exportar
- Ativa automaticamente o modo de produção (logs desativados)
- Use para distribuir aos utilizadores finais

**Fluxo de distribuição típico:**
```
Admin configura → Export Admin (backup) → Export User → distribui aos utilizadores
```

### 6.4 Tokens de configuração

Os tokens são as variáveis internas que controlam o comportamento da ferramenta. O Visual Builder edita estes tokens graficamente.

| Token | Valor padrão | O que controla |
|---|---|---|
| `TOKEN_TITLE_START` | `'Capture'` | Primeira parte do nome no topo |
| `TOKEN_TITLE_ACCENT` | `'Engine'` | Segunda parte (em cor de destaque) |
| `TOKEN_MAIN_COLOR` | `'#0ea5e9'` | Cor principal da interface |
| `TOKEN_ACCENT_FG_OVERRIDE` | `''` | Cor do texto sobre a cor principal (vazio = automático) |
| `TOKEN_FOOTER_TEXT` | `'© {YEAR} • CAPTURE ENGINE'` | Texto do rodapé |
| `TOKEN_SHOW_SESSION_USER` | `true` | Mostra/oculta o Campo 1 (User) |
| `TOKEN_SHOW_SESSION_PC` | `true` | Mostra/oculta o Campo 2 (Equipamento) |
| `TOKEN_USER_LABEL` | `''` | Rótulo do Campo 1 (vazio = usa "User") |
| `TOKEN_EQUIP_LABEL` | `''` | Rótulo do Campo 2 (vazio = usa "Equipamento") |
| `TOKEN_JPEG_QUALITY` | `0.92` | Qualidade de compressão JPEG no export PDF |
| `TOKEN_MAX_IMG_DIMENSION` | `0` | Dimensão máxima de imagens (0 = sem limite) |
| `TOKEN_AUTO_PURGE_HOURS` | `48` | Horas de inatividade até purge automático |
| `TOKEN_DEBUG_MODE` | `true` | Logs na consola do browser (desativado em Export User) |

---

## 7. Segurança e privacidade

| Característica | Detalhe |
|---|---|
| **Zero dependências externas** | Sem CDNs, sem bibliotecas remotas, sem Google Fonts — nada carregado da internet |
| **Air-gapped** | Funciona 100% offline; nenhum dado sai do dispositivo |
| **Sanitização de inputs** | Todo o texto inserido pelo utilizador é sanitizado antes de ser apresentado (proteção XSS) |
| **Content Security Policy** | Metatag CSP no cabeçalho HTML restringe scripts e recursos que podem ser carregados |
| **Admin Gate oculto** | O painel de admin requer 6 cliques no logo — invisível e inatingível acidentalmente |
| **Sem registo** | Nenhum dado de utilização, telemetria ou analytics |
| **Sem cookies** | Usa IndexedDB e localStorage do browser (sem cookies de sessão) |

### Aviso sobre limpeza do browser

Os dados do Capture Engine estão guardados no IndexedDB do browser. **Se limpar os dados de navegação, cache, ou histórico do browser, os dados do Capture Engine são apagados permanentemente.** Exporte sempre os dados importantes antes de limpar o browser.

### Comportamento com múltiplas abas

O Capture Engine não suporta estar aberto em múltiplas abas do mesmo browser ao mesmo tempo. Se tentar abrir o arquivo em duas abas, a segunda aba mostra um aviso de erro e não carrega. Feche a primeira aba antes de abrir noutra.

---

## 8. Limitações conhecidas

| Limitação | Detalhe |
|---|---|
| **Sem sincronização** | Os dados só existem no browser do computador onde foram criados. Não há sincronização entre dispositivos. |
| **Dependente do browser** | Limpar dados do browser apaga todos os dados. |
| **Uma aba de cada vez** | Não suporta uso simultâneo em múltiplas abas do mesmo browser. |
| **PDF sem documentos** | O export PDF processa apenas imagens. Documentos (PDF, DOCX, etc.) requerem export ZIP. |
| **Sem preview de binários** | Documentos binários (PDF, DOCX, XLSX) não têm pré-visualização inline — apenas download. |
| **Windows VBS apenas** | O launcher `CaptureEngineApp.vbs` funciona apenas em Windows com Edge. macOS e Linux usam o HTML diretamente. |
| **Quota do browser** | O IndexedDB tem limites de armazenamento impostos pelo browser (tipicamente 50-80% do disco disponível). Sessões com muitas imagens de alta resolução podem atingir estes limites. |
| **GIF animados** | GIFs animados são capturados mas não animados — são tratados como imagem estática. |

---

## 9. Resolução de problemas

### A aplicação não abre ou mostra página em branco
- Verifique se está a usar Chrome 90+, Edge 90+, ou Firefox 90+
- Experimente abrir diretamente com duplo clique no `capture-engine.html`
- Em alguns sistemas, arquivos HTML locais precisam de permissão — verifique as configurações de segurança do browser

### Os dados desapareceram
- Os dados do Capture Engine ficam no IndexedDB do browser. Se limpou os dados do browser (histórico, cache, dados de sites), os dados foram apagados.
- Os dados só existem no computador e browser onde foram criados.
- Certifique-se de exportar os dados importantes antes de limpar o browser.

### O Ctrl+V não cola nada
- Clique primeiro dentro da área da aplicação (fora de qualquer campo de texto) para garantir que a app tem foco
- Em mobile, use o botão flutuante de colar (FAB) no canto inferior direito
- Verifique se o browser tem permissão para aceder ao clipboard (aparece uma notificação)

### O botão PDF está desativado
- O export PDF só funciona com imagens. Se há documentos (PDF, DOCX, etc.) na sessão, o botão desativa automaticamente.
- Use o export ZIP para sessões com imagens e documentos juntos.

### A janela não abre maximizada (launcher VBS)
- Em ambientes corporativos com políticas de GPO, a flag `--start-maximized` pode ser ignorada. Maximize a janela manualmente.

### Pasta com acentos no caminho (launcher VBS)
- Resolvido na versão 1.1.0 do launcher. Se estiver a usar uma versão mais antiga, mova o arquivo para uma pasta sem caracteres acentuados.

### O modal de anotação não fecha com Escape
- Se uma ferramenta de anotação estiver ativa, Escape cancela a ferramenta — não fecha o modal. Prima Escape novamente para fechar.

### Sessões com mais de 48 horas desapareceram
- O purge automático apaga sessões sem atividade há mais de 48 horas (configurável). Este comportamento é intencional e pode ser ajustado pelo administrador via `TOKEN_AUTO_PURGE_HOURS`.

---

## 10. Perguntas frequentes

**O meu arquivo HTML tem 140KB. É normal?**
Sim. O Capture Engine é uma aplicação completa encapsulada num único arquivo — inclui todo o CSS, toda a lógica JavaScript, e todos os ícones SVG inline. 140KB é um tamanho esperado para uma aplicação desta complexidade.

**Os meus dados ficam guardados para sempre?**
Não. Sessões inativas há mais de 48 horas (por defeito) são apagadas automaticamente. Além disso, limpar os dados do browser apaga tudo. Exporte os dados importantes.

**Posso usar o Capture Engine em Mac ou Linux?**
Sim — abra diretamente o `capture-engine.html` no browser. O launcher `.vbs` é exclusivo do Windows.

**Posso usar em Firefox?**
Sim, Firefox 90+ é suportado. A experiência é idêntica ao Chrome/Edge.

**Posso ter múltiplas versões do Capture Engine abertas ao mesmo tempo?**
Não no mesmo browser — só suporta uma aba. Mas pode ter versões diferentes abertas em browsers diferentes (ex: um no Edge e outro no Firefox).

**O que acontece se colocar o token `EXPORT MODAL` no rodapé?**
Nada — a versão V15+ protege automaticamente os marcadores internos com um caractere invisível (zero-width space), impedindo que valores de tokens interfiram com o Quine Engine.

**Posso usar o Capture Engine como aplicação web (num servidor)?**
É tecnicamente possível, mas não é o caso de uso pretendido. A ferramenta foi desenhada para uso local (protocolo `file://`). Em servidores, podem surgir restrições de CORS no Quine Engine (fetch do próprio arquivo).

**Posso personalizar a ferramenta sem saber programar?**
Sim — o Visual Builder (6 cliques no logo) permite personalizar cores, nome, campos e rodapé sem tocar no código.

---

## 11. Requisitos

### Requisitos mínimos
- Browser moderno: Chrome 90+, Edge 90+ ou Firefox 90+
- Sem internet, sem servidor, sem instalação
- Qualquer sistema operativo com browser moderno

### Requisitos do launcher Windows (opcional)
- Sistema operativo: Windows 10 ou superior
- Microsoft Edge (Chromium 109+) instalado no caminho padrão
- Sem privilégios de administrador necessários

---

## 12. Estrutura de arquivos

```
V16/
├── capture-engine.html      ← A aplicação completa — este é o arquivo que distribui
├── CaptureEngineApp.vbs     ← Launcher opcional para Windows (experiência de app nativa)
├── CaptureEngineApp.vbs.md  ← Documentação técnica do launcher
├── readme.md                ← Este guia (início aqui)
├── changelog.md             ← Histórico completo de versões e alterações
├── agents.md                ← Guia operacional para desenvolvedores e agentes IA
└── design-tokens.md         ← Especificação completa do design system
```

**Qual arquivo distribuir aos utilizadores?**
- Para uso básico: apenas `capture-engine.html`
- Para uso em Windows com experiência de app: `capture-engine.html` + `CaptureEngineApp.vbs`
- Os outros arquivos (`.md`) são documentação interna — não precisam de ser distribuídos

---

## 13. Arquitetura interna

Esta secção é para quem precisa de entender como o sistema funciona internamente. Utilizadores finais podem ignorar.

### O arquivo único

```
capture-engine.html
│
├── <head>
│   ├── Content Security Policy (metatag)
│   └── Script anti-FOUC (aplica dark mode antes de pintar)
│
├── <style>
│   ├── Design tokens (variáveis CSS)
│   ├── Light mode (:root)
│   ├── Dark mode (body.dark)
│   ├── Layout principal
│   ├── Componentes (botões, modais, sidebar, cards)
│   ├── Responsividade (900px, 480px)
│   └── Animações
│
├── <body>
│   ├── Barra de topo (logo, nome, botões de ação)
│   ├── Layout principal
│   │   ├── Sidebar esquerda (campos de sessão, controlos de export)
│   │   ├── Painel de imagens (zona de drop + grelha de thumbnails)
│   │   └── Painel de documentos (zona de drop + lista)
│   ├── Sidebar direita (histórico de sessões)
│   ├── Trash Bar (lixeira)
│   ├── Rodapé
│   └── Modais (imagem, documento, anotação, Visual Builder, export)
│
└── <script> — IIFE com 'use strict'
    │
    ├── SysLogger         → Logs na consola (respeitam TOKEN_DEBUG_MODE)
    ├── TOKENS            → Variáveis de configuração (TOKEN_*)
    ├── escapeHTML()      → Sanitização XSS de todos os inputs
    ├── IndexedDB         → Funções de acesso à base de dados local (idbGet, idbPut, idbDel, idbAll, idbIdx)
    ├── Session Manager   → Criar, carregar, apagar e navegar entre sessões
    ├── Capture Engine    → Receber imagens e documentos (clipboard, drag-drop, picker)
    ├── Reorder           → Drag-and-drop para reordenar itens
    ├── Annotation        → Canvas transparente para anotação sobre imagens
    ├── Text Viewer       → Visualizador de documentos de texto inline
    ├── PDF Engine        → Geração de PDFs em JavaScript puro (sem bibliotecas)
    ├── ZIP Engine        → Geração de ZIPs em JavaScript puro (sem bibliotecas)
    ├── Visual Builder    → Painel de configuração do administrador
    ├── Quine Engine      → Auto-exportação do arquivo com configurações
    ├── Admin Gate        → Ativa o modo admin (6 cliques no logo)
    └── boot()            → Função de inicialização: configura tudo e chama init()
```

### Como os componentes se ligam

```
boot()
  ├── openDB()           → Abre/cria a base de dados IndexedDB
  ├── purgeExpired()     → Apaga sessões antigas
  ├── init()             → Cria sessão nova em branco
  ├── initClipboard()    → Activa listener de Ctrl+V e FAB mobile
  ├── initDragDrop()     → Activa drag-and-drop nas zonas de captura
  ├── initReorder()      → Activa drag-and-drop de reordenação
  ├── initPickers()      → Activa botões "Adicionar Imagem/Documento"
  ├── initTheme()        → Aplica tema (dark/light) guardado
  ├── initSidebar()      → Configura sidebar de histórico
  └── setInterval(5s)    → Auto-save quando isDirty === true
```

### Base de dados local (IndexedDB)

**Nome da base de dados:** `CaptureEngineDB` (versão 2)

| Tabela | Chave primária | Campos principais | Índices |
|---|---|---|---|
| `sessions` | `id` | `name`, `user`, `pc`, `createdAt`, `updatedAt`, `exported` | `createdAt` |
| `images` | `id` | `sessionId`, `blob`, `label`, `order`, `addedAt` | `sessionId`, `order` |
| `documents` | `id` | `sessionId`, `blob`, `name`, `type`, `size`, `order`, `addedAt` | `sessionId`, `order` |
| `removed_images` | `id` | `sessionId`, `blob`, `label`, `removedAt` | `sessionId` |
| `removed_documents` | `id` | `sessionId`, `blob`, `name`, `type`, `size`, `removedAt` | `sessionId` |

**Auto-save:** A cada 5 segundos, se `isDirty === true`. Digitação nos campos User/Equipamento/Nome guarda imediatamente.

---

*Capture Engine V16 · Design de Excelência FAANG · Air-gapped Ready*
