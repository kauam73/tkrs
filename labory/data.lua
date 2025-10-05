--!strict
local Tekscripts = {}
Tekscripts.__index = Tekscripts

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

---
-- Tabela de Constantes de Design (Tema Dark Clean com mais contraste)
---
local DESIGN = {
    -- =================================================================
    -- CORES (Ajustadas para maior contraste e estética)
    -- =================================================================
    
    -- Cores da Janela e Fundo
    WindowColor1 = Color3.fromRGB(20, 20, 22),        -- Fundo principal mais escuro
    WindowColor2 = Color3.fromRGB(15, 15, 17),        -- Fundo secundário para gradiente
    BlockScreenColor = Color3.fromRGB(0, 0, 0),       -- Overlay preto para modais

    -- Cores de Texto
    TitleColor = Color3.fromRGB(255, 255, 255),       -- Títulos branco puro para contraste
    ComponentTextColor = Color3.fromRGB(245, 245, 245), -- Texto dos componentes claro
    InputTextColor = Color3.fromRGB(255, 255, 255),   -- Texto para inputs mais nítido
    NotifyTextColor = Color3.fromRGB(245, 245, 245),  -- Texto para notificações

    -- Cores de Componentes
    ComponentBackground = Color3.fromRGB(30, 30, 35), -- Fundo de componentes mais escuro
    InputBackgroundColor = Color3.fromRGB(38, 38, 45),-- Fundo inputs com contraste
    AccentColor = Color3.fromRGB(0, 170, 255),        -- Azul mais vibrante
    ItemHoverColor = Color3.fromRGB(60, 60, 70),      -- Hover itens com contraste
    ComponentHoverColor = Color3.fromRGB(80, 80, 90), -- Hover geral mais visível
    
    -- Cores de Botões e Controles
    ActiveToggleColor = Color3.fromRGB(0, 170, 255),  -- Azul vibrante para toggles
    InactiveToggleColor = Color3.fromRGB(50, 50, 55), -- Cinza mais escuro
    MinimizeButtonColor = Color3.fromRGB(230, 80, 80),-- Vermelho vibrante para minimizar
    CloseButtonColor = Color3.fromRGB(255, 100, 100), -- Vermelho para fechar
    FloatButtonColor = Color3.fromRGB(40, 40, 45),    -- Botão flutuante discreto
  
    -- Cores de menu dropdown
    DropdownBackground = Color3.fromRGB(25, 25, 30),
    DropdownItemHover = Color3.fromRGB(60, 60, 70),

    -- Cores de Abas (Tabs)
    TabActiveColor = Color3.fromRGB(0, 170, 255),     -- Aba ativa vibrante
    TabInactiveColor = Color3.fromRGB(30, 30, 35),    -- Aba inativa mais escura

    -- Cores de Sliders
    SliderTrackColor = Color3.fromRGB(55, 55, 60),    -- Trilha slider mais escura
    SliderFillColor = Color3.fromRGB(0, 170, 255),    -- Preenchimento ativo
    ThumbColor = Color3.fromRGB(255, 255, 255),       -- Bolinha branca
    ThumbOutlineColor = Color3.fromRGB(30, 30, 35),   -- Contorno da bolinha

    -- Cores de Elementos de UI Diversos
    HRColor = Color3.fromRGB(80, 80, 85),             -- Divisórias mais claras
    ResizeHandleColor = Color3.fromRGB(60, 60, 65),   -- Alça resize
    NotifyBackground = Color3.fromRGB(35, 35, 40),    -- Fundo notificações
    TagBackground = Color3.fromRGB(0, 170, 255),      -- Tags vibrantes

    -- Cores para mensagens de estado vazio
    EmptyStateTextColor = Color3.fromRGB(180, 180, 180), -- Texto para mensagens de vazio

    -- =================================================================
    -- TAMANHOS E DIMENSÕES
    -- =================================================================

    WindowSize = UDim2.new(0, 620, 0, 470),
    MinWindowSize = Vector2.new(500, 370),
    MaxWindowSize = Vector2.new(620, 470),
    TitleHeight = 42,
    TitlePadding = 10,  -- Novo: Espaço para o ícone e o título

    -- Componentes
    ComponentHeight = 44,
    ComponentPadding = 10,
    ContainerPadding = 2,
    CornerRadius = 8,                                 -- Cantos mais suaves
    ButtonIconSize = 24,
    IconSize = 28,  -- Novo: Tamanho do ícone no cabeçalho

    -- Abas (Tabs)
    TabButtonWidth = 140,
    TabButtonHeight = 40,

    -- Elementos Diversos
    FloatButtonSize = UDim2.new(0, 140, 0, 46),
    ResizeHandleSize = 16,
    NotifyWidth = 270,
    NotifyHeight = 70,
    TagHeight = 30,
    TagWidth = 115,
    
    -- Linha Divisória (HR)
    HRHeight = 2,
    HRTextPadding = 14,
    HRMinTextSize = 20,
    HRMaxTextSize = 30,

    -- Menu Dropdown
    DropdownWidth = 150,
    DropdownItemHeight = 35,

    -- =================================================================
    -- EFEITOS
    -- =================================================================
    BlurEffectSize = 8,                              -- Blur mais intenso
    AnimationSpeed = 0.30,                            -- Animações mais rápidas
}

---
-- Funções de Criação de Componentes
---

local function addRoundedCorners(instance: Instance, radius: number?)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or DESIGN.CornerRadius)
    corner.Parent = instance
end

local function addHoverEffect(button: GuiObject, originalColor: Color3, hoverColor: Color3, condition: (() -> boolean)?)
    local isHovering = false
    local isDown = false

    button.MouseEnter:Connect(function()
        isHovering = true
        if not isDown and (not condition or condition()) then
            local tween = TweenService:Create(button, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { BackgroundColor3 = hoverColor })
            tween:Play()
        end
    end)
    button.MouseLeave:Connect(function()
        isHovering = false
        if not isDown and (not condition or condition()) then
            local tween = TweenService:Create(button, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { BackgroundColor3 = originalColor })
            tween:Play()
        end
    end)
    button.MouseButton1Down:Connect(function()
        isDown = true
    end)
    button.MouseButton1Up:Connect(function()
        isDown = false
        if not isHovering and (not condition or condition()) then
            local tween = TweenService:Create(button, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { BackgroundColor3 = originalColor })
            tween:Play()
        end
    end)
end

local function createButton(text: string, size: UDim2, parent: Instance)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = size or UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    btn.BackgroundColor3 = DESIGN.ComponentBackground
    btn.TextColor3 = DESIGN.ComponentTextColor
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Roboto
    btn.TextScaled = true
    btn.Parent = parent

    addRoundedCorners(btn, DESIGN.CornerRadius)
    addHoverEffect(btn, DESIGN.ComponentBackground, DESIGN.ComponentHoverColor)

    return btn
end

---
-- Lógica do Tab
---
local Tab = {}
Tab.__index = Tab

function Tab.new(name: string, parent: Instance)
    local self = setmetatable({} :: {
        Name: string,
        Container: ScrollingFrame,
        Components: {any},
        Button: TextButton?,
        EmptyLabel: TextLabel?
    }, Tab)

    self.Name = name
    self.Container = Instance.new("ScrollingFrame")
    self.Container.Size = UDim2.new(1, 0, 1, 0)
    self.Container.Position = UDim2.new(0, 0, 0, 0)
    self.Container.BackgroundTransparency = 1
    self.Container.BorderSizePixel = 0
    self.Container.ScrollBarThickness = 6
    self.Container.ScrollBarImageColor3 = DESIGN.ComponentHoverColor
    self.Container.Parent = parent

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, DESIGN.ContainerPadding)
    padding.PaddingLeft = UDim.new(0, DESIGN.ContainerPadding)
    padding.PaddingRight = UDim.new(0, DESIGN.ContainerPadding)
    padding.PaddingBottom = UDim.new(0, DESIGN.ContainerPadding)
    padding.Parent = self.Container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, DESIGN.ComponentPadding)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = self.Container

    -- Mensagem de aba sem componentes
    self.EmptyLabel = Instance.new("TextLabel")
    self.EmptyLabel.Size = UDim2.new(1, 0, 1, 0)
    self.EmptyLabel.BackgroundTransparency = 1
    self.EmptyLabel.Text = "Desculpe não tem nada aqui :("
    self.EmptyLabel.TextColor3 = DESIGN.EmptyStateTextColor
    self.EmptyLabel.Font = Enum.Font.Roboto
    self.EmptyLabel.TextScaled = true
    self.EmptyLabel.TextXAlignment = Enum.TextXAlignment.Center
    self.EmptyLabel.TextYAlignment = Enum.TextYAlignment.Center
    self.EmptyLabel.Parent = self.Container
    self.EmptyLabel.Visible = true

    -- Auto-resize do ScrollingFrame
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + DESIGN.ContainerPadding * 2)
        -- Atualiza visibilidade da mensagem de vazio
        self.EmptyLabel.Visible = #self.Components == 0
    end)

    self.Components = {}
    return self
end

---
-- Construtor da GUI
---
function Tekscripts.new(options: { Name: string?, Parent: Instance?, FloatText: string?, startTab: string?, iconId: string? })
    options = options or {}
    local self = setmetatable({} :: {
        ScreenGui: ScreenGui,
        IsMinimized: boolean,
        Tabs: { [string]: any },
        CurrentTab: any?,
        IsDragging: boolean,
        IsResizing: boolean,
        Window: Frame,
        TitleBar: Frame,
        TabContainer: Frame,
        TabContentContainer: Frame,
        ResizeHandle: Frame,
        FloatButton: Frame,
        NotifyContainer: Frame,
        Connections: { any },
        BlockScreen: Frame?,
        Blocked: boolean,
        startTab: string?,
        DropdownMenu: Frame?,
        NoTabsLabel: TextLabel?,
        Title: TextLabel?,
        TitleScrollTween: Tween?,
        TitleScrollConnection: any?
    }, Tekscripts)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = options.Name or "Tekscripts"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.Parent = options.Parent or localPlayer:WaitForChild("PlayerGui")

    self.IsMinimized = false
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsDragging = false
    self.IsResizing = false
    self.Connections = {}
    self.startTab = options.startTab
    self.Blocked = false

    -- Container principal da janela
    self.Window = Instance.new("Frame")
    self.Window.Size = DESIGN.WindowSize
    self.Window.Position = UDim2.new(0.5, -DESIGN.WindowSize.X.Offset / 2, 0.5, -DESIGN.WindowSize.Y.Offset / 2)
    self.Window.BackgroundColor3 = DESIGN.WindowColor1
    self.Window.BorderSizePixel = 0
    self.Window.Parent = self.ScreenGui
    self.Window.ClipsDescendants = true

    addRoundedCorners(self.Window, DESIGN.CornerRadius)

    local windowGradient = Instance.new("UIGradient")
    windowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DESIGN.WindowColor1),
        ColorSequenceKeypoint.new(1, DESIGN.WindowColor2)
    })
    windowGradient.Rotation = 90
    windowGradient.Parent = self.Window

    -- Cabeçalho arrastável
    self.TitleBar = Instance.new("Frame")
    self.TitleBar.Size = UDim2.new(1, 0, 0, DESIGN.TitleHeight)
    self.TitleBar.Position = UDim2.new(0, 0, 0, 0)
    self.TitleBar.BackgroundTransparency = 1
    self.TitleBar.Parent = self.Window

    -- NOVO: Frame para a estrutura `<main>`
    local mainHeader = Instance.new("Frame")
    mainHeader.Size = UDim2.new(1, 0, 1, 0)
    mainHeader.BackgroundTransparency = 1
    mainHeader.LayoutOrder = 1
    mainHeader.Parent = self.TitleBar

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Horizontal
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Padding = UDim.new(0, 5) -- Espaçamento entre os elementos
    listLayout.Parent = mainHeader

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = mainHeader

    -- NOVO: Criação do Frame para o ícone
    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, DESIGN.IconSize, 0, DESIGN.IconSize)
    iconFrame.BackgroundTransparency = 1
    iconFrame.Parent = mainHeader

    -- NOVO: `ImageLabel` para o ícone
    local icon = Instance.new("ImageLabel")
    icon.Image = options.iconId or "rbxassetid://6675147490" -- Ícone padrão
    icon.Size = UDim2.new(1, 0, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Parent = iconFrame
    addRoundedCorners(icon, 5)

    -- NOVO: Frame para o título com o ClipsDescendants
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, -(DESIGN.IconSize + 10 + DESIGN.TitleHeight * 2), 1, 0) -- Ajusta o tamanho
    titleFrame.BackgroundTransparency = 1
    titleFrame.ClipsDescendants = true
    titleFrame.Parent = mainHeader

    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = options.Name or "Tekscripts"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = DESIGN.TitleColor
    title.Font = Enum.Font.RobotoMono
    title.TextScaled = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleFrame
    self.Title = title

    -- NOVO: Inicia o sistema de rolagem do título
    self:SetupTitleScroll()

    -- NOVO: Frame para os botões
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = UDim2.new(0, DESIGN.TitleHeight * 2, 1, 0) -- Ajusta o tamanho
    buttonFrame.BackgroundTransparency = 1
    buttonFrame.Parent = mainHeader
    
    local buttonListLayout = Instance.new("UIListLayout")
    buttonListLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    buttonListLayout.Padding = UDim.new(0, 5)
    buttonListLayout.Parent = buttonFrame

    -- Botão de controle (agora à esquerda do minimizar)
    local controlBtn = Instance.new("TextButton")
    controlBtn.Text = "•••"
    controlBtn.Size = UDim2.new(0, DESIGN.TitleHeight, 0, DESIGN.TitleHeight)
    controlBtn.BackgroundColor3 = DESIGN.ComponentBackground
    controlBtn.TextColor3 = DESIGN.ComponentTextColor
    controlBtn.Font = Enum.Font.Roboto
    controlBtn.TextScaled = true
    controlBtn.BorderSizePixel = 0
    controlBtn.Parent = buttonFrame

    addRoundedCorners(controlBtn, DESIGN.CornerRadius)
    addHoverEffect(controlBtn, DESIGN.ComponentBackground, DESIGN.ComponentHoverColor)

    -- Botão de minimizar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Text = "−"
    minimizeBtn.Size = UDim2.new(0, DESIGN.TitleHeight, 0, DESIGN.TitleHeight)
    minimizeBtn.BackgroundColor3 = DESIGN.MinimizeButtonColor
    minimizeBtn.TextColor3 = DESIGN.ComponentTextColor
    minimizeBtn.Font = Enum.Font.Roboto
    minimizeBtn.TextScaled = true
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = buttonFrame

    addRoundedCorners(minimizeBtn, DESIGN.CornerRadius)
    addHoverEffect(minimizeBtn, DESIGN.MinimizeButtonColor, DESIGN.ComponentHoverColor)

    minimizeBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)

    -- Menu dropdown (apenas com "Fechar")
    self.DropdownMenu = Instance.new("Frame")
    self.DropdownMenu.Size = UDim2.new(0, DESIGN.DropdownWidth, 0, 0)
    self.DropdownMenu.Position = UDim2.new(1, -DESIGN.DropdownWidth - 5, 0, DESIGN.TitleHeight + 5)
    self.DropdownMenu.BackgroundColor3 = DESIGN.DropdownBackground
    self.DropdownMenu.BorderSizePixel = 0
    self.DropdownMenu.Visible = false
    self.DropdownMenu.Parent = self.ScreenGui

    addRoundedCorners(self.DropdownMenu)

    local dropdownLayout = Instance.new("UIListLayout")
    dropdownLayout.Padding = UDim.new(0, 5)
    dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
    dropdownLayout.Parent = self.DropdownMenu

    local dropdownPadding = Instance.new("UIPadding")
    dropdownPadding.PaddingTop = UDim.new(0, 5)
    dropdownPadding.PaddingBottom = UDim.new(0, 5)
    dropdownPadding.Parent = self.DropdownMenu
    
    -- Botão "Fechar" no dropdown
    local closeOption = Instance.new("TextButton")
    closeOption.Text = "Fechar"
    closeOption.Size = UDim2.new(1, -10, 0, DESIGN.DropdownItemHeight)
    closeOption.BackgroundColor3 = DESIGN.DropdownBackground
    closeOption.TextColor3 = DESIGN.CloseButtonColor
    closeOption.Font = Enum.Font.Roboto
    closeOption.TextScaled = true
    closeOption.BorderSizePixel = 0
    closeOption.Parent = self.DropdownMenu

    addRoundedCorners(closeOption, 5)
    addHoverEffect(closeOption, DESIGN.DropdownBackground, DESIGN.DropdownItemHover)

    closeOption.MouseButton1Click:Connect(function()
        self:Destroy()
        self.DropdownMenu.Visible = false
    end)

    -- Atualiza o tamanho do dropdown
    self.DropdownMenu.Size = UDim2.new(0, DESIGN.DropdownWidth, 0, dropdownLayout.AbsoluteContentSize.Y + 10)

    self.Connections.ControlBtn = controlBtn.MouseButton1Click:Connect(function()
        self.DropdownMenu.Visible = not self.DropdownMenu.Visible
    end)

    -- Fecha o dropdown se o usuário clicar em qualquer outro lugar
    self.Connections.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if self.DropdownMenu.Visible and input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local dropdownPos = self.DropdownMenu.AbsolutePosition
            local dropdownSize = self.DropdownMenu.AbsoluteSize
            local controlBtnPos = controlBtn.AbsolutePosition
            local controlBtnSize = controlBtn.AbsoluteSize

            local isOutsideDropdown = mousePos.X < dropdownPos.X or mousePos.X > dropdownPos.X + dropdownSize.X or mousePos.Y < dropdownPos.Y or mousePos.Y > dropdownPos.Y + dropdownSize.Y
            local isOutsideControlBtn = mousePos.X < controlBtnPos.X or mousePos.X > controlBtnPos.X + controlBtnSize.X or mousePos.Y < controlBtnPos.Y or mousePos.Y > controlBtnPos.Y + controlBtnSize.Y

            if isOutsideDropdown and isOutsideControlBtn then
                self.DropdownMenu.Visible = false
            end
        end
    end)

    -- Sistema de arrastar pela barra de título
    self:SetupDragSystem()

    -- Container das abas (lateral esquerda)
    self.TabContainer = Instance.new("Frame")
    self.TabContainer.Size = UDim2.new(0, DESIGN.TabButtonWidth, 1, -DESIGN.TitleHeight)
    self.TabContainer.Position = UDim2.new(0, 0, 0, DESIGN.TitleHeight)
    self.TabContainer.BackgroundColor3 = DESIGN.WindowColor2
    self.TabContainer.BorderSizePixel = 0
    self.TabContainer.Parent = self.Window

    addRoundedCorners(self.TabContainer, DESIGN.CornerRadius)

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = self.TabContainer

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 10)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.Parent = self.TabContainer

    -- Mensagem de "sem abas"
    self.NoTabsLabel = Instance.new("TextLabel")
    self.NoTabsLabel.Size = UDim2.new(1, 0, 1, 0)
    self.NoTabsLabel.BackgroundTransparency = 1
    self.NoTabsLabel.Text = "não tem tabs :("
    self.NoTabsLabel.TextColor3 = DESIGN.EmptyStateTextColor
    self.NoTabsLabel.Font = Enum.Font.Roboto
    self.NoTabsLabel.TextScaled = true
    self.NoTabsLabel.TextXAlignment = Enum.TextXAlignment.Center
    self.NoTabsLabel.TextYAlignment = Enum.TextYAlignment.Center
    self.NoTabsLabel.Parent = self.TabContainer
    self.NoTabsLabel.Visible = true

    -- Container do conteúdo das abas
    self.TabContentContainer = Instance.new("Frame")
    self.TabContentContainer.Size = UDim2.new(1, -DESIGN.TabButtonWidth, 1, -DESIGN.TitleHeight)
    self.TabContentContainer.Position = UDim2.new(0, DESIGN.TabButtonWidth, 0, DESIGN.TitleHeight)
    self.TabContentContainer.BackgroundTransparency = 1
    self.TabContentContainer.Parent = self.Window

    -- Sistema de redimensionamento
    self:SetupResizeSystem()

    -- Float Button
    self:SetupFloatButton(options.FloatText or "📋 Expandir")

    -- Container de Notificações
    self.NotifyContainer = Instance.new("Frame")
    self.NotifyContainer.Name = "NotifyContainer"
    self.NotifyContainer.Size = UDim2.new(0, DESIGN.NotifyWidth, 1, 0)
    self.NotifyContainer.Position = UDim2.new(1, -DESIGN.NotifyWidth - 10, 0, 0)
    self.NotifyContainer.BackgroundTransparency = 1
    self.NotifyContainer.ClipsDescendants = false
    self.NotifyContainer.Parent = self.ScreenGui

    local notifyLayout = Instance.new("UIListLayout")
    notifyLayout.FillDirection = Enum.FillDirection.Vertical
    notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifyLayout.Padding = UDim.new(0, 10)
    notifyLayout.Parent = self.NotifyContainer

    local notifyPadding = Instance.new("UIPadding")
    notifyPadding.PaddingBottom = UDim.new(0, 10)
    notifyPadding.PaddingRight = UDim.new(0, 10)
    notifyPadding.Parent = self.NotifyContainer

    -- Tela de bloqueio
    self.BlockScreen = Instance.new("Frame")
    self.BlockScreen.Size = UDim2.new(1, 0, 1, 0)
    self.BlockScreen.BackgroundTransparency = 0.5
    self.BlockScreen.BackgroundColor3 = DESIGN.BlockScreenColor
    self.BlockScreen.ZIndex = 10
    self.BlockScreen.Visible = false
    self.BlockScreen.Parent = self.ScreenGui

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = self.BlockScreen
    self.BlurEffect = blur

    self.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        if player == localPlayer then
            self:Destroy()
        end
    end)
    
    return self
end

function Tekscripts:Destroy()
    if self.TitleScrollConnection then
        self.TitleScrollConnection:Disconnect()
    end
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    for _, connection in pairs(self.Connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    self.Connections = {}
end

---
-- NOVO: Sistema de rolagem de título
---
function Tekscripts:SetupTitleScroll()
    local title = self.Title
    local parentFrame = title.Parent
    local isScrolling = false

    local function updateTitleScroll()
        if not title or not parentFrame then return end
        
        local textBounds = title.TextBounds.X
        local parentWidth = parentFrame.AbsoluteSize.X

        if textBounds > parentWidth then
            isScrolling = true
            local scrollDistance = textBounds - parentWidth + 5 -- Adiciona um padding
            local scrollSpeed = 50 -- pixels por segundo

            local tweenInfo = TweenInfo.new(
                scrollDistance / scrollSpeed,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut,
                0, -- repetições
                false, -- não reverte
                1 -- atraso
            )

            local tween = TweenService:Create(title, tweenInfo, { Position = UDim2.new(0, -scrollDistance, 0, 0) })

            local function onTweenCompleted()
                if not title then return end
                title.Position = UDim2.new(0, parentWidth, 0, 0) -- Move para o final para reiniciar
                local resetTween = TweenService:Create(title, TweenInfo.new(0, Enum.EasingStyle.Linear), { Position = UDim2.new(0, 0, 0, 0) })
                resetTween:Play()
                resetTween.Completed:Wait()
                updateTitleScroll() -- Inicia o ciclo novamente
            end
            
            self.TitleScrollTween = tween
            tween.Completed:Connect(onTweenCompleted)
            tween:Play()
        else
            isScrolling = false
            title.Position = UDim2.new(0, 0, 0, 0)
        end
    end

    -- NOVO: Conecta a verificação do scroll a cada frame
    self.TitleScrollConnection = RunService.RenderStepped:Connect(function()
        local textBounds = self.Title.TextBounds.X
        local parentWidth = self.Title.Parent.AbsoluteSize.X
        if textBounds > parentWidth and not isScrolling then
            updateTitleScroll()
        elseif textBounds <= parentWidth and isScrolling then
            isScrolling = false
            if self.TitleScrollTween then
                self.TitleScrollTween:Cancel()
                self.TitleScrollTween = nil
            end
            self.Title.Position = UDim2.new(0, 0, 0, 0)
        end
    end)
end

---
-- Sistema de Arrastar
---
function Tekscripts:SetupDragSystem()
    local dragStart = nil
    local startPos = nil

    self.Connections.DragBegin = self.TitleBar.InputBegan:Connect(function(input)
        if self.Blocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = true
            dragStart = UserInputService:GetMouseLocation()
            startPos = self.Window.Position
        end
    end)

    self.Connections.DragChanged = UserInputService.InputChanged:Connect(function(input)
        if self.Blocked then return end
        if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = UserInputService:GetMouseLocation() - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )

            local tween = TweenService:Create(self.Window, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { Position = newPos })
            tween:Play()
        end
    end)

    self.Connections.DragEnded = UserInputService.InputEnded:Connect(function(input)
        if self.Blocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = false
        end
    end)
end

---
-- Sistema de Redimensionamento
---
function Tekscripts:SetupResizeSystem()
    self.ResizeHandle = Instance.new("Frame")
    self.ResizeHandle.Size = UDim2.new(0, DESIGN.ResizeHandleSize, 0, DESIGN.ResizeHandleSize)
    self.ResizeHandle.Position = UDim2.new(1, -DESIGN.ResizeHandleSize, 1, -DESIGN.ResizeHandleSize)
    self.ResizeHandle.BackgroundColor3 = DESIGN.ResizeHandleColor
    self.ResizeHandle.BorderSizePixel = 0
    self.ResizeHandle.Parent = self.Window
    addRoundedCorners(self.ResizeHandle, 4)

    local resizeIcon = Instance.new("TextLabel")
    resizeIcon.Size = UDim2.new(1, 0, 1, 0)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Text = "↘"
    resizeIcon.TextColor3 = DESIGN.ComponentTextColor
    resizeIcon.TextScaled = true
    resizeIcon.Font = Enum.Font.Roboto
    resizeIcon.Parent = self.ResizeHandle

    local resizeStart = nil
    local startSize = nil

    self.Connections.ResizeBegin = self.ResizeHandle.InputBegan:Connect(function(input)
        if self.Blocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsResizing = true
            resizeStart = UserInputService:GetMouseLocation()
            startSize = self.Window.Size
        end
    end)

    self.Connections.ResizeChanged = UserInputService.InputChanged:Connect(function(input)
        if self.Blocked then return end
        if self.IsResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = UserInputService:GetMouseLocation() - resizeStart
            local newWidth = math.clamp(startSize.X.Offset + delta.X, DESIGN.MinWindowSize.X, DESIGN.MaxWindowSize.X)
            local newHeight = math.clamp(startSize.Y.Offset + delta.Y, DESIGN.MinWindowSize.Y, DESIGN.MaxWindowSize.Y)

            local newSize = UDim2.new(0, newWidth, 0, newHeight)
            local tween = TweenService:Create(self.Window, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { Size = newSize })
            tween:Play()

            self:UpdateContainersSize()
        end
    end)

    self.Connections.ResizeEnded = UserInputService.InputEnded:Connect(function(input)
        if self.Blocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsResizing = false
        end
    end)
end

function Tekscripts:UpdateContainersSize()
    self.TabContentContainer.Size = UDim2.new(1, -DESIGN.TabButtonWidth - DESIGN.ResizeHandleSize, 1, -DESIGN.TitleHeight)
end

---
-- Float Button
---
function Tekscripts:SetupFloatButton(text: string)
    self.FloatButton = Instance.new("Frame")
    self.FloatButton.Size = DESIGN.FloatButtonSize
    self.FloatButton.Position = UDim2.new(1, -130, 0, 20)
    self.FloatButton.BackgroundColor3 = DESIGN.FloatButtonColor
    self.FloatButton.BorderSizePixel = 0
    self.FloatButton.Visible = false
    self.FloatButton.Parent = self.ScreenGui

    addRoundedCorners(self.FloatButton, DESIGN.CornerRadius)

    local floatGradient = Instance.new("UIGradient")
    floatGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DESIGN.FloatButtonColor),
        ColorSequenceKeypoint.new(1, DESIGN.WindowColor2)
    })
    floatGradient.Rotation = 45
    floatGradient.Parent = self.FloatButton

    local expandBtn = Instance.new("TextButton")
    expandBtn.Text = text
    expandBtn.Size = UDim2.new(1, 0, 1, 0)
    expandBtn.BackgroundTransparency = 1
    expandBtn.TextColor3 = DESIGN.ComponentTextColor
    expandBtn.Font = Enum.Font.Roboto
    expandBtn.TextScaled = true
    expandBtn.Parent = self.FloatButton

    addHoverEffect(expandBtn, expandBtn.BackgroundColor3, DESIGN.ComponentHoverColor)

    self.Connections.ExpandBtn = expandBtn.MouseButton1Click:Connect(function()
        if self.Blocked then return end
        self:Expand()
    end)

    local floatDragStart = nil
    local floatStartPos = nil
    local floatIsDragging = false

    self.Connections.FloatDragBegin = expandBtn.InputBegan:Connect(function(input)
        if self.Blocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatIsDragging = true
            floatDragStart = UserInputService:GetMouseLocation()
            floatStartPos = self.FloatButton.Position
        end
    end)

    self.Connections.FloatDragChanged = UserInputService.InputChanged:Connect(function(input)
        if self.Blocked then return end
        if floatIsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = UserInputService:GetMouseLocation() - floatDragStart
            local newPos = UDim2.new(
                floatStartPos.X.Scale,
                floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale,
                floatStartPos.Y.Offset + delta.Y
            )
            self.FloatButton.Position = newPos
        end
    end)

    self.Connections.FloatDragEnded = UserInputService.InputEnded:Connect(function(input)
        if self.Blocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatIsDragging = false
        end
    end)
end

---
-- Lógica de Abas
---
function Tekscripts:CreateTab(options: { Title: string })
    assert(type(options) == "table" and type(options.Title) == "string", "Invalid arguments for CreateTab")
    local tabTitle = options.Title
    local tab = Tab.new(tabTitle, self.TabContentContainer)
    self.Tabs[tabTitle] = tab

    local tabButton = Instance.new("TextButton")
    tabButton.Text = tabTitle
    tabButton.Size = UDim2.new(1, 0, 0, DESIGN.TabButtonHeight)
    tabButton.BackgroundColor3 = DESIGN.TabInactiveColor
    tabButton.TextColor3 = DESIGN.ComponentTextColor
    tabButton.Font = Enum.Font.Roboto
    tabButton.TextScaled = true
    tabButton.BorderSizePixel = 0
    tabButton.Parent = self.TabContainer
    tab.Button = tabButton

    addRoundedCorners(tabButton, DESIGN.CornerRadius)

    addHoverEffect(tabButton, DESIGN.TabInactiveColor, DESIGN.ComponentHoverColor, function()
        return self.CurrentTab ~= tab
    end)

    tabButton.MouseButton1Click:Connect(function()
        if self.Blocked then return end
        self:SetActiveTab(tab)
    end)

    tab.Container.Visible = false

    if self.startTab and self.startTab == tabTitle then
        self:SetActiveTab(tab)
    elseif not self.CurrentTab then
        self:SetActiveTab(tab)
    end

    -- Atualiza visibilidade da mensagem de "sem abas"
    self.NoTabsLabel.Visible = next(self.Tabs) == nil
    
    function tab.Destroy()
        for _, componentApi in pairs(tab.Components) do
            if componentApi and componentApi.Destroy then
                componentApi:Destroy()
            end
        end
        if tab.Container then tab.Container:Destroy() end
        if tabButton then tabButton:Destroy() end
        self.Tabs[tabTitle] = nil
        if self.CurrentTab == tab then
            self.CurrentTab = nil
            local firstTab = next(self.Tabs)
            if firstTab then
                self:SetActiveTab(self.Tabs[firstTab])
            else
                self.NoTabsLabel.Visible = true
            end
        end
    end

    return tab
end

function Tekscripts:SetActiveTab(tab: any)
    if self.CurrentTab then
        self.CurrentTab.Container.Visible = false
        self.CurrentTab.Button.BackgroundColor3 = DESIGN.TabInactiveColor
    end

    self.CurrentTab = tab
    self.CurrentTab.Container.Visible = true
    self.CurrentTab.Button.BackgroundColor3 = DESIGN.TabActiveColor
end

---
-- Funções de Estado (Minimizar/Expandir)
---
function Tekscripts:Minimize()
    if self.IsMinimized or self.Blocked then return end
    self.IsMinimized = true

    local minimizeTween = TweenService:Create(self.Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })

    minimizeTween:Play()
    minimizeTween.Completed:Connect(function()
        self.Window.Visible = false
        self.FloatButton.Visible = true

        local floatTween = TweenService:Create(self.FloatButton, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Size = DESIGN.FloatButtonSize
        })
        floatTween:Play()
    end)
end

function Tekscripts:Expand()
    if not self.IsMinimized or self.Blocked then return end
    self.IsMinimized = false

    local floatTween = TweenService:Create(self.FloatButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    floatTween:Play()

    floatTween.Completed:Connect(function()
        self.FloatButton.Visible = false
        self.Window.Visible = true

        local expandTween = TweenService:Create(self.Window, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = DESIGN.WindowSize,
            Position = UDim2.new(0.5, -DESIGN.WindowSize.X.Offset / 2, 0.5, -DESIGN.WindowSize.Y.Offset / 2)
        })
        expandTween:Play()
    end)
end

function Tekscripts:Block(state: boolean)
    self.Blocked = state
    self.BlockScreen.Visible = state
    if state then
        TweenService:Create(self.BlurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size = DESIGN.BlurEffectSize}):Play()
    else
        TweenService:Create(self.BlurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {Size = 0}):Play()
    end
end

---
-- Funções Públicas para criar componentes
---
function Tekscripts:CreateButton(tab: any, options: { Text: string, Callback: () -> () })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateButton")
    assert(type(options) == "table" and type(options.Text) == "string", "Invalid arguments for CreateButton")
    local btn = createButton(options.Text, nil, tab.Container)
    local connections = {}

    local publicApi = {
        _instance = btn,
        _connections = connections
    }

    connections.Click = btn.MouseButton1Click:Connect(function()
        if self.Blocked then return end
        local feedbackTween = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0.95, 0, 0, DESIGN.ComponentHeight * 0.9)
        })
        feedbackTween:Play()

        feedbackTween.Completed:Connect(function()
            local returnTween = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
            })
            returnTween:Play()
        end)

        if options.Callback then options.Callback() end
    end)

    function publicApi.Update(newOptions: { Text: string? })
        if newOptions.Text then
            btn.Text = newOptions.Text
        end
    end

    function publicApi.Destroy()
        if publicApi._instance then
            for _, conn in pairs(publicApi._connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            publicApi._instance:Destroy()
            publicApi._instance = nil
            publicApi._connections = nil
        end
    end

    table.insert(tab.Components, publicApi)
    return publicApi
end

function Tekscripts:CreateToggle(tab: any, options: { Text: string, Callback: (state: boolean) -> () })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateToggle")
    assert(type(options) == "table" and type(options.Text) == "string", "Invalid arguments for CreateToggle")

    -- Box externo
    local outerBox = Instance.new("Frame")
    outerBox.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    outerBox.BackgroundColor3 = DESIGN.ComponentBackground
    outerBox.BorderSizePixel = 0
    outerBox.Parent = tab.Container
    addRoundedCorners(outerBox, DESIGN.CornerRadius)

    -- Container interno (padding)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -DESIGN.ComponentPadding*2, 1, 0)
    container.Position = UDim2.new(0, DESIGN.ComponentPadding, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = outerBox

    -- Label do toggle
    local label = Instance.new("TextLabel")
    label.Text = options.Text
    label.Size = UDim2.new(0.8, -10, 1, 0) -- ocupa 80% menos um pequeno espaçamento
    label.BackgroundTransparency = 1
    label.TextColor3 = DESIGN.ComponentTextColor
    label.Font = Enum.Font.Roboto
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    -- Botão do toggle
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 50, 0, 24)
    switch.Position = UDim2.new(0.8, 10, 0.5, -12) -- 10 pixels de distância do label
    switch.BackgroundColor3 = DESIGN.InactiveToggleColor
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = container
    switch.ClipsDescendants = true
    addRoundedCorners(switch, 100)

    -- Knob do toggle
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    addRoundedCorners(knob, 100)

    local state = false
    local connections = {}
    local publicApi = {
        _instance = outerBox,
        _connections = connections
    }

    local function toggle(newState: boolean)
        state = newState
        TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and DESIGN.ActiveToggleColor or DESIGN.InactiveToggleColor
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }):Play()
        if options.Callback then options.Callback(state) end
    end

    connections.Click = switch.MouseButton1Click:Connect(function()
        if self.Blocked then return end
        toggle(not state)
    end)

    function publicApi.Update(newOptions: { Text: string?, State: boolean? })
        if newOptions.Text then
            label.Text = newOptions.Text
        end
        if newOptions.State ~= nil and newOptions.State ~= state then
            toggle(newOptions.State)
        end
    end

    function publicApi.Destroy()
        if publicApi._instance then
            for _, conn in pairs(publicApi._connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            publicApi._instance:Destroy()
            publicApi._instance = nil
            publicApi._connections = nil
        end
    end

    table.insert(tab.Components, publicApi)
    return publicApi
end

function Tekscripts:CreateTag(tab: any, options: { Text: string, Color: Color3? })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateTag")
    assert(type(options) == "table" and type(options.Text) == "string", "Invalid arguments for CreateTag")

    local tag = Instance.new("TextLabel")
    tag.Text = options.Text
    tag.Size = UDim2.new(0, DESIGN.TagWidth, 0, DESIGN.TagHeight)
    tag.BackgroundColor3 = options.Color or DESIGN.TagBackground
    tag.TextColor3 = DESIGN.ComponentTextColor
    tag.Font = Enum.Font.Roboto
    tag.TextScaled = true
    tag.TextXAlignment = Enum.TextXAlignment.Center
    tag.BorderSizePixel = 0
    tag.Parent = tab.Container
    addRoundedCorners(tag, DESIGN.CornerRadius / 2)

    local publicApi = {
        _instance = tag
    }

    function publicApi.Update(newOptions: { Text: string?, Color: Color3? })
        if newOptions.Text then
            tag.Text = newOptions.Text
        end
        if newOptions.Color then
            tag.BackgroundColor3 = newOptions.Color
        end
    end

    function publicApi.Destroy()
        if publicApi._instance then
            publicApi._instance:Destroy()
            publicApi._instance = nil
        end
    end

    table.insert(tab.Components, publicApi)
    return publicApi
end

function Tekscripts:CreateInput(tab: any, options: { Text: string, Placeholder: string, Callback: (value: any) -> (), Type: string? })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateInput")
    assert(type(options) == "table" and type(options.Text) == "string", "Invalid arguments for CreateInput")

    local inputContainer = Instance.new("Frame")
    inputContainer.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    inputContainer.BackgroundTransparency = 1
    inputContainer.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Text = options.Text
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = DESIGN.ComponentTextColor
    label.Font = Enum.Font.Roboto
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = inputContainer

    local textbox = Instance.new("TextBox")
    textbox.Size = UDim2.new(1, 0, 0.6, 0)
    textbox.Position = UDim2.new(0, 0, 0.4, 0)
    textbox.BackgroundColor3 = DESIGN.InputBackgroundColor
    textbox.PlaceholderText = options.Placeholder or ""
    textbox.PlaceholderColor3 = Color3.new(0.5, 0.5, 0.5)
    textbox.TextColor3 = DESIGN.InputTextColor
    textbox.TextScaled = true
    textbox.Font = Enum.Font.Roboto
    textbox.TextXAlignment = Enum.TextXAlignment.Left
    textbox.TextYAlignment = Enum.TextYAlignment.Center
    textbox.BorderSizePixel = 0
    textbox.Text = ""
    textbox.Parent = inputContainer
    addRoundedCorners(textbox, DESIGN.CornerRadius)

    local connections = {}
    local publicApi = {
        _instance = inputContainer,
        _connections = connections
    }

    if options.Type and options.Type:lower() == "number" then
        connections.Changed = textbox:GetPropertyChangedSignal("Text"):Connect(function()
            if self.Blocked then return end
            local newText = textbox.Text
            if tonumber(newText) or newText == "" or newText == "-" then
                if options.Callback then
                    options.Callback(tonumber(newText) or 0)
                end
            else
                textbox.Text = newText:sub(1, #newText - 1)
            end
        end)
    else
        connections.FocusLost = textbox.FocusLost:Connect(function(enterPressed)
            if self.Blocked then return end
            if enterPressed then
                if options.Callback then
                    options.Callback(textbox.Text)
                end
            end
        end)
    end

    function publicApi.Update(newOptions: { Text: string?, Placeholder: string?, Value: any? })
        if newOptions.Text then
            label.Text = newOptions.Text
        end
        if newOptions.Placeholder then
            textbox.PlaceholderText = newOptions.Placeholder
        end
        if newOptions.Value ~= nil then
            if options.Type and options.Type:lower() == "number" then
                if type(newOptions.Value) == "number" then
                    textbox.Text = tostring(newOptions.Value)
                end
            else
                textbox.Text = tostring(newOptions.Value)
            end
        end
    end

    function publicApi.Destroy()
        if publicApi._instance then
            for _, conn in pairs(publicApi._connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            publicApi._instance:Destroy()
            publicApi._instance = nil
            publicApi._connections = nil
        end
    end

    table.insert(tab.Components, publicApi)
    return publicApi
end

function Tekscripts:CreateHR(tab: any, options: { Text: string? })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateHR")

    local hrContainer = Instance.new("Frame")
    hrContainer.Size = UDim2.new(1, 0, 0, DESIGN.HRHeight)
    hrContainer.BackgroundTransparency = 1
    hrContainer.Parent = tab.Container

    local line1 = Instance.new("Frame")
    line1.BackgroundColor3 = DESIGN.HRColor
    line1.BorderSizePixel = 0
    line1.Parent = hrContainer

    local line2 = Instance.new("Frame")
    line2.BackgroundColor3 = DESIGN.HRColor
    line2.BorderSizePixel = 0
    line2.Parent = hrContainer

    local textLabel
    local textBoundsConnection

    local function updateHRLayout()
        local parentWidth = hrContainer.AbsoluteSize.X
        if textLabel then
            local textWidth = textLabel.TextBounds.X
            local padding = DESIGN.HRTextPadding
            local lineWidth = (parentWidth - textWidth - padding * 2) / 2

            line1.Size = UDim2.new(0, math.max(0, lineWidth), 0, 1)
            line1.Position = UDim2.new(0, 0, 0.5, 0)

            line2.Size = UDim2.new(0, math.max(0, lineWidth), 0, 1)
            line2.Position = UDim2.new(1, -lineWidth, 0.5, 0)

            textLabel.Position = UDim2.new(0.5, -textWidth / 2, 0.5, -textLabel.TextBounds.Y/2)
            textLabel.Size = UDim2.new(0, textWidth, 0, textLabel.TextBounds.Y)
        else
            line1.Size = UDim2.new(1, 0, 0, 1)
            line1.Position = UDim2.new(0, 0, 0.5, 0)

            line2.Size = UDim2.new(0, 0, 0, 1)
        end
    end

    local function setupText()
        if options and options.Text and options.Text ~= "" then
            textLabel = Instance.new("TextLabel")
            textLabel.Text = options.Text
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = DESIGN.ComponentTextColor
            textLabel.Font = Enum.Font.Roboto
            textLabel.TextScaled = true
            textLabel.TextXAlignment = Enum.TextXAlignment.Center
            textLabel.TextYAlignment = Enum.TextYAlignment.Center
            textLabel.Parent = hrContainer

            -- garante limites de tamanho pro texto
            local sizeConstraint = Instance.new("UITextSizeConstraint")
            sizeConstraint.MinTextSize = DESIGN.HRMinTextSize
            sizeConstraint.MaxTextSize = DESIGN.HRMaxTextSize
            sizeConstraint.Parent = textLabel

            textBoundsConnection = textLabel:GetPropertyChangedSignal("TextBounds"):Connect(updateHRLayout)
            updateHRLayout()
        else
            if textLabel then textLabel:Destroy() end
            textLabel = nil
            updateHRLayout()
        end
    end

    setupText()

    local publicApi = {
        _instance = hrContainer,
        _connections = {}
    }

    function publicApi.Update(newOptions: { Text: string? })
        if textBoundsConnection and textBoundsConnection.Connected then
            textBoundsConnection:Disconnect()
        end
        if textLabel then textLabel:Destroy() end
        options = newOptions
        setupText()
    end

    function publicApi.Destroy()
        if publicApi._instance then
            if textBoundsConnection and textBoundsConnection.Connected then
                textBoundsConnection:Disconnect()
            end
            publicApi._instance:Destroy()
            publicApi._instance = nil
        end
    end

    table.insert(tab.Components, publicApi)
    return publicApi
end

function Tekscripts:Notify(options: { 
    Title: string?, 
    Desc: string?, 
    Duration: number?, 
    Callback: (() -> ())?, 
    ButtonText: string?, 
    Persistent: boolean?, 
    ImageId: string?,
    BackgroundColor: Color3?, 
    TitleColor: Color3?, 
    DescColor: Color3?, 
    FontTitle: Enum.Font?,
    FontDesc: Enum.Font?
})
    assert(type(options) == "table" and (options.Title or options.Desc), "Title or Desc required")

    local notifyFrame = Instance.new("Frame")
    notifyFrame.Size = UDim2.new(1, 0, 0, DESIGN.NotifyHeight)
    notifyFrame.BackgroundColor3 = options.BackgroundColor or DESIGN.NotifyBackground
    notifyFrame.BackgroundTransparency = 1
    notifyFrame.BorderSizePixel = 0
    addRoundedCorners(notifyFrame, DESIGN.CornerRadius)
    notifyFrame.Parent = self.NotifyContainer
    notifyFrame.ClipsDescendants = true

    local paddingRight = 10
    local notifyImage
    if options.ImageId then
        notifyImage = Instance.new("ImageLabel")
        notifyImage.Size = UDim2.new(0, DESIGN.NotifyHeight - 8, 0, DESIGN.NotifyHeight - 8)
        notifyImage.Position = UDim2.new(1, -(DESIGN.NotifyHeight - 8) - 5, 0.5, -(DESIGN.NotifyHeight - 8)/2)
        notifyImage.BackgroundTransparency = 1
        notifyImage.Image = options.ImageId
        addRoundedCorners(notifyImage, DESIGN.CornerRadius)
        notifyImage.Parent = notifyFrame
        notifyImage.ImageTransparency = 1
        paddingRight = paddingRight + DESIGN.NotifyHeight + 5
    end

    local actionButton
    if options.ButtonText then
        actionButton = Instance.new("TextButton")
        actionButton.Text = options.ButtonText
        actionButton.Size = UDim2.new(0, 80, 0, 24)
        actionButton.Position = UDim2.new(1, -85, 0.5, -12)
        actionButton.BackgroundColor3 = DESIGN.ActiveToggleColor
        actionButton.TextColor3 = Color3.new(1,1,1)
        addRoundedCorners(actionButton, DESIGN.CornerRadius)
        actionButton.Parent = notifyFrame
        actionButton.AutoButtonColor = true
        actionButton.TextScaled = true
        actionButton.TextWrapped = true
        paddingRight = paddingRight + 85 + 5
    end

    -- Garante largura mínima para o texto
    local minTextWidth = 100
    local textContainerWidth = math.max(UDim2.new(1, -paddingRight, 1, 0).X.Offset, minTextWidth)

    local textContainer = Instance.new("Frame")
    textContainer.Size = UDim2.new(0, textContainerWidth, 1, 0)
    textContainer.Position = UDim2.new(0, 5, 0, 0)
    textContainer.BackgroundTransparency = 1
    textContainer.Parent = notifyFrame

    if options.Title then
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Text = options.Title
        titleLabel.Size = UDim2.new(1,0,0.5,0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.TextColor3 = options.TitleColor or DESIGN.NotifyTextColor
        titleLabel.Font = options.FontTitle or Enum.Font.SourceSansBold
        titleLabel.TextScaled = true
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.TextYAlignment = Enum.TextYAlignment.Top
        titleLabel.TextTransparency = 1
        titleLabel.Parent = textContainer
    end

    if options.Desc then
        local descLabel = Instance.new("TextLabel")
        descLabel.Text = options.Desc
        descLabel.Size = UDim2.new(1,0,0.5,0)
        descLabel.Position = UDim2.new(0,0,0.5,0)
        descLabel.BackgroundTransparency = 1
        descLabel.TextColor3 = options.DescColor or Color3.new(0.8,0.8,0.8)
        descLabel.Font = options.FontDesc or Enum.Font.SourceSans
        descLabel.TextScaled = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextYAlignment = Enum.TextYAlignment.Top
        descLabel.TextTransparency = 1
        descLabel.TextWrapped = true
        descLabel.Parent = textContainer
    end

    local function playTween(obj, props, duration)
        local tween = TweenService:Create(obj, TweenInfo.new(duration or 0.4, Enum.EasingStyle.Quad), props)
        tween:Play()
        return tween
    end

    local function closeNotification()
        local tweens = { playTween(notifyFrame, {BackgroundTransparency = 1}) }
        for _, child in pairs(textContainer:GetChildren()) do
            if child:IsA("TextLabel") then
                table.insert(tweens, playTween(child, {TextTransparency = 1}))
            end
        end
        if notifyImage then table.insert(tweens, playTween(notifyImage, {ImageTransparency = 1})) end
        if actionButton then table.insert(tweens, playTween(actionButton, {BackgroundTransparency = 1, TextTransparency = 1})) end
        tweens[1].Completed:Wait()
        notifyFrame:Destroy()
    end

    local function triggerCallback()
        if options.Callback then options.Callback() end
        closeNotification()
    end

    if actionButton then
        actionButton.MouseButton1Click:Connect(triggerCallback)
        actionButton.TouchTap:Connect(triggerCallback)
    else
        notifyFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                triggerCallback()
            end
        end)
    end

    -- Tween de entrada
    playTween(notifyFrame, {BackgroundTransparency = 0})
    for _, child in pairs(textContainer:GetChildren()) do
        if child:IsA("TextLabel") then playTween(child, {TextTransparency = 0}) end
    end
    if notifyImage then playTween(notifyImage, {ImageTransparency = 0}) end
    if actionButton then playTween(actionButton, {BackgroundTransparency = 0, TextTransparency = 0}) end

    if not options.Persistent then
        spawn(function()
            task.wait(options.Duration or 5)
            closeNotification()
        end)
    end
end

function Tekscripts:CreateSlider(tab: any, options: { 
    Text: string?, 
    Min: number?, 
    Max: number?, 
    Step: number?, 
    Value: number?, 
    Callback: ((number) -> ())? 
})
    assert(tab and tab.Container, "Invalid Tab object provided to CreateSlider")

    options = options or {}
    local title = options.Text or "Slider"
    local minv = tonumber(options.Min) or 0
    local maxv = tonumber(options.Max) or 100
    local step = tonumber(options.Step) or 1
    local value = tonumber(options.Value) or minv
    local callback = options.Callback

    local function clamp(n: number): number
        return math.max(minv, math.min(maxv, n))
    end

    local function roundToStep(n: number): number
        if step <= 0 then return n end
        return math.floor(n / step + 0.5) * step
    end

    value = clamp(roundToStep(value))

    -- Novo Box (Fundo do componente)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    box.BackgroundColor3 = DESIGN.ComponentBackground
    box.BorderSizePixel = 0
    box.Parent = tab.Container

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, DESIGN.CornerRadius)
    boxCorner.Parent = box

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, DESIGN.ComponentPadding)
    padding.PaddingRight = UDim.new(0, DESIGN.ComponentPadding)
    padding.Parent = box

    -- Container interno para o layout
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = box
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    listLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    listLayout.Parent = container
    
    -- Wrapper para o Título e o valor
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, 0, 0, 20)
    headerFrame.BackgroundTransparency = 1
    headerFrame.Parent = container

    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.Font = Enum.Font.Roboto
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = DESIGN.ComponentTextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Parent = headerFrame

    -- Value label
    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0, 60, 1, 0)
    valueLabel.Position = UDim2.new(1, 0, 0, 0)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Font = Enum.Font.Roboto
    valueLabel.TextSize = 15
    valueLabel.TextColor3 = DESIGN.ComponentTextColor
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Text = tostring(value)
    valueLabel.Parent = headerFrame
    
    -- Track frame
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 8)
    track.BackgroundColor3 = DESIGN.SliderTrackColor
    track.BorderSizePixel = 0
    track.Parent = container

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track

    -- Fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((value - minv) / math.max(1, (maxv - minv)), 0, 1, 0)
    fill.BackgroundColor3 = DESIGN.SliderFillColor
    fill.BorderSizePixel = 0
    fill.Parent = track

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    -- Thumb
    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    thumb.BackgroundColor3 = DESIGN.ThumbColor
    thumb.BorderSizePixel = 1
    thumb.BorderColor3 = DESIGN.ThumbOutlineColor
    thumb.Parent = track
    
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(1, 0)
    thumbCorner.Parent = thumb

    -- Logica de interacao (PC e Mobile)
    local connections: { RBXScriptConnection } = {}

    local function updateVisuals()
        local frac = (value - minv) / math.max(1, (maxv - minv))
        fill.Size = UDim2.new(frac, 0, 1, 0)
        thumb.Position = UDim2.new(frac, 0, 0.5, 0)
        valueLabel.Text = tostring(math.floor(value * 100) / 100) -- Arredonda para 2 casas decimais
    end
    
    local dragging = false
    local UIS = game:GetService("UserInputService")
    
    local function handleDrag(inputPos: Vector2)
        local absPos = track.AbsolutePosition
        local absSize = track.AbsoluteSize
        local relativeX = math.clamp(inputPos.X - absPos.X, 0, absSize.X)
        local newFrac = relativeX / absSize.X
        local newVal = clamp(roundToStep(minv + newFrac * (maxv - minv)))
        
        if newVal ~= value then
            value = newVal
            updateVisuals()
            if callback then pcall(callback, value) end
        end
    end
    
    local function handleInputBegan(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            handleDrag(input.Position)
        end
    end
    
    local function handleInputChanged(input: InputObject)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            handleDrag(input.Position)
        end
    end
    
    local function handleInputEnded(input: InputObject)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end

    table.insert(connections, track.InputBegan:Connect(handleInputBegan))
    table.insert(connections, UIS.InputChanged:Connect(handleInputChanged))
    table.insert(connections, UIS.InputEnded:Connect(handleInputEnded))

    local publicApi = {
        _instance = box, -- O PublicAPI agora aponta para o box, o container principal
        _connections = connections
    }

    function publicApi.Set(v: number)
        value = clamp(roundToStep(v))
        updateVisuals()
        if callback then pcall(callback, value) end
    end

    function publicApi.Get(): number
        return value
    end

    function publicApi.Update(newOptions)
        options = newOptions or options
        title = options.Text or title
        minv = tonumber(options.Min) or minv
        maxv = tonumber(options.Max) or maxv
        step = tonumber(options.Step) or step
        value = tonumber(options.Value) or value
        callback = options.Callback or callback
        value = clamp(roundToStep(value))
        titleLabel.Text = title
        updateVisuals()
    end

    function publicApi.Destroy()
        for _, c in ipairs(connections) do
            if c and c.Connected then pcall(function() c:Disconnect() end) end
        end
        if publicApi._instance then
            publicApi._instance:Destroy()
            publicApi._instance = nil
        end
    end
    
    updateVisuals()
    table.insert(tab.Components, publicApi)
    return publicApi
end

function Tekscripts:CreateFloatingButton(options: {
    BorderRadius: number?,
    Text: string?,
    Title: string?,
    Value: boolean?,
    Visible: boolean?,
    Drag: boolean?,
    Block: boolean?,
    Callback: ((boolean) -> ())?
})
    options = options or {}
    local width = 100 -- Largura fixa
    local height = 100 -- Altura fixa
    local borderRadius = tonumber(options.BorderRadius) or 8
    local text = tostring(options.Text or "Clique Aqui")
    local title = tostring(options.Title or "Cabeçote")
    local value = options.Value == nil and false or options.Value
    local visible = options.Visible == nil and false or options.Visible
    local drag = options.Drag == nil and true or options.Drag
    local block = options.Block == nil and false or options.Block
    local callback = options.Callback

    -- ScreenGui independente
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FloatingButtonGui"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    -- Container geral (box único)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, width, 0, height + 25)
    container.Position = UDim2.new(0.5, -width/2, 0.5, -(height + 25)/2)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Dark theme
    container.Visible = visible
    container.Parent = screenGui

    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, borderRadius)
    containerCorner.Parent = container

    -- Cabeçote
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Text = title
    header.TextColor3 = Color3.fromRGB(255, 255, 255)
    header.TextSize = 16
    header.Font = Enum.Font.GothamBold
    header.Parent = container

    -- Linha divisória opcional
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 0, 25)
    divider.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    divider.BorderSizePixel = 0
    divider.Parent = container

    -- Botão principal
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, -25)
    button.Position = UDim2.new(0, 0, 0, 25)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = not block
    button.TextScaled = true -- Adaptação de texto
    button.TextWrapped = true -- Adaptação de texto
    button.Parent = container

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, borderRadius)
    buttonCorner.Parent = button

    -- Estado interno drag
    local dragging = false
    local dragInput, dragStart, startPos
    local UIS = game:GetService("UserInputService")

    -- Atualizar visuais
    local function updateVisuals()
        container.Size = UDim2.new(0, width, 0, height + 25)
        header.Text = title
        button.Text = text
        container.Visible = visible
        button.AutoButtonColor = not block
        containerCorner.CornerRadius = UDim.new(0, borderRadius)
        buttonCorner.CornerRadius = UDim.new(0, borderRadius)
    end

    -- Toggle no clique
    button.MouseButton1Click:Connect(function()
        if block then return end
        value = not value
        if callback then
            task.spawn(callback, value)
        end
    end)

    -- Drag pelo cabeçote (com delta e lock no input inicial)
    if drag then
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = container.Position
                dragInput = input
            end
        end)

        header.InputChanged:Connect(function(input)
            if input == dragInput then
                dragInput = input
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                container.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)

        header.InputEnded:Connect(function(input)
            if input == dragInput then
                dragging = false
                dragInput = nil
            end
        end)
    end

    -- API pública
    local publicApi = {
        _instance = container,
        State = function()
            return {
                BorderRadius = borderRadius,
                Text = text,
                Title = title,
                Value = value,
                Visible = visible,
                Drag = drag,
                Block = block
            }
        end,
        Update = function(newOptions)
            if newOptions then
                borderRadius = tonumber(newOptions.BorderRadius) or borderRadius
                text = tostring(newOptions.Text or text)
                title = tostring(newOptions.Title or title)
                value = newOptions.Value == nil and value or newOptions.Value
                visible = newOptions.Visible == nil and visible or newOptions.Visible
                drag = newOptions.Drag == nil and drag or newOptions.Drag
                block = newOptions.Block == nil and block or newOptions.Block
                callback = newOptions.Callback or callback
                updateVisuals()
            end
        end,
        Destroy = function()
            if screenGui then
                screenGui:Destroy()
                screenGui = nil
            end
        end
    }

    updateVisuals()
    return publicApi
end

function Tekscripts:CreateColorPicker(tab: any, options: {
    Title: string?,
    Color: Color3?,
    Blocked: boolean?,
    Callback: ((Color3) -> ())?
})
    -- Validação inicial
    assert(tab and tab.Container, "CreateColorPicker: 'tab' e 'tab.Container' válidos são necessários.")

    -- // DEPENDÊNCIAS E SERVIÇOS //
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    -- // CONFIGURAÇÃO INICIAL //
    local defaultOptions = {
        Title = "Color",
        Color = Color3.new(1, 1, 1),
        Blocked = false,
        Callback = function() end
    }
    options = options or {}
    for key, value in pairs(defaultOptions) do
        if options[key] == nil then
            options[key] = value
        end
    end

    if typeof(options.Color) ~= "Color3" then
        warn("CreateColorPicker: 'options.Color' inválido. Esperado Color3, recebido " .. typeof(options.Color) .. ". Usando cor padrão.")
        options.Color = defaultOptions.Color
    end

    -- // ESTADO DO COMPONENTE //
    local state = {
        isExpanded = false,
        isBlocked = options.Blocked,
        isDraggingHue = false,
        isDraggingSV = false,
        h = 0, s = 1, v = 1,
        confirmedColor = options.Color
    }
    state.h, state.s, state.v = options.Color:ToHSV()

    local connections = {}

    -- // FUNÇÕES AUXILIARES //
    local function createInstance(className, properties)
        local inst = Instance.new(className)
        for prop, value in pairs(properties) do
            inst[prop] = value
        end
        return inst
    end

    local function addHoverEffect(button, originalColor, hoverColor)
        local isHovering = false
        local isDown = false

        table.insert(connections, button.MouseEnter:Connect(function()
            isHovering = true
            if not isDown and not state.isBlocked then
                TweenService:Create(button, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { BackgroundColor3 = hoverColor }):Play()
            end
        end))
        table.insert(connections, button.MouseLeave:Connect(function()
            isHovering = false
            if not isDown and not state.isBlocked then
                TweenService:Create(button, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { BackgroundColor3 = originalColor }):Play()
            end
        end))
        table.insert(connections, button.MouseButton1Down:Connect(function()
            isDown = true
        end))
        table.insert(connections, button.MouseButton1Up:Connect(function()
            isDown = false
            if not isHovering and not state.isBlocked then
                TweenService:Create(button, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { BackgroundColor3 = originalColor }):Play()
            end
        end))
    end

    -- // CRIAÇÃO DA UI //
    local box = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight),
        BackgroundColor3 = DESIGN.ComponentBackground,
        BorderSizePixel = 0,
        ClipsDescendants = true, -- 🔑 IMPEDIR VAZAMENTO VISUAL
        Parent = tab.Container,
        LayoutOrder = #tab.Components + 1
    })

    createInstance("UICorner", { CornerRadius = UDim.new(0, DESIGN.CornerRadius), Parent = box })
    createInstance("UIPadding", {
        PaddingLeft = UDim.new(0, DESIGN.ComponentPadding),
        PaddingRight = UDim.new(0, DESIGN.ComponentPadding),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = box
    })

    -- Botão principal (título + cor)
    local mainFrame = createInstance("TextButton", {
        Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight),
        BackgroundColor3 = DESIGN.ComponentBackground,
        Text = "",
        BorderSizePixel = 0,
        Parent = box
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0, DESIGN.CornerRadius), Parent = mainFrame })

    local mainLayout = createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = mainFrame
    })

    local titleLabel = createInstance("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Roboto,
        TextSize = 15,
        TextColor3 = DESIGN.ComponentTextColor,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundTransparency = 1,
        Text = options.Title,
        Parent = mainFrame
    })

    local colorBox = createInstance("Frame", {
        Size = UDim2.new(0, 40, 0, DESIGN.ComponentHeight - 10),
        BackgroundColor3 = options.Color,
        BorderSizePixel = 1,
        BorderColor3 = DESIGN.ThumbOutlineColor,
        Parent = mainFrame
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0, DESIGN.CornerRadius / 2), Parent = colorBox })

    -- Container do picker (oculto inicialmente)
    local pickerContainer = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 220),
        BackgroundColor3 = DESIGN.ComponentBackground,
        BorderSizePixel = 0,
        Visible = false, -- Mantém oculto até expansão
        Parent = box,
        LayoutOrder = 1
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0, DESIGN.CornerRadius), Parent = pickerContainer })
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 10),
        Parent = pickerContainer
    })
    createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = pickerContainer
    })

    -- Paleta SV
    local svPalette = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 150),
        BackgroundColor3 = Color3.fromHSV(state.h, 1, 1),
        Parent = pickerContainer
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0, 5), Parent = svPalette })

    local svWhiteGradient = createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(state.h, 1, 1))
        }),
        Parent = svPalette
    })

    local svBlackOverlay = createInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = svPalette
    })
    createInstance("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0, 0)),
            ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0, 1))
        }),
        Parent = svBlackOverlay
    })

    local svThumb = createInstance("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = DESIGN.ThumbColor,
        BorderSizePixel = 1,
        BorderColor3 = DESIGN.ThumbOutlineColor,
        Parent = svPalette
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = svThumb })

    -- Seletor de matiz
    local hueTrack = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundColor3 = DESIGN.SliderTrackColor,
        Parent = pickerContainer
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0, 5), Parent = hueTrack })
    createInstance("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.new(1, 1, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.new(0, 1, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
            ColorSequenceKeypoint.new(0.67, Color3.new(0, 0, 1)),
            ColorSequenceKeypoint.new(0.83, Color3.new(1, 0, 1)),
            ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
        }),
        Parent = hueTrack
    })
    local hueThumb = createInstance("Frame", {
        Size = UDim2.new(0, 12, 1, 0),
        BackgroundColor3 = DESIGN.ThumbColor,
        BorderSizePixel = 1,
        BorderColor3 = DESIGN.ThumbOutlineColor,
        Parent = hueTrack
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = hueThumb })

    -- Input e botão
    local inputConfirmContainer = createInstance("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Parent = pickerContainer
    })
    createInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 10),
        Parent = inputConfirmContainer
    })

    local colorInput = createInstance("TextBox", {
        Size = UDim2.new(0, 100, 0, 25),
        Font = Enum.Font.Roboto,
        TextSize = 14,
        TextColor3 = DESIGN.ComponentTextColor,
        BackgroundColor3 = DESIGN.InputBackground,
        BorderSizePixel = 1,
        BorderColor3 = DESIGN.ThumbOutlineColor,
        Text = string.format("%d, %d, %d", math.floor(options.Color.R * 255), math.floor(options.Color.G * 255), math.floor(options.Color.B * 255)),
        Parent = inputConfirmContainer
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0, 5), Parent = colorInput })
    createInstance("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = colorInput })

    local confirmButton = createInstance("TextButton", {
        Size = UDim2.new(0, 80, 0, 25),
        Font = Enum.Font.Roboto,
        TextSize = 14,
        TextColor3 = DESIGN.ComponentTextColor,
        BackgroundColor3 = DESIGN.ButtonBackground,
        Text = "Confirm",
        Parent = inputConfirmContainer
    })
    createInstance("UICorner", { CornerRadius = UDim.new(0, 5), Parent = confirmButton })

    -- Overlay de bloqueio
    local blockedOverlay = createInstance("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 0.5,
        BackgroundColor3 = DESIGN.BlockScreenColor,
        Visible = state.isBlocked,
        ZIndex = 10,
        Parent = box
    })

    -- // LÓGICA //
    local function updateColorVisuals(useTween: boolean)
        local newColor = Color3.fromHSV(state.h, state.s, state.v)
        if useTween then
            TweenService:Create(colorBox, TweenInfo.new(DESIGN.AnimationSpeed, Enum.EasingStyle.Quad), { BackgroundColor3 = newColor }):Play()
        else
            colorBox.BackgroundColor3 = newColor
        end

        svPalette.BackgroundColor3 = Color3.fromHSV(state.h, 1, 1)
        svWhiteGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(state.h, 1, 1))
        })
        colorInput.Text = string.format("%d, %d, %d", math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255))
    end

    local function updateThumbs()
        hueThumb.Position = UDim2.fromScale(state.h, 0.5)
        svThumb.Position = UDim2.fromScale(state.s, 1 - state.v)
        updateColorVisuals(false)
    end

    local function handleHueDrag(inputPos: Vector2)
        local relX = math.clamp(inputPos.X - hueTrack.AbsolutePosition.X, 0, hueTrack.AbsoluteSize.X)
        state.h = relX / hueTrack.AbsoluteSize.X
        hueThumb.Position = UDim2.fromScale(state.h, 0.5)
        updateColorVisuals(true)
    end

    local function handleSVDrag(inputPos: Vector2)
        local relX = math.clamp(inputPos.X - svPalette.AbsolutePosition.X, 0, svPalette.AbsoluteSize.X)
        local relY = math.clamp(inputPos.Y - svPalette.AbsolutePosition.Y, 0, svPalette.AbsoluteSize.Y)
        state.s = relX / svPalette.AbsoluteSize.X
        state.v = 1 - (relY / svPalette.AbsoluteSize.Y)
        svThumb.Position = UDim2.fromScale(state.s, 1 - state.v)
        updateColorVisuals(true)
    end

    local function parseRGBInput(text: string): Color3?
        local r, g, b = text:match("^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
        if r and g and b then
            local rNum, gNum, bNum = tonumber(r), tonumber(g), tonumber(b)
            if rNum and gNum and bNum and rNum >= 0 and rNum <= 255 and gNum >= 0 and gNum <= 255 and bNum >= 0 and bNum <= 255 then
                return Color3.fromRGB(rNum, gNum, bNum)
            end
        end
        return nil
    end

    local function expand()
        if state.isExpanded or state.isBlocked then return end
        state.isExpanded = true

        local h, s, v = state.confirmedColor:ToHSV()
        state.h, state.s, state.v = h, s, v
        updateThumbs()

        -- 👇 Torna visível APENAS após garantir que o box vai crescer
        pickerContainer.Visible = true

        local finalHeight = DESIGN.ComponentHeight + 220 + 10
        local finalSize = UDim2.new(1, 0, 0, finalHeight)
        TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = finalSize }):Play()

        tab.EmptyLabel.Visible = false
    end

    local function collapse()
        if not state.isExpanded or state.isBlocked then return end
        state.isExpanded = false

        local finalSize = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
        local closeTween = TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = finalSize })
        closeTween:Play()
        closeTween.Completed:Once(function()
            if not state.isExpanded then
                pickerContainer.Visible = false -- 👈 Oculta após animação
            end
            tab.EmptyLabel.Visible = #tab.Components == 0
        end)
    end

    local function onMainFrameClick()
        if state.isBlocked then
            local originalPos = box.Position
            TweenService:Create(box, TweenInfo.new(0.3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out, 1, true), { Position = originalPos + UDim2.new(0, 10, 0, 0) }):Play()
            return
        end
        if state.isExpanded then
            collapse()
        else
            expand()
        end
    end

    local function onConfirmClick()
        if state.isBlocked then return end
        state.confirmedColor = Color3.fromHSV(state.h, state.s, state.v)
        pcall(options.Callback, state.confirmedColor)
        colorBox.BackgroundColor3 = state.confirmedColor
        collapse()
    end

    local function onColorInputChanged()
        if state.isBlocked then return end
        local newColor = parseRGBInput(colorInput.Text)
        if newColor then
            state.confirmedColor = newColor
            state.h, state.s, state.v = newColor:ToHSV()
            updateThumbs()
        end
    end

    -- // EVENTOS //
    addHoverEffect(mainFrame, DESIGN.ComponentBackground, DESIGN.ComponentHoverColor)
    addHoverEffect(confirmButton, DESIGN.ButtonBackground, DESIGN.ComponentHoverColor)
    table.insert(connections, mainFrame.MouseButton1Click:Connect(onMainFrameClick))
    table.insert(connections, confirmButton.MouseButton1Click:Connect(onConfirmClick))
    table.insert(connections, colorInput.FocusLost:Connect(onColorInputChanged))

    table.insert(connections, hueTrack.InputBegan:Connect(function(input)
        if state.isExpanded and not state.isBlocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            state.isDraggingHue = true
            handleHueDrag(input.Position)
        end
    end))

    table.insert(connections, svPalette.InputBegan:Connect(function(input)
        if state.isExpanded and not state.isBlocked and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            state.isDraggingSV = true
            handleSVDrag(input.Position)
        end
    end))

    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if not state.isExpanded or state.isBlocked then return end
        if state.isDraggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            handleHueDrag(input.Position)
        elseif state.isDraggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            handleSVDrag(input.Position)
        end
    end))

    table.insert(connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state.isDraggingHue = false
            state.isDraggingSV = false
        end
    end))

    updateThumbs()

    -- // API PÚBLICA //
    local publicApi = {}

    function publicApi.SetColor(newColor: Color3)
        if typeof(newColor) ~= "Color3" then
            warn("SetColor: Cor inválida. Esperado Color3, recebido " .. typeof(newColor))
            return
        end
        state.confirmedColor = newColor
        colorBox.BackgroundColor3 = newColor
        local h, s, v = newColor:ToHSV()
        state.h, state.s, state.v = h, s, v
        if state.isExpanded then
            updateThumbs()
        end
        pcall(options.Callback, newColor)
    end

    function publicApi.GetColor(): Color3
        return state.confirmedColor
    end

    function publicApi.SetBlocked(isBlocked: boolean)
        state.isBlocked = isBlocked
        blockedOverlay.Visible = isBlocked
    end

    function publicApi.Destroy()
        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        table.clear(connections)
        if box and box.Parent then
            box:Destroy()
        end
        for k in pairs(publicApi) do
            publicApi[k] = nil
        end
        for i, comp in ipairs(tab.Components) do
            if comp == publicApi then
                table.remove(tab.Components, i)
                break
            end
        end
        tab.EmptyLabel.Visible = #tab.Components == 0
        local listLayout = tab.Container:FindFirstChildOfClass("UIListLayout")
        if listLayout then
            tab.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + DESIGN.ContainerPadding * 2)
        end
    end

    publicApi._instance = box
    publicApi._connections = connections
    table.insert(tab.Components, publicApi)

    local listLayout = tab.Container:FindFirstChildOfClass("UIListLayout")
    if listLayout then
        tab.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + DESIGN.ContainerPadding * 2)
    end

    return publicApi
end

function Tekscripts:CreateLabel(tab, options)
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateLabel")
    assert(type(options) == "table" and type(options.Title) == "string", "Invalid arguments for CreateLabel")

    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")

    -- Valores padrão
    local defaultOptions = {
        Title = options.Title,
        Desc = options.Desc,
        Icon = options.Icon,
        TitleColor = DESIGN.ComponentTextColor,
        DescColor = Color3.fromRGB(200, 200, 200),
        Align = Enum.TextXAlignment.Left,
        Highlight = false
    }

    -- Box principal (com sombra sutil)
    local outerBox = Instance.new("Frame")
    outerBox.Size = UDim2.new(1, 0, 0, 0)
    outerBox.BackgroundColor3 = DESIGN.ComponentBackground
    outerBox.BorderSizePixel = 0
    outerBox.ClipsDescendants = true
    outerBox.Parent = tab.Container
    addRoundedCorners(outerBox, DESIGN.CornerRadius)

    -- Sombra sutil (opcional, mas elegante)
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 0, 1, 0)
    shadow.Position = UDim2.new(0, 0, 0, 2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.92
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    addRoundedCorners(shadow, DESIGN.CornerRadius)
    shadow.Parent = outerBox

    -- Container interno
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -DESIGN.ComponentPadding * 2, 1, -DESIGN.ComponentPadding * 2)
    container.Position = UDim2.new(0, DESIGN.ComponentPadding, 0, DESIGN.ComponentPadding)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = outerBox

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.HorizontalAlignment = defaultOptions.Align == Enum.TextXAlignment.Center and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
    listLayout.Parent = container

    -- Ícone (opcional)
    local iconLabel
    if defaultOptions.Icon then
        local iconContainer = Instance.new("Frame")
        iconContainer.Size = UDim2.new(0, 24, 0, 24)
        iconContainer.BackgroundTransparency = 1
        iconContainer.Parent = container

        iconLabel = Instance.new("ImageLabel")
        iconLabel.Image = defaultOptions.Icon
        iconLabel.Size = UDim2.new(1, 0, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.Parent = iconContainer
    end

    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = defaultOptions.Title
    titleLabel.Size = UDim2.new(1, 0, 0, 26)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = defaultOptions.TitleColor
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = defaultOptions.Align
    titleLabel.TextWrapped = true
    titleLabel.Parent = container

    -- Linha de destaque (opcional)
    local highlightLine
    if defaultOptions.Highlight then
        highlightLine = Instance.new("Frame")
        highlightLine.Size = UDim2.new(0, 40, 0, 2)
        highlightLine.BackgroundColor3 = DESIGN.AccentColor or Color3.fromRGB(100, 180, 255)
        highlightLine.Position = UDim2.new(0, 0, 1, 4)
        highlightLine.Parent = titleLabel
        addRoundedCorners(highlightLine, 1)
    end

    -- Descrição
    local descLabel
    if defaultOptions.Desc then
        descLabel = Instance.new("TextLabel")
        descLabel.Text = defaultOptions.Desc
        descLabel.Size = UDim2.new(1, 0, 0, 0)
        descLabel.AutomaticSize = Enum.AutomaticSize.Y
        descLabel.BackgroundTransparency = 1
        descLabel.TextColor3 = defaultOptions.DescColor
        descLabel.Font = Enum.Font.GothamMedium
        descLabel.TextSize = 15
        descLabel.TextXAlignment = defaultOptions.Align
        descLabel.TextWrapped = true
        descLabel.LineHeight = 1.15
        descLabel.Parent = container
    end

    -- Ajuste automático de altura
    local layoutConnection = listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local totalHeight = listLayout.AbsoluteContentSize.Y + DESIGN.ComponentPadding * 2
        outerBox.Size = UDim2.new(1, 0, 0, totalHeight)
        if shadow then
            shadow.Size = UDim2.new(1, 0, 0, totalHeight)
        end
    end)

    -- API pública
    local publicApi = {
        _instance = outerBox,
        _connections = { layoutConnection },
        _titleLabel = titleLabel,
        _descLabel = descLabel,
        _iconLabel = iconLabel
    }

    -- Atualiza título com transição suave
    function publicApi.SetTitle(newTitle, color)
        if not newTitle then return end
        titleLabel.Text = newTitle
        if color then
            TweenService:Create(titleLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { TextColor3 = color }):Play()
        end
    end

    -- Atualiza descrição
    function publicApi.SetDesc(newDesc, color)
        if newDesc == nil then
            if descLabel then
                descLabel:Destroy()
                descLabel = nil
            end
            return
        end

        if not descLabel then
            descLabel = Instance.new("TextLabel")
            descLabel.Size = UDim2.new(1, 0, 0, 0)
            descLabel.AutomaticSize = Enum.AutomaticSize.Y
            descLabel.BackgroundTransparency = 1
            descLabel.Font = Enum.Font.GothamMedium
            descLabel.TextSize = 15
            descLabel.TextXAlignment = defaultOptions.Align
            descLabel.TextWrapped = true
            descLabel.LineHeight = 1.15
            descLabel.Parent = container
        end

        descLabel.Text = newDesc
        if color then
            descLabel.TextColor3 = color
        end
    end

    -- Atualiza ícone
    function publicApi.SetIcon(iconAsset)
        if iconAsset then
            if not iconLabel then
                local iconContainer = Instance.new("Frame")
                iconContainer.Size = UDim2.new(0, 24, 0, 24)
                iconContainer.BackgroundTransparency = 1
                iconContainer.Parent = container

                -- Mantém o ícone no topo
                table.insert(publicApi._connections, listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    iconContainer.LayoutOrder = -1
                end))

                iconLabel = Instance.new("ImageLabel")
                iconLabel.Image = iconAsset
                iconLabel.Size = UDim2.new(1, 0, 1, 0)
                iconLabel.BackgroundTransparency = 1
                iconLabel.Parent = iconContainer
                publicApi._iconLabel = iconLabel
            else
                iconLabel.Image = iconAsset
            end
        else
            if iconLabel and iconLabel.Parent then
                iconLabel.Parent:Destroy()
                iconLabel = nil
                publicApi._iconLabel = nil
            end
        end
    end

    -- Atualiza alinhamento
    function publicApi.SetAlignment(align)
        if not align then return end
        titleLabel.TextXAlignment = align
        if descLabel then
            descLabel.TextXAlignment = align
        end
        listLayout.HorizontalAlignment = align == Enum.TextXAlignment.Center and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
    end

    -- Atualização em lote (compatível com antigo)
    function publicApi.Update(newOptions)
        if newOptions.Title ~= nil then
            publicApi.SetTitle(newOptions.Title, newOptions.TitleColor)
        end
        if newOptions.Desc ~= nil then
            publicApi.SetDesc(newOptions.Desc, newOptions.DescColor)
        end
        if newOptions.Icon ~= nil then
            publicApi.SetIcon(newOptions.Icon)
        end
        if newOptions.Align then
            publicApi.SetAlignment(newOptions.Align)
        end
    end

    -- Destruição segura
    function publicApi.Destroy()
        if publicApi._instance then
            for _, conn in pairs(publicApi._connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            publicApi._instance:Destroy()
            publicApi._instance = nil
            publicApi._connections = nil
        end
        table.clear(publicApi)
    end

    table.insert(tab.Components, publicApi)
    return publicApi
end

function Tekscripts:CreateDropdown(tab: any, options: {
    Title: string,
    Values: { { Name: string, Image: string? } },
    Callback: (selected: {string} | string) -> (),
    MultiSelect: boolean?,
    MaxVisibleItems: number?,
    InitialValues: {string}?
})
    -- Validações
    assert(type(tab) == "table" and tab.Container, "Objeto 'tab' inválido fornecido para CreateDropdown")
    assert(type(options) == "table" and type(options.Title) == "string" and type(options.Values) == "table", "Argumentos inválidos para CreateDropdown")

    -- Configurações
    local multiSelect = options.MultiSelect or false
    local maxVisibleItems = math.min(options.MaxVisibleItems or 5, 8) -- Máximo de 8 itens visíveis para performance
    local itemHeight = 44 -- Altura aumentada para melhor touch
    local imagePadding = 8
    local imageSize = itemHeight - (imagePadding * 2)
    
    -- =================================================================
    -- BOX PRINCIPAL (Container)
    -- =================================================================
    local box = Instance.new("Frame")
    box.AutomaticSize = Enum.AutomaticSize.Y
    box.Size = UDim2.new(1, 0, 0, 0)
    box.BackgroundColor3 = DESIGN.ComponentBackground
    box.BorderSizePixel = 0
    box.Parent = tab.Container
    addRoundedCorners(box, DESIGN.CornerRadius)

    local boxLayout = Instance.new("UIListLayout")
    boxLayout.Padding = UDim.new(0, 0)
    boxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    boxLayout.Parent = box
    
    -- =================================================================
    -- MAIN (Header com título e botão)
    -- =================================================================
    local main = Instance.new("Frame")
    main.Size = UDim2.new(1, 0, 0, 50)
    main.BackgroundTransparency = 1
    main.LayoutOrder = 1
    main.Parent = box

    local mainPadding = Instance.new("UIPadding")
    mainPadding.PaddingLeft = UDim.new(0, 12)
    mainPadding.PaddingRight = UDim.new(0, 12)
    mainPadding.PaddingTop = UDim.new(0, 12)
    mainPadding.PaddingBottom = UDim.new(0, 12)
    mainPadding.Parent = main

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = options.Title
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = DESIGN.ComponentTextColor
    title.Font = Enum.Font.GothamBold
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = main

    -- Botão de ação
    local botaoText = createButton("Selecionar ▼", UDim2.new(0, 100, 1, 0), main)
    botaoText.Name = "BotaoText"
    botaoText.Position = UDim2.new(1, -100, 0, 0)
    botaoText.TextSize = 13
    botaoText.Parent = main

    -- =================================================================
    -- LISTER (ScrollingFrame para os itens)
    -- =================================================================
    local lister = Instance.new("ScrollingFrame")
    lister.Name = "Lister"
    lister.Size = UDim2.new(1, 0, 0, 0) -- Começa fechado
    lister.BackgroundTransparency = 1
    lister.BorderSizePixel = 0
    lister.ClipsDescendants = true
    lister.ScrollBarImageColor3 = DESIGN.AccentColor
    lister.ScrollBarThickness = 5
    lister.ScrollingDirection = Enum.ScrollingDirection.Y
    lister.CanvasSize = UDim2.new(0, 0, 0, 0)
    lister.AutomaticCanvasSize = Enum.AutomaticSize.Y
    lister.LayoutOrder = 2
    lister.Parent = box

    local listerLayout = Instance.new("UIListLayout")
    listerLayout.Padding = UDim.new(0, 4)
    listerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listerLayout.Parent = lister

    local listerPadding = Instance.new("UIPadding")
    listerPadding.PaddingLeft = UDim.new(0, 12)
    listerPadding.PaddingRight = UDim.new(0, 12)
    listerPadding.PaddingTop = UDim.new(0, 8)
    listerPadding.PaddingBottom = UDim.new(0, 12)
    listerPadding.Parent = lister

    -- =================================================================
    -- ESTADO E LÓGICA
    -- =================================================================
    local isOpen = false
    local selectedValues = {}
    local connections = {}
    local itemElements = {}
    local itemOrder = {}

    -- Formata valores selecionados para exibição legível
    local function formatSelectedValues(values)
        if multiSelect then
            if #values == 0 then
                return "Nenhum item selecionado"
            end
            return table.concat(values, ", ")
        else
            return values or "Nenhum item selecionado"
        end
    end

    -- Atualiza o texto do botão
    local function updateButtonText()
        local arrow = isOpen and "▲" or "▼"
        if #selectedValues == 0 then
            botaoText.Text = "Selecionar " .. arrow
        elseif #selectedValues == 1 then
            local displayText = selectedValues[1]
            if #displayText > 10 then
                displayText = string.sub(displayText, 1, 10) .. "..."
            end
            botaoText.Text = displayText .. " " .. arrow
        else
            botaoText.Text = string.format("%d itens %s", #selectedValues, arrow)
        end
    end

    -- Toggle do dropdown
    local function toggleDropdown()
        isOpen = not isOpen
        
        -- Calcula altura necessária
        local numItems = #itemOrder
        local totalItemHeight = (numItems * itemHeight) + ((numItems - 1) * listerLayout.Padding.Offset)
        local maxHeight = (maxVisibleItems * itemHeight) + ((maxVisibleItems - 1) * listerLayout.Padding.Offset)
        local targetHeight = isOpen and math.min(totalItemHeight + listerPadding.PaddingTop.Offset + listerPadding.PaddingBottom.Offset, maxHeight + listerPadding.PaddingTop.Offset + listerPadding.PaddingBottom.Offset) or 0
        
        -- Atualiza CanvasSize antes da animação
        lister.CanvasSize = UDim2.new(0, 0, 0, listerLayout.AbsoluteContentSize.Y)
        
        -- Animação suave
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(lister, tweenInfo, { 
            Size = UDim2.new(1, 0, 0, targetHeight) 
        }):Play()
        
        updateButtonText()
    end

    -- Marca/desmarca item visualmente
    local function setItemSelected(valueName, isSelected)
        local elements = itemElements[valueName]
        if not elements then return end
        
        local targetColor = isSelected and DESIGN.AccentColor or DESIGN.ComponentBackground
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad)
        
        TweenService:Create(elements.container, tweenInfo, {
            BackgroundColor3 = targetColor
        }):Play()
        
        if elements.indicator then
            elements.indicator.Visible = isSelected
        end
    end

    -- Toggle de seleção de item
    local function toggleItemSelection(valueName)
        local isCurrentlySelected = table.find(selectedValues, valueName)
        
        if multiSelect then
            -- Multi-select: adiciona/remove da lista
            if isCurrentlySelected then
                table.remove(selectedValues, isCurrentlySelected)
                setItemSelected(valueName, false)
            else
                table.insert(selectedValues, valueName)
                setItemSelected(valueName, true)
            end
        else
            -- Single-select: limpa tudo e seleciona apenas um
            for name, _ in pairs(itemElements) do 
                setItemSelected(name, false) 
            end
            
            if isCurrentlySelected then
                selectedValues = {}
            else
                selectedValues = { valueName }
                setItemSelected(valueName, true)
            end
            
            -- Fecha automaticamente no single-select
            if isOpen and not isCurrentlySelected then 
                task.delay(0.15, toggleDropdown)
            end
        end
        
        updateButtonText()
        
        -- Callback
        local selected = multiSelect and selectedValues or (selectedValues[1] or nil)
        if options.Callback then 
            options.Callback(selected)
        else
            -- Log para depuração se nenhum callback for fornecido
            print("Selecionado:", formatSelectedValues(selected))
        end
    end

    -- Função interna para criar um item
    local function createItem(valueInfo, index)
        local hasImage = valueInfo.Image and valueInfo.Image ~= ""
        
        -- Container do item
        local itemContainer = Instance.new("TextButton")
        itemContainer.Name = "Item_" .. index
        itemContainer.Size = UDim2.new(1, 0, 0, itemHeight)
        itemContainer.BackgroundColor3 = DESIGN.ComponentBackground
        itemContainer.BorderSizePixel = 0
        itemContainer.Text = ""
        itemContainer.AutoButtonColor = false
        itemContainer.LayoutOrder = index
        itemContainer.Parent = lister
        addRoundedCorners(itemContainer, DESIGN.CornerRadius - 2)

        -- Padding interno
        local itemPadding = Instance.new("UIPadding")
        itemPadding.PaddingLeft = UDim.new(0, 10)
        itemPadding.PaddingRight = UDim.new(0, 10)
        itemPadding.Parent = itemContainer

        -- Frame para organizar conteúdo
        local contentFrame = Instance.new("Frame")
        contentFrame.Size = UDim2.new(1, 0, 1, 0)
        contentFrame.BackgroundTransparency = 1
        contentFrame.Parent = itemContainer

        -- Indicador de seleção (círculo/checkbox)
        local indicator
        if multiSelect then
            -- Checkbox para multi-select
            indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 18, 0, 18)
            indicator.Position = UDim2.new(1, -18, 0.5, -9)
            indicator.BackgroundColor3 = DESIGN.AccentColor
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = contentFrame
            addRoundedCorners(indicator, UDim.new(0, 3))
            
            local checkIcon = Instance.new("TextLabel")
            checkIcon.Size = UDim2.new(1, 0, 1, 0)
            checkIcon.BackgroundTransparency = 1
            checkIcon.Text = "✓"
            checkIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
            checkIcon.Font = Enum.Font.GothamBold
            checkIcon.TextSize = 14
            checkIcon.Parent = indicator
        else
            -- Indicador circular para single-select
            indicator = Instance.new("Frame")
            indicator.Size = UDim2.new(0, 8, 0, 8)
            indicator.Position = UDim2.new(1, -8, 0.5, -4)
            indicator.BackgroundColor3 = DESIGN.AccentColor
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = contentFrame
            addRoundedCorners(indicator, UDim.new(1, 0))
        end

        -- Foto (se existir)
        local foto
        if hasImage then
            foto = Instance.new("ImageLabel")
            foto.Name = "Foto"
            foto.Size = UDim2.new(0, imageSize, 0, imageSize)
            foto.Position = UDim2.new(0, 0, 0.5, -imageSize/2)
            foto.BackgroundTransparency = 1
            foto.Image = valueInfo.Image
            foto.ScaleType = Enum.ScaleType.Fit
            foto.Parent = contentFrame
            addRoundedCorners(foto, UDim.new(0, 4))
        end

        -- Texto do item
        local textXOffset = hasImage and (imageSize + 8) or 0
        local textWidth = multiSelect and -30 or -12
        
        local itemText = Instance.new("TextLabel")
        itemText.Name = "ConteudoText"
        itemText.Size = UDim2.new(1, textWidth, 1, 0)
        itemText.Position = UDim2.new(0, textXOffset, 0, 0)
        itemText.BackgroundTransparency = 1
        itemText.Text = valueInfo.Name
        itemText.TextColor3 = DESIGN.ComponentTextColor
        itemText.Font = Enum.Font.Gotham
        itemText.TextSize = 14
        itemText.TextXAlignment = Enum.TextXAlignment.Left
        itemText.TextYAlignment = Enum.TextYAlignment.Center
        itemText.TextTruncate = Enum.TextTruncate.AtEnd
        itemText.Parent = contentFrame

        -- Armazena referências
        itemElements[valueInfo.Name] = {
            container = itemContainer,
            indicator = indicator,
            text = itemText,
            foto = foto,
            connections = {}
        }

        -- =================================================================
        -- EVENTOS DO ITEM
        -- =================================================================
        
        -- Click/Touch
        itemElements[valueInfo.Name].connections.MouseClick = itemContainer.MouseButton1Click:Connect(function()
            toggleItemSelection(valueInfo.Name)
        end)

        -- Hover (apenas desktop)
        itemElements[valueInfo.Name].connections.MouseEnter = itemContainer.MouseEnter:Connect(function()
            if not table.find(selectedValues, valueInfo.Name) then
                TweenService:Create(itemContainer, TweenInfo.new(0.15), { 
                    BackgroundColor3 = DESIGN.ItemHoverColor or Color3.fromRGB(45, 45, 50)
                }):Play()
            end
        end)

        itemElements[valueInfo.Name].connections.MouseLeave = itemContainer.MouseLeave:Connect(function()
            if not table.find(selectedValues, valueInfo.Name) then
                TweenService:Create(itemContainer, TweenInfo.new(0.15), { 
                    BackgroundColor3 = DESIGN.ComponentBackground 
                }):Play()
            end
        end)
    end

    -- =================================================================
    -- CRIAÇÃO DOS ITENS INICIAIS
    -- =================================================================
    for index, valueInfo in ipairs(options.Values) do
        table.insert(itemOrder, valueInfo.Name)
        createItem(valueInfo, index)
    end

    -- =================================================================
    -- INICIALIZAÇÃO COM VALORES
    -- =================================================================
    if options.InitialValues then
        for _, valueToSelect in ipairs(options.InitialValues) do
            if itemElements[valueToSelect] then
                table.insert(selectedValues, valueToSelect)
                setItemSelected(valueToSelect, true)
            end
        end
        updateButtonText()
    end

    -- =================================================================
    -- EVENTOS GLOBAIS
    -- =================================================================
    
    -- Click no botão principal
    connections.ButtonClick = botaoText.MouseButton1Click:Connect(toggleDropdown)

    -- Click fora para fechar (desktop e mobile)
    connections.InputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not isOpen or gameProcessed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            local clickedGui = input.GuiObject
            
            -- Fecha se clicou fora do dropdown
            if not clickedGui or not clickedGui:IsDescendantOf(box) then
                toggleDropdown()
            end
        end
    end)

    -- =================================================================
    -- API PÚBLICA
    -- =================================================================
    local publicApi = {
        _instance = box,
        _connections = connections
    }

    -- Adiciona um novo item ao dropdown
    -- @param valueInfo Table com Name (string) e Image (string, opcional)
    -- @param position Posição onde o item será inserido (opcional, padrão é no final)
    function publicApi:AddItem(valueInfo, position)
        assert(type(valueInfo) == "table" and type(valueInfo.Name) == "string", "valueInfo inválido para AddItem")
        assert(not itemElements[valueInfo.Name], "Item com nome '" .. valueInfo.Name .. "' já existe")
        
        position = position or (#itemOrder + 1)
        position = math.clamp(position, 1, #itemOrder + 1)
        
        table.insert(itemOrder, position, valueInfo.Name)
        createItem(valueInfo, position)
        
        -- Atualiza LayoutOrder de todos os itens
        for i, name in ipairs(itemOrder) do
            if itemElements[name] then
                itemElements[name].container.LayoutOrder = i
            end
        end
        
        -- Atualiza altura se aberto
        if isOpen then
            toggleDropdown()
            toggleDropdown()
        end
    end

    -- Remove um item do dropdown
    -- @param valueName Nome do item a ser removido
    function publicApi:RemoveItem(valueName)
        assert(type(valueName) == "string", "valueName deve ser string para RemoveItem")
        if itemElements[valueName] then
            local elements = itemElements[valueName]
            
            -- Desconecta eventos do item
            for _, conn in pairs(elements.connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            
            elements.container:Destroy()
            itemElements[valueName] = nil
            
            -- Remove da ordem
            local idx = table.find(itemOrder, valueName)
            if idx then
                table.remove(itemOrder, idx)
            end
            
            -- Remove da seleção se presente
            idx = table.find(selectedValues, valueName)
            if idx then
                table.remove(selectedValues, idx)
            end
            
            updateButtonText()
            
            -- Chama callback com novos selecionados
            local selected = multiSelect and selectedValues or (selectedValues[1] or nil)
            if options.Callback then 
                options.Callback(selected)
            else
                print("Selecionado:", formatSelectedValues(selected))
            end
            
            -- Atualiza altura se aberto
            if isOpen then
                toggleDropdown()
                toggleDropdown()
            end
        end
    end

    -- Remove todos os itens do dropdown
    function publicApi:ClearItems()
        while #itemOrder > 0 do
            self:RemoveItem(itemOrder[1])
        end
    end

    -- Destrói o componente e limpa conexões
    function publicApi:Destroy()
        if self._instance then
            -- Desconecta eventos globais
            for _, conn in pairs(self._connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            
            -- Desconecta eventos de cada item
            for _, elements in pairs(itemElements) do
                for _, conn in pairs(elements.connections) do
                    if conn and conn.Connected then
                        conn:Disconnect()
                    end
                end
            end
            
            self._instance:Destroy()
            self._instance = nil
            itemElements = {}
            itemOrder = {}
            selectedValues = {}
        end
    end

    -- Obtém os valores selecionados
    -- @return Table com valores selecionados (multi-select) ou string/nil (single-select)
    function publicApi:GetSelected()
        return multiSelect and selectedValues or (selectedValues[1] or nil)
    end

    -- Obtém os valores selecionados em formato de string legível
    -- @return String com valores selecionados formatados
    function publicApi:GetSelectedFormatted()
        return formatSelectedValues(multiSelect and selectedValues or (selectedValues[1] or nil))
    end

    -- Define valores selecionados programaticamente
    -- @param values String ou tabela de strings para selecionar
    function publicApi:SetSelected(values)
        -- Limpa seleção anterior
        for name, _ in pairs(itemElements) do
            setItemSelected(name, false)
        end
        selectedValues = {}
        
        -- Define novos valores
        local valuesToSet = type(values) == "table" and values or {values}
        for _, value in ipairs(valuesToSet) do
            if itemElements[value] then
                table.insert(selectedValues, value)
                setItemSelected(value, true)
            end
        end
        
        updateButtonText()
        
        -- Chama callback com novos selecionados
        local selected = multiSelect and selectedValues or (selectedValues[1] or nil)
        if options.Callback then 
            options.Callback(selected)
        else
            print("Selecionado:", formatSelectedValues(selected))
        end
    end

    -- Abre/fecha o dropdown programaticamente
    function publicApi:Toggle()
        toggleDropdown()
    end

    -- Fecha o dropdown
    function publicApi:Close()
        if isOpen then
            toggleDropdown()
        end
    end

    -- Adiciona à lista de componentes da tab
    table.insert(tab.Components, publicApi)
    
    return publicApi
end

return Tekscripts