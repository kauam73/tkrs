-----------------------------------------------------------
-- Carregamento da Biblioteca Rayfield
-----------------------------------------------------------
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-----------------------------------------------------------
-- Serviços e variáveis iniciais
-----------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local FloatingButton

-----------------------------------------------------------
-- Tabela de Configurações Personalizáveis
-----------------------------------------------------------
local config = {
    headPullDistance = 60,      -- Distância para puxar a cabeça do alvo
    aimbotRange = 1000,          -- Alcance máximo do aimbot
    fovSize = 60,               -- Tamanho do FOV (campo de visão) em graus
    showFov = false,            -- Exibir círculo do FOV
    ignoreWalls = false,        -- Ignorar obstáculos (walls) via raycast
    teamCheck = true,           -- Desconsiderar alvos do mesmo time
    aimAssistEnabled = false,   -- Ativar/desativar o AimAssist
    visualizarPlayers = false,  -- Ativar/desativar o ESP dos jogadores
}

-----------------------------------------------------------
-- Criação da Janela Principal com Rayfield
-----------------------------------------------------------
local Window = Rayfield:CreateWindow({
    Name = "Tekscripts",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TekscriptsConfig", -- Pasta para salvar as configurações
        FileName = "PainelConfig"
    }
})

-----------------------------------------------------------
-- Criação das Abas (Categorias)
-----------------------------------------------------------
local AimAssistTab = Window:CreateTab("AimAssist", nil)
local ESPTab = Window:CreateTab("ESP", nil)

-----------------------------------------------------------
-- Aba: AimAssist – Elementos de Configuração
-----------------------------------------------------------
AimAssistTab:CreateSlider({
    Name = "Head Pull Distance",
    Range = {0, 2000},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = config.headPullDistance,
    Flag = "HeadPullDistance", -- Flag única para salvar as configurações
    Callback = function(Value)
        config.headPullDistance = Value
    end,
})

AimAssistTab:CreateSlider({
    Name = "Aimbot Range",
    Range = {0, 2000},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = config.aimbotRange,
    Flag = "AimbotRange",
    Callback = function(Value)
        config.aimbotRange = Value
    end,
})

AimAssistTab:CreateSlider({
    Name = "FOV Size",
    Range = {0, 180},
    Increment = 1,
    Suffix = "°",
    CurrentValue = config.fovSize,
    Flag = "FOVSize",
    Callback = function(Value)
        config.fovSize = Value
    end,
})

AimAssistTab:CreateToggle({
    Name = "Show FOV (Desenhar Círculo)",
    CurrentValue = config.showFov,
    Flag = "ShowFOV",
    Callback = function(Value)
        config.showFov = Value
    end,
})

AimAssistTab:CreateToggle({
    Name = "Ignore Walls",
    CurrentValue = config.ignoreWalls,
    Flag = "IgnoreWalls",
    Callback = function(Value)
        config.ignoreWalls = Value
    end,
})

AimAssistTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = config.teamCheck,
    Flag = "TeamCheck",
    Callback = function(Value)
        config.teamCheck = Value
    end,
})

AimAssistTab:CreateToggle({
    Name = "AimAssist Enabled",
    CurrentValue = config.aimAssistEnabled,
    Flag = "AimAssistEnabled",
    Callback = function(Value)
        config.aimAssistEnabled = Value
    end,
})

FloatingButton = FloatingButton or nil

AimAssistTab:CreateToggle({
    Name = "modo rápido button aimbot",
    Callback = function()
        if FloatingButton then
            -- Se o botão já existir, destrói-o e encerra a função
            FloatingButton.Parent:Destroy()
            FloatingButton = nil
            return
        end

        -- Cria um ScreenGui para conter o botão
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FloatingAimbotGUI"
        screenGui.Parent = game:GetService("CoreGui")  -- Use CoreGui se necessário

        -- Cria o frame que servirá de fundo para o botão
        FloatingButton = Instance.new("Frame")
        FloatingButton.Size = UDim2.new(0, 80, 0, 80)
        -- Posiciona o botão na parte superior central da tela (ajuste o offset Y conforme necessário)
        FloatingButton.Position = UDim2.new(0.5, -40, 0, 20)
        FloatingButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        FloatingButton.BackgroundTransparency = 0.3
        FloatingButton.BorderSizePixel = 0
        FloatingButton.Parent = screenGui

        -- Adiciona cantos arredondados (mais arredondado)
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0.5, 0)  -- Ajuste para deixar o botão bem arredondado
        uiCorner.Parent = FloatingButton

        -- Cria o botão que efetua o toggle do AimAssist
        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, 0, 1, 0)
        Button.BackgroundTransparency = 1
        Button.Text = config.aimAssistEnabled and "✅" or "⚫"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.SourceSansBold
        Button.TextSize = 30
        Button.Parent = FloatingButton

        -- Ao clicar no botão, inverte o estado do AimAssist
        Button.MouseButton1Click:Connect(function()
            config.aimAssistEnabled = not config.aimAssistEnabled
            Button.Text = config.aimAssistEnabled and "✅" or "⚫"
        end)

        -- Função para permitir o arraste do botão usando dedos ou mouse
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
    end,
})

-----------------------------------------------------------
-- Aba: ESP – Elementos de Configuração
-----------------------------------------------------------
ESPTab:CreateToggle({
    Name = "Visualizar Players (Chams)",
    CurrentValue = config.visualizarPlayers,
    Flag = "VisualizarPlayers",
    Callback = function(Value)
        config.visualizarPlayers = Value
        if not Value then
            -- Remove Chams existente de todos os jogadores
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("ChamsHighlight")
                    if highlight then
                        highlight:Destroy()
                    end
                end
            end
        else
            -- Reaplica o Chams para todos os jogadores
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character then
                    applyChams(player)
                end
            end
        end
    end,
})

ESPTab:CreateButton({
    Name = "Refresh Chams",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                -- Remove qualquer efeito existente antes de reaplicar
                local highlight = player.Character:FindFirstChild("ChamsHighlight")
                if highlight then
                    highlight:Destroy()
                end
                applyChams(player)
            end
        end
    end,
})

-----------------------------------------------------------
-- Funções de AimAssist
-----------------------------------------------------------
local function isValidTarget(player)  
    if player == LocalPlayer then return false end  
    if not player.Character or not player.Character:FindFirstChild("Humanoid") then return false end  
    if player.Character.Humanoid.Health <= 0 then return false end  
    if config.teamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then  
        return false  
    end  
    return true  
end  
  
local function isVisible(target)  
    if config.ignoreWalls then  
        return true  
    end  
    local localCharacter = LocalPlayer.Character  
    local targetCharacter = target.Character  
    if not localCharacter or not targetCharacter then return false end  
  
    local localHRP = localCharacter:FindFirstChild("HumanoidRootPart")  
    local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")  
    if not localHRP or not targetHRP then return false end  
  
    local direction = (targetHRP.Position - localHRP.Position).Unit  
    local forward = localCharacter.HumanoidRootPart.CFrame.LookVector  
    local dot = direction:Dot(forward)  
    if dot < 0.5 then  
        return false  
    end  
  
    local threshold = math.cos(math.rad(config.fovSize / 2))  
    if dot < threshold then  
        return false  
    end  
  
    local rayParams = RaycastParams.new()  
    rayParams.FilterDescendantsInstances = {localCharacter}  
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist  
    local rayResult = Workspace:Raycast(localHRP.Position, (targetHRP.Position - localHRP.Position), rayParams)  
    if rayResult and not rayResult.Instance:IsDescendantOf(targetCharacter) then  
        return false  
    end  
  
    return true  
end  
  
local function getClosestTarget()  
    local closest = nil  
    local closestDistance = config.aimbotRange  
    local localCharacter = LocalPlayer.Character  
    if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return nil end  
    local localPos = localCharacter.HumanoidRootPart.Position  
  
    for _, player in ipairs(Players:GetPlayers()) do  
        if isValidTarget(player) then  
            local character = player.Character  
            if character and character:FindFirstChild("HumanoidRootPart") then  
                local distance = (character.HumanoidRootPart.Position - localPos).Magnitude  
                if distance < closestDistance and isVisible(player) then  
                    closestDistance = distance  
                    closest = player  
                end  
            end  
        end  
    end  
  
    return closest  
end  
  
local function getTargetPosition(target)  
    if target and target.Character then  
        local head = target.Character:FindFirstChild("Head")  
        local hrp = target.Character:FindFirstChild("HumanoidRootPart")  
        if head and hrp then  
            local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")  
            if localHRP then  
                local distance = (head.Position - localHRP.Position).Magnitude  
                if distance <= config.headPullDistance then  
                    return head.Position  
                end  
            end  
            return hrp.Position  
        end  
    end  
    return nil  
end

-----------------------------------------------------------
-- Função para desenhar o círculo de FOV (se Drawing API estiver disponível)
-----------------------------------------------------------
local fovCircle
if Drawing and Drawing.new then
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 0, 0)
    fovCircle.Thickness = 2
    fovCircle.Transparency = 1
    fovCircle.Visible = false
end


----------------------------------------------------------
-- SPAM BALAS FUNCTIONS
------------------------------------------------------------
-- WeaponModule

local WeaponModule = {}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local weapon
local debugMode = true
local running = false

-- Variável para armazenar a conexão do CharacterAdded e poder desconectá-la ao desativar
local characterAddedConnection = nil

-- Log simples
local function log(msg)
    if debugMode then
        print("[DEBUG] " .. msg)
    end
end

-- Define valor de forma segura
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

-- Força persistência dos valores
local function enforceWeaponProperties(weapon, desiredProperties)
    for property, value in pairs(desiredProperties) do
        local propObj = weapon:FindFirstChild(property)
        if propObj and propObj.Value ~= value then
            log("Reaplicando " .. property .. " (" .. tostring(propObj.Value) .. " -> " .. tostring(value) .. ")")
            trySetValue(propObj, value)
        end
    end
end

-- Autoreload da arma
local function autoReloadWeapon(weapon)
    local ammo = weapon:FindFirstChild("Ammo")
    local clipSizeObj = weapon:FindFirstChild("ClipSize")
    if ammo and clipSizeObj and ammo.Value <= 0 then
        log("Reloading " .. weapon.Name)
        ammo.Value = clipSizeObj.Value
    end
end

-- Detecta e configura a arma
local function locateAndConfigureWeapon()
    if not running then
        -- Se o módulo não estiver ativo, não faz nada
        return
    end

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
        local knownProperties = {}

        if weaponType:find("pistol") then    
            knownProperties = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
        elseif weaponType:find("rifle") then    
            knownProperties = {FireRate = 12000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
        elseif weaponType:find("shotgun") then    
            knownProperties = {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 50, Recoil = 0, Kickback = 0}
        elseif weaponType:find("smg") then    
            knownProperties = {FireRate = 15000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
        elseif weaponType:find("sniper") then    
            knownProperties = {FireRate = 6000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 20, Recoil = 0, Kickback = 0}
        elseif weaponType:find("machinegun") then    
            knownProperties = {FireRate = 14000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
        elseif weaponType:find("bazooka") then    
            knownProperties = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0}
        elseif weaponType:find("crossbow") then    
            knownProperties = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0}
        elseif weaponType:find("grenadelauncher") then    
            knownProperties = {FireRate = 15000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 9999, Recoil = 0, Kickback = 0}
        elseif weaponType:find("laser") then    
            knownProperties = {FireRate = 11000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
        elseif weaponType:find("flamethrower") then    
            knownProperties = {FireRate = 12000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 2000, Recoil = 0, Kickback = 0}
        elseif weaponType:find("minigun") then    
            knownProperties = {FireRate = 16000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 2000, Recoil = 0, Kickback = 0}
        elseif weaponType:find("rocketlauncher") then    
            knownProperties = {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0}
        elseif weaponType:find("dartgun") then    
            knownProperties = {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 50, Recoil = 0, Kickback = 0}
        elseif weaponType:find("chaingun") then    
            knownProperties = {FireRate = 14000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0}
        else    
            knownProperties = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 9999, Recoil = 0, Kickback = 0}
        end    

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
                    wait(0.001)
                end
            end)
        end    
    else    
        log("Nenhuma arma encontrada.")
    end    
end

-- Detecta novas ferramentas no personagem
local function setupCharacter()
    if not running then
        return
    end
    character = player.Character or player.CharacterAdded:Wait()
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            locateAndConfigureWeapon()
        end
    end)
    locateAndConfigureWeapon()
end

-- Ativa o módulo
function WeaponModule.Enable()
    if running then
        -- Já está ativo, nada a fazer
        return
    end
    running = true
    if not characterAddedConnection then
        characterAddedConnection = player.CharacterAdded:Connect(setupCharacter)
    end
    setupCharacter()
    log("WeaponModule ativado")
end

-- Desativa o módulo
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

-- Toggle para ativar/desativar o WeaponModule
AimAssistTab:CreateToggle({
    Name = "Ativar Módulo de Armas",
    CurrentValue = false,
    Flag = "WeaponModuleToggle",
    Callback = function(Value)
        if Value then
            WeaponModule.Enable()
        else
            WeaponModule.Disable()
        end
    end,
})
-----------------------------------------------------------
-- Funções de ESP
-----------------------------------------------------------
local function applyChams(player)
    if not config.visualizarPlayers then return end
    if player == LocalPlayer then return end  -- Não aplicar no jogador local
    if not player.Character then return end
    
    local character = player.Character

    -- Remove qualquer Highlight existente
    local existingHighlight = character:FindFirstChild("ChamsHighlight")
    if existingHighlight then
        existingHighlight:Destroy()
    end
    
    -- Cria o Highlight para o efeito "chams"
    local highlight = Instance.new("Highlight")
    highlight.Name = "ChamsHighlight"
    highlight.Adornee = character
    highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.FillTransparency = 0.5  -- Ajuste conforme necessário
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    -- Atualiza a cor caso o time do jogador mude
    local teamConnection = player:GetPropertyChangedSignal("Team"):Connect(function()
        highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.new(1, 1, 1)
    end)

    -- Garante que a conexão seja desconectada ao destruir o highlight
    highlight.Destroying:Connect(function()
        teamConnection:Disconnect()
    end)
end

local function monitorPlayer(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        applyChams(player)
    end)
    if player.Character then
        applyChams(player)
    end
end

-- Monitora os jogadores já existentes
for _, player in ipairs(Players:GetPlayers()) do
    monitorPlayer(player)
end

-- Monitora jogadores que entrarem no jogo
Players.PlayerAdded:Connect(monitorPlayer)

-----------------------------------------------------------
-- Loop Principal: Processamento do AimAssist e Atualização do FOV
-----------------------------------------------------------
RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    local localCharacter = LocalPlayer.Character
    if not localCharacter then return end  -- Sai do loop se o jogador não tiver personagem

    local localHRP = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localHRP then return end  -- Sai do loop se não encontrar o HumanoidRootPart

    -- Processamento do AimAssist
    if config.aimAssistEnabled then
        local target = getClosestTarget()
        if target then
            local targetPos = getTargetPosition(target)
            if targetPos then
                camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
            end
        end
    end

    -- Atualização do círculo do FOV (se Drawing API estiver disponível)
    if fovCircle then
        if config.showFov then
            local viewportSize = camera.ViewportSize
            local fovRadians = math.rad(config.fovSize / 2)
            local distance = (viewportSize.Y / 2) / math.tan(math.rad(camera.FieldOfView / 2))
            fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            fovCircle.Radius = distance * math.tan(fovRadians)
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end
end)    

-----------------------------------------------------------
-- Mensagem de Confirmação
-----------------------------------------------------------
print("Tekscripts: AimAssist e ESP carregados com sucesso!")