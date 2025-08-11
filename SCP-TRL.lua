-- === SCP: THE RED LAKE ULTIMATE HUB ===
-- USANDO ORION LIBRARY - MODERNA E ATUALIZADA
-- ===========================================

-- Carregar Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- Criar janela principal
local Window = OrionLib:MakeWindow({
    Name = "SCP: The Red Lake Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "SCPHubConfig",
    IntroText = "Carregando Hub...",
    Icon = "rbxassetid://4483345998",
    IntroIcon = "rbxassetid://4483345998"
})

-- Notificações do sistema
OrionLib:MakeNotification({
    Name = "Hub Carregado!",
    Content = "Use apenas em servidores privados!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
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

-- === ABA: ARMAS ===
local WeaponTab = Window:MakeTab({
    Name = "Armas",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local WeaponSection = WeaponTab:AddSection({
    Name = "Modificação da G18"
})

-- Sliders para armas
local DamageSlider = WeaponSection:AddSlider({
    Name = "Dano",
    Min = 1,
    Max = 100,
    Default = 15,
    Color = Color3.fromRGB(255, 0, 0),
    Increment = 1,
    ValueName = "Dano",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

local FireRateSlider = WeaponSection:AddSlider({
    Name = "Cadência (RPM)",
    Min = 50,
    Max = 1200,
    Default = 400,
    Color = Color3.fromRGB(255, 165, 0),
    Increment = 10,
    ValueName = "RPM",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

local MagazineSlider = WeaponSection:AddSlider({
    Name = "Tamanho do Pente",
    Min = 1,
    Max = 50,
    Default = 17,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 1,
    ValueName = "Munição",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

local RecoilSlider = WeaponSection:AddSlider({
    Name = "Recuo",
    Min = 0,
    Max = 5,
    Default = 0.8,
    Color = Color3.fromRGB(0, 165, 255),
    Increment = 0.1,
    ValueName = "Recuo",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

local ReloadSlider = WeaponSection:AddSlider({
    Name = "Tempo de Recarga",
    Min = 0.1,
    Max = 10,
    Default = 2.2,
    Color = Color3.fromRGB(255, 0, 255),
    Increment = 0.1,
    ValueName = "Segundos",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

-- Botão de aplicar modificações de arma
WeaponSection:AddButton({
    Name = "Aplicar Modificações da G18",
    Callback = function()
        local gun = character:FindFirstChild("G18")
        if not gun then
            OrionLib:MakeNotification({
                Name = "Erro!",
                Content = "Equipe a G18 primeiro!",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
            return
        end
        
        local config = gun:FindFirstChild("Configuration") or gun:FindFirstChild("GunStats") or gun
        local applied = 0
        
        if config:FindFirstChild("Damage") then
            keepModifying(config.Damage, "Value", DamageSlider.Value)
            applied = applied + 1
        end
        
        if config:FindFirstChild("FireRate") then
            keepModifying(config.FireRate, "Value", 60 / FireRateSlider.Value)
            applied = applied + 1
        end
        
        if config:FindFirstChild("MagazineSize") or config:FindFirstChild("Ammo") then
            local mag = config:FindFirstChild("MagazineSize") or config:FindFirstChild("Ammo")
            keepModifying(mag, "Value", MagazineSlider.Value)
            applied = applied + 1
        end
        
        if config:FindFirstChild("Recoil") then
            keepModifying(config.Recoil, "Value", RecoilSlider.Value)
            applied = applied + 1
        end
        
        if config:FindFirstChild("ReloadTime") then
            keepModifying(config.ReloadTime, "Value", ReloadSlider.Value)
            applied = applied + 1
        end
        
        OrionLib:MakeNotification({
            Name = "Sucesso!",
            Content = "Aplicadas " .. applied .. " modificações!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
})

-- === ABA: MOVIMENTO ===
local MovementTab = Window:MakeTab({
    Name = "Movimento",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local MovementSection = MovementTab:AddSection({
    Name = "Modificação de Movimento"
})

local WalkSpeedSlider = MovementSection:AddSlider({
    Name = "Velocidade de Caminhada",
    Min = 1,
    Max = 1000,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    ValueName = "Studs/s",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

local JumpPowerSlider = MovementSection:AddSlider({
    Name = "Força do Pulo",
    Min = 1,
    Max = 1000,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 1,
    ValueName = "Força",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

local FlySpeedSlider = MovementSection:AddSlider({
    Name = "Velocidade de Voo",
    Min = 1,
    Max = 1000,
    Default = 50,
    Color = Color3.fromRGB(255, 0, 128),
    Increment = 1,
    ValueName = "Studs/s",
    Callback = function(Value)
        -- Será aplicado no botão
    end
})

-- Botão de aplicar movimento
MovementSection:AddButton({
    Name = "Aplicar Modificações de Movimento",
    Callback = function()
        keepModifying(humanoid, "WalkSpeed", WalkSpeedSlider.Value)
        keepModifying(humanoid, "JumpPower", JumpPowerSlider.Value)
        
        OrionLib:MakeNotification({
            Name = "Sucesso!",
            Content = "Modificações de movimento aplicadas!",
            Image = "rbxassetid://4483345998",
            Time = 3
        })
    end    
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
    
    local camera = workspace.CurrentCamera
    flyConnection = RunService.Heartbeat:Connect(function()
        local lookVector = camera.CFrame.LookVector
        local rightVector = camera.CFrame.RightVector
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
            moveVector = moveVector.Unit * FlySpeedSlider.Value
        end
        
        flyVelocity.Velocity = moveVector
        flyGyro.CFrame = camera.CFrame
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

MovementSection:AddToggle({
    Name = "Voo por Câmera",
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            enableFly()
            OrionLib:MakeNotification({
                Name = "Voo Ativado!",
                Content = "Use WASD + Espaço/Ctrl",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            disableFly()
            OrionLib:MakeNotification({
                Name = "Voo Desativado!",
                Content = "Voo desativado",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
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

MovementSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        if noclipEnabled then
            enableNoclip()
            OrionLib:MakeNotification({
                Name = "Noclip Ativado!",
                Content = "Atravessar paredes ativado",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        else
            disableNoclip()
            OrionLib:MakeNotification({
                Name = "Noclip Desativado!",
                Content = "Noclip desativado",
                Image = "rbxassetid://4483345998",
                Time = 3
            })
        end
    end    
})

-- === ABA: JOGADOR ===
local PlayerTab = Window:MakeTab({
    Name = "Jogador",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerSection = PlayerTab:AddSection({
    Name = "Modificações do Jogador"
})

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
    
    OrionLib:MakeNotification({
        Name = "God Mode Ativado!",
        Content = "Imortalidade ativada!",
        Image = "rbxassetid://4483345998",
        Time = 3
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
    
    OrionLib:MakeNotification({
        Name = "God Mode Desativado!",
        Content = "Imortalidade desativada",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end

PlayerSection:AddToggle({
    Name = "God Mode",
    Default = false,
    Callback = function(Value)
        godEnabled = Value
        if godEnabled then
            enableGodMode()
        else
            disableGodMode()
        end
    end    
})

-- Sistema de Unload
PlayerSection:AddButton({
    Name = "DESCARREGAR SCRIPT COMPLETAMENTE",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Descarregando...",
            Content = "Removendo todas as modificações",
            Image = "rbxassetid://4483345998",
            Time = 3
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
        
        -- Fechar Orion
        OrionLib:Destroy()
        
        OrionLib:MakeNotification({
            Name = "Script Descarregado!",
            Content = "Todas as modificações removidas",
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end    
})

-- Sistema de persistência após morte
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    
    OrionLib:MakeNotification({
        Name = "Respawn Detectado!",
        Content = "Reaplicando modificações...",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
    
    wait(1)
    
    -- Reaplicar movimento
    keepModifying(humanoid, "WalkSpeed", WalkSpeedSlider.Value)
    keepModifying(humanoid, "JumpPower", JumpPowerSlider.Value)
    
    -- Reaplicar God Mode
    if godEnabled then
        enableGodMode()
    end
    
    OrionLib:MakeNotification({
        Name = "Modificações Reaplicadas!",
        Content = "Todas as funções restauradas",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

humanoid.Died:Connect(function()
    OrionLib:MakeNotification({
        Name = "Morte Detectada!",
        Content = "Modificações serão restauradas no respawn",
        Image = "rbxassetid://4483345998",
        Time = 3
    })
end)

-- Manter Orion aberto
OrionLib:Init()
