--[[
    TekScripts - Universal Edition
    Feito por Kauam
    Super fácil de editar - só adicione módulos e eles funcionam sozinhos!

    COMO ADICIONAR UM MÓDULO:
    1. Copie o exemplo no final (MÓDULO EXEMPLO)
    2. Cole na seção "MÓDULOS DO SCRIPT"
    3. Adicione à tabela Modules com table.insert(Modules, SeuModulo)
    4. Pronto! Ele já aparece no painel automaticamente
]]

-- ==================== CONFIGURAÇÃO PRINCIPAL ====================
local CONFIG = {
    UI = {
        Name = "TekScripts - Universal",
        LoadingTitle = "TekScripts",
        LoadingSubtitle = "Feito por Kauam",
    }
}

-- ==================== SERVIÇOS GLOBAIS ====================
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
}

local Cache = {
    localPlayer = Services.Players.LocalPlayer,
    camera = workspace.CurrentCamera,
    Dependencies = {}, 
    isHandlingDowned = false
}

-- ==================== BIBLIOTECA RAYFIELD ====================
local Rayfield
local success, errorMsg = pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not success then
    warn("Erro ao carregar Rayfield: " .. errorMsg)
    return
end

-- ==================== CRIAÇÃO DA INTERFACE ====================
local Window
success, errorMsg = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = CONFIG.UI.Name,
        LoadingTitle = CONFIG.UI.LoadingTitle,
        LoadingSubtitle = CONFIG.UI.LoadingSubtitle,
    })
end)
if not success or not Window then
    warn("Erro ao criar janela: " .. errorMsg)
    return
end

local Tabs = {
    Player = Window:CreateTab("Jogador", 4483362458),
    Evade = Window:CreateTab("Evade", 4483362458),
}

-- ==================== UTILITÁRIOS ====================
local Utils = {
    Notify = function(title, content, duration)
        pcall(function()
            Rayfield:Notify({
                Title = title,
                Content = content,
                Duration = duration or 3,
                Image = 4483362458,
                Actions = { Ignore = { Name = "Ok", Callback = function() end } },
            })
        end)
    end,
    SafeGet = function(path, waitTime)
        local key = table.concat(path, ".")
        if Cache.Dependencies[key] ~= nil then
            return Cache.Dependencies[key]
        end
        local success, result = pcall(function()
            local obj = game
            for _, part in ipairs(path) do
                if waitTime then
                    obj = obj:WaitForChild(part, waitTime)
                else
                    obj = obj:FindFirstChild(part)
                end
                if not obj then return nil end
            end
            return obj
        end)
        Cache.Dependencies[key] = success and result or nil
        return Cache.Dependencies[key]
    end,
}

-- ==================== MÓDULOS DO SCRIPT ====================
local Modules = {}

-- **MÓDULO: TESTE SIMPLES**
local TestModule = {
    Tab = "Player",
    Name = "Teste Simples",
    Dependencies = {},
    Start = function(self)
        local tab = Tabs[self.Tab]
        tab:CreateSection("Testes")
        tab:CreateButton({
            Name = "Testar Interface",
            Callback = function()
                Utils.Notify("Teste", "A interface está funcionando!", 3)
            end,
        })
        return true
    end,
}
table.insert(Modules, TestModule)

-- **MÓDULO: SPEED HACK**
local SpeedModule = {
    Tab = "Player",
    Name = "Aumentar Velocidade",
    Dependencies = {},
    Config = { speed = 16, defaultSpeed = 16, running = false },
    Start = function(self)
        local tab = Tabs[self.Tab]
        tab:CreateSection("Movimentação")
        self.slider = tab:CreateSlider({
            Name = "Velocidade",
            Range = {16, 250},
            Increment = 1,
            CurrentValue = self.Config.speed,
            Callback = function(value)
                self.Config.speed = value
                self.Config.running = (value > self.Config.defaultSpeed)
                Utils.Notify("Velocidade", "Ajustada para " .. value, 2)
            end,
        })
        tab:CreateButton({
            Name = "Resetar Velocidade",
            Callback = function()
                self.Config.speed = self.Config.defaultSpeed
                self.Config.running = false
                self.slider:Set(self.Config.defaultSpeed)
                Utils.Notify("Velocidade", "Resetada para " .. self.Config.defaultSpeed, 2)
            end,
        })
        Services.RunService.Heartbeat:Connect(function()
            if not self.Config.running then return end
            local char = Cache.localPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * self.Config.speed * 0.01)
            end
        end)
        return true
    end,
}
table.insert(Modules, SpeedModule)

-- **MÓDULO: ESP CAÍDOS**
local DownedESPModule = {
    Tab = "Evade",
    Name = "Ver Jogadores Caídos",
    Dependencies = {{"Workspace", "Game", "Players"}},
    Config = { enabled = false, esps = {} },
    Start = function(self)
        local playersFolder = Utils.SafeGet(self.Dependencies[1], 5)
        if not playersFolder then
            Utils.Notify("Aviso", "ESP Caídos não disponível (pasta de jogadores não encontrada)", 5)
            return false
        end
        local tab = Tabs[self.Tab]
        tab:CreateSection("Visuais")
        tab:CreateToggle({
            Name = "ESP Caídos",
            CurrentValue = false,
            Callback = function(value)
                self.Config.enabled = value
                if not value then
                    for _, esp in pairs(self.Config.esps) do
                        if esp.gui then esp.gui:Destroy() end
                    end
                    self.Config.esps = {}
                end
            end,
        })
        task.spawn(function()
            while true do
                if self.Config.enabled then
                    -- Limpar ESPs antigos
                    for _, esp in pairs(self.Config.esps) do
                        if esp.gui then esp.gui:Destroy() end
                    end
                    self.Config.esps = {}
                    
                    -- Criar novos ESPs
                    for _, model in pairs(playersFolder:GetChildren()) do
                        local timeLeft = model:GetAttribute("DownedTimeLeft")
                        local root = model:FindFirstChild("HumanoidRootPart")
                        if timeLeft and timeLeft > 0 and root then
                            local distance = math.floor((Cache.camera.CFrame.Position - root.Position).Magnitude)
                            local initialTimeLeft = model:GetAttribute("InitialDownedTimeLeft") or timeLeft -- Tenta obter o tempo inicial, usa timeLeft como fallback
                            
                            -- Criar BillboardGui
                            local gui = Instance.new("BillboardGui")
                            gui.Adornee = root
                            gui.Size = UDim2.new(0, 200, 0, 50)
                            gui.StudsOffset = Vector3.new(0, 3, 0)
                            gui.AlwaysOnTop = true
                            gui.Parent = model
                            
                            -- Criar TextLabel
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextStrokeTransparency = 0.5
                            label.Text = string.format("%s\n%d studs\n%d segundos", model.Name, distance, math.floor(timeLeft))
                            label.TextScaled = true
                            label.Font = Enum.Font.SourceSansBold
                            label.Parent = gui
                            
                            -- Calcular a cor com base no tempo restante
                            local t = math.clamp(timeLeft / initialTimeLeft, 0, 1) -- Proporção do tempo restante
                            local r = (1 - t) * 255 -- Vermelho aumenta quando t diminui
                            local b = t * 255 -- Azul diminui quando t diminui
                            label.TextColor3 = Color3.fromRGB(r, 0, b)
                            
                            -- Armazenar ESP com initialTimeLeft
                            table.insert(self.Config.esps, {
                                gui = gui,
                                label = label,
                                initialTimeLeft = initialTimeLeft
                            })
                        end
                    end
                end
                task.wait(1)
            end
        end)
        return true
    end,
}
table.insert(Modules, DownedESPModule)

-- **MÓDULO: ESP NEXTBOTS**
local NextBotESPModule = {
    Tab = "Evade",
    Name = "ESP NextBots",
    Dependencies = {{"Workspace", "Game", "Players"}},
    Config = { enabled = false, activeESP = {} },
    Start = function(self)
        local playersFolder = Utils.SafeGet(self.Dependencies[1], 5)
        if not playersFolder then
            Utils.Notify("Aviso", "ESP NextBots não disponível (pasta de jogadores não encontrada)", 5)
            return false
        end
        local tab = Tabs[self.Tab]
        tab:CreateToggle({
            Name = "ESP NextBots (Nome + Distância)",
            CurrentValue = false,
            Callback = function(value)
                self.Config.enabled = value
                if not value then
                    for _, data in pairs(self.Config.activeESP) do
                        if data.gui then data.gui:Destroy() end
                    end
                    self.Config.activeESP = {}
                end
            end,
        })
        Services.RunService.RenderStepped:Connect(function()
            if not self.Config.enabled then return end
            local char = Cache.localPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            for _, bot in pairs(playersFolder:GetChildren()) do
                if bot:FindFirstChild("Humanoid") and bot:FindFirstChild("HumanoidRootPart") then
                    local team = bot:GetAttribute("Team")
                    if team == "Nextbot" and not self.Config.activeESP[bot] then
                        local botRoot = bot:FindFirstChild("HumanoidRootPart") or bot.PrimaryPart
                        if botRoot then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Name = "NextBotESP"
                            billboard.Size = UDim2.new(0, 100, 0, 40)
                            billboard.AlwaysOnTop = true
                            billboard.Adornee = botRoot
                            billboard.Parent = bot
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.new(1, 0, 0)
                            label.TextStrokeTransparency = 0.5
                            label.TextScaled = true
                            label.Font = Enum.Font.GothamBold
                            label.Parent = billboard
                            self.Config.activeESP[bot] = { gui = billboard, label = label }
                        end
                    end
                end
            end
            for bot, data in pairs(self.Config.activeESP) do
                if bot and bot:FindFirstChild("HumanoidRootPart") then
                    local dist = (bot.HumanoidRootPart.Position - root.Position).Magnitude
                    data.label.Text = bot.Name .. " | " .. math.floor(dist) .. " studs"
                else
                    if data.gui then data.gui:Destroy() end
                    self.Config.activeESP[bot] = nil
                end
            end
        end)
        return true
    end,
}
table.insert(Modules, NextBotESPModule)

-- **MÓDULO: INSTA SAVE**
local InstaSaveModule = {
    Tab = "Evade",
    Name = "Insta Save",
    Dependencies = {{"ReplicatedStorage", "Events", "Character", "Interact"}, {"Workspace", "Game", "Players"}},
    Config = { enabled = false, reviveDistance = 40 },
    Start = function(self)
        local reviveEvent = Utils.SafeGet(self.Dependencies[1], 5)
        local playersFolder = Utils.SafeGet(self.Dependencies[2], 5)
        if not reviveEvent or not playersFolder then
            Utils.Notify("Aviso", "Insta Save não disponível (eventos ou pasta de jogadores não encontrados)", 5)
            return false
        end
        local tab = Tabs[self.Tab]
        tab:CreateSection("REVIVER")
        tab:CreateToggle({
            Name = "Insta Save",
            CurrentValue = false,
            Callback = function(value)
                self.Config.enabled = value
                Utils.Notify("Insta Save", "Insta Save " .. (value and "Ativado" or "Desativado"), 3)
            end,
        })
        self.character = Cache.localPlayer.Character or Cache.localPlayer.CharacterAdded:Wait()
        self.root = self.character and self.character:WaitForChild("HumanoidRootPart")
        Cache.localPlayer.CharacterAdded:Connect(function(newCharacter)
            self.character = newCharacter
            self.root = newCharacter:WaitForChild("HumanoidRootPart")
        end)
        Services.RunService.Stepped:Connect(function()
            if not self.Config.enabled or not self.root or not self.character then return end
            local myModel = playersFolder:FindFirstChild(Cache.localPlayer.Name)
            if myModel and myModel:GetAttribute("DownedTimeLeft") and myModel:GetAttribute("DownedTimeLeft") > 0 then return end
            for _, model in pairs(playersFolder:GetChildren()) do
                if model:IsA("Model") and model.Name ~= Cache.localPlayer.Name then
                    local timeLeft = model:GetAttribute("DownedTimeLeft")
                    local rootPart = model:FindFirstChild("HumanoidRootPart")
                    if timeLeft and timeLeft > 0 and rootPart then
                        local distance = (self.root.Position - rootPart.Position).Magnitude
                        if distance <= self.Config.reviveDistance then
                            pcall(function()
                                reviveEvent:FireServer("Revive", true, model.Name)
                                reviveEvent:FireServer("Revive", model.Name)
                            end)
                        end
                    end
                end
            end
        end)
        return true
    end,
}
table.insert(Modules, InstaSaveModule)

-- **MODULO AUTO CARRY PLAYER**
local AutoPagarPlayerModule = {
    Tab = "Evade",
    Name = "Auto Pagar Player",
    Dependencies = {
        {"Workspace", "Game", "Players"}, -- Para localizar os modelos dos jogadores
        {"ReplicatedStorage", "Events", "Character", "Interact"} -- Para o evento de "pegar"
    },
    Config = {
        enabled = false, -- Controlado pelo toggle
        distanceThreshold = 20, -- Raio para tentar pegar jogadores caídos
        touchThreshold = 2, -- Distância para considerar "tocando" o jogador carregado
        lastNotifiedPlayer = nil, -- Evita spam de notificações
        ignoredPlayers = {}, -- Jogadores ignorados temporariamente
        ignoreDuration = 5, -- Duração para ignorar após soltar
        dropButton = nil, -- Referência ao botão de "soltar"
        buttonCooldown = 1, -- Cooldown para cliques no botão
        lastButtonClick = 0, -- Timestamp do último clique
        dragThreshold = 10 -- Distância mínima para arrastar
    },
    Start = function(self)
        -- Verificar dependências globais
        if not Utils or not Cache or not Tabs then
            warn("AutoPagarPlayerModule: Dependências globais não encontradas")
            pcall(function()
                Utils.Notify("Erro", "Auto Pagar Player não disponível", 5)
            end)
            return false
        end

        -- Verificar aba "Evade"
        local tab = Tabs[self.Tab]
        if not tab or not tab.CreateToggle then
            warn("AutoPagarPlayerModule: Aba 'Evade' ou CreateToggle não encontrado")
            pcall(function()
                Utils.Notify("Erro", "Aba Evade incompatível", 5)
            end)
            return false
        end

        -- Obter dependências do jogo
        local playersFolder = Utils.SafeGet(self.Dependencies[1], 5)
        local interactEvent = Utils.SafeGet(self.Dependencies[2], 5)
        if not playersFolder or not interactEvent then
            warn("AutoPagarPlayerModule: Dependências do jogo não encontradas")
            pcall(function()
                Utils.Notify("Erro", "Dependências do jogo não encontradas", 5)
            end)
            return false
        end

        -- Criar toggle na aba "Evade"
        local success, errorMsg = pcall(function()
            tab:CreateToggle({
                Name = "Auto Pagar Player",
                CurrentValue = false,
                Callback = function(value)
                    self.Config.enabled = value
                    self.Config.lastNotifiedPlayer = nil
                    self.Config.ignoredPlayers = {}
                    if self.Config.dropButton then
                        self:DestroyDropButton()
                    end
                    pcall(function()
                        Utils.Notify("Info", "Auto Pagar Player " .. (value and "ativado" or "desativado") .. "!", 3)
                    end)
                    warn("AutoPagarPlayerModule: Toggle alterado para " .. tostring(value))
                end
            })
        end)

        if not success then
            warn("AutoPagarPlayerModule: Erro ao criar toggle: " .. tostring(errorMsg))
            pcall(function()
                Utils.Notify("Erro", "Falha ao criar toggle", 5)
            end)
            return false
        end

        -- Conectar ao evento CharacterAdded
        if Cache.localPlayer then
            Cache.localPlayer.CharacterAdded:Connect(function()
                warn("AutoPagarPlayerModule: Personagem renascido")
                self.Config.lastNotifiedPlayer = nil
                self.Config.ignoredPlayers = {}
                if self.Config.dropButton then
                    self:DestroyDropButton()
                end
            end)
        end

        -- Loop para monitorar jogadores caídos
        task.spawn(function()
            while true do
                if self.Config.enabled then
                    self:MonitorFallenPlayers(playersFolder, interactEvent)
                    self:UpdateDropButton(playersFolder, interactEvent)
                end
                task.wait(0.1)
            end
        end)

        -- Loop para limpar jogadores ignorados
        task.spawn(function()
            while true do
                local currentTime = tick()
                for playerName, ignoreTime in pairs(self.Config.ignoredPlayers) do
                    if currentTime - ignoreTime >= self.Config.ignoreDuration then
                        self.Config.ignoredPlayers[playerName] = nil
                        warn("AutoPagarPlayerModule: Jogador " .. playerName .. " voltou a ser válido")
                    end
                end
                task.wait(1)
            end
        end)

        warn("AutoPagarPlayerModule: Inicializado com sucesso")
        return true
    end,
    MonitorFallenPlayers = function(self, playersFolder, interactEvent)
        local localPlayer = Cache.localPlayer
        if not localPlayer or not localPlayer.Character then
            return
        end

        local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            return
        end

        -- Encontrar jogador caído mais próximo
        local closestPlayer, closestDistance = nil, math.huge
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and model.Name ~= localPlayer.Name and not self.Config.ignoredPlayers[model.Name] then
                local isDowned = model:GetAttribute("Downed")
                local isCarried = model:GetAttribute("Carried")
                local rootPart = model:FindFirstChild("HumanoidRootPart")
                if isDowned and not isCarried and rootPart then
                    local distance = (localRoot.Position - rootPart.Position).Magnitude
                    if distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = model
                    end
                end
            end
        end

        -- Tentar pegar jogador próximo
        if closestPlayer and closestDistance <= self.Config.distanceThreshold then
            self:CarryPlayer(closestPlayer.Name, interactEvent)
            warn("AutoPagarPlayerModule: Tentando pegar " .. closestPlayer.Name .. " (" .. string.format("%.2f", closestDistance) .. " studs)")
        else
            self.Config.lastNotifiedPlayer = nil
        end
    end,
    CarryPlayer = function(self, playerName, interactEvent)
        local args = {"Carry", [3] = playerName}
        local success, errorMsg = pcall(function()
            interactEvent:FireServer(unpack(args))
        end)
        if success then
            if playerName ~= self.Config.lastNotifiedPlayer then
                pcall(function()
                    Utils.Notify("Sucesso", "Tentando pegar " .. playerName .. "!", 3)
                end)
                self.Config.lastNotifiedPlayer = playerName
            end
            warn("AutoPagarPlayerModule: Evento Carry disparado para " .. playerName)
        else
            pcall(function()
                Utils.Notify("Erro", "Falha ao pegar " .. playerName, 5)
            end)
            warn("AutoPagarPlayerModule: Erro ao disparar Carry: " .. tostring(errorMsg))
        end
    end,
    UpdateDropButton = function(self, playersFolder, interactEvent)
        local localPlayer = Cache.localPlayer
        if not localPlayer or not localPlayer.Character then
            if self.Config.dropButton then
                self:DestroyDropButton()
            end
            return
        end

        local localRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then
            return
        end

        -- Verificar se há um jogador carregado e próximo
        local carriedPlayer = nil
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and model:GetAttribute("Carried") then
                local rootPart = model:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local distance = (localRoot.Position - rootPart.Position).Magnitude
                    if distance <= self.Config.touchThreshold then
                        carriedPlayer = model
                        break
                    end
                end
            end
        end

        -- Mostrar ou esconder botão com base na proximidade
        if carriedPlayer and not self.Config.ignoredPlayers[carriedPlayer.Name] then
            if not self.Config.dropButton then
                self:ShowDropButton(carriedPlayer.Name, interactEvent)
            end
        elseif self.Config.dropButton then
            self:DestroyDropButton()
        end
    end,
    ShowDropButton = function(self, playerName, interactEvent)
        local playerGui = Cache.localPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            warn("AutoPagarPlayerModule: PlayerGui não encontrado")
            return
        end

        -- Limpar botões duplicados
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui.Name == "DropButtonGui" then
                pcall(function()
                    gui:Destroy()
                end)
            end
        end

        local UserInputService = game:GetService("UserInputService")

        -- Criar botão
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "DropButtonGui"
        screenGui.IgnoreGuiInset = true
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 150, 0, 50)
        frame.Position = UDim2.new(0.5, -75, 0.7, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        frame.BorderSizePixel = 2
        frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
        frame.ClipsDescendants = true
        frame.Parent = screenGui

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 8)
        uiCorner.Parent = frame

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.fromRGB(255, 0, 0)
        uiStroke.Thickness = 1
        uiStroke.Parent = frame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.Text = "Soltar " .. playerName
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.TextSize = 18
        button.Font = Enum.Font.GothamBold
        button.Parent = frame

        -- Suporte a arrastar
        local dragging, dragStart, startPos, canDrag = false, nil, nil, false
        local function updatePosition(input)
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end

        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        button.InputChanged:Connect(function(input)
            if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                if not canDrag and delta.Magnitude >= self.Config.dragThreshold then
                    canDrag = true
                    dragging = true
                end
                if dragging then
                    updatePosition(input)
                end
            end
        end)

        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                canDrag = false
                dragStart = nil
            end
        end)

        -- Ação do botão
        button.Activated:Connect(function()
            local currentTime = tick()
            if currentTime - self.Config.lastButtonClick < self.Config.buttonCooldown then
                return
            end
            self.Config.lastButtonClick = currentTime

            local dropArgs = {"Drop", [3] = playerName}
            local success, errorMsg = pcall(function()
                interactEvent:FireServer(unpack(dropArgs))
            end)
            if success then
                self.Config.ignoredPlayers[playerName] = tick()
                self:DestroyDropButton()
                pcall(function()
                    Utils.Notify("Sucesso", "Jogador " .. playerName .. " solto! Ignorado por 5 segundos.", 3)
                end)
                warn("AutoPagarPlayerModule: Evento Drop disparado para " .. playerName)
            else
                pcall(function()
                    Utils.Notify("Erro", "Falha ao soltar " .. playerName, 5)
                end)
                warn("AutoPagarPlayerModule: Erro ao disparar Drop: " .. tostring(errorMsg))
            end
        end)

        self.Config.dropButton = screenGui
    end,
    DestroyDropButton = function(self)
        if self.Config.dropButton then
            pcall(function()
                self.Config.dropButton:Destroy()
            end)
            self.Config.dropButton = nil
        end
    end
}

table.insert(Modules, AutoPagarPlayerModule)

-- **MÓDULO AUTOREVIVER**
local AutoReviveModule = {
    Tab = "Evade",
    Name = "Auto Revive",
    Dependencies = {
        {"Workspace", "Game", "Players"},
        {"ReplicatedStorage", "Events", "Character", "Interact"},
        {"ReplicatedStorage", "Events", "Player", "ChangePlayerMode"}
    },
    Config = {
        enabled = false,
        processing = false,
        savedPosition = nil,
        wasDowned = false,
        lastDownedPosition = nil,
        lastModeEventTime = 0
    },
    Start = function(self)
        -- Verificar dependências globais
        if not Utils or not Cache or not Tabs or not Services then
            warn("Erro: Dependências globais (Utils, Cache, Tabs, Services) não encontradas")
            return false
        end

        -- Obter dependências do jogo
        local playersFolder = Utils.SafeGet(self.Dependencies[1], 5)
        local reviveEvent = Utils.SafeGet(self.Dependencies[2], 5)
        local modeEvent = Utils.SafeGet(self.Dependencies[3], 5)
        
        if not playersFolder or not reviveEvent or not modeEvent then
            Utils.Notify("Aviso", "Auto Revive não disponível (dependências não encontradas)", 5)
            return false
        end

        -- Criar toggle na interface
        local tab = Tabs[self.Tab]
        tab:CreateToggle({
            Name = "Auto Revive",
            CurrentValue = false,
            Callback = function(value)
                self.Config.enabled = value
                if not value then
                    self.Config.processing = false
                    self.Config.savedPosition = nil
                    self.Config.wasDowned = false
                    self.Config.lastDownedPosition = nil
                    self.Config.lastModeEventTime = 0
                end
                Utils.Notify("Auto Revive", "Auto Revive " .. (value and "Ativado" or "Desativado"), 3)
            end
        })

        -- Inicializar referências do personagem
        local character = Cache.localPlayer.Character or Cache.localPlayer.CharacterAdded:Wait()
        local root = character and character:WaitForChild("HumanoidRootPart", 5)
        Cache.localPlayer.CharacterAdded:Connect(function(newChar)
            character = newChar
            root = nil -- Resetar root para evitar referências inválidas
            self.Config.processing = false -- Reiniciar estado de processamento
            self.Config.savedPosition = nil -- Limpar posição salva
            task.defer(function()
                root = character:WaitForChild("HumanoidRootPart", 5)
            end)
        end)

        -- Função para verificar se o jogador local está caído
        local function isLocalDown()
            local myModel = playersFolder:FindFirstChild(Cache.localPlayer.Name)
            if not myModel then
                return false
            end
            local isDowned = myModel:GetAttribute("Downed")
            return isDowned == true
        end

        -- Função para obter jogadores caídos
        local function getDownedPlayers()
            local downed = {}
            for _, model in ipairs(playersFolder:GetChildren()) do
                if model:IsA("Model") and model.Name ~= Cache.localPlayer.Name then
                    local isDowned = model:GetAttribute("Downed")
                    local rootPart = model:FindFirstChild("HumanoidRootPart")
                    local isCarried = model:GetAttribute("Carried")
                    if isDowned == true and rootPart and isCarried ~= true then
                        table.insert(downed, model)
                    end
                end
            end
            return downed
        end

        -- Função para seguir e reviver um jogador
        local function followAndRevive(target)
            local targetRoot = target:FindFirstChild("HumanoidRootPart")
            if not targetRoot or not root then
                return
            end

            local connection
            local startTime = tick()
            local lastTimeLeft = target:GetAttribute("DownedTimeLeft") or 0
            local positionConfirmed = false
            local waitForPositionTime = 2 -- Tempo máximo para esperar a posição real (segundos)

            connection = Services.RunService.RenderStepped:Connect(function()
                if isLocalDown() or not target:IsDescendantOf(playersFolder) or not root then
                    if self.Config.savedPosition and root then
                        task.spawn(function()
                            root.CFrame = self.Config.savedPosition
                        end)
                    end
                    connection:Disconnect()
                    return
                end

                local isDowned = target:GetAttribute("Downed")
                local timeLeft = target:GetAttribute("DownedTimeLeft") or 0
                local isCarried = target:GetAttribute("Carried")
                if isDowned ~= true or (tick() - startTime >= 5) then
                    if self.Config.savedPosition and root then
                        task.spawn(function()
                            root.CFrame = self.Config.savedPosition
                        end)
                    end
                    connection:Disconnect()
                    return
                end

                -- Verificar se o jogador está sendo carregado
                if isCarried == true then
                    if self.Config.savedPosition and root then
                        task.spawn(function()
                            root.CFrame = self.Config.savedPosition
                        end)
                    end
                    connection:Disconnect()
                    return
                end

                -- Verificar confirmação da posição real
                if timeLeft ~= lastTimeLeft then
                    positionConfirmed = true
                    lastTimeLeft = timeLeft
                end

                -- Se o tempo máximo de espera for atingido sem confirmação, voltar à posição original
                if not positionConfirmed and (tick() - startTime >= waitForPositionTime) then
                    if self.Config.savedPosition and root then
                        task.spawn(function()
                            root.CFrame = self.Config.savedPosition
                        end)
                    end
                    connection:Disconnect()
                    return
                end

                -- Ficar fixo abaixo do jogador
                local hoverPos = targetRoot.Position + Vector3.new(0, -4.5, 0)
                if root then
                    root.CFrame = CFrame.new(hoverPos, targetRoot.Position)
                end

                -- Tentar reviver apenas após confirmação da posição
                if positionConfirmed then
                    pcall(function()
                        local name = target.Name
                        reviveEvent:FireServer("Revive", true, name)
                        reviveEvent:FireServer("Revive", name)
                    end)
                end
            end)

            while target:GetAttribute("Downed") == true do
                if isLocalDown() or tick() - startTime >= 5 or not target:IsDescendantOf(playersFolder) or target:GetAttribute("Carried") == true or not root then
                    break
                end
                task.wait(0.2)
            end

            if connection and connection.Connected then
                connection:Disconnect()
            end

            -- Restaurar posição ao finalizar
            if self.Config.savedPosition and root then
                task.spawn(function()
                    root.CFrame = self.Config.savedPosition
                end)
            end
        end

        -- Loop principal
        task.spawn(function()
            while true do
                task.wait(0.3)

                if not self.Config.enabled or not root or not character then
                    task.wait(0.3)
                    continue
                end

                local myModel = playersFolder:FindFirstChild(Cache.localPlayer.Name)
                if not myModel then
                    task.wait(0.3)
                    continue
                end
                local isDowned = myModel:GetAttribute("Downed")

                -- Gerenciar estado de caído
                if isDowned == true then
                    if not self.Config.wasDowned then
                        self.Config.lastDownedPosition = root.CFrame
                        self.Config.wasDowned = true
                        if not Cache.isHandlingDowned then
                            Cache.isHandlingDowned = true
                            pcall(function()
                                modeEvent:FireServer(true)
                            end)
                            Cache.isHandlingDowned = false
                            self.Config.lastModeEventTime = tick()
                        end
                    elseif tick() - self.Config.lastModeEventTime >= 3 then
                        if not Cache.isHandlingDowned then
                            Cache.isHandlingDowned = true
                            pcall(function()
                                modeEvent:FireServer(true)
                            end)
                            Cache.isHandlingDowned = false
                            self.Config.lastModeEventTime = tick()
                        end
                    end
                    task.wait(0.3)
                    continue
                elseif self.Config.wasDowned and isDowned ~= true then
                    if self.Config.lastDownedPosition and root then
                        task.spawn(function()
                            root.CFrame = self.Config.lastDownedPosition
                        end)
                        self.Config.lastDownedPosition = nil
                        self.Config.wasDowned = false
                        self.Config.lastModeEventTime = 0
                    end
                end

                if self.Config.processing then
                    task.wait(0.3)
                    continue
                end

                local downedList = getDownedPlayers()
                if #downedList > 0 then
                    self.Config.processing = true
                    self.Config.savedPosition = root.CFrame

                    table.sort(downedList, function(a, b)
                        local posA = a.HumanoidRootPart and a.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
                        local posB = b.HumanoidRootPart and b.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
                        return (Cache.camera.CFrame.Position - posA).Magnitude <
                               (Cache.camera.CFrame.Position - posB).Magnitude
                    end)

                    for _, player in ipairs(downedList) do
                        if isLocalDown() or not player:IsDescendantOf(playersFolder) or not root then
                            break
                        end
                        if player:GetAttribute("Downed") == true then
                            followAndRevive(player)
                        end
                    end

                    if not isLocalDown() and self.Config.savedPosition and root then
                        task.spawn(function()
                            root.CFrame = self.Config.savedPosition
                        end)
                    end

                    self.Config.processing = false
                    self.Config.savedPosition = nil -- Limpar após restauração
                end

                task.wait(0.3)
            end
        end)

        return true
    end
}

table.insert(Modules, AutoReviveModule)

-- **MÓDULO: FAKE GOOD**
local FakeGoodModule = {
    Tab = "Evade",
    Name = "Fake Good",
    Dependencies = {{"ReplicatedStorage", "Events", "Player", "ChangePlayerMode"}, {"Workspace", "Game", "Players"}},
    Config = { enabled = false, lastPosition = nil, wasDowned = false },
    Start = function(self)
        local changePlayerModeEvent = Utils.SafeGet(self.Dependencies[1], 5)
        local playersFolder = Utils.SafeGet(self.Dependencies[2], 5)
        if not changePlayerModeEvent or not playersFolder then
            Utils.Notify("Aviso", "Fake Good não disponível (eventos ou pasta de jogadores não encontrados)", 5)
            return false
        end
        local tab = Tabs[self.Tab]
        tab:CreateToggle({
            Name = "Fake Good (Previnir Morte)",
            CurrentValue = false,
            Callback = function(value)
                self.Config.enabled = value
                if not value then
                    self.Config.lastPosition = nil
                    self.Config.wasDowned = false
                end
            end,
        })
        task.spawn(function()
            while true do
                if not self.Config.enabled then
                    self.Config.lastPosition = nil
                    self.Config.wasDowned = false
                    task.wait(1)
                    continue
                end
                local model = playersFolder:FindFirstChild(Cache.localPlayer.Name)
                if not model then
                    task.wait(1)
                    continue
                end
                local timeLeft = model:GetAttribute("DownedTimeLeft")
                local rootPart = model:FindFirstChild("HumanoidRootPart")
                if timeLeft and timeLeft > 0 and rootPart then
                    if not self.Config.wasDowned then
                        self.Config.lastPosition = rootPart.CFrame
                        self.Config.wasDowned = true
                    end
                    if not Cache.isHandlingDowned then
                        Cache.isHandlingDowned = true
                        pcall(function()
                            changePlayerModeEvent:FireServer(true)
                        end)
                        Cache.isHandlingDowned = false
                    end
                elseif self.Config.wasDowned and (not timeLeft or timeLeft <= 0) and rootPart then
                    if self.Config.lastPosition then
                        rootPart.CFrame = self.Config.lastPosition
                        self.Config.lastPosition = nil
                        self.Config.wasDowned = false
                    end
                end
                task.wait(1)
            end
        end)
        return true
    end,
}
table.insert(Modules, FakeGoodModule)

-- **MÓDULO BUTTON ALEATÓRIO TP**
local RandomSpawnTeleportModule = {
    Tab = "Evade",
    Name = "Random Spawn Teleport",
    Dependencies = {
        {"Workspace", "Game", "Map", "Parts", "Spawns"} -- Caminho para o modelo de spawns
    },
    Config = {
        enabled = true -- Sempre ativo
    },
    Start = function(self)
        -- Verificar dependências globais
        if not Utils or not Cache or not Tabs then
            warn("RandomSpawnTeleportModule: Dependências globais (Utils, Cache, Tabs) não encontradas")
            pcall(function()
                Utils.Notify("Erro", "Teleportador de Spawn não disponível (dependências não encontradas)", 5)
            end)
            return false
        end

        -- Verificar aba
        local tab = Tabs[self.Tab]
        if not tab then
            warn("RandomSpawnTeleportModule: Aba 'Evade' não encontrada em Tabs")
            pcall(function()
                Utils.Notify("Erro", "Aba Evade não encontrada na interface", 5)
            end)
            return false
        end

        -- Verificar métodos Rayfield
        if not tab.CreateButton then
            warn("RandomSpawnTeleportModule: Método CreateButton não encontrado")
            pcall(function()
                Utils.Notify("Erro", "Interface Rayfield incompatível", 5)
            end)
            return false
        end

        -- Monitorar mudanças no mapa
        local mapPath = {"Workspace", "Game", "Map"}
        local function updateSpawnsModel()
            local spawnsModel = Utils.SafeGet(self.Dependencies[1], 5)
            if spawnsModel then
                warn("RandomSpawnTeleportModule: Modelo Spawns atualizado com sucesso")
            else
                warn("RandomSpawnTeleportModule: Modelo Spawns não encontrado")
            end
            return spawnsModel
        end

        -- Observar mudanças no Map
        local mapFolder = Utils.SafeGet(mapPath, 5)
        if mapFolder then
            mapFolder.ChildAdded:Connect(function(child)
                if child.Name == "Parts" then
                    warn("RandomSpawnTeleportModule: Novo mapa detectado, atualizando spawns")
                    updateSpawnsModel()
                end
            end)
            mapFolder.AncestryChanged:Connect(function()
                warn("RandomSpawnTeleportModule: Mapa alterado, atualizando spawns")
                updateSpawnsModel()
            end)
        end

        -- Criar botão na interface
        local success, errorMsg = pcall(function()
            tab:CreateButton({
                Name = "Teleportar para Spawn Aleatório",
                Callback = function()
                    warn("RandomSpawnTeleportModule: Botão Teleportar clicado")
                    self:TeleportToRandomSpawn(Cache.localPlayer)
                end
            })
        end)

        if not success then
            warn("RandomSpawnTeleportModule: Erro ao criar botão: " .. tostring(errorMsg))
            pcall(function()
                Utils.Notify("Erro", "Falha ao inicializar botão de teletransporte", 5)
            end)
            return false
        end

        -- Conectar ao evento CharacterAdded para lidar com renascimentos
        if Cache.localPlayer then
            Cache.localPlayer.CharacterAdded:Connect(function(character)
                warn("RandomSpawnTeleportModule: Personagem renascido, pronto para teletransporte")
                task.wait(0.5) -- Pequeno atraso para garantir que o personagem esteja carregado
            end)
        end

        warn("RandomSpawnTeleportModule: Inicializado com sucesso")
        return true
    end,
    -- Função para teletransportar o jogador para um SpawnLocation aleatório
    TeleportToRandomSpawn = function(self, player)
        -- Verificar jogador e personagem
        if not player or not player.Character then
            warn("RandomSpawnTeleportModule: Jogador ou personagem não encontrado")
            pcall(function()
                Utils.Notify("Erro", "Aguardando personagem carregar!", 5)
            end)
            return
        end

        local character = player.Character
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            warn("RandomSpawnTeleportModule: HumanoidRootPart não encontrado")
            pcall(function()
                Utils.Notify("Erro", "Personagem não carregado corretamente!", 5)
            end)
            return
        end

        -- Obter modelo de spawns
        local spawnsModel = Utils.SafeGet(self.Dependencies[1], 5)
        if not spawnsModel then
            warn("RandomSpawnTeleportModule: Modelo Spawns não encontrado")
            pcall(function()
                Utils.Notify("Erro", "Mapa não carregado ou spawns não encontrados!", 5)
            end)
            return
        end

        -- Obter SpawnLocations válidos
        local spawnLocations = spawnsModel:GetChildren()
        local validSpawns = {}
        for _, spawn in ipairs(spawnLocations) do
            if spawn:IsA("SpawnLocation") then
                table.insert(validSpawns, spawn)
            end
        end

        -- Verificar se há spawns válidos
        if #validSpawns == 0 then
            warn("RandomSpawnTeleportModule: Nenhum SpawnLocation válido encontrado")
            pcall(function()
                Utils.Notify("Erro", "Nenhum spawn encontrado no mapa!", 5)
            end)
            return
        end

        -- Escolher um spawn aleatoriamente
        local randomSpawn = validSpawns[math.random(1, #validSpawns)]
        warn("RandomSpawnTeleportModule: Spawn selecionado: " .. randomSpawn.Name)

        -- Teletransportar o jogador
        local success, errorMsg = pcall(function()
            task.wait(0.1) -- Pequeno atraso para evitar conflitos com física
            humanoidRootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)
        end)

        if success then
            pcall(function()
                Utils.Notify("Sucesso", "Teletransportado para spawn aleatório!", 3)
            end)
            warn("RandomSpawnTeleportModule: Teletransporte realizado com sucesso")
        else
            warn("RandomSpawnTeleportModule: Erro ao teletransportar: " .. tostring(errorMsg))
            pcall(function()
                Utils.Notify("Erro", "Falha ao teletransportar: " .. tostring(errorMsg), 5)
            end)
        end
    end
}

table.insert(Modules, RandomSpawnTeleportModule)

-- ==================== INICIALIZAÇÃO AUTOMÁTICA ====================
local function InitializeModules()
    local activeModules = {}
    for _, module in ipairs(Modules) do
        local allDependenciesMet = true
        for _, dep in ipairs(module.Dependencies or {}) do
            if not Utils.SafeGet(dep, 5) then
                allDependenciesMet = false
                Utils.Notify("Aviso", "Módulo '" .. module.Name .. "' não carregado (dependência não encontrada)", 5)
                break
            end
        end
        if allDependenciesMet then
            local success, result = pcall(function()
                return module:Start()
            end)
            if success and result then
                table.insert(activeModules, module)
            else
                Utils.Notify("Erro", "Módulo '" .. module.Name .. "' falhou ao iniciar", 5)
            end
        end
    end
    -- Remover abas vazias
    for tabName, tab in pairs(Tabs) do
        local hasControls = false
        for _, module in ipairs(activeModules) do
            if module.Tab == tabName then
                hasControls = true
                break
            end
        end
        if not hasControls then
            tab:Destroy()
            Tabs[tabName] = nil
        end
    end
    Utils.Notify("Inicialização", "TekScripts carregado com " .. #activeModules .. " módulos ativos!", 5)
end

InitializeModules()

-- ==================== FIM DO SCRIPT ====================