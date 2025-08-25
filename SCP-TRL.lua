-- SCP: The Red Lake - ULTIMATE HUB - SWIFT EXECUTOR EXCLUSIVO
-- 🛡️ Diagnóstico, Log, Anti-Kick, Gamepass, Vida Infinita, Fly, Weapon Finder, Unload, Recovery
-- Pronto para loadstring do GitHub | Feito por DraGamer01

------------------ 🛡️ INICIALIZAÇÃO E DIAGNÓSTICO ------------------
print("SCP-TRL iniciado! [DEBUG]")

local scriptVersion = "4.0.1"
local debugEmoji = "🛡️"
local logFilePath = "C:\\Users\\matia\\AppData\\Roaming\\Swift\\Workspace\\SCP-TRL_log.txt"

-- Protege variáveis globais
local character, humanoid, restoreLoop, flyBodyVelocity

local function getExecutor()
    return "Swift"
end

------------------ 🛡️ LOG/DIAGNÓSTICO ------------------
local logs = {}
local function log(msg)
    local fullMsg = debugEmoji .. " [" .. os.date("%H:%M:%S") .. "] " .. tostring(msg)
    table.insert(logs, fullMsg)
    if rconsoleprint then
        rconsoleprint(fullMsg .. "\n")
    else
        print(fullMsg)
    end
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

------------------ 🛡️ CARREGAMENTO SEGURO DO RAYFIELD ------------------
local Rayfield = nil
local rayfieldUrl = 'https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'
print("[DEBUG] Baixando Rayfield...")
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

------------------ 🛡️ UI RAYFIELD SIRIUS ------------------
local Window = Rayfield:CreateWindow({
    Name = "SCP: The Red Lake HUB",
    LoadingTitle = "SCP-TRL",
    LoadingSubtitle = "by DraGamer01",
    ConfigurationSaving = {Enabled = true, FolderName = "SCPTRL"},
    KeySystem = false
})

-- Abas do Hub
local TabConfig = Window:CreateTab("Hub Config", 4483362458)
local TabDiagnostico = Window:CreateTab("Diagnóstico", 4483362458)
local TabModArmas = Window:CreateTab("Modificações de Armas", 4483362458)
local TabVelocidade = Window:CreateTab("Velocidade", 4483362458)
local TabWeapon = Window:CreateTab("Weapon Finder", 4483362458)

------------------ 🛡️ HUB CONFIG ------------------
TabConfig:CreateButton({
    Name = "UNLOAD COMPLETO",
    Callback = function()
        log("Unload iniciado...")
        flying = false
        infiniteLifeActive = false
        if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy() log("Fly removido") end
        if restoreLoop then restoreLoop:Disconnect() end
        for _,v in pairs(game.CoreGui:GetChildren()) do
            if v.Name == "Rayfield" then v:Destroy() log("Rayfield UI removida") end
        end
        log("Unload completo.")
    end
})

local hubTransparency = 0
TabConfig:CreateSlider({
    Name = "Transparência do HUB",
    Range = {0, 1},
    Increment = 0.01,
    CurrentValue = 0,
    Callback = function(Value)
        hubTransparency = Value
        for _,obj in pairs(game.CoreGui:GetDescendants()) do
            if obj:IsA("Frame") or obj:IsA("TextLabel") then
                obj.BackgroundTransparency = hubTransparency
                obj.TextTransparency = hubTransparency
            end
        end
        log("Transparência do HUB: " .. tostring(hubTransparency))
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
            for _,obj in pairs(game.CoreGui:GetDescendants()) do
                if obj:IsA("Frame") or obj:IsA("TextLabel") then
                    obj.BackgroundTransparency = hubTransparency
                    obj.TextTransparency = hubTransparency
                end
            end
            log("Transparência do HUB: " .. tostring(hubTransparency))
        end
    end
})
TabConfig:CreateButton({Name = "Salvar Logs de Debug", Callback = saveLogs})

------------------ 🛡️ DIAGNÓSTICO ------------------
local function runDiagnostics()
    local player = game.Players.LocalPlayer
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:FindFirstChildOfClass("Humanoid")
    local diagnostics = {}
    diagnostics.executor = getExecutor()
    diagnostics.robloxVersion = game:GetService("RunService"):GetRobloxVersion()
    diagnostics.player = player.Name .. " (" .. player.UserId .. ")"
    diagnostics.character = character and character.Name or "N/A"
    diagnostics.health = humanoid and humanoid.Health or "N/A"
    diagnostics.maxHealth = humanoid and humanoid.MaxHealth or "N/A"
    diagnostics.remoteEvents = {}
    for _,obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteEvent") then table.insert(diagnostics.remoteEvents, obj.Name) end
    end
    diagnostics.issues = {}
    if not character then table.insert(diagnostics.issues, "Character não encontrado") end
    if not humanoid then table.insert(diagnostics.issues, "Humanoid não encontrado") end
    if #diagnostics.remoteEvents==0 then table.insert(diagnostics.issues, "Nenhum RemoteEvent") end
    log("DIAGNÓSTICO COMPLETO:\n" .. game:GetService("HttpService"):JSONEncode(diagnostics))
    saveLogs()
end
TabDiagnostico:CreateButton({Name = "Executar Diagnóstico Completo", Callback = runDiagnostics})
TabDiagnostico:CreateButton({Name = "Salvar Logs de Diagnóstico", Callback = saveLogs})

------------------ 🛡️ MODIFICAÇÕES DE ARMAS ------------------
TabModArmas:CreateParagraph({
    Title = "Varredura Avançada",
    Content = "Use o Dex Explorer para obter propriedades da arma e envie aqui. Assim, todos os campos serão gerados!"
})

------------------ 🛡️ VELOCIDADE ------------------
local flySpeed = 50
local runSpeed = 16 -- padrão Roblox
local flying = false
flyBodyVelocity = nil

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
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = runSpeed
            log("WalkSpeed definido: " .. runSpeed)
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
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = runSpeed
                log("WalkSpeed definido: " .. tostring(runSpeed))
            end
        end
    end
})

------------------ 🛡️ FLY (direção da câmera) ------------------
TabVelocidade:CreateToggle({
    Name = "Voo (acompanha câmera)",
    CurrentValue = false,
    Callback = function(Value)
        flying = Value
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
                    flyBodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * flySpeed or Vector3.new(0,0,0)
                    wait()
                end
            end)()
        else
            if flyBodyVelocity and flyBodyVelocity.Parent then flyBodyVelocity:Destroy() end
            log("Voo desativado")
        end
    end,
})

------------------ 🛡️ VIDA INFINITA ------------------
local infiniteLifeActive = false
restoreLoop = nil
TabConfig:CreateToggle({
    Name = "Vida Infinita",
    CurrentValue = false,
    Callback = function(state)
        infiniteLifeActive = state
        local player = game.Players.LocalPlayer
        character = player.Character or player.CharacterAdded:Wait()
        humanoid = character:FindFirstChildOfClass("Humanoid")
        if infiniteLifeActive and humanoid then
            restoreLoop = game:GetService("RunService").Heartbeat:Connect(function()
                if humanoid and humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                    log("Vida restaurada: " .. humanoid.MaxHealth)
                end
            end)
        elseif restoreLoop then restoreLoop:Disconnect() log("Loop de vida infinita parado") end
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
        if state then antiKick() else log("AntiKick desativado") end
    end
})

------------------ 🛡️ WEAPON FINDER ------------------
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
log("SCP-TRL.lua carregado! Versão: " .. scriptVersion .. " Executor: " .. getExecutor())

------------------ 🛡️ FIM DO SCRIPT ------------------
