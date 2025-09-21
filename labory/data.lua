-- UIManager.lua
local UIManager = {}
UIManager.__index = UIManager

-- Tabela de Constantes de Design
local DESIGN = {
    -- Cores
    WindowColor1 = Color3.fromRGB(35, 35, 35), -- Cor do gradiente 1
    WindowColor2 = Color3.fromRGB(25, 25, 25), -- Cor do gradiente 2
    TitleColor = Color3.fromRGB(255, 255, 255),
    ComponentBackground = Color3.fromRGB(50, 50, 50),
    ComponentTextColor = Color3.fromRGB(255, 255, 255),
    ComponentHoverColor = Color3.fromRGB(70, 70, 70), -- Nova cor de hover
    ActiveToggleColor = Color3.fromRGB(70, 160, 255),
    InactiveToggleColor = Color3.fromRGB(70, 70, 70),
    DropdownHoverColor = Color3.fromRGB(60, 60, 60),

    -- Tamanhos e Dimensões
    WindowSize = UDim2.new(0, 400, 0, 500),
    TitleHeight = 30,
    ComponentHeight = 40,
    ComponentPadding = 10,
    ContainerPadding = 10,

    -- Outros
    CornerRadius = 8
}

---
-- Funções de Criação de Componentes
---

local function addRoundedCorners(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = instance
end

-- Novo: Função para adicionar efeitos de hover
local function addHoverEffect(button, originalColor, hoverColor)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
    end)
end

-- Cria um botão base
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
-- Construtor da GUI
---
function UIManager.new(name, parent)
    local self = setmetatable({}, UIManager)

    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = name or "UIManager"
    self.ScreenGui.Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")

    self.Window = Instance.new("Frame")
    self.Window.Size = DESIGN.WindowSize
    self.Window.Position = UDim2.new(0.5, -DESIGN.WindowSize.X.Offset / 2, 0.5, -DESIGN.WindowSize.Y.Offset / 2)
    self.Window.BackgroundColor3 = DESIGN.WindowColor1 -- A cor base, o gradiente vai sobrepor
    self.Window.BorderSizePixel = 0
    self.Window.Parent = self.ScreenGui

    addRoundedCorners(self.Window, DESIGN.CornerRadius)

    -- Novo: Gradiente de cor
    local windowGradient = Instance.new("UIGradient")
    windowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, DESIGN.WindowColor1),
        ColorSequenceKeypoint.new(1, DESIGN.WindowColor2)
    })
    windowGradient.Rotation = 90
    windowGradient.Parent = self.Window

    local title = Instance.new("TextLabel")
    title.Text = name or "UIManager"
    title.Size = UDim2.new(1, 0, 0, DESIGN.TitleHeight)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = DESIGN.TitleColor
    title.TextScaled = true
    title.Font = Enum.Font.Roboto
    title.Parent = self.Window

    self.ComponentContainer = Instance.new("Frame")
    self.ComponentContainer.Size = UDim2.new(1, 0, 1, 0)
    self.ComponentContainer.Position = UDim2.new(0, 0, 0, DESIGN.TitleHeight)
    self.ComponentContainer.BackgroundTransparency = 1
    self.ComponentContainer.Parent = self.Window

    -- Novo: UIPadding para margens internas
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, DESIGN.ContainerPadding)
    padding.PaddingLeft = UDim.new(0, DESIGN.ContainerPadding)
    padding.PaddingRight = UDim.new(0, DESIGN.ContainerPadding)
    padding.PaddingBottom = UDim.new(0, DESIGN.ContainerPadding)
    padding.Parent = self.ComponentContainer

    -- UIListLayout para organizar os componentes automaticamente
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, DESIGN.ComponentPadding)
    listLayout.Parent = self.ComponentContainer
    
    self.Components = {}
    return self
end

---
-- Funções Públicas para criar componentes
---

function UIManager:CreateButton(text, callback)
    local btn = createButton(text, nil, self.ComponentContainer)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    table.insert(self.Components, btn)
    return btn
end

function UIManager:CreateToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = self.ComponentContainer

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
    
    table.insert(self.Components, frame)
    return frame
end

function UIManager:CreateDropdown(title, values, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, DESIGN.ComponentHeight)
    frame.BackgroundTransparency = 1
    frame.Parent = self.ComponentContainer
    
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
    
    table.insert(self.Components, frame)
    return frame
end

return UIManager
