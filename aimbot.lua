-----------------------------------------------------------
-- Serviços e variáveis iniciais
-----------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local currentTarget = nil

-- Configurações padrão do AimAssist e ESP
local config = {
    headPullDistance = 60,
    aimbotRange = 1000,
    fovSize = 60,
    showFov = false,
    ignoreWalls = false,
    teamCheck = true,
    aimAssistEnabled = false,
    visualizarPlayers = true,  -- Se true, os ESP dos players serão criados
}

-----------------------------------------------------------
-- Criação da interface gráfica de configurações (GUI)
-----------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AimAssistConfigGui"
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

-- Botão sempre visível para reabrir o painel
local openPanelButton = Instance.new("TextButton")
openPanelButton.Name = "OpenPanelButton"
openPanelButton.Parent = screenGui
openPanelButton.Size = UDim2.new(0, 100, 0, 30)
openPanelButton.Position = UDim2.new(0, 10, 0, 10)
openPanelButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
openPanelButton.Text = "Config"
openPanelButton.TextColor3 = Color3.new(1, 1, 1)
openPanelButton.Font = Enum.Font.SourceSansBold
openPanelButton.TextSize = 18

local openButtonCorner = Instance.new("UICorner")
openButtonCorner.CornerRadius = UDim.new(0, 6)
openButtonCorner.Parent = openPanelButton

-----------------------------------------------------------
-- Painel principal
-----------------------------------------------------------
local panel = Instance.new("Frame")
panel.Name = "ConfigPanel"
panel.Parent = screenGui
panel.Size = UDim2.new(0, 300, 0, 400)
panel.Position = UDim2.new(0.3, 0, 0.3, 0)
panel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
panel.BorderSizePixel = 0

local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 30))
}
panelGradient.Parent = panel

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelPadding = Instance.new("UIPadding")
panelPadding.PaddingTop = UDim.new(0, 10)
panelPadding.PaddingBottom = UDim.new(0, 10)
panelPadding.PaddingLeft = UDim.new(0, 10)
panelPadding.PaddingRight = UDim.new(0, 10)
panelPadding.Parent = panel

-----------------------------------------------------------
-- Cabeçalho do painel (também para arrastar)
-----------------------------------------------------------
local header = Instance.new("Frame")
header.Name = "Header"
header.Parent = panel
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
header.BorderSizePixel = 0

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = header
titleLabel.Size = UDim2.new(1, -80, 1, 0)  -- espaço para botões
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "aimbot Tekscripts"
titleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Botão de minimizar/maximizar
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Parent = header
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -60, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.Font = Enum.Font.SourceSansBold
minimizeButton.TextSize = 24
minimizeButton.BorderSizePixel = 0

local minButtonCorner = Instance.new("UICorner")
minButtonCorner.CornerRadius = UDim.new(0, 6)
minButtonCorner.Parent = minimizeButton

-- Botão de fechar (oculta o painel)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Parent = header
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.BorderSizePixel = 0

local closeButtonCorner = Instance.new("UICorner")
closeButtonCorner.CornerRadius = UDim.new(0, 6)
closeButtonCorner.Parent = closeButton

-----------------------------------------------------------
-- Área de conteúdo (onde ficarão as opções)
-----------------------------------------------------------
local content = Instance.new("Frame")
content.Name = "Content"
content.Parent = panel
content.Position = UDim2.new(0, 0, 0, 40)
content.Size = UDim2.new(1, 0, 1, -60)  -- espaço para cabeçalho e rodapé
content.BackgroundTransparency = 1

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingLeft = UDim.new(0, 5)
contentPadding.PaddingRight = UDim.new(0, 5)
contentPadding.PaddingTop = UDim.new(0, 5)
contentPadding.PaddingBottom = UDim.new(0, 5)
contentPadding.Parent = content

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = content
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)

-----------------------------------------------------------
-- Função auxiliar para criar uma linha numérica (não altere lógica)
-----------------------------------------------------------
local function createNumericRow(parent, order, labelText, defaultValue)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size = UDim2.new(1, -10, 0, 30)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local label = Instance.new("TextLabel")
    label.Parent = row
    label.Size = UDim2.new(0.5, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox")
    box.Parent = row
    box.Size = UDim2.new(0.5, -5, 1, 0)
    box.Position = UDim2.new(0.5, 5, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    box.Text = tostring(defaultValue)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.SourceSans
    box.TextSize = 16
    box.ClearTextOnFocus = false

    return box
end

-----------------------------------------------------------
-- Função auxiliar para criar uma linha de toggle (não altere lógica)
-----------------------------------------------------------
local function createToggleRow(parent, order, labelText, defaultState)
    local row = Instance.new("Frame")
    row.Parent = parent
    row.Size = UDim2.new(1, -10, 0, 30)
    row.BackgroundTransparency = 1
    row.LayoutOrder = order

    local label = Instance.new("TextLabel")
    label.Parent = row
    label.Size = UDim2.new(0.7, -5, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton")
    toggle.Parent = row
    toggle.Size = UDim2.new(0.3, -5, 1, 0)
    toggle.Position = UDim2.new(0.7, 5, 0, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    toggle.Text = defaultState and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.SourceSansBold
    toggle.TextSize = 16

    return toggle
end

-----------------------------------------------------------
-- Criação das linhas de configuração
-----------------------------------------------------------
-- 1. Head Pull Distance
local headPullBox = createNumericRow(content, 1, "puxar head distance:", config.headPullDistance)
headPullBox.FocusLost:Connect(function()
    local val = tonumber(headPullBox.Text)
    if val then
        config.headPullDistance = val
    else
        headPullBox.Text = tostring(config.headPullDistance)
    end
end)

-- 2. Aimbot Range
local rangeBox = createNumericRow(content, 2, "Alcance do aimbot:", config.aimbotRange)
rangeBox.FocusLost:Connect(function()
    local val = tonumber(rangeBox.Text)
    if val then
        config.aimbotRange = val
    else
        rangeBox.Text = tostring(config.aimbotRange)
    end
end)

-- 3. FOV Size
local fovBox = createNumericRow(content, 3, "Tamanho do FOV:", config.fovSize)
fovBox.FocusLost:Connect(function()
    local val = tonumber(fovBox.Text)
    if val then
        config.fovSize = val
    else
        fovBox.Text = tostring(config.fovSize)
    end
end)

-- 4. Mostrar FOV no centro
local showFovToggle = createToggleRow(content, 4, "Visualizar FOV no centro:", config.showFov)
showFovToggle.MouseButton1Click:Connect(function()
    config.showFov = not config.showFov
    showFovToggle.Text = config.showFov and "ON" or "OFF"
end)

-- 5. Ignorar paredes (Raycast)
local ignoreWallsToggle = createToggleRow(content, 5, "Ignorar parades:", config.ignoreWalls)
ignoreWallsToggle.MouseButton1Click:Connect(function()
    config.ignoreWalls = not config.ignoreWalls
    ignoreWallsToggle.Text = config.ignoreWalls and "ON" or "OFF"
end)

-- 6. Verificar Time (Team Check)
local teamCheckToggle = createToggleRow(content, 6, "Verificar Time:", config.teamCheck)
teamCheckToggle.MouseButton1Click:Connect(function()
    config.teamCheck = not config.teamCheck
    teamCheckToggle.Text = config.teamCheck and "ON" or "OFF"
end)

-- 7. Ativar AimAssist
local aimAssistToggle = createToggleRow(content, 7, "AimAssist:", config.aimAssistEnabled)
aimAssistToggle.MouseButton1Click:Connect(function()
    config.aimAssistEnabled = not config.aimAssistEnabled
    aimAssistToggle.Text = config.aimAssistEnabled and "ON" or "OFF"
end)

-- 8. Visualizar Players (ESP)
local visualizarPlayersToggle = createToggleRow(content, 8, "Visualizar Players:", config.visualizarPlayers)
visualizarPlayersToggle.MouseButton1Click:Connect(function()
    config.visualizarPlayers = not config.visualizarPlayers
    visualizarPlayersToggle.Text = config.visualizarPlayers and "ON" or "OFF"
    
    if not config.visualizarPlayers then
        -- Remove ESP existente de todos os jogadores
        for _, jogador in ipairs(Players:GetPlayers()) do
            if jogador.Character then
                local head = jogador.Character:FindFirstChild("Head") or jogador.Character:FindFirstChildWhichIsA("BasePart")
                if head then
                    local esp = head:FindFirstChild("ESP")
                    if esp then
                        esp:Destroy()
                    end
                end
            end
        end
    else
        -- Reaplica ESP para os jogadores
        for _, jogador in ipairs(Players:GetPlayers()) do
            configurarJogador(jogador)
        end
    end
end)

-- Créditos
local creditsLabel = Instance.new("TextLabel")
creditsLabel.Parent = panel
creditsLabel.Size = UDim2.new(1, 0, 0, 20)
creditsLabel.Position = UDim2.new(0, 0, 1, -20)
creditsLabel.BackgroundTransparency = 1
creditsLabel.Text = "Tekscripts | Criador: kauam"
creditsLabel.TextColor3 = Color3.fromRGB(200,200,200)
creditsLabel.Font = Enum.Font.SourceSans
creditsLabel.TextSize = 14
creditsLabel.TextXAlignment = Enum.TextXAlignment.Center

-----------------------------------------------------------
-- Dragging do painel via cabeçalho (mouse e toque)
-----------------------------------------------------------
local dragging = false
local dragInput, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-----------------------------------------------------------
-- Funções de minimizar/fechar o painel
-----------------------------------------------------------
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    if not isMinimized then
        content.Visible = false
        panel.Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, 40)
        isMinimized = true
        minimizeButton.Text = "+"
    else
        content.Visible = true
        panel.Size = UDim2.new(panel.Size.X.Scale, panel.Size.X.Offset, 0, 400)
        isMinimized = false
        minimizeButton.Text = "-"
    end
end)

closeButton.MouseButton1Click:Connect(function()
    panel.Visible = false
end)

openPanelButton.MouseButton1Click:Connect(function()
    panel.Visible = not panel.Visible
end)

-----------------------------------------------------------
-- (Opcional) Criação do círculo de FOV (usando Drawing API)
-----------------------------------------------------------
local fovCircle
if Drawing and Drawing.new then
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255,0,0)
    fovCircle.Thickness = 2
    fovCircle.Transparency = 1
    fovCircle.Visible = false
end

-----------------------------------------------------------
-- Funções do AimAssist
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

RunService.RenderStepped:Connect(function()
    if config.aimAssistEnabled then
        local localCharacter = LocalPlayer.Character
        if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return end

        currentTarget = getClosestTarget()
        if currentTarget and currentTarget.Character then
            local targetPos = getTargetPosition(currentTarget)
            if targetPos then
                local camera = Workspace.CurrentCamera
                local camPos = camera.CFrame.Position
                camera.CFrame = CFrame.new(camPos, targetPos)
            end
        end
    end

    if fovCircle then
        if config.showFov then
            local camera = Workspace.CurrentCamera
            local viewportSize = camera.ViewportSize
            local halfFov = math.rad(config.fovSize / 2)
            local distance = (viewportSize.Y / 2) / math.tan(math.rad(camera.FieldOfView / 2))
            local radius = distance * math.tan(halfFov)
            fovCircle.Position = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            fovCircle.Radius = radius
            fovCircle.Visible = true
        else
            fovCircle.Visible = false
        end
    end
end)

-----------------------------------------------------------
-- Código de ESP fixo (aplicado aos players)
-----------------------------------------------------------
local function criarESP(jogador)  
    if not config.visualizarPlayers then return end  -- Só cria o ESP se estiver ativado  
    if not jogador or not jogador.Character then return end  
  
    local head = jogador.Character:FindFirstChild("Head") or jogador.Character:FindFirstChildWhichIsA("BasePart")  
    if not head then return end  

    -- Verificar se já existe um ESP para o jogador
    local antigoESP = head:FindFirstChild("ESP")  
    if antigoESP then  
        antigoESP:Destroy()  
    end  
  
    local esp = Instance.new("BillboardGui")  
    esp.Name = "ESP"  
    esp.Adornee = head  
    esp.Size = UDim2.new(5, 0, 1, 0)  
    esp.StudsOffset = Vector3.new(0, 2.5, 0)  
    esp.AlwaysOnTop = true  
    esp.Parent = head  
  
    local texto = Instance.new("TextLabel")  
    texto.Size = UDim2.new(1, 0, 1, 0)  
    texto.BackgroundTransparency = 1  
    texto.TextColor3 = Color3.fromRGB(255, 215, 0)  
    texto.TextStrokeTransparency = 0  
    texto.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)  
    texto.TextSize = 18  
    texto.Font = Enum.Font.GothamBold  
    texto.TextYAlignment = Enum.TextYAlignment.Center  
    texto.Parent = esp  

    -- Atualiza o texto com nome e vida do jogador
    local function atualizarTextoESP()
        local vida = jogador.Character:FindFirstChild("Humanoid") and jogador.Character.Humanoid.Health or 0
        texto.Text = string.format("Nome: %s\nVida: %.0f", jogador.Name, vida)
    end

    -- Atualizar sempre que a vida mudar
    if jogador.Character:FindFirstChild("Humanoid") then
        jogador.Character.Humanoid.HealthChanged:Connect(function()
            atualizarTextoESP()
        end)
    end

    -- Inicializar o texto no momento da criação
    atualizarTextoESP()
end  
  
local function monitorarJogador(jogador)  
    jogador.CharacterAdded:Connect(function()  
        task.wait(0.5) -- Pequeno delay para garantir que o personagem esteja carregado  
        criarESP(jogador)  
    end)  
  
    if jogador.Character then  
        criarESP(jogador)  
    end  
end  
  
function configurarJogador(jogador)  
    local sucesso, erro = pcall(function()  
        if jogador.Name == "FXZGHS1" then  
            monitorarJogador(jogador)  
        elseif jogador.Name == "reivison008" then  
            monitorarJogador(jogador)  
        else  
            monitorarJogador(jogador)  
        end  
    end)  
    if not sucesso then  
        warn("[ESP] Erro ao configurar jogador:", erro)  
    end  
end  
  
for _, jogador in ipairs(Players:GetPlayers()) do  
    configurarJogador(jogador)  
end  
  
Players.PlayerAdded:Connect(configurarJogador)

-----------------------------------------------------------
-- Mensagem final de carregamento e créditos
-----------------------------------------------------------
print("Todos os assets carregados")
print("Script rodando – criado pela TekScripts, desenvolvedor: kauam!")