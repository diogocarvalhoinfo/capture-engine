# Documentação Técnica: Capture Engine Launcher

## 1. Visão Geral
O **Capture Engine Launcher** é um script VBScript (.vbs) desenvolvido para inicializar aplicações web em modo "App" isolado através do Microsoft Edge. Esta ferramenta foi desenhada especificamente para ambientes corporativos restritos (bancários/BigTech), onde a segurança, a conformidade e a estabilidade de execução são prioridades fundamentais.

* **Versão Atual:** 1.1.0 (Auditada)
* **Compatibilidade:** Microsoft Edge (Versões baseadas em Chromium 109 ou superior)

## 2. Propósito
O script contorna comportamentos padrão do Microsoft Edge (como a exibição de assistentes de primeira execução ou a criação automática de atalhos indesejados) para oferecer uma experiência de execução limpa e focada na aplicação. Ele opera inteiramente no espaço do utilizador, eliminando a necessidade de privilégios administrativos ou modificações persistentes no sistema operacional.

## 3. Especificações Técnicas e Segurança
Para total conformidade com auditorias de TI e segurança da informação, o launcher foi estruturado sob os seguintes pilares:

* **Não-Administrativo:** Executa estritamente com as permissões do utilizador logado em modo User-Mode.
* **Integridade do Sistema:** Nenhuma chave de registo do Windows (`HKLM` ou `HKCU`) é alterada ou consultada.
* **Sandbox Local e Isolamento:** Toda a configuração de sessão, cookies e perfil é isolada na pasta `%TEMP%\\CE`. Isto garante que a aplicação não aceda nem interfira com os dados de navegação do browser principal do utilizador.
* **Gestão Inteligente de Armazenamento:** A cada nova execução, o script realiza uma purga higiénica da pasta `Cache\\`, prevenindo o acúmulo indefinido de arquivos temporários e otimizando o espaço em disco do terminal.
* **ID de Aplicação Único (`--app-id`):** Utiliza um identificador customizado (`CaptureEngineCustom`) para forçar o Windows a agrupar a instância como uma aplicação dedicada na barra de tarefas.

## 4. Estrutura Lógica do Script
O ciclo de vida do inicializador executa os seguintes blocks sequenciais:

1. **Validação com Feedback Ativo:** Verifica a existência do executável do Edge no caminho padrão e do arquivo de interface local (`capture-engine.html`). Caso falhe, exibe um alerta visual claro (`MsgBox`) antes de encerrar, substituindo falhas silenciosas.
2. **Sanitização de Input (RFC Compliance):** Converte o caminho local do arquivo em uma URI válida (`file:///`), tratando caracteres especiais para mitigar falhas de parser no Chromium.
3. **Isolamento e Purga:** Cria a estrutura de diretórios em `%TEMP%` e limpa seletivamente os resíduos de cache da sessão anterior.
4. **Injeção de Estado (First-Run Bypass):** Injeta preventivamente um arquivo JSON estruturado em `Default\\Preferences`. Isto simula uma sessão do Edge já configurada, bloqueando ecrãs de boas-vindas intrusivos.
5. **Composição de Parâmetros (Launch Args):** Monta as flags do Chromium otimizadas para o ecossistema corporativo.
6. **Gestão Inteligente do Atalho:** Resolve explicitamente as variáveis de ambiente (como `%SystemRoot%`) para assegurar a renderização correta do ícone do sistema. O atalho só é recriado na Área de Trabalho se tiver sido removido, respeitando as preferências de organização do utilizador.
7. **Execução Isolada:** Dispara o processo do navegador de forma assíncrona e desconectada do interpretador do script.

## 5. Instruções de Implementação e Uso

### Para o Utilizador Final
1. O script inicial gerará um ícone na **Área de Trabalho**.
2. **Fixação na Barra de Tarefas:**
   * **Incorreto:** Clicar com o botão direito no ícone da barra de tarefas com a aplicação aberta e selecionar "Fixar". Isso pode desassociar os argumentos de isolamento.
   * **Correto:** Arraste o atalho criado na Área de Trabalho diretamente para a Barra de Tarefas. Isto garante a persistência correta do ícone e das propriedades de segurança da instância.

### Para a Equipa de Auditoria / Administradores de TI
* **Dependências:** O script assume o ciclo de vida padrão do Edge instalado em `C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe`.
* **Remoção de Parâmetros Obsoletos:** A flag `--disable-features=RendererCodeIntegrity` foi **removida** a partir da versão 1.1.0. Por ter sido descontinuada pela engenharia do Chromium, sua manutenção gerava riscos de falsos positivos ou alertas de anomalia comportamental em sistemas modernos de EDR (Endpoint Detection and Response).
* **Prevenção de Ruído de UI:** Foi adicionada a flag `--disable-translate`. Esta flag impede que o Edge ofereça barras de tradução automáticas para o utilizador ao renderizar componentes ou strings locais.

## 6. Resolução de Problemas

* **Ícone Genérico na Barra de Tarefas:** Se a aplicação perder a identidade visual (exibir o ícone padrão do Edge ou uma folha em branco), remova o atalho fixado na barra de tarefas, apague o atalho da Área de Trabalho e execute o script novamente para refazer o processo de *drag-and-drop*.
* **Mensagem de Erro na Inicialização:** Se uma janela crítica surgir informando que arquivos não foram encontrados, certifique-se de que o arquivo `capture-engine.html` não foi movido ou renomeado, e que ele reside exatamente no mesmo diretório em que o script `.vbs` está sendo executado.

---
*Documentação técnica atualizada em conformidade com as diretrizes de segurança corporativa vigentes.*