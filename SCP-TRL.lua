-- === SCP: THE RED LAKE ULTIMATE HUB - VERSÃO CORRIGIDA ===
-- COM TELETRANSPORTE POR CLIQUE E CORREÇÕES DE ERROS
-- ====================================================

-- Função de diagnóstico avançado
local function diagnosticar()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    print("=== DIAGNÓSTICO SCP HUB ===")
    
    -- Verificar God Mode
    print("SISTEMA DE VIDA:")
    if humanoid then
        print("- Humanoid.Health:", humanoid.Health)
        print("- Humanoid.MaxHealth:", humanoid.MaxHealth)
        
        -- Procurar por outros sistemas de vida
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                if string.find(string.lower(obj.Name), "health") or 
                   string.find(string.lower(obj.Name), "hp") or
                   string.find(string.lower(obj.Name), "vida") then
                    print("- Valor alternativo encontrado:", obj.Name, "=", obj.Value)
                end
            end
        end
    end
    
    -- Verificar armas
    print("\nSISTEMA DE ARMAS:")
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") then
            print("- Arma encontrada:", tool.Name)
            for _, obj in pairs(tool:GetDescendants()) do
                if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                    print("  - Valor:", obj.Name, "=", obj.Value, "(Tipo:", obj.ClassName, ")")
                end
            end
        end
    end
    
    print("\n=== FIM DO DIAGNÓSTICO ===")
end

-- Carregar Rayfield com tratamento de erros melhorado
local Rayfield
local sucesso, msg = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not sucesso then
    warn("[ERRO] Falha ao carregar Rayfield:", msg)
    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
        Text = "[ERRO] Biblioteca UI não carregada: " .. tostring(msg),
        Color = Color3.new(1, 0, 0)
    })
    return
end

Rayfield = sucesso and Rayfield or nil

if not Rayfield then
    warn("[ERRO] Rayfield não está disponível")
    return
end

-- Criar janela com tratamento robusto de erros e ícone padrão
local Window
sucesso, msg = pcall(function()
    return Rayfield:CreateWindow({
        Name = "SCP: The Red Lake Hub",
        Icon = 0, -- Usando ícone padrão (0) para evitar erros de template
        LoadingTitle = "Carregando Hub...",
        LoadingSubtitle = "Aguarde...",
        ShowText = "SCP Hub",
        Theme = "DarkBlue",
        ToggleUIKeybind = "H",
        DisableRayfieldPrompts = true, -- Desativar prompts para evitar erros
        DisableBuildWarnings = true, -- Desativar avisos de build
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

if not sucesso or not Window then
    warn("[ERRO] Falha ao criar janela:", msg)
    return
end

-- Notificação inicial
pcall(function()
    Rayfield:Notify({
        Title = "Hub Carregado!",
        Content = "Pressione H para mostrar/esconder. Execute diagnóstico se necessário.",
        Duration = 5,
        Image = 0, -- Usando ícone padrão
    })
end)

-- Variáveis globais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Sistema de persistência robusto
local connections = {}
local originalValues = {}
local activeLoops = {}

-- Função de modificação melhorada
local function manterModificacao(objeto, propriedade, novoValor)
    if not objeto or not objeto.Parent then return end
    
    -- Salvar valor original
    if not originalValues[objeto] then
        originalValues[objeto] = {}
    end
    if originalValues[objeto][propriedade] == nil then
        originalValues[objeto][propriedade] = objeto[propriedade]
    end
    
    -- Parar loop existente
    if activeLoops[objeto] and activeLoops[objeto][propriedade] then
        activeLoops[objeto][propriedade]:Disconnect()
    end
    
    -- Criar novo loop
    local conexao
    conexao = RunService.Heartbeat:Connect(function()
        if objeto and objeto.Parent then
            pcall(function()
                objeto[propriedade] = novoValor
            end)
        else
            conexao:Disconnect()
        end
    end)
    
    if not activeLoops[objeto] then
        activeLoops[objeto] = {}
    end
    activeLoops[objeto][propriedade] = conexao
    table.insert(connections, conexao)
end

-- === SISTEMA DE TELETRANSPORTE POR CLIQUE ===
local teletransporteAtivado = false
local conexaoTeletransporte

local function teletransportarPara(posicao)
    if character and character.PrimaryPart then
        character:SetPrimaryPartCFrame(CFrame.new(posicao))
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

local function onClickTeletransporte()
    if not teletransporteAtivado then return end
    
    local mouse = player:GetMouse()
    if mouse.Target then
        local posicao = mouse.Hit.Position
        teletransportarPara(posicao)
    end
end

-- === AIMBOT OTIMIZADO DO PASTEBIN ===
local aimbotAtivado = false
local conexaoAimbot

-- Função para encontrar jogador mais próximo
local function encontrarJogadorProximo()
    local jogadorMaisProximo = nil
    local distanciaMinima = math.huge
    
    for _, jogadorAlvo in pairs(Players:GetPlayers()) do
        if jogadorAlvo ~= player and jogadorAlvo.Character and jogadorAlvo.Character:FindFirstChild("Humanoid") and jogadorAlvo.Character.Humanoid.Health > 0 then
            local personagemAlvo = jogadorAlvo.Character
            local cabeca = personagemAlvo:FindFirstChild("Head")
            
            if cabeca then
                local posicaoTela, naTela = Camera:WorldToViewportPoint(cabeca.Position)
                local distancia = (Vector2.new(posicaoTela.X, posicaoTela.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if naTela and distancia < distanciaMinima then
                    distanciaMinima = distancia
                    jogadorMaisProximo = jogadorAlvo
                end
            end
        end
    end
    
    return jogadorMaisProximo
end

-- Função de atualização do aimbot
local function atualizarAimbot()
    if not aimbotAtivado then return end
    
    local jogadorAlvo = encontrarJogadorProximo()
    if jogadorAlvo and jogadorAlvo.Character and jogadorAlvo.Character:FindFirstChild("Head") then
        local cabeca = jogadorAlvo.Character.Head
        local vetorDirecao = (cabeca.Position - Camera.CFrame.Position).unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + vetorDirecao)
    end
end

-- Controle do aimbot com tecla F
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        aimbotAtivado = not aimbotAtivado
        pcall(function()
            Rayfield:Notify({
                Title = "Aimbot",
                Content = aimbotAtivado and "ATIVADO (F)" or "DESATIVADO (F)",
                Duration = 2,
                Image = 0,
            })
        end)
    end
end)

-- === ABA: ARMAS ===
local abaArmas = Window:CreateTab("Armas", 0) -- Usando ícone padrão
local secaoArmas = abaArmas:CreateSection("Modificação da G18")

-- Sliders
local sliderDano = abaArmas:CreateSlider({
    Name = "Dano",
    Range = {1, 100},
    Increment = 1,
    Suffix = "Dano",
    CurrentValue = 15,
    Flag = "Dano",
    Callback = function(v) end
})

local sliderCadencia = abaArmas:CreateSlider({
    Name = "Cadência (RPM)",
    Range = {50, 1200},
    Increment = 10,
    Suffix = "RPM",
    CurrentValue = 400,
    Flag = "Cadencia",
    Callback = function(v) end
})

local sliderPente = abaArmas:CreateSlider({
    Name = "Tamanho do Pente",
    Range = {1, 50},
    Increment = 1,
    Suffix = "Munição",
    CurrentValue = 17,
    Flag = "Pente",
    Callback = function(v) end
})

-- Botão de aplicar com diagnóstico
abaArmas:CreateButton({
    Name = "Aplicar Modificações da G18",
    Callback = function()
        local arma = character:FindFirstChild("G18")
        if not arma then
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
        
        local modificacoesAplicadas = 0
        
        -- Tentar múltiplos caminhos para encontrar os valores
        local caminhosParaTestar = {
            "Configuration",
            "GunStats",
            "Values",
            "Stats",
            "" -- Raiz da arma
        }
        
        for _, caminho in pairs(caminhosParaTestar) do
            local config = caminho ~= "" and arma:FindFirstChild(caminho) or arma
            
            if config then
                -- Testar dano
                if config:FindFirstChild("Damage") then
                    manterModificacao(config.Damage, "Value", sliderDano.CurrentValue)
                    modificacoesAplicadas = modificacoesAplicadas + 1
                end
                
                -- Testar cadência
                if config:FindFirstChild("FireRate") then
                    manterModificacao(config.FireRate, "Value", 60 / sliderCadencia.CurrentValue)
                    modificacoesAplicadas = modificacoesAplicadas + 1
                end
                
                -- Testar pente
                if config:FindFirstChild("MagazineSize") then
                    manterModificacao(config.MagazineSize, "Value", sliderPente.CurrentValue)
                    modificacoesAplicadas = modificacoesAplicadas + 1
                elseif config:FindFirstChild("Ammo") then
                    manterModificacao(config.Ammo, "Value", sliderPente.CurrentValue)
                    modificacoesAplicadas = modificacoesAplicadas + 1
                end
            end
        end
        
        pcall(function()
            Rayfield:Notify({
                Title = "RESULTADO",
                Content = modificacoesAplicadas .. " modificações aplicadas!",
                Duration = 3,
                Image = 0,
            })
        end)
        
        if modificacoesAplicadas == 0 then
            diagnosticar()
        end
    end
})

-- Seção do Aimbot
abaArmas:CreateSection("Aimbot")

abaArmas:CreateToggle({
    Name = "Ativar Aimbot",
    CurrentValue = false,
    Flag = "Aimbot",
    Callback = function(valor)
        aimbotAtivado = valor
        if aimbotAtivado then
            conexaoAimbot = RunService.RenderStepped:Connect(atualizarAimbot)
            table.insert(connections, conexaoAimbot)
            pcall(function()
                Rayfield:Notify({
                    Title = "Aimbot ATIVADO",
                    Content = "Use F para alternar",
                    Duration = 3,
                    Image = 0,
                })
            end)
        else
            if conexaoAimbot then
                conexaoAimbot:Disconnect()
                conexaoAimbot = nil
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

abaArmas:CreateParagraph({
    Title = "Controles",
    Content = "Pressione F para ativar/desativar rapidamente"
})

-- === ABA: MOVIMENTO ===
local abaMovimento = Window:CreateTab("Movimento", 0)
local secaoMovimento = abaMovimento:CreateSection("Modificação de Movimento")

local sliderVelocidade = abaMovimento:CreateSlider({
    Name = "Velocidade de Caminhada",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "Studs/s",
    CurrentValue = 16,
    Flag = "Velocidade",
    Callback = function(v) end
})

local sliderPulo = abaMovimento:CreateSlider({
    Name = "Força do Pulo",
    Range = {1, 1000},
    Increment = 1,
    Suffix = "Força",
    CurrentValue = 50,
    Flag = "Pulo",
    Callback = function(v) end
})

-- Botão de aplicar movimento
abaMovimento:CreateButton({
    Name = "Aplicar Modificações de Movimento",
    Callback = function()
        if humanoid then
            manterModificacao(humanoid, "WalkSpeed", sliderVelocidade.CurrentValue)
            manterModificacao(humanoid, "JumpPower", sliderPulo.CurrentValue)
            
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

-- Seção de Teletransporte
abaMovimento:CreateSection("Teletransporte por Clique")

abaMovimento:CreateToggle({
    Name = "Ativar Teletransporte",
    CurrentValue = false,
    Flag = "Teletransporte",
    Callback = function(valor)
        teletransporteAtivado = valor
        if teletransporteAtivado then
            conexaoTeletransporte = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    onClickTeletransporte()
                end
            end)
            table.insert(connections, conexaoTeletransporte)
            pcall(function()
                Rayfield:Notify({
                    Title = "TELETRANSPORTE ATIVADO",
                    Content = "Clique para teletransportar!",
                    Duration = 3,
                    Image = 0,
                })
            end)
        else
            if conexaoTeletransporte then
                conexaoTeletransporte:Disconnect()
                conexaoTeletransporte = nil
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

abaMovimento:CreateParagraph({
    Title = "Como usar",
    Content = "Ative o teletransporte e clique em qualquer lugar para se teletransportar"
})

-- === ABA: JOGADOR ===
local abaJogador = Window:CreateTab("Jogador", 0)
local secaoJogador = abaJogador:CreateSection("Modificações do Jogador")

-- God Mode melhorado
local godModeAtivado = false
local conexaoGodMode
local vidaDeus = 1e9

local function ativarGodMode()
    -- Modificar Humanoid
    if humanoid then
        manterModificacao(humanoid, "MaxHealth", vidaDeus)
        manterModificacao(humanoid, "Health", vidaDeus)
    end
    
    -- Procurar por outros sistemas de vida
    for _, obj in pairs(character:GetDescendants()) do
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            if string.find(string.lower(obj.Name), "health") or 
               string.find(string.lower(obj.Name), "hp") or
               string.find(string.lower(obj.Name), "vida") then
                manterModificacao(obj, "Value", vidaDeus)
            end
        end
    end
    
    -- Bloquear morte
    conexaoGodMode = humanoid.StateChanged:Connect(function(_, novoEstado)
        if novoEstado == Enum.HumanoidStateType.Dead then
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            if humanoid then
                humanoid.Health = vidaDeus
            end
        end
    end)
    
    table.insert(connections, conexaoGodMode)
    
    pcall(function()
        Rayfield:Notify({
            Title = "GOD MODE ATIVADO",
            Content = "Imortalidade ativada!",
            Duration = 3,
            Image = 0,
        })
    end)
end

local function desativarGodMode()
    if conexaoGodMode then
        conexaoGodMode:Disconnect()
        conexaoGodMode = nil
    end
    
    -- Restaurar valores originais
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

abaJogador:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(valor)
        godModeAtivado = valor
        if godModeAtivado then
            ativarGodMode()
        else
            desativarGodMode()
        end
    end
})

-- Botão de diagnóstico
abaJogador:CreateButton({
    Name = "Rodar Diagnóstico",
    Callback = function()
        diagnosticar()
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

-- Sistema de persistência após morte
player.CharacterAdded:Connect(function(novoPersonagem)
    character = novoPersonagem
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
    
    -- Reaplicar movimento
    manterModificacao(humanoid, "WalkSpeed", sliderVelocidade.CurrentValue)
    manterModificacao(humanoid, "JumpPower", sliderPulo.CurrentValue)
    
    -- Reaplicar God Mode
    if godModeAtivado then
        ativarGodMode()
    end
    
    -- Reaplicar Aimbot
    if aimbotAtivado then
        conexaoAimbot = RunService.RenderStepped:Connect(atualizarAimbot)
        table.insert(connections, conexaoAimbot)
    end
    
    -- Reaplicar Teletransporte
    if teletransporteAtivado then
        conexaoTeletransporte = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                onClickTeletransporte()
            end
        end)
        table.insert(connections, conexaoTeletransporte)
    end
end)

-- Botão de unload
abaJogador:CreateButton({
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
        
        -- Desativar tudo
        if conexaoAimbot then
            conexaoAimbot:Disconnect()
            conexaoAimbot = nil
        end
        
        if conexaoGodMode then
            conexaoGodMode:Disconnect()
            conexaoGodMode = nil
        end
        
        if conexaoTeletransporte then
            conexaoTeletransporte:Disconnect()
            conexaoTeletransporte = nil
        end
        
        -- Desconectar todas as conexões
        for _, conexao in pairs(connections) do
            if conexao then
                conexao:Disconnect()
            end
        end
        
        -- Restaurar valores originais
        for objeto, valores in pairs(originalValues) do
            if objeto and objeto.Parent then
                for propriedade, valorOriginal in pairs(valores) do
                    pcall(function()
                        objeto[propriedade] = valorOriginal
                    end)
                end
            end
        end
        
        -- Limpar variáveis
        connections = {}
        originalValues = {}
        activeLoops = {}
        
        -- Fechar Rayfield
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

-- Notificação final
pcall(function()
    Rayfield:Notify({
        Title = "HUB PRONTO",
        Content = "Todos os sistemas carregados!",
        Duration = 3,
        Image = 0,
    })
end)
