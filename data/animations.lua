--[[
    Painel de Animações para Roblox
    Versão: 2.0
    
    Descrição: Sistema de gerenciamento e aplicação de animações personalizadas
    com interface gráfica responsiva e otimizada.
]]

-- Módulo de Configuração
local Config = {
    ARQUIVO_ANIMACOES_SALVAS = "emotes.json",
    ARQUIVO_POSICAO_PAINEL = "panel_position.json",
    URL_JSON_ANIMACOES = "https://raw.githubusercontent.com/kauam73/tkrs/refs/heads/main/data/Animations.json",
    TAMANHO_PAINEL = {
        LARGURA = 350,
        ALTURA = 500,
        ALTURA_MINIMIZADO = 40
    },
    CORES = {
        FUNDO_PRINCIPAL = Color3.fromRGB(30, 30, 30),
        FUNDO_SECUNDARIO = Color3.fromRGB(20, 20, 20),
        FUNDO_ELEMENTO = Color3.fromRGB(50, 50, 50),
        FUNDO_ELEMENTO_HOVER = Color3.fromRGB(70, 70, 70),
        TEXTO = Color3.new(1, 1, 1),
        TEXTO_SECUNDARIO = Color3.fromRGB(230, 230, 230),
        BORDA = Color3.fromRGB(60, 60, 60),
        SUCESSO = Color3.new(0, 1, 0),
        ERRO = Color3.new(1, 0, 0),
        DESTAQUE = Color3.fromRGB(0, 170, 255)
    },
    ANIMACAO_TIPOS = {
        ["Climb"] = "climb", 
        ["Fall"] = "fall", 
        ["Idle"] = "idle",
        ["Jump"] = "jump", 
        ["Run"] = "run", 
        ["Swim"] = "swim", 
        ["Walk"] = "walk"
    }
}

-- Módulo de Utilitários
local Utils = {}

-- Detecta recursos do executor e fornece fallbacks quando necessário
function Utils.detectarRecursos()
    local recursos = {
        httpRequest = (typeof(request) == "function" and request) or
                     (typeof(http_request) == "function" and http_request) or
                     (syn and syn.request) or 
                     (fluxus and fluxus.request) or
                     (trigon and trigon.request) or 
                     (codex and codex.request),
                     
        writeFile = writefile or 
                   (fluxus and fluxus.writefile) or 
                   (trigon and trigon.writefile) or 
                   (codex and codex.writefile),
                   
        readFile = readfile or 
                  (fluxus and fluxus.readfile) or 
                  (trigon and trigon.readfile) or 
                  (codex and codex.readfile),
                  
        isFile = isfile or 
                (fluxus and fluxus.isfile) or 
                (trigon and trigon.isfile) or 
                (codex and codex.isfile) or 
                function() return false end
    }
    
    -- Verificação de recursos essenciais
    if not recursos.httpRequest then
        error("Erro: Seu executor não suporta requisições HTTP.")
    end
    
    if not recursos.writeFile or not recursos.readFile then
        warn("Aviso: Seu executor não suporta operações de arquivo. Algumas funcionalidades serão limitadas.")
    end
    
    return recursos
end

-- Função para criar elementos de UI com propriedades padrão
function Utils.criarElementoUI(tipo, pai, props)
    local elemento = Instance.new(tipo, pai)
    
    if props then
        for prop, valor in pairs(props) do
            elemento[prop] = valor
        end
    end
    
    return elemento
end

-- Função para criar cantos arredondados em elementos UI
function Utils.adicionarCantos(elemento, raio)
    local uiCorner = Utils.criarElementoUI("UICorner", elemento, {
        CornerRadius = UDim.new(0, raio or 5)
    })
    return uiCorner
end

-- Função para criar animação de hover em botões
function Utils.adicionarEfeitoHover(botao, corNormal, corHover)
    botao.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(
            botao, 
            TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
            {BackgroundColor3 = corHover}
        ):Play()
    end)
    
    botao.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(
            botao, 
            TweenInfo.new(0.2, Enum.EasingStyle.Quad), 
            {BackgroundColor3 = corNormal}
        ):Play()
    end)
end

-- Módulo de Gerenciamento de Dados
local DataManager = {}

function DataManager.new(recursos)
    local self = {}
    self.recursos = recursos
    self.animacoes = {}
    self.animacoesPersonalizadas = {
        climb = nil, fall = nil, idle = nil, jump = nil,
        run = nil, swim = nil, walk = nil
    }
    
    -- Carrega animações do servidor
    function self:carregarAnimacoes()
        local sucesso, erro = pcall(function()
            local resposta = self.recursos.httpRequest({
                Url = Config.URL_JSON_ANIMACOES,
                Method = "GET"
            })
            
            if resposta.StatusCode ~= 200 then
                error("Erro ao carregar animações: StatusCode " .. resposta.StatusCode)
            end
            
            self.animacoes = game:GetService("HttpService"):JSONDecode(resposta.Body)
        end)
        
        if not sucesso then
            warn("Falha ao carregar animações: " .. (erro or "Erro desconhecido"))
            self.animacoes = {}
            return false
        end
        
        return true
    end
    
    -- Salva animações personalizadas no arquivo local
    function self:salvarAnimacoesPersonalizadas()
        if not self.recursos.writeFile then return false end
        
        local sucesso, erro = pcall(function()
            self.recursos.writeFile(
                Config.ARQUIVO_ANIMACOES_SALVAS, 
                game:GetService("HttpService"):JSONEncode(self.animacoesPersonalizadas)
            )
        end)
        
        if not sucesso then
            warn("Falha ao salvar animações: " .. (erro or "Erro desconhecido"))
            return false
        end
        
        return true
    end
    
    -- Carrega animações personalizadas do arquivo local
    function self:carregarAnimacoesSalvas()
        if not self.recursos.isFile or not self.recursos.readFile then return false end
        
        if self.recursos.isFile(Config.ARQUIVO_ANIMACOES_SALVAS) then
            local sucesso, erro = pcall(function()
                local dados = self.recursos.readFile(Config.ARQUIVO_ANIMACOES_SALVAS)
                self.animacoesPersonalizadas = game:GetService("HttpService"):JSONDecode(dados)
            end)
            
            if not sucesso then
                warn("Falha ao carregar animações salvas: " .. (erro or "Erro desconhecido"))
                return false
            end
            
            return true
        end
        
        return false
    end
    
    -- Salva a posição do painel no arquivo local
    function self:salvarPosicaoPainel(posicao)
        if not self.recursos.writeFile then return false end
        
        local sucesso, erro = pcall(function()
            self.recursos.writeFile(
                Config.ARQUIVO_POSICAO_PAINEL, 
                game:GetService("HttpService"):JSONEncode({
                    x = posicao.X.Offset, 
                    y = posicao.Y.Offset
                })
            )
        end)
        
        if not sucesso then
            warn("Falha ao salvar posição do painel: " .. (erro or "Erro desconhecido"))
            return false
        end
        
        return true
    end
    
    -- Obtém a posição inicial do painel
    function self:obterPosicaoInicial()
        if self.recursos.isFile and self.recursos.readFile and self.recursos.isFile(Config.ARQUIVO_POSICAO_PAINEL) then
            local sucesso, posicao = pcall(function()
                local dados = self.recursos.readFile(Config.ARQUIVO_POSICAO_PAINEL)
                local pos = game:GetService("HttpService"):JSONDecode(dados)
                return UDim2.new(0, pos.x, 0, pos.y)
            end)
            
            if sucesso then
                return posicao
            end
        end
        
        -- Posição padrão centralizada
        local tamanhoTela = workspace.CurrentCamera.ViewportSize
        local posX = (tamanhoTela.X - Config.TAMANHO_PAINEL.LARGURA) / 2
        local posY = (tamanhoTela.Y - Config.TAMANHO_PAINEL.ALTURA) / 2
        return UDim2.new(0, posX, 0, posY)
    end
    
    return self
end

-- Módulo de Gerenciamento de Animações
local AnimationManager = {}

function AnimationManager.new(dataManager)
    local self = {}
    self.dataManager = dataManager
    
    -- Espera pela estrutura de animação do personagem
    function self:esperarEstrutura(personagem)
        local animate = personagem:WaitForChild("Animate", 10)
        if not animate then 
            warn("Estrutura de animação não encontrada no personagem")
            return nil 
        end
        
        -- Verifica se a estrutura esperada existe
        local estruturaEsperada = {
            { "walk", "WalkAnim" }, 
            { "idle", "Animation1" }, 
            { "idle", "Animation2" },
            { "jump", "JumpAnim" }, 
            { "fall", "FallAnim" }, 
            { "run", "RunAnim" },
            { "swim", "Swim" }, 
            { "climb", "ClimbAnim" }
        }
        
        local estruturaCompleta = true
        for _, caminho in ipairs(estruturaEsperada) do
            local pasta = animate:FindFirstChild(caminho[1])
            if not pasta or not pasta:FindFirstChild(caminho[2]) then
                estruturaCompleta = false
                break
            end
        end
        
        if not estruturaCompleta then
            warn("Estrutura de animação incompleta no personagem")
        end
        
        return animate
    end
    
    -- Aplica animações personalizadas ao personagem
    function self:aplicarAnimacoes(personagem)
        local animate = self:esperarEstrutura(personagem)
        if not animate then return false end
        
        local function definirAnimacao(nomePasta, nomeAnim, id)
            if not id then return end
            
            local pasta = animate:FindFirstChild(nomePasta)
            if not pasta then return end
            
            local anim = pasta:FindFirstChild(nomeAnim)
            if anim and anim:IsA("Animation") then
                anim.AnimationId = "rbxassetid://" .. id
            end
        end
        
        -- Aplica cada tipo de animação
        definirAnimacao("walk", "WalkAnim", self.dataManager.animacoesPersonalizadas.walk)
        definirAnimacao("idle", "Animation1", self.dataManager.animacoesPersonalizadas.idle)
        definirAnimacao("idle", "Animation2", self.dataManager.animacoesPersonalizadas.idle)
        definirAnimacao("jump", "JumpAnim", self.dataManager.animacoesPersonalizadas.jump)
        definirAnimacao("fall", "FallAnim", self.dataManager.animacoesPersonalizadas.fall)
        definirAnimacao("run", "RunAnim", self.dataManager.animacoesPersonalizadas.run)
        definirAnimacao("swim", "Swim", self.dataManager.animacoesPersonalizadas.swim)
        definirAnimacao("climb", "ClimbAnim", self.dataManager.animacoesPersonalizadas.climb)
        
        return true
    end
    
    -- Recarrega animações do personagem
    function self:recarregarAnimacoes(personagem)
        local humanoid = personagem:FindFirstChildOfClass("Humanoid")
        local animate = self:esperarEstrutura(personagem)
        
        if not (humanoid and animate) then 
            warn("Humanoid ou estrutura de animação não encontrada")
            return false 
        end
        
        -- Para todas as animações em reprodução
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        
        -- Reaplica as animações personalizadas
        self:aplicarAnimacoes(personagem)
        
        -- Força a reinicialização do script Animate
        local animateScript = personagem:FindFirstChild("Animate")
        if animateScript then
            animateScript.Disabled = true
            task.wait(0.1) -- Pequena espera para garantir que o script seja desativado
            animateScript.Disabled = false
        end
        
        -- Reaplica o estado atual do humanoid
        local estado = humanoid:GetState()
        if estado == Enum.HumanoidStateType.Running then
            humanoid.WalkSpeed = humanoid.WalkSpeed -- Reaplica a velocidade atual
        elseif estado == Enum.HumanoidStateType.Jumping then
            humanoid.Jump = true
        end
        
        return true
    end
    
    -- Conecta eventos ao personagem
    function self:conectarPersonagem(personagem)
        local humanoid = personagem:WaitForChild("Humanoid", 10)
        if not humanoid then 
            warn("Humanoid não encontrado no personagem")
            return false 
        end
        
        local animate = self:esperarEstrutura(personagem)
        if not animate then return false end
        
        -- Espera para garantir que o personagem esteja completamente carregado
        task.wait(0.5)
        
        -- Aplica animações e recarrega
        self:aplicarAnimacoes(personagem)
        task.wait(0.1)
        self:recarregarAnimacoes(personagem)
        
        return true
    end
    
    -- Aplica uma animação específica
    function self:aplicarAnimacao(idAnimacao, labelFeedback)
        for _, anim in pairs(self.dataManager.animacoes) do
            if anim.idAnimacao == idAnimacao then
                local tipo = Config.ANIMACAO_TIPOS[anim.nome]
                
                if tipo and self.dataManager.animacoesPersonalizadas[tipo] ~= idAnimacao then
                    -- Atualiza a animação personalizada
                    self.dataManager.animacoesPersonalizadas[tipo] = idAnimacao
                    self.dataManager:salvarAnimacoesPersonalizadas()
                    
                    -- Aplica ao personagem atual se existir
                    local player = game:GetService("Players").LocalPlayer
                    if player.Character then
                        self:recarregarAnimacoes(player.Character)
                    end
                    
                    -- Feedback visual
                    if labelFeedback then
                        labelFeedback.Text = "Animação '" .. anim.nome .. "' aplicada!"
                        labelFeedback.TextColor3 = Config.CORES.SUCESSO
                        labelFeedback.Parent.Visible = true
                        task.delay(3, function() 
                            labelFeedback.Parent.Visible = false 
                        end)
                    end
                    
                    return true
                end
                
                break
            end
        end
        
        return false
    end
    
    return self
end

-- Módulo de Interface do Usuário
local UIManager = {}

function UIManager.new(dataManager, animationManager)
    local self = {}
    self.dataManager = dataManager
    self.animationManager = animationManager
    self.isCollapsed = false
    self.dragging = false
    self.lastTapTime = 0
    
    -- Cria a interface principal
    function self:criarInterface()
        local player = game:GetService("Players").LocalPlayer
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        
        -- ScreenGui principal
        self.screenGui = Utils.criarElementoUI("ScreenGui", player:WaitForChild("PlayerGui"), {
            Name = "AnimationPanel",
            IgnoreGuiInset = true,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        })
        
        -- Frame principal
        self.mainFrame = Utils.criarElementoUI("Frame", self.screenGui, {
            Size = UDim2.new(0, Config.TAMANHO_PAINEL.LARGURA, 0, Config.TAMANHO_PAINEL.ALTURA),
            Position = self.dataManager:obterPosicaoInicial(),
            BackgroundColor3 = Config.CORES.FUNDO_PRINCIPAL,
            BackgroundTransparency = 0.1,
            ClipsDescendants = true,
            Active = true
        })
        Utils.adicionarCantos(self.mainFrame, 10)
        
        -- Barra de título
        self.titleBar = Utils.criarElementoUI("Frame", self.mainFrame, {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Config.CORES.FUNDO_SECUNDARIO,
            BackgroundTransparency = 0.2
        })
        
        -- Título
        self.titleLabel = Utils.criarElementoUI("TextLabel", self.titleBar, {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            Text = "Animações",
            TextColor3 = Config.CORES.TEXTO,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            TextSize = 16,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Botão de reset de posição
        self.resetButton = Utils.criarElementoUI("TextButton", self.titleBar, {
            Size = UDim2.new(0, 100, 0, 30),
            Position = UDim2.new(1, -110, 0, 5),
            Text = "Reset Position",
            BackgroundColor3 = Config.CORES.FUNDO_ELEMENTO,
            TextColor3 = Config.CORES.TEXTO,
            Font = Enum.Font.Gotham,
            TextSize = 14
        })
        Utils.adicionarCantos(self.resetButton, 5)
        Utils.adicionarEfeitoHover(self.resetButton, Config.CORES.FUNDO_ELEMENTO, Config.CORES.FUNDO_ELEMENTO_HOVER)
        
        -- Frame de feedback
        self.feedbackFrame = Utils.criarElementoUI("Frame", self.mainFrame, {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 45),
            BackgroundColor3 = Config.CORES.FUNDO_SECUNDARIO,
            BackgroundTransparency = 0.5,
            Visible = false
        })
        Utils.adicionarCantos(self.feedbackFrame, 5)
        
        -- Label de feedback
        self.feedbackLabel = Utils.criarElementoUI("TextLabel", self.feedbackFrame, {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = Config.CORES.TEXTO,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center
        })
        
        -- Caixa de pesquisa
        self.searchBox = Utils.criarElementoUI("TextBox", self.mainFrame, {
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 80),
            BackgroundColor3 = Config.CORES.FUNDO_ELEMENTO,
            TextColor3 = Config.CORES.TEXTO,
            PlaceholderText = "Pesquisar animações...",
            Font = Enum.Font.Gotham,
            TextSize = 14,
            Text = "",
            ClearTextOnFocus = false
        })
        Utils.adicionarCantos(self.searchBox, 5)
        
        -- Frame de rolagem
        self.scrollingFrame = Utils.criarElementoUI("ScrollingFrame", self.mainFrame, {
            Size = UDim2.new(1, -20, 1, -120),
            Position = UDim2.new(0, 10, 0, 120),
            BackgroundTransparency = 1,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            AutomaticCanvasSize = Enum.AutomaticSize.None,
            BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png",
            MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
            TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png",
            ElasticBehavior = Enum.ElasticBehavior.Always
        })
        
        -- Layout da lista
        self.uiListLayout = Utils.criarElementoUI("UIListLayout", self.scrollingFrame, {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Vertical
        })
        
        -- Configurar eventos
        self:configurarEventos()
        
        return self.screenGui
    end
    
    -- Configura todos os eventos da interface
    function self:configurarEventos()
        local player = game:GetService("Players").LocalPlayer
        local TweenService = game:GetService("TweenService")
        local UserInputService = game:GetService("UserInputService")
        
        -- Atualiza o tamanho do canvas quando o conteúdo muda
        self.uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.uiListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        -- Botão de reset de posição
        self.resetButton.MouseButton1Click:Connect(function()
            local screenSize = workspace.CurrentCamera.ViewportSize
            local initialX = (screenSize.X - Config.TAMANHO_PAINEL.LARGURA) / 2
            local initialY = (screenSize.Y - Config.TAMANHO_PAINEL.ALTURA) / 2
            
            TweenService:Create(
                self.mainFrame, 
                TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
                {Position = UDim2.new(0, initialX, 0, initialY)}
            ):Play()
            
            self.dataManager:salvarPosicaoPainel(UDim2.new(0, initialX, 0, initialY))
        end)
        
        -- Eventos de arraste
        local dragStart, startPos
        
        self.titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self.dragging = true
                dragStart = input.Position
                startPos = self.mainFrame.Position
                
                -- Verifica duplo clique para colapsar/expandir
                local currentTime = tick()
                if currentTime - self.lastTapTime < 0.3 then
                    self.isCollapsed = not self.isCollapsed
                    local targetSize = self.isCollapsed and 
                        UDim2.new(0, Config.TAMANHO_PAINEL.LARGURA, 0, Config.TAMANHO_PAINEL.ALTURA_MINIMIZADO) or 
                        UDim2.new(0, Config.TAMANHO_PAINEL.LARGURA, 0, Config.TAMANHO_PAINEL.ALTURA)
                    
                    TweenService:Create(
                        self.mainFrame, 
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
                        {Size = targetSize}
                    ):Play()
                end
                self.lastTapTime = currentTime
            end
        end)
        
        self.titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                self.dragging = false
                self.dataManager:salvarPosicaoPainel(self.mainFrame.Position)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if self.dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local newPosX = startPos.X.Offset + delta.X
                local newPosY = startPos.Y.Offset + delta.Y
                
                local screenSize = workspace.CurrentCamera.ViewportSize
                local minX = 0
                local maxX = screenSize.X - self.mainFrame.Size.X.Offset
                local minY = 0
                local maxY = screenSize.Y - self.mainFrame.Size.Y.Offset
                
                newPosX = math.clamp(newPosX, minX, maxX)
                newPosY = math.clamp(newPosY, minY, maxY)
                
                TweenService:Create(
                    self.mainFrame, 
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad), 
                    {Position = UDim2.new(0, newPosX, 0, newPosY)}
                ):Play()
            end
        end)
        
        -- Ajusta posição quando o tamanho da tela muda
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            local screenSize = workspace.CurrentCamera.ViewportSize
            local currentPos = self.mainFrame.Position
            
            local newX = math.clamp(
                currentPos.X.Offset, 
                0, 
                screenSize.X - self.mainFrame.Size.X.Offset
            )
            
            local newY = math.clamp(
                currentPos.Y.Offset, 
                0, 
                screenSize.Y - self.mainFrame.Size.Y.Offset
            )
            
            self.mainFrame.Position = UDim2.new(0, newX, 0, newY)
            self.dataManager:salvarPosicaoPainel(self.mainFrame.Position)
        end)
        
        -- Atualiza a lista quando o texto de pesquisa muda
        self.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            self:atualizarLista()
        end)
        
        -- Conecta eventos do personagem
        player.CharacterAdded:Connect(function(char)
            self.animationManager:conectarPersonagem(char)
            self.screenGui.Enabled = true
            self.mainFrame.Visible = true
        end)
        
        player.CharacterRemoving:Connect(function()
            self.screenGui.Enabled = true
            self.mainFrame.Visible = true
        end)
    end
    
    -- Atualiza a lista de animações
    function self:atualizarLista()
        -- Limpa a lista atual
        for _, child in ipairs(self.scrollingFrame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        local buttonHeight = 60
        local visibleCount = 0
        
        -- Organiza animações por pacote
        local animationsByBundle = {}
        for _, anim in ipairs(self.dataManager.animacoes) do
            local bundleName = anim.bundleNome or "Sem Pacote"
            if not animationsByBundle[bundleName] then
                animationsByBundle[bundleName] = {}
            end
            table.insert(animationsByBundle[bundleName], anim)
        end
        
        -- Cria a lista com cabeçalhos de pacote e separadores
        for bundleName, anims in pairs(animationsByBundle) do
            -- Cabeçalho do pacote
            local headerFrame = Utils.criarElementoUI("Frame", self.scrollingFrame, {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                LayoutOrder = visibleCount
            })
            
            local headerLabel = Utils.criarElementoUI("TextLabel", headerFrame, {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Text = bundleName,
                TextColor3 = Config.CORES.TEXTO_SECUNDARIO,
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            visibleCount = visibleCount + 1
            
            -- Animações do pacote
            local animacoesVisiveis = false
            for _, anim in ipairs(anims) do
                local nome = anim.nome or "Desconhecido"
                local id = anim.idAnimacao or "?"
                local textoPesquisa = self.searchBox.Text:lower() or ""
                
                if textoPesquisa == "" or string.match(string.lower(nome .. bundleName), textoPesquisa) then
                    animacoesVisiveis = true
                    
                    local buttonFrame = Utils.criarElementoUI("Frame", self.scrollingFrame, {
                        Size = UDim2.new(1, 0, 0, buttonHeight),
                        BackgroundColor3 = Config.CORES.FUNDO_ELEMENTO,
                        BackgroundTransparency = 0,
                        BorderSizePixel = 1,
                        BorderColor3 = Config.CORES.BORDA,
                        LayoutOrder = visibleCount
                    })
                    Utils.adicionarCantos(buttonFrame, 5)
                    
                    local animLabel = Utils.criarElementoUI("TextLabel", buttonFrame, {
                        Size = UDim2.new(1, -30, 0, 20),
                        Position = UDim2.new(0, 20, 0, 5),
                        Text = nome,
                        TextColor3 = Config.CORES.TEXTO,
                        BackgroundTransparency = 1,
                        Font = Enum.Font.GothamSemibold,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    -- Adiciona ID da animação como subtítulo
                    local idLabel = Utils.criarElementoUI("TextLabel", buttonFrame, {
                        Size = UDim2.new(1, -30, 0, 16),
                        Position = UDim2.new(0, 20, 0, 25),
                        Text = "ID: " .. id,
                        TextColor3 = Config.CORES.TEXTO_SECUNDARIO,
                        BackgroundTransparency = 1,
                        Font = Enum.Font.Gotham,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    
                    -- Adiciona marcação se a animação está em uso
                    local marker = Utils.criarElementoUI("Frame", buttonFrame, {
                        Size = UDim2.new(0, 10, 0, 10),
                        Position = UDim2.new(0, 5, 0, 10),
                        BackgroundColor3 = Config.CORES.DESTAQUE,
                        BackgroundTransparency = 1
                    })
                    Utils.adicionarCantos(marker, 10)
                    
                    -- Verifica se a animação está em uso
                    for animType, currentId in pairs(self.dataManager.animacoesPersonalizadas) do
                        if currentId == id and Config.ANIMACAO_TIPOS[anim.nome] == animType then
                            marker.BackgroundTransparency = 0
                            break
                        end
                    end
                    
                    -- Botão de aplicar animação
                    local button = Utils.criarElementoUI("TextButton", buttonFrame, {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = ""
                    })
                    
                    -- Efeito de clique
                    button.MouseButton1Click:Connect(function()
                        self.animationManager:aplicarAnimacao(id, self.feedbackLabel)
                        
                        -- Efeito visual de clique
                        local originalColor = buttonFrame.BackgroundColor3
                        buttonFrame.BackgroundColor3 = Config.CORES.FUNDO_ELEMENTO_HOVER
                        
                        task.delay(0.2, function()
                            buttonFrame.BackgroundColor3 = originalColor
                        end)
                        
                        -- Atualiza a lista para mostrar a nova seleção
                        self:atualizarLista()
                    end)
                    
                    -- Adiciona efeito de hover
                    Utils.adicionarEfeitoHover(buttonFrame, Config.CORES.FUNDO_ELEMENTO, Config.CORES.FUNDO_ELEMENTO_HOVER)
                    
                    visibleCount = visibleCount + 1
                end
            end
            
            -- Se não houver animações visíveis neste pacote, remove o cabeçalho
            if not animacoesVisiveis then
                headerFrame:Destroy()
                visibleCount = visibleCount - 1
            else
                -- Separador
                local separator = Utils.criarElementoUI("Frame", self.scrollingFrame, {
                    Size = UDim2.new(1, -20, 0, 2),
                    BackgroundColor3 = Config.CORES.BORDA,
                    BackgroundTransparency = 0.5,
                    LayoutOrder = visibleCount
                })
                
                visibleCount = visibleCount + 1
            end
        end
        
        -- Atualiza o tamanho do canvas
        self.scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, self.uiListLayout.AbsoluteContentSize.Y + 10)
    end
    
    return self
end

-- Inicialização do sistema
local function iniciarSistema()
    -- Detecta recursos disponíveis
    local recursos = Utils.detectarRecursos()
    
    -- Inicializa gerenciadores
    local dataManager = DataManager.new(recursos)
    local animationManager = AnimationManager.new(dataManager)
    local uiManager = UIManager.new(dataManager, animationManager)
    
    -- Carrega dados
    dataManager:carregarAnimacoes()
    task.wait(0.1) -- Pequena espera para garantir que as animações foram carregadas
    dataManager:carregarAnimacoesSalvas()
    
    -- Cria interface
    local ui = uiManager:criarInterface()
    
    -- Conecta ao personagem atual se existir
    local player = game:GetService("Players").LocalPlayer
    if player.Character then 
        animationManager:conectarPersonagem(player.Character) 
    end
    
    -- Atualiza a lista de animações
    uiManager:atualizarLista()
    
    return {
        dataManager = dataManager,
        animationManager = animationManager,
        uiManager = uiManager,
        ui = ui
    }
end

-- Inicia o sistema
local sistema = iniciarSistema()
