local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Criação do efeito de desfoque para o fundo
local blur = Instance.new("BlurEffect")
blur.Size = 24  -- Tamanho inicial do desfoque
blur.Parent = Lighting

-- Criação da ScreenGui e elementos principais
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.4, 0, 0.4, 0)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Gradiente de fundo
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 128, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 128))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

-- Cantos arredondados
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0.1, 0)
UICorner.Parent = MainFrame

-- Cabeçalho
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0.2, 0)
Header.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0.1, 0)
HeaderCorner.Parent = Header

-- Título
local Title = Instance.new("TextLabel")
Title.Text = "TekScripts Pack Emote"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Frame de logs
local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1, -20, 0.6, 0)
LogFrame.Position = UDim2.new(0, 10, 0.25, 0)
LogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 6
LogFrame.Parent = MainFrame

local LogCorner = Instance.new("UICorner")
LogCorner.CornerRadius = UDim.new(0.1, 0)
LogCorner.Parent = LogFrame

-- Texto de log
local LogText = Instance.new("TextLabel")
LogText.Text = "Inicializando..."
LogText.Font = Enum.Font.Gotham
LogText.TextSize = 18
LogText.TextColor3 = Color3.fromRGB(200, 200, 200)
LogText.Size = UDim2.new(1, -10, 1, 0)
LogText.Position = UDim2.new(0, 5, 0, 0)
LogText.TextWrapped = true
LogText.TextYAlignment = Enum.TextYAlignment.Top
LogText.BackgroundTransparency = 1
LogText.Parent = LogFrame

-- Barra de carregamento
local LoadingBar = Instance.new("Frame")
LoadingBar.Size = UDim2.new(1, -20, 0.05, 0)
LoadingBar.Position = UDim2.new(0, 10, 0.87, 0)
LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 128, 255)
LoadingBar.BorderSizePixel = 0
LoadingBar.Parent = MainFrame

local LoadingCorner = Instance.new("UICorner")
LoadingCorner.CornerRadius = UDim.new(0.1, 0)
LoadingCorner.Parent = LoadingBar

-- Progresso da barra de carregamento
local LoadingProgress = Instance.new("Frame")
LoadingProgress.Size = UDim2.new(0, 0, 1, 0)
LoadingProgress.BackgroundColor3 = Color3.fromRGB(0, 255, 128)
LoadingProgress.BorderSizePixel = 0
LoadingProgress.Parent = LoadingBar

local ProgressCorner = Instance.new("UICorner")
ProgressCorner.CornerRadius = UDim.new(0.1, 0)
ProgressCorner.Parent = LoadingProgress

-- Funções auxiliares
local function updateLog(message)
    LogText.Text = LogText.Text .. "\n" .. message
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogText.TextBounds.Y)
end

local function isSecureEnvironment()
    local isSafe = pcall(function()
        return game.PlaceId
    end)
    return isSafe
end

local function simulateLoading()
    for i = 1, 100 do
        LoadingProgress:TweenSize(
            UDim2.new(i / 100, 0, 1, 0),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.02,  -- Tempo reduzido para carregamento mais rápido
            true
        )
        task.wait(0.02)
    end
end

local scriptsExecuted = false

local function checkCharacterModel()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Torso") then
        updateLog("Estrutura do personagem pode não ser compatível. Altere para R16 para evitar problemas.")
    end
end

local function executeScripts()
    updateLog("Executando: Emotes Pack")
    local success, errorMessage = pcall(function()
        loadstring(game:HttpGet("https://pastebin.com/raw/eCpipCTH"))()
    end)
    if success then
        updateLog("Emotes Pack executado com sucesso!")
    else
        updateLog("Erro ao executar Emotes Pack: " .. errorMessage)
    end

    updateLog("Executando: Animated")
    local success2, errorMessage2 = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Gazer-Ha/Animated/main/G"))()
    end)
    if success2 then
        updateLog("Animated executado com sucesso!")
    else
        updateLog("Erro ao executar Animated: " .. errorMessage2)
    end
end

-- Execução inicial do script
task.spawn(function()
    if scriptsExecuted then
        updateLog("Tek detectou que já tem scripts iniciados.")
        return
    end

    scriptsExecuted = true

    if not isSecureEnvironment() then
        updateLog("Ambiente inseguro! Execução interrompida.")
        return
    end

    checkCharacterModel()

    updateLog("Iniciando...")
    simulateLoading()

    -- Executando os scripts
    executeScripts()

    task.wait(1)

    -- Transição de remoção da interface e do efeito de desfoque
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local mainFrameTween = TweenService:Create(MainFrame, tweenInfo, {Position = UDim2.new(0.3, 0, -0.5, 0)})
    mainFrameTween:Play()

    -- Tween para reduzir o blur simultaneamente
    local blurTween = TweenService:Create(blur, tweenInfo, {Size = 0})
    blurTween:Play()
    blurTween.Completed:Connect(function()
        blur:Destroy()
    end)

    mainFrameTween.Completed:Connect(function()
        MainFrame:Destroy()

        -- Exibição do texto final
        local RGBText = Instance.new("TextLabel")
        RGBText.Text = "Tek Scripts v1"
        RGBText.Font = Enum.Font.GothamBold
        RGBText.TextSize = 18
        RGBText.Size = UDim2.new(0.3, 0, 0.05, 0)
        RGBText.Position = UDim2.new(0.7, 0, 0.95, 0)
        RGBText.BackgroundTransparency = 1
        RGBText.Parent = ScreenGui

        -- Animação de cor RGB
        task.spawn(function()
            while true do
                for i = 0, 1, 0.01 do
                    RGBText.TextColor3 = Color3.fromHSV(i, 1, 1)
                    task.wait(0.05)
                end
            end
        end)
    end)
end)