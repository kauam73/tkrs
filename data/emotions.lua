--[[ Roblox Floating GUI Emote Player | por Kauam ]]--

local function getRequest()
    return (syn and syn.request) or
           (fluxus and fluxus.request) or
           (http and http.request) or
           (krnl and krnl.request) or
           (getgenv().request) or
           request
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character and character:WaitForChild("Humanoid")

local emoteDataURL = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/emotes.json"
local emoteList = {}
local emoteTrack = nil
local loopEmote = false
local dragging = false
local dragInput, dragStart, startPos
local isMinimized = false

-- Atualizar character e humanoid quando o personagem renasce
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    if emoteTrack then
        emoteTrack:Stop()
        emoteTrack = nil
    end
end)

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

local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "EmoteGUI"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 460, 0, 420)
mainFrame.Position = UDim2.new(0.5, -230, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 14)

local backgroundBlur = Instance.new("Frame", mainFrame)
backgroundBlur.Size = UDim2.new(1, 20, 1, 20)
backgroundBlur.Position = UDim2.new(-0.04, 0, -0.04, 0)
backgroundBlur.BackgroundColor3 = Color3.new(0, 0, 0)
backgroundBlur.BackgroundTransparency = 0.75
Instance.new("UICorner", backgroundBlur).CornerRadius = UDim.new(0, 18)
local blurStroke = Instance.new("UIStroke", backgroundBlur)
blurStroke.Color = Color3.fromRGB(70, 70, 70)
blurStroke.Thickness = 1.5

-- Cabeçalho
local header = Instance.new("TextLabel", mainFrame)
header.Size = UDim2.new(1, -20, 0, 40)
header.Position = UDim2.new(0, 10, 0, 10)
header.Text = "Emotes Tekscripts"
header.TextSize = 22
header.Font = Enum.Font.GothamBlack
header.BackgroundTransparency = 1
header.TextColor3 = Color3.fromRGB(255, 255, 255)
header.TextStrokeTransparency = 0.8
header.TextStrokeColor3 = Color3.fromRGB(100, 100, 100)

-- Abas
local tabFrame = Instance.new("Frame", mainFrame)
tabFrame.Size = UDim2.new(1, -20, 0, 36)
tabFrame.Position = UDim2.new(0, 10, 0, 60)
tabFrame.BackgroundTransparency = 1

local emoteTabButton = Instance.new("TextButton", tabFrame)
emoteTabButton.Size = UDim2.new(0.5, -5, 1, 0)
emoteTabButton.Position = UDim2.new(0, 0, 0, 0)
emoteTabButton.Text = "Emotes"
emoteTabButton.TextSize = 15
emoteTabButton.Font = Enum.Font.GothamBold
emoteTabButton.TextColor3 = Color3.new(1, 1, 1)
emoteTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Instance.new("UICorner", emoteTabButton).CornerRadius = UDim.new(0, 8)
createGradient(emoteTabButton)
local emoteTabStroke = Instance.new("UIStroke", emoteTabButton)
emoteTabStroke.Color = Color3.fromRGB(255, 100, 100)
emoteTabStroke.Thickness = 1.5

local configTabButton = Instance.new("TextButton", tabFrame)
configTabButton.Size = UDim2.new(0.5, -5, 1, 0)
configTabButton.Position = UDim2.new(0.5, 5, 0, 0)
configTabButton.Text = "Configurações"
configTabButton.TextSize = 15
configTabButton.Font = Enum.Font.GothamBold
configTabButton.TextColor3 = Color3.new(1, 1, 1)
configTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", configTabButton).CornerRadius = UDim.new(0, 8)
createGradient(configTabButton)
local configTabStroke = Instance.new("UIStroke", configTabButton)
configTabStroke.Color = Color3.fromRGB(100, 100, 100)
configTabStroke.Thickness = 1

-- Efeitos de hover nas abas
local function addHoverEffect(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
    end)
    button.MouseLeave:Connect(function()
        if button == emoteTabButton and emotePanel.Visible or button == configTabButton and configPanel.Visible then
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
        else
            TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
        end
    end)
end
addHoverEffect(emoteTabButton)
addHoverEffect(configTabButton)

-- Painel de emotes
local emotePanel = Instance.new("Frame", mainFrame)
emotePanel.Size = UDim2.new(1, -20, 1, -110)
emotePanel.Position = UDim2.new(0, 10, 0, 100)
emotePanel.BackgroundTransparency = 1
emotePanel.Visible = true

local searchBox = Instance.new("TextBox", emotePanel)
searchBox.PlaceholderText = "🔍 Buscar por nome ou ID..."
searchBox.Size = UDim2.new(1, -20, 0, 38)
searchBox.Position = UDim2.new(0, 10, 0, 10)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 16
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
searchBox.BorderSizePixel = 0
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 8)
local searchStroke = Instance.new("UIStroke", searchBox)
searchStroke.Color = Color3.fromRGB(80, 80, 80)
searchStroke.Thickness = 1

local scroll = Instance.new("ScrollingFrame", emotePanel)
scroll.Size = UDim2.new(1, -20, 1, -60)
scroll.Position = UDim2.new(0, 10, 0, 50)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 6
scroll.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 120)
scroll.BackgroundTransparency = 1
scroll.ScrollingEnabled = true
scroll.ScrollingDirection = Enum.ScrollingDirection.Y
scroll.ElasticBehavior = Enum.ElasticBehavior.Never -- Scroll firme, sem elasticidade

local gridLayout = Instance.new("UIGridLayout", scroll)
gridLayout.CellSize = UDim2.new(0, 120, 0, 140)
gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
gridLayout.StartCorner = Enum.StartCorner.TopLeft
gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Painel de configurações
local configPanel = Instance.new("Frame", mainFrame)
configPanel.Size = UDim2.new(1, -20, 1, -110)
configPanel.Position = UDim2.new(0, 10, 0, 100)
configPanel.BackgroundTransparency = 1
configPanel.Visible = false

local configHeader = Instance.new("TextLabel", configPanel)
configHeader.Size = UDim2.new(1, -20, 0, 40)
configHeader.Position = UDim2.new(0, 10, 0, 10)
configHeader.Text = "Configurações"
configHeader.TextSize = 20
configHeader.Font = Enum.Font.GothamBold
configHeader.BackgroundTransparency = 1
configHeader.TextColor3 = Color3.fromRGB(255, 255, 255)

local creditsLabel = Instance.new("TextLabel", configPanel)
creditsLabel.Size = UDim2.new(1, -20, 0, 30)
creditsLabel.Position = UDim2.new(0, 10, 0, 60)
creditsLabel.Text = "Créditos: Kauam Henrique"
creditsLabel.TextSize = 16
creditsLabel.Font = Enum.Font.Gotham
creditsLabel.TextColor3 = Color3.new(1, 1, 1)
creditsLabel.BackgroundTransparency = 1

local loopToggle = Instance.new("TextButton", configPanel)
loopToggle.Size = UDim2.new(0, 140, 0, 38)
loopToggle.Position = UDim2.new(0, 10, 0, 100)
loopToggle.Text = "Loop: Desligado"
loopToggle.TextSize = 14
loopToggle.Font = Enum.Font.Gotham
loopToggle.TextColor3 = Color3.new(1, 1, 1)
loopToggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Instance.new("UICorner", loopToggle).CornerRadius = UDim.new(0, 8)
createGradient(loopToggle)

local closeGuiButton = Instance.new("TextButton", configPanel)
closeGuiButton.Size = UDim2.new(0, 140, 0, 38)
closeGuiButton.Position = UDim2.new(0, 10, 0, 150)
closeGuiButton.Text = "Fechar GUI"
closeGuiButton.TextSize = 14
closeGuiButton.Font = Enum.Font.Gotham
closeGuiButton.TextColor3 = Color3.new(1, 1, 1)
closeGuiButton.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
Instance.new("UICorner", closeGuiButton).CornerRadius = UDim.new(0, 8)
createGradient(closeGuiButton)

loopToggle.MouseButton1Click:Connect(function()
    loopEmote = not loopEmote
    loopToggle.Text = "Loop: " .. (loopEmote and "Ligado" or "Desligado")
end)

closeGuiButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Lógica de abas com transição suave
local function setActiveTab(tab)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if tab == "emotes" then
        TweenService:Create(emotePanel, tweenInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(configPanel, tweenInfo, {BackgroundTransparency = 1}):Play()
        emotePanel.Visible = true
        configPanel.Visible = false
        emoteTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        configTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        emoteTabStroke.Color = Color3.fromRGB(255, 100, 100)
        configTabStroke.Color = Color3.fromRGB(100, 100, 100)
    else
        TweenService:Create(emotePanel, tweenInfo, {BackgroundTransparency = 1}):Play()
        TweenService:Create(configPanel, tweenInfo, {BackgroundTransparency = 1}):Play()
        emotePanel.Visible = false
        configPanel.Visible = true
        emoteTabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        configTabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        emoteTabStroke.Color = Color3.fromRGB(100, 100, 100)
        configTabStroke.Color = Color3.fromRGB(255, 100, 100)
    end
end

emoteTabButton.MouseButton1Click:Connect(function()
    setActiveTab("emotes")
end)

configTabButton.MouseButton1Click:Connect(function()
    setActiveTab("config")
end)

-- Botão de arrasto
local dragButton = Instance.new("TextButton", screenGui)
dragButton.Size = UDim2.new(0, 70, 0, 70)
dragButton.Position = UDim2.new(0.5, 200, 0.5, -200)
dragButton.Text = "tek"
dragButton.TextSize = 18
dragButton.Font = Enum.Font.GothamBlack
dragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dragButton.BackgroundTransparency = 0.2
dragButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", dragButton).CornerRadius = UDim.new(0, 35)
local dragStroke = Instance.new("UIStroke", dragButton)
dragStroke.Color = Color3.fromRGB(120, 120, 120)
dragStroke.Thickness = 1.5

local buttonGradient = createGradient(dragButton)
buttonGradient.Transparency = NumberSequence.new(0.4)

local function updateDrag(input)
    local delta = input.Position - dragStart
    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    local tween = TweenService:Create(dragButton, TweenInfo.new(0.2), {Position = newPos})
    tween:Play()
end

dragButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    mainFrame.Visible = not isMinimized
    dragButton.Text = isMinimized and "kauam" or "tek"
    TweenService:Create(dragButton, TweenInfo.new(0.2), {Size = isMinimized and UDim2.new(0, 65, 0, 65) or UDim2.new(0, 70, 0, 70)}):Play()
end)

dragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = dragButton.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

dragButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        updateDrag(input)
    end
end)

-- Suporte a scroll por toque
local touchStart, lastTouchPos
scroll.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = input.Position
        lastTouchPos = input.Position
        scroll.ScrollingEnabled = true
    end
end)

scroll.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch and touchStart then
        local delta = input.Position - lastTouchPos
        local newCanvasPos = scroll.CanvasPosition - Vector2.new(0, delta.Y * 0.5)
        TweenService:Create(scroll, TweenInfo.new(0.1), {CanvasPosition = newCanvasPos}):Play()
        lastTouchPos = input.Position
    end
end)

scroll.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        touchStart = nil
        lastTouchPos = nil
    end
end)

-- Animação de carregamento
local loadingSpinner = Instance.new("ImageLabel")
loadingSpinner.Image = "rbxassetid://10101260412"
loadingSpinner.Size = UDim2.new(0.8, 0, 0.8, 0)
loadingSpinner.Position = UDim2.new(0.1, 0, 0.1, 0)
loadingSpinner.BackgroundTransparency = 1
loadingSpinner.ZIndex = 2

local spinAnimation = RunService.RenderStepped:Connect(function(delta)
    loadingSpinner.Rotation = loadingSpinner.Rotation + (delta * 360)
end)

local function createLoadingSpinner(parent)
    local spinner = loadingSpinner:Clone()
    spinner.Parent = parent
    return spinner
end

local function carregarEmotes()
    local req = getRequest()
    local response = req({Url = emoteDataURL, Method = "GET"})
    local json = HttpService:JSONDecode(response.Body)
    emoteList = json
end

local function criarCard(emote)
    local btn = Instance.new("ImageButton", scroll)
    btn.Name = emote.nome
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.ImageTransparency = 1
    btn.Size = UDim2.new(0, 120, 0, 140)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Color = Color3.fromRGB(70, 70, 70)
    btnStroke.Thickness = 1.5

    local spinner = createLoadingSpinner(btn)
    local textLabel = Instance.new("TextLabel", btn)
    textLabel.Text = "Carregando..."
    textLabel.Size = UDim2.new(1, 0, 0, 20)
    textLabel.Position = UDim2.new(0, 0, 0.5, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Center

    task.spawn(function()
        local thumbUrl = string.format(
            "https://thumbnails.roblox.com/v1/assets?assetIds=%s&returnPolicy=PlaceHolder&size=250x250&format=Png&isCircular=false",
            emote.idCatalogo
        )

        local req = getRequest()
        local response = req({Url = thumbUrl, Method = "GET"})
        local thumbData = HttpService:JSONDecode(response.Body)

        if thumbData and thumbData.data and #thumbData.data > 0 and thumbData.data[1].imageUrl then
            btn.Image = thumbData.data[1].imageUrl
            textLabel:Destroy()
            spinner:Destroy()
            btn.ImageTransparency = 0
        else
            textLabel.Text = "no image"
            spinner.ImageColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)

    local txt = Instance.new("TextLabel", btn)
    txt.Size = UDim2.new(1, 0, 0, 25)
    txt.Position = UDim2.new(0, 0, 1, -25)
    txt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    txt.BackgroundTransparency = 0.5
    txt.Text = emote.nome
    txt.TextSize = 12
    txt.TextColor3 = Color3.new(1, 1, 1)
    txt.Font = Enum.Font.GothamBold
    txt.TextXAlignment = Enum.TextXAlignment.Center
    txt.ZIndex = 2
    local txtStroke = Instance.new("UIStroke", txt)
    txtStroke.Color = Color3.fromRGB(50, 50, 50)
    txtStroke.Thickness = 0.5

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 100, 100)}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
        TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(70, 70, 70)}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        if not humanoid then return end

        -- Parar todas as animações ativas para evitar conflitos
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end

        -- Limpar a animação atual, se existir
        if emoteTrack then
            emoteTrack:Stop()
            emoteTrack = nil
        end

        -- Carregar e reproduzir a nova animação
        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. emote.idEmote
        emoteTrack = humanoid:LoadAnimation(animation)
        emoteTrack.Looped = loopEmote
        emoteTrack:Play()

        -- Monitorar movimento para interromper a animação
        if character and character:FindFirstChild("HumanoidRootPart") then
            local lastPos = character.HumanoidRootPart.Position
            local stopConn = RunService.Heartbeat:Connect(function()
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    if emoteTrack then emoteTrack:Stop() end
                    stopConn:Disconnect()
                    return
                end
                local pos = character.HumanoidRootPart.Position
                if (pos - lastPos).Magnitude > 0.1 or humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                    if emoteTrack then emoteTrack:Stop() end
                    stopConn:Disconnect()
                end
                lastPos = pos
            end)

            emoteTrack.Stopped:Connect(function()
                stopConn:Disconnect()
            end)
        end
    end)
end

local function atualizarLista(filtro)
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("GuiObject") and child ~= gridLayout then
            child:Destroy()
        end
    end
    local filteredEmotes = {}
    for _, emote in ipairs(emoteList) do
        if filtro == "" or emote.nome:lower():find(filtro:lower()) or emote.idCatalogo == filtro then
            table.insert(filteredEmotes, emote)
            criarCard(emote)
        end
    end
    -- Ajustar CanvasSize dinamicamente
    local cardsPerRow = math.floor((scroll.AbsoluteSize.X - 20) / (120 + 15))
    local rowCount = math.ceil(#filteredEmotes / cardsPerRow)
    scroll.CanvasSize = UDim2.new(0, 0, 0, rowCount * (140 + 15) + 15)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    atualizarLista(searchBox.Text)
end)

carregarEmotes()
atualizarLista("")