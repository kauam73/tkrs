```
# Documentação - UIManager

Este documento descreve como utilizar a biblioteca UIManager para criar interfaces de usuário no Roblox. O foco é na importação e no uso prático dos componentes.

## 1. Carregando a Biblioteca

Primeiro, você precisa carregar o módulo da UIManager em seu script local.

```lua
-- Supondo que o módulo se chame "UIManager" e esteja em ReplicatedStorage
local UIManager = require(game.ReplicatedStorage.UIManager)
```

## 2. Criando a Janela Principal

Tudo começa com a criação da janela principal. Você pode definir um título e outras opções.

```lua
-- Cria uma nova janela com o título "Meu Painel"
local gui = UIManager.new({
    Name = "Meu Painel",
    FloatText = "Abrir Painel", -- Texto do botão quando a janela está minimizada
    startTab = "Principal" -- (Opcional) Nome da aba que deve abrir primeiro
})
```

## 3. Criando Abas (Tabs)

Os componentes são organizados dentro de abas. Crie uma ou mais abas para agrupar suas funcionalidades.

```lua
-- Cria uma aba chamada "Principal"
local tabPrincipal = gui:CreateTab({ Title = "Principal" })

-- Cria outra aba chamada "Configurações"
local tabConfig = gui:CreateTab({ Title = "Configurações" })
```

## 4. Adicionando Componentes

Todos os componentes são adicionados a uma aba específica.

### Botão (Button)

Cria um botão clicável que executa uma função (callback).

```lua
gui:CreateButton(tabPrincipal, {
    Text = "Clique em Mim",
    Callback = function()
        print("Botão foi clicado!")
    end
})
```

### Toggle (Interruptor)

Cria um interruptor (on/off) que retorna seu estado (true ou false) no callback.

```lua
gui:CreateToggle(tabPrincipal, {
    Text = "Ativar Funcionalidade",
    Callback = function(estado)
        if estado then
            print("Toggle ativado!")
        else
            print("Toggle desativado.")
        end
    end
})
```

### Dropdown (Menu de Seleção)

Cria um menu suspenso com uma lista de opções.

```lua
gui:CreateDropdown(tabPrincipal, {
    Title = "Selecione uma Opção",
    Values = { "Opção 1", "Opção 2", "Opção 3" },
    SelectedValue = "Opção 1", -- (Opcional) Valor que já vem selecionado
    Callback = function(valorSelecionado)
        print("Você selecionou: " .. valorSelecionado)
    end
})
```

### Label (Rótulo)

Exibe um texto informativo, com um título e uma descrição opcional.

```lua
gui:CreateLabel(tabConfig, {
    Title = "Informação Importante",
    Desc = "Este é um texto descritivo sobre a configuração."
})
```

### Tag (Etiqueta)

Cria uma pequena etiqueta colorida para exibir status ou categorias.

```lua
gui:CreateTag(tabConfig, {
    Text = "VERSÃO 1.0",
    Color = Color3.fromRGB(90, 140, 200) -- (Opcional) Cor de fundo
})
```

### Input (Campo de Texto)

Cria um campo para o usuário inserir texto ou números.

#### Para texto:

```lua
gui:CreateInput(tabConfig, {
    Text = "Nome do Jogador",
    Placeholder = "Digite seu nome aqui...",
    Callback = function(texto)
        print("O nome digitado foi: " .. texto)
    end
})
```

#### Para números:

```lua
gui:CreateInput(tabConfig, {
    Text = "Idade",
    Placeholder = "0",
    Type = "number", -- Define o tipo como número
    Callback = function(numero)
        if type(numero) == "number" then
            print("A idade digitada foi: " .. numero)
        end
    end
})
```

### HR (Linha Horizontal)

Cria uma linha divisória para separar visualmente os componentes. Pode conter um texto centralizado.

#### Linha simples:

```lua
gui:CreateHR(tabPrincipal, {})
```

#### Linha com texto:

```lua
gui:CreateHR(tabPrincipal, {
    Text = "Outra Seção"
})
```

## 5. Notificações

Exibe uma notificação no canto da tela. Elas podem ser temporárias ou persistentes.

```lua
gui:Notify({
    Title = "Sucesso!",
    Desc = "A operação foi concluída.",
    Duration = 5, -- (Opcional) Duração em segundos. Se omitido, a notificação é persistente.
    ButtonText = "OK", -- (Opcional) Adiciona um botão
    Callback = function()
        print("Notificação fechada!")
    end
})
```

## 6. Funções de Controle da Janela

Você pode controlar a janela programaticamente.

### Bloquear Interação (Block)

Bloqueia a interface e aplica um efeito de desfoque na tela. Útil para pop-ups ou eventos importantes.

```lua
-- Bloqueia a UI
gui:Block(true)

-- Desbloqueia a UI
gui:Block(false)
```

### Destruir a Janela (Destroy)

Remove completamente a interface da tela e desconecta todos os eventos.

```lua
gui:Destroy()
```
```