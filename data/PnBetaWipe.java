-- Core
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Módulo de Utilitários
local Utils = {}

--##################################
-- RETORNA A FUNÇÃO DE REQUISIÇÃO HTTP SUPORTADA PELO EXECUTOR
--##################################
function Utils.getRequest()
    return (syn and syn.request)
        or (fluxus and fluxus.request)
        or (http and http.request)
        or (krnl and krnl.request)
        or (getgenv().request)
        or request
end

--##################################
-- RETORNA A API DE SISTEMA DE ARQUIVOS SUPORTADA PELO EXECUTOR
--##################################
function Utils.getFileSystem()
    local funcs = {
        writeFile = writefile
            or (fluxus and fluxus.writefile)
            or (trigon and trigon.writefile)
            or (codex and codex.writefile),

        readFile = readfile
            or (fluxus and fluxus.readFile)
            or (trigon and trigon.readFile)
            or (codex and codex.readFile),

        isFile = isfile
            or (fluxus and fluxus.isfile)
            or (trigon and trigon.isfile)
            or (codex and codex.isfile)
            or function() return false end
    }

    assert(funcs.writeFile and funcs.readFile, "Executor não suporta escrita/leitura de arquivos.")
    return funcs
end

Utils.fs = Utils.getFileSystem()

--##################################
-- GARANTE QUE O FRAME FIQUE DENTRO DA TELA
-- Corrigido para ajustar a posição de forma robusta
--##################################
function Utils.keepFrameOnScreen(frame)
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local frameSize = frame.AbsoluteSize
    local framePos = frame.AbsolutePosition

    -- Calcula a nova posição X e Y, garantindo que a borda direita e inferior não saiam da tela.
    local newX = math.clamp(framePos.X, 0, viewportSize.X - frameSize.X)
    local newY = math.clamp(framePos.Y, 0, viewportSize.Y - frameSize.Y)

    if newX ~= framePos.X or newY ~= framePos.Y then
        -- A diferença de offset necessária para ajustar a posição
        local xOffset = newX - framePos.X
        local yOffset = newY - framePos.Y

        -- Cria uma nova UDim2 com o novo offset
        frame.Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset + xOffset,
                                   frame.Position.Y.Scale, frame.Position.Y.Offset + yOffset)
    end
end

-- Módulo de Configurações
local Config = {
    GUI_NAME = "EmoteAnimGUI",
    EMOTE_DATA_URL = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/emotes.json",
    ANIMATION_DATA_URL = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/Animations.json",
    SAVED_ANIMATIONS_FILE = "tks_animations.json",
    MAX_RETRIES = 6,
    RETRY_DELAY = 3,
    CORNER_RADIUS = UDim.new(0, 8),
    HEADER_CORNER_RADIUS = UDim.new(0, 8),
    MAIN_FRAME_CORNER_RADIUS = UDim.new(0, 14),
    DRAG_BUTTON_CORNER_RADIUS = UDim.new(0, 35),
    BORDER_THICKNESS = 1.5,
    SMALL_BORDER_THICKNESS = 1,
    TWEEN_DURATION = 0.2,
    TWEEN_EASING_STYLE = Enum.EasingStyle.Quad,
    TWEEN_EASING_DIRECTION = Enum.EasingDirection.Out,
    COLOR_BACKGROUND_DARK = Color3.fromRGB(20, 20, 20),
    COLOR_BACKGROUND_TRANSPARENCY = 0.15,
    COLOR_BLUR_BACKGROUND = Color3.new(0, 0, 0),
    COLOR_BLUR_TRANSPARENCY = 0.75,
    COLOR_STROKE_LIGHT = Color3.fromRGB(70, 70, 70),
    COLOR_HEADER_BACKGROUND = Color3.fromRGB(40, 40, 40),
    COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255),
    COLOR_TEXT_STROKE_GREY = Color3.fromRGB(100, 100, 100),
    COLOR_TAB_ACTIVE_BG = Color3.fromRGB(60, 60, 60),
    COLOR_TAB_INACTIVE_BG = Color3.fromRGB(40, 40, 40),
    COLOR_ACCENT_PRIMARY = Color3.fromRGB(255, 100, 100),
    COLOR_ACCENT_SECONDARY = Color3.fromRGB(200, 80, 80),
    COLOR_SEARCHBOX_BG = Color3.fromRGB(35, 35, 35),
    COLOR_CARD_BG = Color3.fromRGB(35, 35, 35),
    COLOR_CARD_HOVER = Color3.fromRGB(50, 50, 50),
    COLOR_CREDITS_TEXT = Color3.new(1, 1, 1),
    COLOR_LOOP_TOGGLE_BG = Color3.fromRGB(50, 50, 50),
    COLOR_CLOSE_BUTTON_BG = Color3.fromRGB(80, 40, 40),
    COLOR_DRAG_BUTTON_BG = Color3.fromRGB(35, 35, 35),
    COLOR_SCROLLBAR = Color3.fromRGB(120, 120, 120),
    COLOR_STATUS_LABEL_BG = Color3.fromRGB(30, 30, 30),
    COLOR_CARD_TEXT_BG = Color3.fromRGB(0, 0, 0),
    COLOR_CARD_TEXT_STROKE = Color3.fromRGB(50, 50, 50),
    COLOR_CATEGORY_HEADER_BG = Color3.fromRGB(30, 30, 30),
    FONT_HEADER = Enum.Font.GothamBlack,
    FONT_TABS = Enum.Font.GothamBold,
    FONT_DEFAULT = Enum.Font.Gotham,
    FONT_CARD = Enum.Font.GothamBold,
    FONT_DRAG_BUTTON = Enum.Font.GothamBlack,
    MAIN_FRAME_SIZE = UDim2.new(0, 480, 0, 450),
    HEADER_HEIGHT = 40,
    TAB_HEIGHT = 36,
    SEARCH_BOX_HEIGHT = 38,
    CARD_SIZE = UDim2.new(0, 120, 0, 140),
    CARD_PADDING = UDim2.new(0, 10, 0, 10),
    DRAG_BUTTON_SIZE_NORMAL = UDim2.new(0, 70, 0, 70),
    DRAG_BUTTON_SIZE_MINIMIZED = UDim2.new(0, 65, 0, 65),
    LOOP_TOGGLE_SIZE = UDim2.new(0, 140, 0, 38),
    CLOSE_BUTTON_SIZE = UDim2.new(0, 140, 0, 38),
    SCROLLBAR_THICKNESS = 6,
    CATEGORY_HEADER_HEIGHT = 28,
    ANIMATION_FADE_DURATION = 0.3,
    SEARCH_DEBOUNCE_DELAY = 0.3,
    SCROLL_INERTIA = 0.92,
}

-- Módulo de Construtores de UI
local UIBuilder = {}

local ConnectionManager = {}

--##############################
-- CRIA UMA NOVA INSTÂNCIA DO CONNECTIONMANAGER
--##############################
function ConnectionManager:New()
    local self = setmetatable({}, { __index = ConnectionManager })
    self.connections = {}
    return self
end

--##############################
-- ADICIONA UMA CONEXÃO AO GERENCIADOR
--##############################
function ConnectionManager:Add(connection)
    table.insert(self.connections, connection)
end

--##############################
-- REMOVE UMA CONEXÃO DO GERENCIADOR
--##############################
function ConnectionManager:Remove(connection)
    for i, conn in ipairs(self.connections) do
        if conn == connection then
            table.remove(self.connections, i)
            break
        end
    end
end

--##############################
-- DESCONECTA TODAS AS CONEXÕES E LIMPA A LISTA
--##############################
function ConnectionManager:DisconnectAll()
    for _, conn in ipairs(self.connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    self.connections = {}
end

--##################################
-- CRIA UM UIGradient CONFIGURADO
--##################################
function UIBuilder.createUIGradient(parent, color1, color2, rotation)
    local gradient = Instance.new("UIGradient")

    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1 or Config.COLOR_ACCENT_PRIMARY),
        ColorSequenceKeypoint.new(1, color2 or Config.COLOR_ACCENT_SECONDARY)
    }
    gradient.Rotation = rotation or 90

    gradient.Parent = parent
    return gradient
end

--##################################
-- CRIA UM UICORNER CONFIGURADO
--##################################
function UIBuilder.createUICorner(parent, radius)
    local corner = Instance.new("UICorner")

    corner.CornerRadius = radius or Config.CORNER_RADIUS
    corner.Parent = parent
    return corner
end

--##############################
-- CRIA UM UISTROKE CONFIGURADO
--##############################
function UIBuilder.createUIStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")

    stroke.Color = color or Config.COLOR_STROKE_LIGHT
    stroke.Thickness = thickness or Config.BORDER_THICKNESS

    stroke.Parent = parent
    return stroke
end

--##################################
-- CRIA UM COMPONENTE DE CRÉDITOS HORIZONTAL
--##################################
function UIBuilder.createCreditsSwitcher(parent, position, creditsList, textSize, font, textColor, spacing, interval, effect)
    interval = interval or 2
    spacing = spacing or 6
    effect = effect or "suav"

    local TweenService = game:GetService("TweenService")

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 0)
    container.Position = position
    container.AnchorPoint = Vector2.new(0.5, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = parent

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 0, 0)
    bg.AutomaticSize = Enum.AutomaticSize.Y
    bg.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    bg.BackgroundTransparency = 0.2
    bg.BorderSizePixel = 0
    bg.Parent = container

    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", bg)
    stroke.Color = Color3.fromRGB(50, 50, 50)
    stroke.Thickness = 1
    stroke.Transparency = 0.6

    local layout = Instance.new("UIListLayout", bg)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, spacing)

    local padding = Instance.new("UIPadding", bg)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.LayoutOrder = 0
    titleLabel.Size = UDim2.new(1, 0, 0, 0)
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextSize = textSize * 0.7
    titleLabel.Font = font
    titleLabel.TextColor3 = textColor:Lerp(Color3.new(1,1,1), 0.6)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Top
    titleLabel.Text = creditsList[1] and creditsList[1].title or ""
    titleLabel.Parent = bg

    local creditLabel = titleLabel:Clone()
    creditLabel.LayoutOrder = 1
    creditLabel.TextSize = textSize
    creditLabel.TextColor3 = textColor
    creditLabel.Text = creditsList[1] and creditsList[1].text or ""
    creditLabel.Parent = bg

    local currentIndex = 1
    local running = false

    local function typing(label, text, speed)
        for i = #label.Text, 0, -1 do
            label.Text = label.Text:sub(1, i)
            task.wait(speed * 0.5)
        end
        for i = 1, #text do
            label.Text = text:sub(1, i)
            task.wait(speed)
        end
    end

    local function smooth(label1, label2, newTitle, newText)
        running = true
        local out1 = TweenService:Create(label1, TweenInfo.new(0.3), { TextTransparency = 1 })
        local out2 = TweenService:Create(label2, TweenInfo.new(0.3), { TextTransparency = 1 })
        out1:Play() out2:Play()
        out1.Completed:Wait()

        label1.Text = newTitle
        label2.Text = newText

        TweenService:Create(label1, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
        TweenService:Create(label2, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()

        running = false
    end

    local function next()
        if running then return end
        currentIndex = currentIndex % #creditsList + 1
        local entry = creditsList[currentIndex]
        if effect == "typing" then
            running = true
            task.spawn(function()
                typing(titleLabel, entry.title or "", 0.03)
                typing(creditLabel, entry.text or "", 0.03)
                running = false
            end)
        else
            task.spawn(smooth, titleLabel, creditLabel, entry.title or "", entry.text or "")
        end
    end

    task.spawn(function()
        while true do
            task.wait(interval)
            next()
        end
    end)

    return container
end

--##################################
-- CRIA UM FRAME CONFIGURADO COM OPCIONAIS
--##################################
function UIBuilder.createFrame(
    parent,
    size,
    position,
    backgroundColor,
    backgroundTransparency,
    borderSizePixel,
    active,
    clipsDescendants,
    cornerRadius,
    strokeColor,
    strokeThickness
)
    local frame = Instance.new("Frame")

    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = backgroundColor or Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = backgroundTransparency or 0
    frame.BorderSizePixel = borderSizePixel or 0
    frame.Active = active or false
    frame.ClipsDescendants = clipsDescendants or false

    frame.Parent = parent

    if cornerRadius then
        UIBuilder.createUICorner(frame, cornerRadius)
    end

    if strokeColor then
        UIBuilder.createUIStroke(frame, strokeColor, strokeThickness)
    end

    return frame
end

--##################################
-- CRIA UM TEXTLABEL CONFIGURADO
--##################################
function UIBuilder.createTextLabel(
    parent,
    size,
    position,
    text,
    textSize,
    font,
    backgroundTransparency,
    textColor,
    textStrokeTransparency,
    textStrokeColor,
    textXAlignment,
    textYAlignment,
    textWrapped
)
    local label = Instance.new("TextLabel")

    label.Size = size
    label.Position = position
    label.Text = text
    label.TextSize = textSize
    label.Font = font

    label.BackgroundTransparency = backgroundTransparency or 1
    label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)

    label.TextStrokeTransparency = textStrokeTransparency or 1
    label.TextStrokeColor3 = textStrokeColor or Color3.new(0, 0, 0)

    label.TextXAlignment = textXAlignment or Enum.TextXAlignment.Center
    label.TextYAlignment = textYAlignment or Enum.TextYAlignment.Center

    label.TextWrapped = textWrapped or false
    label.Parent = parent

    return label
end

--###################################
-- CRIA UM TEXTBUTTON CONFIGURADO COM OPCIONAIS
--###################################
function UIBuilder.createTextButton(
    parent,
    size,
    position,
    text,
    textSize,
    font,
    textColor,
    backgroundColor,
    backgroundTransparency,
    cornerRadius,
    strokeColor,
    strokeThickness,
    gradient
)
    local button = Instance.new("TextButton")

    button.Size = size
    button.Position = position
    button.Text = text
    button.TextSize = textSize
    button.Font = font

    button.TextColor3 = textColor or Color3.new(1, 1, 1)
    button.BackgroundColor3 = backgroundColor or Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = backgroundTransparency or 0

    button.Parent = parent

    if cornerRadius then
        UIBuilder.createUICorner(button, cornerRadius)
    end

    if strokeColor then
        UIBuilder.createUIStroke(button, strokeColor, strokeThickness)
    end

    if gradient then
        UIBuilder.createUIGradient(button)
    end

    return button
end

--##############################
-- CRIA UM IMAGELABEL CONFIGURADO
--##############################
function UIBuilder.createImageLabel(parent, size, position, image, backgroundTransparency, zIndex)
    local label = Instance.new("ImageLabel")

    label.Image = image
    label.Size = size
    label.Position = position

    label.BackgroundTransparency = backgroundTransparency or 1
    label.ZIndex = zIndex or 1

    label.Parent = parent
    return label
end

--##################################
-- CRIA UM TEXTBOX CONFIGURADO COM OPCIONAIS
--##################################
function UIBuilder.createTextBox(
    parent,
    size,
    position,
    placeholderText,
    textSize,
    font,
    textColor,
    backgroundColor,
    borderSizePixel,
    clearTextOnFocus,
    cornerRadius,
    strokeColor,
    strokeThickness
)
    local textBox = Instance.new("TextBox")

    textBox.PlaceholderText = placeholderText
    textBox.Size = size
    textBox.Position = position
    textBox.Font = font
    textBox.TextSize = textSize
    
    textBox.Text = "" -- Garante que o texto inicial é vazio

    textBox.TextColor3 = textColor or Color3.new(1, 1, 1)
    textBox.BackgroundColor3 = backgroundColor or Color3.fromRGB(255, 255, 255)

    textBox.BorderSizePixel = borderSizePixel or 0
    textBox.ClearTextOnFocus = clearTextOnFocus or false

    textBox.Parent = parent

    if cornerRadius then
        UIBuilder.createUICorner(textBox, cornerRadius)
    end

    if strokeColor then
        UIBuilder.createUIStroke(textBox, strokeColor, strokeThickness)
    end

    return textBox
end

--###########################################
-- CRIA UM SCROLLINGFRAME CONFIGURADO E PERSONALIZADO
--###########################################
function UIBuilder.createScrollingFrame(
    parent,
    size,
    position,
    scrollBarThickness,
    scrollBarImageColor,
    backgroundTransparency,
    scrollingEnabled,
    scrollingDirection,
    elasticBehavior
)
    local scroll = Instance.new("ScrollingFrame")

    scroll.Size = size
    scroll.Position = position
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    scroll.ScrollBarThickness = scrollBarThickness or 6
    scroll.ScrollBarImageColor3 = scrollBarImageColor or Color3.fromRGB(180, 180, 180)

    scroll.BackgroundTransparency = backgroundTransparency or 0.15
    scroll.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    scroll.BorderSizePixel = 0
    scroll.ClipsDescendants = true
    scroll.ZIndex = 2

    scroll.ScrollingEnabled = scrollingEnabled ~= nil and scrollingEnabled or true
    scroll.ScrollingDirection = scrollingDirection or Enum.ScrollingDirection.Y
    scroll.ElasticBehavior = elasticBehavior or Enum.ElasticBehavior.Always -- estilo iOS com bounce

    -- Arredondamento do frame principal
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = scroll

    -- Sombra interna elegante
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 0)
    stroke.Thickness = 1
    stroke.Transparency = 0.8
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = scroll

    -- Comportamento natural de arrastar com toque e mouse já é nativo
    -- Mas você pode ajustar o modo de scroll suave assim:
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.ScrollingDirection = Enum.ScrollingDirection.Y

    scroll.Parent = parent

    return scroll
end

--##################################
-- CRIA UM UIGridLayout CONFIGURADO
--##################################
function UIBuilder.createUIGridLayout(parent, cellSize, cellPadding, startCorner, horizontalAlignment)
    local gridLayout = Instance.new("UIGridLayout")

    gridLayout.CellSize = cellSize or Config.CARD_SIZE
    gridLayout.CellPadding = cellPadding or Config.CARD_PADDING
    gridLayout.StartCorner = startCorner or Enum.StartCorner.TopLeft
    gridLayout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center

    gridLayout.Parent = parent
    return gridLayout
end

--##################################
-- CRIA UM UIListLayout CONFIGURADO
--##################################
function UIBuilder.createUIListLayout(parent, padding, horizontalAlignment, verticalAlignment, sortOrder)
    local list = Instance.new("UIListLayout")

    list.Padding = padding or UDim.new(0, 5)
    list.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
    list.VerticalAlignment = verticalAlignment or Enum.VerticalAlignment.Top
    list.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder

    list.Parent = parent
    return list
end

--##################################
-- CRIA UM LOADING SPINNER ANIMADO
--##################################
function UIBuilder.createLoadingSpinner(parent)
    local spinner = UIBuilder.createImageLabel(
        parent,
        UDim2.new(0.8, 0, 0.8, 0),
        UDim2.new(0.1, 0, 0.1, 0),
        "rbxassetid://10101260412",
        1,
        2
    )

    local connectionManager = ConnectionManager:New()

    local renderConn = RunService.RenderStepped:Connect(function(delta)
        if not spinner or not spinner.Parent then
            connectionManager:DisconnectAll()
            return
        end
        spinner.Rotation = spinner.Rotation + (delta * 360)
    end)

    connectionManager:Add(renderConn)
    spinner.Destroying:Connect(function()
        connectionManager:DisconnectAll()
    end)

    return spinner
end

-- Módulo Principal do Player
local PlayerController = {}

PlayerController.emoteList = {}
PlayerController.emoteTrack = nil
PlayerController.loopEmote = false
PlayerController.currentEmoteStopConn = nil
PlayerController.animationList = {}
PlayerController.customAnimations = {climb = nil, fall = nil, idle = nil, jump = nil, run = nil, swim = nil, walk = nil}

PlayerController.animationTypes = {["Climb"] = "climb", ["Fall"] = "fall", ["Idle"] = "idle", ["Jump"] = "jump", ["Run"] = "run", ["Swim"] = "swim", ["Walk"] = "walk"}

PlayerController.isMinimized = false
PlayerController.isDraggingPanel = false
PlayerController.panelDragStart = nil
PlayerController.panelStartPos = nil
PlayerController.draggingButton = false
PlayerController.dragButtonStart = nil
PlayerController.dragButtonStartPos = nil
PlayerController.connections = ConnectionManager:New()

--##############################
-- INICIALIZA O PLAYERCONTROLLER
--##############################
function PlayerController:init()
    if PlayerGui:FindFirstChild(Config.GUI_NAME) then
        return
    end

    self:setupCharacterListeners()
    self:createGUI()
    self:setupInteractions()
    self:loadAllData()
end

--########################################################
-- CONFIGURA LISTENERS PARA EVENTOS DE RESPAWN DO PERSONAGEM
--########################################################
function PlayerController:setupCharacterListeners()
    local function onCharacter(char)
        self.character = char
        self.humanoid = char:WaitForChild("Humanoid", 5) -- timeout 5s
        if not self.humanoid then
            -- warn("Humanoid não encontrado após respawn.")
            return
        end

        self:cleanupEmoteAnimation()

        local animate = char:WaitForChild("Animate", 5)
        if not animate then
            -- warn("Animate não encontrado após respawn.")
            return
        end

        task.delay(0.1, function()
            self:reloadCharacterAnimations(char)
        end)
    end

    self.connections:Add(player.CharacterAdded:Connect(onCharacter))

    if player.Character then
        onCharacter(player.Character)
    end
end

--##################################################
-- RECARREGA AS ANIMAÇÕES DO PERSONAGEM DE FORMA ROBUSTA
--##################################################
function PlayerController:reloadCharacterAnimations(char)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animate = char:FindFirstChild("Animate")

    if not (humanoid and animate) then
        -- warn("Humanoid ou Animate não encontrado ao tentar recarregar animações.")
        return
    end

    -- Para todas as animações em execução
    for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
        track:Stop(0)
    end

    -- Desativa e reativa o script Animate com atraso para garantir recarregamento
    animate.Disabled = true
    task.wait(0.1) -- Atraso maior para estabilidade

    self:applyCustomAnimationsToCharacter(char)

    animate.Disabled = false

    -- print("Animações recarregadas para o personagem: " .. char.Name)
end

--##############################################################
-- APLICA AS ANIMAÇÕES PERSONALIZADAS AO SCRIPT ANIMATE DO PLAYER
--##############################################################
function PlayerController:applyCustomAnimationsToCharacter(char)
    local animate = char:FindFirstChild("Animate")
    if not animate then
        -- warn("Script Animate não encontrado ao aplicar animações.")
        return
    end

    -- Cria ou atualiza uma animação dentro do Animate
    local function ensureAnimationStructure(folderName, animName, id)
        if not id then return end

        local folder = animate:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folderName
            folder.Parent = animate
            -- print("Criado folder '" .. folderName .. "' em Animate.")
        end

        local anim = folder:FindFirstChild(animName)
        if not anim then
            anim = Instance.new("Animation")
            anim.Name = animName
            anim.Parent = folder
            -- print("Criada animação '" .. animName .. "' em " .. folderName .. ".")
        end

        if anim:IsA("Animation") then
            anim.AnimationId = "rbxassetid://" .. id
        else
            -- warn("Objeto '" .. animName .. "' não é uma Animation.")
        end
    end

    -- Aplicação de cada animação customizada
    ensureAnimationStructure("walk",  "WalkAnim",   self.customAnimations.walk)
    ensureAnimationStructure("idle",  "Animation1", self.customAnimations.idle)
    ensureAnimationStructure("idle",  "Animation2", self.customAnimations.idle)
    ensureAnimationStructure("jump",  "JumpAnim",   self.customAnimations.jump)
    ensureAnimationStructure("fall",  "FallAnim",   self.customAnimations.fall)
    ensureAnimationStructure("run",   "RunAnim",    self.customAnimations.run)
    ensureAnimationStructure("swim",  "Swim",       self.customAnimations.swim)
    ensureAnimationStructure("climb", "ClimbAnim",  self.customAnimations.climb)
end

--##################################
-- CARREGA OS DADOS DAS ANIMAÇÕES ONLINE
--##################################
function PlayerController:loadAnimationsData()
    local attempt = 1

    while attempt <= Config.MAX_RETRIES do
        local success, err = pcall(function()
            local request = Utils.getRequest()
            local res = request({
                Url = Config.ANIMATION_DATA_URL,
                Method = "GET"
            })

            if not res or not res.Success then
                local msg = res and res.StatusMessage or "Falha na requisição"
                error("Erro ao carregar animações: " .. msg)
            end

            self.animationList = HttpService:JSONDecode(res.Body)
        end)

        if success then
            return true
        end

        if attempt == Config.MAX_RETRIES then
            self.animationList = {}
            return false
        end

        task.wait(Config.RETRY_DELAY)
        attempt += 1
    end

    return false
end

--#########################################
-- SALVA AS ANIMAÇÕES PERSONALIZADAS NO ARQUIVO
--#########################################
function PlayerController:saveCustomAnimations()
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(self.customAnimations)
        Utils.fs.writeFile(Config.SAVED_ANIMATIONS_FILE, json)
    end)

    if not success then
        -- warn("[AnimSave] Falha ao salvar animações: " .. tostring(err))
    end
end

--##################################
-- CARREGA AS ANIMAÇÕES PERSONALIZADAS
--##################################
function PlayerController:loadSavedAnimations()
    if not Utils.fs.isFile(Config.SAVED_ANIMATIONS_FILE) then
        -- print("Arquivo não encontrado. Carregando animações padrão.")
        self.customAnimations = {
            climb = nil,
            fall  = nil,
            idle  = nil,
            jump  = nil,
            run   = nil,
            swim  = nil,
            walk  = nil,
        }
        return
    end

    local success, data = pcall(function()
        return Utils.fs.readFile(Config.SAVED_ANIMATIONS_FILE)
    end)

    if not success or not data then
        -- warn("Erro ao ler arquivo: " .. tostring(data))
        return
    end

    local decodedSuccess, decodedData = pcall(function()
        return HttpService:JSONDecode(data)
    end)

    if decodedSuccess then
        self.customAnimations = decodedData
    else
        -- warn("Erro ao decodificar JSON: " .. tostring(decodedData))
    end
end

function PlayerController:applyAnimation(idAnimacao)
    local applied = false
    for _, anim in ipairs(self.animationList) do
        if anim.idAnimacao == idAnimacao then
            local animType = self.animationTypes[anim.nome]
            if animType then
                if self.customAnimations[animType] ~= idAnimacao then
                    self.customAnimations[animType] = idAnimacao
                    self:saveCustomAnimations()
                    if self.character then self:reloadCharacterAnimations(self.character) end
                end
                applied = true
                break
            end
        end
    end
    if self.animationSearchBox then
        self:updateAnimationList(self.animationSearchBox.Text)
    end
end

--#########################
-- SET COMPONENTS INTERFACE GUI
--#########################

function PlayerController:createGUI()
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = Config.GUI_NAME
    self.screenGui.ResetOnSpawn = false
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = PlayerGui

    self.mainFrame = UIBuilder.createFrame(
        self.screenGui,
        Config.MAIN_FRAME_SIZE,
        UDim2.new(0.5, 0, 0.5, 0),
        Config.COLOR_BACKGROUND_DARK,
        Config.COLOR_BACKGROUND_TRANSPARENCY,
        0,
        true,
        true,
        Config.MAIN_FRAME_CORNER_RADIUS
    )
    self.mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)

    local blurFrame = UIBuilder.createFrame(
        self.mainFrame,
        UDim2.new(1, 20, 1, 20),
        UDim2.new(0, -10, 0, -10),
        Config.COLOR_BLUR_BACKGROUND,
        Config.COLOR_BLUR_TRANSPARENCY,
        0,
        false,
        false,
        UDim.new(0, 18),
        Config.COLOR_STROKE_LIGHT,
        Config.BORDER_THICKNESS
    )

    -- Lógica reforçada pra manter o frame sempre dentro da tela
    self.connections:Add(RunService.RenderStepped:Connect(function()
        if self.mainFrame.Visible then
            local absPos = self.mainFrame.AbsolutePosition
            local absSize = self.mainFrame.AbsoluteSize
            local screenSize = self.screenGui.AbsoluteSize
            local pos = self.mainFrame.Position

            local newX = pos.X
            local newY = pos.Y

            if absPos.X < 0 then
                newX = UDim.new(0, 0 + absSize.X * self.mainFrame.AnchorPoint.X)
            elseif absPos.X + absSize.X > screenSize.X then
                newX = UDim.new(0, screenSize.X - absSize.X * (1 - self.mainFrame.AnchorPoint.X))
            end

            if absPos.Y < 0 then
                newY = UDim.new(0, 0 + absSize.Y * self.mainFrame.AnchorPoint.Y)
            elseif absPos.Y + absSize.Y > screenSize.Y then
                newY = UDim.new(0, screenSize.Y - absSize.Y * (1 - self.mainFrame.AnchorPoint.Y))
            end

            self.mainFrame.Position = UDim2.new(newX.Scale, newX.Offset, newY.Scale, newY.Offset)
        end
    end))

    self:createHeaderAndTabs()
    self:createEmotePanel()
    self:createAnimationPanel()
    self:createConfigPanel()
    self:createDragButton()
end

--############################
-- CRIAÇÃO DA BASE DO PAINEL LAYOUT
--############################

function PlayerController:createHeaderAndTabs()
    -- Header
    local header = UIBuilder.createFrame(
        self.mainFrame,
        UDim2.new(1, -20, 0, Config.HEADER_HEIGHT),
        UDim2.new(0, 10, 0, 10),
        Config.COLOR_HEADER_BACKGROUND,
        0.8, 0, true, false,
        Config.HEADER_CORNER_RADIUS
    )

    UIBuilder.createTextLabel(
        header,
        UDim2.new(1, 0, 1, 0),
        UDim2.new(0, 0, 0, 0),
        "tkst painel ",
        22, Config.FONT_HEADER, 1,
        Config.COLOR_TEXT_WHITE,
        0.8, Config.COLOR_TEXT_STROKE_GREY
    )

    -- Tabs
    local tabFrame = UIBuilder.createFrame(
        self.mainFrame,
        UDim2.new(1, -20, 0, Config.TAB_HEIGHT),
        UDim2.new(0, 10, 0, 10 + Config.HEADER_HEIGHT + 10),
        nil, 1
    )

    local tabWidth = 1 / 3

    self.emoteTabButton = UIBuilder.createTextButton(
        tabFrame,
        UDim2.new(tabWidth, -4, 1, 0),
        UDim2.new(0, 0, 0, 0),
        "Emotes",
        15, Config.FONT_TABS,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_TAB_ACTIVE_BG,
        0, Config.CORNER_RADIUS,
        Config.COLOR_ACCENT_PRIMARY,
        Config.BORDER_THICKNESS,
        true
    )

    self.animationTabButton = UIBuilder.createTextButton(
        tabFrame,
        UDim2.new(tabWidth, -4, 1, 0),
        UDim2.new(tabWidth, 2, 0, 0),
        "Animações",
        15, Config.FONT_TABS,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_TAB_INACTIVE_BG,
        0, Config.CORNER_RADIUS,
        Config.COLOR_TEXT_STROKE_GREY,
        Config.SMALL_BORDER_THICKNESS,
        true
    )

    self.configTabButton = UIBuilder.createTextButton(
        tabFrame,
        UDim2.new(tabWidth, -4, 1, 0),
        UDim2.new(tabWidth * 2, 4, 0, 0),
        "Config",
        15, Config.FONT_TABS,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_TAB_INACTIVE_BG,
        0, Config.CORNER_RADIUS,
        Config.COLOR_TEXT_STROKE_GREY,
        Config.SMALL_BORDER_THICKNESS,
        true
    )

    -- Drag do painel
    self.connections:Add(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.isDraggingPanel = true
            self.panelDragStart = input.Position
            self.panelStartPos = self.mainFrame.Position

            local inputEndConn
            inputEndConn = UserInputService.InputEnded:Connect(function(inputEnded)
                if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch then
                    self.isDraggingPanel = false
                    inputEndConn:Disconnect()
                end
            end)

            self.connections:Add(inputEndConn)
        end
    end))

    self.connections:Add(UserInputService.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and self.isDraggingPanel then
            local delta = input.Position - self.panelDragStart
            local newPos = UDim2.new(
                self.panelStartPos.X.Scale,
                self.panelStartPos.X.Offset + delta.X,
                self.panelStartPos.Y.Scale,
                self.panelStartPos.Y.Offset + delta.Y
            )
            self.mainFrame.Position = newPos
        end
    end))
end

--########################
-- INPUT BOX SEARCH EMOTES
--########################

function PlayerController:createEmotePanel()
    local padding = 10
    local headerOffset = padding + Config.HEADER_HEIGHT + padding + Config.TAB_HEIGHT

    self.emotePanel = UIBuilder.createFrame(
        self.mainFrame,
        UDim2.new(1, -20, 1, -(headerOffset + padding)),
        UDim2.new(0, padding, 0, headerOffset),
        nil, 1, 0, false, false, nil, nil, nil
    )
    self.emotePanel.Visible = true

    -- Caixa de busca
    self.emoteSearchBox = UIBuilder.createTextBox(
        self.emotePanel,
        UDim2.new(1, -20, 0, Config.SEARCH_BOX_HEIGHT),
        UDim2.new(0, 10, 0, 10),
        "🔍 Buscar emote...",
        16, Config.FONT_DEFAULT,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_SEARCHBOX_BG,
        0, true,
        Config.CORNER_RADIUS,
        Config.COLOR_STROKE_LIGHT,
        Config.SMALL_BORDER_THICKNESS
    )

    -- Área de scroll
    self.emoteScrollFrame = UIBuilder.createScrollingFrame(
        self.emotePanel,
        UDim2.new(1, 0, 1, -(padding + Config.SEARCH_BOX_HEIGHT + padding)),
        UDim2.new(0, 0, 0, padding + Config.SEARCH_BOX_HEIGHT),
        Config.SCROLLBAR_THICKNESS,
        Config.COLOR_SCROLLBAR,
        1, true,
        Enum.ScrollingDirection.Y,
        Enum.ElasticBehavior.Never
    )
    self.emoteScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    -- Grade de emotes
    UIBuilder.createUIGridLayout(
        self.emoteScrollFrame,
        Config.CARD_SIZE,
        Config.CARD_PADDING,
        Enum.StartCorner.TopLeft,
        Enum.HorizontalAlignment.Center
    )
end

--########################
-- INPUT BOX SEARCH ANIMAÇÕES
--########################

function PlayerController:createAnimationPanel()
    local padding = 10
    local headerOffset = padding + Config.HEADER_HEIGHT + padding + Config.TAB_HEIGHT

    self.animationPanel = UIBuilder.createFrame(
        self.mainFrame,
        UDim2.new(1, -20, 1, -(headerOffset + padding)),
        UDim2.new(0, padding, 0, headerOffset),
        nil, 1, 0, false, false, nil, nil, nil
    )
    self.animationPanel.Visible = false

    -- Caixa de busca
    self.animationSearchBox = UIBuilder.createTextBox(
        self.animationPanel,
        UDim2.new(1, -20, 0, Config.SEARCH_BOX_HEIGHT),
        UDim2.new(0, 10, 0, 10),
        "🔍 Buscar animação ou pacote...",
        16, Config.FONT_DEFAULT,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_SEARCHBOX_BG,
        0, true,
        Config.CORNER_RADIUS,
        Config.COLOR_STROKE_LIGHT,
        Config.SMALL_BORDER_THICKNESS
    )

    -- Área de scroll
    local scroll = UIBuilder.createScrollingFrame(
        self.animationPanel,
        UDim2.new(1, 0, 1, -(padding + Config.SEARCH_BOX_HEIGHT + padding)),
        UDim2.new(0, 0, 0, padding + Config.SEARCH_BOX_HEIGHT),
        Config.SCROLLBAR_THICKNESS,
        Config.COLOR_SCROLLBAR,
        1, true,
        Enum.ScrollingDirection.Y,
        Enum.ElasticBehavior.Never
    )
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    self.animationScrollFrame = scroll

    -- Layout da lista de animações
    UIBuilder.createUIListLayout(
        self.animationScrollFrame,
        UDim.new(0, 10),
        Enum.HorizontalAlignment.Center,
        Enum.VerticalAlignment.Top,
        Enum.SortOrder.LayoutOrder
    )
end

--######################
-- ÁREA DE CONFIGURAÇÕES 
--######################

function PlayerController:createConfigPanel()
    local padding = 10
    local headerHeight = Config.HEADER_HEIGHT
    local tabHeight = Config.TAB_HEIGHT
    local yOffset = padding + headerHeight + padding + tabHeight

    self.configPanel = UIBuilder.createFrame(
        self.mainFrame,
        UDim2.new(1, -20, 1, -(yOffset + padding)),
        UDim2.new(0, padding, 0, yOffset),
        nil, 1, 0, false, false
    )
    self.configPanel.Visible = false

    local posY = 10

    UIBuilder.createTextLabel(
        self.configPanel,
        UDim2.new(1, -20, 0, 35),
        UDim2.new(0, 10, 0, posY),
        "Configurações",
        22, Config.FONT_TABS,
        1, Config.COLOR_TEXT_WHITE,
        0.8, Config.COLOR_TEXT_STROKE_GREY,
        Enum.TextXAlignment.Left
    )
    posY += 40

    local credits = {
        { title = "Criador do Painel", text = "Kauam" },
        { title = "Tiktok", text = "Tekscripts" },
        { title = "Roblox", text = "FXZGHS1" }
    }

    self.creditsSwitcher = UIBuilder.createCreditsSwitcher(
        self.configPanel,
        UDim2.new(0.5, 0, 0, posY),
        credits,
        16, Config.FONT_DEFAULT,
        Config.COLOR_CREDITS_TEXT,
        15,
        2,          -- intervalo em segundos
        "typing"    -- efeito "typing" ou "suav"
    )
    posY += 70

    self.loopToggle = UIBuilder.createTextButton(
        self.configPanel,
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, posY),
        "Loop Emote: Off",
        14, Config.FONT_DEFAULT,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_LOOP_TOGGLE_BG,
        0, Config.CORNER_RADIUS,
        nil, nil, true
    )
    posY += 50

    self.closeGuiButton = UIBuilder.createTextButton(
        self.configPanel,
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, posY),
        "Fechar GUI",
        14, Config.FONT_DEFAULT,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_CLOSE_BUTTON_BG,
        0, Config.CORNER_RADIUS,
        nil, nil, true
    )
end

--##########################
-- BOTÃO FLOAT DE FECHAR PAINEL
--##########################

function PlayerController:createDragButton()
    self.dragButton = UIBuilder.createTextButton(
        self.screenGui,
        Config.DRAG_BUTTON_SIZE_NORMAL,
        UDim2.new(1, -120, 0, 60), -- Posicionado no canto superior direito para melhor visibilidade
        "fechar",
        18, Config.FONT_DRAG_BUTTON,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_DRAG_BUTTON_BG,
        0.2, Config.DRAG_BUTTON_CORNER_RADIUS,
        Config.COLOR_SCROLLBAR,
        Config.BORDER_THICKNESS
    )

    local btnGrad = UIBuilder.createUIGradient(self.dragButton)
    btnGrad.Transparency = NumberSequence.new(0.4)

    -- Adicionado para garantir que o botão flutuante fique sempre na tela
    self.connections:Add(RunService.RenderStepped:Connect(function()
        Utils.keepFrameOnScreen(self.dragButton)
    end))
end

--######################################
-- CONFIGURA INTERAÇÕES DE GUI: TROCA DE ABAS, DRAG, BUSCA E CONTROLES
--######################################
function PlayerController:setupInteractions()
    local tweenInfo = TweenInfo.new(Config.TWEEN_DURATION, Config.TWEEN_EASING_STYLE, Config.TWEEN_EASING_DIRECTION)

    local allTabs = {
        emotes = self.emoteTabButton,
        animations = self.animationTabButton,
        config = self.configTabButton,
    }

    local allPanels = {
        emotes = self.emotePanel,
        animations = self.animationPanel,
        config = self.configPanel,
    }

    local function setActiveTab(activeTabName)
        for name, button in pairs(allTabs) do
            local isActive = (name == activeTabName)
            allPanels[name].Visible = isActive

            TweenService:Create(button, tweenInfo, {
                BackgroundColor3 = isActive and Config.COLOR_TAB_ACTIVE_BG or Config.COLOR_TAB_INACTIVE_BG
            }):Play()

            local stroke = button:FindFirstChildOfClass("UIStroke")
            if stroke then
                TweenService:Create(stroke, tweenInfo, {
                    Color = isActive and Config.COLOR_ACCENT_PRIMARY or Config.COLOR_TEXT_STROKE_GREY
                }):Play()
            end
        end
    end

    -- Conexões das abas
    for tabName, button in pairs(allTabs) do
        self.connections:Add(button.MouseButton1Click:Connect(function()
            setActiveTab(tabName)
        end))
    end

    -- Toggle loop do emote
    self.connections:Add(self.loopToggle.MouseButton1Click:Connect(function()
        self.loopEmote = not self.loopEmote
        self.loopToggle.Text = "Loop Emote: " .. (self.loopEmote and "On" or "Off")
        if self.emoteTrack and self.emoteTrack.IsPlaying then
            self.emoteTrack.Looped = self.loopEmote
        end
    end))

    -- Fechar GUI
    self.connections:Add(self.closeGuiButton.MouseButton1Click:Connect(function()
        self:cleanupEmoteAnimation()
        self.screenGui:Destroy()
        self.connections:DisconnectAll()
    end))

    -- Minimizar/Restaurar GUI
    self.connections:Add(self.dragButton.MouseButton1Click:Connect(function()
        self.isMinimized = not self.isMinimized
        self.mainFrame.Visible = not self.isMinimized
        self.dragButton.Text = self.isMinimized and "abrir" or "fechar"

        TweenService:Create(self.dragButton, tweenInfo, {
            Size = self.isMinimized and Config.DRAG_BUTTON_SIZE_MINIMIZED or Config.DRAG_BUTTON_SIZE_NORMAL
        }):Play()
    end))

    -- Drag início
    self.connections:Add(self.dragButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.draggingButton = true
            self.dragButtonStart = input.Position
            self.dragButtonStartPos = self.dragButton.Position

            local endConn
            endConn = UserInputService.InputEnded:Connect(function(inputEnded)
                if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 or inputEnded.UserInputType == Enum.UserInputType.Touch then
                    self.draggingButton = false
                    endConn:Disconnect()
                end
            end)
            self.connections:Add(endConn)
        end
    end))

    -- Drag movimento
    self.connections:Add(UserInputService.InputChanged:Connect(function(input)
        if self.draggingButton and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - self.dragButtonStart
            local newPos = UDim2.new(
                self.dragButtonStartPos.X.Scale,
                self.dragButtonStartPos.X.Offset + delta.X,
                self.dragButtonStartPos.Y.Scale,
                self.dragButtonStartPos.Y.Offset + delta.Y
            )
            self.dragButton.Position = newPos
        end
    end))

    -- Debounce para busca
    local function setupSearchDebounce(searchBox, updateFunction)
        local searchTimer, lastSearchText = nil, ""

        self.connections:Add(searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local currentText = searchBox.Text
            if currentText == lastSearchText then return end
            lastSearchText = currentText

            if searchTimer then
                task.cancel(searchTimer)
                searchTimer = nil
            end

            searchTimer = task.delay(Config.SEARCH_DEBOUNCE_DELAY, function()
                if searchBox and searchBox.Parent and searchBox.Text == currentText then
                    updateFunction(self, currentText)
                end
                searchTimer = nil
            end)
        end))
    end

    setupSearchDebounce(self.emoteSearchBox, self.updateEmoteList)
    setupSearchDebounce(self.animationSearchBox, self.updateAnimationList)
end

--##########################################
-- REPRODUZ UMA ANIMAÇÃO DE EMOTE PELO ID FORNECIDO
--##########################################
function PlayerController:playEmoteAnimation(emoteId)
    if not emoteId then
        -- warn("EmoteId inválido.")
        return
    end
    self.lastEmoteId = emoteId

    self:cleanupEmoteAnimation()

    if not self.character or not self.humanoid then
        -- warn("Personagem ou Humanoid indisponível para emoteId: " .. emoteId)
        return
    end

    local root = self.character:FindFirstChild("HumanoidRootPart")
    if not root then
        -- warn("HumanoidRootPart não encontrado para emoteId: " .. emoteId)
        return
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. emoteId

    local success, track = pcall(function()
        return self.humanoid:LoadAnimation(anim)
    end)

    if not success or not track then
        -- warn("Falha ao carregar animação para emoteId: " .. emoteId)
        anim:Destroy()
        return
    end

    self.emoteTrack = track
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = self.loopEmote or false
    track:Play(Config.ANIMATION_FADE_DURATION)

    self.currentEmoteStopConn = RunService.Heartbeat:Connect(function()
        if not self.character or not self.character:FindFirstChild("HumanoidRootPart")
            or not self.emoteTrack or not self.emoteTrack.IsPlaying then
            self:cleanupEmoteAnimation()
            return
        end

        local state = self.humanoid:GetState()
        if self.humanoid.MoveDirection.Magnitude > 0.1
            or state == Enum.HumanoidStateType.Jumping
            or state == Enum.HumanoidStateType.Freefall then
            self:cleanupEmoteAnimation()
        end
    end)
end

--######################################
-- LIMPA A ANIMAÇÃO DE EMOTE ATUAL, DESCONECTANDO E PARANDO A TRACK
--######################################
function PlayerController:cleanupEmoteAnimation()
    if self.currentEmoteStopConn then
        pcall(function()
            self.currentEmoteStopConn:Disconnect()
        end)
        self.currentEmoteStopConn = nil
    end

    if self.emoteTrack then
        pcall(function()
            if Config and Config.ANIMATION_FADE_DURATION then
                self.emoteTrack:Stop(Config.ANIMATION_FADE_DURATION)
            else
                self.emoteTrack:Stop()
            end
            self.emoteTrack:Destroy()
        end)
        self.emoteTrack = nil
    end
end

--#########################################
-- CARREGA EMOTES DA URL, RETENTANDO SE NECESSÁRIO
--#########################################
function PlayerController:loadEmotes()
    if not Config or not Config.MAX_RETRIES or not Config.RETRY_DELAY or not Config.EMOTE_DATA_URL then
        -- warn("Configuração inválida para loadEmotes.")
        return false
    end

    local req = Utils.getRequest()

    for attempt = 1, Config.MAX_RETRIES do
        local success, res = pcall(function()
            return req({ Url = Config.EMOTE_DATA_URL, Method = "GET" })
        end)

        if success and res and res.Success then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(res.Body)
            end)

            if ok and data then
                local validEmotes = {}

                for _, emote in ipairs(data) do
                    if emote.nome and emote.idEmote and emote.idCatalogo then
                        table.insert(validEmotes, emote)
                    else
                        -- warn("Emote inválido encontrado: " .. tostring(emote.nome or "sem nome"))
                    end
                end

                if #validEmotes > 0 then
                    self.emoteList = validEmotes
                    self:updateEmoteList("")
                    return true
                end
            end
        end

        task.wait(Config.RETRY_DELAY)
    end

    -- warn("Falha ao carregar emotes após " .. Config.MAX_RETRIES .. " tentativas.")
    return false
end

--##########################################
-- VINCULA EVENTO DE RESPAWN DO PERSONAGEM E REPLICA EMOTES AUTOMATICAMENTE
--##########################################
function PlayerController:bindCharacterRespawn()
    if self._bindedCharacterAdded then return end
    self._bindedCharacterAdded = true

    local player = Players.LocalPlayer
    self.characterAddedConn = player.CharacterAdded:Connect(function(char)
        self.character = char
        self.humanoid = char:WaitForChild("Humanoid", 5)
        if not self.humanoid then
            -- warn("Humanoid não encontrado após CharacterAdded")
            return
        end

        self.humanoid.Died:Connect(function()
            self:cleanupEmoteAnimation()
        end)

        if self.lastEmoteId and self.autoReplayEmotes then
            self:playEmoteAnimation(self.lastEmoteId)
        end
    end)
end

--########################
-- LIMPA ANIMAÇÕES E DESCONECTA EVENTOS
--########################
function PlayerController:cleanupAllConnections()
    self:cleanupEmoteAnimation()

    if self._bindedCharacterAdded then
        pcall(function()
            self.characterAddedConn:Disconnect()
        end)
        self._bindedCharacterAdded = nil
        self.characterAddedConn = nil
    end
end

--########################
-- CRIA UM CARD VISUAL PARA UM EMOTE
--########################
function PlayerController:createEmoteCard(emote)
    local btn = Instance.new("ImageButton")
    btn.Name = emote.nome
    btn.BackgroundColor3 = Config.COLOR_CARD_BG
    btn.Size = Config.CARD_SIZE
    btn.Parent = self.emoteScrollFrame

    UIBuilder.createUICorner(btn, Config.CORNER_RADIUS)
    local btnStroke = UIBuilder.createUIStroke(btn, Config.COLOR_STROKE_LIGHT, Config.BORDER_THICKNESS)

    btn.Image = "rbxthumb://type=Asset&id=" .. emote.idCatalogo .. "&w=420&h=420"
    btn.ImageTransparency = 0

    local txtContainer = UIBuilder.createFrame(
        btn,
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 0, 1, -25),
        Config.COLOR_CARD_TEXT_BG,
        0.5, 0, false, true
    )
    local txt = UIBuilder.createTextLabel(
        txtContainer,
        UDim2.new(1, -10, 1, 0),
        UDim2.new(0, 5, 0, 0),
        emote.nome,
        12,
        Config.FONT_CARD,
        1,
        Config.COLOR_TEXT_WHITE,
        nil,
        nil,
        Enum.TextXAlignment.Center,
        Enum.TextYAlignment.Center,
        true
    )
    UIBuilder.createUIStroke(txt, Config.COLOR_CARD_TEXT_STROKE, 0.5)

    local tweenInfo = TweenInfo.new(Config.TWEEN_DURATION)

    local enterConn = btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tweenInfo, { BackgroundColor3 = Config.COLOR_CARD_HOVER }):Play()
        TweenService:Create(btnStroke, tweenInfo, { Color = Config.COLOR_ACCENT_PRIMARY }):Play()
    end)
    local leaveConn = btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tweenInfo, { BackgroundColor3 = Config.COLOR_CARD_BG }):Play()
        TweenService:Create(btnStroke, tweenInfo, { Color = Config.COLOR_STROKE_LIGHT }):Play()
    end)
    local clickConn = btn.MouseButton1Click:Connect(function()
        self:playEmoteAnimation(emote.idEmote)
    end)

    local cardConnections = ConnectionManager:New()
    cardConnections:Add(enterConn)
    cardConnections:Add(leaveConn)
    cardConnections:Add(clickConn)

    btn.Destroying:Connect(function()
        cardConnections:DisconnectAll()
    end)
end


--########################
-- ATUALIZA A LISTA VISUAL DE EMOTES COM BASE EM UM FILTRO
--########################

function PlayerController:updateEmoteList(filter)        
    for _, child in ipairs(self.emoteScrollFrame:GetChildren()) do        
        if child:IsA("GuiObject") and child.Name ~= "UIGridLayout" then        
            child:Destroy()        
        end        
    end        
        
    local filtered = {}        
    local filterLower = string.lower(filter or "")        
        
    for _, emote in ipairs(self.emoteList) do        
        local name = string.lower(tostring(emote.nome or ""))        
        local idCatalogo = tostring(emote.idCatalogo or "")        
        
        if filterLower == "" or string.find(name, filterLower, 1, true) or string.find(idCatalogo, filterLower, 1, true) then        
            table.insert(filtered, emote)        
        end        
    end        
        
    for _, emote in ipairs(filtered) do        
        self:createEmoteCard(emote)        
    end        
end

--########################
-- CRIA UM CARD VISUAL PARA UMA ANIMAÇÃO PERSONALIZADA
--########################

function PlayerController:createAnimationCard(animationData, parentFrame)
    -- Cria botão principal do card
    local btn = Instance.new("ImageButton")
    btn.Name = animationData.nome
    btn.LayoutOrder = 1
    btn.BackgroundColor3 = Config.COLOR_CARD_BG
    btn.Size = Config.CARD_SIZE
    btn.Parent = parentFrame

    UIBuilder.createUICorner(btn, Config.CORNER_RADIUS)

    -- Define imagem do card
    btn.Image = "rbxthumb://type=Asset&id=" .. animationData.idAsset .. "&w=420&h=420"
    btn.ImageTransparency = 0

    -- Verifica se a animação está selecionada
    local animType = self.animationTypes[animationData.nome]
    local isSelected = animType and self.customAnimations[animType] == animationData.idAnimacao
    local strokeColor = isSelected and Config.COLOR_ACCENT_PRIMARY or Config.COLOR_STROKE_LIGHT
    local btnStroke = UIBuilder.createUIStroke(btn, strokeColor, Config.BORDER_THICKNESS)

    -- Cria container para o nome no rodapé do card
    local txtContainer = UIBuilder.createFrame(
        btn,
        UDim2.new(1, 0, 0, 25),
        UDim2.new(0, 0, 1, -25),
        Config.COLOR_CARD_TEXT_BG,
        0.5, 0, false, true
    )

    -- Adiciona texto com o nome da animação
    local txt = UIBuilder.createTextLabel(
        txtContainer,
        UDim2.new(1, -10, 1, 0),
        UDim2.new(0, 5, 0, 0),
        animationData.nome,
        12,
        Config.FONT_CARD,
        1,
        Config.COLOR_TEXT_WHITE,
        nil, nil,
        Enum.TextXAlignment.Center,
        Enum.TextYAlignment.Center,
        true
    )

    UIBuilder.createUIStroke(txt, Config.COLOR_CARD_TEXT_STROKE, 0.5)

    -- Animações ao passar o mouse
    local tweenInfo = TweenInfo.new(Config.TWEEN_DURATION)

    local enterConn = btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tweenInfo, {
            BackgroundColor3 = Config.COLOR_CARD_HOVER
        }):Play()

        if not isSelected then
            TweenService:Create(btnStroke, tweenInfo, {
                Color = Config.COLOR_ACCENT_PRIMARY
            }):Play()
        end
    end)

    local leaveConn = btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tweenInfo, {
            BackgroundColor3 = Config.COLOR_CARD_BG
        }):Play()

        if not isSelected then
            TweenService:Create(btnStroke, tweenInfo, {
                Color = Config.COLOR_STROKE_LIGHT
            }):Play()
        end
    end)

    -- Aplica a animação ao clicar
    local clickConn = btn.MouseButton1Click:Connect(function()
        self:applyAnimation(animationData.idAnimacao)
    end)

    -- Gerencia conexões para evitar vazamento de memória
    local cardConnections = ConnectionManager:New()
    cardConnections:Add(enterConn)
    cardConnections:Add(leaveConn)
    cardConnections:Add(clickConn)

    btn.Destroying:Connect(function()
        cardConnections:DisconnectAll()
    end)
end


function PlayerController:updateAnimationList(filter)
    -- Limpa os elementos antigos
    for _, child in ipairs(self.animationScrollFrame:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then
            child:Destroy()
        end
    end

    -- Prepara filtro e categorizações
    local filterLower = string.lower(filter or "")
    local categorized = {}

    for _, anim in ipairs(self.animationList) do
        local nameLower = string.lower(tostring(anim.nome or ""))
        local bundleLower = string.lower(tostring(anim.bundleNome or "Outros"))

        if filterLower == ""
            or string.find(nameLower, filterLower, 1, true)
            or string.find(bundleLower, filterLower, 1, true)
        then
            local groupName = anim.bundleNome or "Outros"
            if not categorized[groupName] then
                categorized[groupName] = {}
            end
            table.insert(categorized[groupName], anim)
        end
    end

    -- Ordena categorias
    local categoryOrder = {}
    for name in pairs(categorized) do
        table.insert(categoryOrder, name)
    end
    table.sort(categoryOrder)

    -- Cria visualização por categoria
    for i, categoryName in ipairs(categoryOrder) do
        -- Frame da categoria
        local categoryFrame = UIBuilder.createFrame(
            self.animationScrollFrame,
            UDim2.new(1, 0, 0, 0),
            UDim2.new(),
            nil,
            1
        )
        categoryFrame.Name = "Category_" .. categoryName
        categoryFrame.AutomaticSize = Enum.AutomaticSize.Y
        categoryFrame.LayoutOrder = i

        UIBuilder.createUIListLayout(
            categoryFrame,
            UDim.new(0, 5),
            Enum.HorizontalAlignment.Center,
            Enum.VerticalAlignment.Top,
            Enum.SortOrder.LayoutOrder
        )

        -- Cabeçalho
        local header = UIBuilder.createTextLabel(
            categoryFrame,
            UDim2.new(1, -10, 0, Config.CATEGORY_HEADER_HEIGHT),
            UDim2.new(0, 5, 0, 0),
            categoryName,
            16,
            Config.FONT_TABS,
            0,
            Config.COLOR_TEXT_WHITE,
            nil,
            nil,
            Enum.TextXAlignment.Center,
            Enum.TextYAlignment.Center,
            false
        )
        header.LayoutOrder = 0
        header.BackgroundColor3 = Config.COLOR_CATEGORY_HEADER_BG
        UIBuilder.createUICorner(header, Config.CORNER_RADIUS)

        -- Grid de cards
        local gridFrame = UIBuilder.createFrame(
            categoryFrame,
            UDim2.new(1, 0, 0, 0),
            UDim2.new(),
            nil,
            1
        )
        gridFrame.LayoutOrder = 1
        gridFrame.AutomaticSize = Enum.AutomaticSize.Y

        UIBuilder.createUIGridLayout(
            gridFrame,
            Config.CARD_SIZE,
            Config.CARD_PADDING,
            Enum.StartCorner.TopLeft,
            Enum.HorizontalAlignment.Center
        )

        -- Cards da categoria
        for _, animData in ipairs(categorized[categoryName]) do
            self:createAnimationCard(animData, gridFrame)
        end
    end
end

--########################
-- CARREGA DADOS LOCAIS E REMOTOS DE EMOTES E ANIMAÇÕES
--########################
function PlayerController:loadAllData()
    self:loadSavedAnimations()

    if player.Character then
        self:applyCustomAnimationsToCharacter(player.Character)
    end

    -- Carrega dados dos emotes
    coroutine.wrap(function()
        if self:loadEmotes() then
            -- Emotes carregados com sucesso
        else
            -- warn("Não foi possível carregar os emotes. Verifique sua conexão ou a URL dos dados.")
        end
    end)()

    -- Carrega dados das animações e atualiza a lista
    coroutine.wrap(function()
        if self:loadAnimationsData() then
            self:updateAnimationList("")
        else
            -- warn("Não foi possível carregar os dados de animação. Verifique sua conexão ou a URL dos dados.")
        end
    end)()
end

PlayerController:init()
