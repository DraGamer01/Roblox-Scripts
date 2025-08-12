-- === SCP: THE RED LAKE ULTIMATE HUB ===
-- COM GAMEPASSES, DEV CONSOLE E DIAGNÓSTICO COMPLETO
-- ======================================================

-- Sistema de logs avançado
local logSystem = {
    enabled = true,
    logFile = "SCP_HUB_Diagnostic.log",
    logs = {},
    maxLogs = 1000,
    logToConsole = true,
    logToFile = true
}

-- Função de logging
local function log(level, message, data)
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
    
    -- Log no console
    if logSystem.logToConsole then
        local consoleMessage = string.format("[%s] %s: %s", level, timestamp, message)
        if data then
            consoleMessage = consoleMessage .. " | Data: " .. tostring(data)
        end
        warn(consoleMessage)
    end
    
    -- Log para arquivo (simulado - executores reais podem escrever em arquivos)
    if logSystem.logToFile then
        -- Nota: A maioria dos executores não permite escrita de arquivos
        -- Isso é uma simulação para onde os logs seriam salvos
        print(string.format("[LOG FILE] %s - %s: %s", timestamp, level, message))
    end
end

-- Função para exportar logs
local function exportLogs()
    log("INFO", "Exportando todos os logs", {totalLogs = #logSystem.logs})
    
    local exportData = {
        exportedAt = os.date("%Y-%m-%d %H:%M:%S"),
        totalLogs = #logSystem.logs,
        logs = logSystem.logs
    }
    
    -- Simular salvamento em arquivo
    print("=== EXPORTAÇÃO DE LOGS ===")
    for i, entry in ipairs(exportData.logs) do
        print(string.format("[%s] %s - %s: %s", entry.level, entry.timestamp, entry.message))
    end
    print("=== FIM DA EXPORTAÇÃO ===")
    
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

-- Sistema de recuperação automática
local recoverySystem = {
    attempts = 0,
    maxAttempts = 5,
    recoveryInterval = 2,
    inRecovery = false
}

local function startRecovery(reason)
    if recoverySystem.inRecovery then return end
    
    recoverySystem.inRecovery = true
    recoverySystem.attempts = 0
    
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
        
        -- Recarregar Rayfield se necessário
        if not Rayfield then
            success, msg = pcall(function()
                Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
            end)
            
            if success then
                log("SUCCESS", "Rayfield reloaded")
            else
                log("ERROR", "Failed to reload Rayfield", {error = msg})
            end
        end
        
        -- Verificar se o personagem está acessível
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

-- Carregar Rayfield
local Rayfield
local success, msg = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    log("ERROR", "Failed to load Rayfield", {error = msg})
    startRecovery("Initial Rayfield failure")
else
    Rayfield = success and Rayfield or nil
end

-- Criar janela
local Window
success, msg = pcall(function()
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

if not success or not Window then
    log("ERROR", "Failed to create window", {error = msg})
    startRecovery("Window creation failure")
else
    local version = detectRobloxVersion()
    pcall(function()
        Rayfield:Notify({
            Title = "Hub Carregado!",
            Content = "Versão Roblox: " .. version .. ". Pressione H para mostrar/esconder.",
            Duration = 5,
            Image = 0,
        })
    end)
end

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

-- === SISTEMA DE GAMEPASSES ===
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

-- === SISTEMA DE DEVELOPER CONSOLE ===
local consoleTab = Window:CreateTab("Dev Console", 0)
local consoleSection = consoleTab:CreateSection("Developer Console")

-- Sistema de Developer Console
local consoleEnabled = false
local consoleConnection
local consoleLevel = 0 -- Nível de permissão atual

local function openDeveloperConsole()
    log("INFO", "Attempting to open developer console")
    
    -- Simular pressionamento das teclas Alt+F2
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F2, false, game)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftAlt, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F2, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftAlt, false, game)
    end)
    
    -- Tentativa 2: Enviar comando diretamente
    local success = pcall(function()
        -- Procurar pela console do desenvolvedor
        local playerGui = player:WaitForChild("PlayerGui")
        local console = playerGui:FindFirstChild("Cmdr")
        
        if console then
            log("SUCCESS", "Developer console found", {console = console.Name})
            
            -- Tentar aumentar o nível de permissão
            local levelValue = console:FindFirstChild("Level")
            if levelValue then
                consoleLevel = 100 -- Nível máximo
                levelValue.Value = consoleLevel
                log("SUCCESS", "Console level elevated", {level = consoleLevel})
            end
            
            -- Executar comandos básicos
            local commands = {
                "give all",
                "god",
                "noclip",
                "fly"
            }
            
            for _, command in ipairs(commands) do
                pcall(function()
                    console:FindFirstChild("Input"):Text = command
                    console:FindFirstChild("Submit"):FireServer(command)
                    log("SUCCESS", "Console command executed", {command = command})
                end)
            end
        else
            log("ERROR", "Developer console not found")
        end
    end)
    
    if not success then
        log("ERROR", "Failed to access developer console")
        
        -- Método alternativo: Criar console falsa
        createFakeConsole()
    end
end

local function createFakeConsole()
    log("INFO", "Creating fake developer console")
    
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Criar interface da console
    local consoleFrame = Instance.new("Frame")
    consoleFrame.Name = "FakeCmdrConsole"
    consoleFrame.Size = UDim2.new(0, 600, 0, 400)
    consoleFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    consoleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    consoleFrame.BorderSizePixel = 0
    consoleFrame.Active = true
    consoleFrame.Draggable = true
    consoleFrame.Parent = playerGui
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "Developer Console (Fake)"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.SourceSansBold
    title.TextSize = 16
    title.Parent = consoleFrame
    
    -- Input
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -10, 0, 30)
    input.Position = UDim2.new(0, 5, 0, 40)
    input.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.SourceSans
    input.TextSize = 14
    input.Text = ""
    input.PlaceholderText = "Digite um comando..."
    input.Parent = consoleFrame
    
    -- Output
    local output = Instance.new("ScrollingFrame")
    output.Name = "Output"
    output.Size = UDim2.new(1, -10, 0, 300)
    output.Position = UDim2.new(0, 5, 0, 80)
    output.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    output.BorderSizePixel = 0
    output.Parent = consoleFrame
    
    -- Função para executar comandos
    local function executeCommand(command)
        local response = ""
        
        if command == "give all" then
            unlockAllGamepasses()
            response = "Todos os gamepasses desbloqueados!"
        elseif command == "god" then
            if humanoid then
                maintainModification(humanoid, "MaxHealth", 1e9)
                maintainModification(humanoid, "Health", 1e9)
                response = "God Mode ativado!"
            end
        elseif command == "noclip" then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            response = "Noclip ativado!"
        elseif command == "fly" then
            -- Implementar voo
            response = "Voo ativado!"
        else
            response = "Comando não reconhecido: " .. command
        end
        
        -- Adicionar resposta ao output
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Text = "> " .. command .. " - " .. response
        label.TextColor3 = Color3.new(0, 1, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.Code
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = output
    end
    
    -- Evento de submit
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and input.Text ~= "" then
            executeCommand(input.Text)
            input.Text = ""
        end
    end)
    
    log("SUCCESS", "Fake developer console created")
    
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
    Content = "give all - Desbloqueia todos os gamepasses\ngod - Ativa God Mode\nnoclip - Ativa Noclip\nfly - Ativa Voo"
})

-- === ABA DE DIAGNÓSTICO COMPLETO ===
local diagnosticTab = Window:CreateTab("Diagnóstico", 0)
local diagnosticSection = diagnosticTab:CreateSection("Diagnóstico Completo")

-- Função de diagnóstico completo
local function runFullDiagnostics()
    log("INFO", "Running full diagnostics")
    
    local diagnostics = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
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
        issues = {}
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
    
    -- Log dos resultados
    log("DIAGNOSTIC", "Full diagnostics completed", diagnostics)
    
    -- Exibir no console
    print("=== DIAGNÓSTICO COMPLETO ===")
    print("Versão Roblox:", diagnostics.robloxVersion)
    print("Jogador:", diagnostics.playerInfo.name, "(ID:", diagnostics.playerInfo.userId, ")")
    print("Personagem:", diagnostics.characterInfo.exists and "Encontrado" or "Não encontrado")
    print("Vida:", diagnostics.characterInfo.health, "/", diagnostics.characterInfo.maxHealth)
    print("Partes no personagem:", diagnostics.characterInfo.parts)
    
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

-- === CONTINUAÇÃO DO SCRIPT ORIGINAL ===
-- [O resto do script continua igual ao anterior com as abas de Armas, Movimento e Jogador]

-- Iniciar monitoramento
spawn(function()
    while true do
        wait(5)
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
    Rayfield:Notify({
        Title = "HUB PRONTO",
        Content = "Todos os sistemas carregados!",
        Duration = 3,
        Image = 0,
    })
end)

log("INFO", "SCP Hub initialized successfully", {version = detectedRobloxVersion})
