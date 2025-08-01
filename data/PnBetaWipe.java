

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

function Utils.getRequest()
    return (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or (krnl and krnl.request) or (getgenv().request) or request
end

function Utils.getFileSystem()
    local funcs = {
        writeFile = writefile or (fluxus and fluxus.writefile) or (trigon and trigon.writefile) or (codex and codex.writefile),
        readFile = readfile or (fluxus and fluxus.readFile) or (trigon and trigon.readFile) or (codex and codex.readFile),
        isFile = isfile or (fluxus and fluxus.isfile) or (trigon and trigon.isfile) or (codex and codex.isfile) or function() return false end
    }
    assert(funcs.writeFile and funcs.readFile, "Executor não suporta escrita/leitura de arquivos.")
    return funcs
end

Utils.fs = Utils.getFileSystem()

function Utils.keepFrameOnScreen(frame)
    local viewportSize = workspace.CurrentCamera.ViewportSize
    local frameSize = frame.AbsoluteSize
    local framePos = frame.AbsolutePosition
    local newPosX = math.clamp(framePos.X, 0, viewportSize.X - frameSize.X)
    local newPosY = math.clamp(framePos.Y, 0, viewportSize.Y - frameSize.Y)
    if newPosX ~= framePos.X or newPosY ~= framePos.Y then
        frame.Position = UDim2.new(0, newPosX, 0, newPosY)
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

function ConnectionManager:New()
    local self = setmetatable({}, {__index = ConnectionManager})
    self.connections = {}
    return self
end
function ConnectionManager:Add(connection)
    table.insert(self.connections, connection)
end
function ConnectionManager:Remove(connection)
    for i, conn in ipairs(self.connections) do
        if conn == connection then
            table.remove(self.connections, i)
            break
        end
    end
end
function ConnectionManager:DisconnectAll()
    for _, conn in ipairs(self.connections) do
        pcall(function() conn:Disconnect() end)
    end
    self.connections = {}
end

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
function UIBuilder.createUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Config.CORNER_RADIUS
    corner.Parent = parent
    return corner
end
function UIBuilder.createUIStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Config.COLOR_STROKE_LIGHT
    stroke.Thickness = thickness or Config.BORDER_THICKNESS
    stroke.Parent = parent
    return stroke
end
function UIBuilder.createFrame(parent, size, position, backgroundColor, backgroundTransparency, borderSizePixel, active, clipsDescendants, cornerRadius, strokeColor, strokeThickness)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = backgroundColor or Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = backgroundTransparency or 0
    frame.BorderSizePixel = borderSizePixel or 0
    frame.Active = active or false
    frame.ClipsDescendants = clipsDescendants or false
    frame.Parent = parent
    if cornerRadius then UIBuilder.createUICorner(frame, cornerRadius) end
    if strokeColor then UIBuilder.createUIStroke(frame, strokeColor, strokeThickness) end
    return frame
end
function UIBuilder.createTextLabel(parent, size, position, text, textSize, font, backgroundTransparency, textColor, textStrokeTransparency, textStrokeColor, textXAlignment, textYAlignment, textWrapped)
    local label = Instance.new("TextLabel")
    label.Size = size; label.Position = position; label.Text = text; label.TextSize = textSize; label.Font = font
    label.BackgroundTransparency = backgroundTransparency or 1; label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = textStrokeTransparency or 1; label.TextStrokeColor3 = textStrokeColor or Color3.new(0, 0, 0)
    label.TextXAlignment = textXAlignment or Enum.TextXAlignment.Center; label.TextYAlignment = textYAlignment or Enum.TextYAlignment.Center
    label.TextWrapped = textWrapped or false; label.Parent = parent
    return label
end
function UIBuilder.createTextButton(parent, size, position, text, textSize, font, textColor, backgroundColor, backgroundTransparency, cornerRadius, strokeColor, strokeThickness, gradient)
    local button = Instance.new("TextButton")
    button.Size = size; button.Position = position; button.Text = text; button.TextSize = textSize; button.Font = font
    button.TextColor3 = textColor or Color3.new(1, 1, 1); button.BackgroundColor3 = backgroundColor or Color3.fromRGB(255, 255, 255)
    button.BackgroundTransparency = backgroundTransparency or 0; button.Parent = parent
    if cornerRadius then UIBuilder.createUICorner(button, cornerRadius) end
    if strokeColor then UIBuilder.createUIStroke(button, strokeColor, strokeThickness) end
    if gradient then UIBuilder.createUIGradient(button) end
    return button
end
function UIBuilder.createImageLabel(parent, size, position, image, backgroundTransparency, zIndex)
    local label = Instance.new("ImageLabel")
    label.Image = image; label.Size = size; label.Position = position
    label.BackgroundTransparency = backgroundTransparency or 1; label.ZIndex = zIndex or 1; label.Parent = parent
    return label
end
function UIBuilder.createTextBox(parent, size, position, placeholderText, textSize, font, textColor, backgroundColor, borderSizePixel, clearTextOnFocus, cornerRadius, strokeColor, strokeThickness)
    local textBox = Instance.new("TextBox")
    textBox.PlaceholderText = placeholderText; textBox.Size = size; textBox.Position = position; textBox.Font = font; textBox.TextSize = textSize
    textBox.TextColor3 = textColor or Color3.new(1, 1, 1); textBox.BackgroundColor3 = backgroundColor or Color3.fromRGB(255, 255, 255)
    textBox.BorderSizePixel = borderSizePixel or 0; textBox.ClearTextOnFocus = clearTextOnFocus or false; textBox.Parent = parent
    if cornerRadius then UIBuilder.createUICorner(textBox, cornerRadius) end
    if strokeColor then UIBuilder.createUIStroke(textBox, strokeColor, strokeThickness) end
    return textBox
end
function UIBuilder.createScrollingFrame(parent, size, position, scrollBarThickness, scrollBarImageColor, backgroundTransparency, scrollingEnabled, scrollingDirection, elasticBehavior)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = size; scroll.Position = position; scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = scrollBarThickness or Config.SCROLLBAR_THICKNESS; scroll.ScrollBarImageColor3 = scrollBarImageColor or Config.COLOR_SCROLLBAR
    scroll.BackgroundTransparency = backgroundTransparency or 1; scroll.ScrollingEnabled = scrollingEnabled or true
    scroll.ScrollingDirection = scrollingDirection or Enum.ScrollingDirection.Y; scroll.ElasticBehavior = elasticBehavior or Enum.ElasticBehavior.Never
    scroll.Parent = parent
    return scroll
end
function UIBuilder.createUIGridLayout(parent, cellSize, cellPadding, startCorner, horizontalAlignment)
    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = cellSize or Config.CARD_SIZE; gridLayout.CellPadding = cellPadding or Config.CARD_PADDING
    gridLayout.StartCorner = startCorner or Enum.StartCorner.TopLeft; gridLayout.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
    gridLayout.Parent = parent
    return gridLayout
end
function UIBuilder.createUIListLayout(parent, padding, horizontalAlignment, verticalAlignment, sortOrder)
    local list = Instance.new("UIListLayout")
    list.Padding = padding or UDim.new(0, 5)
    list.HorizontalAlignment = horizontalAlignment or Enum.HorizontalAlignment.Center
    list.VerticalAlignment = verticalAlignment or Enum.VerticalAlignment.Top
    list.SortOrder = sortOrder or Enum.SortOrder.LayoutOrder
    list.Parent = parent
    return list
end
function UIBuilder.createLoadingSpinner(parent)
    local spinner = UIBuilder.createImageLabel(parent, UDim2.new(0.8, 0, 0.8, 0), UDim2.new(0.1, 0, 0.1, 0), "rbxassetid://10101260412", 1, 2)
    local connectionManager = ConnectionManager:New()
    connectionManager:Add(RunService.RenderStepped:Connect(function(delta)
        if not spinner or not spinner.Parent then connectionManager:DisconnectAll(); return end
        spinner.Rotation = spinner.Rotation + (delta * 360)
    end))
    spinner.Destroying:Connect(function() connectionManager:DisconnectAll() end)
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

function PlayerController:init()
    if PlayerGui:FindFirstChild(Config.GUI_NAME) then return end
    self:setupCharacterListeners()
    self:createGUI()
    self:setupInteractions()
    self:loadAllData()
end

function PlayerController:setupCharacterListeners()
    -- Configura listeners para o evento de respawn do personagem
    local function onCharacter(char)
        -- Aguarda até que o Humanoid e o Animate estejam disponíveis
        self.character = char
        self.humanoid = char:WaitForChild("Humanoid", 5) -- Timeout de 5 segundos
        if not self.humanoid then
            -- warn("Humanoid não encontrado após respawn")
            return
        end
        
        -- Limpa emotes anteriores
        self:cleanupEmoteAnimation()
        
        -- Aguarda o Animate ser carregado e aplica as animações
        local animate = char:WaitForChild("Animate", 5)
        if not animate then

            return
        end
        
        -- Aplica as animações com um pequeno atraso para garantir inicialização
        task.delay(0.1, function()
            self:reloadCharacterAnimations(char)
        end)
    end
    
    -- Conecta o evento CharacterAdded
    self.connections:Add(player.CharacterAdded:Connect(onCharacter))
    
    -- Se o personagem já existe, aplica imediatamente
    if player.Character then
        onCharacter(player.Character)
    end
end

function PlayerController:reloadCharacterAnimations(char)
    -- Recarrega as animações do personagem de forma robusta
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local animate = char:FindFirstChild("Animate")
    
    if not (humanoid and animate) then
        -- warn("Humanoid ou Animate não encontrado ao tentar recarregar animações")
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

function PlayerController:applyCustomAnimationsToCharacter(char)
    -- Aplica as animações customizadas ao script Animate, criando estrutura se necessário
    local animate = char:FindFirstChild("Animate")
    if not animate then
        -- warn("Script Animate não encontrado ao aplicar animações")
        return
    end
    
    local function ensureAnimationStructure(folderName, animName, id)
        if not id then return end
        local folder = animate:FindFirstChild(folderName)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folderName
            folder.Parent = animate
            -- print("Criado folder " .. folderName .. " em Animate")
        end
        
        local anim = folder:FindFirstChild(animName)
        if not anim then
            anim = Instance.new("Animation")
            anim.Name = animName
            anim.Parent = folder
            -- print("Criada animação " .. animName .. " em " .. folderName)
        end
        
        if anim:IsA("Animation") then
            anim.AnimationId = "rbxassetid://" .. id
        else
            -- warn("Objeto " .. animName .. " não é uma Animation")
        end
    end
    
    -- Aplica todas as animações customizadas
    ensureAnimationStructure("walk", "WalkAnim", self.customAnimations.walk)
    ensureAnimationStructure("idle", "Animation1", self.customAnimations.idle)
    ensureAnimationStructure("idle", "Animation2", self.customAnimations.idle)
    ensureAnimationStructure("jump", "JumpAnim", self.customAnimations.jump)
    ensureAnimationStructure("fall", "FallAnim", self.customAnimations.fall)
    ensureAnimationStructure("run", "RunAnim", self.customAnimations.run)
    ensureAnimationStructure("swim", "Swim", self.customAnimations.swim)
    ensureAnimationStructure("climb", "ClimbAnim", self.customAnimations.climb)
end

function PlayerController:loadAnimationsData()
    local attempt = 1
    while attempt <= Config.MAX_RETRIES do
        local success, err = pcall(function()
            local res = Utils.getRequest()({ Url = Config.ANIMATION_DATA_URL, Method = "GET" })
            if res and res.Success then
                self.animationList = HttpService:JSONDecode(res.Body)
            else
                error("Erro ao carregar animações: " .. (res and res.StatusMessage or "Falha na requisição"))
            end
        end)
        if success then return true end
        -- warn("Animações: Tentativa " .. attempt .. " falhou: " .. tostring(err))
        if attempt == Config.MAX_RETRIES then self.animationList = {}; return false end
        task.wait(Config.RETRY_DELAY)
        attempt += 1
    end
    return false
end

function PlayerController:saveCustomAnimations()
    local success, err = pcall(function()
        Utils.fs.writeFile(Config.SAVED_ANIMATIONS_FILE, HttpService:JSONEncode(self.customAnimations))
    end)
    if not success then
        -- warn("Erro ao salvar animações personalizadas: " .. tostring(err))
    end
end

function PlayerController:loadSavedAnimations()
    if Utils.fs.isFile(Config.SAVED_ANIMATIONS_FILE) then
        local success, data = pcall(function() return Utils.fs.readFile(Config.SAVED_ANIMATIONS_FILE) end)
        if success and data then
            local decodedSuccess, decodedData = pcall(function() return HttpService:JSONDecode(data) end)
            if decodedSuccess then
                self.customAnimations = decodedData
            else
                -- warn("Erro ao decodificar animações salvas: " .. tostring(decodedData))
            end
        else
            -- warn("Erro ao ler arquivo de animações salvas: " .. tostring(data))
        end
    else
        -- print("Arquivo " .. Config.SAVED_ANIMATIONS_FILE .. " não encontrado. Iniciando com animações padrão.")
        self.customAnimations = {climb = nil, fall = nil, idle = nil, jump = nil, run = nil, swim = nil, walk = nil}
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

    -- Blur/Stroke Frame de fundo
    UIBuilder.createFrame(
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

    self.connections:Add(RunService.RenderStepped:Connect(function()
        if self.mainFrame.Visible then
            Utils.keepFrameOnScreen(self.mainFrame)
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
            inputEndConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    self.isDraggingPanel = false
                    inputEndConn:Disconnect()
                end
            end)

            self.connections:Add(inputEndConn)
        end
    end))

    self.connections:Add(header.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and self.isDraggingPanel then
            local delta = input.Position - self.panelDragStart
            self.mainFrame.Position = UDim2.new(
                self.panelStartPos.X.Scale,
                self.panelStartPos.X.Offset + delta.X,
                self.panelStartPos.Y.Scale,
                self.panelStartPos.Y.Offset + delta.Y
            )
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

    self.configPanel = UIBuilder.createFrame(
        self.mainFrame,
        UDim2.new(1, -20, 1, -(padding + headerHeight + padding + tabHeight + padding)),
        UDim2.new(0, padding, 0, padding + headerHeight + padding + tabHeight),
        nil, 1, 0, false, false, nil, nil, nil
    )
    self.configPanel.Visible = false

    UIBuilder.createTextLabel(
        self.configPanel,
        UDim2.new(1, -20, 0, 40),
        UDim2.new(0, 10, 0, 10),
        "Configurações",
        20, Config.FONT_TABS,
        1, Config.COLOR_TEXT_WHITE
    )

    UIBuilder.createTextLabel(
        self.configPanel,
        UDim2.new(1, -20, 0, 30),
        UDim2.new(0, 10, 0, 60),
        "| By: Kauam     \n| ttk: Tekscripts\n| R: FXZGHS1    ",
        16, Config.FONT_DEFAULT,
        1, Config.COLOR_CREDITS_TEXT
    )

    self.loopToggle = UIBuilder.createTextButton(
        self.configPanel,
        Config.LOOP_TOGGLE_SIZE,
        UDim2.new(0, 10, 0, 100),
        "Loop Emote: Off",
        14, Config.FONT_DEFAULT,
        Config.COLOR_TEXT_WHITE,
        Config.COLOR_LOOP_TOGGLE_BG,
        0, Config.CORNER_RADIUS,
        nil, nil, true
    )

    self.closeGuiButton = UIBuilder.createTextButton(
        self.configPanel,
        Config.CLOSE_BUTTON_SIZE,
        UDim2.new(0, 10, 0, 150),
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
        UDim2.new(0.5, 200, 0.5, -200),
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

    self.connections:Add(RunService.RenderStepped:Connect(function()
        Utils.keepFrameOnScreen(self.dragButton)
    end))
end

function PlayerController:setupInteractions()
    local tweenInfo = TweenInfo.new(
        Config.TWEEN_DURATION,
        Config.TWEEN_EASING_STYLE,
        Config.TWEEN_EASING_DIRECTION
    )

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

    -- Troca de abas
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

    self.connections:Add(self.emoteTabButton.MouseButton1Click:Connect(function()
        setActiveTab("emotes")
    end))

    self.connections:Add(self.animationTabButton.MouseButton1Click:Connect(function()
        setActiveTab("animations")
    end))

    self.connections:Add(self.configTabButton.MouseButton1Click:Connect(function()
        setActiveTab("config")
    end))

    -- Toggle loop emote
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

    -- Minimizar e restaurar GUI
    self.connections:Add(self.dragButton.MouseButton1Click:Connect(function()
        self.isMinimized = not self.isMinimized
        self.mainFrame.Visible = not self.isMinimized
        self.dragButton.Text = self.isMinimized and "abrir" or "fechar"

        TweenService:Create(self.dragButton, tweenInfo, {
            Size = self.isMinimized and Config.DRAG_BUTTON_SIZE_MINIMIZED or Config.DRAG_BUTTON_SIZE_NORMAL
        }):Play()
    end))

    -- Início do drag do botão
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

    -- Movimento do botão
    self.connections:Add(UserInputService.InputChanged:Connect(function(input)
        if self.draggingButton and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - self.dragButtonStart

            TweenService:Create(self.dragButton, tweenInfo, {
                Position = UDim2.new(
                    self.dragButtonStartPos.X.Scale,
                    self.dragButtonStartPos.X.Offset + delta.X,
                    self.dragButtonStartPos.Y.Scale,
                    self.dragButtonStartPos.Y.Offset + delta.Y
                )
            }):Play()
        end
    end))

    -- Debounce de busca
    local function setupSearchDebounce(searchBox, updateFunction)
        local searchTimer = nil
        local lastSearchText = ""

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

function PlayerController:playEmoteAnimation(emoteId)
    if not emoteId then
        -- warn("EmoteId inválido.")
        return
    end
    self.lastEmoteId = emoteId

    self:cleanupEmoteAnimation()

    if not self.character or not self.humanoid then
        -- warn("Personagem ou humanoid não disponível para emoteId: " .. emoteId)
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

        if self.humanoid.MoveDirection.Magnitude > 0.1 or
            self.humanoid:GetState() == Enum.HumanoidStateType.Jumping or
            self.humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            self:cleanupEmoteAnimation()
        end
    end)
end

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

function PlayerController:loadEmotes()
    if not Config or not Config.MAX_RETRIES or not Config.RETRY_DELAY or not Config.EMOTE_DATA_URL then
        -- warn("Configuração inválida para loadEmotes.")
        return false
    end

    local req = Utils.getRequest()
    for i = 1, Config.MAX_RETRIES do
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

function PlayerController:bindCharacterRespawn()
    if self._bindedCharacterAdded then
        return
    end
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

    local txtContainer = UIBuilder.createFrame(btn, UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 1, -25), Config.COLOR_CARD_TEXT_BG, 0.5, 0, false, true)
    local txt = UIBuilder.createTextLabel(txtContainer, UDim2.new(1, -10, 1, 0), UDim2.new(0, 5, 0, 0), emote.nome, 12, Config.FONT_CARD, 1, Config.COLOR_TEXT_WHITE, nil, nil, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center, true)
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

function PlayerController:createAnimationCard(animationData, parentFrame)
    local btn = Instance.new("ImageButton")
    btn.Name = animationData.nome; btn.LayoutOrder = 1; btn.BackgroundColor3 = Config.COLOR_CARD_BG; btn.Size = Config.CARD_SIZE; btn.Parent = parentFrame
    UIBuilder.createUICorner(btn, Config.CORNER_RADIUS)
    
    local animType = self.animationTypes[animationData.nome]
    local isSelected = animType and self.customAnimations[animType] == animationData.idAnimacao
    local strokeColor = isSelected and Config.COLOR_ACCENT_PRIMARY or Config.COLOR_STROKE_LIGHT
    local btnStroke = UIBuilder.createUIStroke(btn, strokeColor, Config.BORDER_THICKNESS)

    btn.Image = "rbxthumb://type=Asset&id=" .. animationData.idAsset .. "&w=420&h=420"; btn.ImageTransparency = 0 
    
    local txtContainer = UIBuilder.createFrame(btn, UDim2.new(1, 0, 0, 25), UDim2.new(0, 0, 1, -25), Config.COLOR_CARD_TEXT_BG, 0.5, 0, false, true)
    local txt = UIBuilder.createTextLabel(txtContainer, UDim2.new(1, -10, 1, 0), UDim2.new(0, 5, 0, 0), animationData.nome, 12, Config.FONT_CARD, 1, Config.COLOR_TEXT_WHITE, nil, nil, Enum.TextXAlignment.Center, Enum.TextYAlignment.Center, true)
    UIBuilder.createUIStroke(txt, Config.COLOR_CARD_TEXT_STROKE, 0.5)

    local tweenInfo = TweenInfo.new(Config.TWEEN_DURATION)
    local enterConn = btn.MouseEnter:Connect(function()
        TweenService:Create(btn, tweenInfo, {BackgroundColor3 = Config.COLOR_CARD_HOVER}):Play()
        if not isSelected then TweenService:Create(btnStroke, tweenInfo, {Color = Config.COLOR_ACCENT_PRIMARY}):Play() end
    end)
    local leaveConn = btn.MouseLeave:Connect(function()
        TweenService:Create(btn, tweenInfo, {BackgroundColor3 = Config.COLOR_CARD_BG}):Play()
        if not isSelected then TweenService:Create(btnStroke, tweenInfo, {Color = Config.COLOR_STROKE_LIGHT}):Play() end
    end)
    local clickConn = btn.MouseButton1Click:Connect(function()
        self:applyAnimation(animationData.idAnimacao)
    end)
    local cardConnections = ConnectionManager:New(); cardConnections:Add(enterConn); cardConnections:Add(leaveConn); cardConnections:Add(clickConn)
    btn.Destroying:Connect(function() cardConnections:DisconnectAll() end)
end

function PlayerController:updateAnimationList(filter)
    for _, child in ipairs(self.animationScrollFrame:GetChildren()) do if child:IsA("GuiObject") and child.Name ~= "UIListLayout" then child:Destroy() end end
    
    local filterLower = string.lower(filter or "")
    local categorized = {}

    for _, anim in ipairs(self.animationList) do
        local nameLower = string.lower(tostring(anim.nome or ""))
        local bundleLower = string.lower(tostring(anim.bundleNome or "Outros"))
        if filterLower == "" or string.find(nameLower, filterLower, 1, true) or string.find(bundleLower, filterLower, 1, true) then
            if not categorized[anim.bundleNome] then categorized[anim.bundleNome] = {} end
            table.insert(categorized[anim.bundleNome], anim)
        end
    end

    local categoryOrder = {}
    for name in pairs(categorized) do table.insert(categoryOrder, name) end
    table.sort(categoryOrder)

    for i, categoryName in ipairs(categoryOrder) do
        local categoryFrame = UIBuilder.createFrame(self.animationScrollFrame, UDim2.new(1, 0, 0, 0), UDim2.new(), nil, 1)
        categoryFrame.Name = "Category_" .. (categoryName or "Outros")
        categoryFrame.AutomaticSize = Enum.AutomaticSize.Y
        categoryFrame.LayoutOrder = i
        UIBuilder.createUIListLayout(categoryFrame, UDim.new(0, 5), Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top, Enum.SortOrder.LayoutOrder)

        local header = UIBuilder.createTextLabel(categoryFrame, UDim2.new(1, -10, 0, Config.CATEGORY_HEADER_HEIGHT), UDim2.new(0, 5, 0, 0),
            categoryName, 16, Config.FONT_TABS, 0, Config.COLOR_TEXT_WHITE, nil, nil, Enum.TextXAlignment.Left, Enum.TextYAlignment.Center, false)
        header.LayoutOrder = 0
        header.BackgroundColor3 = Config.COLOR_CATEGORY_HEADER_BG
        UIBuilder.createUICorner(header, Config.CORNER_RADIUS)

        local gridFrame = UIBuilder.createFrame(categoryFrame, UDim2.new(1, 0, 0, 0), UDim2.new(), nil, 1)
        gridFrame.LayoutOrder = 1
        gridFrame.AutomaticSize = Enum.AutomaticSize.Y
        UIBuilder.createUIGridLayout(gridFrame, Config.CARD_SIZE, Config.CARD_PADDING, Enum.StartCorner.TopLeft, Enum.HorizontalAlignment.Left)

        for _, animData in ipairs(categorized[categoryName]) do
            self:createAnimationCard(animData, gridFrame)
        end
    end
end

function PlayerController:loadAllData()
    self:loadSavedAnimations()
    if player.Character then
        self:applyCustomAnimationsToCharacter(player.Character)
    end

    coroutine.wrap(function()
        if self:loadEmotes() then
        else
            -- warn("Não foi possível carregar os emotes. Verifique sua conexão ou a URL dos dados.")
        end
    end)()

    coroutine.wrap(function()
        if self:loadAnimationsData() then
            self:updateAnimationList("")
        else
            -- warn("Não foi possível carregar os dados de animação. Verifique sua conexão ou a URL dos dados.")
        end
    end)()
end

PlayerController:init()