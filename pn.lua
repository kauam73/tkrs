-- Módulo Feedback Collector independente
local FeedbackCollector = {
    Config = {
        enabled = true, -- Ativa/desativa o sistema
        lastSentTime = 0, -- Timestamp do último envio
        cooldown = 30, -- Cooldown em segundos
        inputText = "", -- Texto do usuário
        maxChars = 700, -- Máximo de caracteres
        popupDelay = 254, -- Delay para exibir a GUI (em segundos)
        guiVisible = false, -- Controla visibilidade da GUI
        feedbackSent = false, -- Impede múltiplos pop-ups
        pendingRequest = false, -- Indica requisição pendente
        queuedRequest = nil, -- Armazena requisição pendente
        notificationSpacing = 90, -- Espaço entre notificações empilhadas
        notificationQueue = {} -- Rastreia notificações ativas
    },
    HttpUrl = "https://spiny-cliff-leather.glitch.me/api/msg", -- URL da API
    RawScriptUrl = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/universal.lua", -- URL do script remoto
    Connections = {} -- Armazena conexões para cleanup
}

-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Função para codificar URLs
function FeedbackCollector:UrlEncode(str)
    str = tostring(str)
    local encoded = ""
    for i = 1, #str do
        local char = str:sub(i, i)
        if char:match("[A-Za-z0-9]") then
            encoded = encoded .. char
        else
            encoded = encoded .. string.format("%%%02X", string.byte(char))
        end
    end
    return encoded
end

-- Função para decodificar JSON
local function decodeJSON(str)
    if not str or str == "" then
        warn("FeedbackCollector: Corpo da resposta vazio ou inválido")
        return nil
    end
    local success, result = pcall(function()
        return HttpService:JSONDecode(str)
    end)
    if success then
        print("FeedbackCollector: JSON decodificado com sucesso: " .. HttpService:JSONEncode(result))
        return result
    else
        warn("FeedbackCollector: Falha ao decodificar JSON: " .. tostring(result))
        return nil
    end
end

-- Função para detectar método HTTP
function FeedbackCollector:GetHttpMethod()
    local executorFunctions = {
        "http_request", "request", "HttpPost", "HttpGet", "fetch",
        "syn.request", "fluxus.request", "krnl_request", "krnl.request", "http"
    }
    local sources = {
        getgenv and getgenv() or {},
        _G or {},
        syn or {},
        fluxus or {},
        krnl or {}
    }

    for _, name in ipairs(executorFunctions) do
        local parts = string.split(name, ".")
        for _, source in ipairs(sources) do
            local ref = source
            for _, part in ipairs(parts) do
                ref = ref and ref[part]
            end
            if type(ref) == "function" then
                print("FeedbackCollector: Método HTTP encontrado: " .. name)
                return function(url)
                    local success, result = pcall(function()
                        return ref({ Url = url, Method = "GET" })
                    end)
                    if success then return result end
                    warn("Falha ao chamar " .. name .. ": " .. tostring(result))
                    return nil
                end
            end
        end
    end

    if game.HttpGet then
        print("FeedbackCollector: Método HTTP encontrado: game:HttpGet")
        return function(url)
            local success, result = pcall(function()
                return { Body = game:HttpGet(url), Success = true, StatusCode = 200 }
            end)
            if success then return result end
            warn("Falha ao chamar game:HttpGet: " .. tostring(result))
            return nil
        end
    end

    warn("FeedbackCollector: Nenhum método HTTP disponível")
    return nil
end

-- Função para executar script remoto
function FeedbackCollector:ExecuteRawScript()
    if not game.HttpGet then
        warn("FeedbackCollector: game:HttpGet não disponível")
        self:Notify("Erro: Método HTTP não suportado pelo executor.", 5, "error")
        return
    end

    print("FeedbackCollector: Tentando obter script de " .. self.RawScriptUrl)
    local success, response = pcall(game.HttpGet, game, self.RawScriptUrl)
    if success and response then
        print("FeedbackCollector: Script raw obtido com sucesso. Tamanho: " .. #response .. " bytes")
        local loadSuccess, loadResult = pcall(function()
            local func = loadstring(response)
            if func then return func() end
            error("Erro ao compilar loadstring")
        end)
        if loadSuccess then
            print("FeedbackCollector: Script raw executado com sucesso")
        else
            warn("FeedbackCollector: Erro ao executar loadstring: " .. tostring(loadResult))
            self:Notify("Erro ao executar o script remoto.", 5, "error")
        end
    else
        warn("FeedbackCollector: Falha ao obter script raw: " .. tostring(response))
        self:Notify("Falha ao carregar o script remoto.", 5, "error")
    end
end

-- Função para atualizar posições das notificações empilhadas
function FeedbackCollector:UpdateNotificationPositions()
    local spacing = self.Config.notificationSpacing
    local baseY = -100 -- Posição base (em relação ao fundo da tela)
    
    for index, notification in ipairs(self.Config.notificationQueue) do
        local frame = notification.Frame
        local targetY = baseY - (index - 1) * spacing
        local tween = TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -370, 1, targetY)
        })
        tween:Play()
    end
end

-- Função para exibir notificações empilhadas
function FeedbackCollector:Notify(message, duration, status)
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5)

    if not PlayerGui then
        warn("FeedbackCollector: PlayerGui não encontrado")
        return
    end

    local notification = Instance.new("ScreenGui")
    notification.Name = "FeedbackNotification"
    notification.IgnoreGuiInset = true
    notification.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 80)
    frame.Position = UDim2.new(1, -20, 1, -100) -- Posição inicial (fora da tela)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.BorderSizePixel = 0
    frame.ZIndex = 10
    frame.Parent = notification

    -- Gradiente de fundo
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
    }
    gradient.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame

    -- Ícone de status
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 40, 0, 40)
    icon.Position = UDim2.new(0, 10, 0, 20)
    icon.BackgroundTransparency = 1
    icon.Text = status == "success" and "✓" or (status == "waiting" and "⟳" or "!")
    icon.TextColor3 = status == "success" and Color3.fromRGB(0, 255, 0) or (status == "waiting" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 100, 100))
    icon.TextSize = 24
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 11
    icon.Parent = frame

    -- Label de mensagem
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, -10)
    label.Position = UDim2.new(0, 60, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = message
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.SourceSansBold
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 11
    label.Parent = frame

    -- Sombra
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.7
    shadow.ZIndex = 9
    shadow.Parent = frame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 15)
    shadowCorner.Parent = shadow

    -- Adicionar à fila de notificações
    local notificationData = {
        Frame = frame,
        ScreenGui = notification
    }
    table.insert(self.Config.notificationQueue, notificationData)

    -- Atualizar posições
    self:UpdateNotificationPositions()

    -- Animação de entrada
    local tweenIn = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -370, 1, -100) })
    tweenIn:Play()

    -- Animação de saída e remoção
    task.spawn(function()
        task.wait(duration or 4)
        local tweenOut = TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, -20, frame.Position.Y, 0) })
        tweenOut:Play()
        tweenOut.Completed:Wait()

        -- Remover da fila e atualizar posições
        for i, queuedNotification in ipairs(self.Config.notificationQueue) do
            if queuedNotification == notificationData then
                table.remove(self.Config.notificationQueue, i)
                break
            end
        end
        self:UpdateNotificationPositions()

        -- Destruir notificação
        notification:Destroy()
    end)
end

-- Função para criar a GUI flutuante
function FeedbackCollector:CreateFeedbackGui()
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 10)

    if not PlayerGui then
        warn("FeedbackCollector: PlayerGui não encontrado após 10 segundos")
        self:Notify("Erro: Interface do jogador não encontrada.", 5, "error")
        self.Config.guiVisible = false
        return
    end

    if self.Config.guiVisible then
        warn("FeedbackCollector: GUI já visível, ignorando criação")
        return
    end

    print("FeedbackCollector: Criando GUI de feedback")
    self.Config.guiVisible = true

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FeedbackGui"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = PlayerGui

    local backdrop = Instance.new("Frame")
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 1
    backdrop.ZIndex = 9
    backdrop.Parent = screenGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -225, 1.5, 0)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ZIndex = 10
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 14)
    corner.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = "Nos ajude a melhorar!"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 11
    title.Parent = mainFrame

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -20, 0, 60)
    desc.Position = UDim2.new(0, 10, 0, 50)
    desc.BackgroundTransparency = 1
    desc.Text = "Sua opinião é importante! Envie feedback, sugestões ou relatos de problemas (máx. 700 caracteres)."
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.TextSize = 14
    desc.Font = Enum.Font.SourceSans
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 11
    desc.Parent = mainFrame

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(1, -20, 0, 120)
    inputFrame.Position = UDim2.new(0, 10, 0, 120)
    inputFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    inputFrame.BackgroundTransparency = 0.2
    inputFrame.BorderSizePixel = 0
    inputFrame.ZIndex = 10
    inputFrame.Parent = mainFrame

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -10, 1, -10)
    textBox.Position = UDim2.new(0, 5, 0, 5)
    textBox.BackgroundTransparency = 1
    textBox.Text = self.Config.inputText
    textBox.PlaceholderText = "Digite seu feedback aqui..."
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 14
    textBox.Font = Enum.Font.SourceSans
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.TextYAlignment = Enum.TextYAlignment.Top
    textBox.TextWrapped = true
    textBox.MultiLine = true
    textBox.ClearTextOnFocus = false
    textBox.ZIndex = 11
    textBox.Parent = inputFrame

    local charCounter = Instance.new("TextLabel")
    charCounter.Size = UDim2.new(0, 100, 0, 20)
    charCounter.Position = UDim2.new(1, -110, 1, -25)
    charCounter.BackgroundTransparency = 1
    charCounter.Text = "0/" .. self.Config.maxChars
    charCounter.TextColor3 = Color3.fromRGB(150, 150, 150)
    charCounter.TextSize = 12
    charCounter.Font = Enum.Font.SourceSans
    charCounter.ZIndex = 11
    charCounter.Parent = inputFrame

    textBox:GetPropertyChangedSignal("Text"):Connect(function()
        local text = textBox.Text
        self.Config.inputText = text
        charCounter.Text = #text .. "/" .. self.Config.maxChars
        if #text > self.Config.maxChars then
            charCounter.TextColor3 = Color3.fromRGB(255, 100, 100)
        else
            charCounter.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end)

    local sendButton = Instance.new("TextButton")
    sendButton.Size = UDim2.new(0, 120, 0, 40)
    sendButton.Position = UDim2.new(1, -130, 1, -50)
    sendButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    sendButton.Text = "Enviar"
    sendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendButton.TextSize = 16
    sendButton.Font = Enum.Font.SourceSansBold
    sendButton.ZIndex = 11
    sendButton.Parent = mainFrame

    local sendButtonCorner = Instance.new("UICorner")
    sendButtonCorner.CornerRadius = UDim.new(0, 10)
    sendButtonCorner.Parent = sendButton

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 40, 0, 40)
    closeButton.Position = UDim2.new(0, 10, 1, -50)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 16
    closeButton.Font = Enum.Font.SourceSansBold
    closeButton.ZIndex = 11
    closeButton.Parent = mainFrame

    local closeButtonCorner = Instance.new("UICorner")
    closeButtonCorner.CornerRadius = UDim.new(0, 10)
    closeButtonCorner.Parent = closeButton

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local mainTween = TweenService:Create(mainFrame, tweenInfo, { Position = UDim2.new(0.5, -225, 0.5, -175) })
    local backdropTween = TweenService:Create(backdrop, tweenInfo, { BackgroundTransparency = 0.4 })
    mainTween:Play()
    backdropTween:Play()

    local function lockPlayer(lock)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if lock then
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
            else
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
            end
        end
    end
    lockPlayer(true)

    local function closeGui()
        self.Config.guiVisible = false
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local mainTween = TweenService:Create(mainFrame, tweenInfo, { Position = UDim2.new(0.5, -225, 1.5, 0) })
        local backdropTween = TweenService:Create(backdrop, tweenInfo, { BackgroundTransparency = 1 })
        mainTween:Play()
        backdropTween:Play()
        task.wait(0.3)
        screenGui:Destroy()
        lockPlayer(false)
        print("FeedbackCollector: GUI fechada com sucesso")
    end

    sendButton.MouseButton1Click:Connect(function()
        self:SendFeedback(closeGui)
    end)

    closeButton.MouseButton1Click:Connect(closeGui)

    return screenGui
end

-- Função para enviar o feedback
function FeedbackCollector:SendFeedback(closeCallback)
    local currentTime = tick()
    local timeSinceLastSent = currentTime - self.Config.lastSentTime
    if timeSinceLastSent < self.Config.cooldown then
        self:Notify("Aguarde " .. math.ceil(self.Config.cooldown - timeSinceLastSent) .. " segundos.", 3, "error")
        return
    end

    local msg = self.Config.inputText or ""
    if #msg == 0 then
        self:Notify("Digite uma mensagem antes de enviar.", 3, "error")
        return
    end
    if #msg > self.Config.maxChars then
        self:Notify("A mensagem deve ter até 700 caracteres.", 3, "error")
        return
    end

    local player = Players.LocalPlayer
    if not player then
        self:Notify("Jogador não encontrado.", 3, "error")
        return
    end
    local name = player.Name or "Unknown"
    local id = tostring(player.UserId or 0)

    local url = self.HttpUrl .. "?name=" .. self:UrlEncode(name) .. "&id=" .. self:UrlEncode(id) .. "&msg=" .. self:UrlEncode(msg)
    print("FeedbackCollector: Enviando feedback para URL: " .. url)

    local httpMethod = self:GetHttpMethod()
    if not httpMethod then
        self:Notify("Método HTTP não compatível.", 5, "error")
        return
    end

    self.Config.pendingRequest = true
    self:Notify("Aguardando resposta da API...", 5, "waiting")
    if closeCallback then closeCallback() end

    local success, response = pcall(httpMethod, url)
    if success and response then
        local statusCode = response.StatusCode or (response.Success and 200 or 400)
        local body = response.Body or ""
        local jsonResponse = decodeJSON(body)

        if (statusCode == 200 or statusCode == 201) and (jsonResponse and (jsonResponse.status == "Mensagem salva com sucesso." or jsonResponse.status == nil)) then
            print("FeedbackCollector: Feedback enviado com sucesso (StatusCode: " .. statusCode .. ")")
            self.Config.lastSentTime = tick()
            self.Config.inputText = ""
            self.Config.feedbackSent = true
            self.Config.pendingRequest = false
            self.Config.queuedRequest = nil
            self:Notify("Feedback enviado com sucesso!", 5, "success")
            
            -- Aguardar até que todas as notificações sejam exibidas
            task.spawn(function()
                while #self.Config.notificationQueue > 0 do
                    task.wait(0.1) -- Verifica a cada 0.1 segundos
                end
                print("FeedbackCollector: Todas as notificações foram exibidas, encerrando sistema")
                self:Shutdown()
            end)
        else
            local errorMsg = jsonResponse and jsonResponse.error or (response.StatusMessage or "Erro desconhecido (StatusCode: " .. tostring(statusCode) .. ")")
            warn("FeedbackCollector: Erro ao enviar feedback: " .. errorMsg)
            self.Config.pendingRequest = false
            self.Config.queuedRequest = nil
            self:Notify("Erro ao enviar: " .. errorMsg, 5, "error")
        end
    else
        self.Config.queuedRequest = { url = url, callback = closeCallback }
        self.Config.pendingRequest = false
        self:Notify("Falha na conexão. Tentando novamente em breve...", 5, "error")
        task.delay(5, function()
            if self.Config.queuedRequest then
                print("FeedbackCollector: Reenviando requisição pendente")
                self:SendFeedback(self.Config.queuedRequest.callback)
                self.Config.queuedRequest = nil
            end
        end)
    end
end

-- Função para encerrar todos os processos e desativar o sistema
function FeedbackCollector:Shutdown()
    print("FeedbackCollector: Encerrando processos e desativando o sistema")
    self.Config.enabled = false -- Desativa o sistema
    self.Config.guiVisible = false -- Impede que a GUI reapareça
    self.Config.feedbackSent = true -- Marca como enviado

    -- Desconectar todos os eventos
    for _, connection in pairs(self.Connections) do
        if connection then
            connection:Disconnect()
            print("FeedbackCollector: Conexão desconectada")
        end
    end
    self.Connections = {}

    -- Limpar notificações ativas
    for _, notification in ipairs(self.Config.notificationQueue) do
        if notification.ScreenGui then
            notification.ScreenGui:Destroy()
        end
    end
    self.Config.notificationQueue = {}
    print("FeedbackCollector: Sistema encerrado com sucesso")
end

-- Função para gerenciar temporizador e respawn
function FeedbackCollector:ManageTimer()
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        warn("FeedbackCollector: LocalPlayer não encontrado, aguardando...")
        local playerAddedConn
        playerAddedConn = Players.PlayerAdded:Connect(function(player)
            if player == Players.LocalPlayer then
                playerAddedConn:Disconnect()
                self:ManageTimer()
            end
        end)
        table.insert(self.Connections, playerAddedConn)
        return
    end

    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
    if not PlayerGui then
        warn("FeedbackCollector: PlayerGui não encontrado, cancelando temporizador")
        return
    end

    print("FeedbackCollector: Iniciando temporizador para GUI")

    local elapsedTime = 0
    local isAlive = true

    local function resetTimer()
        elapsedTime = 0
        print("FeedbackCollector: Temporizador reiniciado")
    end

    local characterAddedConn = LocalPlayer.CharacterAdded:Connect(function(character)
        isAlive = true
        print("FeedbackCollector: Personagem adicionado, isAlive = true")
        if self.Config.guiVisible and not self.Config.feedbackSent then
            self:CreateFeedbackGui()
        end
    end)
    table.insert(self.Connections, characterAddedConn)

    local characterRemovingConn = LocalPlayer.CharacterRemoving:Connect(function()
        isAlive = false
        resetTimer()
        print("FeedbackCollector: Personagem removido, isAlive = false")
    end)
    table.insert(self.Connections, characterRemovingConn)

    local heartbeatConn = RunService.Heartbeat:Connect(function(deltaTime)
        if not self.Config.enabled or self.Config.feedbackSent then
            print("FeedbackCollector: Temporizador desativado (enabled ou feedbackSent)")
            return
        end

        if not isAlive or self.Config.guiVisible then
            return
        end

        elapsedTime = elapsedTime + deltaTime
        if elapsedTime >= self.Config.popupDelay then
            print("FeedbackCollector: Temporizador atingiu " .. self.Config.popupDelay .. "s, criando GUI")
            self:CreateFeedbackGui()
            resetTimer()
        end
    end)
    table.insert(self.Connections, heartbeatConn)

    local ancestryChangedConn = LocalPlayer.AncestryChanged:Connect(function()
        print("FeedbackCollector: AncestryChanged detectado, encerrando temporizador")
        self:Shutdown()
    end)
    table.insert(self.Connections, ancestryChangedConn)
end

-- Função inicial
function FeedbackCollector:Start()
    self:ExecuteRawScript()
    self:ManageTimer()
end

-- Iniciar o módulo
FeedbackCollector:Start()