# Capture Engine · Criar Atalho no Windows

> Guia passo a passo para abrir o Capture Engine como uma aplicação nativa — sem barra de endereço, sem abas, sem interface de browser.

---

## O que este guia faz

Por padrão, abrir um arquivo `.html` com duplo clique abre o browser normal — com barra de endereço, abas e botões de navegação. Seguindo este guia, vais criar um **atalho** que abre o Capture Engine como uma aplicação isolada, igual a um programa instalado.

---

## Requisitos

- Windows 10 ou superior
- Microsoft Edge instalado (versão Chromium — padrão em qualquer Windows moderno)

---

## Passo a passo

### Passo 1 — Localiza o arquivo

Confirma onde está o arquivo `capture-engine.html` no teu computador.

Exemplo: `C:\Ferramentas\CaptureEngine\capture-engine.html`

> **Dica:** Clica com o botão direito no arquivo → **Propriedades** → o caminho completo aparece no campo **Local**.

---

### Passo 2 — Cria um atalho na Área de Trabalho

1. Clica com o botão direito num espaço vazio da **Área de Trabalho**
2. Seleciona **Novo** → **Atalho**
3. Na janela que abre, cola o seguinte comando no campo de destino:

```
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --app="CAMINHO_DO_ARQUIVO" --user-data-dir="%TEMP%\CE" --no-first-run --start-maximized
```

4. **Substitui `CAMINHO_DO_ARQUIVO`** pelo caminho completo do teu arquivo. Exemplo:

```
"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --app="C:\Ferramentas\CaptureEngine\capture-engine.html" --user-data-dir="%TEMP%\CE" --no-first-run --start-maximized
```

> ⚠️ **Atenção às aspas:** O caminho do arquivo deve estar entre aspas (`"..."`), especialmente se tiver espaços no nome da pasta.

5. Clica em **Avançar**
6. Dá um nome ao atalho — por exemplo: `Capture Engine`
7. Clica em **Concluir**

---

### Passo 3 — Testa o atalho

Faz duplo clique no atalho que acabas de criar. O Capture Engine abre numa janela limpa, sem barra de endereço, maximizado.

---

### Passo 4 — Personaliza o ícone (opcional)

Para dar ao atalho um ícone mais adequado:

1. Clica com o botão direito no atalho → **Propriedades**
2. Clica em **Alterar ícone...**
3. Cola este caminho no campo de pesquisa:

```
%SystemRoot%\System32\shell32.dll
```

4. Escolhe um ícone à tua preferência (o ícone de câmera ou pasta são boas opções)
5. Clica em **OK** → **Aplicar**

---

## O que cada parâmetro faz

| Parâmetro | Função |
|---|---|
| `--app="..."` | Abre o arquivo em modo de aplicação — sem barra de endereço, sem abas |
| `--user-data-dir="%TEMP%\CE"` | Usa um perfil de browser isolado para evitar conflitos com o Edge principal e suprimir ecrãs de boas-vindas |
| `--no-first-run` | Ignora o assistente de configuração inicial do Edge |
| `--start-maximized` | Abre a janela maximizada |

---

## Resolução de problemas

**O Edge não está no caminho indicado**

Em alguns sistemas, o Edge está instalado em:
```
C:\Program Files\Microsoft\Edge\Application\msedge.exe
```
(sem o `(x86)`). Se o atalho não funcionar, tenta este caminho alternativo.

Para confirmar o caminho correto:
1. Abre o **Menu Iniciar**
2. Procura por `Microsoft Edge`
3. Clica com o botão direito → **Abrir localização do arquivo**
4. Clica com o botão direito no atalho do Edge → **Propriedades** → o campo **Destino** mostra o caminho completo do `msedge.exe`

**A janela abre mas não está maximizada**

Em ambientes corporativos com políticas de grupo (GPO), o parâmetro `--start-maximized` pode ser ignorado. Maximiza a janela manualmente com a tecla `⊞ Win + ↑` ou arrastar para o topo do ecrã.

**O arquivo mudou de pasta**

Se moveres o `capture-engine.html` para outra pasta, o atalho fica inválido. Repete o Passo 2 com o novo caminho, ou edita o atalho existente: botão direito → **Propriedades** → atualiza o campo **Destino**.

---

## Distribuição em ambiente corporativo

Se precisas de distribuir o atalho a vários computadores, podes criar o atalho uma vez e copiar o arquivo `.lnk` resultante para a Área de Trabalho de outros utilizadores, desde que:

- O caminho para o `capture-engine.html` seja o mesmo em todos os computadores (ex: pasta de rede partilhada `\\servidor\ferramentas\capture-engine.html`)
- O Microsoft Edge esteja instalado no mesmo caminho em todos os computadores

---

*Capture Engine V18 · Guia de Atalho Windows · Air-gapped Ready*
