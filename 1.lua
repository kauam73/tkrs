
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
    if not config.visualizarPlayers or player == LocalPlayer or not player.Character then return end

    local character = player.Character
    local oldHighlight = character:FindFirstChild("ChamsHighlight")
    if oldHighlight then oldHighlight:Destroy() end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ChamsHighlight"
    highlight.Adornee = character
    highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    local teamConn
    teamConn = player:GetPropertyChangedSignal("Team"):Connect(function()
        if highlight and highlight.Parent then
            highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        else
            teamConn:Disconnect()
        end
    end)

    playerConnections[player] = playerConnections[player] or {}
    if playerConnections[player].Team then playerConnections[player].Team:Disconnect() end
    playerConnections[player].Team = teamConn
end

local function removeChams(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("ChamsHighlight")
        if highlight then highlight:Destroy() end
    end
    if playerConnections[player] and playerConnections[player].Team then
        playerConnections[player].Team:Disconnect()
        playerConnections[player].Team = nil
    end
end

-----------------------------------------------------------
-- INFO ESP: Nome, Distância, Inventário, Vida (GUI adaptativa)
-----------------------------------------------------------
--// Remover ESP de Info de um jogador
local function removeInfoESP(player)
    if infoESPData[player] then
        if infoESPData[player].conn then infoESPData[player].conn:Disconnect() end
        if infoESPData[player].gui then infoESPData[player].gui:Destroy() end
        infoESPData[player] = nil
    end
end

--// Aplicar ESP de Info em um jogador
local function applyInfoESP(player)
    if not config.visualizarInfo or player == LocalPlayer or not player.Character then
        removeInfoESP(player)
        return
    end

    local head = player.Character:FindFirstChild("Head")
    if not head then return end

    removeInfoESP(player)

    local gui = Instance.new("BillboardGui")
    gui.Name = "InfoESP"
    gui.Adornee = head
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.Parent = head

    local container = Instance.new("Frame")
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BackgroundTransparency = 0.7
    container.BorderSizePixel = 1
    container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    container.Position = UDim2.new(0, 2, 0, 2)
    container.Parent = gui

    local uicorner = Instance.new("UICorner", container)
    uicorner.CornerRadius = UDim.new(0, 6)

    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, -8, 0, 20)
    header.Position = UDim2.new(0, 4, 0, 4)
    header.BackgroundTransparency = 1
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    header.TextStrokeTransparency = 0.4
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = container

    local inventoryText = Instance.new("TextLabel")
    inventoryText.Size = UDim2.new(1, -8, 1, -28)
    inventoryText.Position = UDim2.new(0, 4, 0, 24)
    inventoryText.BackgroundTransparency = 1
    inventoryText.TextColor3 = Color3.fromRGB(180, 255, 200)
    inventoryText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    inventoryText.TextStrokeTransparency = 0.6
    inventoryText.Font = Enum.Font.Code
    inventoryText.TextWrapped = true
    inventoryText.TextYAlignment = Enum.TextYAlignment.Top
    inventoryText.TextXAlignment = Enum.TextXAlignment.Left
    inventoryText.TextSize = 10
    inventoryText.Parent = container

    local conn
    conn = RunService.Heartbeat:Connect(function()
        -- Se o personagem não estiver completo, apenas pausamos a atualização
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return
        end

        local hrp = player.Character.HumanoidRootPart
        local localHrp = LocalPlayer.Character.HumanoidRootPart
        local dist = (hrp.Position - localHrp.Position).Magnitude

        -- Obter vida do Humanoid
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local healthText = "❤️ N/A"
        if humanoid then
            healthText = string.format("\n❤️ %.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
        end

        -- Atualizar cabeçalho com nome, distância e vida
        header.Text = string.format("👤 %s | 📏 %.1f | %s", player.Name, dist, healthText)

        local inventory = {}
        for _, tool in ipairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(inventory, "• " .. tool.Name)
            end
        end
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(inventory, "\n👉 " .. tool.Name .. " [Equipped]")
            end
        end

        inventoryText.Text = (#inventory == 0) and "🔒 Empty Inventory" or table.concat(inventory, "\n")

        -- Ajusta dinamicamente a altura da GUI
        local lines = 1 + #inventory
        local heightPx = 28 + (lines * 14)
        container.Size = UDim2.new(1, -4, 0, heightPx)
        gui.Size = UDim2.new(0, 180, 0, heightPx + 4)
    end)

    infoESPData[player] = {
        gui = gui,
        conn = conn
    }
end

-----------------------------------------------------------
-- MONITORAMENTO DE JOGADORES
-----------------------------------------------------------
local function monitorPlayer(player)
    if player == LocalPlayer then return end

    playerConnections[player] = playerConnections[player] or {}
    if playerConnections[player].Character then
        playerConnections[player].Character:Disconnect()
    end

    local charConn
    charConn = player.CharacterAdded:Connect(function(character)
        task.spawn(function()
            local head = character:WaitForChild("Head", 5)
            local hrp = character:WaitForChild("HumanoidRootPart", 5)

            if not head or not hrp then
                task.wait(1)
                head = character:FindFirstChild("Head")
                hrp = character:FindFirstChild("HumanoidRootPart")
            end

            if head and hrp then
                if config.visualizarPlayers then applyChams(player) end
                if config.visualizarInfo then applyInfoESP(player) end
            end
        end)
    end)

    playerConnections[player].Character = charConn

    -- Caso já esteja com personagem ativo
    if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
        if config.visualizarPlayers then applyChams(player) end
        if config.visualizarInfo then applyInfoESP(player) end
    end
end

local function unmonitorPlayer(player)
    -- ⚠️ Não apagar GUIs se for o LocalPlayer
    if player == LocalPlayer then return end

    if playerConnections[player] then
        for _, conn in pairs(playerConnections[player]) do
            if conn then conn:Disconnect() end
        end
        playerConnections[player] = nil
    end

    removeInfoESP(player)
    removeChams(player)
end

-----------------------------------------------------------
-- INICIALIZAÇÃO
-----------------------------------------------------------
Players.PlayerAdded:Connect(function(player)
    monitorPlayer(player)
end)

Players.PlayerRemoving:Connect(unmonitorPlayer)

for _, player in ipairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

-----------------------------------------------------------
-- UI: TOGGLES & BOTÃO (exemplo)
-----------------------------------------------------------
-- ESPTab deve existir e ter CreateToggle e CreateButton métodos
-- Adapte para seu framework de UI

ESPTab:CreateToggle({
    Name = "Visualizar Players (Chams)",
    CurrentValue = config.visualizarPlayers,
    Flag = "VisualizarPlayers",
    Callback = function(Value)
        config.visualizarPlayers = Value
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if Value then
                applyChams(player)
            else
                removeChams(player)
            end
        end
    end,
})

ESPTab:CreateToggle({
    Name = "Visualizar Nome, Distância e Itens",
    CurrentValue = config.visualizarInfo,
    Flag = "VisualizarInfo",
    Callback = function(Value)
        config.visualizarInfo = Value
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if Value then
                applyInfoESP(player)
            else
                removeInfoESP(player)
            end
        end
    end,
})

ESPTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            removeChams(player)
            removeInfoESP(player)
            if config.visualizarPlayers then applyChams(player) end
            if config.visualizarInfo then applyInfoESP(player) end
        end
    end,
})

-- Mensagem de Confirmação
print("Tekscripts: AimAssist e ESP carregados com sucesso!")