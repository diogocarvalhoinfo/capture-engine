# CaptureEngineApp · Launcher Windows

> Script VBScript que abre o `capture-engine.html` como se fosse uma aplicação nativa — sem barra de endereço, sem abas, sem distrações do browser.

---

## Em linguagem simples — o que isto faz?

Quando abre um arquivo `.html` com duplo clique, o Windows abre-o como uma página web normal: com a barra de endereço, os botões de voltar/avançar, as abas, e possivelmente um tela de boas-vindas do Edge.

O launcher elimina tudo isso. Ao fazer duplo clique em `CaptureEngineApp.vbs`, o Capture Engine abre em modo de aplicação — uma janela limpa, maximizada, sem interface de browser visível. Parece uma aplicação instalada, não uma página web.

**Para quem é:** Utilizadores que querem uma experiência de aplicação profissional, especialmente em ambientes corporativos onde a janela limpa é importante.

**Para quem não é necessário:** Quem prefere abrir o arquivo `.html` diretamente no browser — isso funciona perfeitamente bem também.

---

## Informação Técnica

| Propriedade | Valor |
|---|---|
| Versão | `1.1.0` |
| Compatibilidade | Microsoft Edge (Chromium 109+) |
| Requisitos | Windows, Edge instalado no caminho padrão |
| Permissões necessárias | Nenhuma — corre como utilizador normal, sem admin |

---

## O que o script faz, passo a passo

### 1. Valida os arquivos necessários

Antes de fazer qualquer coisa, o script verifica:
- O Edge está instalado no caminho padrão? (`C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe`)
- O `capture-engine.html` está na mesma pasta que o script?

Se qualquer um falhar, aparece uma mensagem de erro clara (em vez de falhar silenciosamente).

### 2. Converte o caminho em URI válida

O Windows usa caminhos com barras invertidas (`C:\Pasta\arquivo.html`). O browser precisa de URIs com barras normais e encoding de caracteres especiais (`file:///C:/Pasta/arquivo.html`).

O script converte o caminho automaticamente. **A partir de V15**, esta conversão suporta corretamente pastas com nomes acentuados em português (`Área de Trabalho`, `Documentação`, etc.) — caracteres como `ã`, `ç`, `é` são codificados em `%HH` para que o Edge os interprete corretamente.

### 3. Cria uma pasta de perfil isolada

O script cria uma pasta de sessão em `%TEMP%\CE`. Isto serve para:
- **Isolar completamente** os dados do Capture Engine dos dados pessoais do browser do utilizador (histórico, passwords, cookies)
- **Evitar telas de boas-vindas** do Edge que aparecem em perfis novos (o script injeta um arquivo de Preferências que simula um perfil já configurado)
- **Limpar o cache** automaticamente a cada abertura, evitando que a pasta cresça indefinidamente

Nada disto afeta o perfil normal do Edge — são pastas completamente separadas.

### 4. Gera (ou reutiliza) um atalho na Área de Trabalho

O script cria um atalho `.lnk` na Área de Trabalho com o ícone correto do sistema (`shell32.dll`). Se o atalho já existir, não o sobrescreve — respeita a organização do utilizador.

**Porquê um atalho e não apenas o script?** O atalho tem o ícone correto e pode ser arrastado para a barra de tarefas (ver instruções abaixo).

### 5. Lança o Edge em modo App

```
msedge.exe --app=file:///...  --user-data-dir=%TEMP%\CE
           --app-id=CaptureEngineCustom
           --start-maximized
           --disable-first-run-ui
           --no-default-browser-check
           --disable-translate
```

| Flag | O que faz |
|---|---|
| `--app=file:///...` | Abre em modo App — sem barra de endereço, sem abas |
| `--user-data-dir` | Usa a pasta de perfil isolada em `%TEMP%\CE` |
| `--app-id` | Agrupa a janela como app separada na barra de tarefas |
| `--start-maximized` | Abre maximizado (best-effort — pode ser ignorado por GPO em ambientes restritos) |
| `--disable-first-run-ui` | Suprime telas de boas-vindas |
| `--no-default-browser-check` | Suprime o diálogo "Queres que o Edge seja o browser padrão?" |
| `--disable-translate` | Suprime a barra de tradução automática |

---

## Instruções para o Utilizador Final

### Primeira abertura
1. Certifique-se de que `CaptureEngineApp.vbs` e `capture-engine.html` estão **na mesma pasta**
2. Faça duplo clique em `CaptureEngineApp.vbs`
3. Um atalho é criado automaticamente na Área de Trabalho

### Colocar na Barra de Tarefas (opcional)

> ⚠️ **Método correto:** Arraste o atalho da Área de Trabalho diretamente para a Barra de Tarefas.

> ❌ **Método errado:** Clicar com o botão direito na aplicação aberta e escolher "Fixar na barra de tarefas" — isto pode desassociar os argumentos de isolamento e a aplicação abrirá em modo browser normal na próxima vez.

### Depois de fixar na barra de tarefas
Pode usar o atalho na barra de tarefas diretamente — não precisa de correr o `.vbs` de novo.

---

## Resolução de Problemas

### "Arquivos não encontrados" ao abrir
O `capture-engine.html` foi movido ou renomeado. O script e o HTML têm de estar na mesma pasta. Mova-os para a mesma pasta e execute o `.vbs` de novo.

### Ícone genérico (folha em branco) na barra de tarefas
1. Clique com o botão direito no ícone e escolha "Desafixar da barra de tarefas"
2. Apague o atalho da Área de Trabalho
3. Execute o `CaptureEngineApp.vbs` de novo
4. Arraste o novo atalho da Área de Trabalho para a barra de tarefas

### A janela não abre maximizada
Em alguns ambientes corporativos com políticas de GPO que controlam o estado de janelas, a flag `--start-maximized` pode ser ignorada. A aplicação abre na mesma — apenas em tamanho de janela normal em vez de maximizada. Maximize manualmente se necessário.

### Pasta com acentos no caminho (ex: "Área de Trabalho")
Resolvido na versão 1.1.0 — o launcher codifica corretamente caracteres como `ã`, `ç`, `é` no caminho da URI.

---

## Para Equipas de TI e Auditoria

### O que o script NÃO faz
- ❌ Não modifica o registo do Windows (`HKLM` ou `HKCU`)
- ❌ Não instala nenhum software
- ❌ Não requer privilégios de administrador
- ❌ Não acede a dados de navegação do perfil principal do Edge
- ❌ Não faz ligações à internet

### O que o script FAZ (inventário completo)
- ✅ Lê o caminho do próprio arquivo via `WScript.ScriptFullName`
- ✅ Verifica existência de arquivos via `FileSystemObject.FileExists`
- ✅ Cria pasta em `%TEMP%\CE` e limpa `%TEMP%\CE\Default\Cache\`
- ✅ Escreve um arquivo JSON em `%TEMP%\CE\Default\Preferences` (preferências de perfil Edge)
- ✅ Cria/verifica atalho em `%USERPROFILE%\Desktop\` via `WScript.CreateObject("WScript.Shell")`
- ✅ Lança `msedge.exe` com os argumentos documentados acima, modo assíncrono (`WshShell.Run ... 0, False`)

### Nota sobre `--disable-features=RendererCodeIntegrity`
Esta flag foi **removida** na versão 1.1.0. Foi descontinuada pelo Chromium e a sua presença em versões modernas do Edge pode gerar alertas em sistemas EDR (Endpoint Detection and Response) modernos. A remoção foi proativa para evitar falsos positivos em auditorias de segurança.

---

*CaptureEngineApp Launcher · v1.1.0 · Windows / Edge Chromium 109+*
