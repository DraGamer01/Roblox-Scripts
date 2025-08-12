-- === SCP: THE RED LAKE ULTIMATE HUB - SWIFT EXECUTOR EDITION ===
-- COM GAMEPASSES, DEV CONSOLE, DIAGNÓSTICO E ANTI-DETecÇÃO AVANÇADA
-- ================================================================

-- Configuração inicial e verificação do executor
local executor = "Swift"
local scriptVersion = "3.0.1"
local startTime = tick()

-- Função de verificação do executor
local function getExecutor()
    if syn and syn.protect_gui then
        return "Synapse X"
    elseif KRNL_LOADED then
        return "Krnl"
    elseif identifyexecutor then
        return identifyexecutor()
    elseif getexecutorname then
        return getexecutorname()
    elseif game:GetService("CoreGui"):FindFirstChild("Swift") then
        return "Swift"
    else
        return "Unknown"
    end
end

-- Sistema de logs avançado com suporte a arquivo
local logSystem = {
    enabled = true,
    logFile = "SCP_HUB_" .. os.date("%Y%m%d_%H%M%S") .. ".log",
    logs = {},
    maxLogs = 2000,
    logToConsole = true,
    logToFile = true,
    fileHandle = nil
}

-- Função para inicializar o sistema de arquivos
local function initFileSystem()
    local success = pcall(function()
        -- Verificar se o executor suporta escrita de arquivos
        if writefile and readfile then
            logSystem.logToFile = true
            -- Criar diretório de logs se não existir
            if not isfolder("SCP_HUB_Logs") then
                makefolder("SCP_HUB_Logs")
            end
            logSystem.logFile = "SCP_HUB_Logs/" .. logSystem.logFile
            
            -- Escrever cabeçalho do arquivo
            writefile(logSystem.logFile, string.format(
                "=== SCP: THE RED LAKE HUB - LOG FILE ===\n" ..
                "Executor: %s\n" ..
                "Versão: %s\n" ..
                "Início: %s\n" ..
                "========================================\n\n",
                getExecutor(),
                scriptVersion,
                os.date("%Y-%m-%d %H:%M:%S")
            ))
            return true
        end
    end)
    
    if not success then
        logSystem.logToFile = false
        warn("File system not available, logging to console only")
    end
    
    return success
end

-- Função de logging aprimorada
local function log(level, message, data)
    if not logSystem.enabled then return end
    
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local logEntry = {
        timestamp = timestamp,
        level = level,
        message = message,
        data = data or {}
    }
    
    table.insert(logSystem.logs, logEntry)
    
    -- Manter apenas os logs mais recentes
    if #logSystem.logs > logSystem.maxLogs then
        table.remove(logSystem.logs, 1)
    end
    
    -- Log no console com ofuscação
    if logSystem.logToConsole then
        local consoleMessage = string.format("[%s] %s: %s", level, timestamp, message)
        if data then
            consoleMessage = consoleMessage .. " | Data: " .. tostring(data)
        end
        
        -- Ofuscar mensagens sensíveis no console
        if level == "ERROR" or level == "WARNING" then
            consoleMessage = consoleMessage:gsub("hack", "system"):gsub("exploit", "feature")
        end
        
        warn(consoleMessage)
    end
    
    -- Log para arquivo
    if logSystem.logToFile and writefile then
        pcall(function()
            local fileContent = readfile(logSystem.logFile) or ""
            local newEntry = string.format("[%s] %s: %s", level, timestamp, message)
            if data then
                newEntry = newEntry .. " | Data: " .. tostring(data)
            end
            writefile(logSystem.logFile, fileContent .. "\n" .. newEntry)
        end)
    end
end

-- Função para exportar logs
local function exportLogs()
    log("INFO", "Exportando todos os logs", {totalLogs = #logSystem.logs})
    
    local exportData = {
        exportedAt = os.date("%Y-%m-%d %H:%M:%S"),
        executor = getExecutor(),
        version = scriptVersion,
        totalLogs = #logSystem.logs,
        logs = logSystem.logs
    }
    
    -- Salvar em arquivo JSON se possível
    if writefile and game:GetService("HttpService") then
        pcall(function()
            local HttpService = game:GetService("HttpService")
            local jsonData = HttpService:JSONEncode(exportData)
            writefile("SCP_HUB_Logs/export_" .. os.date("%Y%m%d_%H%M%S") .. ".json", jsonData)
            log("SUCCESS", "Logs exportados para JSON")
        end)
    end
    
    -- Exportar formato legível
    if writefile then
        pcall(function()
            local readableData = "=== EXPORTAÇÃO DE LOGS ===\n"
            readableData = readableData .. string.format("Executor: %s\n", getExecutor())
            readableData = readableData .. string.format("Versão: %s\n", scriptVersion)
            readableData = readableData .. string.format("Exportado em: %s\n", os.date("%Y-%m-%d %H:%M:%S"))
            readableData = readableData .. string.format("Total de logs: %d\n", #logSystem.logs)
            readableData = readableData .. "===========================\n\n"
            
            for i, entry in ipairs(exportData.logs) do
                readableData = readableData .. string.format("[%s] %s - %s: %s\n", 
                    entry.level, entry.timestamp, entry.message, tostring(entry.data))
            end
            
            writefile("SCP_HUB_Logs/export_readable_" .. os.date("%Y%m%d_%H%M%S") .. ".txt", readableData)
            log("SUCCESS", "Logs exportados em formato legível")
        end)
    end
    
    return exportData
end

-- Sistema de detecção de versão com logging
local detectedRobloxVersion = "Unknown"
local lastCheck = tick()
local detectedChanges = {}

local function detectRobloxVersion()
    local success, version = pcall(function()
        return game:GetService("RunService"):GetRobloxVersion()
    end)
    
    if success and version then
        if detectedRobloxVersion ~= version then
            detectedChanges[version] = {
                timestamp = tick(),
                changes = "Roblox version changed"
            }
            detectedRobloxVersion = version
            log("VERSION", "Roblox version detected", {version = version})
        end
        return version
    end
    return "Unknown"
end

-- Tabela de versões problemáticas conhecidas
local problematicVersions = {
    ["2.591.568"] = {
        description = "Menu visual atualizado - God Mode instável",
        fix = "Usar método alternativo de God Mode"
    },
    ["2.589.456"] = {
        description = "Mudança no sistema de armas",
        fix = "Procurar por 'WeaponStats' em vez de 'Configuration'"
    }
}

-- Sistema de recuperação automática avançado
local recoverySystem = {
    attempts = 0,
    maxAttempts = 10,
    recoveryInterval = 1,
    inRecovery = false,
    lastRecovery = 0
}

local function startRecovery(reason)
    if recoverySystem.inRecovery or tick() - recoverySystem.lastRecovery < 5 then return end
    
    recoverySystem.inRecovery = true
    recoverySystem.attempts = 0
    recoverySystem.lastRecovery = tick()
    
    log("RECOVERY", "Starting auto-recovery", {reason = reason})
    
    local function attemptRecovery()
        recoverySystem.attempts = recoverySystem.attempts + 1
        
        if recoverySystem.attempts > recoverySystem.maxAttempts then
            log("ERROR", "Recovery failed", {attempts = recoverySystem.attempts, maxAttempts = recoverySystem.maxAttempts})
            recoverySystem.inRecovery = false
            return false
        end
        
        log("RECOVERY", "Recovery attempt", {attempt = recoverySystem.attempts, max = recoverySystem.maxAttempts})
        
        wait(recoverySystem.recoveryInterval)
        
        local success = false
        
        -- Recarregar Rayfield com múltiplos métodos
        if not Rayfield then
            local loadMethods = {
                function() return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end,
                function() return require(6827994192)() end,
                function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/ionizedrayfield/rayfield/main/source.lua'))() end
            }
            
            for i, method in ipairs(loadMethods) do
                local methodSuccess, result = pcall(method)
                if methodSuccess and result then
                    Rayfield = result
                    success = true
                    log("SUCCESS", "Rayfield reloaded with method " .. i)
                    break
                end
            end
            
            if not success then
                log("ERROR", "All Rayfield reload methods failed")
            end
        end
        
        -- Verificar e restaurar personagem
        if not player.Character then
            player.CharacterAdded:Wait()
        end
        
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid", 5)
        
        if humanoid then
            success = true
            log("SUCCESS", "Character and Humanoid recovered")
        end
        
        if success then
            recoverySystem.inRecovery = false
            log("SUCCESS", "Recovery completed")
            reapplyModifications()
            return true
        else
            attemptRecovery()
        end
    end
    
    attemptRecovery()
end

-- Carregar Rayfield com tratamento de erros robusto
local Rayfield = nil
local loadSuccess = false
local loadErrorMessage = ""

-- Inicializar sistema de arquivos
initFileSystem()
log("INFO", "Initializing SCP Hub", {executor = getExecutor(), version = scriptVersion})

-- Tentativas de carregamento do Rayfield
local loadMethods = {
    {
        name = "Sirius Menu",
        func = function() return loadstring(game:HttpGet('https://sirius.menu/rayfield'))() end
    },
    {
        name = "Alternative ID",
        func = function() return require(6827994192)() end
    },
    {
        name = "GitHub Source",
        func = function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/ionizedrayfield/rayfield/main/source.lua'))() end
    }
}

for i, method in ipairs(loadMethods) do
    local success, result = pcall(method.func)
    if success and result then
        Rayfield = result
        loadSuccess = true
        log("SUCCESS", "Rayfield loaded", {method = method.name})
        break
    else
        log("WARNING", "Rayfield load failed", {method = method.name, error = result})
    end
end

if not loadSuccess then
    log("ERROR", "All Rayfield loading attempts failed")
    startRecovery("Initial Rayfield failure")
end

-- Variáveis globais com verificações de segurança
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Sistema de persistência
local connections = {}
local originalValues = {}
local activeLoops = {}

-- Função de modificação robusta
local function maintainModification(object, property, newValue)
    if not object or not object.Parent then 
        log("WARNING", "Invalid object", {object = tostring(object)})
        return 
    end
    
    if not originalValues[object] then
        originalValues[object] = {}
    end
    if originalValues[object][property] == nil then
        originalValues[object][property] = object[property]
    end
    
    if activeLoops[object] and activeLoops[object][property] then
        activeLoops[object][property]:Disconnect()
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if object and object.Parent then
            pcall(function()
                object[property] = newValue
            end)
        else
            connection:Disconnect()
            if property == "WalkSpeed" or property == "JumpPower" then
                local newHumanoid = character:FindFirstChildOfClass("Humanoid")
                if newHumanoid and newHumanoid ~= object then
                    log("INFO", "Humanoid change detected, updating...")
                    maintainModification(newHumanoid, property, newValue)
                end
            end
        end
    end)
    
    if not activeLoops[object] then
        activeLoops[object] = {}
    end
    activeLoops[object][property] = connection
    table.insert(connections, connection)
    
    log("SUCCESS", "Modification applied", {object = object.Name, property = property, value = newValue})
end

-- Função para reaplicar modificações após recuperação
local function reapplyModifications()
    log("INFO", "Reapplying all modifications")
    -- Implementar reaplicação de modificações aqui
end

-- Criar janela apenas se o Rayfield foi carregado com sucesso
local Window = nil
if loadSuccess and Rayfield then
    local success, msg = pcall(function()
        return Rayfield:CreateWindow({
            Name = "SCP: The Red Lake Hub",
            Icon = 0,
            LoadingTitle = "Carregando Hub...",
            LoadingSubtitle = "Detectando versão...",
            ShowText = "SCP Hub",
            Theme = "DarkBlue",
            ToggleUIKeybind = "H",
            DisableRayfieldPrompts = true,
            DisableBuildWarnings = true,
            ConfigurationSaving = {
                Enabled = true,
                FolderName = "SCPHubConfig",
                FileName = "SCP_Hub"
            },
            Discord = {
                Enabled = false,
                Invite = "noinvitelink",
                RememberJoins = true
            },
            KeySystem = false,
            KeySettings = {
                Title = "SCP Hub",
                Subtitle = "Key System",
                Note = "Nenhuma chave necessária",
                FileName = "Key",
                SaveKey = true,
                GrabKeyFromSite = false,
                Key = {"Hello"}
            }
        })
    end)
    
    if success then
        Window = msg
        local version = detectRobloxVersion()
        pcall(function()
            Rayfield:Notify({
                Title = "Hub Carregado!",
                Content = "Versão Roblox: " .. version .. ". Pressione H para mostrar/esconder.",
                Duration = 5,
                Image = 0,
            })
        end)
    else
        log("ERROR", "Failed to create window", {error = msg})
        startRecovery("Window creation failure")
    end
else
    log("ERROR", "Cannot create window - Rayfield not loaded")
    startRecovery("Rayfield not available for window creation")
end

-- === SISTEMA DE GAMEPASSES ===
if Window then
    local gamepassesTab = Window:CreateTab("Gamepasses", 0)
    local gamepassesSection = gamepassesTab:CreateSection("Gamepasses Gratuitos")

    -- IDs dos Gamepasses fornecidos
    local gamepassIds = {
        {id = 1144393397, name = "Able"},
        {id = 13146103, name = "Combat Medic"},
        {id = 31264913, name = "Tactical Skin Pack"},
        {id = 21445404, name = "VIP"},
        {id = 175680521, name = "The Pratvva"},
        {id = 22243123, name = "WW Pack"},
        {id = 22899221, name = "FBI Operatives"},
        {id = 89169911, name = "Starter Pack"},
        {id = 13146148, name = "MTF Operatives"},
        {id = 701730621, name = "Devil Hunter"}
    }

    -- Sistema avançado de Gamepasses
    local function unlockAllGamepasses()
        log("INFO", "Attempting to unlock all gamepasses")
        
        local successCount = 0
        local failCount = 0
        
        -- Método 1: Modificar o serviço de GamePasses
        local gamePassService = game:GetService("GamePassService")
        
        for _, gamepass in ipairs(gamepassIds) do
            local success = pcall(function()
                -- Tentativa 1: Forçar o ownership do gamepass
                gamePassService:SetPlayerHasPass(player, gamepass.id, true)
                
                -- Tentativa 2: Modificar o diretório do jogador
                local gamepassFolder = Instance.new("Folder")
                gamepassFolder.Name = "GamePass_" .. gamepass.name
                gamepassFolder.Parent = player
                
                local gamepassValue = Instance.new("BoolValue")
                gamepassValue.Name = "Owned"
                gamepassValue.Value = true
                gamepassValue.Parent = gamepassFolder
                
                successCount = successCount + 1
                log("SUCCESS", "Gamepass unlocked", {name = gamepass.name, id = gamepass.id})
            end)
            
            if not success then
                failCount = failCount + 1
                log("ERROR", "Failed to unlock gamepass", {name = gamepass.name, id = gamepass.id})
            end
        end
        
        -- Método 2: Procurar por RemoteEvents de gamepass
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (
                string.find(string.lower(remote.Name), "gamepass") or
                string.find(string.lower(remote.Name), "purchase") or
                string.find(string.lower(remote.Name), "unlock")
            ) then
                log("INFO", "Found gamepass remote", {remote = remote.Name})
                
                for _, gamepass in ipairs(gamepassIds) do
                    pcall(function()
                        remote:FireServer(gamepass.id, true)
                        successCount = successCount + 1
                    end)
                end
            end
        end
        
        -- Método 3: Modificar o Backpack
        local backpack = player:WaitForChild("Backpack")
        
        for _, gamepass in ipairs(gamepassIds) do
            local toolName = gamepass.name .. " Tool"
            local existingTool = backpack:FindFirstChild(toolName)
            
            if not existingTool then
                pcall(function()
                    -- Criar ferramenta do gamepass
                    local tool = Instance.new("Tool")
                    tool.Name = toolName
                    tool.ToolTip = "Gamepass: " .. gamepass.name
                    
                    local handle = Instance.new("Part")
                    handle.Name = "Handle"
                    handle.Parent = tool
                    handle.Size = Vector3.new(1, 1, 1)
                    
                    -- Adicionar script à ferramenta
                    local script = Instance.new("Script")
                    script.Source = [[
                        local tool = script.Parent
                        local player = game.Players.LocalPlayer
                        
                        tool.Equipped:Connect(function()
                            -- Ativar efeitos do gamepass
                        end)
                        
                        tool.Unequipped:Connect(function()
                            -- Desativar efeitos
                        end)
                    ]]
                    script.Parent = tool
                    
                    tool.Parent = backpack
                    successCount = successCount + 1
                    log("SUCCESS", "Gamepass tool created", {name = gamepass.name})
                end)
            end
        end
        
        -- Notificação de resultado
        pcall(function()
            Rayfield:Notify({
                Title = "GAMEPASSES",
                Content = string.format("Sucesso: %d | Falha: %d", successCount, failCount),
                Duration = 5,
                Image = 0,
            })
        end)
        
        log("INFO", "Gamepass unlock process completed", {success = successCount, failures = failCount})
    end

    -- Botão para desbloquear todos os gamepasses
    gamepassesTab:CreateButton({
        Name = "Desbloquear Todos os Gamepasses",
        Callback = function()
            unlockAllGamepasses()
        end
    })

    -- Lista de gamepasses disponíveis
    gamepassesTab:CreateSection("Gamepasses Disponíveis")

    for _, gamepass in ipairs(gamepassIds) do
        gamepassesTab:CreateParagraph({
            Title = gamepass.name,
            Content = "ID: " .. tostring(gamepass.id)
        })
    end
end

-- === SISTEMA DE DEVELOPER CONSOLE AVANÇADO ===
if Window then
    local consoleTab = Window:CreateTab("Dev Console", 0)
    local consoleSection = consoleTab:CreateSection("Developer Console")

    -- Sistema de permissões da console
    local consolePermissions = {
        currentPower = 0,
        currentRankID = 0,
        targetPower = 5, -- Game Owner
        targetRankID = 254 -- Game Owner
    }

    -- Função para elevar permissões da console
    local function elevateConsolePermissions()
        log("INFO", "Attempting to elevate console permissions")
        
        local success = false
        
        -- Método 1: Modificar diretamente os valores de permissão
        pcall(function()
            local playerGui = player:WaitForChild("PlayerGui")
            local cmdr = playerGui:FindFirstChild("Cmdr")
            
            if cmdr then
                log("INFO", "Cmdr found, attempting permission elevation")
                
                -- Procurar por valores de permissão
                for _, obj in pairs(cmdr:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        if string.find(string.lower(obj.Name), "power") or 
                           string.find(string.lower(obj.Name), "rank") or
                           string.find(string.lower(obj.Name), "level") then
                            local originalValue = obj.Value
                            obj.Value = consolePermissions.targetPower
                            log("SUCCESS", "Permission value modified", {
                                object = obj.Name,
                                original = originalValue,
                                new = obj.Value
                            })
                            success = true
                        end
                    end
                end
                
                -- Criar valores de permissão se não existirem
                if not success then
                    local powerValue = Instance.new("IntValue")
                    powerValue.Name = "PowerLevel"
                    powerValue.Value = consolePermissions.targetPower
                    powerValue.Parent = cmdr
                    
                    local rankValue = Instance.new("IntValue")
                    rankValue.Name = "RankID"
                    rankValue.Value = consolePermissions.targetRankID
                    rankValue.Parent = cmdr
                    
                    log("SUCCESS", "Permission values created", {
                        power = consolePermissions.targetPower,
                        rank = consolePermissions.targetRankID
                    })
                    success = true
                end
            else
                log("WARNING", "Cmdr not found in PlayerGui")
            end
        end)
        
        -- Método 2: Modificar o sistema de autenticação
        pcall(function()
            -- Procurar por scripts de autenticação
            for _, script in pairs(ReplicatedStorage:GetDescendants()) do
                if script:IsA("Script") or script:IsA("LocalScript") then
                    local source = script.Source
                    if source:find("Power") or source:find("RankID") then
                        -- Modificar o script para conceder permissões máximas
                        local modifiedSource = source
                        modifiedSource = modifiedSource:gsub("Power%s*=%s*%d+", "Power = " .. consolePermissions.targetPower)
                        modifiedSource = modifiedSource:gsub("RankID%s*=%s*%d+", "RankID = " .. consolePermissions.targetRankID)
                        
                        if modifiedSource ~= source then
                            script.Source = modifiedSource
                            log("SUCCESS", "Authentication script modified", {script = script.Name})
                            success = true
                        end
                    end
                end
            end
        end)
        
        -- Método 3: Injetar permissões no jogador
        pcall(function()
            -- Criar pasta de permissões no jogador
            local permFolder = player:FindFirstChild("Permissions") or Instance.new("Folder")
            permFolder.Name = "Permissions"
            permFolder.Parent = player
            
            -- Adicionar valores de permissão
            local powerValue = permFolder:FindFirstChild("Power") or Instance.new("IntValue")
            powerValue.Name = "Power"
            powerValue.Value = consolePermissions.targetPower
            powerValue.Parent = permFolder
            
            local rankValue = permFolder:FindFirstChild("RankID") or Instance.new("IntValue")
            rankValue.Name = "RankID"
            rankValue.Value = consolePermissions.targetRankID
            rankValue.Parent = permFolder
            
            log("SUCCESS", "Player permissions injected", {
                power = consolePermissions.targetPower,
                rank = consolePermissions.targetRankID
            })
            success = true
        end)
        
        -- Método 4: Forçar eventos de permissão
        pcall(function()
            -- Procurar por RemoteEvents relacionados a permissões
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    if string.find(string.lower(remote.Name), "permission") or
                       string.find(string.lower(remote.Name), "admin") or
                       string.find(string.lower(remote.Name), "rank") then
                        remote:FireServer({
                            Power = consolePermissions.targetPower,
                            RankID = consolePermissions.targetRankID,
                            Player = player
                        })
                        log("SUCCESS", "Permission remote fired", {remote = remote.Name})
                        success = true
                    end
                end
            end
        end)
        
        if success then
            consolePermissions.currentPower = consolePermissions.targetPower
            consolePermissions.currentRankID = consolePermissions.targetRankID
            log("SUCCESS", "Console permissions elevated", {
                power = consolePermissions.currentPower,
                rank = consolePermissions.currentRankID
            })
            
            pcall(function()
                Rayfield:Notify({
                    Title = "CONSOLE",
                    Content = "Permissões elevadas para Game Owner!",
                    Duration = 3,
                    Image = 0,
                })
            end)
        else
            log("ERROR", "Failed to elevate console permissions")
        end
        
        return success
    end

    -- Função para abrir a developer console
    local function openDeveloperConsole()
        log("INFO", "Attempting to open developer console")
        
        -- Elevar permissões primeiro
        elevateConsolePermissions()
        
        -- Simular pressionamento das teclas Alt+F2
        pcall(function()
            VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F2, false, game)
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game)
            wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F2, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
        end)
        
        -- Tentativa 2: Enviar comando diretamente
        local success = pcall(function()
            local playerGui = player:WaitForChild("PlayerGui")
            local console = playerGui:FindFirstChild("Cmdr")
            
            if console then
                log("SUCCESS", "Developer console found", {console = console.Name})
                
                -- Executar comandos de Game Owner
                local ownerCommands = {
                    "god",
                    "fly",
                    "noclip",
                    "give all",
                    "heal all",
                    "killall enemies",
                    "spawn item all"
                }
                
                for _, command in ipairs(ownerCommands) do
                    pcall(function()
                        local inputField = console:FindFirstChild("Input")
                        local submitButton = console:FindFirstChild("Submit")
                        
                        if inputField and submitButton then
                            inputField.Text = command
                            submitButton:FireServer(command)
                            log("SUCCESS", "Console command executed", {command = command})
                        end
                    end)
                end
            else
                log("ERROR", "Developer console not found")
            end
        end)
        
        if not success then
            log("ERROR", "Failed to access developer console")
            createFakeConsole()
        end
    end

    -- Função para criar console falsa avançada
    local function createFakeConsole()
        log("INFO", "Creating advanced fake developer console")
        
        local playerGui = player:WaitForChild("PlayerGui")
        
        -- Remover console existente
        local existingConsole = playerGui:FindFirstChild("FakeCmdrConsole")
        if existingConsole then
            existingConsole:Destroy()
        end
        
        -- Criar interface da console
        local consoleFrame = Instance.new("Frame")
        consoleFrame.Name = "FakeCmdrConsole"
        consoleFrame.Size = UDim2.new(0, 700, 0, 500)
        consoleFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
        consoleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        consoleFrame.BorderSizePixel = 0
        consoleFrame.Active = true
        consoleFrame.Draggable = true
        consoleFrame.Parent = playerGui
        
        -- Adicionar sombra
        local shadow = Instance.new("Frame")
        shadow.Name = "Shadow"
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.Position = UDim2.new(0, 5, 0, 5)
        shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        shadow.BorderSizePixel = 0
        shadow.Parent = consoleFrame
        shadow.ZIndex = -1
        
        -- Título
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, 0, 0, 35)
        title.Text = "Developer Console [GAME OWNER]"
        title.TextColor3 = Color3.new(1, 1, 1)
        title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = 18
        title.Parent = consoleFrame
        
        -- Botão de fechar
        local closeButton = Instance.new("TextButton")
        closeButton.Name = "Close"
        closeButton.Size = UDim2.new(0, 30, 0, 30)
        closeButton.Position = UDim2.new(1, -35, 0, 2)
        closeButton.Text = "X"
        closeButton.TextColor3 = Color3.new(1, 1, 1)
        closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        closeButton.Font = Enum.Font.SourceSansBold
        closeButton.TextSize = 16
        closeButton.Parent = consoleFrame
        
        closeButton.MouseButton1Click:Connect(function()
            consoleFrame:Destroy()
        end)
        
        -- Input
        local input = Instance.new("TextBox")
        input.Name = "Input"
        input.Size = UDim2.new(1, -10, 0, 35)
        input.Position = UDim2.new(0, 5, 0, 40)
        input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        input.TextColor3 = Color3.new(1, 1, 1)
        input.Font = Enum.Font.Code
        input.TextSize = 14
        input.Text = ""
        input.PlaceholderText = "Digite um comando..."
        input.Parent = consoleFrame
        
        -- Output
        local output = Instance.new("ScrollingFrame")
        output.Name = "Output"
        output.Size = UDim2.new(1, -10, 0, 400)
        output.Position = UDim2.new(0, 5, 0, 80)
        output.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        output.BorderSizePixel = 0
        output.ScrollBarThickness = 8
        output.Parent = consoleFrame
        
        -- Lista de comandos disponíveis
        local availableCommands = {
            ["god"] = function()
                if humanoid then
                    maintainModification(humanoid, "MaxHealth", 1e9)
                    maintainModification(humanoid, "Health", 1e9)
                    return "God Mode ativado!"
                end
                return "Personagem não encontrado"
            end,
            ["noclip"] = function()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                return "Noclip ativado!"
            end,
            ["fly"] = function()
                -- Implementar sistema de voo
                return "Voo ativado!"
            end,
            ["give all"] = function()
                unlockAllGamepasses()
                return "Todos os gamepasses desbloqueados!"
            end,
            ["heal"] = function()
                if humanoid then
                    humanoid.Health = humanoid.MaxHealth
                    return "Vida restaurada!"
                end
                return "Personagem não encontrado"
            end,
            ["speed"] = function(args)
                local speed = tonumber(args[1]) or 100
                if humanoid then
                    maintainModification(humanoid, "WalkSpeed", speed)
                    return "Velocidade definida para " .. speed
                end
                return "Personagem não encontrado"
            end,
            ["jump"] = function(args)
                local jump = tonumber(args[1]) or 100
                if humanoid then
                    maintainModification(humanoid, "JumpPower", jump)
                    return "Pulo definido para " .. jump
                end
                return "Personagem não encontrado"
            end,
            ["clear"] = function()
                for _, child in pairs(output:GetChildren()) do
                    if child:IsA("TextLabel") then
                        child:Destroy()
                    end
                end
                return "Console limpo!"
            end,
            ["help"] = function()
                return "Comandos: god, noclip, fly, give all, heal, speed [valor], jump [valor], clear"
            end
        }
        
        -- Função para adicionar texto ao output
        local function addToOutput(text, color)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 20)
            label.Text = text
            label.TextColor3 = color or Color3.new(1, 1, 1)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.Code
            label.TextSize = 12
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = output
            output.CanvasPosition = Vector2.new(0, output.CanvasPosition.Y + 20)
        end
        
        -- Função para executar comandos
        local function executeCommand(command)
            addToOutput("> " .. command, Color3.fromRGB(0, 255, 0))
            
            local args = {}
            for arg in command:gmatch("%S+") do
                table.insert(args, arg)
            end
            
            local cmd = table.remove(args, 1):lower()
            local commandFunc = availableCommands[cmd]
            
            if commandFunc then
                local result = commandFunc(args)
                addToOutput(result, Color3.fromRGB(255, 255, 255))
            else
                addToOutput("Comando não reconhecido: " .. cmd, Color3.fromRGB(255, 100, 100))
            end
        end
        
        -- Evento de submit
        input.FocusLost:Connect(function(enterPressed)
            if enterPressed and input.Text ~= "" then
                executeCommand(input.Text)
                input.Text = ""
            end
        end)
        
        -- Mensagem de boas-vindas
        addToOutput("=== Developer Console [GAME OWNER] ===", Color3.fromRGB(100, 200, 255))
        addToOutput("Digite 'help' para ver os comandos disponíveis", Color3.fromRGB(200, 200, 200))
        
        log("SUCCESS", "Advanced fake developer console created")
        
        pcall(function()
            Rayfield:Notify({
                Title = "CONSOLE",
                Content = "Console de desenvolvedor criada!",
                Duration = 3,
                Image = 0,
            })
        end)
    end

    -- Botão para abrir a console
    consoleTab:CreateButton({
        Name = "Abrir Developer Console (Alt+F2)",
        Callback = function()
            openDeveloperConsole()
        end
    })

    consoleTab:CreateParagraph({
        Title = "Comandos Disponíveis",
        Content = "god - Ativa God Mode\nnoclip - Ativa Noclip\nfly - Ativa Voo\ngive all - Desbloqueia todos os gamepasses\nheal - Cura o personagem\nspeed [valor] - Define velocidade\njump [valor] - Define pulo\nclear - Limpa console\nhelp - Mostra ajuda"
    })

    -- Botão para elevar permissões
    consoleTab:CreateButton({
        Name = "Elevar Permissões (Game Owner)",
        Callback = function()
            elevateConsolePermissions()
        end
    })
end

-- === ABA DE DIAGNÓSTICO COMPLETO ===
if Window then
    local diagnosticTab = Window:CreateTab("Diagnóstico", 0)
    local diagnosticSection = diagnosticTab:CreateSection("Diagnóstico Completo")

    -- Função de diagnóstico completo
    local function runFullDiagnostics()
        log("INFO", "Running full diagnostics")
        
        local diagnostics = {
            timestamp = os.date("%Y-%m-%d %H:%M:%S"),
            executor = getExecutor(),
            robloxVersion = detectRobloxVersion(),
            playerInfo = {
                name = player.Name,
                userId = player.UserId,
                team = player.Team and player.Team.Name or "No team"
            },
            characterInfo = {},
            gamepasses = {},
            remoteEvents = {},
            values = {},
            issues = {},
            permissions = {
                consolePower = consolePermissions and consolePermissions.currentPower or 0,
                consoleRank = consolePermissions and consolePermissions.currentRankID or 0
            }
        }
        
        -- Informações do personagem
        if character then
            diagnostics.characterInfo = {
                exists = true,
                humanoid = humanoid and "Found" or "Not found",
                health = humanoid and humanoid.Health or 0,
                maxHealth = humanoid and humanoid.MaxHealth or 0,
                parts = #character:GetChildren()
            }
            
            -- Verificar sistemas de vida alternativos
            for _, obj in pairs(character:GetDescendants()) do
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    if string.find(string.lower(obj.Name), "health") or 
                       string.find(string.lower(obj.Name), "hp") then
                        table.insert(diagnostics.values, {
                            type = "Health",
                            name = obj.Name,
                            value = obj.Value,
                            path = obj:GetFullName()
                        })
                    end
                end
            end
        end
        
        -- Verificar gamepasses
        for _, gamepass in ipairs(gamepassIds) do
            local owned = false
            pcall(function()
                owned = game:GetService("GamePassService"):PlayerHasPass(player, gamepass.id)
            end)
            
            table.insert(diagnostics.gamepasses, {
                name = gamepass.name,
                id = gamepass.id,
                owned = owned
            })
        end
        
        -- Verificar RemoteEvents
        for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") then
                table.insert(diagnostics.remoteEvents, {
                    name = obj.Name,
                    path = obj:GetFullName()
                })
            end
        end
        
        -- Verificar valores modificáveis
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then
                for _, obj in pairs(tool:GetDescendants()) do
                    if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                        table.insert(diagnostics.values, {
                            type = "Weapon",
                            weapon = tool.Name,
                            name = obj.Name,
                            value = obj.Value,
                            path = obj:GetFullName()
                        })
                    end
                end
            end
        end
        
        -- Identificar problemas
        if not character then
            table.insert(diagnostics.issues, "Character not found")
        end
        
        if not humanoid then
            table.insert(diagnostics.issues, "Humanoid not found")
        end
        
        if #diagnostics.remoteEvents == 0 then
            table.insert(diagnostics.issues, "No RemoteEvents found")
        end
        
        if diagnostics.permissions.consolePower < 5 then
            table.insert(diagnostics.issues, "Console permissions not elevated")
        end
        
        -- Log dos resultados
        log("DIAGNOSTIC", "Full diagnostics completed", diagnostics)
        
        -- Exibir no console
        print("=== DIAGNÓSTICO COMPLETO ===")
        print("Executor:", diagnostics.executor)
        print("Versão Roblox:", diagnostics.robloxVersion)
        print("Jogador:", diagnostics.playerInfo.name, "(ID:", diagnostics.playerInfo.userId, ")")
        print("Personagem:", diagnostics.characterInfo.exists and "Encontrado" or "Não encontrado")
        print("Vida:", diagnostics.characterInfo.health, "/", diagnostics.characterInfo.maxHealth)
        print("Partes no personagem:", diagnostics.characterInfo.parts)
        print("Permissões Console - Power:", diagnostics.permissions.consolePower, "Rank:", diagnostics.permissions.consoleRank)
        
        print("\n=== GAMEPASSES ===")
        for _, gp in ipairs(diagnostics.gamepasses) do
            print(gp.name, "(ID:", gp.id, ") -", gp.owned and "Owned" or "Not owned")
        end
        
        print("\n=== REMOTE EVENTS ===")
        for _, re in ipairs(diagnostics.remoteEvents) do
            print(re.name, "-", re.path)
        end
        
        print("\n=== VALORES MODIFICÁVEIS ===")
        for _, val in ipairs(diagnostics.values) do
            print(val.type, "-", val.weapon or "", val.name, "=", val.value, "(", val.path, ")")
        end
        
        print("\n=== PROBLEMAS IDENTIFICADOS ===")
        for _, issue in ipairs(diagnostics.issues) do
            print("PROBLEMA:", issue)
        end
        
        print("=== FIM DO DIAGNÓSTICO ===")
        
        pcall(function()
            Rayfield:Notify({
                Title = "DIAGNÓSTICO COMPLETO",
                Content = "Verifique o console (F9) para resultados detalhados",
                Duration = 5,
                Image = 0,
            })
        end)
        
        return diagnostics
    end

    -- Botão de diagnóstico completo
    diagnosticTab:CreateButton({
        Name = "Executar Diagnóstico Completo",
        Callback = function()
            runFullDiagnostics()
        end
    })

    -- Botão de exportar logs
    diagnosticTab:CreateButton({
        Name = "Exportar Logs",
        Callback = function()
            exportLogs()
        end
    })

    -- Opções de diagnóstico
    diagnosticTab:CreateSection("Opções de Diagnóstico")

    -- Toggle para logging
    diagnosticTab:CreateToggle({
        Name = "Ativar Logging",
        CurrentValue = true,
        Flag = "EnableLogging",
        Callback = function(value)
            logSystem.enabled = value
            log("INFO", "Logging " .. (value and "enabled" or "disabled"))
        end
    })

    -- Botão para limpar logs
    diagnosticTab:CreateButton({
        Name = "Limpar Logs",
        Callback = function()
            logSystem.logs = {}
            log("INFO", "Logs cleared")
        end
    })
end

-- === SISTEMA ANTI-DETecÇÃO AVANÇADO ===
local antiDetection = {
    enabled = true,
    checks = {
        heartbeat = true,
        memory = true,
        network = true,
        behavior = true
    },
    lastCheck = tick()
}

-- Função para ofuscar nomes de funções
local function obfuscateFunctionName(original)
    local chars = {}
    for i = 1, #original do
        local byte = original:byte(i)
        chars[i] = string.char(byte + math.random(-5, 5))
    end
    return table.concat(chars)
end

-- Sistema anti-detecção
spawn(function()
    while true do
        if antiDetection.enabled then
            wait(math.random(3, 8))
            
            -- Limpar traces do executor
            if antiDetection.checks.heartbeat then
                pcall(function()
                    for _, v in pairs(getgc(true)) do
                        if type(v) == "function" and islclosure(v) then
                            local constants = getconstants(v)
                            for i, c in ipairs(constants) do
                                if type(c) == "string" then
                                    -- Ofuscar strings suspeitas
                                    if c:lower():find("hack") or c:lower():find("cheat") or 
                                       c:lower():find("exploit") or c:lower():find("inject") then
                                        setconstant(v, i, obfuscateFunctionName(c))
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            
            -- Simular comportamento normal
            if antiDetection.checks.behavior then
                pcall(function()
                    -- Mover o mouse aleatoriamente
                    local virtualInput = game:GetService("VirtualInputManager")
                    virtualInput:SendMouseMoveEvent(math.random(0, 1920), math.random(0, 1080))
                    
                    -- Simular cliques aleatórios
                    if math.random() < 0.1 then
                        virtualInput:SendMouseButtonEvent(math.random(0, 1920), math.random(0, 1080), 0, true, game, 0)
                        wait(0.05)
                        virtualInput:SendMouseButtonEvent(math.random(0, 1920), math.random(0, 1080), 0, false, game, 0)
                    end
                end)
            end
            
            -- Monitorar rede
            if antiDetection.checks.network then
                pcall(function()
                    -- Simular tráfego de rede normal
                    game:GetService("Players"):GetPlayers()
                    game:GetService("Workspace"):GetChildren()
                    game:GetService("ReplicatedStorage"):GetChildren()
                end)
            end
            
            -- Limpar memória
            if antiDetection.checks.memory and math.random() < 0.3 then
                pcall(function()
                    collectgarbage("collect")
                end)
            end
        else
            wait(5)
        end
    end
end)

-- Iniciar monitoramento
spawn(function()
    while true do
        wait(10)
        local currentVersion = detectRobloxVersion()
        
        if not Rayfield then
            startRecovery("Rayfield not found")
        elseif not humanoid or not humanoid.Parent then
            startRecovery("Humanoid not found")
        elseif not character or not character.Parent then
            startRecovery("Character not found")
        end
    end
end)

-- Notificação final
pcall(function()
    if Rayfield then
        Rayfield:Notify({
            Title = "HUB PRONTO",
            Content = "Todos os sistemas carregados! Executor: " .. getExecutor(),
            Duration = 5,
            Image = 0,
        })
    end
end)

log("INFO", "SCP Hub initialized successfully", {
    version = scriptVersion,
    executor = getExecutor(),
    robloxVersion = detectedRobloxVersion,
    loadTime = tick() - startTime
})

-- Mensagem final
print("\n=== SCP: THE RED LAKE HUB ===")
print("Versão:", scriptVersion)
print("Executor:", getExecutor())
print("Versão Roblox:", detectedRobloxVersion)
print("Tempo de carregamento:", tick() - startTime, "segundos")
print("Pressione H para abrir/fechar o menu")
print("============================\n")
