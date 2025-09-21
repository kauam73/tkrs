--!strict
local UIManager = {}
UIManager.__index = UIManager

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Tabela de Constantes de Design
local DESIGN = {
    -- Cores
    WindowColor1 = Color3.fromRGB(35, 35, 35),
    WindowColor2 = Color3.fromRGB(25, 25, 25),
    TitleColor = Color3.fromRGB(255, 255, 255),
    ComponentBackground = Color3.fromRGB(50, 50, 50),
    ComponentTextColor = Color3.fromRGB(255, 255, 255),
    ComponentHoverColor = Color3.fromRGB(70, 70, 70),
    ActiveToggleColor = Color3.fromRGB(70, 160, 255),
    InactiveToggleColor = Color3.fromRGB(70, 70, 70),
    DropdownHoverColor = Color3.fromRGB(60, 60, 60),
    MinimizeButtonColor = Color3.fromRGB(255, 50, 50),
    CloseButtonColor = Color3.fromRGB(255, 50, 50),
    FloatButtonColor = Color3.fromRGB(50, 50, 50),
    TabActiveColor = Color3.fromRGB(70, 160, 255),
    TabInactiveColor = Color3.fromRGB(40, 40, 40),
    ResizeHandleColor = Color3.fromRGB(70, 70, 70),
    NotifyBackground = Color3.fromRGB(50, 50, 50),
    NotifyTextColor = Color3.fromRGB(255, 255, 255),
    TagBackground = Color3.fromRGB(70, 160, 255),
    InputBackgroundColor = Color3.fromRGB(40, 40, 40),
    InputTextColor = Color3.fromRGB(255, 255, 255),
    HRColor = Color3.fromRGB(70, 70, 70),
    BlockScreenColor = Color3.new(0, 0, 0),

    -- Tamanhos e Dimensões
    WindowSize = UDim2.new(0, 500, 0, 400),
    MinWindowSize = Vector2.new(300, 250),
    MaxWindowSize = Vector2.new(800, 600),
    TitleHeight = 35,
    ComponentHeight = 40,
    ComponentPadding = 10,
    ContainerPadding = 10,
    FloatButtonSize = UDim2.new(0, 120, 0, 40),
    TabButtonWidth = 120,
    TabButtonHeight = 35,
    ResizeHandleSize = 15,
    NotifyWidth = 200,
    NotifyHeight = 40,
    TagHeight = 25,
    TagWidth = 100,
    HRHeight = 2,
    HRTextPadding = 10,

    -- Outros
    CornerRadius = 10,
    ButtonIconSize = 25
}

---
-- Funções de Criação de Componentes
---

local function addRoundedCorners(instance: Instance, radius: number?)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or DESIGN.CornerRadius)
    corner.Parent = instance
end

local function addHoverEffect(button: GuiObject, originalColor: Color3, hoverColor: Color3)
    local isHovering = false
    local isDown = false

    button.MouseEnter:Connect(function()
        isHovering = true
        if not isDown then
            local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = hoverColor })
            tween:Play()
        end
    end)
    button.MouseLeave:Connect(function()
        isHovering = false
        if not isDown then
            local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = originalColor })
            tween:Play()
        end
    end)
    button.MouseButton1Down:Connect(function()
        isDown = true
    end)
    button.MouseButton1Up:Connect(function()
        isDown = false
        if not isHovering then
            local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = originalColor })
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
        Button: TextButton?
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

    -- Auto-resize do ScrollingFrame
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Container.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + DESIGN.ContainerPadding * 2)
    end)

    self.Components = {}
    return self
end

---
-- Construtor da GUI
---
function UIManager.new(options: { Name: string?, Parent: Instance?, FloatText: string?, startTab: string? })
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
        startTab: string?
    }, UIManager)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = options.Name or "UIManager"
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

    local title = Instance.new("TextLabel")
    title.Text = options.Name or "UIManager"
    title.Size = UDim2.new(1, -(DESIGN.TitleHeight * 2), 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = DESIGN.TitleColor
    title.TextScaled = true
    title.Font = Enum.Font.RobotoMono
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = self.TitleBar

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Text = "–"
    minimizeBtn.Size = UDim2.new(0, DESIGN.TitleHeight, 0, DESIGN.TitleHeight)
    minimizeBtn.Position = UDim2.new(1, -DESIGN.TitleHeight, 0, 0)
    minimizeBtn.BackgroundColor3 = DESIGN.MinimizeButtonColor
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.Roboto
    minimizeBtn.TextScaled = true
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Parent = self.TitleBar

    addRoundedCorners(minimizeBtn, DESIGN.CornerRadius)
    addHoverEffect(minimizeBtn, DESIGN.MinimizeButtonColor, Color3.fromRGB(255, 80, 80))

    self.Connections.MinimizeBtn = minimizeBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)

    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, DESIGN.TitleHeight, 0, DESIGN.TitleHeight)
    closeBtn.Position = UDim2.new(1, -(DESIGN.TitleHeight * 2), 0, 0)
    closeBtn.BackgroundColor3 = DESIGN.CloseButtonColor
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.Roboto
    closeBtn.TextScaled = true
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = self.TitleBar

    addRoundedCorners(closeBtn, DESIGN.CornerRadius)
    addHoverEffect(closeBtn, DESIGN.CloseButtonColor, Color3.fromRGB(255, 80, 80))

    self.Connections.CloseBtn = closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
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

    -- Container do conteúdo das abas
    self.TabContentContainer = Instance.new("Frame")
    self.TabContentContainer.Size = UDim2.new(1, -DESIGN.TabButtonWidth - DESIGN.ResizeHandleSize, 1, -DESIGN.TitleHeight)
    self.TabContentContainer.Position = UDim2.new(0, DESIGN.TabButtonWidth, 0, DESIGN.TitleHeight)
    self.TabContentContainer.BackgroundTransparency = 1
    self.TabContentContainer.Parent = self.Window

    -- Sistema de redimensionamento
    self:SetupResizeSystem()

    -- Float Button melhorado
    self:SetupFloatButton(options.FloatText or "📋 Expandir")

    -- Container de Notificações (visível mesmo quando minimizado)
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

    -- Conexão para garantir que o painel persista
    self.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        if player == localPlayer then
            self:Destroy()
        end
    end)
    
    return self
end

function UIManager:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    -- Limpa referências para garbage collection
    for _, connection in pairs(self.Connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
    self.Connections = {}
end

---
-- Sistema de Arrastar
---
function UIManager:SetupDragSystem()
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

            local tween = TweenService:Create(self.Window, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Position = newPos })
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
function UIManager:SetupResizeSystem()
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

    addHoverEffect(self.ResizeHandle, DESIGN.ResizeHandleColor, DESIGN.ComponentHoverColor)

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
            local tween = TweenService:Create(self.Window, TweenInfo.new(0.1, Enum.EasingStyle.Quad), { Size = newSize })
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

function UIManager:UpdateContainersSize()
    self.TabContentContainer.Size = UDim2.new(1, -DESIGN.TabButtonWidth - DESIGN.ResizeHandleSize, 1, -DESIGN.TitleHeight)
end

---
-- Float Button Melhorado
---
function UIManager:SetupFloatButton(text: string)
    self.FloatButton = Instance.new("Frame")
    self.FloatButton.Size = DESIGN.FloatButtonSize
    self.FloatButton.Position = UDim2.new(1, -130, 1, -60)
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

    addHoverEffect(self.FloatButton, DESIGN.FloatButtonColor, DESIGN.ComponentHoverColor)

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
function UIManager:CreateTab(options: { Title: string })
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
    addHoverEffect(tabButton, DESIGN.TabInactiveColor, DESIGN.ComponentHoverColor)

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
    
    function tab.Destroy()
        for _, componentApi in pairs(tab.Components) do
            if componentApi and componentApi.Destroy then
                componentApi.Destroy()
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
            end
        end
    end

    return tab
end

function UIManager:SetActiveTab(tab: any)
    if self.CurrentTab then
        self.CurrentTab.Container.Visible = false
        -- Restaura a cor do botão da aba anterior
        self.CurrentTab.Button.BackgroundColor3 = DESIGN.TabInactiveColor
    end

    self.CurrentTab = tab
    self.CurrentTab.Container.Visible = true

    -- Define a cor do botão da nova aba ativa
    self.CurrentTab.Button.BackgroundColor3 = DESIGN.TabActiveColor
end

---
-- Funções de Estado (Minimizar/Expandir)
---
function UIManager:Minimize()
    if self.IsMinimized or self.Blocked then return end
    self.IsMinimized = true

    local minimizeTween = TweenService:Create(self.Window, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    })

    minimizeTween:Play()
    minimizeTween.Completed:Connect(function()
        self.Window.Visible = false
        self.FloatButton.Visible = true

        local floatTween = TweenService:Create(self.FloatButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Size = DESIGN.FloatButtonSize
        })
        floatTween:Play()
    end)
end

function UIManager:Expand()
    if not self.IsMinimized or self.Blocked then return end
    self.IsMinimized = false

    local floatTween = TweenService:Create(self.FloatButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0)
    })
    floatTween:Play()

    floatTween.Completed:Connect(function()
        self.FloatButton.Visible = false
        self.Window.Visible = true

        local expandTween = TweenService:Create(self.Window, TweenInfo.new(0.4, Enum.EasingStyle.Back), {
            Size = DESIGN.WindowSize,
            Position = UDim2.new(0.5, -DESIGN.WindowSize.X.Offset / 2, 0.5, -DESIGN.WindowSize.Y.Offset / 2)
        })
        expandTween:Play()
    end)
end

function UIManager:Block(state: boolean)
    self.Blocked = state
    self.BlockScreen.Visible = state
end

---
-- Funções Públicas para criar componentes
---
function UIManager:CreateButton(tab: any, options: { Text: string, Callback: () -> () })
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

function UIManager:CreateToggle(tab: any, options: { Text: string, Callback: (state: boolean) -> () })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateToggle")
    assert(type(options) == "table" and type(options.Text) == "string", "Invalid arguments for CreateToggle")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Text = options.Text
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = DESIGN.ComponentTextColor
    label.Font = Enum.Font.Roboto
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 50, 0, 24)
    switch.Position = UDim2.new(0.7, 0, 0.5, -12)
    switch.BackgroundColor3 = DESIGN.InactiveToggleColor
    switch.Text = ""
    switch.AutoButtonColor = false
    switch.Parent = frame
    switch.ClipsDescendants = true
    addRoundedCorners(switch, 100)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch
    addRoundedCorners(knob, 100)

    local state = false
    local connections = {}
    local publicApi = {
        _instance = frame,
        _connections = connections
    }

    local function toggle(newState: boolean)
        state = newState
        TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundColor3 = state and DESIGN.ActiveToggleColor or DESIGN.InactiveToggleColor }):Play()
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10) }):Play()
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

function UIManager:CreateDropdown(tab: any, options: { Title: string, Values: { string }, Callback: (value: string) -> () })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateDropdown")
    assert(type(options) == "table" and type(options.Title) == "string" and type(options.Values) == "table", "Invalid arguments for CreateDropdown")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    local label = Instance.new("TextLabel")
    label.Text = options.Title
    label.Size = UDim2.new(1, 0, 0.4, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = DESIGN.ComponentTextColor
    label.Font = Enum.Font.Roboto
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = createButton("Selecionar ▼", UDim2.new(1, 0, 0.6, 0), frame)
    btn.Position = UDim2.new(0, 0, 0.4, 0)

    local dropdownOpen = false
    local dropdownFrame
    local connections = {}
    local currentValues = options.Values
    local currentValue = options.SelectedValue or currentValues[1] or ""
    btn.Text = currentValue .. " ▼"

    local publicApi = {
        _instance = frame,
        _connections = connections
    }

    local function closeDropdown()
        if dropdownFrame then
            dropdownFrame:Destroy()
        end
        dropdownOpen = false
        btn.Text = currentValue .. " ▼"
    end
    
    connections.InputBegan = UserInputService.InputBegan:Connect(function(input)
        if dropdownOpen and input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not btn:IsAncestorOf(input.Target) and (not dropdownFrame or not dropdownFrame:IsAncestorOf(input.Target)) then
                closeDropdown()
            end
        end
    end)
    
    connections.Click = btn.MouseButton1Click:Connect(function()
        if self.Blocked then return end
        if dropdownOpen then
            closeDropdown()
        else
            btn.Text = currentValue .. " ▲"
            dropdownFrame = Instance.new("ScreenGui")
            dropdownFrame.Name = "DropdownOverlay"
            dropdownFrame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            dropdownFrame.Parent = localPlayer:WaitForChild("PlayerGui")
            
            local dropdownHolder = Instance.new("Frame")
            dropdownHolder.Size = UDim2.new(1, 0, 1, 0)
            dropdownHolder.Position = UDim2.new(0, 0, 0, 0)
            dropdownHolder.BackgroundTransparency = 1
            dropdownHolder.Parent = dropdownFrame

            local pos, size = btn.AbsolutePosition, btn.AbsoluteSize
            
            local listFrame = Instance.new("Frame")
            listFrame.Size = UDim2.new(0, size.X, 0, 0)
            listFrame.Position = UDim2.new(0, pos.X, 0, pos.Y + size.Y)
            listFrame.BackgroundColor3 = DESIGN.ComponentBackground
            listFrame.BorderSizePixel = 0
            listFrame.Parent = dropdownHolder
            listFrame.ClipsDescendants = true
            addRoundedCorners(listFrame, DESIGN.CornerRadius)

            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = listFrame

            for _, v in ipairs(currentValues) do
                local option = createButton(v, UDim2.new(1, 0, 0, DESIGN.ComponentHeight - 2), listFrame)
                option.MouseButton1Click:Connect(function()
                    currentValue = v
                    if options.Callback then options.Callback(v) end
                    closeDropdown()
                end)
            end
            
            local totalHeight = #currentValues * (DESIGN.ComponentHeight - 2) + dropdownLayout.Padding.Offset * (#currentValues - 1)
            local openTween = TweenService:Create(listFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(0, size.X, 0, totalHeight) })
            openTween:Play()
            
            dropdownOpen = true
        end
    end)

    function publicApi.Update(newOptions: { Title: string?, Values: { string }?, SelectedValue: string? })
        if newOptions.Title then
            label.Text = newOptions.Title
        end
        if newOptions.Values then
            currentValues = newOptions.Values
        end
        if newOptions.SelectedValue and table.find(currentValues, newOptions.SelectedValue) then
            currentValue = newOptions.SelectedValue
            btn.Text = currentValue .. " ▼"
        end
    end

    function publicApi.Destroy()
        if publicApi._instance then
            for _, conn in pairs(publicApi._connections) do
                if conn and conn.Connected then
                    conn:Disconnect()
                end
            end
            closeDropdown()
            publicApi._instance:Destroy()
            publicApi._instance = nil
            publicApi._connections = nil
        end
    end

    table.insert(tab.Components, publicApi)
    return publicApi
end

function UIManager:CreateLabel(tab: any, options: { Title: string, Desc: string? })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateLabel")
    assert(type(options) == "table" and type(options.Title) == "string", "Invalid arguments for CreateLabel")

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = tab.Container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = container

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = options.Title
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.BackgroundColor3 = DESIGN.ComponentBackground
    titleLabel.TextColor3 = DESIGN.ComponentTextColor
    titleLabel.Font = Enum.Font.Roboto
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.BorderSizePixel = 0
    titleLabel.Parent = container
    addRoundedCorners(titleLabel, DESIGN.CornerRadius)

    local descLabel
    if options.Desc then
        descLabel = Instance.new("TextLabel")
        descLabel.Text = options.Desc
        descLabel.Size = UDim2.new(1, 0, 0, 15)
        descLabel.BackgroundColor3 = DESIGN.ComponentBackground
        descLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6)
        descLabel.Font = Enum.Font.Roboto
        descLabel.TextScaled = true
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.TextWrap = true
        descLabel.BorderSizePixel = 0
        descLabel.Parent = container
        addRoundedCorners(descLabel, DESIGN.CornerRadius)
    end

    local layoutConnection = listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
    end)

    local publicApi = {
        _instance = container,
        _connections = { layoutConnection }
    }

    function publicApi.Update(newOptions: { Title: string?, Desc: string? })
        if newOptions.Title then
            titleLabel.Text = newOptions.Title
        end
        if newOptions.Desc ~= nil then
            if newOptions.Desc and not descLabel then
                descLabel = Instance.new("TextLabel")
                descLabel.Text = newOptions.Desc
                descLabel.Size = UDim2.new(1, 0, 0, 15)
                descLabel.BackgroundColor3 = DESIGN.ComponentBackground
                descLabel.TextColor3 = Color3.new(0.6, 0.6, 0.6)
                descLabel.Font = Enum.Font.Roboto
                descLabel.TextScaled = true
                descLabel.TextXAlignment = Enum.TextXAlignment.Left
                descLabel.TextWrap = true
                descLabel.BorderSizePixel = 0
                descLabel.Parent = container
                addRoundedCorners(descLabel, DESIGN.CornerRadius)
            elseif newOptions.Desc and descLabel then
                descLabel.Text = newOptions.Desc
            elseif not newOptions.Desc and descLabel then
                descLabel:Destroy()
                descLabel = nil
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

function UIManager:CreateTag(tab: any, options: { Text: string, Color: Color3? })
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

function UIManager:CreateInput(tab: any, options: { Text: string, Placeholder: string, Callback: (value: any) -> (), Type: string? })
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

function UIManager:CreateHR(tab: any, options: { Text: string? })
    assert(type(tab) == "table" and tab.Container, "Invalid Tab object provided to CreateHR")
    local hrContainer = Instance.new("Frame")
    hrContainer.Size = UDim2.new(1, 0, 0, DESIGN.HRHeight)
    hrContainer.BackgroundTransparency = 1
    hrContainer.Parent = tab.Container

    local line1 = Instance.new("Frame")
    line1.Size = UDim2.new(0.5, 0, 1, 0)
    line1.Position = UDim2.new(0, 0, 0, 0)
    line1.BackgroundColor3 = DESIGN.HRColor
    line1.BorderSizePixel = 0
    line1.Parent = hrContainer

    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(0.5, 0, 1, 0)
    line2.Position = UDim2.new(0.5, 0, 0, 0)
    line2.BackgroundColor3 = DESIGN.HRColor
    line2.BorderSizePixel = 0
    line2.Parent = hrContainer

    local textLabel
    if options and options.Text and options.Text ~= "" then
        textLabel = Instance.new("TextLabel")
        textLabel.Text = options.Text
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = DESIGN.ComponentTextColor
        textLabel.Font = Enum.Font.Roboto
        textLabel.TextScaled = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
        textLabel.Size = UDim2.new(0, 0, 0, 20)
        textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        textLabel.Parent = hrContainer

        local textBounds = textLabel.TextBounds.X
        textLabel.Size = UDim2.new(0, textBounds + DESIGN.HRTextPadding, 0, 20)
        textLabel.Position = UDim2.new(0.5, -textBounds / 2 - DESIGN.HRTextPadding / 2, 0, 0)

        local lineSize = (hrContainer.AbsoluteSize.X - textBounds - DESIGN.HRTextPadding) / 2
        line1.Size = UDim2.new(0, lineSize, 1, 0)
        line2.Size = UDim2.new(0, lineSize, 1, 0)
        line2.Position = UDim2.new(0, lineSize + textBounds + DESIGN.HRTextPadding, 0, 0)

        task.spawn(function()
            local connection = RunService.RenderStepped:Connect(function()
                local newTextBounds = textLabel.TextBounds.X
                if newTextBounds ~= textBounds then
                    textBounds = newTextBounds
                    textLabel.Size = UDim2.new(0, textBounds + DESIGN.HRTextPadding, 0, 20)
                    textLabel.Position = UDim2.new(0.5, -textBounds / 2 - DESIGN.HRTextPadding / 2, 0, 0)

                    local newSize = (hrContainer.AbsoluteSize.X - textBounds - DESIGN.HRTextPadding) / 2
                    line1.Size = UDim2.new(0, newSize, 1, 0)
                    line2.Size = UDim2.new(0, newSize, 1, 0)
                    line2.Position = UDim2.new(0, newSize + textBounds + DESIGN.HRTextPadding, 0, 0)
                end
            end)
            hrContainer.AncestryChanged:Connect(function()
                if not hrContainer.Parent then
                    connection:Disconnect()
                end
            end)
        end)
    else
        line1.Size = UDim2.new(1, 0, 1, 0)
        line2:Destroy()
    end

    local publicApi = {
        _instance = hrContainer,
        _connections = {}
    }

    function publicApi.Update(newOptions: { Text: string? })
        -- Remova o texto e as linhas existentes
        if textLabel then textLabel:Destroy() end
        line1:Destroy()
        if line2 then line2:Destroy() end

        -- Crie as novas linhas e texto com base na nova opção
        line1 = Instance.new("Frame")
        line1.Size = UDim2.new(0.5, 0, 1, 0)
        line1.Position = UDim2.new(0, 0, 0, 0)
        line1.BackgroundColor3 = DESIGN.HRColor
        line1.BorderSizePixel = 0
        line1.Parent = hrContainer

        line2 = Instance.new("Frame")
        line2.Size = UDim2.new(0.5, 0, 1, 0)
        line2.Position = UDim2.new(0.5, 0, 0, 0)
        line2.BackgroundColor3 = DESIGN.HRColor
        line2.BorderSizePixel = 0
        line2.Parent = hrContainer

        if newOptions and newOptions.Text and newOptions.Text ~= "" then
            textLabel = Instance.new("TextLabel")
            textLabel.Text = newOptions.Text
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = DESIGN.ComponentTextColor
            textLabel.Font = Enum.Font.Roboto
            textLabel.TextScaled = true
            textLabel.TextXAlignment = Enum.TextXAlignment.Center
            textLabel.TextYAlignment = Enum.TextYAlignment.Center
            textLabel.Size = UDim2.new(0, 0, 0, 20)
            textLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            textLabel.Parent = hrContainer
            
            local textBounds = textLabel.TextBounds.X
            textLabel.Size = UDim2.new(0, textBounds + DESIGN.HRTextPadding, 0, 20)
            textLabel.Position = UDim2.new(0.5, -textBounds / 2 - DESIGN.HRTextPadding / 2, 0, 0)
            
            local lineSize = (hrContainer.AbsoluteSize.X - textBounds - DESIGN.HRTextPadding) / 2
            line1.Size = UDim2.new(0, lineSize, 1, 0)
            line2.Size = UDim2.new(0, lineSize, 1, 0)
            line2.Position = UDim2.new(0, lineSize + textBounds + DESIGN.HRTextPadding, 0, 0)
        else
            line1.Size = UDim2.new(1, 0, 1, 0)
            line2:Destroy()
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

function UIManager:Notify(options: { Text: string, Duration: number? })
    assert(type(options) == "table" and type(options.Text) == "string", "Invalid arguments for Notify")

    local notifyFrame = Instance.new("Frame")
    notifyFrame.Size = UDim2.new(1, 0, 0, DESIGN.NotifyHeight)
    notifyFrame.BackgroundColor3 = DESIGN.NotifyBackground
    notifyFrame.BackgroundTransparency = 1
    notifyFrame.BorderSizePixel = 0
    addRoundedCorners(notifyFrame, DESIGN.CornerRadius)

    local notifyText = Instance.new("TextLabel")
    notifyText.Text = options.Text
    notifyText.Size = UDim2.new(1, 0, 1, 0)
    notifyText.BackgroundTransparency = 1
    notifyText.TextColor3 = DESIGN.NotifyTextColor
    notifyText.TextTransparency = 1
    notifyText.Font = Enum.Font.Roboto
    notifyText.TextScaled = true
    notifyText.TextXAlignment = Enum.TextXAlignment.Center
    notifyText.TextYAlignment = Enum.TextYAlignment.Center
    notifyText.Parent = notifyFrame

    notifyFrame.Parent = self.NotifyContainer

    local tweenInBg = TweenService:Create(notifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 })
    local tweenInText = TweenService:Create(notifyText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
    tweenInBg:Play()
    tweenInText:Play()

    spawn(function()
        task.wait(options.Duration or 5)
        local tweenOutBg = TweenService:Create(notifyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 })
        local tweenOutText = TweenService:Create(notifyText, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
        tweenOutBg:Play()
        tweenOutText:Play()
        tweenOutBg.Completed:Wait()
        notifyFrame:Destroy()
    end)
end

return UIManager
