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