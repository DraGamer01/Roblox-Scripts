-- === SCP: THE RED LAKE ULTIMATE HUB ===
-- COM SISTEMA DE DIAGNÓSTICO AVANÇADO E LOGS
-- ===============================================

-- Sistema de arquivos e logs
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Sistema de logs
local logSystem = {
    enabled = true,
    logFolder = "SCP_HUB_LOGS",
    currentLogFile = nil,
    maxLogFiles = 10,
    maxLogSize = 1000000 -- 1MB por arquivo
}

-- Função para criar diretório de logs
local function ensureLogDirectory()
    if not isfolder(logSystem.logFolder) then
        makefolder(logSystem.logFolder)
    end
end

-- Função para criar novo arquivo de log
local function createNewLogFile()
    ensureLogDirectory()
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local fileName = logSystem.logFolder .. "/diagnostic_" .. timestamp .. ".txt"
    logSystem.currentLogFile = fileName
    
    -- Escrever cabeçalho do log
    local header = [[
=== SCP HUB DIAGNOSTIC LOG ===
Data: ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[
Versão Roblox: ]] .. game:GetService("RunService"):GetRobloxVersion() .. [[
Jogador: ]] .. player.Name .. [[
========================================

]]
    
    writefile(fileName, header)
    return fileName
end

-- Função para escrever no log
local function writeToLog(message)
    if not logSystem.enabled then return end
    
    if not logSystem.currentLogFile or not isfile(logSystem.currentLogFile) then
        createNewLogFile()
    end
    
    -- Verificar tamanho do arquivo
    local success, content = pcall(function()
        return readfile(logSystem.currentLogFile)
    end)
    
    if success and #content > logSystem.maxLogSize then
        createNewLogFile()
    end
    
    -- Adicionar timestamp e mensagem
    local logEntry = "[" .. os.date("%H:%M:%S") .. "] " .. message .. "\n"
    appendfile(logSystem.currentLogFile, logEntry)
    
    -- Também mostrar no console
    print("[SCP LOG] " .. message)
end

-- Limpar logs antigos
local function cleanOldLogs()
    ensureLogDirectory()
    local files = listfiles(logSystem.logFolder)
    
    -- Ordenar por data (mais recentes primeiro)
    table.sort(files, function(a, b)
        return a > b
    end)
    
    -- Manter apenas os logs mais recentes
    for i = logSystem.maxLogFiles + 1, #files do
        delfile(files[i])
    end
end

-- Inicializar sistema de logs
spawn(function()
    cleanOldLogs()
    createNewLogFile()
    writeToLog("Sistema de diagnóstico inicializado")
end)

-- Sistema de versões problemáticas
local problematicVersions = {
    ["2.591.568"] = {
        description = "Menu visual atualizado - God Mode instável",
        fix = "Usar método alternativo de God Mode com loop contínuo",
        priority = "high"
    },
    ["2.589.456"] = {
        description = "Mudança no sistema de armas",
        fix = "Procurar por 'WeaponStats' em vez de 'Configuration'",
        priority = "medium"
    },
    ["2.587.123"] = {
        description = "Alteração no sistema de Humanoid",
        fix = "Aumentar frequência de verificação para 3 segundos",
        priority = "medium"
    }
}

-- Sistema de detecção de versão
local detectedRobloxVersion = "Unknown"
local lastCheck = tick()
local detectedChanges = {}

local function detectRobloxVersion()
    local success, version = pcall(function()
        return game:GetService("RunService"):GetRobloxVersion()
    end)
    
    if success and version then
        writeToLog("Versão Roblox detectada: " .. version)
        
        if detectedRobloxVersion ~= version then
            detectedChanges[version] = {
                timestamp = tick(),
                changes = "Roblox version changed"
            }
            detectedRobloxVersion = version
            
            writeToLog("MUDANÇA DE VERSÃO DETECTADA")
            writeToLog("Versão anterior: Unknown")
            writeToLog("Versão atual: " .. version)
            
            -- Verificar se é uma versão problemática
            if problematicVersions[version] then
                local problem = problematicVersions[version]
                writeToLog("VERSÃO PROBLEMÁTICA IDENTIFICADA!")
                writeToLog("Problema: " .. problem.description)
                writeToLog("Solução: " .. problem.fix)
                writeToLog("Prioridade: " .. problem.priority)
            end
        end
        return version
    end
    return "Unknown"
end

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
    
    writeToLog("Iniciando recuperação automática. Razão: " .. reason)
    
    local function attemptRecovery()
        recoverySystem.attempts = recoverySystem.attempts + 1
        
        if recoverySystem.attempts > recoverySystem.maxAttempts then
            writeToLog("Falha na recuperação após " .. recoverySystem.maxAttempts .. " tentativas")
            recoverySystem.inRecovery = false
            return false
        end
        
        writeToLog("Tentativa de recuperação " .. recoverySystem.attempts .. " de " .. recoverySystem.maxAttempts)
        
        wait(recoverySystem.recoveryInterval)
        
        local success = false
        
        -- Recarregar Rayfield se necessário
        if not Rayfield then
            success, msg = pcall(function()
                Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
            end)
            
            if success then
                writeToLog("Rayfield recarregado com sucesso")
            else
                writeToLog("Falha ao recarregar Rayfield: " .. tostring(msg))
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
            writeToLog("Personagem e Humanoid recuperados")
        end
        
        if success then
            recoverySystem.inRecovery = false
            writeToLog("Recuperação concluída com sucesso")
            
            -- Reaplicar todas as modificações ativas
            reapplyModifications()
            return true
        else
            attemptRecovery()
        end
    end
    
    attemptRecovery()
end

-- Função para reaplicar todas as modificações
local function reapplyModifications()
    writeToLog("Reaplicando todas as modificações ativas")
    
    -- Reaplicar God Mode
    if godModeEnabled then
        pcall(enableGodMode)
    end
    
    -- Reaplicar velocidade e pulo
    if walkSpeedSlider and jumpPowerSlider then
        pcall(function()
            maintainModification(humanoid, "WalkSpeed", walkSpeedSlider.CurrentValue)
            maintainModification(humanoid, "JumpPower", jumpPowerSlider.CurrentValue)
        end)
    end
    
    -- Reaplicar Aimbot
    if aimbotEnabled then
        pcall(function()
            if aimbotConnection then aimbotConnection:Disconnect() end
            aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
            table.insert(connections, aimbotConnection)
        end)
    end
    
    -- Reaplicar Teleport
    if teleportEnabled then
        pcall(function()
            if teleportConnection then teleportConnection:Disconnect() end
            teleportConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onClickTeleport()
                end
            end)
            table.insert(connections, teleportConnection)
        end)
    end
end

-- Sistema de monitoramento contínuo
local function startMonitoring()
    spawn(function()
        while true do
            wait(5) -- Verificar a cada 5 segundos
            
            -- Detectar mudanças na versão
            local currentVersion = detectRobloxVersion()
            
            -- Verificar se componentes críticos ainda existem
            if not Rayfield then
                startRecovery("Rayfield não encontrado")
            elseif not humanoid or not humanoid.Parent then
                startRecovery("Humanoid não encontrado")
            elseif not character or not character.Parent then
                startRecovery("Personagem não encontrado")
            end
            
            -- Verificar se as modificações estão ativas
            if godModeEnabled and humanoid and humanoid.Health < godHealth * 0.9 then
                writeToLog("Detectada perda de God Mode, reaplicando...")
                pcall(enableGodMode)
            end
            
            if walkSpeedSlider and humanoid and humanoid.WalkSpeed ~= walkSpeedSlider.CurrentValue then
                writeToLog("Detectada perda de velocidade, reaplicando...")
                pcall(function()
                    maintainModification(humanoid, "WalkSpeed", walkSpeedSlider.CurrentValue)
                end)
            end
        end
    end)
end

-- Carregar Rayfield com sistema de fallback
local Rayfield
local success, msg = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    writeToLog("Falha ao carregar Rayfield: " .. tostring(msg))
    startRecovery("Falha inicial do Rayfield")
else
    Rayfield = success and Rayfield or nil
end

-- Sistema de fallback para criação da janela
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
    writeToLog("Falha ao criar janela: " .. tostring(msg))
    startRecovery("Falha na criação da janela")
else
    -- Atualizar o texto de carregamento com a versão detectada
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

-- Iniciar monitoramento
startMonitoring()

-- Robust persistence system
local connections = {}
local originalValues = {}
local activeLoops = {}

-- Modification function with constant verification
local function maintainModification(object, property, newValue)
    if not object or not object.Parent then 
        writeToLog("AVISO: Objeto inválido: " .. tostring(object))
        return 
    end
    
    -- Save original value
    if not originalValues[object] then
        originalValues[object] = {}
    end
    if originalValues[object][property] == nil then
        originalValues[object][property] = object[property]
    end
    
    -- Stop existing loop
    if activeLoops[object] and activeLoops[object][property] then
        activeLoops[object][property]:Disconnect()
    end
    
    -- Create new loop with additional verification
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if object and object.Parent then
            pcall(function()
                object[property] = newValue
            end)
        else
            connection:Disconnect()
            -- Try to find object again
            if property == "WalkSpeed" or property == "JumpPower" then
                local newHumanoid = character:FindFirstChildOfClass("Humanoid")
                if newHumanoid and newHumanoid ~= object then
                    writeToLog("Detectada mudança de Humanoid, atualizando...")
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
end

-- === CLICK TELEPORT SYSTEM ===
local teleportEnabled = false
local teleportConnection

local function teleportTo(position)
    if character and character.PrimaryPart then
        character:SetPrimaryPartCFrame(CFrame.new(position))
        pcall(function()
            Rayfield:Notify({
                Title = "TELETRANSPORTE",
                Content = "Teletransportado com sucesso!",
                Duration = 2,
                Image = 0,
            })
        end)
        writeToLog("Teletransporte executado para posição: " .. tostring(position))
    end
end

local function onClickTeleport()
    if not teleportEnabled then return end
    
    local mouse = player:GetMouse()
    if mouse.Target then
        local position = mouse.Hit.Position
        teleportTo(position)
    end
end

-- === AIMBOT SYSTEM ===
local aimbotEnabled = false
local aimbotConnection

local function findClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
            local targetCharacter = targetPlayer.Character
            local head = targetCharacter:FindFirstChild("Head")
            
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if onScreen and distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = targetPlayer
                end
            end
        end
    end
    
    return closestPlayer
end

local function updateAimbot()
    if not aimbotEnabled then return end
    
    local targetPlayer = findClosestPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local head = targetPlayer.Character.Head
        local directionVector = (head.Position - Camera.CFrame.Position).unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + directionVector)
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        aimbotEnabled = not aimbotEnabled
        pcall(function()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = aimbotEnabled and "ATIVADO (F)" or "DESATIVADO (F)",
                Duration = 2,
                Image = 0,
            })
        end)
        writeToLog("Aimbot " .. (aimbotEnabled and "ativado" or "desativado"))
    end
end)

-- === WEAPONS TAB ===
local weaponsTab = Window:CreateTab("Armas", 0)
local weaponsSection = weaponsTab:CreateSection("Modificação da G18")

local damageSlider = weaponsTab:CreateSlider({
    Name = "Dano",
    Range = {1, 100},
    Increment = 1,
    Suffix = "Dano",
    CurrentValue = 15,
    Flag = "Damage",
    Callback = function(v) end
})

local fireRateSlider = weaponsTab:CreateSlider({
    Name = "Cadência (RPM)",
    Range = {50, 1200},
    Increment = 10,
    Suffix = "RPM",
    CurrentValue = 400,
    Flag = "FireRate",
    Callback = function(v) end
})

local magazineSlider = weaponsTab:CreateSlider({
    Name = "Tamanho do Pente",
    Range = {1, 50},
    Increment = 1,
    Suffix = "Munição",
    CurrentValue = 17,
    Flag = "Magazine",
    Callback = function(v) end
})

weaponsTab:CreateButton({
    Name = "Aplicar Modificações da G18",
    Callback = function()
        local weapon = character:FindFirstChild("G18")
        if not weapon then
            pcall(function()
                Rayfield:Notify({
                    Title = "ERRO",
                    Content = "Equipe a G18 primeiro!",
                    Duration = 3,
                    Image = 0,
                })
            end)
            writeToLog("ERRO: G18 não equipada")
            return
        end
        
        local modificationsApplied = 0
        writeToLog("Aplicando modificações na G18")
        
        local pathsToTest = {
            "Configuration",
            "GunStats",
            "Values",
            "Stats",
            ""
        }
        
        for _, path in pairs(pathsToTest) do
            local config = path ~= "" and weapon:FindFirstChild(path) or weapon
            
            if config then
                if config:FindFirstChild("Damage") then
                    maintainModification(config.Damage, "Value", damageSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
                    writeToLog("Dano modificado: " .. damageSlider.CurrentValue)
                end
                
                if config:FindFirstChild("FireRate") then
                    maintainModification(config.FireRate, "Value", 60 / fireRateSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
                    writeToLog("Cadência modificada: " .. fireRateSlider.CurrentValue .. " RPM")
                end
                
                if config:FindFirstChild("MagazineSize") then
                    maintainModification(config.MagazineSize, "Value", magazineSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
                    writeToLog("Pente modificado: " .. magazineSlider.CurrentValue)
                elseif config:FindFirstChild("Ammo") then
                    maintainModification(config.Ammo, "Value", magazineSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
                    writeToLog("Munição modificada: " .. magazineSlider.CurrentValue)
                end
            end
        end
        
        pcall(function()
            Rayfield:Notify({
                Title = "RESULTADO",
                Content = modificationsApplied .. " modificações aplicadas!",
                Duration = 3,
                Image = 0,
            })
        end)
        
        writeToLog("Total de modificações aplicadas: " .. modificationsApplied)
        
        if modificationsApplied == 0 then
            runDiagnostics()
        end
    end
})

weaponsTab:CreateSection("Aimbot")

weaponsTab:CreateToggle({
    Name = "Ativar Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(value)
        aimbotEnabled = value
        if aimbotEnabled then
            aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
            table.insert(connections, aimbotConnection)
            pcall(function()
                Rayfield:Notify({
                    Title = "Aimbot ATIVADO",
                    Content = "Use F para alternar",
                    Duration = 3,
                    Image = 0,
                })
            end)
        else
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
            pcall(function()
                Rayfield:Notify({
                    Title = "Aimbot DESATIVADO",
                    Content = "Aimbot desativado",
                    Duration = 3,
                    Image = 0,
                })
            end)
        end
    end
})

weaponsTab:CreateParagraph({
    Title = "Controles",
    Content = "Pressione F para ativar/desativar rapidamente"
})

-- === MOVEMENT TAB ===
local movementTab = Window:CreateTab("Movimento", 0)
local movementSection = movementTab:CreateSection("Modificação de Movimento")

local walkSpeedSlider = movementTab:CreateSlider({
    Name = "Velocidade de Caminhada",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "Studs/s",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v) end
})

local jumpPowerSlider = movementTab:CreateSlider({
    Name = "Força do Pulo",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "Força",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v) end
})

movementTab:CreateButton({
    Name = "Aplicar Modificações de Movimento",
    Callback = function()
        if humanoid then
            maintainModification(humanoid, "WalkSpeed", walkSpeedSlider.CurrentValue)
            maintainModification(humanoid, "JumpPower", jumpPowerSlider.CurrentValue)
            
            pcall(function()
                Rayfield:Notify({
                    Title = "SUCESSO",
                    Content = "Modificações aplicadas!",
                    Duration = 3,
                    Image = 0,
                })
            end)
            
            writeToLog("Velocidade: " .. walkSpeedSlider.CurrentValue .. ", Pulo: " .. jumpPowerSlider.CurrentValue)
        end
    end
})

movementTab:CreateSection("Teletransporte por Clique")

movementTab:CreateToggle({
    Name = "Ativar Teletransporte",
    CurrentValue = false,
    Flag = "Teleport",
    Callback = function(value)
        teleportEnabled = value
        if teleportEnabled then
            teleportConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onClickTeleport()
                end
            end)
            table.insert(connections, teleportConnection)
            pcall(function()
                Rayfield:Notify({
                    Title = "TELETRANSPORTE ATIVADO",
                    Content = "Clique para teletransportar!",
                    Duration = 3,
                    Image = 0,
                })
            end)
        else
            if teleportConnection then
                teleportConnection:Disconnect()
                teleportConnection = nil
            end
            pcall(function()
                Rayfield:Notify({
                    Title = "TELETRANSPORTE DESATIVADO",
                    Content = "Teletransporte desativado",
                    Duration = 3,
                    Image = 0,
                })
            end)
        end
    end
})

movementTab:CreateParagraph({
    Title = "Como usar",
    Content = "Ative o teletransporte e clique em qualquer lugar para se teletransportar"
})

-- === PLAYER TAB ===
local playerTab = Window:CreateTab("Jogador", 0)
local playerSection = playerTab:CreateSection("Modificações do Jogador")

-- God Mode variables
local godModeEnabled = false
local godModeConnection
local godHealth = 1e9

local function enableGodMode()
    writeToLog("Ativando God Mode")
    
    if humanoid then
        maintainModification(humanoid, "MaxHealth", godHealth)
        maintainModification(humanoid, "Health", godHealth)
        writeToLog("God Mode aplicado ao Humanoid")
    end
    
    -- Search for other health systems
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            if string.find(string.lower(obj.Name), "health") or 
               string.find(string.lower(obj.Name), "hp") or
               string.find(string.lower(obj.Name), "vida") then
                maintainModification(obj, "Value", godHealth)
                writeToLog("God Mode aplicado a valor alternativo: " .. obj.Name)
            end
        end
    end
    
    -- Block death
    godModeConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Dead then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            if humanoid then
                humanoid.Health = godHealth
            end
            writeToLog("Morte bloqueada e vida restaurada")
        end
    end)
    
    table.insert(connections, godModeConnection)
    
    pcall(function()
        Rayfield:Notify({
            Title = "GOD MODE ATIVADO",
            Content = "Imortalidade ativada!",
            Duration = 3,
            Image = 0,
        })
    end)
end

local function disableGodMode()
    writeToLog("Desativando God Mode")
    
    if godModeConnection then
        godModeConnection:Disconnect()
        godModeConnection = nil
    end
    
    -- Restore original values
    if humanoid and originalValues[humanoid] then
        if originalValues[humanoid].MaxHealth then
            humanoid.MaxHealth = originalValues[humanoid].MaxHealth
        end
        if originalValues[humanoid].Health then
            humanoid.Health = originalValues[humanoid].Health
        end
    end
    
    pcall(function()
        Rayfield:Notify({
            Title = "GOD MODE DESATIVADO",
            Content = "Imortalidade desativada",
            Duration = 3,
            Image = 0,
        })
    end)
end

playerTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(value)
        godModeEnabled = value
        if godModeEnabled then
            enableGodMode()
        else
            disableGodMode()
        end
    end
})

-- === DIAGNOSTICS TAB ===
local diagnosticsTab = Window:CreateTab("Diagnóstico", 0)
local diagnosticsSection = diagnosticsTab:CreateSection("Ferramentas de Diagnóstico")

diagnosticsTab:CreateButton({
    Name = "Rodar Diagnóstico Completo",
    Callback = function()
        runDiagnostics()
        pcall(function()
            Rayfield:Notify({
                Title = "DIAGNÓSTICO",
                Content = "Verifique o console (F9) e os arquivos de log",
                Duration = 3,
                Image = 0,
            })
        end)
    end
})

diagnosticsTab:CreateButton({
    Name = "Limpar Logs Antigos",
    Callback = function()
        cleanOldLogs()
        pcall(function()
            Rayfield:Notify({
                Title = "LIMPEZA",
                Content = "Logs antigos removidos",
                Duration = 3,
                Image = 0,
            })
        end)
        writeToLog("Logs antigos limpos pelo usuário")
    end
})

diagnosticsTab:CreateButton({
    Name = "Ver Versões Detectadas",
    Callback = function()
        writeToLog("=== HISTÓRICO DE VERSÕES DETECTADAS ===")
        for version, data in pairs(detectedChanges) do
            writeToLog("Versão: " .. version .. " em " .. os.date("%Y-%m-%d %H:%M:%S", data.timestamp))
            writeToLog("Mudanças: " .. data.changes)
            writeToLog("---")
        end
        
        pcall(function()
            Rayfield:Notify({
                Title = "VERSÕES",
                Content = "Histórico salvo nos logs",
                Duration = 3,
                Image = 0,
            })
        end)
    end
})

diagnosticsTab:CreateSection("Informações do Sistema")

diagnosticsTab:CreateParagraph({
    Title = "Local dos Logs",
    Content = "Pasta: " .. logSystem.logFolder .. "\nOs logs são salvos automaticamente"
})

diagnosticsTab:CreateParagraph({
    Title = "Versão Atual",
    Content = "Roblox: " .. detectedRobloxVersion .. "\nDetectada em: " .. os.date("%Y-%m-%d %H:%M:%S")
})

diagnosticsTab:CreateParagraph({
    Title = "Status do Sistema",
    Content = "Logs: " .. (logSystem.enabled and "ATIVADOS" or "DESATIVADOS") .. "\nArquivo atual: " .. (logSystem.currentLogFile or "Nenhum")
})

-- Death persistence system
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
    writeToLog("RESPAWN DETECTADO - Reaplicando modificações")
    
    pcall(function()
        Rayfield:Notify({
            Title = "RESPAWN DETECTADO",
            Content = "Reaplicando modificações...",
            Duration = 3,
            Image = 0,
        })
    end)
    
    wait(1)
    
    -- Reapply movement
    maintainModification(humanoid, "WalkSpeed", walkSpeedSlider.CurrentValue)
    maintainModification(humanoid, "JumpPower", jumpPowerSlider.CurrentValue)
    
    -- Reapply God Mode
    if godModeEnabled then
        enableGodMode()
    end
    
    -- Reapply Aimbot
    if aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
        table.insert(connections, aimbotConnection)
    end
    
    -- Reapply Teleport
    if teleportEnabled then
        teleportConnection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                onClickTeleport()
            end
        end)
        table.insert(connections, teleportConnection)
    end
end)

-- Unload button
playerTab:CreateButton({
    Name = "DESCARREGAR SCRIPT",
    Callback = function()
        writeToLog("SCRIPT SENDO DESCARREGADO PELO USUÁRIO")
        
        pcall(function()
            Rayfield:Notify({
                Title = "DESCARREGANDO...",
                Content = "Removendo todas as modificações",
                Duration = 3,
                Image = 0,
            })
        end)
        
        -- Disable everything
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        
        if godModeConnection then
            godModeConnection:Disconnect()
            godModeConnection = nil
        end
        
        if teleportConnection then
            teleportConnection:Disconnect()
            teleportConnection = nil
        end
        
        -- Disconnect all connections
        for _, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        -- Restore original values
        for object, values in pairs(originalValues) do
            if object and object.Parent then
                for property, originalValue in pairs(values) do
                    pcall(function()
                        object[property] = originalValue
                    end)
                end
            end
        end
        
        -- Clear variables
        connections = {}
        originalValues = {}
        activeLoops = {}
        
        -- Close Rayfield
        pcall(function()
            Rayfield:Destroy()
        end)
        
        writeToLog("Todas as modificações removidas")
        writeToLog("Script completamente descarregado")
        
        pcall(function()
            Rayfield:Notify({
                Title = "SCRIPT DESCARREGADO",
                Content = "Todas as modificações removidas",
                Duration = 5,
                Image = 0,
            })
        end)
    end
})

-- Final notification
pcall(function()
    Rayfield:Notify({
        Title = "HUB PRONTO",
        Content = "Todos os sistemas carregados!",
        Duration = 3,
        Image = 0,
    })
end)

writeToLog("SCP Hub inicializado com sucesso")
