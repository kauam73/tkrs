

# Documentação - UIManager

Este documento descreve como utilizar a biblioteca UIManager para criar interfaces de usuário no Roblox. O foco é na importação e no uso prático dos componentes.

## 1. Carregando a Biblioteca

Primeiro, você precisa carregar o módulo da UIManager em seu script local.

```lua
-- para carregar o script labory da interface no seu client
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/labory/data.lua"))()
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

### para Ia

```-- BLACK BOX UIManager (v1.0) - Labory pronta para IAs
-- Descrição: Biblioteca de UI para Roblox com metadados para compreensão rápida por IAs
-- Autor: Kauam Henrique
-- GitHub: https://github.com/kauam73/tkrs

local UIManager = {}
-- para carregar o script labory da interface no seu client
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/labory/data.lua"))()


--[[
METADATA (para IA):
{
    "name": "UIManager",
    "version": "1.0",
    "author": "Kauam Henrique",
    "description": "Biblioteca para criar interfaces de usuário no Roblox",
    "components": ["Button", "Toggle", "Dropdown", "Label", "Tag", "Input", "HR", "Notify"],
    "usage_example": "local gui = UIManager.new({ Name='Meu Painel' })",
    "functions": {
        "new": "Cria janela principal",
        "CreateTab": "Cria aba na janela",
        "CreateButton": "Adiciona botão",
        "CreateToggle": "Adiciona toggle",
        "CreateDropdown": "Adiciona dropdown",
        "CreateLabel": "Adiciona label",
        "CreateTag": "Adiciona tag",
        "CreateInput": "Adiciona campo de texto ou número",
        "CreateHR": "Cria linha horizontal",
        "Notify": "Exibe notificação",
        "Block": "Bloqueia/desbloqueia UI",
        "Destroy": "Remove interface e eventos"
    }
}
]]

-- Função principal: cria janela
function UIManager.new(opts)
    local self = setmetatable({}, UIManager)
    self.Name = opts.Name or "UI"
    self.FloatText = opts.FloatText or "Abrir"
    self.startTab = opts.startTab or nil
    self.Tabs = {}
    return self
end

-- Cria aba
function UIManager:CreateTab(opts)
    local tab = { Title = opts.Title or "Aba", Components = {} }
    table.insert(self.Tabs, tab)
    return tab
end

-- Adiciona botão
function UIManager:CreateButton(tab, opts)
    table.insert(tab.Components, { Type="Button", Text=opts.Text, Callback=opts.Callback })
end

-- Adiciona toggle
function UIManager:CreateToggle(tab, opts)
    table.insert(tab.Components, { Type="Toggle", Text=opts.Text, Callback=opts.Callback })
end

-- Adiciona dropdown
function UIManager:CreateDropdown(tab, opts)
    table.insert(tab.Components, { Type="Dropdown", Title=opts.Title, Values=opts.Values, SelectedValue=opts.SelectedValue, Callback=opts.Callback })
end

-- Adiciona label
function UIManager:CreateLabel(tab, opts)
    table.insert(tab.Components, { Type="Label", Title=opts.Title, Desc=opts.Desc })
end

-- Adiciona tag
function UIManager:CreateTag(tab, opts)
    table.insert(tab.Components, { Type="Tag", Text=opts.Text, Color=opts.Color })
end

-- Adiciona input
function UIManager:CreateInput(tab, opts)
    table.insert(tab.Components, { Type="Input", Text=opts.Text, Placeholder=opts.Placeholder, InputType=opts.Type, Callback=opts.Callback })
end

-- Adiciona linha horizontal
function UIManager:CreateHR(tab, opts)
    table.insert(tab.Components, { Type="HR", Text=opts.Text })
end

-- Notificação
function UIManager:Notify(opts)
    local notif = { Title=opts.Title, Desc=opts.Desc, Duration=opts.Duration, ButtonText=opts.ButtonText, Callback=opts.Callback }
    print("Notificação disparada: ", notif.Title)
end

-- Bloquear/Desbloquear UI
function UIManager:Block(state)
    print("UI bloqueada:", state)
end

-- Destruir janela
function UIManager:Destroy()
    self.Tabs = {}
    print("UI destruída")
end

return UIManager```