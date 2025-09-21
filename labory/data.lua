-- UIManager.lua
local UIManager = {}
UIManager.__index = UIManager

-- Cria um Window/Box pai para os componentes
function UIManager.new(name, parent)
    local self = setmetatable({}, UIManager)

    -- ScreenGui principal
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = name or "UIManager"
    self.ScreenGui.Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")

    -- Frame container estilo Window
    self.Window = Instance.new("Frame")
    self.Window.Size = UDim2.new(0, 400, 0, 500)
    self.Window.Position = UDim2.new(0.5, -200, 0.5, -250)
    self.Window.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    self.Window.BorderSizePixel = 0
    self.Window.Parent = self.ScreenGui

    -- Título da Window
    local title = Instance.new("TextLabel")
    title.Text = name or "UIManager"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.TextScaled = true
    title.Parent = self.Window

    -- Container para organizar os componentes
    self.ComponentContainer = Instance.new("Frame")
    self.ComponentContainer.Size = UDim2.new(1, -20, 1, -40)
    self.ComponentContainer.Position = UDim2.new(0,10,0,40)
    self.ComponentContainer.BackgroundTransparency = 1
    self.ComponentContainer.Parent = self.Window

    self.Components = {}
    self.NextY = 0 -- controla posição vertical automática
    return self
end

-- Função auxiliar pra posicionar componentes automaticamente
function UIManager:_PlaceComponent(frame, height)
    frame.Position = UDim2.new(0,0,0,self.NextY)
    frame.Parent = self.ComponentContainer
    self.NextY = self.NextY + height + 10
end

-- Cria um botão simples
function UIManager:CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text or "Button"
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)

    self:_PlaceComponent(btn, 40)
    table.insert(self.Components, btn)
    return btn
end

-- Cria um toggle simples
function UIManager:CreateToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Text = text or "Toggle"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Text = "Off"
    btn.Size = UDim2.new(0.3, 0, 1, 0)
    btn.Position = UDim2.new(0.7,0,0,0)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = frame

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "On" or "Off"
        if callback then callback(state) end
    end)

    self:_PlaceComponent(frame, 40)
    table.insert(self.Components, frame)
    return frame
end

-- Cria um dropdown simples
function UIManager:CreateDropdown(title, values, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Text = title or "Dropdown"
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Text = "Select"
    btn.Size = UDim2.new(1, 0, 0.5, 0)
    btn.Position = UDim2.new(0,0,0.5,0)
    btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = frame

    local dropdownOpen = false
    local dropdownFrame

    btn.MouseButton1Click:Connect(function()
        if dropdownOpen then
            if dropdownFrame then dropdownFrame:Destroy() end
            dropdownOpen = false
        else
            dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, 0, 0, #values*30)
            dropdownFrame.Position = UDim2.new(0,0,1,0)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
            dropdownFrame.Parent = frame

            for i, v in ipairs(values) do
                local option = Instance.new("TextButton")
                option.Text = v
                option.Size = UDim2.new(1,0,0,30)
                option.Position = UDim2.new(0,0,0,(i-1)*30)
                option.BackgroundColor3 = Color3.fromRGB(70,70,70)
                option.TextColor3 = Color3.fromRGB(255,255,255)
                option.Parent = dropdownFrame
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

    self:_PlaceComponent(frame, 40)
    table.insert(self.Components, frame)
    return frame
end

return UIManager