-- === SCP: THE RED LAKE ULTIMATE HUB ===
-- ENGLISH SCRIPT WITH PORTUGUESE VISUAL ELEMENTS
-- ===============================================

-- Roblox update detection system
local detectedRobloxVersion = "Unknown"
local lastCheck = tick()
local detectedChanges = {}

-- Function to detect Roblox version
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
            warn("[SCP HUB] Roblox version detected:", version)
        end
        return version
    end
    return "Unknown"
end

-- Auto-recovery system
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
    
    warn("[SCP HUB] Starting auto-recovery. Reason:", reason)
    
    local function attemptRecovery()
        recoverySystem.attempts = recoverySystem.attempts + 1
        
        if recoverySystem.attempts > recoverySystem.maxAttempts then
            warn("[SCP HUB] Recovery failed after", recoverySystem.maxAttempts, "attempts")
            recoverySystem.inRecovery = false
            return false
        end
        
        warn("[SCP HUB] Recovery attempt", recoverySystem.attempts, "of", recoverySystem.maxAttempts)
        
        -- Wait before next attempt
        wait(recoverySystem.recoveryInterval)
        
        -- Try to reload critical components
        local success = false
        
        -- Reload Rayfield if needed
        if not Rayfield then
            success, msg = pcall(function()
                Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
            end)
            
            if success then
                warn("[SCP HUB] Rayfield reloaded successfully")
            else
                warn("[SCP HUB] Failed to reload Rayfield:", msg)
            end
        end
        
        -- Check if character is accessible
        if not player.Character then
            player.CharacterAdded:Wait()
        end
        
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:WaitForChild("Humanoid", 5)
        
        if humanoid then
            success = true
            warn("[SCP HUB] Character and Humanoid recovered")
        end
        
        if success then
            recoverySystem.inRecovery = false
            warn("[SCP HUB] Recovery completed successfully")
            
            -- Reapply all active modifications
            reapplyModifications()
            return true
        else
            -- Try again
            attemptRecovery()
        end
    end
    
    attemptRecovery()
end

-- Function to reapply all modifications
local function reapplyModifications()
    warn("[SCP HUB] Reapplying all active modifications")
    
    -- Reapply God Mode
    if godModeEnabled then
        pcall(enableGodMode)
    end
    
    -- Reapply speed and jump
    if walkSpeedSlider and jumpPowerSlider then
        pcall(function()
            maintainModification(humanoid, "WalkSpeed", walkSpeedSlider.CurrentValue)
            maintainModification(humanoid, "JumpPower", jumpPowerSlider.CurrentValue)
        end)
    end
    
    -- Reapply Aimbot
    if aimbotEnabled then
        pcall(function()
            if aimbotConnection then aimbotConnection:Disconnect() end
            aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
            table.insert(connections, aimbotConnection)
        end)
    end
    
    -- Reapply Teleport
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

-- Continuous monitoring system
local function startMonitoring()
    spawn(function()
        while true do
            wait(5) -- Check every 5 seconds
            
            -- Detect version changes
            local currentVersion = detectRobloxVersion()
            
            -- Check if critical components still exist
            if not Rayfield then
                startRecovery("Rayfield not found")
            elseif not humanoid or not humanoid.Parent then
                startRecovery("Humanoid not found")
            elseif not character or not character.Parent then
                startRecovery("Character not found")
            end
            
            -- Check if modifications are active
            if godModeEnabled and humanoid and humanoid.Health < godHealth * 0.9 then
                warn("[SCP HUB] God Mode lost detected, reapplying...")
                pcall(enableGodMode)
            end
            
            if walkSpeedSlider and humanoid and humanoid.WalkSpeed ~= walkSpeedSlider.CurrentValue then
                warn("[SCP HUB] Speed loss detected, reapplying...")
                pcall(function()
                    maintainModification(humanoid, "WalkSpeed", walkSpeedSlider.CurrentValue)
                end)
            end
        end
    end)
end

-- Load Rayfield with fallback system
local Rayfield
local success, msg = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success then
    warn("[ERROR] Failed to load Rayfield:", msg)
    startRecovery("Initial Rayfield failure")
else
    Rayfield = success and Rayfield or nil
end

-- Fallback system for window creation
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
    warn("[ERROR] Failed to create window:", msg)
    startRecovery("Window creation failure")
else
    -- Update loading text with detected version
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

-- Start monitoring
startMonitoring()

-- Global variables with verification system
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Robust persistence system
local connections = {}
local originalValues = {}
local activeLoops = {}

-- Modification function with constant verification
local function maintainModification(object, property, newValue)
    if not object or not object.Parent then 
        warn("[WARNING] Invalid object:", object)
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
                    warn("[SCP HUB] Humanoid change detected, updating...")
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

-- Function to find closest player
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

-- Aimbot update function
local function updateAimbot()
    if not aimbotEnabled then return end
    
    local targetPlayer = findClosestPlayer()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local head = targetPlayer.Character.Head
        local directionVector = (head.Position - Camera.CFrame.Position).unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + directionVector)
    end
end

-- Aimbot control with F key
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
    end
end)

-- === WEAPONS TAB ===
local weaponsTab = Window:CreateTab("Armas", 0)
local weaponsSection = weaponsTab:CreateSection("Modificação da G18")

-- Sliders
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

-- Apply button with diagnostics
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
            return
        end
        
        local modificationsApplied = 0
        
        -- Try multiple paths to find values
        local pathsToTest = {
            "Configuration",
            "GunStats",
            "Values",
            "Stats",
            "" -- Weapon root
        }
        
        for _, path in pairs(pathsToTest) do
            local config = path ~= "" and weapon:FindFirstChild(path) or weapon
            
            if config then
                -- Test damage
                if config:FindFirstChild("Damage") then
                    maintainModification(config.Damage, "Value", damageSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
                end
                
                -- Test fire rate
                if config:FindFirstChild("FireRate") then
                    maintainModification(config.FireRate, "Value", 60 / fireRateSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
                end
                
                -- Test magazine
                if config:FindFirstChild("MagazineSize") then
                    maintainModification(config.MagazineSize, "Value", magazineSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
                elseif config:FindFirstChild("Ammo") then
                    maintainModification(config.Ammo, "Value", magazineSlider.CurrentValue)
                    modificationsApplied = modificationsApplied + 1
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
        
        if modificationsApplied == 0 then
            runDiagnostics()
        end
    end
})

-- Aimbot section
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

-- Apply movement button
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
        end
    end
})

-- Teleport section
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

-- Improved God Mode
local godModeEnabled = false
local godModeConnection
local godHealth = 1e9

local function enableGodMode()
    -- Modify Humanoid
    if humanoid then
        maintainModification(humanoid, "MaxHealth", godHealth)
        maintainModification(humanoid, "Health", godHealth)
    end
    
    -- Search for other health systems
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            if string.find(string.lower(obj.Name), "health") or 
               string.find(string.lower(obj.Name), "hp") or
               string.find(string.lower(obj.Name), "vida") then
                maintainModification(obj, "Value", godHealth)
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

-- Diagnostics button
playerTab:CreateButton({
    Name = "Rodar Diagnóstico",
    Callback = function()
        runDiagnostics()
        pcall(function()
            Rayfield:Notify({
                Title = "DIAGNÓSTICO",
                Content = "Verifique o console (F9) para resultados",
                Duration = 3,
                Image = 0,
            })
        end)
    end
})

-- Death persistence system
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
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
