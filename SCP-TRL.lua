-- === SCP: THE RED LAKE ULTIMATE HUB ===
-- USANDO RAYFIELD UI COM TEMA SERENITY E TECLA H
-- ================================================

-- Carregar Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Criar janela principal com tema Serenity
local Window = Rayfield:CreateWindow({
    Name = "SCP: The Red Lake Hub",
    Icon = 4483345998, -- Ícone do Roblox
    LoadingTitle = "Carregando Hub...",
    LoadingSubtitle = "Aguarde...",
    ShowText = "SCP Hub",
    Theme = "Serenity", -- Tema aplicado corretamente aqui
    ToggleUIKeybind = "H", -- Tecla para mostrar/esconder a UI (ALTERADO PARA H)
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
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

-- Notificações do sistema
Rayfield:Notify({
    Title = "Hub Carregado!",
    Content = "Use apenas em servidores privados! Pressione H para mostrar/esconder",
    Duration = 6.5,
    Image = 4483345998,
    Actions = {
        Ignore = {
            Name = "Ok",
            Callback = function()
            end
        },
    },
})

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Sistema de persistência
local connections = {}
local originalValues = {}
local activeLoops = {}

-- Função para manter modificações
local function keepModifying(targetObject, valueName, newValue)
    if not targetObject or not targetObject.Parent then return end
    
    if not originalValues[targetObject] then
        originalValues[targetObject] = {}
    end
    if originalValues[targetObject][valueName] == nil then
        originalValues[targetObject][valueName] = targetObject[valueName]
    end
    
    if activeLoops[targetObject] and activeLoops[targetObject][valueName] then
        activeLoops[targetObject][valueName]:Disconnect()
    end
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if targetObject and targetObject.Parent then
            pcall(function()
                targetObject[valueName] = newValue
            end)
        else
            connection:Disconnect()
        end
    end)
    
    if not activeLoops[targetObject] then
        activeLoops[targetObject] = {}
    end
    activeLoops[targetObject][valueName] = connection
    table.insert(connections, connection)
end

-- === AIMBOT INTEGRADO ===
local aimbotEnabled = false
local aimbotConnection

-- Função do Aimbot
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
            local targetCharacter = targetPlayer.Character
            local targetHead = targetCharacter:FindFirstChild("Head")
            
            if targetHead then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetHead.Position)
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
    
    local closestPlayer = getClosestPlayer()
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        local targetHead = closestPlayer.Character.Head
        local lookVector = (targetHead.Position - Camera.CFrame.Position).unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
    end
end

-- Controle do Aimbot com tecla F
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        aimbotEnabled = not aimbotEnabled
        Rayfield:Notify({
            Title = "Aimbot",
            Content = aimbotEnabled and "Ativado (F)" or "Desativado (F)",
            Duration = 3,
            Image = 4483345998,
        })
    end
end)

-- === ABA: ARMAS ===
local WeaponTab = Window:CreateTab("Armas", 4483345998)

-- Seção da G18
local WeaponSection = WeaponTab:CreateSection("Modificação da G18")

-- Sliders para armas
local DamageSlider = WeaponTab:CreateSlider({
    Name = "Dano",
    Range = {1, 100},
    Increment = 1,
    Suffix = "Dano",
    CurrentValue = 15,
    Flag = "Damage",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

local FireRateSlider = WeaponTab:CreateSlider({
    Name = "Cadência (RPM)",
    Range = {50, 1200},
    Increment = 10,
    Suffix = "RPM",
    CurrentValue = 400,
    Flag = "FireRate",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

local MagazineSlider = WeaponTab:CreateSlider({
    Name = "Tamanho do Pente",
    Range = {1, 50},
    Increment = 1,
    Suffix = "Munição",
    CurrentValue = 17,
    Flag = "Magazine",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

local RecoilSlider = WeaponTab:CreateSlider({
    Name = "Recuo",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "Recuo",
    CurrentValue = 0.8,
    Flag = "Recoil",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

local ReloadSlider = WeaponTab:CreateSlider({
    Name = "Tempo de Recarga",
    Range = {0.1, 10},
    Increment = 0.1,
    Suffix = "Segundos",
    CurrentValue = 2.2,
    Flag = "ReloadTime",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

-- Botão de aplicar modificações de arma
WeaponTab:CreateButton({
    Name = "Aplicar Modificações da G18",
    Callback = function()
        local gun = character:FindFirstChild("G18")
        if not gun then
            Rayfield:Notify({
                Title = "Erro!",
                Content = "Equipe a G18 primeiro!",
                Duration = 3,
                Image = 4483345998,
            })
            return
        end
        
        local config = gun:FindFirstChild("Configuration") or gun:FindFirstChild("GunStats") or gun
        local applied = 0
        
        if config:FindFirstChild("Damage") then
            keepModifying(config.Damage, "Value", DamageSlider.CurrentValue)
            applied = applied + 1
        end
        
        if config:FindFirstChild("FireRate") then
            keepModifying(config.FireRate, "Value", 60 / FireRateSlider.CurrentValue)
            applied = applied + 1
        end
        
        if config:FindFirstChild("MagazineSize") or config:FindFirstChild("Ammo") then
            local mag = config:FindFirstChild("MagazineSize") or config:FindFirstChild("Ammo")
            keepModifying(mag, "Value", MagazineSlider.CurrentValue)
            applied = applied + 1
        end
        
        if config:FindFirstChild("Recoil") then
            keepModifying(config.Recoil, "Value", RecoilSlider.CurrentValue)
            applied = applied + 1
        end
        
        if config:FindFirstChild("ReloadTime") then
            keepModifying(config.ReloadTime, "Value", ReloadSlider.CurrentValue)
            applied = applied + 1
        end
        
        Rayfield:Notify({
            Title = "Sucesso!",
            Content = "Aplicadas " .. applied .. " modificações!",
            Duration = 3,
            Image = 4483345998,
        })
    end,
})

-- Seção do Aimbot
local AimbotSection = WeaponTab:CreateSection("Aimbot")

-- Toggle do Aimbot
WeaponTab:CreateToggle({
    Name = "Ativar Aimbot",
    CurrentValue = false,
    Flag = "AimbotToggle",
    Callback = function(Value)
        aimbotEnabled = Value
        if aimbotEnabled then
            aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
            table.insert(connections, aimbotConnection)
            Rayfield:Notify({
                Title = "Aimbot Ativado!",
                Content = "Use F ou o toggle para desativar",
                Duration = 3,
                Image = 4483345998,
            })
        else
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
            Rayfield:Notify({
                Title = "Aimbot Desativado!",
                Content = "Aimbot desativado",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end,
})

WeaponTab:CreateParagraph({
    Title = "Controles",
    Content = "Pressione F para ativar/desativar rapidamente"
})

-- === ABA: MOVIMENTO ===
local MovementTab = Window:CreateTab("Movimento", 4483345998)

local MovementSection = MovementTab:CreateSection("Modificação de Movimento")

local WalkSpeedSlider = MovementTab:CreateSlider({
    Name = "Velocidade de Caminhada",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "Studs/s",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

local JumpPowerSlider = MovementTab:CreateSlider({
    Name = "Força do Pulo",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "Força",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

local FlySpeedSlider = MovementTab:CreateSlider({
    Name = "Velocidade de Voo",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "Studs/s",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value)
        -- Será aplicado no botão
    end,
})

-- Botão de aplicar movimento
MovementTab:CreateButton({
    Name = "Aplicar Modificações de Movimento",
    Callback = function()
        keepModifying(humanoid, "WalkSpeed", WalkSpeedSlider.CurrentValue)
        keepModifying(humanoid, "JumpPower", JumpPowerSlider.CurrentValue)
        
        Rayfield:Notify({
            Title = "Sucesso!",
            Content = "Modificações de movimento aplicadas!",
            Duration = 3,
            Image = 4483345998,
        })
    end,
})

-- Sistema de Voo
local flyEnabled = false
local flyConnection
local flyVelocity, flyGyro

local function enableFly()
    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    
    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyVelocity.P = 5000
    flyVelocity.Parent = character.PrimaryPart
    
    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyGyro.P = 5000
    flyGyro.Parent = character.PrimaryPart
    
    flyConnection = RunService.Heartbeat:Connect(function()
        local lookVector = Camera.CFrame.LookVector
        local rightVector = Camera.CFrame.RightVector
        local upVector = Vector3.new(0, 1, 0)
        
        local moveVector = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveVector += lookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveVector -= lookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveVector -= rightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveVector += rightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveVector += upVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveVector -= upVector
        end
        
        if moveVector.Magnitude > 0 then
            moveVector = moveVector.Unit * FlySpeedSlider.CurrentValue
        end
        
        flyVelocity.Velocity = moveVector
        flyGyro.CFrame = Camera.CFrame
    end)
    
    table.insert(connections, flyConnection)
end

local function disableFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    if flyVelocity then
        flyVelocity:Destroy()
        flyVelocity = nil
    end
    
    if flyGyro then
        flyGyro:Destroy()
        flyGyro = nil
    end
    
    humanoid:ChangeState(Enum.HumanoidStateType.Running)
end

MovementTab:CreateToggle({
    Name = "Voo por Câmera",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            enableFly()
            Rayfield:Notify({
                Title = "Voo Ativado!",
                Content = "Use WASD + Espaço/Ctrl",
                Duration = 3,
                Image = 4483345998,
            })
        else
            disableFly()
            Rayfield:Notify({
                Title = "Voo Desativado!",
                Content = "Voo desativado",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end,
})

-- Sistema de Noclip
local noclipEnabled = false
local noclipConnection

local function enableNoclip()
    noclipConnection = RunService.Stepped:Connect(function()
        if character and character.PrimaryPart then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    table.insert(connections, noclipConnection)
end

local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        noclipEnabled = Value
        if noclipEnabled then
            enableNoclip()
            Rayfield:Notify({
                Title = "Noclip Ativado!",
                Content = "Atravessar paredes ativado",
                Duration = 3,
                Image = 4483345998,
            })
        else
            disableNoclip()
            Rayfield:Notify({
                Title = "Noclip Desativado!",
                Content = "Noclip desativado",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end,
})

-- === ABA: JOGADOR ===
local PlayerTab = Window:CreateTab("Jogador", 4483345998)

local PlayerSection = PlayerTab:CreateSection("Modificações do Jogador")

-- God Mode
local godEnabled = false
local healthConnection
local godHealth = 1e9

local function enableGodMode()
    keepModifying(humanoid, "MaxHealth", godHealth)
    keepModifying(humanoid, "Health", godHealth)
    
    healthConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Dead then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            humanoid.Health = godHealth
        end
    end)
    
    table.insert(connections, healthConnection)
    
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            if string.find(string.lower(obj.Name), "health") or 
               string.find(string.lower(obj.Name), "hp") then
                keepModifying(obj, "Value", godHealth)
            end
        end
    end
    
    Rayfield:Notify({
        Title = "God Mode Ativado!",
        Content = "Imortalidade ativada!",
        Duration = 3,
        Image = 4483345998,
    })
end

local function disableGodMode()
    if healthConnection then
        healthConnection:Disconnect()
        healthConnection = nil
    end
    
    if originalValues[humanoid] then
        if originalValues[humanoid].MaxHealth then
            humanoid.MaxHealth = originalValues[humanoid].MaxHealth
        end
        if originalValues[humanoid].Health then
            humanoid.Health = originalValues[humanoid].Health
        end
    end
    
    Rayfield:Notify({
        Title = "God Mode Desativado!",
        Content = "Imortalidade desativada",
        Duration = 3,
        Image = 4483345998,
    })
end

PlayerTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodModeToggle",
    Callback = function(Value)
        godEnabled = Value
        if godEnabled then
            enableGodMode()
        else
            disableGodMode()
        end
    end,
})

-- Sistema de Unload
PlayerTab:CreateButton({
    Name = "DESCARREGAR SCRIPT COMPLETAMENTE",
    Callback = function()
        Rayfield:Notify({
            Title = "Descarregando...",
            Content = "Removendo todas as modificações",
            Duration = 3,
            Image = 4483345998,
        })
        
        -- Desativar tudo
        if flyEnabled then
            disableFly()
        end
        
        if noclipEnabled then
            disableNoclip()
        end
        
        if godEnabled then
            disableGodMode()
        end
        
        if aimbotEnabled then
            aimbotEnabled = false
            if aimbotConnection then
                aimbotConnection:Disconnect()
                aimbotConnection = nil
            end
        end
        
        -- Desconectar todas as conexões
        for _, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        -- Resetar valores originais
        for obj, values in pairs(originalValues) do
            if obj and obj.Parent then
                for valueName, originalValue in pairs(values) do
                    pcall(function()
                        obj[valueName] = originalValue
                    end)
                end
            end
        end
        
        -- Limpar variáveis
        connections = {}
        originalValues = {}
        activeLoops = {}
        
        -- Fechar Rayfield
        Rayfield:Destroy()
        
        Rayfield:Notify({
            Title = "Script Descarregado!",
            Content = "Todas as modificações removidas",
            Duration = 5,
            Image = 4483345998,
        })
    end,
})

-- Sistema de persistência após morte
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    
    Rayfield:Notify({
        Title = "Respawn Detectado!",
        Content = "Reaplicando modificações...",
        Duration = 3,
        Image = 4483345998,
    })
    
    wait(1)
    
    -- Reaplicar movimento
    keepModifying(humanoid, "WalkSpeed", WalkSpeedSlider.CurrentValue)
    keepModifying(humanoid, "JumpPower", JumpPowerSlider.CurrentValue)
    
    -- Reaplicar God Mode
    if godEnabled then
        enableGodMode()
    end
    
    -- Reaplicar Aimbot
    if aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
        table.insert(connections, aimbotConnection)
    end
    
    Rayfield:Notify({
        Title = "Modificações Reaplicadas!",
        Content = "Todas as funções restauradas",
        Duration = 3,
        Image = 4483345998,
    })
end)

humanoid.Died:Connect(function()
    Rayfield:Notify({
        Title = "Morte Detectada!",
        Content = "Modificações serão restauradas no respawn",
        Duration = 3,
        Image = 4483345998,
    })
end)
