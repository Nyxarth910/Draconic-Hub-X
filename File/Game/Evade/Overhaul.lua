local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
loadstring(game:HttpGet('https://raw.githubusercontent.com/Pnsdgsa/Script-kids/refs/heads/main/Scripthub/Darahub/evade/TimerGUI-NoRepeat'))()
local Window = Fluent:CreateWindow({
    Title = "Draconic-X-Evade ",
    SubTitle = "Overhaul (Unfinished - B Version) Made by Nyxarth910 and Aerave ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local FloatingButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Floating%20Button.lua",true))()
FloatingButton.init(Window)

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" })
}

local Options = Fluent.Options

Fluent:Notify({
    Title = "Draconic X Evade",
    Content = "System Loaded",
    Duration = 3
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Billboard ESP Variables
local NextbotBillboards = {}
local PlayerBillboards = {}
local TicketBillboards = {}

-- Tracer ESP Variables
local playerTracerElements = {}
local botTracerElements = {}
local playerTracerConnection = nil
local botTracerConnection = nil

-- Auto Respawn Variables
local lastSavedPosition = nil
local respawnConnection = nil
local AutoSelfReviveConnection = nil
local hasRevived = false
local SelfReviveMethod = "Spawnpoint"

-- New Feature Variables
local AntiAFKConnection = nil
local autoWhistleHandle = nil
local stableCameraInstance = nil

-- Get nextbot names from ReplicatedStorage
local nextBotNames = {}
if ReplicatedStorage:FindFirstChild("NPCs") then
    for _, npc in ipairs(ReplicatedStorage.NPCs:GetChildren()) do
        table.insert(nextBotNames, npc.Name)
    end
end

function isNextbotModel(model)
    if not model or not model.Name then return false end
    for _, name in ipairs(nextBotNames) do
        if model.Name == name then return true end
    end
    return model.Name:lower():find("nextbot") or 
           model.Name:lower():find("scp") or 
           model.Name:lower():find("monster") or
           model.Name:lower():find("creep") or
           model.Name:lower():find("enemy") or
           model.Name:lower():find("zombie") or
           model.Name:lower():find("ghost") or
           model.Name:lower():find("demon")
end

function getDistanceFromPlayer(targetPosition)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
        return 0 
    end
    local distance = (targetPosition - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    return math.floor(distance)
end

-- ==================== BILLBOARD ESP FUNCTIONS ====================

function CreateBillboardESP(Name, Part, Color, TextSize)
    if not Part or Part:FindFirstChild(Name) then return nil end

    local BillboardGui = Instance.new("BillboardGui")
    local TextLabel = Instance.new("TextLabel")
    local TextStroke = Instance.new("UIStroke")

    BillboardGui.Parent = Part
    BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    BillboardGui.Name = Name
    BillboardGui.AlwaysOnTop = true
    BillboardGui.LightInfluence = 1
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
    BillboardGui.MaxDistance = 1000

    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.TextScaled = false
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.TextSize = TextSize or 14
    TextLabel.TextColor3 = Color or Color3.fromRGB(255, 255, 255)

    TextStroke.Parent = TextLabel
    TextStroke.Thickness = 2
    TextStroke.Color = Color3.new(0, 0, 0)

    return BillboardGui
end

function UpdateBillboardESP(Name, Part, NameText, Color, TextSize)
    if not Part then return false end

    local esp = Part:FindFirstChild(Name)
    if esp and esp:FindFirstChildOfClass("TextLabel") then
        local label = esp:FindFirstChildOfClass("TextLabel")
        
        if Color then
            label.TextColor3 = Color
        end
        
        if TextSize then
            label.TextSize = TextSize
        end
        
        local distance = getDistanceFromPlayer(Part.Position)
        local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
        label.Text = string.format("%s [%dm]", name, distance)
        
        return true
    end
    return false
end

function DestroyBillboardESP(Name, Part)
    if not Part then return false end
    
    local esp = Part:FindFirstChild(Name)
    if esp then
        esp:Destroy()
        return true
    end
    
    return false
end

local function scanForNextbots()
    local nextbots = {}
    
    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
                if hrp then
                    nextbots[model] = hrp
                end
            end
        end
    end
    
    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in ipairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Head")
                if hrp then
                    nextbots[model] = hrp
                end
            end
        end
    end
    
    for model, hrp in pairs(nextbots) do
        if not NextbotBillboards[model] then
            local esp = CreateBillboardESP("NextbotESP", hrp, Color3.fromRGB(255, 0, 0), 16)
            if esp then
                UpdateBillboardESP("NextbotESP", hrp, model.Name, Color3.fromRGB(255, 0, 0), 16)
                NextbotBillboards[model] = {esp = esp, hrp = hrp}
            end
        else
            UpdateBillboardESP("NextbotESP", hrp, model.Name, Color3.fromRGB(255, 0, 0), 16)
        end
    end
    
    for model, data in pairs(NextbotBillboards) do
        if not nextbots[model] or not model.Parent then
            if data.hrp then
                DestroyBillboardESP("NextbotESP", data.hrp)
            end
            NextbotBillboards[model] = nil
        end
    end
end

local function scanForPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if head then
                if not PlayerBillboards[player] then
                    local esp = CreateBillboardESP("PlayerESP", head, Color3.fromRGB(0, 255, 0), 14)
                    if esp then
                        UpdateBillboardESP("PlayerESP", head, player.Name, Color3.fromRGB(0, 255, 0), 14)
                        PlayerBillboards[player] = esp
                    end
                else
                    UpdateBillboardESP("PlayerESP", head, player.Name, Color3.fromRGB(0, 255, 0), 14)
                end
            end
        elseif PlayerBillboards[player] then
            if player.Character then
                DestroyBillboardESP("PlayerESP", player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart"))
            end
            PlayerBillboards[player] = nil
        end
    end
end

local function scanForTickets()
    local gameFolder = workspace:FindFirstChild("Game")
    if gameFolder then
        local effects = gameFolder:FindFirstChild("Effects")
        if effects then
            local tickets = effects:FindFirstChild("Tickets")
            if tickets then
                for _, ticket in pairs(tickets:GetChildren()) do
                    if ticket:IsA("BasePart") or ticket:IsA("Model") then
                        local part = ticket:IsA("Model") and ticket:FindFirstChild("Head") or ticket:IsA("BasePart") and ticket
                        if part then
                            if not TicketBillboards[ticket] then
                                local esp = CreateBillboardESP("TicketESP", part, Color3.fromRGB(255, 255, 0), 12)
                                if esp then
                                    UpdateBillboardESP("TicketESP", part, "Ticket", Color3.fromRGB(255, 255, 0), 12)
                                    TicketBillboards[ticket] = esp
                                end
                            else
                                UpdateBillboardESP("TicketESP", part, "Ticket", Color3.fromRGB(255, 255, 0), 12)
                            end
                        end
                    end
                end
            end
        end
    end
    
    for ticket, esp in pairs(TicketBillboards) do
        if not ticket or not ticket.Parent then
            local part = ticket:IsA("Model") and ticket:FindFirstChild("Head") or ticket
            if part then
                DestroyBillboardESP("TicketESP", part)
            end
            TicketBillboards[ticket] = nil
        end
    end
end

-- ==================== TRACER ESP FUNCTIONS ====================

function createTracerObject()
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.ZIndex = 1
    return tracer
end

function updatePlayerTracers()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                currentTargets[player] = true
                
                if not playerTracerElements[player] then
                    playerTracerElements[player] = createTracerObject()
                end

                local tracer = playerTracerElements[player]
                local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                if onScreen then
                    tracer.Visible = true
                    tracer.From = screenBottomCenter
                    tracer.To = Vector2.new(vector.X, vector.Y)
                    tracer.Color = Color3.fromRGB(0, 255, 0)
                else
                    tracer.Visible = false
                end
            end
        end
    end

    for player, tracer in pairs(playerTracerElements) do
        if not currentTargets[player] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            playerTracerElements[player] = nil
        end
    end
end

function updateBotTracers()
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    local screenBottomCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
    local currentTargets = {}

    local playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in pairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    currentTargets[model] = true
                    
                    if not botTracerElements[model] then
                        botTracerElements[model] = createTracerObject()
                    end

                    local tracer = botTracerElements[model]
                    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        tracer.Visible = true
                        tracer.From = screenBottomCenter
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = Color3.fromRGB(255, 0, 0)
                    else
                        tracer.Visible = false
                    end
                end
            end
        end
    end

    local npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in pairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    currentTargets[model] = true
                    
                    if not botTracerElements[model] then
                        botTracerElements[model] = createTracerObject()
                    end

                    local tracer = botTracerElements[model]
                    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position)

                    if onScreen then
                        tracer.Visible = true
                        tracer.From = screenBottomCenter
                        tracer.To = Vector2.new(vector.X, vector.Y)
                        tracer.Color = Color3.fromRGB(255, 0, 0)
                    else
                        tracer.Visible = false
                    end
                end
            end
        end
    end

    for model, tracer in pairs(botTracerElements) do
        if not currentTargets[model] then
            if tracer and tracer.Remove then
                tracer:Remove()
            end
            botTracerElements[model] = nil
        end
    end
end

function startPlayerTracers()
    if playerTracerConnection then return end
    playerTracerConnection = RunService.RenderStepped:Connect(updatePlayerTracers)
end

function stopPlayerTracers()
    if playerTracerConnection then
        playerTracerConnection:Disconnect()
        playerTracerConnection = nil
    end
    for player, tracer in pairs(playerTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    playerTracerElements = {}
end

function startBotTracers()
    if botTracerConnection then return end
    botTracerConnection = RunService.RenderStepped:Connect(updateBotTracers)
end

function stopBotTracers()
    if botTracerConnection then
        botTracerConnection:Disconnect()
        botTracerConnection = nil
    end
    for model, tracer in pairs(botTracerElements) do
        if tracer and tracer.Remove then
            tracer:Remove()
        end
    end
    botTracerElements = {}
end

-- ==================== AUTO RESPAWN FUNCTIONS ====================

local function startAutoRespawn()
    if AutoSelfReviveConnection then
        AutoSelfReviveConnection:Disconnect()
    end
    if respawnConnection then
        respawnConnection:Disconnect()
    end
    
    local character = LocalPlayer.Character
    if character then
        local humanoid = character:WaitForChild("Humanoid")
        local hrp = character:WaitForChild("HumanoidRootPart")
        
        AutoSelfReviveConnection = character:GetAttributeChangedSignal("Downed"):Connect(function()
            local isDowned = character:GetAttribute("Downed")
            if isDowned then
                if SelfReviveMethod == "Spawnpoint" then
                    if not hasRevived then
                        hasRevived = true
                        pcall(function()
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                        end)
                        task.delay(10, function()
                            hasRevived = false
                        end)
                    end
                elseif SelfReviveMethod == "Fake Revive" then
                    if hrp then
                        lastSavedPosition = hrp.Position
                    end
                    task.wait(3)
                    local startTime = tick()
                    repeat
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                        end)
                    until not character:GetAttribute("Downed") or (tick() - startTime > 1)
                    local newCharacter
                    repeat
                        newCharacter = LocalPlayer.Character
                        task.wait()
                    until newCharacter and newCharacter:FindFirstChild("HumanoidRootPart")
                    local newHRP = newCharacter:FindFirstChild("HumanoidRootPart")
                    if lastSavedPosition and newHRP then
                        newHRP.CFrame = CFrame.new(lastSavedPosition)
                        task.wait(0.5)
                        local movedDistance = (newHRP.Position - lastSavedPosition).Magnitude
                        if movedDistance > 1 then
                            lastSavedPosition = nil
                        end
                    end
                end
            end
        end)
    end
    
    respawnConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        task.wait(1)
        local newHumanoid = newChar:WaitForChild("Humanoid")
        local newHRP = newChar:WaitForChild("HumanoidRootPart")
        
        AutoSelfReviveConnection = newChar:GetAttributeChangedSignal("Downed"):Connect(function()
            local isDowned = newChar:GetAttribute("Downed")
            if isDowned then
                if SelfReviveMethod == "Spawnpoint" then
                    if not hasRevived then
                        hasRevived = true
                        task.wait(3)
                        pcall(function()
                            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                        end)
                        task.delay(10, function()
                            hasRevived = false
                        end)
                    end
                elseif SelfReviveMethod == "Fake Revive" then
                    if newHRP then
                        lastSavedPosition = newHRP.Position
                    end
                    task.wait(3)
                    local startTime = tick()
                    repeat
                        pcall(function()
                            ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                        end)
                        task.wait(1)
                    until not newChar:GetAttribute("Downed") or (tick() - startTime > 1)
                    local freshCharacter
                    repeat
                        freshCharacter = LocalPlayer.Character
                        task.wait()
                    until freshCharacter and freshCharacter:FindFirstChild("HumanoidRootPart")
                    local freshHRP = freshCharacter:FindFirstChild("HumanoidRootPart")
                    if lastSavedPosition and freshHRP then
                        freshHRP.CFrame = CFrame.new(lastSavedPosition)
                        task.wait(0.5)
                        local movedDistance = (freshHRP.Position - lastSavedPosition).Magnitude
                        if movedDistance > 1 then
                            lastSavedPosition = nil
                        end
                    end
                end
            end
        end)
    end)
end

local function stopAutoRespawn()
    if AutoSelfReviveConnection then
        AutoSelfReviveConnection:Disconnect()
        AutoSelfReviveConnection = nil
    end
    if respawnConnection then
        respawnConnection:Disconnect()
        respawnConnection = nil
    end
    hasRevived = false
    lastSavedPosition = nil
end

-- ==================== NEW FEATURES ====================

-- Anti AFK Functions
local function startAntiAFK()
    if AntiAFKConnection then return end
    AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

local function stopAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
end

-- Auto Whistle Functions
local function startAutoWhistle()
    if autoWhistleHandle then return end  
    autoWhistleHandle = task.spawn(function()
        while autoWhistleHandle do
            pcall(function() 
                ReplicatedStorage.Events.Character.Whistle:FireServer()
            end)
            task.wait(1)
        end
    end)
end

local function stopAutoWhistle()
    if autoWhistleHandle then
        task.cancel(autoWhistleHandle)
        autoWhistleHandle = nil
    end
end

-- No Camera Shake Functions
local StableCamera = {}
StableCamera.__index = StableCamera

function StableCamera.new(maxDistance)
    local self = setmetatable({}, StableCamera)
    self.Player = Players.LocalPlayer
    self.MaxDistance = maxDistance or 50
    self._conn = RunService.RenderStepped:Connect(function(dt) self:Update(dt) end)
    return self
end

local function tryResetShake(player)
    if not player then return end
    local ok, playerScripts = pcall(function() return player:FindFirstChild("PlayerScripts") end)
    if not ok or not playerScripts then return end
    local cameraSet = playerScripts:FindFirstChild("Camera") and playerScripts.Camera:FindFirstChild("Set")
    if cameraSet and type(cameraSet.Invoke) == "function" then
        pcall(function()
            cameraSet:Invoke("CFrameOffset", "Shake", CFrame.new())
        end)
    end
end

function StableCamera:Update(dt)
    if Players and Players.LocalPlayer then
        tryResetShake(Players.LocalPlayer)
    end
end

function StableCamera:Destroy()
    if self._conn then
        self._conn:Disconnect()
        self._conn = nil
    end
end

local function startNoCameraShake()
    if stableCameraInstance then return end
    stableCameraInstance = StableCamera.new()
end

local function stopNoCameraShake()
    if stableCameraInstance then
        stableCameraInstance:Destroy()
        stableCameraInstance = nil
    end
end

-- ==================== FLUENT UI SECTIONS ====================

-- Billboard ESP Section
local billboardSection = Tabs.Main:AddSection("Billboard ESP")

local NextbotToggle = Tabs.Main:AddToggle("NextbotToggle", {
    Title = "Nextbots",
    Default = false
})

local PlayerToggle = Tabs.Main:AddToggle("PlayerToggle", {
    Title = "Players",
    Default = false
})

local TicketToggle = Tabs.Main:AddToggle("TicketToggle", {
    Title = "Tickets",
    Default = false
})

-- Tracer ESP Section
local tracerSection = Tabs.Main:AddSection("Tracer ESP")

local TracerPlayerToggle = Tabs.Main:AddToggle("TracerPlayerToggle", {
    Title = "Tracer Players",
    Default = false
})

local TracerBotToggle = Tabs.Main:AddToggle("TracerBotToggle", {
    Title = "Tracer Bots",
    Default = false
})

-- Main Modification Section
local modificationSection = Tabs.Main:AddSection("Main Modification")

local AutoRespawnToggle = Tabs.Main:AddToggle("AutoRespawnToggle", {
    Title = "Auto Respawn",
    Default = false
})

local AutoRespawnTypeDropdown = Tabs.Main:AddDropdown("AutoRespawnTypeDropdown", {
    Title = "Auto Respawn Type",
    Values = {"Spawnpoint", "Fake Revive"},
    Multi = false,
    Default = "Spawnpoint",
})

Tabs.Main:AddParagraph({
    Title = "",
    Content = ""
})

-- New Features Section

local AntiAFKToggle = Tabs.Main:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = false
})

local AutoWhistleToggle = Tabs.Main:AddToggle("AutoWhistleToggle", {
    Title = "Auto Whistle",
    Default = false
})

local NoCameraShakeToggle = Tabs.Main:AddToggle("NoCameraShakeToggle", {
    Title = "No Camera Shake",
    Default = false
})

-- ==================== TOGGLE HANDLERS ====================

-- Billboard ESP Loops
local nextbotLoop
local playerLoop
local ticketLoop

NextbotToggle:OnChanged(function(value)
    if value then
        if not nextbotLoop then
            nextbotLoop = RunService.RenderStepped:Connect(function()
                if Options.NextbotToggle.Value then
                    scanForNextbots()
                end
            end)
        end
    else
        if nextbotLoop then
            nextbotLoop:Disconnect()
            nextbotLoop = nil
        end
        
        for model, data in pairs(NextbotBillboards) do
            if data.hrp then
                DestroyBillboardESP("NextbotESP", data.hrp)
            end
        end
        NextbotBillboards = {}
    end
end)

PlayerToggle:OnChanged(function(value)
    if value then
        if not playerLoop then
            playerLoop = RunService.RenderStepped:Connect(function()
                if Options.PlayerToggle.Value then
                    scanForPlayers()
                end
            end)
        end
    else
        if playerLoop then
            playerLoop:Disconnect()
            playerLoop = nil
        end
        
        for player, esp in pairs(PlayerBillboards) do
            if player.Character then
                DestroyBillboardESP("PlayerESP", player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart"))
            end
        end
        PlayerBillboards = {}
    end
end)

TicketToggle:OnChanged(function(value)
    if value then
        if not ticketLoop then
            ticketLoop = RunService.RenderStepped:Connect(function()
                if Options.TicketToggle.Value then
                    scanForTickets()
                end
            end)
        end
    else
        if ticketLoop then
            ticketLoop:Disconnect()
            ticketLoop = nil
        end
        
        for ticket, esp in pairs(TicketBillboards) do
            local part = ticket:IsA("Model") and ticket:FindFirstChild("Head") or ticket
            if part then
                DestroyBillboardESP("TicketESP", part)
            end
        end
        TicketBillboards = {}
    end
end)

-- Tracer ESP Toggle Handlers
TracerPlayerToggle:OnChanged(function(value)
    if value then
        startPlayerTracers()
    else
        stopPlayerTracers()
    end
end)

TracerBotToggle:OnChanged(function(value)
    if value then
        startBotTracers()
    else
        stopBotTracers()
    end
end)

-- Auto Respawn Toggle Handlers
AutoRespawnToggle:OnChanged(function(value)
    if value then
        startAutoRespawn()
    else
        stopAutoRespawn()
    end
end)

AutoRespawnTypeDropdown:OnChanged(function(value)
    SelfReviveMethod = value
    print("Auto Respawn Type changed to:", value)
end)

-- New Features Toggle Handlers
AntiAFKToggle:OnChanged(function(value)
    if value then
        startAntiAFK()
    else
        stopAntiAFK()
    end
end)

AutoWhistleToggle:OnChanged(function(value)
    if value then
        startAutoWhistle()
    else
        stopAutoWhistle()
    end
end)

NoCameraShakeToggle:OnChanged(function(value)
    if value then
        startNoCameraShake()
    else
        stopNoCameraShake()
    end
end)

-- ==================== SAVE MANAGER ====================

local TimerDisplayToggle = Tabs.Main:AddToggle("TimerDisplayToggle", {
    Title = "Show Timer",
    Default = false
})

local timerDisplayLoop = nil

TimerDisplayToggle:OnChanged(function(state)
    if state then
        if timerDisplayLoop then return end
        
        timerDisplayLoop = RunService.RenderStepped:Connect(function()
            local player = game:GetService("Players").LocalPlayer
            local pg = player.PlayerGui
            
            -- Find the timer display in the game's UI
            local shared = pg:FindFirstChild("Shared")
            local hud = shared and shared:FindFirstChild("HUD")
            local overlay = hud and hud:FindFirstChild("Overlay")
            local default = overlay and overlay:FindFirstChild("Default")
            local ro = default and default:FindFirstChild("RoundOverlay")
            local round = ro and ro:FindFirstChild("Round")
            local timer = round and round:FindFirstChild("RoundTimer")
            
            -- Show/hide the timer based on toggle state
            if timer then
                timer.Visible = true
            end
            
            -- Also check for timer container in main interface
            local main = pg:FindFirstChild("MainInterface")
            if main then
                local container = main:FindFirstChild("TimerContainer")
                if container then
                    container.Visible = true
                end
            end
        end)
    else
        if timerDisplayLoop then
            timerDisplayLoop:Disconnect()
            timerDisplayLoop = nil
        end
        
        -- Hide the timer when toggled off
        local player = game:GetService("Players").LocalPlayer
        local pg = player.PlayerGui
        
        local shared = pg:FindFirstChild("Shared")
        local hud = shared and shared:FindFirstChild("HUD")
        local overlay = hud and hud:FindFirstChild("Overlay")
        local default = overlay and overlay:FindFirstChild("Default")
        local ro = default and default:FindFirstChild("RoundOverlay")
        local round = ro and ro:FindFirstChild("Round")
        local timer = round and round:FindFirstChild("RoundTimer")
        
        if timer then
            timer.Visible = false
        end
        
        local main = pg:FindFirstChild("MainInterface")
        if main then
            local container = main:FindFirstChild("TimerContainer")
            if container then
                container.Visible = false
            end
        end
    end
end)
local billboardSection = Tabs.Main:AddSection("Player Modification")
-- who needs noclip on evade lol it's not even work 
local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false
})

local FlySpeedInput = Tabs.Main:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = "50",
    Placeholder = "Enter speed value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            featureStates.FlySpeed = tonumber(Value)
            print("Fly speed set to:", featureStates.FlySpeed)
        end
    end
})

-- Fly variables
local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local character = LocalPlayer.Character
local humanoid = character and character:FindFirstChild("Humanoid")
local rootPart = character and character:FindFirstChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")

-- Initialize fly speed
featureStates = featureStates or {}
featureStates.FlySpeed = 50

local function startFlying()
    if not character or not humanoid or not rootPart then 
        -- Try to get fresh references
        character = LocalPlayer.Character
        if not character then return end
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
        if not humanoid or not rootPart then return end
    end
    
    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = rootPart
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.Parent = rootPart
    
    humanoid.PlatformStand = true
end

local function stopFlying()
    flying = false
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
    if humanoid then
        humanoid.PlatformStand = false
    end
end

local function updateFly()
    if not flying or not bodyVelocity or not bodyGyro then return end
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera.CFrame
    local direction = Vector3.new(0, 0, 0)
    local moveDirection = humanoid.MoveDirection
    
    if moveDirection.Magnitude > 0 then
        local forwardVector = cameraCFrame.LookVector
        local rightVector = cameraCFrame.RightVector
        local forwardComponent = moveDirection:Dot(forwardVector) * forwardVector
        local rightComponent = moveDirection:Dot(rightVector) * rightVector
        direction = direction + (forwardComponent + rightComponent).Unit * moveDirection.Magnitude
    end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) or humanoid.Jump then
        direction = direction + Vector3.new(0, 1, 0)
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        direction = direction - Vector3.new(0, 1, 0)
    end
    
    local speed = featureStates.FlySpeed or 50
    bodyVelocity.Velocity = direction.Magnitude > 0 and direction.Unit * (speed * 2) or Vector3.new(0, 0, 0)
    bodyGyro.CFrame = cameraCFrame
end

-- Fly loop connection
local flyLoop = nil

-- Character changed event to update references
local characterAddedConnection = nil

FlyToggle:OnChanged(function(state)
    if state then
        -- Set up character tracking
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
        end
        
        characterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
            character = newChar
            task.wait(0.5)
            humanoid = character:WaitForChild("Humanoid")
            rootPart = character:WaitForChild("HumanoidRootPart")
            
            -- Restart flying if it was enabled
            if Options.FlyToggle.Value and flying == false then
                startFlying()
            end
        end)
        
        -- Get current character
        character = LocalPlayer.Character
        if character then
            humanoid = character:FindFirstChild("Humanoid")
            rootPart = character:FindFirstChild("HumanoidRootPart")
        end
        
        startFlying()
        
        -- Start update loop
        if not flyLoop then
            flyLoop = RunService.RenderStepped:Connect(function()
                if Options.FlyToggle.Value then
                    updateFly()
                end
            end)
        end
    else
        stopFlying()
        
        if flyLoop then
            flyLoop:Disconnect()
            flyLoop = nil
        end
        
        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
    end
end)

-- Make sure to disconnect everything when script ends
game:GetService("Players").LocalPlayer.CharacterRemoving:Connect(function()
    if Options.FlyToggle.Value then
        stopFlying()
        if flyLoop then
            flyLoop:Disconnect()
            flyLoop = nil
        end
    end
end)
Tabs.Main:AddParagraph({
    Title = "Manual",
    Content = ""
})
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("DraconicXEvade")
SaveManager:SetFolder("DraconicXEvade/Config")

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
