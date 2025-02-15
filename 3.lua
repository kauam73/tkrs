-- Carrega a biblioteca RayField  
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()  

-- Cria a janela principal (sem KeySystem)  
local Window = Rayfield:CreateWindow({  
    Name = "extração dados em alto fator",  
    LoadingTitle = "Carregando...",  
    LoadingSubtitle = "Por Tekscripts",  
    Theme = "Padrão",  
    ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "Tekscripts" },  
    Discord = { Enabled = false, Invite = "discord", RememberJoins = true }  
})  

-- Cria a aba  
local Tab = Window:CreateTab("ReplicatedStorage", 4483362458)  

-- Obtém o caminho completo do objeto  
local function getObjectPath(obj)  
    local path = {}  
    local current = obj  
    while current and current ~= game do  
        table.insert(path, 1, current.Name)  
        current = current.Parent  
    end  
    return table.concat(path, ".")  
end  

-- Coleta informações do objeto com mais detalhes  
local function coletarDetalhes(obj)  
    local detalhes = {  
        Nome = obj.Name,  
        Classe = obj.ClassName,  
        Caminho = getObjectPath(obj), -- caminho completo  
        Propriedades = {}  
    }  
    if obj:IsA("ValueBase") then  
        detalhes.Propriedades.Value = obj.Value  
    end  
    if obj:IsA("RemoteEvent") then  
        detalhes.Propriedades.RemoteEvent = true  
        local atributos = obj:GetAttributes()  
        if next(atributos) then detalhes.Propriedades.Atributos = atributos end  
        return detalhes  
    end  
    if obj:IsA("RemoteFunction") then  
        detalhes.Propriedades.RemoteFunction = true  
        local atributos = obj:GetAttributes()  
        if next(atributos) then detalhes.Propriedades.Atributos = atributos end  
        return detalhes  
    end  
    detalhes.Filhos = {}  
    for _, filho in ipairs(obj:GetChildren()) do  
        table.insert(detalhes.Filhos, coletarDetalhes(filho))  
    end  
    return detalhes  
end  

-- Gera JSON legível  
local function prettyPrint(tbl, indent)  
    indent = indent or 0  
    local indentStr = string.rep("  ", indent)  
    local toprint = ""  
    if type(tbl) == "table" then  
        toprint = toprint .. "{\n"  
        for k, v in pairs(tbl) do  
            local key = type(k)=="number" and "["..k.."]" or '"'..tostring(k)..'"'  
            toprint = toprint .. indentStr .. "  " .. key .. " = " .. prettyPrint(v, indent+1) .. ",\n"  
        end  
        toprint = toprint .. indentStr .. "}"  
    elseif type(tbl) == "string" then  
        toprint = toprint .. '"' .. tbl .. '"'  
    else  
        toprint = toprint .. tostring(tbl)  
    end  
    return toprint  
end  

-- Funções de coleta recursiva para RemoteEvents, RemoteFunctions, Valores e ModuleScripts  
local function coletarRemoteEvents(obj)  
    local eventos = {}  
    if obj:IsA("RemoteEvent") then table.insert(eventos, obj) end  
    for _, child in ipairs(obj:GetChildren()) do  
        for _, evt in ipairs(coletarRemoteEvents(child)) do  
            table.insert(eventos, evt)  
        end  
    end  
    return eventos  
end  

local function listarRemoteEvents()  
    local replicatedStorage = game:GetService("ReplicatedStorage")  
    return coletarRemoteEvents(replicatedStorage)  
end  

local function coletarRemoteFunctions(obj)  
    local funcoes = {}  
    if obj:IsA("RemoteFunction") then table.insert(funcoes, obj) end  
    for _, child in ipairs(obj:GetChildren()) do  
        for _, rf in ipairs(coletarRemoteFunctions(child)) do  
            table.insert(funcoes, rf)  
        end  
    end  
    return funcoes  
end  

local function listarRemoteFunctions()  
    local replicatedStorage = game:GetService("ReplicatedStorage")  
    return coletarRemoteFunctions(replicatedStorage)  
end  

local function coletarValores(obj)  
    local valores = {}  
    if obj:IsA("ValueBase") then  
        table.insert(valores, coletarDetalhes(obj))  
    end  
    for _, child in ipairs(obj:GetChildren()) do  
        for _, val in ipairs(coletarValores(child)) do  
            table.insert(valores, val)  
        end  
    end  
    return valores  
end  

local function listarValores()  
    local replicatedStorage = game:GetService("ReplicatedStorage")  
    return coletarValores(replicatedStorage)  
end  

local function coletarModuleScripts(obj)  
    local modules = {}  
    if obj:IsA("ModuleScript") then  
        local detalhes = {  
            Nome = obj.Name,  
            Classe = obj.ClassName,  
            Caminho = getObjectPath(obj),  
            Source = obj.Source -- código fonte  
        }  
        table.insert(modules, detalhes)  
    end  
    for _, child in ipairs(obj:GetChildren()) do  
        for _, mod in ipairs(coletarModuleScripts(child)) do  
            table.insert(modules, mod)  
        end  
    end  
    return modules  
end  

local function listarModuleScripts()  
    local replicatedStorage = game:GetService("ReplicatedStorage")  
    return coletarModuleScripts(replicatedStorage)  
end  

----------------------------------------------------------------  
-- Seção: Extração de JSON Completo  
local SecExtracao = Tab:CreateSection("Extração de JSON")  

local ButtonExtrairCompleto = Tab:CreateButton({  
    Name = "Extrair JSON Completo",  
    Callback = function()  
        local replicatedStorage = game:GetService("ReplicatedStorage")  
        local data = {}  

        -- Coleta detalhada de todos os filhos de ReplicatedStorage  
        data.Detalhado = {}  
        for _, item in ipairs(replicatedStorage:GetChildren()) do  
            table.insert(data.Detalhado, coletarDetalhes(item))  
        end  

        -- Coleta de Valores  
        data.Valores = listarValores()  

        -- Coleta de ModuleScripts  
        data.ModuleScripts = listarModuleScripts()  

        -- Coleta de RemoteEvents (convertendo para detalhes)  
        local remoteEvents = listarRemoteEvents()  
        data.RemoteEvents = {}  
        for _, evt in ipairs(remoteEvents) do  
            table.insert(data.RemoteEvents, coletarDetalhes(evt))  
        end  

        -- Coleta de RemoteFunctions (convertendo para detalhes)  
        local remoteFunctions = listarRemoteFunctions()  
        data.RemoteFunctions = {}  
        for _, rf in ipairs(remoteFunctions) do  
            table.insert(data.RemoteFunctions, coletarDetalhes(rf))  
        end  

        -- Gera JSON legível  
        local jsonCompleto = prettyPrint(data)  
        writefile("replicated_storage_completo.json", jsonCompleto)  
        Tab:CreateLabel("JSON completo salvo!")  
    end,  
})  

----------------------------------------------------------------  
-- Seção: Acionamento de RemoteEvents e RemoteFunctions  
local SecRemote = Tab:CreateSection("Acionamento de Remotes")  

-- RemoteEvents  
local remoteEvents = listarRemoteEvents()  
local dropdownEventos = {}  
for _, evt in ipairs(remoteEvents) do  
    table.insert(dropdownEventos, evt.Name)  
end  
local remoteEventSelecionado = dropdownEventos[1] or ""  

local RemoteEventDropdown = Tab:CreateDropdown({  
    Name = "Selecionar RemoteEvent",  
    Options = dropdownEventos,  
    Callback = function(selected)  
        remoteEventSelecionado = selected  
    end,  
})  

local ButtonAcionarEvento = Tab:CreateButton({  
    Name = "Acionar RemoteEvent",  
    Callback = function()  
        local eventos = listarRemoteEvents()  
        local eventoAlvo = nil  
        for _, evt in ipairs(eventos) do  
            if evt.Name == remoteEventSelecionado then  
                eventoAlvo = evt  
                break  
            end  
        end  
        if eventoAlvo then  
            local success, err = pcall(function()  
                eventoAlvo:FireServer("Teste")  
            end)  
            if not success then  
                Tab:CreateLabel("Erro: " .. tostring(err))  
            else  
                Tab:CreateLabel("RemoteEvent acionado!")  
            end  
        else  
            Tab:CreateLabel("RemoteEvent não encontrado.")  
        end  
    end,  
})  

-- RemoteFunctions  
local remoteFunctions = listarRemoteFunctions()  
local dropdownFuncoes = {}  
for _, rf in ipairs(remoteFunctions) do  
    table.insert(dropdownFuncoes, rf.Name)  
end  
local remoteFunctionSelecionada = dropdownFuncoes[1] or ""  

local RemoteFunctionDropdown = Tab:CreateDropdown({  
    Name = "Selecionar RemoteFunction",  
    Options = dropdownFuncoes,  
    Callback = function(selected)  
        remoteFunctionSelecionada = selected  
    end,  
})  

local ButtonAcionarRF = Tab:CreateButton({  
    Name = "Acionar RemoteFunction",  
    Callback = function()  
        local funcoes = listarRemoteFunctions()  
        local rfAlvo = nil  
        for _, rf in ipairs(funcoes) do  
            if rf.Name == remoteFunctionSelecionada then  
                rfAlvo = rf  
                break  
            end  
        end  
        if rfAlvo then  
            local success, retorno = pcall(function()  
                return rfAlvo:InvokeServer("e9e")  
            end)  
            if not success then  
                Tab:CreateLabel("Erro: " .. tostring(retorno))  
            else  
                Tab:CreateLabel("RemoteFunction retornou: " .. tostring(retorno))  
            end  
        else  
            Tab:CreateLabel("RemoteFunction não encontrada.")  
        end  
    end,  
})
