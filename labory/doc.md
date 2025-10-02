# Documentação - UIManager    
    
**Painel de Interface Simples para Exploiters**    
    
Este documento descreve como utilizar a biblioteca UIManager para criar interfaces de usuário no Roblox. **Este painel foi desenvolvido especificamente para uso de exploiters**, oferecendo uma interface simples e prática para criar painéis de controle para seus scripts e ferramentas de exploit.    
    
---    
    
## 🎯 Sobre Este Painel    
    
O UIManager é uma biblioteca projetada **exclusivamente para exploiters**, permitindo criar interfaces gráficas de forma rápida e eficiente. Com ela, você pode:    
    
- Criar painéis personalizados para seus scripts de exploit    
- Adicionar botões, toggles, dropdowns e outros componentes    
- Organizar suas ferramentas em abas separadas    
- Ter uma interface profissional sem precisar programar do zero    
    
**Público-alvo:** Exploiters que desejam uma interface simples e funcional para seus scripts    
    
---    
    
## 1. Carregando a Biblioteca    
    
Primeiro, você precisa carregar o módulo da UIManager em seu script de exploit local, ISSO É OBRIGATÓRIO FAZER PARA FUNCIONAR!.    
    
```lua    
-- Para carregar o script labory da interface no seu executor/exploit, coloquei no início do seu código >    
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/labory/data.lua "))()    
```    
    
---    
    
## 2. Criando a Janela Principal do Seu Painel    
    
Tudo começa com a criação da janela principal do seu painel de exploit. Você pode definir um título e outras opções.    
    
```lua    
-- Cria uma nova janela com o título "Meu Painel de Exploit"    
local gui = UIManager.new({    
    Name = "Meu Painel de Exploit",    
    FloatText = "Abrir Painel", -- Texto do botão quando a janela está minimizada    
    startTab = "Principal" -- (Opcional) Nome da aba que deve abrir primeiro    
})    
```    
    
---    
    
## 3. Criando Abas (Tabs)    
    
Os componentes do seu painel são organizados dentro de abas. Crie uma ou mais abas para agrupar suas funcionalidades de exploit.    
    
```lua    
-- Cria uma aba chamada "Principal" para suas funções principais    
local tabPrincipal = gui:CreateTab({ Title = "Principal" })    
    
-- Cria outra aba chamada "Configurações"    
local tabConfig = gui:CreateTab({ Title = "Configurações" })    
    
-- Cria aba para funcionalidades específicas    
local tabPlayer = gui:CreateTab({ Title = "Player" })    
```    
    
---    
    
## 4. Adicionando Componentes ao Seu Painel    
    
Todos os componentes são adicionados a uma aba específica do seu painel.    
    
### Botão (Button)    
    
Cria um botão clicável que executa uma função (callback). Ideal para ativar funcionalidades do exploit.    
    
```lua    
gui:CreateButton(tabPrincipal, {    
    Text = "ESP Players",    
    Callback = function()    
        print("ESP ativado!")    
        -- Seu código de ESP aqui    
    end    
})    
```    
    
### Toggle (Interruptor)    
    
Cria um interruptor (on/off) que retorna seu estado (true ou false) no callback. Perfeito para funcionalidades que você quer ligar/desligar.    
    
```lua    
gui:CreateToggle(tabPrincipal, {    
    Text = "Fly",    
    Callback = function(estado)    
        if estado then    
            print("Fly ativado!")    
            -- Código para ativar fly    
        else    
            print("Fly desativado.")    
            -- Código para desativar fly    
        end    
    end    
})    
```    
    
### Dropdown (Menu de Seleção)    
    
Cria um menu suspenso com uma lista de opções. Útil para selecionar entre diferentes modos ou configurações.    
    
```lua    
gui:CreateDropdown(tabPrincipal, {    
    Title = "Modo de Velocidade",    
    Values = { "Normal", "Rápido", "Super Rápido" },    
    SelectedValue = "Normal", -- (Opcional) Valor que já vem selecionado    
    Callback = function(valorSelecionado)    
        print("Velocidade: " .. valorSelecionado)    
        -- Seu código para aplicar velocidade    
    end    
})    
```    
    
### Label (Rótulo)    
    
Exibe um texto informativo no seu painel, com um título e uma descrição opcional.    
    
```lua    
gui:CreateLabel(tabConfig, {    
    Title = "Informação Importante",    
    Desc = "Este painel foi desenvolvido para exploiters usarem de forma simples e prática."    
})    
```    
    
### Tag (Etiqueta)    
    
Cria uma pequena etiqueta colorida para exibir status, versões ou categorias no seu painel.    
    
```lua    
gui:CreateTag(tabConfig, {    
    Text = "VERSÃO 1.0",    
    Color = Color3.fromRGB(90, 140, 200) -- (Opcional) Cor de fundo    
})    
```    
    
### Input (Campo de Texto)    
    
Cria um campo para o usuário inserir texto ou números no painel.    
    
#### Para texto:    
    
```lua    
gui:CreateInput(tabPlayer, {    
    Text = "Nome do Jogador",    
    Placeholder = "Digite o username...",    
    Callback = function(texto)    
        print("Teleportar para: " .. texto)    
        -- Código para teleportar    
    end    
})    
```    
    
#### Para números:    
    
```lua    
gui:CreateInput(tabPlayer, {    
    Text = "Walkspeed",    
    Placeholder = "16",    
    Type = "number", -- Define o tipo como número    
    Callback = function(numero)    
        if type(numero) == "number" then    
            print("Velocidade: " .. numero)    
            -- game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = numero    
        end    
    end    
})    
```    
    
### HR (Linha Horizontal)    
    
Cria uma linha divisória para separar visualmente os componentes no seu painel. Pode conter um texto centralizado.    
    
#### Linha simples:    
    
```lua    
gui:CreateHR(tabPrincipal, {})    
```    
    
#### Linha com texto:    
    
```lua    
gui:CreateHR(tabPrincipal, {    
    Text = "Funções de Combate"    
})    
```    
    
### Novos Componentes
    
#### Float Button
    
```lua
-- Criar o float button
local button = Tekscripts:CreateFloatingButton({
    Text = "Ativar Kill Aura",
    Title = "Ferramenta",
    BorderRadius = 12,
    Value = false,
    Visible = true,
    Drag = true,
    Block = false,
    Callback = function(state)
        if state then
            print("Kill Aura ativado!")
            -- Coloque aqui o código para ativar a Kill Aura
        else
            print("Kill Aura desativado!")
            -- Coloque aqui o código para desativar a Kill Aura
        end
    end
})

-- Você pode atualizar o botão depois
button.Update({
    Text = "Desativar Kill Aura",
    BorderRadius = 20
})

-- Checar o estado atual
print(button.State().Value) -- true ou false

-- Destruir o botão
-- button.Destroy()
```

#### Slider

```lua
-- Supondo que você já tenha um Tab criado no Tekscripts
local myTab = {
    Container = Instance.new("Frame"), -- apenas exemplo, seu container real
    Components = {}
}

-- Criar o slider
local slider = Tekscripts:CreateSlider(myTab, {
    Text = "Velocidade do Player",
    Min = 10,
    Max = 100,
    Step = 5,
    Value = 50,
    Callback = function(val)
        print("Velocidade atual:", val)
        -- Aqui você pode colocar o código para alterar a velocidade do player
        -- Ex: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
    end
})

-- Alterar valor programaticamente
slider.Set(75)

-- Pegar valor atual
print("Valor atual do slider:", slider.Get())

-- Atualizar opções do slider
slider.Update({
    Text = "Nova Velocidade",
    Min = 20,
    Max = 200,
    Step = 10
})

-- Destruir slider
-- slider.Destroy()
```
    
---    
    
## 5. Notificações    
    
Exibe uma notificação no canto da tela. Útil para informar o usuário do exploit sobre ações realizadas.    
    
```lua    
gui:Notify({    
    Title = "Sucesso!",    
    Desc = "ESP ativado com sucesso.",    
    Duration = 5, -- (Opcional) Duração em segundos. Se omitido, a notificação é persistente.    
    ButtonText = "OK", -- (Opcional) Adiciona um botão    
    Callback = function()    
        print("Notificação fechada!")    
    end    
})    
```    
    
---    
    
## 6. Funções de Controle da Janela    
    
Você pode controlar a janela do painel programaticamente.    
    
### Bloquear Interação (Block)    
    
Bloqueia a interface e aplica um efeito de desfoque na tela. Útil para pop-ups ou eventos importantes no seu exploit.    
    
```lua    
-- Bloqueia a UI do painel    
gui:Block(true)    
    
-- Desbloqueia a UI do painel    
gui:Block(false)    
```    
    
### Destruir a Janela (Destroy)    
    
Remove completamente a interface da tela e desconecta todos os eventos. Use quando quiser fechar o painel completamente.    
    
```lua    
gui:Destroy()    
```    
    
---    
    
## 📝 Exemplo Completo de Painel para Exploiter    
    
```lua    
-- Carregar a biblioteca    
local UIManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/labory/data.lua "))()    
    
-- Criar painel    
local gui = UIManager.new({    
    Name = "Meu Painel de Exploit",    
    FloatText = "Abrir",    
    startTab = "Principal"    
})    
    
-- Criar aba principal    
local tabMain = gui:CreateTab({ Title = "Principal" })    
    
-- Adicionar toggle de fly    
gui:CreateToggle(tabMain, {    
    Text = "Fly",    
    Callback = function(state)    
        if state then    
            print("Fly ON")    
        else    
            print("Fly OFF")    
        end    
    end    
})    
    
-- Adicionar botão de ESP    
gui:CreateButton(tabMain, {    
    Text = "Ativar ESP",    
    Callback = function()    
        gui:Notify({    
            Title = "ESP Ativado",    
            Desc = "Todos os players estão visíveis",    
            Duration = 3    
        })    
    end    
})    
    
-- Adicionar input de velocidade    
gui:CreateInput(tabMain, {    
    Text = "WalkSpeed",    
    Placeholder = "16",    
    Type = "number",    
    Callback = function(num)    
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = num    
    end    
})    
```    
    
---    
    
## ⚠️ Nota Final    
    
**Este painel UIManager é uma ferramenta projetada para exploiters criarem interfaces simples e funcionais para seus scripts.** Use de forma responsável e esteja ciente das políticas e termos de serviço da plataforma onde você está utilizando.