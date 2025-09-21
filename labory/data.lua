-- UIManager.lua
local UIManager = {}
UIManager.__index = UIManager

-- Cria um Frame pai para os componentes
function UIManager.new(name, parent)
    local self = setmetatable({}, UIManager)
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = name or "UIManager"
    self.ScreenGui.Parent = parent or game.Players.LocalPlayer:WaitForChild("PlayerGui")
    self.Components = {}
    return self
end

-- Cria um botão simples
function UIManager:CreateButton(text, position, callback)
    local btn = Instance.new("TextButton")
    btn.Text = text or "Button"
    btn.Size = UDim2.new(0, 150, 0, 50)
    btn.Position = position or UDim2.new(0,0,0,0)
    btn.Parent = self.ScreenGui
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    table.insert(self.Components, btn)
    return btn
end

-- Cria um toggle simples
function UIManager:CreateToggle(text, position, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = position or UDim2.new(0,0,0,0)
    frame.Parent = self.ScreenGui

    local label = Instance.new("TextLabel")
    label.Text = text or "Toggle"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Text = "Off"
    btn.Size = UDim2.new(0.3, 0, 1, 0)
    btn.Position = UDim2.new(0.7, 0, 0, 0)
    btn.Parent = frame

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "On" or "Off"
        if callback then callback(state) end
    end)

    table.insert(self.Components, frame)
    return frame
end

-- Cria um dropdown simples
function UIManager:CreateDropdown(title, values, position, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = position or UDim2.new(0,0,0,0)
    frame.Parent = self.ScreenGui

    local label = Instance.new("TextLabel")
    label.Text = title or "Dropdown"
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.BackgroundTransparency = 1
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Text = "Select"
    btn.Size = UDim2.new(1, 0, 0.5, 0)
    btn.Position = UDim2.new(0,0,0.5,0)
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

    table.insert(self.Components, frame)
    return frame
end

return UIManager