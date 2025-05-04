-- Serviços
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local jsonUrl = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/Animations.json"
local animations = {}
local customAnimations = {
    climb = nil, fall = nil, idle = nil, jump = nil,
    run = nil, swim = nil, walk = nil
}
local animationTypes = {
    ["Climb"] = "climb", ["Fall"] = "fall", ["Idle"] = "idle",
    ["Jump"] = "jump", ["Run"] = "run", ["Swim"] = "swim", ["Walk"] = "walk"
}

-- Requisição HTTP
local httpRequest = (typeof(request) == "function" and request) or
    (typeof(http_request) == "function" and http_request) or
    (syn and syn.request) or (fluxus and fluxus.request) or
    (trigon and trigon.request) or (codex and codex.request)
assert(httpRequest, "Executor não suporta requisições HTTP.")

-- Arquivos
local writeFile, readFile, isFile =
    writefile or (fluxus and fluxus.writefile) or (trigon and trigon.writefile) or (codex and codex.writefile),
    readfile or (fluxus and fluxus.readfile) or (trigon and trigon.readfile) or (codex and codex.readfile),
    isfile or (fluxus and fluxus.isfile) or (trigon and trigon.isfile) or (codex and codex.isfile) or function() return false end
assert(writeFile and readFile, "Executor não suporta escrita de arquivos.")

-- Funções
local function loadAnimations()
    local success, err = pcall(function()
        local res = httpRequest({ Url = jsonUrl, Method = "GET" })
        assert(res.StatusCode == 200, "Erro ao carregar animações: " .. (err or "StatusCode não 200"))
        animations = HttpService:JSONDecode(res.Body)
    end)
    if not success then
        warn("Falha ao carregar animações: " .. (err or "Desconhecido"))
        animations = {}
    end
end

local function saveCustomAnimations()
    writeFile("emotes.json", HttpService:JSONEncode(customAnimations))
end

local function loadSavedAnimations()
    if isFile("emotes.json") then
        local data = readFile("emotes.json")
        customAnimations = HttpService:JSONDecode(data)
    end
end

local function savePanelPosition(position)
    writeFile("panel_position.json", HttpService:JSONEncode({x = position.X.Offset, y = position.Y.Offset}))
end

local function getInitialPosition()
    if isFile("panel_position.json") then
        local data = readFile("panel_position.json")
        local pos = HttpService:JSONDecode(data)
        return UDim2.new(0, pos.x, 0, pos.y)
    else
        local screenSize = workspace.CurrentCamera.ViewportSize
        local initialX = (screenSize.X - 350) / 2 -- Centraliza com base no tamanho da UI (350 de largura)
        local initialY = (screenSize.Y - 500) / 2 -- Centraliza com base no tamanho da UI (500 de altura)
        return UDim2.new(0, initialX, 0, initialY)
    end
end

local function waitForAnimateStructure(char)
    local animate = char:WaitForChild("Animate", 10)
    if not animate then return nil end
    local expected = {
        { "walk", "WalkAnim" }, { "idle", "Animation1" }, { "idle", "Animation2" },
        { "jump", "JumpAnim" }, { "fall", "FallAnim" }, { "run", "RunAnim" },
        { "swim", "Swim" }, { "climb", "ClimbAnim" }
    }
    for _, p in ipairs(expected) do
        local folder = animate:FindFirstChild(p[1])
        if folder then folder:FindFirstChild(p[2]) end
    end
    return animate
end

local function applyCustomAnimations(char)
    local animate = waitForAnimateStructure(char)
    if not animate then return end
    local function setAnim(folderName, animName, id)
        if not id then return end
        local folder = animate:FindFirstChild(folderName)
        if folder then
            local anim = folder:FindFirstChild(animName)
            if anim and anim:IsA("Animation") then
                anim.AnimationId = "rbxassetid://" .. id
            end
        end
    end
    setAnim("walk", "WalkAnim", customAnimations.walk)
    setAnim("idle", "Animation1", customAnimations.idle)
    setAnim("idle", "Animation2", customAnimations.idle)
    setAnim("jump", "JumpAnim", customAnimations.jump)
    setAnim("fall", "FallAnim", customAnimations.fall)
    setAnim("run", "RunAnim", customAnimations.run)
    setAnim("swim", "Swim", customAnimations.swim)
    setAnim("climb", "ClimbAnim", customAnimations.climb)
end

local function reloadAnimations(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animate = waitForAnimateStructure(char)
    if not (humanoid and animate) then return end

    -- Para todas as animações em reprodução
    for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop()
    end

    -- Reaplica as animações personalizadas
    applyCustomAnimations(char)

    -- Força a reinicialização do script Animate
    local animateScript = char:FindFirstChild("Animate")
    if animateScript then
        animateScript.Disabled = true
        task.wait()
        animateScript.Disabled = false
    end

    -- Reaplica o estado atual do humanoid
    local state = humanoid:GetState()
    if state == Enum.HumanoidStateType.Running then
        humanoid.WalkSpeed = 16
    elseif state == Enum.HumanoidStateType.Jumping then
        humanoid.Jump = true
    end
end

local function connectCharacter(char)
    local humanoid = char:WaitForChild("Humanoid", 10)
    if not humanoid then return end
    local animate = waitForAnimateStructure(char)
    if not animate then return end
    task.wait(0.5) -- Espera para garantir que o personagem esteja completamente carregado
    applyCustomAnimations(char)
    task.wait(0.1)
    reloadAnimations(char)
end

local function applyAnimation(idAnimacao, feedbackLabel)
    for _, anim in pairs(animations) do
        if anim.idAnimacao == idAnimacao then
            local typ = animationTypes[anim.nome]
            if typ and customAnimations[typ] ~= idAnimacao then
                customAnimations[typ] = idAnimacao
                saveCustomAnimations()
                if player.Character then
                    reloadAnimations(player.Character)
                end
                if feedbackLabel then
                    feedbackLabel.Text = "Animação '" .. anim.nome .. "' aplicada!"
                    feedbackLabel.TextColor3 = Color3.new(0, 1, 0)
                    feedbackLabel.Parent.Visible = true
                    task.delay(3, function() feedbackLabel.Parent.Visible = false end)
                end
                -- Atualiza a lista dinamicamente
                populateList()
            end
            break
        end
    end
end

-- UI Moderna
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "AnimationPanel"
screenGui.IgnoreGuiInset = true
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = getInitialPosition() -- Usa a nova função para posição inicial
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.ClipsDescendants = true
mainFrame.Active = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
titleBar.BackgroundTransparency = 0.2

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -10, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "Animações"
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Botão de reset para centralizar a UI
local resetButton = Instance.new("TextButton", titleBar)
resetButton.Size = UDim2.new(0, 100, 0, 30)
resetButton.Position = UDim2.new(1, -110, 0, 5)
resetButton.Text = "Reset Position"
resetButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resetButton.TextColor3 = Color3.new(1, 1, 1)
resetButton.Font = Enum.Font.Gotham
resetButton.TextSize = 14
Instance.new("UICorner", resetButton).CornerRadius = UDim.new(0, 5)

resetButton.MouseButton1Click:Connect(function()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local initialX = (screenSize.X - mainFrame.Size.X.Offset) / 2
    local initialY = (screenSize.Y - mainFrame.Size.Y.Offset) / 2
    mainFrame.Position = UDim2.new(0, initialX, 0, initialY)
    savePanelPosition(mainFrame.Position)
end)

local feedbackFrame = Instance.new("Frame", mainFrame)
feedbackFrame.Size = UDim2.new(1, -20, 0, 30)
feedbackFrame.Position = UDim2.new(0, 10, 0, 45)
feedbackFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
feedbackFrame.BackgroundTransparency = 0.5
feedbackFrame.Visible = false
Instance.new("UICorner", feedbackFrame).CornerRadius = UDim.new(0, 5)

local feedbackLabel = Instance.new("TextLabel", feedbackFrame)
feedbackLabel.Size = UDim2.new(1, -10, 1, 0)
feedbackLabel.Position = UDim2.new(0, 5, 0, 0)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.TextColor3 = Color3.new(1, 1, 1)
feedbackLabel.Font = Enum.Font.GothamBold
feedbackLabel.TextSize = 14
feedbackLabel.TextXAlignment = Enum.TextXAlignment.Center

local searchBox = Instance.new("TextBox", mainFrame)
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 80)
searchBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
searchBox.TextColor3 = Color3.new(1, 1, 1)
searchBox.PlaceholderText = "Pesquisar animações..."
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 14
Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 5)
searchBox.Text = ""

local scrollingFrame = Instance.new("ScrollingFrame", mainFrame)
scrollingFrame.Size = UDim2.new(1, -20, 1, -120)
scrollingFrame.Position = UDim2.new(0, 10, 0, 120)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local uiListLayout = Instance.new("UIListLayout", scrollingFrame)
uiListLayout.Padding = UDim.new(0, 10)
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.FillDirection = Enum.FillDirection.Vertical

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end)

-- Arraste suave com limites e ajuste de visibilidade
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        savePanelPosition(mainFrame.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newPosX = startPos.X.Offset + delta.X
        local newPosY = startPos.Y.Offset + delta.Y

        local screenSize = workspace.CurrentCamera.ViewportSize
        local screenWidth = screenSize.X
        local screenHeight = screenSize.Y

        local minX = 0
        local maxX = screenWidth - mainFrame.Size.X.Offset
        local minY = 0
        local maxY = screenHeight - mainFrame.Size.Y.Offset

        newPosX = math.clamp(newPosX, minX, maxX)
        newPosY = math.clamp(newPosY, minY, maxY)

        local newPos = UDim2.new(0, newPosX, 0, newPosY)
        TweenService:Create(mainFrame, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = newPos}):Play()
    end
end)

-- Retrair/Expandir com duplo toque
local lastTapTime = 0
local isCollapsed = false
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local currentTime = tick()
        if currentTime - lastTapTime < 0.3 then
            isCollapsed = not isCollapsed
            local targetSize = isCollapsed and UDim2.new(0, 350, 0, 40) or UDim2.new(0, 350, 0, 500)
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
        end
        lastTapTime = currentTime
    end
end)

-- Ajustar posição quando o tamanho da tela muda
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local currentPos = mainFrame.Position
    local newX = math.clamp(currentPos.X.Offset, 0, screenSize.X - mainFrame.Size.X.Offset)
    local newY = math.clamp(currentPos.Y.Offset, 0, screenSize.Y - mainFrame.Size.Y.Offset)
    mainFrame.Position = UDim2.new(0, newX, 0, newY)
    savePanelPosition(mainFrame.Position)
end)

-- Listar animações agrupadas por pacote
local function populateList()
    for _, child in ipairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local buttonHeight = 60
    local separatorHeight = 10
    local visibleCount = 0

    -- Organiza animações por pacote
    local animationsByBundle = {}
    for _, anim in ipairs(animations) do
        local bundleName = anim.bundleNome or "Sem Pacote"
        if not animationsByBundle[bundleName] then
            animationsByBundle[bundleName] = {}
        end
        table.insert(animationsByBundle[bundleName], anim)
    end

    -- Cria a lista com cabeçalhos de pacote e separadores
    for bundleName, anims in pairs(animationsByBundle) do
        -- Cabeçalho do pacote
        local headerFrame = Instance.new("Frame", scrollingFrame)
        headerFrame.Size = UDim2.new(1, 0, 0, 30)
        headerFrame.BackgroundTransparency = 1
        headerFrame.LayoutOrder = visibleCount

        local headerLabel = Instance.new("TextLabel", headerFrame)
        headerLabel.Size = UDim2.new(1, -10, 1, 0)
        headerLabel.Position = UDim2.new(0, 10, 0, 0)
        headerLabel.Text = bundleName
        headerLabel.TextColor3 = Color3.fromRGB(0.9, 0.9, 0.9)
        headerLabel.BackgroundTransparency = 1
        headerLabel.Font = Enum.Font.GothamBold
        headerLabel.TextSize = 16
        headerLabel.TextXAlignment = Enum.TextXAlignment.Left

        visibleCount = visibleCount + 1

        -- Animações do pacote
        for _, anim in ipairs(anims) do
            local name = anim.nome or "Desconhecido"
            local id = anim.idAnimacao or "?"
            local searchText = searchBox.Text:lower() or ""

            if searchText == "" or string.match(string.lower(name .. bundleName), searchText) then
                local buttonFrame = Instance.new("Frame", scrollingFrame)
                buttonFrame.Size = UDim2.new(1, 0, 0, buttonHeight)
                buttonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                buttonFrame.BackgroundTransparency = 0
                buttonFrame.BorderSizePixel = 1
                buttonFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
                buttonFrame.LayoutOrder = visibleCount
                Instance.new("UICorner", buttonFrame).CornerRadius = UDim.new(0, 5)

                local animLabel = Instance.new("TextLabel", buttonFrame)
                animLabel.Size = UDim2.new(1, -30, 0, 20)
                animLabel.Position = UDim2.new(0, 20, 0, 5)
                animLabel.Text = name
                animLabel.TextColor3 = Color3.new(1, 1, 1)
                animLabel.BackgroundTransparency = 1
                animLabel.Font = Enum.Font.GothamSemibold
                animLabel.TextSize = 14
                animLabel.TextXAlignment = Enum.TextXAlignment.Left

                -- Adiciona marcação se a animação está em uso
                local marker = Instance.new("Frame", buttonFrame)
                marker.Size = UDim2.new(0, 10, 0, 10)
                marker.Position = UDim2.new(0, 5, 0, 10)
                marker.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                marker.BackgroundTransparency = 1
                Instance.new("UICorner", marker).CornerRadius = UDim.new(1, 0)
                for animType, currentId in pairs(customAnimations) do
                    if currentId == id and animationTypes[anim.nome] == animType then
                        marker.BackgroundTransparency = 0
                        break
                    end
                end

                local button = Instance.new("TextButton", buttonFrame)
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundTransparency = 1
                button.Text = ""
                button.MouseButton1Click:Connect(function()
                    applyAnimation(id, feedbackLabel)
                    local originalColor = buttonFrame.BackgroundColor3
                    buttonFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                    task.delay(0.2, function()
                        buttonFrame.BackgroundColor3 = originalColor
                    end)
                end)

                visibleCount = visibleCount + 1
            end
        end

        -- Separador
        local separator = Instance.new("Frame", scrollingFrame)
        separator.Size = UDim2.new(1, -20, 0, 2)
        separator.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        separator.BackgroundTransparency = 0.5
        separator.LayoutOrder = visibleCount
        visibleCount = visibleCount + 1
    end

    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y + 10)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(populateList)

-- Inicialização
loadAnimations()
task.wait(0.1)
loadSavedAnimations()
if player.Character then connectCharacter(player.Character) end
player.CharacterAdded:Connect(function(char)
    connectCharacter(char)
    screenGui.Enabled = true
    mainFrame.Visible = true
end)
player.CharacterRemoving:Connect(function()
    screenGui.Enabled = true
    mainFrame.Visible = true
end)
populateList()