-- Inicialização do jogador e personagem
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local showFloatingButton = false         -- Controla exibição do botão flutuante
getgenv().scriptEnabled = false            -- Controla a execução do script

local weapon
local debugMode = false
local guiButton

-- Função de depuração
local function log(msg)
    if debugMode then
        print("[DEBUG] " .. msg)
    end
end

-- Atribuição segura de valor
local function trySetValue(obj, value)
    pcall(function()
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            obj.Value = value
        elseif obj:IsA("BoolValue") then
            obj.Value = (value ~= 0)
        elseif obj:IsA("StringValue") and tonumber(obj.Value) then
            obj.Value = tostring(value)
        end
    end)
end

-- Força a persistência dos valores
local function enforceWeaponProperties(weapon, desiredProperties)
    for property, value in pairs(desiredProperties) do
        local propObj = weapon:FindFirstChild(property)
        if propObj and propObj.Value ~= value then
            log("Reaplicando " .. property .. " (" .. tostring(propObj.Value) .. " -> " .. tostring(value) .. ")")
            trySetValue(propObj, value)
        end
    end
end

-- Recarrega automaticamente a arma se necessário
local function autoReloadWeapon(weapon)
    local ammo = weapon:FindFirstChild("Ammo")
    local clipSizeObj = weapon:FindFirstChild("ClipSize")
    if ammo and clipSizeObj then
        if ammo.Value <= 0 then
            log("Reloading " .. weapon.Name)
            ammo.Value = clipSizeObj.Value
        end
    end
end

-- Detecta e configura a arma; executa se o script estiver ativo
local function locateAndConfigureWeapon()
    if not getgenv().scriptEnabled then return end

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
                while weapon and weapon.Parent do
                    if getgenv().scriptEnabled then
                        enforceWeaponProperties(weapon, knownProperties)
                        autoReloadWeapon(weapon)
                    end
                    wait(0.001)
                end
            end)
        end
    else
        log("Nenhuma arma encontrada.")
    end
end

-- Cria GUI com botão flutuante para detectar a arma (se habilitado)
local function createGuiButton()
    if not showFloatingButton then return end

    guiButton = Instance.new("ScreenGui")
    guiButton.Name = "PersistentUI"
    guiButton.ResetOnSpawn = false
    guiButton.Parent = player:WaitForChild("PlayerGui")

    local button = Instance.new("TextButton", guiButton)
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0.85, 0, 0.2, 0)
    button.Text = "⚡ Detectar Arma"
    button.TextScaled = true
    button.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.BorderSizePixel = 2

    local dragging = false
    local dragStart, startPos

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    button.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    button.MouseButton1Click:Connect(function()
        locateAndConfigureWeapon()
    end)
end

-- Configura o personagem e detecta novas ferramentas
local function setupCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            locateAndConfigureWeapon()
        end
    end)
    locateAndConfigureWeapon()
end

player.CharacterAdded:Connect(setupCharacter)
setupCharacter()
createGuiButton()

-- Função global para alternar a execução do script
getgenv().toggleScript = function()
    getgenv().scriptEnabled = not getgenv().scriptEnabled
    print("Script ativado: " .. tostring(getgenv().scriptEnabled))
    if not getgenv().scriptEnabled then
        if guiButton then
            guiButton:Destroy()
        end
    else
        setupCharacter()
        if showFloatingButton and not guiButton then
            createGuiButton()
        end
    end
end