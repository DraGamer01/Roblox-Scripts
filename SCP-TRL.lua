-- SCP: The Red Lake - ULTIMATE HUB - SWIFT EXECUTOR EXCLUSIVO
-- 🛡️ Diagnóstico, Log, Anti-Kick, Gamepass, Vida Infinita, Fly, Noclip, Weapon Finder, Unload, Recovery
-- Pronto para loadstring do GitHub | Feito por DraGamer01

print("SCP-TRL iniciado! [DEBUG]")

local scriptVersion = "5.0.0"
local debugEmoji = "🛡️"
local logFilePath = "C:\\Users\\matia\\AppData\\Roaming\\Swift\\Workspace\\SCP-TRL_log.txt"

local character, humanoid, restoreLoop, flyBodyVelocity, noclipLoop = nil, nil, nil, nil, nil
local flying, infiniteLifeActive, noclipActive = false, false, false
local runSpeed, flySpeed = 16, 50

local function log(msg)
    local fullMsg = debugEmoji .. " [" .. os.date("%H:%M:%S") .. "] " .. tostring(msg)
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

-- Rayfield UI seguro
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

local rayfieldUI = game.CoreGui:FindFirstChild("Rayfield")

------------------ 🛡️ HUB CONFIG ------------------
local TabConfig = Window:CreateTab("Hub Config", 4483362458)
local hubTransparency = 0

TabConfig:CreateSlider({
    Name = "Transparência do HUB",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = hubTransparency,
    Callback = function(Value)
        hubTransparency = Value
        if rayfieldUI then
            for _,obj in pairs(rayfieldUI:GetDescendants()) do
                if obj:IsA("Frame") then
                    pcall(function() obj.BackgroundTransparency = hubTransparency end)
                end
                if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                    pcall(function() obj.TextTransparency = hubTransparency end)
                end
            end
            log("Transparência do HUB ajustada para " .. tostring(hubTransparency))
        else
            logError("Rayfield UI não encontrada para transparência")
        end
    end
})
TabConfig:CreateInput({
    Name = "Transparência Numérica",
    PlaceholderText = "0.00 (mín) até 1.00 (máx)",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        local val = tonumber(text)
        if val and val >= 0 and val <= 1 then
            hubTransparency = val
            if rayfieldUI then
                for _,obj in pairs(rayfieldUI:GetDescendants()) do
                    if obj:IsA("Frame") then
                        pcall(function() obj.BackgroundTransparency = hubTransparency end)
                    end
                    if obj:IsA("TextLabel") or obj:IsA("TextBox") then
                        pcall(function() obj.TextTransparency = hubTransparency end)
                    end
                end
            end
            log("Transparência do HUB ajustada para " .. tostring(hubTransparency))
        end
    end
})

TabConfig:CreateButton({
    Name = "Salvar Logs de Debug",
    Callback = function()
        log("Botão 'Salvar Logs de Debug' pressionado")
        saveLogs()
    end
})

------------------ 🛡️ VIDA INFINITA ------------------
TabConfig:CreateToggle({
    Name = "Vida Infinita",
    CurrentValue = false,
    Callback = function(state)
        infiniteLifeActive = state
        log("Vida infinita " .. (state and "ativada" or "desativada"))
        local player = game.Players.LocalPlayer
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if infiniteLifeActive and humanoid then
            restoreLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if humanoid and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                    log("Vida restaurada: " .. humanoid.Health)
                end
            end)
            log("Loop de vida infinita iniciado")
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
        if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy() log("Fly removido") end
        if restoreLoop then restoreLoop:Disconnect() log("Loop de vida infinita parado") end
        if noclipLoop then noclipLoop:Disconnect() log("Noclip parado") end
        if rayfieldUI then rayfieldUI:Destroy() log("Rayfield UI removida") end
        character, humanoid, restoreLoop, flyBodyVelocity, noclipLoop = nil, nil, nil, nil, nil
        log("Unload completo.")
    end
})

------------------ 🛡️ DIAGNÓSTICO APRIMORADO ------------------
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

------------------ 🛡️ MODIFICAÇÕES DE ARMAS ------------------
local TabModArmas = Window:CreateTab("Modificações de Armas", 4483362458)
TabModArmas:CreateParagraph({
    Title = "Varredura Avançada",
    Content = "Use o Dex Explorer para obter propriedades da arma e envie aqui. Assim, todos os campos serão gerados!"
})

------------------ 🛡️ VELOCIDADE E FLY ------------------
local TabVelocidade = Window:CreateTab("Velocidade", 4483362458)

TabVelocidade:CreateSlider({
    Name = "Velocidade do Voo",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = flySpeed,
    Callback = function(Value)
        flySpeed = Value
        log("Velocidade de voo ajustada: " .. Value)
    end
})
TabVelocidade:CreateInput({
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
TabVelocidade:CreateSlider({
    Name = "Velocidade Correndo",
    Range = {1, 1000},
    Increment = 1,
    CurrentValue = runSpeed,
    Callback = function(Value)
        runSpeed = Value
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
TabVelocidade:CreateInput({
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

TabVelocidade:CreateToggle({
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
                    -- Direção na frente da câmera (inclinação e giro)
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
