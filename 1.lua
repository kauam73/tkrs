-- Carregamento da Biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Serviços e Variáveis Iniciais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local FloatingButton

-- Tabela de Configurações Personalizáveis
local config = {
    aimAssistEnabled = false,   -- Ativar/desativar o AimAssist
    aimbotStrength = 0.5,       -- Força do aimbot (0 a 1)
    aimbotRange = 1000,         -- Alcance máximo do aimbot
    fovSize = 60,               -- Tamanho do FOV em graus
    showFov = false,            -- Exibir círculo do FOV
    ignoreWalls = false,        -- Ignorar obstáculos via raycast
    teamCheck = true,           -- Desconsiderar alvos do mesmo time
    headPullDistance = 60,      -- Distância para puxar a cabeça do alvo
    visualizarPlayers = false,  -- Ativar/desativar o ESP dos jogadores
    visualizarInfo = false      -- Ativar/desativar informações detalhadas no ESP
}

-- Criação da Janela Principal com Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Tekscripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TekscriptsConfig",
        FileName = "PainelConfig"
    }
})

-- Criação das Abas (Categorias)
local AimAssistTab = Window:CreateTab("AimAssist", nil)
local ESPTab = Window:CreateTab("ESP", nil)
local OthersTab = Window:CreateTab("Outros", nil)

-- ### Aba AimAssist ###
-- Toggle Principal do AimAssist
AimAssistTab:CreateToggle({
    Name = "Ativar AimAssist",
    CurrentValue = config.aimAssistEnabled,
    Flag = "AimAssistEnabled",
    Callback = function(Value)
        config.aimAssistEnabled = Value
    end
})

-- Botão Flutuante para Controle Rápido
AimAssistTab:CreateToggle({
    Name = "Botão Flutuante (Ativação Rápida)",
    CurrentValue = false,
    Flag = "FloatingButtonToggle",
    Callback = function(Value)
        if Value then
            if not FloatingButton then
                local screenGui = Instance.new("ScreenGui")
                screenGui.Name = "FloatingAimbotGUI"
                screenGui.Parent = game:GetService("CoreGui")

                FloatingButton = Instance.new("Frame")
                FloatingButton.Size = UDim2.new(0, 80, 0, 80)
                FloatingButton.Position = UDim2.new(0.5, -40, 0, 20)
                FloatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                FloatingButton.BackgroundTransparency = 0.3
                FloatingButton.BorderSizePixel = 0
                FloatingButton.Parent = screenGui

                local uiCorner = Instance.new("UICorner")
                uiCorner.CornerRadius = UDim.new(0.5, 0)
                uiCorner.Parent = FloatingButton

                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 1, 0)
                Button.BackgroundTransparency = 1
                Button.Text = config.aimAssistEnabled and "✅" or "⚫"
                Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                Button.Font = Enum.Font.SourceSansBold
                Button.TextSize = 30
                Button.Parent = FloatingButton

                Button.MouseButton1Click:Connect(function()
                    config.aimAssistEnabled = not config.aimAssistEnabled
                    Button.Text = config.aimAssistEnabled and "✅" or "⚫"
                end)

                local UserInputService = game:GetService("UserInputService")
                local dragging, dragInput, dragStart, startPos

                FloatingButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = FloatingButton.Position
                        input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragging = false
                            end
                        end)
                    end
                end)

                FloatingButton.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        dragInput = input
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input == dragInput then
                        local delta = input.Position - dragStart
                        FloatingButton.Position = UDim2.new(
                            startPos.X.Scale, startPos.X.Offset + delta.X,
                            startPos.Y.Scale, startPos.Y.Offset + delta.Y
                        )
                    end
                end)
            end
        else
            if FloatingButton then
                FloatingButton.Parent:Destroy()
                FloatingButton = nil
            end
        end
    end
})


-- Configurações Principais do AimAssist
AimAssistTab:CreateSlider({
    Name = "Força do Aimbot",
    Range = {0, 1},
    Increment = 0.01,
    Suffix = "",
    CurrentValue = config.aimbotStrength,
    Flag = "AimbotStrength",
    Callback = function(Value)
        config.aimbotStrength = Value
    end
})

AimAssistTab:CreateSlider({
    Name = "Alcance do Aimbot",
    Range = {0, 2000},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = config.aimbotRange,
    Flag = "AimbotRange",
    Callback = function(Value)
        config.aimbotRange = Value
    end
})

AimAssistTab:CreateSlider({
    Name = "Distância para Puxar Cabeça",
    Range = {0, 2000},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = config.headPullDistance,
    Flag = "HeadPullDistance",
    Callback = function(Value)
        config.headPullDistance = Value
    end
})

-- Configurações de FOV
AimAssistTab:CreateSlider({
    Name = "Tamanho do FOV",
    Range = {0, 360},
    Increment = 1,
    Suffix = "°",
    CurrentValue = config.fovSize,
    Flag = "FOVSize",
    Callback = function(Value)
        config.fovSize = Value
    end
})

AimAssistTab:CreateToggle({
    Name = "Exibir Círculo de FOV",
    CurrentValue = config.showFov,
    Flag = "ShowFOV",
    Callback = function(Value)
        config.showFov = Value
    end
})

-- Filtros de Alvo
AimAssistTab:CreateToggle({
    Name = "Ignorar Paredes",
    CurrentValue = config.ignoreWalls,
    Flag = "IgnoreWalls",
    Callback = function(Value)
        config.ignoreWalls = Value
    end
})

AimAssistTab:CreateToggle({
    Name = "Verificar Time",
    CurrentValue = config.teamCheck,
    Flag = "TeamCheck",
    Callback = function(Value)
        config.teamCheck = Value
    end
})


-- ### Aba Outros ###
-- Módulo de Armas
local WeaponModule = {}
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local weapon
local debugMode = true
local running = false
local characterAddedConnection

local printCount = 0 -- contador de prints

local function clearConsole()
    -- Comando para limpar console (em Roblox geralmente não tem um "clear" direto)
    -- Podemos usar repetidos prints vazios para simular limpeza
    for i = 1, 30 do
        print("")
    end
    print("[DEBUG] Console limpo após 100 prints")
end

local function log(msg)
    if debugMode then 
        print("[DEBUG] " .. msg) 
        printCount = printCount + 1
        if printCount >= 100 then
            clearConsole()
            printCount = 0
        end
    end
end

local function trySetValue(obj, value)
    pcall(function()
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            obj.Value = value
        elseif obj:IsA("BoolValue") then
            obj.Value = value ~= 0
        elseif obj:IsA("StringValue") and tonumber(obj.Value) then
            obj.Value = tostring(value)
        end
    end)
end

local function enforceWeaponProperties(weapon, desiredProperties)
    for property, value in pairs(desiredProperties) do
        local propObj = weapon:FindFirstChild(property)
        if propObj and propObj.Value ~= value then
            log("Reaplicando " .. property .. " (" .. tostring(propObj.Value) .. " -> " .. tostring(value) .. ")")
            trySetValue(propObj, value)
        end
    end
end

local function autoReloadWeapon(weapon)
    local ammo = weapon:FindFirstChild("Ammo")
    local clipSizeObj = weapon:FindFirstChild("ClipSize")
    if ammo and clipSizeObj and ammo.Value <= 0 then
        log("Reloading " .. weapon.Name)
        ammo.Value = clipSizeObj.Value
    end
end

local function locateAndConfigureWeapon()
    if not running then return end
    weapon = character:FindFirstChildOfClass("Tool")
    if weapon then
        log("Arma detectada: " .. weapon.Name)
        local keywords = {"cooldown", "delay", "reload", "interval", "fire", "clip", "reserve", "heat", "magazine", "charge", "recall", "recoil", "kickback"}
        for _, desc in ipairs(weapon:GetDescendants()) do
            for _, keyword in ipairs(keywords) do
                if desc.Name:lower():find(keyword) then
                    log("Ajustando: " .. desc.Name)
                    trySetValue(desc, 0)
                end
            end
        end

        local weaponType = weapon.Name:lower()
        local knownProperties = weaponType:find("pistol") and {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
            or weaponType:find("rifle") and {FireRate = 12000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
            or weaponType:find("shotgun") and {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 50, Recoil = 0, Kickback = 0}
            or weaponType:find("smg") and {FireRate = 15000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
            or weaponType:find("sniper") and {FireRate = 6000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 20, Recoil = 0, Kickback = 0}
            or weaponType:find("machinegun") and {FireRate = 14000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
            or weaponType:find("bazooka") and {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0}
            or weaponType:find("crossbow") and {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0}
            or weaponType:find("grenadelauncher") and {FireRate = 15000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 9999, Recoil = 0, Kickback = 0}
            or weaponType:find("laser") and {FireRate = 11000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
            or weaponType:find("flamethrower") and {FireRate = 12000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 2000, Recoil = 0, Kickback = 0}
            or weaponType:find("minigun") and {FireRate = 16000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 2000, Recoil = 0, Kickback = 0}
            or weaponType:find("rocketlauncher") and {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0}
            or weaponType:find("dartgun") and {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 50, Recoil = 0, Kickback = 0}
            or weaponType:find("chaingun") and {FireRate = 14000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
            or {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 9999, Recoil = 0, Kickback = 0}

        for property, value in pairs(knownProperties) do
            if weapon:FindFirstChild(property) then
                log("Configurando " .. property .. " para " .. tostring(value))
                trySetValue(weapon[property], value)
            end
        end

        if not weapon:FindFirstChild("EnforceLoop") then
            local enforceLoop = Instance.new("BoolValue")
            enforceLoop.Name = "EnforceLoop"
            enforceLoop.Parent = weapon
            spawn(function()
                while weapon and weapon.Parent and running do
                    enforceWeaponProperties(weapon, knownProperties)
                    autoReloadWeapon(weapon)
                    task.wait(0.001)
                end
            end)
        end
    else
        --log("") -- removido log vazio
    end
end

local function setupCharacter()
    if not running then return end
    character = player.Character or player.CharacterAdded:Wait()
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then locateAndConfigureWeapon() end
    end)
    locateAndConfigureWeapon()
end

function WeaponModule.Enable()
    if running then return end
    running = true
    if not characterAddedConnection then
        characterAddedConnection = player.CharacterAdded:Connect(setupCharacter)
    end
    setupCharacter()
    log("WeaponModule ativado")
end

function WeaponModule.Disable()
    running = false
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
        characterAddedConnection = nil
    end
    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("EnforceLoop") then
                tool:FindFirstChild("EnforceLoop"):Destroy()
            end
        end
    end
    log("WeaponModule desativado")
end

OthersTab:CreateToggle({
    Name = "Ativar Módulo de Armas",
    CurrentValue = false,
    Flag = "WeaponModuleToggle",
    Callback = function(Value)
        if Value then WeaponModule.Enable() else WeaponModule.Disable() end
    end
})
-- ### Validação de Alvo ###
-- ### Verifica se o alvo é válido ###
local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return false end
    if player.Character.Humanoid.Health <= 0 then return false end
    if config.teamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then
        return false
    end
    return true
end

-- ### Verifica se a parte está visível ###
local function isPartVisible(part, origin)
    if config.ignoreWalls then return true end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(origin.Position, part.Position - origin.Position, rayParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

-- ### Retorna a melhor parte para mirar respeitando aimbotRange e visibilidade ###
local function getBestVisiblePartPosition(target)
    local character = target.Character
    if not character then return nil end

    local origin = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    if not origin then return nil end

    local head = character:FindFirstChild("Head")
    local localHRP = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localHRP then return nil end

    local bestPart = nil
    local bestDist = math.huge

    local function tryPart(part, preferHead)
        if not part then return end
        local dist = (part.Position - localHRP.Position).Magnitude
        if dist <= config.aimbotRange and isPartVisible(part, origin) then
            local priority = preferHead and 0 or 1
            if dist < bestDist or priority < (bestPart and bestPart.priority or 1) then
                bestPart = { pos = part.Position, priority = priority, dist = dist }
            end
        end
    end

    tryPart(head, (head and (head.Position - localHRP.Position).Magnitude <= config.headPullDistance))

    local partsToCheck = {
        "UpperTorso", "LowerTorso",
        "RightUpperArm", "LeftUpperArm",
        "RightLowerArm", "LeftLowerArm",
        "RightHand", "LeftHand"
    }

    for _, name in ipairs(partsToCheck) do
        tryPart(character:FindFirstChild(name), false)
    end

    return bestPart and bestPart.pos or nil
end

-- ### Busca o melhor alvo ###
local function getClosestTarget()
    local closestPlayer = nil
    local closestDist = config.aimbotRange
    local localCharacter = LocalPlayer.Character
    local hrp = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera
    if not hrp or not camera then return nil end

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local aimPos = getBestVisiblePartPosition(player)
            if aimPos then
                local dist = (aimPos - hrp.Position).Magnitude
                if dist < closestDist then
                    local dir = (aimPos - camera.CFrame.Position).Unit
                    local dot = dir:Dot(camera.CFrame.LookVector)
                    local fovThreshold = math.cos(math.rad(config.fovSize / 2))
                    if dot >= fovThreshold then
                        closestDist = dist
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- ### FOV Circle ###
local fovCircle
if Drawing and Drawing.new then
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 0, 0)
    fovCircle.Thickness = 2
    fovCircle.Transparency = 1
    fovCircle.Visible = false
end

-- ### Loop Principal ###
RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return end

    if config.aimAssistEnabled then
        local target = getClosestTarget()
        if target then
            local aimPos = getBestVisiblePartPosition(target)
            if aimPos then
                local cf = CFrame.new(camera.CFrame.Position, aimPos)
                camera.CFrame = camera.CFrame:Lerp(cf, config.aimbotStrength)
            end
        end
    end

    if fovCircle and config.showFov then
        local viewport = camera.ViewportSize
        local fovRadians = math.rad(config.fovSize / 2)
        local dist = (viewport.Y / 2) / math.tan(math.rad(camera.FieldOfView / 2))
        fovCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        fovCircle.Radius = dist * math.tan(fovRadians)
        fovCircle.Visible = true
    elseif fovCircle then
        fovCircle.Visible = false
    end
end)

-- ### Funções de ESP ###
-----------------------------------------------------------
-- SERVIÇOS & VARIÁVEIS GLOBAIS
-----------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local playerConnections = {}
local infoESPData = {}

local config = config or {}
config.visualizarPlayers = config.visualizarPlayers or false
config.visualizarInfo = config.visualizarInfo or false

-----------------------------------------------------------
-- CHAMS (Highlight)
-----------------------------------------------------------
local function applyChams(player)
    if not config.visualizarPlayers then return end
    if player == LocalPlayer or not player.Character then return end

    local character = player.Character
    local oldHighlight = character:FindFirstChild("ChamsHighlight")
    if oldHighlight then oldHighlight:Destroy() end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ChamsHighlight"
    highlight.Adornee = character
    highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    local teamConn = player:GetPropertyChangedSignal("Team"):Connect(function()
        if highlight and highlight.Parent then
            highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
        end
    end)

    highlight.Destroying:Connect(function()
        if teamConn then teamConn:Disconnect() end
    end)

    playerConnections[player] = playerConnections[player] or {}
    if playerConnections[player].Team then
        playerConnections[player].Team:Disconnect()
    end
    playerConnections[player].Team = teamConn
end

-----------------------------------------------------------
-- INFO ESP: Nome, Distância, Inventário + Imagem
-----------------------------------------------------------
local function removeInfoESP(player)
    if infoESPData[player] then
        if infoESPData[player].conn then infoESPData[player].conn:Disconnect() end
        if infoESPData[player].gui then infoESPData[player].gui:Destroy() end
        infoESPData[player] = nil
    end
end

local function applyInfoESP(player)
    if not config.visualizarInfo then return end
    if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild("Head") then return end

    removeInfoESP(player)

    local head = player.Character.Head
    local gui = Instance.new("BillboardGui")
    gui.Name = "InfoESP"
    gui.Size = UDim2.new(0, 200, 0, 120)
    gui.StudsOffset = Vector3.new(0, 2.8, 0)
    gui.AlwaysOnTop = true
    gui.Adornee = head
    gui.Parent = head

    local container = Instance.new("Frame", gui)
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 1, 0)

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 0, 35)
    text.Position = UDim2.new(0, 0, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0.3
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.Parent = container

    local img = Instance.new("ImageLabel")
    img.Size = UDim2.new(0, 32, 0, 32)
    img.Position = UDim2.new(1, -36, 0, 3)
    img.BackgroundTransparency = 1
    img.Visible = false -- Esconde, não vamos usar
    img.Parent = container

    local invText = Instance.new("TextLabel")
    invText.Size = UDim2.new(1, -8, 1, -40)
    invText.Position = UDim2.new(0, 4, 0, 38)
    invText.BackgroundTransparency = 1
    invText.TextColor3 = Color3.fromRGB(160, 255, 180)
    invText.TextStrokeColor3 = Color3.new(0, 0, 0)
    invText.TextStrokeTransparency = 0.6
    invText.Font = Enum.Font.Code
    invText.TextWrapped = true
    invText.TextYAlignment = Enum.TextYAlignment.Top
    invText.TextXAlignment = Enum.TextXAlignment.Left
    invText.TextScaled = false
    invText.TextSize = 12
    invText.Parent = container

local conn = RunService.RenderStepped:Connect(function()
    if not player.Character then
        removeInfoESP(player)
        return
    end

    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not localHrp then
        removeInfoESP(player)
        return
    end

    local dist = (hrp.Position - localHrp.Position).Magnitude
    text.Text = string.format("👤 %s | 📏 %.0f", player.Name, dist)

        local inventory = {}

        -- Itens na mochila
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(inventory, "• " .. tool.Name)
            end
        end

        -- Itens usando (personagem)
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(inventory, "👉 " .. tool.Name .. " [Usando]")
            end
        end

        invText.Text = #inventory > 0 and table.concat(inventory, "\n") or "🔒 Inventário vazio"
        img.Visible = false -- mantém invisível
    end)

    infoESPData[player] = {
        gui = gui,
        conn = conn
    }
end

-----------------------------------------------------------
-- MONITORAMENTO GERAL
-----------------------------------------------------------
local function monitorPlayer(player)
    if playerConnections[player] then
        for _, conn in pairs(playerConnections[player]) do
            if conn and typeof(conn.Disconnect) == "function" then
                conn:Disconnect()
            end
        end
    end
    removeInfoESP(player)

    local charConn = player.CharacterAdded:Connect(function()
        task.wait(0.3)
        if config.visualizarPlayers then applyChams(player) end
        if config.visualizarInfo then applyInfoESP(player) end
    end)

    if player.Character then
        if config.visualizarPlayers then applyChams(player) end
        if config.visualizarInfo then applyInfoESP(player) end
    end

    playerConnections[player] = playerConnections[player] or {}
    playerConnections[player].Character = charConn
end

local function unmonitorPlayer(player)
    if playerConnections[player] then
        for _, conn in pairs(playerConnections[player]) do
            if conn and typeof(conn.Disconnect) == "function" then
                conn:Disconnect()
            end
        end
        playerConnections[player] = nil
    end
    removeInfoESP(player)
    if player.Character then
        local cham = player.Character:FindFirstChild("ChamsHighlight")
        if cham then cham:Destroy() end
    end
end

-----------------------------------------------------------
-- INICIALIZAÇÃO DE MONITORAMENTO EXISTENTE
-----------------------------------------------------------
Players.PlayerAdded:Connect(function(p)
    if config.visualizarPlayers or config.visualizarInfo then
        monitorPlayer(p)
    end
end)

Players.PlayerRemoving:Connect(unmonitorPlayer)

for _, p in ipairs(Players:GetPlayers()) do
    if config.visualizarPlayers or config.visualizarInfo then
        monitorPlayer(p)
    end
end

-- ### Aba ESP ###
-- Toggle Principal do ESP
ESPTab:CreateToggle({
    Name = "Visualizar Players (Chams)",
    CurrentValue = config.visualizarPlayers,
    Flag = "VisualizarPlayers",
    Callback = function(Value)
        config.visualizarPlayers = Value
        for _, p in ipairs(Players:GetPlayers()) do
            if Value then monitorPlayer(p) else unmonitorPlayer(p) end
        end
    end,
})

ESPTab:CreateToggle({
    Name = "Visualizar Nome, Distância e Itens",
    CurrentValue = config.visualizarInfo,
    Flag = "VisualizarInfo",
    Callback = function(Value)
        config.visualizarInfo = Value
        for _, p in ipairs(Players:GetPlayers()) do
            if Value then applyInfoESP(p) else removeInfoESP(p) end
        end
    end,
})

ESPTab:CreateButton({
    Name = "Refresh Chams",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if config.visualizarPlayers then applyChams(p) end
        end
    end,
})
-----------------------------------------------------------
-- UI: Toggles & Botão
-----------------------------------------------------------
Players.PlayerAdded:Connect(function(p)
    if config.visualizarPlayers or config.visualizarInfo then
        monitorPlayer(p)
    end
end)

Players.PlayerRemoving:Connect(unmonitorPlayer)

for _, p in ipairs(Players:GetPlayers()) do
    if config.visualizarPlayers or config.visualizarInfo then
        monitorPlayer(p)
    end
end

-- Mensagem de Confirmação
print("Tekscripts: AimAssist e ESP carregados com sucesso!")