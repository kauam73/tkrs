-- Script universal para detectar método de requisição HTTP em executores
local function detectHttpMethod()
    local success, result

    -- Lista de métodos comuns em diferentes executores
    local methods = {
        { name = "syn.request", check = (typeof(syn) == "table" and typeof(syn.request) == "function") and syn.request or nil },
        { name = "http.request", check = (typeof(http) == "table" and typeof(http.request) == "function") and http.request or nil },
        { name = "request", check = (typeof(request) == "function") and request or nil },
        { name = "HttpGet", check = (typeof(HttpGet) == "function") and HttpGet or nil },
        { name = "httpget", check = (typeof(httpget) == "function") and httpget or nil },
        { name = "HttpGetAsync", check = (typeof(HttpGetAsync) == "function") and HttpGetAsync or nil },
        { name = "game.HttpGet", check = (typeof(game) == "Instance" and typeof(game.HttpGet) == "function") and function(...) return game:HttpGet(...) end or nil }
    }

    for _, method in ipairs(methods) do
        if method.check then
            return method.name, method.check
        end
    end

    return nil, nil
end

-- Função principal que será carregada via loadstring
return function(userMethod)
    local detectedName, detectedFunc = detectHttpMethod()
    local methodToUse = nil

    if typeof(userMethod) == "function" then
        methodToUse = userMethod
    elseif typeof(userMethod) == "string" and userMethod == detectedName then
        methodToUse = detectedFunc
    elseif userMethod ~= nil then
        warn("Método especificado inválido ou não suportado: " .. tostring(userMethod))
    end

    -- Fallback para o método detectado
    _G.ExecutorHttpMethod = methodToUse or detectedFunc

    -- Logging
    if detectedName then
        print("Método HTTP detectado: " .. detectedName)
    else
        warn("Nenhum método HTTP suportado detectado.")
    end

    if _G.ExecutorHttpMethod then
        print("Método HTTP configurado com sucesso.")
    else
        warn("Falha ao configurar método HTTP.")
    end

    return _G.ExecutorHttpMethod
end