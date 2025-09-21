local UIManager = {}
UIManager.__index = UIManager

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
    FloatButtonColor = Color3.fromRGB(50, 50, 50),
    TabActiveColor = Color3.fromRGB(70, 160, 255),
    TabInactiveColor = Color3.fromRGB(40, 40, 40),
    ResizeHandleColor = Color3.fromRGB(70, 70, 70),

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

    -- Outros
    CornerRadius = 10
}

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

---
-- Funções de Criação de Componentes
---

local function addRoundedCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or DESIGN.CornerRadius)
    corner.Parent = instance
end

local function addHoverEffect(button, originalColor, hoverColor)
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = hoverColor})
        tween:Play()
    end)
    button.MouseLeave:Connect(function()
        local tween = TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = originalColor})
        tween:Play()
    end)
end

local function createButton(text, size, parent)
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

function Tab.new(name, parent)
    local self = setmetatable({}, Tab)
    
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
function UIManager.new(name, parent)
    local self = setmetatable({}, UIManager)
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = name or "UIManager"
    self.ScreenGui.Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    self.IsMinimized = false
    self.Tabs = {}
    self.CurrentTab = nil
    self.IsDragging = false
    self.IsResizing = false
    
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
    title.Text = name or "UIManager"
    title.Size = UDim2.new(1, -DESIGN.TitleHeight, 1, 0)
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

    minimizeBtn.MouseButton1Click:Connect(function()
        self:Minimize()
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
    self:SetupFloatButton()
    
    return self
end

---
-- Sistema de Arrastar
---
function UIManager:SetupDragSystem()
    local dragStart = nil
    local startPos = nil
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = true
            dragStart = input.Position
            startPos = self.Window.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X,
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
            
            -- Suavizar movimento
            local tween = TweenService:Create(self.Window, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Position = newPos})
            tween:Play()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = false
        end
    end)
end

---
-- Sistema de Redimensionamento
---
function UIManager:SetupResizeSystem()
    -- Handle de redimensionamento no canto inferior direito
    self.ResizeHandle = Instance.new("Frame")
    self.ResizeHandle.Size = UDim2.new(0, DESIGN.ResizeHandleSize, 0, DESIGN.ResizeHandleSize)
    self.ResizeHandle.Position = UDim2.new(1, -DESIGN.ResizeHandleSize, 1, -DESIGN.ResizeHandleSize)
    self.ResizeHandle.BackgroundColor3 = DESIGN.ResizeHandleColor
    self.ResizeHandle.BorderSizePixel = 0
    self.ResizeHandle.Parent = self.Window

    addRoundedCorners(self.ResizeHandle, 4)

    -- Indicador visual do resize handle
    local resizeIcon = Instance.new("TextLabel")
    resizeIcon.Size = UDim2.new(1, 0, 1, 0)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Text = "↘"
    resizeIcon.TextColor3 = DESIGN.ComponentTextColor
    resizeIcon.TextScaled = true
    resizeIcon.Font = Enum.Font.Roboto
    resizeIcon.Parent = self.ResizeHandle

    -- Hover effect para o resize handle
    addHoverEffect(self.ResizeHandle, DESIGN.ResizeHandleColor, DESIGN.ComponentHoverColor)

    local resizeStart = nil
    local startSize = nil
    
    self.ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsResizing = true
            resizeStart = input.Position
            startSize = self.Window.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if self.IsResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.clamp(startSize.X.Offset + delta.X, DESIGN.MinWindowSize.X, DESIGN.MaxWindowSize.X)
            local newHeight = math.clamp(startSize.Y.Offset + delta.Y, DESIGN.MinWindowSize.Y, DESIGN.MaxWindowSize.Y)
            
            local newSize = UDim2.new(0, newWidth, 0, newHeight)
            
            -- Suavizar redimensionamento
            local tween = TweenService:Create(self.Window, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = newSize})
            tween:Play()
            
            -- Atualizar containers
            self:UpdateContainersSize()
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsResizing = false
        end
    end)
end

function UIManager:UpdateContainersSize()
    -- Atualizar tamanho do container de conteúdo das abas
    self.TabContentContainer.Size = UDim2.new(1, -DESIGN.TabButtonWidth - DESIGN.ResizeHandleSize, 1, -DESIGN.TitleHeight)
end

---
-- Float Button Melhorado
---
function UIManager:SetupFloatButton()
    self.FloatButton = Instance.new("Frame")
    self.FloatButton.Size = DESIGN.FloatButtonSize
    self.FloatButton.Position = UDim2.new(1, -130, 1, -60)
    self.FloatButton.BackgroundColor3 = DESIGN.FloatButtonColor
    self.FloatButton.BorderSizePixel = 0
    self.FloatButton.Visible = false
    self.FloatButton.Parent = self.ScreenGui
    
    addRoundedCorners(self.FloatButton, DESIGN.CornerRadius)

    -- Gradient para o float button
    local floatGradient = Instance.new("UIGradient")
    floatGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DESIGN.FloatButtonColor), 
        ColorSequenceKeypoint.new(1, DESIGN.WindowColor2)
    })
    floatGradient.Rotation = 45
    floatGradient.Parent = self.FloatButton

    local expandBtn = Instance.new("TextButton")
    expandBtn.Text = "📋 Expandir"
    expandBtn.Size = UDim2.new(1, 0, 1, 0)
    expandBtn.BackgroundTransparency = 1
    expandBtn.TextColor3 = DESIGN.ComponentTextColor
    expandBtn.Font = Enum.Font.Roboto
    expandBtn.TextScaled = true
    expandBtn.Parent = self.FloatButton

    addHoverEffect(self.FloatButton, DESIGN.FloatButtonColor, DESIGN.ComponentHoverColor)

    expandBtn.MouseButton1Click:Connect(function()
        self:Expand()
    end)

    -- Sistema de arrastar para o float button
    local floatDragStart = nil
    local floatStartPos = nil
    local floatIsDragging = false
    
    expandBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatIsDragging = true
            floatDragStart = input.Position
            floatStartPos = self.FloatButton.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if floatIsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatDragStart
            local newPos = UDim2.new(
                floatStartPos.X.Scale, 
                floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale, 
                floatStartPos.Y.Offset + delta.Y
            )
            self.FloatButton.Position = newPos
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatIsDragging = false
        end
    end)
end

---
-- Lógica de Abas
---
function UIManager:CreateTab(options)
    local tabTitle = options.Title or "Nova Aba"
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
    
    addRoundedCorners(tabButton, DESIGN.CornerRadius)
    addHoverEffect(tabButton, DESIGN.TabInactiveColor, DESIGN.ComponentHoverColor)

    tabButton.MouseButton1Click:Connect(function()
        self:SetActiveTab(tab)
    end)
    
    tab.Button = tabButton

    if not self.CurrentTab then
        self:SetActiveTab(tab)
    end
    
    return tab
end

function UIManager:SetActiveTab(tab)
    -- Desativar aba atual
    if self.CurrentTab then
        self.CurrentTab.Container.Visible = false
        local inactiveTween = TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = DESIGN.TabInactiveColor
        })
        inactiveTween:Play()
    end
    
    -- Ativar nova aba
    self.CurrentTab = tab
    self.CurrentTab.Container.Visible = true
    
    local activeTween = TweenService:Create(self.CurrentTab.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        BackgroundColor3 = DESIGN.TabActiveColor
    })
    activeTween:Play()
end

---
-- Funções de Estado (Minimizar/Expandir)
---
function UIManager:Minimize()
    if self.IsMinimized then return end
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
    if not self.IsMinimized then return end
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

---
-- Funções Públicas para criar componentes
---

function UIManager:CreateButton(tab, text, callback)
    local btn = createButton(text, nil, tab.Container)
    btn.MouseButton1Click:Connect(function()
        -- Feedback visual
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
        
        if callback then callback() end
    end)
    table.insert(tab.Components, btn)
    return btn
end

function UIManager:CreateToggle(tab, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container

    -- Label
    local label = Instance.new("TextLabel")
    label.Text = text or "Toggle"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = DESIGN.ComponentTextColor
    label.Font = Enum.Font.Roboto
    label.TextScaled = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    -- Cápsula do switch (agora botão clicável)
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 50, 0, 24)
    switch.Position = UDim2.new(0.7, 0, 0.5, -12)
    switch.BackgroundColor3 = DESIGN.InactiveToggleColor
    switch.Text = "" -- sem texto
    switch.AutoButtonColor = false
    switch.Parent = frame
    switch.ClipsDescendants = true

    local corner = Instance.new("UICorner", switch)
    corner.CornerRadius = UDim.new(1, 0)

    -- Bolinha interna
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switch

    local knobCorner = Instance.new("UICorner", knob)
    knobCorner.CornerRadius = UDim.new(1, 0)

    -- Interatividade
    local state = false
    local TweenService = game:GetService("TweenService")

    local function toggle(newState)
        state = newState

        -- cor da cápsula
        TweenService:Create(switch, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and DESIGN.ActiveToggleColor or DESIGN.InactiveToggleColor
        }):Play()

        -- posição da bolinha
        TweenService:Create(knob, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        }):Play()

        if callback then
            callback(state)
        end
    end

    -- Evento de clique (funciona no PC e mobile)
    switch.MouseButton1Click:Connect(function()
        toggle(not state)
    end)

    table.insert(tab.Components, frame)
    return frame
end

function UIManager:CreateDropdown(tab, title, values, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = tab.Container
    
    local label = Instance.new("TextLabel")
    label.Text = title or "Dropdown"
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

    btn.MouseButton1Click:Connect(function()
        if dropdownOpen then
            if dropdownFrame then 
                local closeTween = TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(1, 0, 0, 0)
                })
                closeTween:Play()
                closeTween.Completed:Connect(function()
                    dropdownFrame:Destroy()
                end)
            end
            dropdownOpen = false
            btn.Text = btn.Text:gsub("▲", "▼")
        else
            btn.Text = btn.Text:gsub("▼", "▲")
            dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
            dropdownFrame.Position = UDim2.new(0, 0, 1, 0)
            dropdownFrame.BackgroundColor3 = DESIGN.ComponentBackground
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Parent = frame
            dropdownFrame.ClipsDescendants = true
            addRoundedCorners(dropdownFrame, DESIGN.CornerRadius)

            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = dropdownFrame

            for _, v in ipairs(values) do
                local option = createButton(v, UDim2.new(1, 0, 0, DESIGN.ComponentHeight-2), dropdownFrame)
                
                option.MouseButton1Click:Connect(function()
                    btn.Text = v .. " ▼"
                    dropdownOpen = false
                    
                    local closeTween = TweenService:Create(dropdownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                        Size = UDim2.new(1, 0, 0, 0)
                    })
                    closeTween:Play()
                    closeTween.Completed:Connect(function()
                        dropdownFrame:Destroy()
                    end)
                    
                    if callback then callback(v) end
                end)
            end
            
            local openTween = TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(1, 0, 0, #values * DESIGN.ComponentHeight)
            })
            openTween:Play()
            dropdownOpen = true
        end
    end)
    
    table.insert(tab.Components, frame)
    return frame
end

return UIManager