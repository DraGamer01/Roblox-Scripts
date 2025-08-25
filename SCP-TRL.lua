-- SCP: The Red Lake - ULTIMATE HUB - Swift Executor Exclusivo (SEM TRANSPARÊNCIA)
-- Feito para Swift Executor. Não contém nenhum código de transparência de HUB.
-- Inclui: Fly, Vida Infinita, Anti-Kick, Noclip, WalkSpeed, FlySpeed, FOV, Aimbot, Diagnostics, Weapon Finder
-- AGORA COM: Buff universal de armas (para todas as armas) configurável e persistente na aba de Modificações de Armas!

print("SCP-TRL iniciado! [Swift Exclusive]")

local scriptVersion = "6.2.0"
local debugEmoji = "🛡️"
local logFilePath = "C:\\Users\\matia\\AppData\\Roaming\\Swift\\Workspace\\SCP-TRL_log.txt"

local character, humanoid, restoreLoop, flyBodyVelocity, noclipLoop = nil, nil, nil, nil, nil
local flying, infiniteLifeActive, noclipActive = false, false, false
local runSpeed, flySpeed, currentFOV = 16, 50, 70 -- FOV padrão = 70

local logs = {}

local function log(msg)
    local fullMsg = debugEmoji .. " [" .. os.date("%H:%M:%S") .. "] " .. tostring(msg)
    table.insert(logs, fullMsg)
    if rconsoleprint then rconsoleprint(fullMsg .. "\n") end
    print(fullMsg)
end
local function logError(msg)
    log("ERRO: " .. tostring(msg))
end
local function saveLogs()
    if writefile then
        writefile(logFilePath, table.concat(logs, "\n"))
        log("Logs salvos em: " .. logFilePath)
    else
        logError("writefile não disponível!")
    end
end

-- UI
local Rayfield = nil
local rayfieldUrl = 'https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'
log("[DEBUG] Baixando Rayfield...")
local rfcode = game:HttpGet(rayfieldUrl)
if not rfcode or #rfcode < 50 then
    logError("Rayfield download falhou ou está vazio!")
else
    local loaded, rf = pcall(function() return loadstring(rfcode)() end)
    if loaded and rf then
        Rayfield = rf
        log("Rayfield Sirius carregado!")
    else
        logError("Rayfield Sirius não carregado! Erro: " .. tostring(rf))
    end
end

if not Rayfield then
    logError("Rayfield NÃO carregado, nenhuma interface será exibida!")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "SCP: The Red Lake HUB",
    LoadingTitle = "SCP-TRL",
    LoadingSubtitle = "by DraGamer01",
    ConfigurationSaving = {Enabled = true, FolderName = "SCPTRL"},
    KeySystem = false
})

------------------ 🛡️ HUB CONFIG ------------------
local TabConfig = Window:CreateTab("Hub Config", 4483362458)

TabConfig:CreateButton({
    Name = "Salvar Logs de Debug",
    Callback = function()
        log("Botão 'Salvar Logs de Debug' pressionado")
        saveLogs()
    end
})

------------------ 🛡️ VIDA INFINITA MELHORADA ------------------
TabConfig:CreateToggle({
    Name = "Vida Infinita (protegido de NPCs)",
    CurrentValue = false,
    Callback = function(state)
        infiniteLifeActive = state
        log("Vida infinita " .. (state and "ativada" or "desativada"))
        local player = game.Players.LocalPlayer
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if infiniteLifeActive and humanoid then
            if not humanoid:GetAttribute("LifePatched") then
                humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    if infiniteLifeActive and humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = humanoid.MaxHealth
                        log("Vida restaurada: " .. humanoid.Health)
                    end
                end)
                humanoid.StateChanged:Connect(function(_, newState)
                    if infiniteLifeActive and newState == Enum.HumanoidStateType.Dead then
                        humanoid.Health = humanoid.MaxHealth
                        humanoid.PlatformStand = false
                        log("Bloqueou morte do Humanoid (state Dead)")
                    end
                end)
                humanoid:SetAttribute("LifePatched", true)
            end
        elseif restoreLoop then
            restoreLoop:Disconnect()
            log("Loop de vida infinita parado")
        end
    end,
})

------------------ 🛡️ ANTI-KICK/ANTI-CHEAT ------------------
local function antiKick()
    local player = game.Players.LocalPlayer
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        if tostring(self) == tostring(player) and (getnamecallmethod() == "Kick" or getnamecallmethod() == "kick") then
            logError("Tentativa de Kick bloqueada!")
            return
        end
        return oldNamecall(self, ...)
    end)
    log("AntiKick ativo!")
end
TabConfig:CreateToggle({
    Name = "Anti-Kick/Anti-Cheat",
    CurrentValue = true,
    Callback = function(state)
        log("AntiKick " .. (state and "ativado" or "desativado"))
        if state then antiKick() end
    end
})

------------------ 🛡️ NOCLIP ------------------
local function setNoclip(state)
    noclipActive = state
    log("Noclip " .. (state and "ativado" or "desativado"))
    if noclipActive then
        noclipLoop = game:GetService("RunService").Stepped:Connect(function()
            local player = game.Players.LocalPlayer
            character = player.Character or player.CharacterAdded:Wait()
            for _, part in pairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    elseif noclipLoop then
        noclipLoop:Disconnect()
        noclipLoop = nil
    end
end

TabConfig:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = setNoclip
})

------------------ 🛡️ UNLOAD COMPLETO ------------------
TabConfig:CreateButton({
    Name = "UNLOAD COMPLETO",
    Callback = function()
        log("Unload iniciado...")
        flying = false
        infiniteLifeActive = false
        noclipActive = false
        weaponBuffActive = false -- Para o buff universal de armas!
        if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy() log("Fly removido") end
        if restoreLoop then restoreLoop:Disconnect() log("Loop de vida infinita parado") end
        if noclipLoop then noclipLoop:Disconnect() log("Noclip parado") end
        local rayfieldUI = game.CoreGui:FindFirstChild("Rayfield")
        if rayfieldUI then rayfieldUI:Destroy() log("Rayfield UI removida") end
        character, humanoid, restoreLoop, flyBodyVelocity, noclipLoop = nil, nil, nil, nil, nil
        log("Unload completo.")
    end
})

------------------ 🛡️ DIAGNÓSTICO ------------------
local TabDiagnostico = Window:CreateTab("Diagnóstico", 4483362458)
local function runDiagnostics()
    log("Diagnóstico completo iniciado!")
    local player = game.Players.LocalPlayer
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:FindFirstChildOfClass("Humanoid")
    local backpack = player:FindFirstChild("Backpack")
    local diagnostics = {
        executor = "Swift",
        robloxVersion = game:GetService("RunService"):GetRobloxVersion(),
        player = player.Name .. " (" .. player.UserId .. ")",
        character = character and character.Name or "N/A",
        health = humanoid and humanoid.Health or "N/A",
        maxHealth = humanoid and humanoid.MaxHealth or "N/A",
        walkSpeed = humanoid and humanoid.WalkSpeed or "N/A",
        jumpPower = humanoid and humanoid.JumpPower or "N/A",
        team = player.Team and player.Team.Name or "N/A",
        tools = {},
        scripts = {},
        remoteEvents = {},
        remoteFunctions = {},
        issues = {}
    }
    if backpack then
        for _,tool in pairs(backpack:GetChildren()) do
            table.insert(diagnostics.tools, tool.Name)
        end
    end
    for _,obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            table.insert(diagnostics.tools, obj.Name .. " (equipped)")
        elseif obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
            table.insert(diagnostics.scripts, obj.Name)
        end
    end
    for _,obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteEvent") then table.insert(diagnostics.remoteEvents, obj.Name) end
        if obj:IsA("RemoteFunction") then table.insert(diagnostics.remoteFunctions, obj.Name) end
    end
    -- Verificações extras
    if not character then table.insert(diagnostics.issues, "Character não encontrado") end
    if not humanoid then table.insert(diagnostics.issues, "Humanoid não encontrado") end
    if #diagnostics.remoteEvents == 0 then table.insert(diagnostics.issues, "Nenhum RemoteEvent") end
    if infiniteLifeActive then table.insert(diagnostics.issues, "Vida Infinita ativada") end
    if flying then table.insert(diagnostics.issues, "Fly ativado") end
    if noclipActive then table.insert(diagnostics.issues, "Noclip ativado") end
    local infoJson = game:GetService("HttpService"):JSONEncode(diagnostics)
    log("DIAGNÓSTICO COMPLETO:\n" .. infoJson)
    if writefile then
        writefile(logFilePath, infoJson)
        log("Diagnóstico salvo em: " .. logFilePath)
    end
end
TabDiagnostico:CreateButton({Name = "Executar Diagnóstico Completo", Callback = runDiagnostics})
TabDiagnostico:CreateButton({Name = "Salvar Logs de Diagnóstico", Callback = saveLogs})

------------------ 🛡️ MODIFICAÇÕES DE ARMAS (UNIVERSAL WEAPON BUFF) ------------------
local TabModArmas = Window:CreateTab("Modificações de Armas", 4483362458)

TabModArmas:CreateParagraph({
    Title = "Buff Universal em TODAS as Armas",
    Content = "Configure abaixo e ative o buff. Modifica todas armas da pasta Tools no ReplicatedStorage."
})

-- Valores padrões para o buff universal
local weaponBuffValues = {
    Damage = 999,
    RPM = 3000,
    ReloadTime = 0.1,
    Spread = 0,
    Ammo = 9999,
    TotalAmmo = 99999,
    BulletsToFire = 1,
    CanPenetrate = true,
    HeadshotBonus = true,
    Range = 9999,
    Type = "Auto"
}

-- Interface para editar cada valor
for attr, default in pairs(weaponBuffValues) do
    if typeof(default) == "number" then
        TabModArmas:CreateInput({
            Name = attr,
            PlaceholderText = tostring(default),
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                local val = tonumber(text)
                if val then weaponBuffValues[attr] = val log("["..attr.."] = "..val) end
            end
        })
    elseif typeof(default) == "boolean" then
        TabModArmas:CreateToggle({
            Name = attr,
            CurrentValue = default,
            Callback = function(state)
                weaponBuffValues[attr] = state
                log("["..attr.."] = " .. tostring(state))
            end
        })
    elseif typeof(default) == "string" then
        TabModArmas:CreateInput({
            Name = attr,
            PlaceholderText = default,
            RemoveTextAfterFocusLost = false,
            Callback = function(text)
                if text ~= "" then weaponBuffValues[attr] = text log("["..attr.."] = "..text) end
            end
        })
    end
end

-- Patcher forte universal
local weaponBuffActive = false
local weaponBuffLoop = nil

local function patchAllWeapons()
    local rs = game:GetService("ReplicatedStorage")
    local tools = rs:FindFirstChild("Tools")
    if not tools then return 0 end
    local changed = 0
    for _,tool in ipairs(tools:GetChildren()) do
        if tool:IsA("Tool") then
            for attr, val in pairs(weaponBuffValues) do
                if tool:GetAttribute(attr) ~= nil then
                    tool:SetAttribute(attr, val)
                end
            end
            changed = changed + 1
        end
    end
    return changed
end

local function startWeaponBuff()
    if weaponBuffLoop then return end
    weaponBuffActive = true
    weaponBuffLoop = task.spawn(function()
        while weaponBuffActive do
            local changed = patchAllWeapons()
            if changed > 0 then
                log("Buff universal aplicado em "..changed.." armas!")
            end
            task.wait(2)
        end
    end)
end

local function stopWeaponBuff()
    weaponBuffActive = false
    weaponBuffLoop = nil
end

TabModArmas:CreateToggle({
    Name = "Ativar/Desativar Buff Universal de Armas",
    CurrentValue = false,
    Callback = function(state)
        if state then
            startWeaponBuff()
            log("Buff universal de armas ativado!")
        else
            stopWeaponBuff()
            log("Buff universal de armas desativado!")
        end
    end
})

------------------ 🛡️ MODS PRINCIPAIS ------------------
local TabMods = Window:CreateTab("Mods", 4483362458)

TabMods:CreateToggle({
    Name = "Voo (acompanha câmera)",
    CurrentValue = false,
    Callback = function(Value)
        flying = Value
        log("Fly " .. (Value and "ativado" or "desativado"))
        local player = game.Players.LocalPlayer
        character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        if flying then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.Name = "FlyVelocity"
            flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            flyBodyVelocity.Velocity = Vector3.new(0,0,0)
            flyBodyVelocity.Parent = root
            coroutine.wrap(function()
                while flying and flyBodyVelocity do
                    local camera = workspace.CurrentCamera
                    local direction = Vector3.new()
                    local uis = game:GetService("UserInputService")
                    if uis:IsKeyDown(Enum.KeyCode.W) then direction = direction + camera.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then direction = direction - camera.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then direction = direction - camera.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then direction = direction + camera.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.Space) then direction = direction + camera.CFrame.UpVector end
                    if uis:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - camera.CFrame.UpVector end
                    if direction.Magnitude > 0 then
                        flyBodyVelocity.Velocity = direction.Unit * flySpeed
                        root.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
                    else
                        flyBodyVelocity.Velocity = Vector3.new(0,0,0)
                    end
                    wait()
                end
            end)()
        else
            if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy() end
            log("Voo desativado")
        end
    end,
})

------------------ 🛡️ CONFIGURAÇÕES DOS MODS ------------------
local TabModsConfig = Window:CreateTab("Configurações Mods", 4483362458)

-- FOV
local FOVInput
TabModsConfig:CreateSection("FOV")
TabModsConfig:CreateSlider({
    Name = "FOV",
    Range = {40, 120},
    Increment = 1,
    CurrentValue = currentFOV,
    Callback = function(Value)
        currentFOV = Value
        workspace.CurrentCamera.FieldOfView = currentFOV
        if FOVInput then FOVInput:Set(Value) end
        log("FOV ajustado: "..tostring(Value))
    end
})
FOVInput = TabModsConfig:CreateInput({
    Name = "FOV Numérico",
    PlaceholderText = "40-120",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local val = tonumber(text)
        if val and val >= 40 and val <= 120 then
            currentFOV = val
            workspace.CurrentCamera.FieldOfView = currentFOV
            log("FOV ajustado: "..tostring(currentFOV))
        end
    end
})

-- Fly Speed
local FlyInput
TabModsConfig:CreateSection("Velocidade de Voo")
TabModsConfig:CreateSlider({
    Name = "Velocidade do Voo",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = flySpeed,
    Callback = function(Value)
        flySpeed = Value
        if FlyInput then FlyInput:Set(Value) end
        log("Velocidade de voo ajustada: " .. Value)
    end
})
FlyInput = TabModsConfig:CreateInput({
    Name = "Velocidade do Voo Numérica",
    PlaceholderText = "Digite valor entre 1 e 1000",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local val = tonumber(text)
        if val and val >= 1 and val <= 1000 then
            flySpeed = val
            log("Velocidade de voo ajustada: " .. tostring(flySpeed))
        end
    end
})

-- WalkSpeed
local WalkSpeedInput
TabModsConfig:CreateSection("Velocidade Correndo")
TabModsConfig:CreateSlider({
    Name = "Velocidade Correndo",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = runSpeed,
    Callback = function(Value)
        runSpeed = Value
        if WalkSpeedInput then WalkSpeedInput:Set(Value) end
        local player = game.Players.LocalPlayer
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:FindFirstChildOfClass("Humanoid")
        log("WalkSpeed definido: " .. runSpeed)
        if humanoid then
            humanoid.WalkSpeed = runSpeed
        else
            logError("Humanoid não encontrado para setar WalkSpeed")
        end
    end
})
WalkSpeedInput = TabModsConfig:CreateInput({
    Name = "Velocidade Correndo Numérica",
    PlaceholderText = "Digite valor entre 1 e 1000",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local val = tonumber(text)
        if val and val >= 1 and val <= 1000 then
            runSpeed = val
            local player = game.Players.LocalPlayer
            character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:FindFirstChildOfClass("Humanoid")
            log("WalkSpeed definido: " .. tostring(runSpeed))
            if humanoid then
                humanoid.WalkSpeed = runSpeed
            else
                logError("Humanoid não encontrado para setar WalkSpeed")
            end
        end
    end
})

------------------ 🛡️ AIMBOT INTEGRADO ------------------
local TabAimbot = Window:CreateTab("Aimbot", 4483362458)
local aimbotActive = false
local selectedWeapon = ""

TabAimbot:CreateInput({
    Name = "Nome da Arma (exato)",
    PlaceholderText = "Digite o nome da arma",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        selectedWeapon = text
        log("Arma do aimbot: " .. selectedWeapon)
    end
})

TabAimbot:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(state)
        aimbotActive = state
        log("Aimbot " .. (state and "ativado" or "desativado"))
        if aimbotActive then
            coroutine.wrap(function()
                getgenv().aim = true
                local name = game.Players.LocalPlayer.Name
                while wait() and aimbotActive do
                    repeat wait() until game.workspace:FindFirstChild(name)
                    if selectedWeapon ~= "" then
                        for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                            if v.Name == selectedWeapon then
                                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
                            end
                        end
                    end
                    -- Recarregar se necessário
                    local crosshair = game:GetService("Players"):FindFirstChild(name).PlayerGui:FindFirstChild("Crosshair")
                    if crosshair and crosshair:FindFirstChild("Counter") then
                        if crosshair.Counter.CurrentAmmo.Text == "0" and crosshair.Counter.StoredAmmo.Text == "0" then
                            for i, v in pairs(game.workspace.Maps.Classic.Interactable.AmmoBoxes.Box:GetDescendants()) do
                                if v:IsA("ProximityPrompt") then
                                    local root = game.Players.LocalPlayer.Character.HumanoidRootPart
                                    root.Anchored = false
                                    local p = root.CFrame
                                    root.CFrame = v.Parent.CFrame
                                    wait(1)
                                    fireproximityprompt(v)
                                    wait(1)
                                    root.CFrame = p
                                end
                            end
                        end
                    end
                    -- Forçar recarga
                    local tool = game.Players.LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                    if tool and tool:FindFirstChild("Main") then
                        tool.Main:FireServer("AMMO")
                    end
                    -- Encontrar NPC mais próximo
                    local closestDistance = math.huge
                    local closestNPC = nil
                    for _,v in pairs(game:GetService("Workspace").NPCs:GetDescendants()) do
                        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Head") then
                            if v.Parent.Name ~= "Deceased" and v.Parent.Name ~= "Friends" and v.Parent.Name ~= "Survivors" then
                                local distance = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestNPC = v
                                end
                            end
                        end
                    end
                    if closestNPC then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closestNPC.Head.Position)
                    end
                end
            end)()
        else
            getgenv().aim = false
        end
    end
})

------------------ 🛡️ WEAPON FINDER ------------------
local TabWeapon = Window:CreateTab("Weapon Finder", 4483362458)
local function findWeaponProperties()
    local player = game.Players.LocalPlayer
    local out = {}
    for _,tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolProps = {}
            for _,prop in pairs(tool:GetChildren()) do
                if prop:IsA("IntValue") or prop:IsA("NumberValue") or prop:IsA("BoolValue") or prop:IsA("StringValue") then
                    table.insert(toolProps, prop.Name .. ": " .. tostring(prop.Value))
                end
            end
            table.insert(out, "Arma: " .. tool.Name .. "\n" .. table.concat(toolProps, "\n"))
        end
    end
    if #out > 0 and writefile then
        local path = "C:\\Users\\matia\\AppData\\Roaming\\Swift\\Workspace\\SCP-TRL_weapons.txt"
        writefile(path, table.concat(out, "\n\n"))
        log("Weapon properties salvos em: " .. path)
    else
        log("Nenhuma arma detectada no Backpack.")
    end
end
TabWeapon:CreateButton({Name = "Encontrar propriedades das armas e salvar", Callback = findWeaponProperties})

------------------ 🛡️ BOOT LOG ------------------
log("SCP-TRL.lua carregado! Versão: " .. scriptVersion .. " Executor: Swift")

------------------ 🛡️ FIM DO SCRIPT ------------------
