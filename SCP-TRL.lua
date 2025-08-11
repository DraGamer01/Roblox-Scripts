-- === SCP: THE RED LAKE ULTIMATE HUB ===
-- SCRIPT COMPLETO COM SIRIUS UI INTEGRADA
-- ===========================================

-- Carregar Sirius UI (biblioteca)
local Library = loadstring(game:HttpGet('https://sirius.menu/sirius'))()

-- Verificar se a biblioteca carregou corretamente
if not Library then
    warn("Falha ao carregar a biblioteca Sirius UI!")
    return
end

-- Criar janela principal
local Window = Library:CreateWindow("SCP: The Red Lake Hub")

-- Notificações do sistema
Library:Notify("Hub Carregado!", "Use apenas em servidores privados!", 5)

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
        Library:Notify("Aimbot", aimbotEnabled and "Ativado (F)" or "Desativado (F)", 2)
    end
end)

-- === ABA: ARMAS ===
local WeaponTab = Window:CreateTab("Armas")

-- Seção da G18
WeaponTab:CreateSection("Modificação da G18")

-- Sliders para armas
local DamageSlider = WeaponTab:CreateSlider("Dano", 1, 100, 15, function(Value)
    -- Será aplicado no botão
end)

local FireRateSlider = WeaponTab:CreateSlider("Cadência (RPM)", 50, 1200, 400, function(Value)
    -- Será aplicado no botão
end)

local MagazineSlider = WeaponTab:CreateSlider("Tamanho do Pente", 1, 50, 17, function(Value)
    -- Será aplicado no botão
end)

local RecoilSlider = WeaponTab:CreateSlider("Recuo", 0, 5, 0.8, function(Value)
    -- Será aplicado no botão
end)

local ReloadSlider = WeaponTab:CreateSlider("Tempo de Recarga", 0.1, 10, 2.2, function(Value)
    -- Será aplicado no botão
end)

-- Botão de aplicar modificações de arma
WeaponTab:CreateButton("Aplicar Modificações da G18", function()
    local gun = character:FindFirstChild("G18")
    if not gun then
        Library:Notify("Erro!", "Equipe a G18 primeiro!", 3)
        return
    end
    
    local config = gun:FindFirstChild("Configuration") or gun:FindFirstChild("GunStats") or gun
    local applied = 0
    
    if config:FindFirstChild("Damage") then
        keepModifying(config.Damage, "Value", DamageSlider)
        applied = applied + 1
    end
    
    if config:FindFirstChild("FireRate") then
        keepModifying(config.FireRate, "Value", 60 / FireRateSlider)
        applied = applied + 1
    end
    
    if config:FindFirstChild("MagazineSize") or config:FindFirstChild("Ammo") then
        local mag = config:FindFirstChild("MagazineSize") or config:FindFirstChild("Ammo")
        keepModifying(mag, "Value", MagazineSlider)
        applied = applied + 1
    end
    
    if config:FindFirstChild("Recoil") then
        keepModifying(config.Recoil, "Value", RecoilSlider)
        applied = applied + 1
    end
    
    if config:FindFirstChild("ReloadTime") then
        keepModifying(config.ReloadTime, "Value", ReloadSlider)
        applied = applied + 1
    end
    
    Library:Notify("Sucesso!", "Aplicadas " .. applied .. " modificações!", 3)
end)

-- Seção do Aimbot
WeaponTab:CreateSection("Aimbot")

-- Toggle do Aimbot
WeaponTab:CreateToggle("Ativar Aimbot", false, function(Value)
    aimbotEnabled = Value
    if aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
        table.insert(connections, aimbotConnection)
        Library:Notify("Aimbot Ativado!", "Use F ou o toggle para desativar", 3)
    else
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
        Library:Notify("Aimbot Desativado!", "Aimbot desativado", 3)
    end
end)

WeaponTab:CreateLabel("Pressione F para ativar/desativar rapidamente")

-- === ABA: MOVIMENTO ===
local MovementTab = Window:CreateTab("Movimento")

MovementTab:CreateSection("Modificação de Movimento")

local WalkSpeedSlider = MovementTab:CreateSlider("Velocidade de Caminhada", 1, 1000, 16, function(Value)
    -- Será aplicado no botão
end)

local JumpPowerSlider = MovementTab:CreateSlider("Força do Pulo", 1, 1000, 50, function(Value)
    -- Será aplicado no botão
end)

local FlySpeedSlider = MovementTab:CreateSlider("Velocidade de Voo", 1, 1000, 50, function(Value)
    -- Será aplicado no botão
end)

-- Botão de aplicar movimento
MovementTab:CreateButton("Aplicar Modificações de Movimento", function()
    keepModifying(humanoid, "WalkSpeed", WalkSpeedSlider)
    keepModifying(humanoid, "JumpPower", JumpPowerSlider)
    
    Library:Notify("Sucesso!", "Modificações de movimento aplicadas!", 3)
end)

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
            moveVector = moveVector.Unit * FlySpeedSlider
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

MovementTab:CreateToggle("Voo por Câmera", false, function(Value)
    flyEnabled = Value
    if flyEnabled then
        enableFly()
        Library:Notify("Voo Ativado!", "Use WASD + Espaço/Ctrl", 3)
    else
        disableFly()
        Library:Notify("Voo Desativado!", "Voo desativado", 3)
    end
end)

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

MovementTab:CreateToggle("Noclip", false, function(Value)
    noclipEnabled = Value
    if noclipEnabled then
        enableNoclip()
        Library:Notify("Noclip Ativado!", "Atravessar paredes ativado", 3)
    else
        disableNoclip()
        Library:Notify("Noclip Desativado!", "Noclip desativado", 3)
    end
end)

-- === ABA: JOGADOR ===
local PlayerTab = Window:CreateTab("Jogador")

PlayerTab:CreateSection("Modificações do Jogador")

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
    
    Library:Notify("God Mode Ativado!", "Imortalidade ativada!", 3)
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
    
    Library:Notify("God Mode Desativado!", "Imortalidade desativada", 3)
end

PlayerTab:CreateToggle("God Mode", false, function(Value)
    godEnabled = Value
    if godEnabled then
        enableGodMode()
    else
        disableGodMode()
    end
end)

-- Sistema de Unload
PlayerTab:CreateButton("DESCARREGAR SCRIPT COMPLETAMENTE", function()
    Library:Notify("Descarregando...", "Removendo todas as modificações", 3)
    
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
    
    -- Fechar janela
    Library:Destroy()
    
    Library:Notify("Script Descarregado!", "Todas as modificações removidas", 5)
end)

-- Sistema de persistência após morte
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    
    Library:Notify("Respawn Detectado!", "Reaplicando modificações...", 3)
    
    wait(1)
    
    -- Reaplicar movimento
    keepModifying(humanoid, "WalkSpeed", WalkSpeedSlider)
    keepModifying(humanoid, "JumpPower", JumpPowerSlider)
    
    -- Reaplicar God Mode
    if godEnabled then
        enableGodMode()
    end
    
    -- Reaplicar Aimbot
    if aimbotEnabled then
        aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
        table.insert(connections, aimbotConnection)
    end
    
    Library:Notify("Modificações Reaplicadas!", "Todas as funções restauradas", 3)
end)

humanoid.Died:Connect(function()
    Library:Notify("Morte Detectada!", "Modificações serão restauradas no respawn", 3)
end)
