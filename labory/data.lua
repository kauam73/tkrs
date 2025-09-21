-- UIManager.lua
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
    TabActiveColor = Color3.fromRGB(70, 70, 70),
    TabInactiveColor = Color3.fromRGB(40, 40, 40),
    ResizeHandleColor = Color3.fromRGB(150, 150, 150),

    -- Tamanhos e Dimensões
    WindowSize = UDim2.new(0, 400, 0, 500),
    WindowMinSize = Vector2.new(300, 400),
    TitleHeight = 30,
    ComponentHeight = 40,
    ComponentPadding = 10,
    ContainerPadding = 10,
    FloatButtonSize = UDim2.new(0, 100, 0, 50),
    TabButtonWidth = 80, -- Largura da aba na lateral
    ResizeHandleSize = 10,
}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

---
-- Funções de Criação de Componentes
---

local function addRoundedCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

local function addHoverEffect(button, originalColor, hoverColor)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
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
    self.Container = Instance.new("Frame")
    self.Container.Size = UDim2.new(1, 0, 1, 0)
    self.Container.Position = UDim2.new(0, 0, 0, 0)
    self.Container.BackgroundTransparency = 1
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
    
    self.Window = Instance.new("Frame")
    self.Window.Size = DESIGN.WindowSize
    self.Window.Position = UDim2.new(0.5, -DESIGN.WindowSize.X.Offset / 2, 0.5, -DESIGN.WindowSize.Y.Offset / 2)
    self.Window.BackgroundColor3 = DESIGN.WindowColor1
    self.Window.BorderSizePixel = 0
    self.Window.Parent = self.ScreenGui

    addRoundedCorners(self.Window, DESIGN.CornerRadius)

    local windowGradient = Instance.new("UIGradient")
    windowGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, DESIGN.WindowColor1), ColorSequenceKeypoint.new(1, DESIGN.WindowColor2)})
    windowGradient.Rotation = 90
    windowGradient.Parent = self.Window

    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, DESIGN.TitleHeight)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = self.Window

    local title = Instance.new("TextLabel")
    title.Text = name or "UIManager"
    title.Size = UDim2.new(1, -DESIGN.TitleHeight, 0, DESIGN.TitleHeight)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = DESIGN.TitleColor
    title.TextScaled = true
    title.Font = Enum.Font.Roboto
    title.Parent = titleBar

    -- Lógica de arrastar a janela
    local isDraggingWindow = false
    local dragStartPositionWindow = Vector2.new()
    titleBar.MouseButton1Down:Connect(function(x, y)
        isDraggingWindow = true
        dragStartPositionWindow = Vector2.new(x, y) - self.Window.AbsolutePosition
        local dragConnection = UserInputService.InputChanged:Connect(function(input)
            if isDraggingWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
                local newPos = input.Position - dragStartPositionWindow
                self.Window.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDraggingWindow = false
                dragConnection:Disconnect()
            end
        end)
    end)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Text = "–"
    minimizeBtn.Size = UDim2.new(0, DESIGN.TitleHeight, 0, DESIGN.TitleHeight)
    minimizeBtn.Position = UDim2.new(1, -DESIGN.TitleHeight, 0, 0)
    minimizeBtn.BackgroundColor3 = DESIGN.MinimizeButtonColor
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.Roboto
    minimizeBtn.TextScaled = true
    minimizeBtn.Parent = titleBar
    minimizeBtn.MouseButton1Click:Connect(function() self:Minimize() end)
    addRoundedCorners(minimizeBtn, DESIGN.CornerRadius)
    addHoverEffect(minimizeBtn, DESIGN.MinimizeButtonColor, DESIGN.ComponentHoverColor)

    -- Floating Button
    self.FloatButton = Instance.new("Frame")
    self.FloatButton.Size = DESIGN.FloatButtonSize
    self.FloatButton.Position = UDim2.new(0.5, -DESIGN.FloatButtonSize.X.Offset / 2, 1, -DESIGN.FloatButtonSize.Y.Offset - 10)
    self.FloatButton.BackgroundColor3 = DESIGN.FloatButtonColor
    self.FloatButton.Visible = false
    self.FloatButton.Parent = self.ScreenGui
    addRoundedCorners(self.FloatButton, DESIGN.CornerRadius)

    local floatLayout = Instance.new("UIListLayout")
    floatLayout.FillDirection = Enum.FillDirection.Horizontal
    floatLayout.Parent = self.FloatButton

    local expandBtn = createButton("Expandir", UDim2.new(0.5, 0, 1, 0), self.FloatButton)
    expandBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    expandBtn.Font = Enum.Font.Roboto
    expandBtn.MouseButton1Click:Connect(function() self:Expand() end)

    local dragBtn = createButton("Arrastar", UDim2.new(0.5, 0, 1, 0), self.FloatButton)
    dragBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    dragBtn.Font = Enum.Font.Roboto

    -- Lógica de Arrastar o FloatButton
    local isDraggingFloat = false
    local dragStartPositionFloat = Vector2.new()
    dragBtn.MouseButton1Down:Connect(function(x, y)
        isDraggingFloat = true
        dragStartPositionFloat = Vector2.new(x, y) - self.FloatButton.AbsolutePosition
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingFloat and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPos = input.Position - dragStartPositionFloat
            self.FloatButton.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingFloat = false
        end
    end)

    -- Barra de Redimensionamento
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Size = UDim2.new(0, DESIGN.ResizeHandleSize, 0, DESIGN.ResizeHandleSize)
    resizeHandle.Position = UDim2.new(1, -DESIGN.ResizeHandleSize, 1, -DESIGN.ResizeHandleSize)
    resizeHandle.BackgroundColor3 = DESIGN.ResizeHandleColor
    resizeHandle.Parent = self.Window
    addRoundedCorners(resizeHandle, 3)

    -- Lógica de Redimensionar
    local isResizing = false
    resizeHandle.MouseButton1Down:Connect(function()
        isResizing = true
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newSize = input.Position - self.Window.AbsolutePosition
            local clampedSize = Vector2.new(
                math.max(newSize.X, DESIGN.WindowMinSize.X),
                math.max(newSize.Y, DESIGN.WindowMinSize.Y)
            )
            self.Window.Size = UDim2.new(0, clampedSize.X, 0, clampedSize.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = false
        end
    end)

    -- Containers para os botões das abas e o conteúdo das abas
    self.TabButtonContainer = Instance.new("Frame")
    self.TabButtonContainer.Size = UDim2.new(0, DESIGN.TabButtonWidth, 1, -DESIGN.TitleHeight)
    self.TabButtonContainer.Position = UDim2.new(0, 0, 0, DESIGN.TitleHeight)
    self.TabButtonContainer.BackgroundTransparency = 1
    self.TabButtonContainer.Parent = self.Window
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Vertical
    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.Parent = self.TabButtonContainer

    self.TabContentContainer = Instance.new("Frame")
    self.TabContentContainer.Size = UDim2.new(1, -DESIGN.TabButtonWidth, 1, -DESIGN.TitleHeight)
    self.TabContentContainer.Position = UDim2.new(0, DESIGN.TabButtonWidth, 0, DESIGN.TitleHeight)
    self.TabContentContainer.BackgroundTransparency = 1
    self.TabContentContainer.Parent = self.Window
    
    return self
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
    tabButton.Size = UDim2.new(1, 0, 0, DESIGN.TabButtonWidth) -- Adaptação para layout vertical
    tabButton.BackgroundColor3 = DESIGN.TabInactiveColor
    tabButton.TextColor3 = DESIGN.ComponentTextColor
    tabButton.Parent = self.TabButtonContainer
    addRoundedCorners(tabButton, 6)

    tabButton.MouseButton1Click:Connect(function()
        self:SetActiveTab(tab)
    end)
    
    tab.Button = tabButton

    if next(self.Tabs) == tabTitle then
        self:SetActiveTab(tab)
    end
    
    return tab
end

function UIManager:SetActiveTab(tab)
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
function UIManager:Minimize()
    if self.IsMinimized then return end
    self.IsMinimized = true
    local TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(self.Window, TweenInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(self.Window, TweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()

    -- Oculta e move o float button
    self.FloatButton.Position = UDim2.new(0.5, -DESIGN.FloatButtonSize.X.Offset / 2, 1, -DESIGN.FloatButtonSize.Y.Offset - 10)
    self.FloatButton.Visible = true
end

function UIManager:Expand()
    if not self.IsMinimized then return end
    self.IsMinimized = false
    
    local TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(self.Window, TweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(self.Window, TweenInfo, {Size = DESIGN.WindowSize}):Play()

    -- Oculta o float button
    self.FloatButton.Visible = false
end

---
-- Funções Públicas para criar componentes
---

function UIManager:CreateButton(tab, text, callback)
    local btn = createButton(text, nil, tab.Container)
    btn.MouseButton1Click:Connect(function()
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

    local label = Instance.new("TextLabel")
    label.Text = text or "Toggle"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = DESIGN.ComponentTextColor
    label.Font = Enum.Font.Roboto
    label.Parent = frame

    local btn = createButton("Off", UDim2.new(0.3, 0, 1, 0), frame)
    btn.Position = UDim2.new(0.7, 0, 0, 0)
    btn.BackgroundColor3 = DESIGN.InactiveToggleColor
    addHoverEffect(btn, DESIGN.InactiveToggleColor, DESIGN.ComponentHoverColor)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "On" or "Off"
        btn.BackgroundColor3 = state and DESIGN.ActiveToggleColor or DESIGN.InactiveToggleColor
        if callback then callback(state) end
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
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = DESIGN.ComponentTextColor
    label.Font = Enum.Font.Roboto
    label.Parent = frame

    local btn = createButton("Select", UDim2.new(1, 0, 0.5, 0), frame)
    btn.Position = UDim2.new(0, 0, 0.5, 0)
    
    local dropdownOpen = false
    local dropdownFrame

    btn.MouseButton1Click:Connect(function()
        if dropdownOpen then
            if dropdownFrame then dropdownFrame:Destroy() end
            dropdownOpen = false
        else
            dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, #values * DESIGN.ComponentHeight)
            dropdownFrame.Position = UDim2.new(0, 0, 1, 0)
            dropdownFrame.BackgroundColor3 = DESIGN.ComponentBackground
            dropdownFrame.Parent = frame
            addRoundedCorners(dropdownFrame, DESIGN.CornerRadius)

            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = dropdownFrame

            for _, v in ipairs(values) do
                local option = createButton(v, UDim2.new(1, 0, 0, DESIGN.ComponentHeight-2), dropdownFrame)
                
                option.MouseButton1Click:Connect(function()
                    btn.Text = v
                    dropdownOpen = false
                    dropdownFrame:Destroy()
                    if callback then callback(v) end
                end)
            end
            dropdownOpen = true
        end
    end)
    
    table.insert(tab.Components, frame)
    return frame
end

return UIManager
