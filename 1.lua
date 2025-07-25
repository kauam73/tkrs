--!strict
-- @author Tekscripts

--- SERVICES & LIBRARIES ---
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--- GLOBAL CONFIGURATIONS ---
local config = {
    aimAssistEnabled = false,
    aimbotStrength = 0.5,
    aimbotRange = 1000,
    fovSize = 60,
    showFov = false,
    ignoreWalls = false,
    teamCheck = true,
    headPullDistance = 60,
    visualizePlayers = false, -- Chams
    visualizeInfo = false,   -- Info ESP
    weaponModuleEnabled = false,
    debugMode = false
}

--- GLOBAL STATE VARIABLES ---
local FloatingButtonGUI: ScreenGui?
local FOVCircle: Drawing.Circle?
local PlayerConnections: { [Player]: { [string]: RBXScriptConnection } } = {}
local InfoESPData: { [Player]: { gui: BillboardGui, conn: RBXScriptConnection } } = {}

--- UTILITY FUNCTIONS ---
local function log(message: string)
    if config.debugMode then
        warn("[DEBUG] " .. message)
    end
end

local function isPlayerValid(player: Player): boolean
    return player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and (player.Character:FindFirstChildOfClass("Humanoid") :: Humanoid).Health > 0
end

local function trySetValue(obj: Instance, value: number | boolean | string)
    pcall(function()
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            (obj :: NumberValue).Value = value :: number
        elseif obj:IsA("BoolValue") then
            (obj :: BoolValue).Value = (value ~= 0) :: boolean
        elseif obj:IsA("StringValue") and tonumber((obj :: StringValue).Value) then
            (obj :: StringValue).Value = tostring(value)
        end
    end)
end

--- CORE MODULE ---
local Core = {}

function Core.setupRayfieldUI(): (Rayfield.Tab, Rayfield.Tab, Rayfield.Tab)
    local Window = Rayfield:CreateWindow({
        Name = "Tekscripts",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "TekscriptsConfig",
            FileName = "PainelConfig"
        }
    })

    local AimAssistTab = Window:CreateTab("AimAssist", nil)
    local ESPTab = Window:CreateTab("ESP", nil)
    local OthersTab = Window:CreateTab("Outros", nil)

    return AimAssistTab, ESPTab, OthersTab
end

function Core.createFloatingButton(callback: (value: boolean) -> ())
    local function updateButtonText(button: TextButton)
        button.Text = config.aimAssistEnabled and "✅" or "⚫"
    end

    local function createButton()
        if FloatingButtonGUI then return end

        FloatingButtonGUI = Instance.new("ScreenGui")
        FloatingButtonGUI.Name = "FloatingAimbotGUI"
        FloatingButtonGUI.Parent = CoreGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 80, 0, 80)
        frame.Position = UDim2.new(0.5, -40, 0, 20)
        frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        frame.Parent = FloatingButtonGUI

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = frame

        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 1, 0)
        button.BackgroundTransparency = 1
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.SourceSansBold
        button.TextSize = 30
        button.Parent = frame
        updateButtonText(button)

        button.MouseButton1Click:Connect(function()
            config.aimAssistEnabled = not config.aimAssistEnabled
            updateButtonText(button)
        end)

        local dragging, dragStart, startPos: boolean, Vector2, UDim2
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                if dragStart and startPos then
                    local delta = input.Position - dragStart
                    frame.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                dragStart = nil
                startPos = nil
            end
        end)
    end

    local function destroyButton()
        if FloatingButtonGUI then
            FloatingButtonGUI:Destroy()
            FloatingButtonGUI = nil
        end
    end

    return function(value: boolean)
        if value then
            createButton()
        else
            destroyButton()
        end
        callback(value)
    end
end

--- AIMASSIST MODULE ---
local AimAssist = {}

local RaycastParamsForVisibility = RaycastParams.new()
RaycastParamsForVisibility.FilterType = Enum.RaycastFilterType.Exclude

local function isPartVisible(part: BasePart, origin: BasePart): boolean
    if config.ignoreWalls then return true end

    local maxPenetrations = 5
    local originPos = origin.Position
    local targetPos = part.Position
    local direction = (targetPos - originPos).Unit
    local currentOrigin = originPos

    RaycastParamsForVisibility.FilterDescendantsInstances = {LocalPlayer.Character}

    for _ = 1, maxPenetrations do
        local result = Workspace:Raycast(currentOrigin, direction * (targetPos - currentOrigin).Magnitude, RaycastParamsForVisibility)

        if not result then return true end

        local hit = result.Instance
        if hit:IsDescendantOf(part.Parent) then return true end

        if hit.Transparency == 1 or not hit.CanCollide then
            currentOrigin = result.Position + direction * 0.01
        else
            break
        end
    end
    return false
end

function AimAssist.getBestVisiblePartPosition(target: Player): Vector3?
    local character = target.Character
    local localCharacter = LocalPlayer.Character
    if not character or not localCharacter then return nil end

    local origin = localCharacter:FindFirstChild("Head") or localCharacter:FindFirstChild("HumanoidRootPart")
    local localHRP = localCharacter:FindFirstChild("HumanoidRootPart")
    if not origin or not localHRP then return nil end

    local bestPartPos: Vector3? = nil
    local bestDist = math.huge

    local head = character:FindFirstChild("Head")
    if head and isPartVisible(head, origin) then
        local dist = (head.Position - localHRP.Position).Magnitude
        if dist <= config.aimbotRange then
            if dist <= config.headPullDistance then
                return head.Position -- Optimal target, prioritize head if within pull distance
            else
                bestPartPos = head.Position
                bestDist = dist
            end
        end
    end

    local partsToCheck = { character:FindFirstChild("UpperTorso"), character:FindFirstChild("LowerTorso"), character:FindFirstChild("HumanoidRootPart") }
    for _, part in ipairs(partsToCheck) do
        if part and isPartVisible(part, origin) then
            local dist = (part.Position - localHRP.Position).Magnitude
            if dist < bestDist and dist <= config.aimbotRange then
                bestDist = dist
                bestPartPos = part.Position
            end
        end
    end
    return bestPartPos
end

function AimAssist.getClosestTarget(): Player?
    local bestPlayer: Player? = nil
    local closestToCrosshair = math.huge
    local localCharacter = LocalPlayer.Character
    local hrp = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    local camera = Workspace.CurrentCamera

    if not hrp or not camera then return nil end

    local viewportCenter = camera.ViewportSize / 2
    local fovRadius = (viewportCenter.Y / math.tan(math.rad(camera.FieldOfView / 2))) * math.tan(math.rad(config.fovSize / 2))

    for _, player in ipairs(Players:GetPlayers()) do
        if not isPlayerValid(player) then continue end
        if config.teamCheck and LocalPlayer.Team and player.Team and LocalPlayer.Team == player.Team then continue end

        local aimPos = AimAssist.getBestVisiblePartPosition(player)
        if aimPos then
            local screenPoint, onScreen = camera:WorldToScreenPoint(aimPos)
            if onScreen then
                local distanceToCenter = (Vector2.new(screenPoint.X, screenPoint.Y) - viewportCenter).Magnitude
                if distanceToCenter <= fovRadius and distanceToCenter < closestToCrosshair then
                    closestToCrosshair = distanceToCenter
                    bestPlayer = player
                end
            end
        end
    end
    return bestPlayer
end

function AimAssist.initFOVDisplay()
    if not Drawing then return end
    if not FOVCircle then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        FOVCircle.Thickness = 2
        FOVCircle.Transparency = 1
        FOVCircle.Visible = false
    end
end

function AimAssist.updateFOVDisplay()
    if not FOVCircle then return end
    local camera = Workspace.CurrentCamera
    if not camera then return end

    if config.showFov then
        local viewport = camera.ViewportSize
        local fovRadians = math.rad(config.fovSize / 2)
        local screenHeight = viewport.Y
        local currentCameraFovRadians = math.rad(camera.FieldOfView / 2)
        local distanceToScreen = (screenHeight / 2) / math.tan(currentCameraFovRadians)
        FOVCircle.Radius = distanceToScreen * math.tan(fovRadians)
        FOVCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    local camera = Workspace.CurrentCamera
    local localCharacter = LocalPlayer.Character
    if not camera or not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return end

    if config.aimAssistEnabled then
        local target = AimAssist.getClosestTarget()
        if target then
            local aimPos = AimAssist.getBestVisiblePartPosition(target)
            if aimPos then
                local cf = CFrame.new(camera.CFrame.Position, aimPos)
                camera.CFrame = camera.CFrame:Lerp(cf, config.aimbotStrength)
            end
        end
    end
    AimAssist.updateFOVDisplay()
end)

--- WEAPON MODULE ---
local WeaponModule = {}
local CurrentWeapon: Tool? = nil
local WeaponRunning = false
local CharacterAddedConnection: RBXScriptConnection? = nil
local WeaponLogCount = 0

local WEAPON_KEYWORDS = {"cooldown", "delay", "reload", "interval", "fire", "clip", "reserve", "heat", "magazine", "charge", "recall", "recoil", "kickback"}

local WEAPON_PROPERTIES_MAP = {
    pistol = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0},
    rifle = {FireRate = 12000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0},
    shotgun = {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 50, Recoil = 0, Kickback = 0},
    smg = {FireRate = 15000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0},
    sniper = {FireRate = 6000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 20, Recoil = 0, Kickback = 0},
    machinegun = {FireRate = 14000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 2000, Recoil = 0, Kickback = 0},
    bazooka = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0},
    crossbow = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0},
    grenadelauncher = {FireRate = 15000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 9999, Recoil = 0, Kickback = 0},
    laser = {FireRate = 11000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0},
    flamethrower = {FireRate = 12000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 2000, Recoil = 0, Kickback = 0},
    minigun = {FireRate = 16000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 2000, Recoil = 0, Kickback = 0},
    rocketlauncher = {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 1, Recoil = 0, Kickback = 0},
    dartgun = {FireRate = 8000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 50, Recoil = 0, Kickback = 0},
    chaingun = {FireRate = 14000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 999, Recoil = 0, Kickback = 0},
    default = {FireRate = 10000, Cooldown = 0, Automatic = true, ReloadTime = 0, ClipSize = 9999, Recoil = 0, Kickback = 0}
}

local function weaponLog(msg: string)
    if config.debugMode then
        warn("[DEBUG] [WeaponModule] " .. msg)
        WeaponLogCount += 1
        if WeaponLogCount >= 100 then
            -- A simple way to "clear" console by flooding, useful in some contexts
            for _ = 1, 30 do warn("") end
            warn("[DEBUG] Console " .. "limpo" .. " (WeaponModule)")
            WeaponLogCount = 0
        end
    end
end

local function enforceWeaponProperties(weapon: Tool, desiredProperties: { [string]: number | boolean })
    for property, value in pairs(desiredProperties) do
        local propObj = weapon:FindFirstChild(property)
        if propObj then
            local currentValue = nil
            if propObj:IsA("NumberValue") or propObj:IsA("IntValue") then
                currentValue = (propObj :: NumberValue).Value
            elseif propObj:IsA("BoolValue") then
                currentValue = (propObj :: BoolValue).Value
            elseif propObj:IsA("StringValue") and tonumber((propObj :: StringValue).Value) then
                currentValue = tonumber((propObj :: StringValue).Value)
            end

            if currentValue ~= value then
                weaponLog(string.format("Reapplying %s (%s -> %s)", property, tostring(currentValue), tostring(value)))
                trySetValue(propObj, value)
            end
        end
    end
end

local function autoReloadWeapon(weapon: Tool)
    local ammo = weapon:FindFirstChild("Ammo") :: NumberValue?
    local clipSizeObj = weapon:FindFirstChild("ClipSize") :: NumberValue?
    if ammo and clipSizeObj and ammo.Value <= 0 then
        weaponLog("Reloading " .. weapon.Name)
        ammo.Value = clipSizeObj.Value
    end
end

local function applyWeaponConfiguration(weapon: Tool)
    weaponLog("Weapon detected: " .. weapon.Name)

    for _, desc in ipairs(weapon:GetDescendants()) do
        if desc:IsA("NumberValue") or desc:IsA("IntValue") or desc:IsA("BoolValue") or (desc:IsA("StringValue") and tonumber(desc.Value)) then
            for _, keyword in ipairs(WEAPON_KEYWORDS) do
                if desc.Name:lower():find(keyword) then
                    weaponLog("Adjusting descendant: " .. desc.Name)
                    trySetValue(desc, 0)
                    break
                end
            end
        end
    end

    local weaponType = weapon.Name:lower()
    local knownProperties = WEAPON_PROPERTIES_MAP[weaponType:match("^(%a+)") or ""] or WEAPON_PROPERTIES_MAP.default

    for property, value in pairs(knownProperties) do
        local prop = weapon:FindFirstChild(property)
        if prop then
            weaponLog(string.format("Configuring %s to %s", property, tostring(value)))
            trySetValue(prop, value)
        end
    end

    local enforceLoop = weapon:FindFirstChild("EnforceLoop")
    if not enforceLoop then
        enforceLoop = Instance.new("BoolValue")
        enforceLoop.Name = "EnforceLoop"
        enforceLoop.Parent = weapon
        task.spawn(function()
            while weapon and weapon.Parent and WeaponRunning and enforceLoop.Parent == weapon do
                enforceWeaponProperties(weapon, knownProperties)
                autoReloadWeapon(weapon)
                task.wait(0.001)
            end
            weaponLog("Enforce loop for " .. weapon.Name .. " terminated.")
            if enforceLoop.Parent then enforceLoop:Destroy() end
        end)
    end
end

local function setupCharacter(character: Model)
    if not WeaponRunning then return end

    CurrentWeapon = character:FindFirstChildOfClass("Tool")
    if CurrentWeapon then
        applyWeaponConfiguration(CurrentWeapon)
    end

    if PlayerConnections[LocalPlayer] and PlayerConnections[LocalPlayer].CharacterChildAdded then
        PlayerConnections[LocalPlayer].CharacterChildAdded:Disconnect()
    end
    PlayerConnections[LocalPlayer] = PlayerConnections[LocalPlayer] or {}
    PlayerConnections[LocalPlayer].CharacterChildAdded = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            applyWeaponConfiguration(child)
        end
    end)
end

function WeaponModule.Enable()
    if WeaponRunning then return end
    WeaponRunning = true
    config.weaponModuleEnabled = true
    if not CharacterAddedConnection then
        CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(setupCharacter)
    end
    if LocalPlayer.Character then
        setupCharacter(LocalPlayer.Character)
    end
    weaponLog("WeaponModule activated.")
end

function WeaponModule.Disable()
    if not WeaponRunning then return end
    WeaponRunning = false
    config.weaponModuleEnabled = false
    if CharacterAddedConnection then
        CharacterAddedConnection:Disconnect()
        CharacterAddedConnection = nil
    end
    if LocalPlayer.Character then
        if PlayerConnections[LocalPlayer] and PlayerConnections[LocalPlayer].CharacterChildAdded then
            PlayerConnections[LocalPlayer].CharacterChildAdded:Disconnect()
            PlayerConnections[LocalPlayer].CharacterChildAdded = nil
        end
        for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                local enforceLoop = tool:FindFirstChild("EnforceLoop")
                if enforceLoop then
                    enforceLoop:Destroy()
                end
            end
        end
    end
    CurrentWeapon = nil
    weaponLog("WeaponModule deactivated.")
end

--- ESP MODULE ---
local ESP = {}

function ESP.applyChams(player: Player)
    if not config.visualizePlayers or player == LocalPlayer or not isPlayerValid(player) then return end
    local character = player.Character
    if not character then return end

    local highlight = character:FindFirstChild("ChamsHighlight") :: Highlight?
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "ChamsHighlight"
        highlight.Adornee = character
        highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
        highlight.FillTransparency = 0.6
        highlight.OutlineTransparency = 0
        highlight.Parent = character

        local teamConn = player:GetPropertyChangedSignal("Team"):Connect(function()
            if highlight and highlight.Parent then
                highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(255, 255, 255)
            else
                if PlayerConnections[player] and PlayerConnections[player].Team then
                    PlayerConnections[player].Team:Disconnect()
                    PlayerConnections[player].Team = nil
                end
            end
        end)

        PlayerConnections[player] = PlayerConnections[player] or {}
        if PlayerConnections[player].Team then PlayerConnections[player].Team:Disconnect() end
        PlayerConnections[player].Team = teamConn
    end
end

function ESP.removeChams(player: Player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("ChamsHighlight")
        if highlight then highlight:Destroy() end
    end
    if PlayerConnections[player] and PlayerConnections[player].Team then
        PlayerConnections[player].Team:Disconnect()
        PlayerConnections[player].Team = nil
    end
end

function ESP.removeInfoESP(player: Player)
    local data = InfoESPData[player]
    if data then
        if data.conn then data.conn:Disconnect() end
        if data.gui then data.gui:Destroy() end
        InfoESPData[player] = nil
    end
end

function ESP.applyInfoESP(player: Player)
    if not config.visualizeInfo or player == LocalPlayer or not isPlayerValid(player) then
        ESP.removeInfoESP(player)
        return
    end

    local head = player.Character and player.Character:FindFirstChild("Head")
    if not head then return end

    ESP.removeInfoESP(player)

    local gui = Instance.new("BillboardGui")
    gui.Name = "InfoESP"
    gui.Adornee = head
    gui.AlwaysOnTop = true
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.LightInfluence = 1
    gui.Parent = head

    local container = Instance.new("Frame")
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BackgroundTransparency = 0.7
    container.BorderSizePixel = 1
    container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    container.Size = UDim2.new(1, 0, 1, 0)
    container.Position = UDim2.new(0, 0, 0, 0)
    container.Parent = gui

    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 6)

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

    local conn = RunService.Heartbeat:Connect(function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        local localHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not localHrp then
            ESP.removeInfoESP(player)
            return
        end

        local dist = (hrp.Position - localHrp.Position).Magnitude
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        local healthText = "❤️ N/A"
        if humanoid then
            healthText = string.format("❤️ %.0f/%.0f", humanoid.Health, humanoid.MaxHealth)
        end
        header.Text = string.format("👤 %s | 📏 %.1f | %s", player.Name, dist, healthText)

        local inventory = {}
        if player.Backpack then
            for _, tool in ipairs(player.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(inventory, "• " .. tool.Name)
                end
            end
        end
        if player.Character then
            for _, tool in ipairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool.Parent == player.Character then
                    table.insert(inventory, "👉 " .. tool.Name .. " [Equipped]")
                end
            end
        end

        inventoryText.Text = (#inventory == 0) and "🔒 Empty Inventory" or table.concat(inventory, "\n")
        local lines = 1 + #inventory
        local heightPx = 28 + (lines * 14)
        container.Size = UDim2.new(1, 0, 0, heightPx)
        gui.Size = UDim2.new(0, 180, 0, heightPx)
    end)
    InfoESPData[player] = { gui = gui, conn = conn }
end

function ESP.monitorPlayer(player: Player)
    if player == LocalPlayer then return end

    if PlayerConnections[player] and PlayerConnections[player].Character then
        PlayerConnections[player].Character:Disconnect()
        PlayerConnections[player].Character = nil
    end

    local charConn = player.CharacterAdded:Connect(function(character)
        task.spawn(function()
            local head = character:WaitForChild("Head", 5)
            local hrp = character:WaitForChild("HumanoidRootPart", 5)
            if head and hrp then
                if config.visualizePlayers then ESP.applyChams(player) end
                if config.visualizeInfo then ESP.applyInfoESP(player) end
            else
                warn(("%s's character did not load essential parts in time."):format(player.Name))
            end
        end)
    end)

    PlayerConnections[player] = PlayerConnections[player] or {}
    PlayerConnections[player].Character = charConn

    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if head and hrp then
            if config.visualizePlayers then ESP.applyChams(player) end
            if config.visualizeInfo then ESP.applyInfoESP(player) end
        end
    end
end

function ESP.unmonitorPlayer(player: Player)
    if player == LocalPlayer then return end
    local connections = PlayerConnections[player]
    if connections then
        for _, conn in pairs(connections) do
            if conn then conn:Disconnect() end
        end
        PlayerConnections[player] = nil
    end
    ESP.removeInfoESP(player)
    ESP.removeChams(player)
end

--- RAYFIELD UI INITIALIZATION ---
local AimAssistTab, ESPTab, OthersTab = Core.setupRayfieldUI()

-- AimAssist Tab UI
AimAssistTab:CreateToggle({
    Name = "Enable AimAssist",
    CurrentValue = config.aimAssistEnabled,
    Flag = "AimAssistEnabled",
    Callback = function(Value)
        config.aimAssistEnabled = Value
    end
})

AimAssistTab:CreateToggle({
    Name = "Floating Button (Quick Toggle)",
    CurrentValue = false,
    Flag = "FloatingButtonToggle",
    Callback = Core.createFloatingButton(function(value)
        -- This callback is for Rayfield's internal saving, the button directly modifies config.aimAssistEnabled
    end)
})

AimAssistTab:CreateSlider({
    Name = "Aimbot Strength",
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
    Name = "Aimbot Range",
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
    Name = "Head Pull Distance",
    Range = {0, 2000},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = config.headPullDistance,
    Flag = "HeadPullDistance",
    Callback = function(Value)
        config.headPullDistance = Value
    end
})

AimAssistTab:CreateSlider({
    Name = "FOV Size",
    Range = {0, 360},
    Increment = 1,
    Suffix = "°",
    CurrentValue = config.fovSize,
    Flag = "FOVSize",
    Callback = function(Value)
        config.fovSize = Value
        AimAssist.updateFOVDisplay()
    end
})

AimAssistTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = config.showFov,
    Flag = "ShowFOV",
    Callback = function(Value)
        config.showFov = Value
        AimAssist.updateFOVDisplay()
    end
})

AimAssistTab:CreateToggle({
    Name = "Ignore Walls",
    CurrentValue = config.ignoreWalls,
    Flag = "IgnoreWalls",
    Callback = function(Value)
        config.ignoreWalls = Value
    end
})

AimAssistTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = config.teamCheck,
    Flag = "TeamCheck",
    Callback = function(Value)
        config.teamCheck = Value
    end
})

-- ESP Tab UI
ESPTab:CreateToggle({
    Name = "Visualize Players (Chams)",
    CurrentValue = config.visualizePlayers,
    Flag = "VisualizePlayers",
    Callback = function(Value)
        config.visualizePlayers = Value
        for _, player in ipairs(Players:GetPlayers()) do
            if isPlayerValid(player) then
                if Value then ESP.applyChams(player) else ESP.removeChams(player) end
            end
        end
    end,
})

ESPTab:CreateToggle({
    Name = "Visualize Name, Distance & Items",
    CurrentValue = config.visualizeInfo,
    Flag = "VisualizeInfo",
    Callback = function(Value)
        config.visualizeInfo = Value
        for _, player in ipairs(Players:GetPlayers()) do
            if isPlayerValid(player) then
                if Value then ESP.applyInfoESP(player) else ESP.removeInfoESP(player) end
            end
        end
    end,
})

ESPTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if isPlayerValid(player) then
                ESP.removeChams(player)
                ESP.removeInfoESP(player)
                if config.visualizePlayers then ESP.applyChams(player) end
                if config.visualizeInfo then ESP.applyInfoESP(player) end
            end
        end
    end,
})

-- Others Tab UI
OthersTab:CreateToggle({
    Name = "Enable Weapon Module",
    CurrentValue = config.weaponModuleEnabled,
    Flag = "WeaponModuleToggle",
    Callback = function(Value)
        if Value then
            WeaponModule.Enable()
        else
            WeaponModule.Disable()
        end
    end
})

OthersTab:CreateToggle({
    Name = "Enable Debug Mode (Console)",
    CurrentValue = config.debugMode,
    Flag = "DebugMode",
    Callback = function(Value)
        config.debugMode = Value
        if not Value then
            warn("[DEBUG] Debug mode deactivated.")
        end
    end
})

--- GLOBAL MONITORS INITIALIZATION ---
-- Monitor players already in game
for _, player in ipairs(Players:GetPlayers()) do
    ESP.monitorPlayer(player)
end
-- Monitor new players joining
Players.PlayerAdded:Connect(ESP.monitorPlayer)
-- Clean up when players leave
Players.PlayerRemoving:Connect(ESP.unmonitorPlayer)

-- Initialize FOV Circle only once
AimAssist.initFOVDisplay()

print("Tekscripts: AimAssist, ESP, and Weapon Module loaded successfully!")
