--[[ Roblox Floating GUI Emote Player | por Kauam (Otimizado) ]]--

-- Identificador único para evitar múltiplas instâncias
local scriptId = "EmotePlayer_" .. tostring(math.random(1000000, 9999999))
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Verificar se já existe uma instância rodando
if player:WaitForChild("PlayerGui"):FindFirstChild("EmoteGUI") then 
    return 
end

-- Serviços do Roblox
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Variáveis globais
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local emoteDataURL = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/emotes.json"
local emoteList = {}
local emoteTrack = nil
local loopEmote = false
local dragging = false
local dragInput, dragStart, startPos
local isMinimized = false
local isDraggingPanel = false
local panelDragStart, panelStartPos
local currentAnimationState = "idle" -- Para controlar o estado da animação
local currentStopConn = nil -- Variável global para a conexão de parada

-- Função para obter requisição HTTP
local function getRequest()
    return (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or
           (krnl and krnl.request) or (getgenv().request) or request
end

-- Atualizar character e humanoid ao renascer
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    if emoteTrack then
        emoteTrack:Stop()
        emoteTrack = nil
    end
    
    -- Limpar conexão existente
    if currentStopConn then
        pcall(function() currentStopConn:Disconnect() end)
        currentStopConn = nil
    end
    
    currentAnimationState = "idle"
end)

-- Funções de UI
local function createGradient(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 80, 80))
    }
    gradient.Rotation = 90
    gradient.Parent = parent
    return gradient
end

local function createLoadingSpinner(parent)
    local spinner = Instance.new("ImageLabel")
    spinner.Image = "rbxassetid://10101260412"
    spinner.Size = UDim2.new(0.8, 0, 0.8, 0)
    spinner.Position = UDim2.new(0.1, 0, 0.1, 0)
    spinner.BackgroundTransparency = 1
    spinner.ZIndex = 2
    spinner.Parent = parent
    
    -- Otimização: usar uma conexão local em vez de global
    local spinnerConnection = nil
    spinnerConnection = RunService.RenderStepped:Connect(function(delta)
        if not spinner or not spinner.Parent then
            if spinnerConnection then
                pcall(function() spinnerConnection:Disconnect() end)
                spinnerConnection = nil
            end
            return
        end
        spinner.Rotation = spinner.Rotation + (delta * 360)
    end)
    
    return spinner
end

-- Função para manter o frame dentro da tela
local function keepFrameOnScreen(frame)
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local frameSize = frame.AbsoluteSize
    local framePos = frame.AbsolutePosition
    
    local newPosX = math.clamp(framePos.X, 0, viewportSize.X - frameSize.X)
    local newPosY = math.clamp(framePos.Y, 0, viewportSize.Y - frameSize.Y)
    
    if newPosX ~= framePos.X or newPosY ~= framePos.Y then
        frame.Position = UDim2.new(0, newPosX, 0, newPosY)
    end
end

-- Criação da GUI
local function createGUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "EmoteGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 460, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -230, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    mainFrame.BackgroundTransparency = 0.15
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

    local backgroundBlur = Instance.new("Frame")
    backgroundBlur.Size = UDim2.new(1, 20, 1, 20)
    backgroundBlur.Position = UDim2.new(-0.04, 0, -0.04, 0)
    backgroundBlur.BackgroundColor3 = Color3.new(0, 0, 0)
    backgroundBlur.BackgroundTransparency = 0.75
    backgroundBlur.Parent = mainFrame
    Instance.new("UICorner", backgroundBlur).CornerRadius = UDim.new(0, 18)
    local blurStroke = Instance.new("UIStroke")
    blurStroke.Color = Color3.fromRGB(70, 70, 70)
    blurStroke.Thickness = 1.5
    blurStroke.Parent = backgroundBlur
    
    -- Verificar posição do frame periodicamente para mantê-lo na tela
    local frameCheckConn = nil
    frameCheckConn = RunService.RenderStepped:Connect(function()
        if not mainFrame or not mainFrame.Parent then
            if frameCheckConn then
                pcall(function() frameCheckConn:Disconnect() end)
                frameCheckConn = nil
            end
            return
        end
        
        if mainFrame.Visible then
            keepFrameOnScreen(mainFrame)
        end
    end)

    return screenGui, mainFrame
end

-- Cabeçalho e abas
local function createHeaderAndTabs(mainFrame)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, -20, 0, 40)
    header.Position = UDim2.new(0, 10, 0, 10)
    header.BackgroundTransparency = 0.8
    header.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    
    local headerLabel = Instance.new("TextLabel")
    headerLabel.Size = UDim2.new(1, 0, 1, 0)
    headerLabel.Text = "Tkst painel emotes"
    headerLabel.TextSize = 22
    headerLabel.Font = Enum.Font.GothamBlack
    headerLabel.BackgroundTransparency = 1
    headerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerLabel.TextStrokeTransparency = 0.8
    headerLabel.TextStrokeColor3 = Color3.fromRGB(100, 100, 100)
    headerLabel.Parent = header

    local tabFrame = Instance.new("Frame")
    tabFrame.Size = UDim2.new(1, -20, 0, 36)
    tabFrame.Position = UDim2.new(0, 10, 0, 60)
    tabFrame.BackgroundTransparency = 1
    tabFrame.Parent = mainFrame

    local emoteTabButton = Instance.new("TextButton")
    emoteTabButton.Size = UDim2.new(0.5, -5, 1, 0)
    emoteTabButton.Position = UDim2.new(0, 0, 0, 0)
    emoteTabButton.Text = "Emotes"
    emoteTabButton.TextSize = 15
    emoteTabButton.Font = Enum.Font.GothamBold
    emoteTabButton.TextColor3 = Color3.new(1, 1, 1)
    emoteTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    emoteTabButton.Parent = tabFrame
    Instance.new("UICorner", emoteTabButton).CornerRadius = UDim.new(0, 8)
    createGradient(emoteTabButton)
    local emoteTabStroke = Instance.new("UIStroke")
    emoteTabStroke.Color = Color3.fromRGB(255, 100, 100)
    emoteTabStroke.Thickness = 1.5
    emoteTabStroke.Parent = emoteTabButton

    local configTabButton = Instance.new("TextButton")
    configTabButton.Size = UDim2.new(0.5, -5, 1, 0)
    configTabButton.Position = UDim2.new(0.5, 5, 0, 0)
    configTabButton.Text = "Configurações"
    configTabButton.TextSize = 15
    configTabButton.Font = Enum.Font.GothamBold
    configTabButton.TextColor3 = Color3.new(1, 1, 1)
    configTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    configTabButton.Parent = tabFrame
    Instance.new("UICorner", configTabButton).CornerRadius = UDim.new(0, 8)
    createGradient(configTabButton)
    local configTabStroke = Instance.new("UIStroke")
    configTabStroke.Color = Color3.fromRGB(100, 100, 100)
    configTabStroke.Thickness = 1
    configTabStroke.Parent = configTabButton

    -- Implementar arrasto pelo cabeçote
    local headerDragConn = nil
    local headerChangeConn = nil
    
    headerDragConn = header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDraggingPanel = true
            panelDragStart = input.Position
            panelStartPos = mainFrame.Position
            
            local inputEndConn = nil
            inputEndConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDraggingPanel = false
                    if inputEndConn then
                        pcall(function() inputEndConn:Disconnect() end)
                        inputEndConn = nil
                    end
                end
            end)
        end
    end)
    
    headerChangeConn = header.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or 
            input.UserInputType == Enum.UserInputType.Touch) and isDraggingPanel then
            local delta = input.Position - panelDragStart
            local newPos = UDim2.new(
                panelStartPos.X.Scale, 
                panelStartPos.X.Offset + delta.X,
                panelStartPos.Y.Scale,
                panelStartPos.Y.Offset + delta.Y
            )
            mainFrame.Position = newPos
        end
    end)

    return emoteTabButton, configTabButton, emoteTabStroke, configTabStroke
end

-- Painel de emotes
local function createEmotePanel(mainFrame)
    local emotePanel = Instance.new("Frame")
    emotePanel.Size = UDim2.new(1, -20, 1, -110)
    emotePanel.Position = UDim2.new(0, 10, 0, 100)
    emotePanel.BackgroundTransparency = 1
    emotePanel.Visible = true
    emotePanel.Parent = mainFrame

    local searchBox = Instance.new("TextBox")
    searchBox.PlaceholderText = "🔍 Buscar por nome ou ID..."
    searchBox.Size = UDim2.new(1, -20, 0, 38)
    searchBox.Position = UDim2.new(0, 10, 0, 10)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 16
    searchBox.TextColor3 = Color3.new(1, 1, 1)
    searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    searchBox.BorderSizePixel = 0
    searchBox.ClearTextOnFocus = true  -- Melhor para dispositivos móveis
    searchBox.Parent = emotePanel
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)
    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = Color3.fromRGB(80, 80, 80)
    searchStroke.Thickness = 1
    searchStroke.Parent = searchBox

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 6
    scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
    scroll.BackgroundTransparency = 1
    scroll.ScrollingEnabled = true
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y
    scroll.ElasticBehavior = Enum.ElasticBehavior.Never
    scroll.Parent = emotePanel

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0, 120, 0, 140)
    gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
    gridLayout.StartCorner = Enum.StartCorner.TopLeft
    gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    gridLayout.Parent = scroll

    return emotePanel, searchBox, scroll
end

-- Painel de configurações
local function createConfigPanel(mainFrame)
    local configPanel = Instance.new("Frame")
    configPanel.Size = UDim2.new(1, -20, 1, -110)
    configPanel.Position = UDim2.new(0, 10, 0, 100)
    configPanel.BackgroundTransparency = 1
    configPanel.Visible = false
    configPanel.Parent = mainFrame

    local configHeader = Instance.new("TextLabel")
    configHeader.Size = UDim2.new(1, -20, 0, 40)
    configHeader.Position = UDim2.new(0, 10, 0, 10)
    configHeader.Text = "Configurações"
    configHeader.TextSize = 20
    configHeader.Font = Enum.Font.GothamBold
    configHeader.BackgroundTransparency = 1
    configHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    configHeader.Parent = configPanel

    local creditsLabel = Instance.new("TextLabel")
    creditsLabel.Size = UDim2.new(1, -20, 0, 30)
    creditsLabel.Position = UDim2.new(0, 10, 0, 60)
    creditsLabel.Text = "By Creator: Kauam\n ttk: Tekscripts\n Rlx: FXZGHS1"
    creditsLabel.TextSize = 16
    creditsLabel.Font = Enum.Font.Gotham
    creditsLabel.TextColor3 = Color3.new(1, 1, 1)
    creditsLabel.BackgroundTransparency = 1
    creditsLabel.Parent = configPanel

    local loopToggle = Instance.new("TextButton")
    loopToggle.Size = UDim2.new(0, 140, 0, 38)
    loopToggle.Position = UDim2.new(0, 10, 0, 100)
    loopToggle.Text = "Loop: Desligado"
    loopToggle.TextSize = 14
    loopToggle.Font = Enum.Font.Gotham
    loopToggle.TextColor3 = Color3.new(1, 1, 1)
    loopToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    loopToggle.Parent = configPanel
    Instance.new("UICorner", loopToggle).CornerRadius = UDim.new(0, 8)
    createGradient(loopToggle)

    local closeGuiButton = Instance.new("TextButton")
    closeGuiButton.Size = UDim2.new(0, 140, 0, 38)
    closeGuiButton.Position = UDim2.new(0, 10, 0, 150)
    closeGuiButton.Text = "Fechar GUI"
    closeGuiButton.TextSize = 14
    closeGuiButton.Font = Enum.Font.Gotham
    closeGuiButton.TextColor3 = Color3.new(1, 1, 1)
    closeGuiButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
    closeGuiButton.Parent = configPanel
    Instance.new("UICorner", closeGuiButton).CornerRadius = UDim.new(0, 8)
    createGradient(closeGuiButton)

    return configPanel, loopToggle, closeGuiButton
end

-- Botão de arrasto
local function createDragButton(screenGui)
    local dragButton = Instance.new("TextButton")
    dragButton.Size = UDim2.new(0, 70, 0, 70)
    dragButton.Position = UDim2.new(0.5, 200, 0.5, -200)
    dragButton.Text = "fechar"
    dragButton.TextSize = 18
    dragButton.Font = Enum.Font.GothamBlack
    dragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dragButton.BackgroundTransparency = 0.2
    dragButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    dragButton.Parent = screenGui
    Instance.new("UICorner", dragButton).CornerRadius = UDim.new(0, 35)
    local dragStroke = Instance.new("UIStroke")
    dragStroke.Color = Color3.fromRGB(120, 120, 120)
    dragStroke.Thickness = 1.5
    dragStroke.Parent = dragButton
    local buttonGradient = createGradient(dragButton)
    buttonGradient.Transparency = NumberSequence.new(0.4)
    
    -- Manter o botão na tela
    local buttonCheckConn = nil
    buttonCheckConn = RunService.RenderStepped:Connect(function()
        if not dragButton or not dragButton.Parent then
            if buttonCheckConn then
                pcall(function() buttonCheckConn:Disconnect() end)
                buttonCheckConn = nil
            end
            return
        end
        
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local buttonSize = dragButton.AbsoluteSize
        local buttonPos = dragButton.AbsolutePosition
        
        local newPosX = math.clamp(buttonPos.X, 0, viewportSize.X - buttonSize.X)
        local newPosY = math.clamp(buttonPos.Y, 0, viewportSize.Y - buttonSize.Y)
        
        if newPosX ~= buttonPos.X or newPosY ~= buttonPos.Y then
            dragButton.Position = UDim2.new(0, newPosX, 0, newPosY)
        end
    end)

    return dragButton
end

-- Função para gerenciar animações de forma suave
local function playEmoteAnimation(emoteId)
    if not character or not humanoid then return end
    
    -- Limpar conexão existente
    if currentStopConn then
        pcall(function() currentStopConn:Disconnect() end)
        currentStopConn = nil
    end
    
    -- Parar animação atual se existir
    if emoteTrack then
        emoteTrack:Stop(0.3) -- Parar com fade de 0.3 segundos para suavidade
        emoteTrack = nil
    end
    
    -- Criar e configurar nova animação
    local animation = Instance.new("Animation")
    animation.AnimationId = "rbxassetid://" .. emoteId
    
    -- Carregar animação com prioridade alta para evitar conflitos
    emoteTrack = humanoid:LoadAnimation(animation)
    emoteTrack.Priority = Enum.AnimationPriority.Action
    emoteTrack.Looped = loopEmote
    
    -- Configurar transições suaves
    emoteTrack.Stopped:Connect(function()
        currentAnimationState = "idle"
        -- Permitir que as animações padrão do personagem voltem naturalmente
        task.delay(0.1, function()
            if currentAnimationState == "idle" then
                -- Não precisamos fazer nada, as animações padrão já devem ter voltado
            end
        end)
    end)
    
    -- Iniciar com fade suave
    currentAnimationState = "emoting"
    emoteTrack:Play(0.3) -- Iniciar com fade de 0.3 segundos para suavidade
    
    -- Monitorar movimento do personagem para interromper a animação
    if character and character:FindFirstChild("HumanoidRootPart") then
        local lastPos = character.HumanoidRootPart.Position
        
        -- Usar variável global para a conexão
        currentStopConn = RunService.Heartbeat:Connect(function()
            if not character or not character:FindFirstChild("HumanoidRootPart") or not emoteTrack or not emoteTrack.IsPlaying then
                if currentStopConn then
                    pcall(function() currentStopConn:Disconnect() end)
                    currentStopConn = nil
                end
                return
            end
            
            local pos = character.HumanoidRootPart.Position
            if (pos - lastPos).Magnitude > 0.1 or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                if emoteTrack and emoteTrack.IsPlaying then
                    emoteTrack:Stop(0.3) -- Parar com fade suave
                end
                
                if currentStopConn then
                    pcall(function() currentStopConn:Disconnect() end)
                    currentStopConn = nil
                end
            end
            lastPos = pos
        end)
    end
end

-- Lógica de interação
local function setupInteractions(screenGui, mainFrame, emotePanel, configPanel, emoteTabButton, configTabButton, emoteTabStroke, configTabStroke, loopToggle, closeGuiButton, dragButton, scroll, searchBox)
    -- Efeitos de hover nas abas
    local function addHoverEffect(button, isActive)
        local enterConn = nil
        local leaveConn = nil
        
        enterConn = button.MouseEnter:Connect(function()
            if not button or not button.Parent then
                if enterConn then
                    pcall(function() enterConn:Disconnect() end)
                    enterConn = nil
                end
                return
            end
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
        end)
        
        leaveConn = button.MouseLeave:Connect(function()
            if not button or not button.Parent then
                if leaveConn then
                    pcall(function() leaveConn:Disconnect() end)
                    leaveConn = nil
                end
                return
            end
            local targetColor = (isActive() and Color3.fromRGB(60, 60, 60)) or Color3.fromRGB(40, 40, 40)
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        end)
    end
    
    addHoverEffect(emoteTabButton, function() return emotePanel.Visible end)
    addHoverEffect(configTabButton, function() return configPanel.Visible end)

    -- Lógica de abas
    local function setActiveTab(tab)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if tab == "emotes" then
            emotePanel.Visible = true
            configPanel.Visible = false
            emoteTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            configTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            emoteTabStroke.Color = Color3.fromRGB(255, 100, 100)
            configTabStroke.Color = Color3.fromRGB(100, 100, 100)
        else
            emotePanel.Visible = false
            configPanel.Visible = true
            emoteTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            configTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            emoteTabStroke.Color = Color3.fromRGB(100, 100, 100)
            configTabStroke.Color = Color3.fromRGB(255, 100, 100)
        end
        TweenService:Create(emotePanel, tweenInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(configPanel, tweenInfo, {BackgroundTransparency = 1}):Play()
    end

    emoteTabButton.MouseButton1Click:Connect(function() setActiveTab("emotes") end)
    configTabButton.MouseButton1Click:Connect(function() setActiveTab("config") end)

    -- Configurações
    loopToggle.MouseButton1Click:Connect(function()
        loopEmote = not loopEmote
        loopToggle.Text = "Loop: " .. (loopEmote and "Ligado" or "Desligado")
        
        -- Atualizar animação atual se estiver tocando
        if emoteTrack and emoteTrack.IsPlaying then
            emoteTrack.Looped = loopEmote
        end
    end)

    closeGuiButton.MouseButton1Click:Connect(function()
        -- Limpar conexão existente
        if currentStopConn then
            pcall(function() currentStopConn:Disconnect() end)
            currentStopConn = nil
        end
        
        if emoteTrack then
            emoteTrack:Stop(0.3)
        end
        screenGui:Destroy()
    end)

    -- Arrasto do botão
    local function updateDrag(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(dragButton, TweenInfo.new(0.2), {Position = newPos}):Play()
    end

    dragButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        mainFrame.Visible = not isMinimized
        dragButton.Text = isMinimized and "abrir" or "fechar"
        TweenService:Create(dragButton, TweenInfo.new(0.2), {Size = isMinimized and UDim2.new(0, 65, 0, 65) or UDim2.new(0, 70, 0, 70)}):Play()
    end)

    local dragBeganConn = nil
    local dragChangedConn = nil
    local inputChangedConn = nil
    
    dragBeganConn = dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = dragButton.Position
            
            local inputEndConn = nil
            inputEndConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if inputEndConn then
                        pcall(function() inputEndConn:Disconnect() end)
                        inputEndConn = nil
                    end
                end
            end)
        end
    end)

    dragChangedConn = dragButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    inputChangedConn = UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            updateDrag(input)
        end
    end)

    -- Suporte a scroll por toque otimizado
    local touchStart, lastTouchPos
    local scrollVelocity = Vector2.new(0, 0)
    local scrollInertia = 0.92
    local isScrolling = false
    
    local scrollBeganConn = nil
    local scrollChangedConn = nil
    local scrollEndedConn = nil
    
    scrollBeganConn = scroll.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStart = input.Position
            lastTouchPos = input.Position
            scrollVelocity = Vector2.new(0, 0)
            isScrolling = true
            scroll.ScrollingEnabled = true
        end
    end)

    scrollChangedConn = scroll.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch and touchStart then
            local delta = input.Position - lastTouchPos
            scrollVelocity = Vector2.new(0, delta.Y * 0.5)
            local newCanvasPos = scroll.CanvasPosition - Vector2.new(0, delta.Y * 0.5)
            scroll.CanvasPosition = newCanvasPos
            lastTouchPos = input.Position
        end
    end)

    scrollEndedConn = scroll.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            touchStart = nil
            lastTouchPos = nil
            
            -- Aplicar inércia ao scroll
            if isScrolling then
                isScrolling = false
                
                local inertiaConnection = nil
                inertiaConnection = RunService.RenderStepped:Connect(function()
                    if not scroll or not scroll.Parent then
                        if inertiaConnection then
                            pcall(function() inertiaConnection:Disconnect() end)
                            inertiaConnection = nil
                        end
                        return
                    end
                    
                    if scrollVelocity.Magnitude < 0.1 then
                        if inertiaConnection then
                            pcall(function() inertiaConnection:Disconnect() end)
                            inertiaConnection = nil
                        end
                        return
                    end
                    
                    scrollVelocity = scrollVelocity * scrollInertia
                    scroll.CanvasPosition = scroll.CanvasPosition - Vector2.new(0, scrollVelocity.Y)
                end)
            end
        end
    end)
end

-- Funções de emotes
local function carregarEmotes()
    local tentativas = 0
    local maxTentativas = 6
    local delayEntreTentativas = 3
    local statusLabel = nil
    
    -- Criar label de status para feedback
    local function criarStatusLabel(parent)
        if statusLabel then return end
        
        statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, 0, 0, 30)
        statusLabel.Position = UDim2.new(0, 0, 0.5, -15)
        statusLabel.BackgroundTransparency = 0.5
        statusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        statusLabel.TextSize = 14
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Text = "Carregando emotes..."
        statusLabel.ZIndex = 10
        statusLabel.Parent = parent
        
        local spinner = createLoadingSpinner(statusLabel)
        spinner.Size = UDim2.new(0, 20, 0, 20)
        spinner.Position = UDim2.new(0, 5, 0.5, -10)
        
        return statusLabel
    end
    
    local screenGui = player:WaitForChild("PlayerGui"):FindFirstChild("EmoteGUI")
    if screenGui then
        local mainFrame = screenGui:FindFirstChild("MainFrame") or screenGui:FindFirstChildWhichIsA("Frame")
        if mainFrame then
            statusLabel = criarStatusLabel(mainFrame)
        end
    end

    while tentativas < maxTentativas do
        if statusLabel then
            statusLabel.Text = "Carregando emotes... Tentativa " .. (tentativas + 1) .. "/" .. maxTentativas
        end
        
        local req = getRequest()
        local success, response = pcall(function()
            return req({Url = emoteDataURL, Method = "GET"})
        end)
        
        if success and response and response.Success then
            local success2, decoded = pcall(function()
                return HttpService:JSONDecode(response.Body)
            end)
            
            if success2 and decoded then
                emoteList = decoded
                if statusLabel then
                    statusLabel:Destroy()
                end
                return true
            end
        end
        
        tentativas += 1
        if tentativas < maxTentativas then
            if statusLabel then
                statusLabel.Text = "Falha ao carregar. Tentando novamente em " .. delayEntreTentativas .. "s..."
            end
            wait(delayEntreTentativas)
        end
    end
    
    if statusLabel then
        statusLabel.Text = "Falha ao carregar emotes após " .. maxTentativas .. " tentativas."
        task.delay(3, function()
            if statusLabel and statusLabel.Parent then
                statusLabel:Destroy()
            end
        end)
    end
    
    warn("Falha ao carregar emotes após " .. maxTentativas .. " tentativas.")
    return false
end

local function criarCard(emote, scroll)
    local btn = Instance.new("ImageButton")
    btn.Name = emote.nome
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Size = UDim2.new(0, 120, 0, 140)
    btn.Parent = scroll
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(70, 70, 70)
    btnStroke.Thickness = 1.5
    btnStroke.Parent = btn

    -- Usar diretamente o formato rbxthumb:// com o idCatalogo
    btn.Image = "rbxthumb://type=Asset&id=" .. emote.idCatalogo .. "&w=420&h=420"
    btn.ImageTransparency = 0
    
    -- Container para o texto com clipping
    local txtContainer = Instance.new("Frame")
    txtContainer.Size = UDim2.new(1, 0, 0, 25)
    txtContainer.Position = UDim2.new(0, 0, 1, -25)
    txtContainer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    txtContainer.BackgroundTransparency = 0.5
    txtContainer.ClipsDescendants = true
    txtContainer.ZIndex = 2
    txtContainer.Parent = btn
    
    -- Texto com suporte a quebra de linha
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, -10, 1, 0)
    txt.Position = UDim2.new(0, 5, 0, 0)
    txt.BackgroundTransparency = 1
    txt.Text = emote.nome
    txt.TextSize = 12
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.GothamBold
    txt.TextXAlignment = Enum.TextXAlignment.Center
    txt.TextYAlignment = Enum.TextYAlignment.Center
    txt.TextWrapped = true
    txt.ZIndex = 3
    txt.Parent = txtContainer
    
    local txtStroke = Instance.new("UIStroke")
    txtStroke.Color = Color3.fromRGB(50, 50, 50)
    txtStroke.Thickness = 0.5
    txtStroke.Parent = txt

    local enterConn = nil
    local leaveConn = nil
    local clickConn = nil
    
    enterConn = btn.MouseEnter:Connect(function()
        if not btn or not btn.Parent then
            if enterConn then
                pcall(function() enterConn:Disconnect() end)
                enterConn = nil
            end
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 100, 100)}):Play()
    end)

    leaveConn = btn.MouseLeave:Connect(function()
        if not btn or not btn.Parent then
            if leaveConn then
                pcall(function() leaveConn:Disconnect() end)
                leaveConn = nil
            end
            return
        end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(70, 70, 70)}):Play()
    end)

    clickConn = btn.MouseButton1Click:Connect(function()
        if not btn or not btn.Parent then
            if clickConn then
                pcall(function() clickConn:Disconnect() end)
                clickConn = nil
            end
            return
        end
        
        if not humanoid then return end
        playEmoteAnimation(emote.idEmote)
    end)
end

-- Função otimizada para atualizar a lista de emotes
local function atualizarLista(filtro, scroll)
    -- Limpar cards existentes
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIGridLayout" then
            child:Destroy()
        end
    end
    
    -- Filtrar emotes em lote para melhor performance
    local filteredEmotes = {}
    local filtroLower = ""
    
    -- Verificar se o filtro é válido
    if filtro and type(filtro) == "string" then
        filtroLower = string.lower(filtro)
    end
    
    -- Primeiro, coletar todos os emotes que correspondem ao filtro
    for _, emote in ipairs(emoteList) do
        local nome = string.lower(tostring(emote.nome or ""))
        local idCatalogo = tostring(emote.idCatalogo or "")
        
        if filtroLower == "" or 
           string.find(nome, filtroLower, 1, true) or 
           string.find(idCatalogo, filtroLower, 1, true) then
            table.insert(filteredEmotes, emote)
        end
    end
    
    -- Processar em lotes para não travar a interface
    local function processarLote(inicio, fim)
        for i = inicio, math.min(fim, #filteredEmotes) do
            criarCard(filteredEmotes[i], scroll)
        end
        
        -- Atualizar tamanho do canvas após cada lote
        local cardsPerRow = math.floor((scroll.AbsoluteSize.X - 20) / (120 + 15))
        if cardsPerRow < 1 then cardsPerRow = 1 end
        local rowCount = math.ceil(#filteredEmotes / cardsPerRow)
        scroll.CanvasSize = UDim2.new(0, 0, 0, rowCount * (140 + 15) + 15)
    end
    
    -- Processar em lotes de 10 emotes por frame
    local batchSize = 10
    local totalEmotes = #filteredEmotes
    local currentIndex = 1
    
    local function processNextBatch()
        if currentIndex <= totalEmotes then
            processarLote(currentIndex, currentIndex + batchSize - 1)
            currentIndex = currentIndex + batchSize
            
            -- Agendar próximo lote para o próximo frame
            task.spawn(processNextBatch)
        end
    end
    
    processNextBatch()
end

-- Inicialização
local function initialize()
    local screenGui, mainFrame = createGUI()
    local emoteTabButton, configTabButton, emoteTabStroke, configTabStroke = createHeaderAndTabs(mainFrame)
    local emotePanel, searchBox, scroll = createEmotePanel(mainFrame)
    local configPanel, loopToggle, closeGuiButton = createConfigPanel(mainFrame)
    local dragButton = createDragButton(screenGui)

    setupInteractions(screenGui, mainFrame, emotePanel, configPanel, emoteTabButton, configTabButton, emoteTabStroke, configTabStroke, loopToggle, closeGuiButton, dragButton, scroll, searchBox)

    if carregarEmotes() then
        atualizarLista("", scroll)
        
        -- Sistema de pesquisa otimizado com debounce mais eficiente
        local searchDelay = 0.3  -- Reduzido para melhor responsividade
        local lastSearchText = ""
        local searchTimer = nil
        
        local searchConn = nil
        searchConn = searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            if not searchBox or not searchBox.Parent then
                if searchConn then
                    pcall(function() searchConn:Disconnect() end)
                    searchConn = nil
                end
                return
            end
            
            local currentText = searchBox.Text
            
            -- Cancelar timer anterior se existir
            if searchTimer then
                task.cancel(searchTimer)
                searchTimer = nil
            end
            
            -- Se o texto não mudou, não fazer nada
            if currentText == lastSearchText then return end
            lastSearchText = currentText
            
            -- Configurar novo timer
            searchTimer = task.delay(searchDelay, function()
                if searchBox and searchBox.Parent and searchBox.Text == currentText then
                    atualizarLista(currentText, scroll)
                end
                searchTimer = nil
            end)
        end)
    end
end

initialize()
