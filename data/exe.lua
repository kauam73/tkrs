local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Verificar se o script já está em execução
if _G.TekScriptsExecuting then
    warn("TekScripts já está em execução!")
    return
end
_G.TekScriptsExecuting = true

-- Criação do efeito de desfoque para o fundo
local blur = Instance.new("BlurEffect")
blur.Size = 24
blur.Parent = Lighting

-- Criação da ScreenGui e elementos principais
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Position = UDim2.new(0.35, 0, 0.35, 0)
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
Title.Text = "TekScripts Loader"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Size = UDim2.new(0.8, -20, 1, 0)
Title.Position = UDim2.new(0.15, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Ícone no cabeçalho
local Icon = Instance.new("ImageLabel")
Icon.Image = "rbxassetid://1234567890" -- Substitua pelo ID de uma imagem real
Icon.Size = UDim2.new(0.1, 0, 0.8, 0)
Icon.Position = UDim2.new(0.02, 0, 0.1, 0)
Icon.BackgroundTransparency = 1
Icon.Parent = Header

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

-- Container de logs com UIListLayout
local LogContainer = Instance.new("Frame")
LogContainer.Size = UDim2.new(1, 0, 1, 0)
LogContainer.BackgroundTransparency = 1
LogContainer.Parent = LogFrame

local LogListLayout = Instance.new("UIListLayout")
LogListLayout.Padding = UDim.new(0, 5)
LogListLayout.Parent = LogContainer

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
    local logEntry = Instance.new("TextLabel")
    logEntry.Text = message
    logEntry.Font = Enum.Font.Gotham
    logEntry.TextSize = 18
    logEntry.TextColor3 = Color3.fromRGB(200, 200, 200)
    logEntry.Size = UDim2.new(1, -10, 0, 20)
    logEntry.BackgroundTransparency = 1
    logEntry.TextXAlignment = Enum.TextXAlignment.Left
    logEntry.Parent = LogContainer
    LogFrame.CanvasSize = UDim2.new(0, 0, 0, LogListLayout.AbsoluteContentSize.Y)
end

local function isSecureEnvironment()
    return game:GetService("RunService"):IsClient()
end

local function waitForCharacter(timeout)
    timeout = timeout or 10
    local startTime = tick()
    while not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
        if tick() - startTime >= timeout then
            return false
        end
        LocalPlayer.CharacterAdded:Wait()
    end
    return true
end

local function checkAndFixCharacterModel()
    -- Aguardar o personagem carregar
    if not waitForCharacter(10) then
        updateLog("Personagem não carregado após 10 segundos. Tentando recarregar...")
        pcall(function()
            LocalPlayer:LoadCharacter() -- Tentar recarregar o personagem
        end)
        if not waitForCharacter(5) then
            updateLog("Falha ao carregar o personagem. Verifique sua conexão ou o jogo.")
            return false
        end
    end

    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        -- Verificar se é R6
        if humanoid.RigType == Enum.HumanoidRigType.R6 then
            updateLog("Detectado personagem R6. Recomenda-se usar R15 para compatibilidade.")
            -- Tentar mudar para R15 (depende do suporte do jogo)
            pcall(function()
                humanoid:ChangeState(Enum.HumanoidStateType.Dead) -- Forçar respawn
                LocalPlayer:LoadCharacter() -- Recarregar como R15 (se o jogo suportar)
            end)
            if waitForCharacter(5) and LocalPlayer.Character:FindFirstChild("Humanoid").RigType == Enum.HumanoidRigType.R15 then
                updateLog("Personagem alterado para R15 com sucesso!")
            else
                updateLog("Não foi possível alterar para R15. Continuando com R6, mas podem ocorrer problemas.")
                return true -- Permitir continuação com R6, mas com aviso
            end
        else
            updateLog("Personagem R15 detectado. Estrutura compatível.")
        end
        return true
    end
    updateLog("Humanoid não encontrado. Estrutura incompatível.")
    return false
end

local function updateLoadingProgress(progress)
    LoadingProgress:TweenSize(
        UDim2.new(progress, 0, 1, 0),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.5,
        true
    )
    task.wait(0.5)
end

-- Função para tentar executar um script com retries
local function retryRequest(url, scriptName, maxRetries, retryDelay)
    maxRetries = maxRetries or 3
    retryDelay = retryDelay or 2
    local attempt = 1

    while attempt <= maxRetries do
        updateLog(string.format("Tentativa %d/%d: Carregando %s...", attempt, maxRetries, scriptName))
        local success, result = pcall(function()
            local response = game:HttpGet(url)
            local func = loadstring(response)
            if func then
                func()
            else
                error("Falha ao compilar o script")
            end
        end)

        if success then
            updateLog(string.format("%s executado com sucesso!", scriptName))
            return true
        else
            updateLog(string.format("Erro ao executar %s: %s", scriptName, tostring(result)))
            if attempt < maxRetries then
                updateLog(string.format("Aguardando %d segundos antes da próxima tentativa...", retryDelay))
                task.wait(retryDelay)
            end
            attempt = attempt + 1
        end
    end

    updateLog(string.format("Falha ao executar %s após %d tentativas.", scriptName, maxRetries))
    return false
end

local scriptsExecuted = false
local hasError = false

local function executeScripts()
    local scripts = {
        {
            name = "painel de emotes",
            url = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/emotions.lua"
        },
        {
            name = "painel animações",
            url = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/animations.lua"
        }
    }

    for _, script in ipairs(scripts) do
        updateLog(string.format("Executando: %s", script.name))
        local success = retryRequest(script.url, script.name, 3, 2)
        if not success then
            hasError = true
        end
    end
end

-- Execução inicial do script
task.spawn(function()
    if scriptsExecuted then
        updateLog("Tek detectou que já tem scripts iniciados.")
        return
    end

    scriptsExecuted = true

    updateLog("Inicializando...")
    updateLoadingProgress(0.2)

    if not isSecureEnvironment() then
        updateLog("Ambiente inseguro! Execução interrompida.")
        hasError = true
        return
    end

    updateLoadingProgress(0.4)

    if not checkAndFixCharacterModel() then
        hasError = true
    end

    updateLoadingProgress(0.6)

    executeScripts()

    updateLoadingProgress(1)

    task.wait(1)

    if not hasError then
        -- Transição de remoção da interface e do efeito de desfoque
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local mainFrameTween = TweenService:Create(MainFrame, tweenInfo, {Position = UDim2.new(0.35, 0, -0.5, 0)})
        mainFrameTween:Play()

        local blurTween = TweenService:Create(blur, tweenInfo, {Size = 0})
        blurTween:Play()
        blurTween.Completed:Connect(function()
            blur:Destroy()
        end)

        mainFrameTween.Completed:Connect(function()
            MainFrame:Destroy()

            local RGBText = Instance.new("TextLabel")
            RGBText.Text = "Tek Scripts v1"
            RGBText.Font = Enum.Font.GothamBold
            RGBText.TextSize = 18
            RGBText.Size = UDim2.new(0.3, 0, 0.05, 0)
            RGBText.Position = UDim2.new(0.7, 0, 0.95, 0)
            RGBText.BackgroundTransparency = 1
            RGBText.Parent = ScreenGui

            task.spawn(function()
                while true do
                    for i = 0, 1, 0.01 do
                        RGBText.TextColor3 = Color3.fromHSV(i, 1, 1)
                        task.wait(0.05)
                    end
                end
            end)
        end)
    else
        updateLog("Ocorreu um erro durante a execução. Verifique os logs acima.")
    end

    -- Limpar variável global ao finalizar
    _G.TekScriptsExecuting = nil
end)