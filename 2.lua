local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Configuração
local BLUR_INTENSITY = 24
local UI_COLOR_SCHEME = {
    Primary = Color3.fromRGB(0, 150, 255),
    Secondary = Color3.fromRGB(0, 200, 200),
    Background = Color3.fromRGB(15, 15, 15),
    Text = Color3.fromRGB(240, 240, 240),
    Error = Color3.fromRGB(255, 50, 50),
    Warning = Color3.fromRGB(255, 150, 0)
}

-- Blur
local blur = Instance.new("BlurEffect")
blur.Size = BLUR_INTENSITY
blur.Parent = Lighting

-- Interface Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Bloqueador de Input
local InputBlocker = Instance.new("Frame")
InputBlocker.Size = UDim2.new(1,0,1,0)
InputBlocker.BackgroundTransparency = 1
InputBlocker.Active = true
InputBlocker.Parent = ScreenGui

-- Container Principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.35,0,0.4,0)
MainFrame.Position = UDim2.new(0.5,0,0.5,0)
MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
MainFrame.BackgroundColor3 = UI_COLOR_SCHEME.Background
MainFrame.Parent = ScreenGui

-- UICorner e UIStroke
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.03,0)
UICorner.Parent = MainFrame
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = UI_COLOR_SCHEME.Primary
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0.15,0)
Header.BackgroundColor3 = UI_COLOR_SCHEME.Primary
Header.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "TEKSCRIPTS V2"
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 22
Title.TextColor3 = UI_COLOR_SCHEME.Text
Title.Size = UDim2.new(1,-40,1,0)
Title.Position = UDim2.new(0,20,0,0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Status de Rede
local NetworkStats = Instance.new("Frame")
NetworkStats.Size = UDim2.new(0.4,0,1,0)
NetworkStats.Position = UDim2.new(0.6,0,0,0)
NetworkStats.BackgroundTransparency = 1
NetworkStats.Parent = Header

local PingLabel = Instance.new("TextLabel")
PingLabel.Text = "Ping: 0ms"
PingLabel.Font = Enum.Font.GothamMedium
PingLabel.TextSize = 14
PingLabel.TextColor3 = UI_COLOR_SCHEME.Text
PingLabel.Size = UDim2.new(0.5,0,1,0)
PingLabel.BackgroundTransparency = 1
PingLabel.TextXAlignment = Enum.TextXAlignment.Right
PingLabel.Parent = NetworkStats

local FPSLabel = Instance.new("TextLabel")
FPSLabel.Text = "FPS: 0"
FPSLabel.Font = Enum.Font.GothamMedium
FPSLabel.TextSize = 14
FPSLabel.TextColor3 = UI_COLOR_SCHEME.Text
FPSLabel.Size = UDim2.new(0.5,0,1,0)
FPSLabel.Position = UDim2.new(0.5,0,0,0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
FPSLabel.Parent = NetworkStats

-- Sistema de Logs
local LogsContainer = Instance.new("ScrollingFrame")
LogsContainer.Size = UDim2.new(0.95,0,0.65,0)
LogsContainer.Position = UDim2.new(0.025,0,0.2,0)
LogsContainer.BackgroundTransparency = 1
LogsContainer.ScrollBarThickness = 4
LogsContainer.Parent = MainFrame

local LogsLayout = Instance.new("UIListLayout")
LogsLayout.Padding = UDim.new(0,5)
LogsLayout.Parent = LogsContainer

-- Barra de Progresso
local ProgressContainer = Instance.new("Frame")
ProgressContainer.Size = UDim2.new(0.9,0,0.08,0)
ProgressContainer.Position = UDim2.new(0.05,0,0.88,0)
ProgressContainer.BackgroundColor3 = Color3.fromRGB(30,30,30)
ProgressContainer.Parent = MainFrame

local ProgressBar = Instance.new("Frame")
ProgressBar.Size = UDim2.new(0,0,1,0)
ProgressBar.BackgroundColor3 = UI_COLOR_SCHEME.Secondary
ProgressBar.Parent = ProgressContainer

-- Créditos
local CreditsLabel = Instance.new("TextLabel")
CreditsLabel.Text = "Desenvolvido por: FXZGHS1"
CreditsLabel.Font = Enum.Font.GothamMedium
CreditsLabel.TextSize = 12
CreditsLabel.TextColor3 = Color3.fromRGB(150,150,150)
CreditsLabel.Size = UDim2.new(0.3,0,0.04,0)
CreditsLabel.Position = UDim2.new(0.7,0,0.96,0)
CreditsLabel.BackgroundTransparency = 1
CreditsLabel.TextXAlignment = Enum.TextXAlignment.Right
CreditsLabel.Visible = false
CreditsLabel.Parent = ScreenGui

-- Função para criar logs
local function createLog(message, logType)
    local logEntry = Instance.new("TextLabel")
    logEntry.Text = "  • " .. message
    logEntry.Font = Enum.Font.GothamMedium
    logEntry.TextSize = 14
    logEntry.TextXAlignment = Enum.TextXAlignment.Left
    logEntry.Size = UDim2.new(1,0,0,20)
    logEntry.BackgroundTransparency = 1
    logEntry.TextColor3 = UI_COLOR_SCHEME.Text

    if logType == "warn" then
        logEntry.TextColor3 = UI_COLOR_SCHEME.Warning
        logEntry.Text = "  ⚠ " .. message
    elseif logType == "error" then
        logEntry.TextColor3 = UI_COLOR_SCHEME.Error
        logEntry.Text = "  ✖ " .. message
    elseif logType == "success" then
        logEntry.TextColor3 = UI_COLOR_SCHEME.Secondary
        logEntry.Text = "  ✔ " .. message
    end

    logEntry.Parent = LogsContainer
    LogsContainer.CanvasSize = UDim2.new(0,0,0,LogsLayout.AbsoluteContentSize.Y)
    LogsContainer.CanvasPosition = Vector2.new(0, LogsContainer.CanvasSize.Y.Offset)
end

-- Monitoramento de FPS
local lastTick = tick()
local frameCount = 0
RunService.Heartbeat:Connect(function()
    frameCount = frameCount + 1
    local currentTime = tick()
    if currentTime - lastTick >= 1 then
        local fps = math.floor(frameCount / (currentTime - lastTick))
        FPSLabel.Text = "FPS: " .. fps
        frameCount = 0
        lastTick = currentTime
    end
end)

-- Execução dos Scripts
local function executeScripts()
    local scripts = {
        {Name = "Emotes Pack", Url = "https://pastebin.com/raw/eCpipCTH"},
        {Name = "Animated", Url = "https://raw.githubusercontent.com/Gazer-Ha/Animated/main/G"}
    }
    local finishedCount = 0  -- Conta scripts finalizados
    local totalScripts = #scripts

    for _, scriptData in pairs(scripts) do
        task.spawn(function()
            createLog("Iniciando: " .. scriptData.Name, "info")
            local success, result = pcall(function()
                return loadstring(game:HttpGet(scriptData.Url))()
            end)
            if success then
                createLog(scriptData.Name .. " carregado!", "success")
            else
                createLog("Erro em " .. scriptData.Name .. ": " .. result, "error")
            end
            finishedCount = finishedCount + 1
            TweenService:Create(ProgressBar, TweenInfo.new(0.5), {
                Size = UDim2.new(finishedCount/totalScripts, 0, 1, 0)
            }):Play()
        end)
    end

    while finishedCount < totalScripts do
        task.wait()
    end
end

-- Fluxo Principal
task.spawn(function()
    -- Animação de entrada
    MainFrame.Size = UDim2.new(0,0,0,0)
    TweenService:Create(MainFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0.35,0,0.4,0)
    }):Play()

    -- Atualização de Ping (simulado)
    task.spawn(function()
        while true do
            local ping = math.random(50,150)
            PingLabel.Text = "Ping: " .. ping .. "ms"
            task.wait(1)
        end
    end)

    -- Execução dos scripts
    local success, err = pcall(executeScripts)

    -- Animação de fechamento
    local closeTween = TweenService:Create(MainFrame, TweenInfo.new(1, Enum.EasingStyle.Quad), {
        Position = UDim2.new(0.5,0,1.5,0),
        BackgroundTransparency = 1
    })
    TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
    closeTween:Play()

    closeTween.Completed:Wait()
    CreditsLabel.Visible = true
    TweenService:Create(CreditsLabel, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    
    -- Remove a interface
    InputBlocker:Destroy()
    ScreenGui:Destroy()
    blur:Destroy()
end)
