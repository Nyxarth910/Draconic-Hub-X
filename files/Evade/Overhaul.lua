local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Window = Fluent:CreateWindow({
    Title = "Draconic-X-Evade ",
    SubTitle = "Overhaul (Unfinished - B Version) Made by Nyxarth910 and Aerave ",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local FloatingButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nyxarth910/Draconic-Hub-X/refs/heads/main/Files/Floating%20Button.lua",true))()
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
 billboardSection = Tabs.Main:AddSection("Billboard ESP")

 NextbotToggle = Tabs.Main:AddToggle("NextbotToggle", {
    Title = "Nextbots",
    Default = false
})

 PlayerToggle = Tabs.Main:AddToggle("PlayerToggle", {
    Title = "Players",
    Default = false
})

 TicketToggle = Tabs.Main:AddToggle("TicketToggle", {
    Title = "Tickets",
    Default = false
})

-- Tracer ESP Section
 tracerSection = Tabs.Main:AddSection("Tracer ESP")

 TracerPlayerToggle = Tabs.Main:AddToggle("TracerPlayerToggle", {
    Title = "Tracer Players",
    Default = false
})

 TracerBotToggle = Tabs.Main:AddToggle("TracerBotToggle", {
    Title = "Tracer Bots",
    Default = false
})

-- Main Modification Section
 modificationSection = Tabs.Main:AddSection("Main Modification")

 AutoRespawnToggle = Tabs.Main:AddToggle("AutoRespawnToggle", {
    Title = "Auto Respawn",
    Default = false
})

 AutoRespawnTypeDropdown = Tabs.Main:AddDropdown("AutoRespawnTypeDropdown", {
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

 AntiAFKToggle = Tabs.Main:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = false
})

 AutoWhistleToggle = Tabs.Main:AddToggle("AutoWhistleToggle", {
    Title = "Auto Whistle",
    Default = false
})

 NoCameraShakeToggle = Tabs.Main:AddToggle("NoCameraShakeToggle", {
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
            
            if timer then
                timer.Visible = true
            end
            
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
 FlyToggle = Tabs.Main:AddToggle("FlyToggle", {
    Title = "Fly",
    Default = false
})

 FlySpeedInput = Tabs.Main:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = "50",
    Placeholder = "Enter speed value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            featureStates.FlySpeed = tonumber(Value)
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
 function manualRevive()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local isDowned = character:GetAttribute("Downed")
    
    if not isDowned then 
        return 
    end
    
    local SelfReviveMethod = Options.AutoRespawnTypeDropdown and Options.AutoRespawnTypeDropdown.Value or "Spawnpoint"
    
    if SelfReviveMethod == "Spawnpoint" then
        pcall(function()
            ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
        end)
        
    elseif SelfReviveMethod == "Fake Revive" then
        local lastSavedPosition = hrp and hrp.Position
        
        if hrp then
            lastSavedPosition = hrp.Position
        end
        
        task.spawn(function()
            task.wait(3)
            local startTime = tick()
            repeat
                pcall(function()
                    ReplicatedStorage:WaitForChild("Events"):WaitForChild("Player"):WaitForChild("ChangePlayerMode"):FireServer(true)
                end)
                task.wait(1)
            until not character:GetAttribute("Downed") or (tick() - startTime > 1)
            
            local newCharacter
            repeat
                newCharacter = player.Character
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
        end)
    end
end

 RespawnButton = Tabs.Main:AddButton({
    Title = "Respawn Button",
    Callback = function()
        local CoreGui = game:GetService("CoreGui")
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")
        
        if existingScreenGui then
            existingScreenGui:Destroy()
        else
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "DraconicRespawnButtonGUI"
            screenGui.ResetOnSpawn = false
            screenGui.Parent = CoreGui
            
            local function createGradientButton(parent, position, size, text)
                local button = Instance.new("Frame")
                button.Name = "GradientBtn"
                button.BackgroundTransparency = 0.7
                button.Size = size
                button.Position = position
                button.Draggable = true
                button.Active = true
                button.Selectable = true
                button.Parent = parent

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(1, 0)
                corner.Parent = button

                local gradient = Instance.new("UIGradient")
                gradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }
                gradient.Rotation = 45
                gradient.Parent = button

                local stroke = Instance.new("UIStroke")
                stroke.Color = Color3.fromRGB(120, 0, 0)
                stroke.Thickness = 2
                stroke.Parent = button

                local label = Instance.new("TextLabel")
                label.Text = text
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextSize = 30
                label.Font = Enum.Font.GothamMedium
                label.Parent = button

                local clicker = Instance.new("TextButton")
                clicker.Size = UDim2.new(1, 0, 1, 0)
                clicker.BackgroundTransparency = 1
                clicker.Text = ""
                clicker.ZIndex = 5
                clicker.Active = false
                clicker.Selectable = false
                clicker.Parent = button

                clicker.MouseButton1Click:Connect(function()
                    manualRevive()
                end)

                clicker.MouseEnter:Connect(function()
                    stroke.Color = Color3.fromRGB(160, 0, 0)
                end)

                clicker.MouseLeave:Connect(function()
                    stroke.Color = Color3.fromRGB(120, 0, 0)
                end)

                return button, clicker, stroke
            end
            
            local buttonSize = 200
            if Options.RespawnButtonSizeInput and Options.RespawnButtonSizeInput.Value and tonumber(Options.RespawnButtonSizeInput.Value) then
                buttonSize = tonumber(Options.RespawnButtonSizeInput.Value)
            end
            
            local btnWidth = math.max(150, math.min(buttonSize, 400))
            local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
            
            local btn, clicker, stroke = createGradientButton(
                screenGui,
                UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
                UDim2.new(0, btnWidth, 0, btnHeight),
                "RESPAWN"
            )
        end
    end
})

 RespawnButtonSizeInput = Tabs.Main:AddInput("RespawnButtonSizeInput", {
    Title = "Button Size",
    Default = "200",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("DraconicRespawnButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})
 LeaderboardToggle = Tabs.Main:AddButton({
    Title = "Open Leaderboard",
    Callback = function()
        local playerScripts = game:GetService("Players").LocalPlayer.PlayerScripts
        
        local ohTable1 = {
            ["Down"] = true,
            ["Key"] = "Leaderboard"
        }
        
        playerScripts.Events.temporary_events.UseKeybind:Fire(ohTable1)
        
        task.wait(0.1)
        
        local ohTable2 = {
            ["Down"] = false,
            ["Key"] = "Leaderboard"
        }
        
        playerScripts.Events.temporary_events.UseKeybind:Fire(ohTable2)
    end
})
if not workspace:FindFirstChild("SecurityPart") then
    local SecurityPart = Instance.new("Part")
    SecurityPart.Name = "SecurityPart"
    SecurityPart.Size = Vector3.new(10, 1, 10)
    SecurityPart.Position = Vector3.new(5000, 5000, 5000)
    SecurityPart.Anchored = true
    SecurityPart.CanCollide = true
    SecurityPart.Parent = workspace
end

local AutoTab = Window:AddTab({ Title = "Auto Farm", Icon = "clock" })

AutoTab:AddSection("Farmings")

AutoMoneyFarmToggle = AutoTab:AddToggle("AutoMoneyFarmToggle", {
    Title = "Auto Farm Money",
    Default = false
})

AutoTicketFarmToggle = AutoTab:AddToggle("AutoTicketFarmToggle", {
    Title = "Auto Farm Tickets",
    Default = false
})

AFKFarmToggle = AutoTab:AddToggle("AFKFarmToggle", {
    Title = "AFK Farm",
    Default = false
})


AutoTab:AddParagraph({
    Title = "Teleports",
})

TeleportObjectiveButton = AutoTab:AddButton({
    Title = "Teleport to Objective",
    Callback = function()
        local objectives = {}
        
        local gameFolder = workspace:FindFirstChild("Game")
        if not gameFolder then return end
        
        local mapFolder = gameFolder:FindFirstChild("Map")
        if not mapFolder then return end
        
        local partsFolder = mapFolder:FindFirstChild("Parts")
        if not partsFolder then return end
        
        local objectivesFolder = partsFolder:FindFirstChild("Objectives")
        if not objectivesFolder then return end
        
        for _, obj in pairs(objectivesFolder:GetChildren()) do
            if obj:IsA("Model") then
                local primaryPart = obj.PrimaryPart
                if not primaryPart then
                    for _, part in pairs(obj:GetChildren()) do
                        if part:IsA("BasePart") then
                            primaryPart = part
                            break
                        end
                    end
                end
                
                if primaryPart then
                    table.insert(objectives, {
                        Name = obj.Name,
                        Part = primaryPart,
                        Position = primaryPart.Position,
                        Size = primaryPart.Size
                    })
                end
            end
        end
        
        if #objectives == 0 then
            return
        end
        
        local selectedObjective = objectives[math.random(1, #objectives)]
        
        local character = LocalPlayer.Character
        if not character then return end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end
        
        local teleportPosition = selectedObjective.Position + Vector3.new(0, 5, 0)
        
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local ray = workspace:Raycast(teleportPosition, Vector3.new(0, -10, 0), raycastParams)
        if ray then
            teleportPosition = ray.Position + Vector3.new(0, 3, 0)
        end
        
        humanoidRootPart.CFrame = CFrame.new(teleportPosition)
    end
})
AutoMoneyFarmConnection = nil
AutoWinConnection = nil
AutoTicketFarmConnection = nil
AutoReviveModule = nil

character = LocalPlayer.Character
humanoid = character and character:FindFirstChild("Humanoid")
rootPart = character and character:FindFirstChild("HumanoidRootPart")

function startAutoWin()
    if AutoWinConnection then return end
    
    AutoWinConnection = RunService.Heartbeat:Connect(function()
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then return end
        
        local currentCharacter = LocalPlayer.Character
        if not currentCharacter then return end
        
        local currentRootPart = currentCharacter:FindFirstChild("HumanoidRootPart")
        if not currentRootPart then return end
        
        if not currentCharacter:GetAttribute("Downed") then
            currentRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end

function stopAutoWin()
    if AutoWinConnection then
        AutoWinConnection:Disconnect()
        AutoWinConnection = nil
    end
end

function initAutoReviveModule()
    local reviveRange = 10
    local loopDelay = 0.15
    local autoReviveEnabled = false
    local reviveLoopHandle = nil
    local interactEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

    function isPlayerDowned(pl)
        if not pl or not pl.Character then return false end
        local char = pl.Character
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health <= 0 then
            return true
        end
        if char.GetAttribute and char:GetAttribute("Downed") == true then
            return true
        end
        return false
    end

    function startAutoRevive()
        if reviveLoopHandle then return end
        reviveLoopHandle = task.spawn(function()
            while autoReviveEnabled do
                local currentPlayer = Players.LocalPlayer
                if currentPlayer and currentPlayer.Character and currentPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local myHRP = currentPlayer.Character.HumanoidRootPart
                    for _, pl in ipairs(Players:GetPlayers()) do
                        if pl ~= currentPlayer then
                            local char = pl.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                if isPlayerDowned(pl) then
                                    local hrp = char.HumanoidRootPart
                                    local success, dist = pcall(function()
                                        return (myHRP.Position - hrp.Position).Magnitude
                                    end)
                                    if success and dist and dist <= reviveRange then
                                        pcall(function()
                                            interactEvent:FireServer("Revive", true, pl.Name)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
                task.wait(loopDelay)
            end
            reviveLoopHandle = nil
        end)
    end

    function stopAutoRevive()
        autoReviveEnabled = false
    end

    function ToggleAutoRevive(state)
        if state == nil then
            autoReviveEnabled = not autoReviveEnabled
        else
            autoReviveEnabled = (state == true)
        end
        if autoReviveEnabled then
            startAutoRevive()
        else
            stopAutoRevive()
        end
    end

    function SetReviveRange(range)
        if type(range) == "number" and range > 0 then
            reviveRange = range
        end
    end

    return {
        Toggle = ToggleAutoRevive,
        Start = function() ToggleAutoRevive(true) end,
        Stop = function() ToggleAutoRevive(false) end,
        SetRange = SetReviveRange,
        IsEnabled = function() return autoReviveEnabled end,
    }
end

function startAutoMoneyFarm()
    if AutoMoneyFarmConnection then return end
    
    if not AutoReviveModule then
        AutoReviveModule = initAutoReviveModule()
    end
    
    AutoReviveModule.Start()
    
    AutoMoneyFarmConnection = RunService.Heartbeat:Connect(function()
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then return end
        
        local currentCharacter = LocalPlayer.Character
        if not currentCharacter then return end
        
        local currentRootPart = currentCharacter:FindFirstChild("HumanoidRootPart")
        if not currentRootPart then return end
        
        local downedPlayerFound = false
        local playersInGame = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
        
        if playersInGame then
            for _, v in pairs(playersInGame:GetChildren()) do
                if v:IsA("Model") and v:GetAttribute("Downed") then
                    if v:FindFirstChild("RagdollConstraints") then
                        continue
                    end
                    
                    local vHrp = v:FindFirstChild("HumanoidRootPart")
                    if vHrp then
                        currentRootPart.CFrame = vHrp.CFrame + Vector3.new(0, 3, 0)
                        pcall(function()
                            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", true, v)
                        end)
                        task.wait(0.5)
                        downedPlayerFound = true
                        break
                    end
                end
            end
        end
        
        if not downedPlayerFound then
            currentRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
        end
    end)
end

function stopAutoMoneyFarm()
    if AutoMoneyFarmConnection then
        AutoMoneyFarmConnection:Disconnect()
        AutoMoneyFarmConnection = nil
    end
    
    if AutoReviveModule then
        AutoReviveModule.Stop()
    end
end

AutoMoneyFarmToggle:OnChanged(function(state)
    if state then
        startAutoMoneyFarm()
    else
        stopAutoMoneyFarm()
    end
end)

AFKFarmToggle:OnChanged(function(state)
    if state then
        startAutoWin()
    else
        stopAutoWin()
    end
end)

AutoTicketFarmToggle:OnChanged(function(state)
    local yOffset = 15
    local currentTicket = nil
    local ticketProcessedTime = 0

    if state then
        local securityPart = workspace:FindFirstChild("SecurityPart")
        if not securityPart then
            return
        end

        if AutoTicketFarmConnection then
            AutoTicketFarmConnection:Disconnect()
        end
        
        AutoTicketFarmConnection = RunService.Heartbeat:Connect(function()
            local character = LocalPlayer.Character
            if not character then return end
            
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            local tickets = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Effects") and workspace.Game.Effects:FindFirstChild("Tickets")

            if character:GetAttribute("Downed") then
                pcall(function()
                    ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
                end)
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                return
            end

            if tickets then
                local activeTickets = tickets:GetChildren()
                if #activeTickets > 0 then
                    if not currentTicket or not currentTicket.Parent then
                        currentTicket = activeTickets[1]
                        ticketProcessedTime = tick()
                    end

                    if currentTicket and currentTicket.Parent then
                        local ticketPart = currentTicket:FindFirstChild("HumanoidRootPart") or currentTicket:IsA("BasePart") and currentTicket
                        if ticketPart then
                            local targetPosition = ticketPart.Position + Vector3.new(0, yOffset, 0)
                            humanoidRootPart.CFrame = CFrame.new(targetPosition)
                            
                            if tick() - ticketProcessedTime > 0.1 then
                                humanoidRootPart.CFrame = ticketPart.CFrame
                            end
                        else
                            currentTicket = nil
                        end
                    else
                        humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                        currentTicket = nil
                    end
                else
                    humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                    currentTicket = nil
                end
            else
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
                currentTicket = nil
            end
        end)
    else
        if AutoTicketFarmConnection then
            AutoTicketFarmConnection:Disconnect()
            AutoTicketFarmConnection = nil
        end
        currentTicket = nil
        local character = LocalPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            local securityPart = workspace:FindFirstChild("SecurityPart")
            if humanoidRootPart and securityPart then
                humanoidRootPart.CFrame = securityPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
end)

CombatTab = Window:AddTab({ Title = "Combat", Icon = "swords" })

CombatTab:AddSection("Anti-Nextbot")

featureStates.AntiNextbot = false
featureStates.AntiNextbotTeleportType = "Distance"
featureStates.AntiNextbotDistance = 50
featureStates.DistanceTeleport = 20

PathfindingService = game:GetService("PathfindingService")

antiNextbotConnection = nil
farmsSuppressedByAntiNextbot = false
previousMoneyFarm = false
previousTicketFarm = false
previousAutoWin = false

function handleAntiNextbot()
    if not featureStates.AntiNextbot then return end

    character = Players.LocalPlayer.Character
    humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    nextbots = {}
    npcsFolder = workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, model in ipairs(npcsFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(nextbots, model)
                end
            end
        end
    end

    playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
    if playersFolder then
        for _, model in ipairs(playersFolder:GetChildren()) do
            if model:IsA("Model") and isNextbotModel(model) then
                hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    table.insert(nextbots, model)
                end
            end
        end
    end

    for _, nextbot in ipairs(nextbots) do
        nextbotHrp = nextbot:FindFirstChild("HumanoidRootPart")
        if nextbotHrp then
            distance = (humanoidRootPart.Position - nextbotHrp.Position).Magnitude
            if distance <= featureStates.AntiNextbotDistance then
                if featureStates.AntiNextbotTeleportType == "Players" then
                    validPlayers = {}
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                            table.insert(validPlayers, plr)
                        end
                    end
                    if #validPlayers > 0 then
                        randomPlayer = validPlayers[math.random(1, #validPlayers)]
                        humanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                    end
                elseif featureStates.AntiNextbotTeleportType == "Spawn" then
                    spawnsFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Map") and workspace.Game.Map:FindFirstChild("Parts") and workspace.Game.Map.Parts:FindFirstChild("Spawns")
                    if spawnsFolder then
                        spawnLocations = spawnsFolder:GetChildren()
                        if #spawnLocations > 0 then
                            randomSpawn = spawnLocations[math.random(1, #spawnLocations)]
                            humanoidRootPart.CFrame = randomSpawn.CFrame + Vector3.new(0, 3, 0)
                        end
                    end
                elseif featureStates.AntiNextbotTeleportType == "Distance" then
                    direction = (humanoidRootPart.Position - nextbotHrp.Position).Unit
                    targetPos = humanoidRootPart.Position + direction * featureStates.DistanceTeleport

                    path = PathfindingService:CreatePath({
                        AgentRadius = 2,
                        AgentHeight = 5,
                        AgentCanJump = true
                    })

                    success, errorMessage = pcall(function()
                        path:ComputeAsync(humanoidRootPart.Position, targetPos)
                    end)

                    if success and path.Status == Enum.PathStatus.Success then
                        waypoints = path:GetWaypoints()
                        if #waypoints > 1 then
                            lastValidPos = waypoints[#waypoints].Position
                            distanceToTarget = (lastValidPos - humanoidRootPart.Position).Magnitude
                            if distanceToTarget <= featureStates.DistanceTeleport then
                                humanoidRootPart.CFrame = CFrame.new(lastValidPos + Vector3.new(0, 3, 0))
                            else
                                for i = #waypoints, 1, -1 do
                                    waypointPos = waypoints[i].Position
                                    if (waypointPos - humanoidRootPart.Position).Magnitude <= featureStates.DistanceTeleport then
                                        humanoidRootPart.CFrame = CFrame.new(waypointPos + Vector3.new(0, 3, 0))
                                        break
                                    end
                                end
                            end
                        end
                    else
                        fallbackPos = humanoidRootPart.Position + direction * featureStates.DistanceTeleport
                        ray = Ray.new(humanoidRootPart.Position, direction * featureStates.DistanceTeleport)
                        hit, hitPos = workspace:FindPartOnRayWithIgnoreList(ray, {character, nextbot})
                        if not hit then
                            humanoidRootPart.CFrame = CFrame.new(fallbackPos + Vector3.new(0, 3, 0))
                        else
                            humanoidRootPart.CFrame = CFrame.new(hitPos + Vector3.new(0, 3, 0))
                        end
                    end
                end
                break
            end
        end
    end
end

task.spawn(function()
    while true do
        if featureStates.AntiNextbot then
            pcall(handleAntiNextbot)
        end
        task.wait(0.1)
    end
end)

AntiNextbotToggle = CombatTab:AddToggle("AntiNextbotToggle", {
    Title = "Anti-Nextbot",
    Default = false
})

AntiNextbotTeleportTypeDropdown = CombatTab:AddDropdown("AntiNextbotTeleportTypeDropdown", {
    Title = "Teleport Type",
    Values = {"Players", "Spawn", "Distance"},
    Multi = false,
    Default = "Distance"
})

AntiNextbotDistanceInput = CombatTab:AddInput("AntiNextbotDistanceInput", {
    Title = "Detection Distance",
    Default = "50",
    Placeholder = "Enter distance",
    Numeric = true,
    Finished = false
})

DistanceTeleportInput = CombatTab:AddInput("DistanceTeleportInput", {
    Title = "Teleport Distance",
    Default = "20",
    Placeholder = "Enter distance",
    Numeric = true,
    Finished = false
})

AntiNextbotToggle:OnChanged(function(state)
    featureStates.AntiNextbot = state
    
    if state then
        antiNextbotConnection = RunService.Heartbeat:Connect(function()
            if not featureStates.AntiNextbot then return end
            
            character = player.Character
            humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then return end
            
            nearestDistance = math.huge
            nearestNextbot = nil
            playersFolder = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
            npcsFolder = workspace:FindFirstChild("NPCs")
            
            if playersFolder then
                for _, model in pairs(playersFolder:GetChildren()) do
                    if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                        dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if dist < nearestDistance then
                            nearestDistance = dist
                            nearestNextbot = model
                        end
                    end
                end
            end
            
            if npcsFolder then
                for _, model in pairs(npcsFolder:GetChildren()) do
                    if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and isNextbotModel(model) then
                        dist = (model.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                        if dist < nearestDistance then
                            nearestDistance = dist
                            nearestNextbot = model
                        end
                    end
                end
            end
            
            threshold = featureStates.AntiNextbotDistance
            isTooClose = (nearestDistance < threshold)
            
            if isTooClose and not farmsSuppressedByAntiNextbot then
                previousMoneyFarm = Options.AutoMoneyFarmToggle.Value
                previousTicketFarm = Options.AutoTicketFarmToggle.Value
                previousAutoWin = Options.AFKFarmToggle.Value
                
                if Options.AutoMoneyFarmToggle.Value then
                    Options.AutoMoneyFarmToggle:Set(false)
                end
                if Options.AutoTicketFarmToggle.Value then
                    Options.AutoTicketFarmToggle:Set(false)
                end
                if Options.AFKFarmToggle.Value then
                    Options.AFKFarmToggle:Set(false)
                end
                
                farmsSuppressedByAntiNextbot = true
            elseif not isTooClose and farmsSuppressedByAntiNextbot then
                if previousMoneyFarm then
                    Options.AutoMoneyFarmToggle:Set(true)
                end
                if previousTicketFarm then
                    Options.AutoTicketFarmToggle:Set(true)
                end
                if previousAutoWin then
                    Options.AFKFarmToggle:Set(true)
                end
                
                farmsSuppressedByAntiNextbot = false
            end
            
            if isTooClose then
                safePart = workspace:FindFirstChild("SecurityPart")
                if safePart then
                    humanoidRootPart.CFrame = safePart.CFrame + Vector3.new(math.random(-5, 5), 3, math.random(-5, 5))
                end
            end
        end)
    else
        if antiNextbotConnection then
            antiNextbotConnection:Disconnect()
            antiNextbotConnection = nil
        end
        if farmsSuppressedByAntiNextbot then
            if previousMoneyFarm then
                Options.AutoMoneyFarmToggle:Set(true)
            end
            if previousTicketFarm then
                Options.AutoTicketFarmToggle:Set(true)
            end
            if previousAutoWin then
                Options.AFKFarmToggle:Set(true)
            end
            
            farmsSuppressedByAntiNextbot = false
        end
    end
end)

AntiNextbotTeleportTypeDropdown:OnChanged(function(value)
    featureStates.AntiNextbotTeleportType = value
end)

AntiNextbotDistanceInput:OnChanged(function(value)
    num = tonumber(value)
    if num and num > 0 then
        featureStates.AntiNextbotDistance = num
    end
end)

DistanceTeleportInput:OnChanged(function(value)
    num = tonumber(value)
    if num and num > 0 then
        featureStates.DistanceTeleport = num
    end
end)
 MiscTab = Window:AddTab({ Title = "Misc", Icon = "star" })
MiscTab:AddSection("Player Adjustments")
local currentSettings = {
    Speed = "1500",
    JumpCap = "1",
    AirStrafeAcceleration = "187"
}
local appliedOnce = false
local playerModelPresent = false
local gameStatsPath = workspace:WaitForChild("Game"):WaitForChild("Stats")
getgenv().ApplyMode = "Not Optimized"
local requiredFields = {
    Friction = true,
    AirStrafeAcceleration = true,
    JumpHeight = true,
    RunDeaccel = true,
    JumpSpeedMultiplier = true,
    JumpCap = true,
    SprintCap = true,
    WalkSpeedMultiplier = true,
    BhopEnabled = true,
    Speed = true,
    AirAcceleration = true,
    RunAccel = true,
    SprintAcceleration = true
}

local function hasAllFields(tbl)
    if type(tbl) ~= "table" then return false end
    for field, _ in pairs(requiredFields) do
        if rawget(tbl, field) == nil then return false end
    end
    return true
end

local function getConfigTables()
    local tables = {}
    for _, obj in ipairs(getgc(true)) do
        local success, result = pcall(function()
            if hasAllFields(obj) then return obj end
        end)
        if success and result then
            table.insert(tables, result)
        end
    end
    return tables
end

local function applyToTables(callback)
    local targets = getConfigTables()
    if #targets == 0 then return end
    
    if getgenv().ApplyMode == "Optimized" then
        task.spawn(function()
            for i, tableObj in ipairs(targets) do
                if tableObj and typeof(tableObj) == "table" then
                    pcall(callback, tableObj)
                end
                
                if i % 3 == 0 then
                    task.wait()
                end
            end
        end)
    else
        for i, tableObj in ipairs(targets) do
            if tableObj and typeof(tableObj) == "table" then
                pcall(callback, tableObj)
            end
        end
    end
end

local function applyStoredSettings()
    local settings = {
        {field = "Speed", value = tonumber(currentSettings.Speed)},
        {field = "JumpCap", value = tonumber(currentSettings.JumpCap)},
        {field = "AirStrafeAcceleration", value = tonumber(currentSettings.AirStrafeAcceleration)}
    }
    
    for _, setting in ipairs(settings) do
        if setting.value and tostring(setting.value) ~= "1500" and tostring(setting.value) ~= "1" and tostring(setting.value) ~= "187" then
            applyToTables(function(obj)
                obj[setting.field] = setting.value
            end)
        end
    end
end

local function applySettingsWithDelay()
    if not playerModelPresent or appliedOnce then
        return
    end
    
    appliedOnce = true
    
    local settings = {
        {field = "Speed", value = tonumber(currentSettings.Speed), delay = math.random(1, 14)},
        {field = "JumpCap", value = tonumber(currentSettings.JumpCap), delay = math.random(1, 14)},
        {field = "AirStrafeAcceleration", value = tonumber(currentSettings.AirStrafeAcceleration), delay = math.random(1, 14)}
    }
    
    for _, setting in ipairs(settings) do
        if setting.value and tostring(setting.value) ~= "1500" and tostring(setting.value) ~= "1" and tostring(setting.value) ~= "187" then
            task.spawn(function()
                task.wait(setting.delay)
                applyToTables(function(obj)
                    obj[setting.field] = setting.value
                end)
            end)
        end
    end
end

local function isPlayerModelPresent()
    local GameFolder = workspace:FindFirstChild("Game")
    local PlayersFolder = GameFolder and GameFolder:FindFirstChild("Players")
    return PlayersFolder and PlayersFolder:FindFirstChild(player.Name) ~= nil
end

SpeedInput = MiscTab:AddInput("SpeedInput", {
    Title = "Player Speed",
    Default = currentSettings.Speed,
    Placeholder = "Default 1500",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 1450 and val <= 100008888 then
            currentSettings.Speed = tostring(val)
            applyToTables(function(obj)
                obj.Speed = val
            end)
        end
    end
})

JumpPowerInput = MiscTab:AddInput("JumpPowerInput", {
    Title = "Player Jump",
    Default = "3",
    Placeholder = "",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        if Value and tonumber(Value) then
            JumpPowerValue = tonumber(Value)
        end
    end
})

JumpCapInput = MiscTab:AddInput("JumpCapInput", {
    Title = "Player Jump Cap",
    Default = currentSettings.JumpCap,
    Placeholder = "Default 1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 0.1 and val <= 5088888 then
            currentSettings.JumpCap = tostring(val)
            applyToTables(function(obj)
                obj.JumpCap = val
            end)
        end
    end
})

StrafeInput = MiscTab:AddInput("StrafeInput", {
    Title = "Player Strafe Acceleration",
    Default = currentSettings.AirStrafeAcceleration,
    Placeholder = "Default 187",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local val = tonumber(Value)
        if val and val >= 1 and val <= 1000888888 then
            currentSettings.AirStrafeAcceleration = tostring(val)
            applyToTables(function(obj)
                obj.AirStrafeAcceleration = val
            end)
        end
    end
})

ApplyMethodDropdown = MiscTab:AddDropdown("ApplyMethodDropdown", {
    Title = "Select Apply Method",
    Values = {"Not Optimized", "Optimized"},
    Multi = false,
    Default = getgenv().ApplyMode,
    Callback = function(Value)
        getgenv().ApplyMode = Value
    end
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChangeSettingRemote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Data"):WaitForChild("ChangeSetting")
local UpdatedEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Client"):WaitForChild("Settings"):WaitForChild("Updated")

FovInput = MiscTab:AddInput("FovInput", {
    Title = "Player FOV",
    Default = "",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            ChangeSettingRemote:InvokeServer(2, num)
            UpdatedEvent:Fire(2, num)
        end
    end
})

JumpPowerValue = 3
MaxJumpsValue = math.huge

CurrentJumpCount = 0
JumpHumanoid = nil
JumpRootPart = nil

Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    JumpHumanoid = newChar:FindFirstChild("Humanoid")
    JumpRootPart = newChar:FindFirstChild("HumanoidRootPart")
    if JumpHumanoid and JumpRootPart then
        CurrentJumpCount = 0
        JumpHumanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed then
                CurrentJumpCount = 0
            end
        end)
        JumpHumanoid.Jumping:Connect(function(isJumping)
            if isJumping and CurrentJumpCount < MaxJumpsValue then
                CurrentJumpCount = CurrentJumpCount + 1
                JumpHumanoid.JumpHeight = JumpPowerValue
                if CurrentJumpCount > 1 and JumpRootPart then
                    JumpRootPart:ApplyImpulse(Vector3.new(0, JumpPowerValue * JumpRootPart.Mass, 0))
                end
            end
        end)
    end
end)

-- Handle initial character
if Players.LocalPlayer.Character then
    task.spawn(function()
        task.wait(0.5)
        JumpHumanoid = Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        JumpRootPart = Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if JumpHumanoid and JumpRootPart then
            CurrentJumpCount = 0
            JumpHumanoid.StateChanged:Connect(function(oldState, newState)
                if newState == Enum.HumanoidStateType.Landed then
                    CurrentJumpCount = 0
                end
            end)
            JumpHumanoid.Jumping:Connect(function(isJumping)
                if isJumping and CurrentJumpCount < MaxJumpsValue then
                    CurrentJumpCount = CurrentJumpCount + 1
                    JumpHumanoid.JumpHeight = JumpPowerValue
                    if CurrentJumpCount > 1 and JumpRootPart then
                        JumpRootPart:ApplyImpulse(Vector3.new(0, JumpPowerValue * JumpRootPart.Mass, 0))
                    end
                end
            end)
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    task.wait(0.5)
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
end)
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
--====FAILED TO DECOMPILED CODE====--
JumpPowerToggle = MiscTab:AddToggle("JumpPowerToggle", {
    Title = "Jump Power Toggle",
    Default = false
})

JumpPowerToggle:OnChanged(function()
    --====FAILED TO EXECUTE FUNCTION====--
end)

--====FAILED TO DECOMPILED CODE====--
PlayerJumpPowerInput = MiscTab:AddInput("PlayerJumpPowerInput", {
    Title = "Player Jump Power",
    Default = "Failed To Decode",
    Placeholder = "Failed To Decode",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        --====FAILED TO EXECUTE CALLBACK====--
    end
})

--====FAILED TO DECOMPILED CODE====--
WalkspeedToggle = MiscTab:AddToggle("WalkspeedToggle", {
    Title = "Walkspeed Toggle",
    Default = false
})

WalkspeedToggle:OnChanged(function()
    --====FAILED TO EXECUTE FUNCTION====--
end)

--====FAILED TO DECOMPILED CODE====--
PlayerWalkspeedInput = MiscTab:AddInput("PlayerWalkspeedInput", {
    Title = "Player Walkspeed",
    Default = "Failed To Decode",
    Placeholder = "Failed To Decode",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        --====FAILED TO EXECUTE CALLBACK====--
    end
})
--====FAILED TO DECOMPILED CODE====--
BounceToggle = MiscTab:AddToggle("WalkspeedToggle", {
    Title = "Walkspeed Toggle",
    Default = false
})

BounceToggle:OnChanged(function()
    --====FAILED TO EXECUTE FUNCTION====--
end)

--====FAILED TO DECOMPILED CODE====--
BounceInput = MiscTab:AddInput("BounceInput", {
    Title = "Player Walkspeed",
    Default = "Failed To Decode",
    Placeholder = "Failed To Decode",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        --====FAILED TO EXECUTE CALLBACK====--
    end
})
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
BounceToggle = MiscTab:AddToggle("BounceToggle", {
    Title = "Modify Bounce",
    Default = false
    --[[ FAILED TO DECOMPILE FUNCTION]]
})

BounceInput = MiscTab:AddInput("BounceInput", {
    Title = "Player Bounce",
    Default = "80",
    Placeholder = "Failed to Decode",
    Numeric = true,
    Finished = false
})

MiscTab:AddSection("Game Automations")


local InstantReviveToggle = MiscTab:AddToggle("InstantReviveToggle", {
    Title = "Instant Revive",
    Default = false
})

local ReviveWhileEmoteToggle = MiscTab:AddToggle("ReviveWhileEmoteToggle", {
    Title = "Instant Revive While Emoting",
    Default = false
})

local ReviveDelaySlider = MiscTab:AddSlider("ReviveDelaySlider", {
    Title = "Revive Delay",
    Min = 0,
    Max = 1,
    Default = 0.15,
    Rounding = 2,
    Callback = function(value)
        getgenv().InstantReviveDelay = value
    end
})
getgenv().InstantReviveDelay = 0.15

local InstantReviveModule = (function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local reviveRange = 10
    local loopDelay = getgenv().InstantReviveDelay or 0.15

    local enabled = false
    local handle = nil
    local stateConnection = nil
    local isCurrentlyEmoting = false

    local interactEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact")

    local function updateEmoteStatus()
        if not LocalPlayer.Character then
            isCurrentlyEmoting = false
            return
        end
        local state = LocalPlayer.Character:GetAttribute("State")
        isCurrentlyEmoting = state and string.find(state, "Emoting")
    end

    local function isPlayerDowned(pl)
        if not pl or not pl.Character then return false end
        local char = pl.Character
        if char:GetAttribute("Downed") then return true end
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.Health <= 0 then return true end
        return false
    end

    local function reviveLoop()
        while enabled do
            if isCurrentlyEmoting and not Options.ReviveWhileEmoteToggle.Value then
                task.wait(0.3)
                continue
            end

            local myChar = LocalPlayer.Character
            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                local myHRP = myChar.HumanoidRootPart

                for _, pl in Players:GetPlayers() do
                    if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        if isPlayerDowned(pl) then
                            local dist = (myHRP.Position - pl.Character.HumanoidRootPart.Position).Magnitude
                            if dist <= reviveRange then
                                pcall(function()
                                    interactEvent:FireServer("Revive", true, pl.Name)
                                end)
                            end
                        end
                    end
                end
            end

            task.wait(loopDelay)
        end
    end

    local function start()
        if handle then return end
        enabled = true
        updateEmoteStatus()

        if LocalPlayer.Character then
            stateConnection = LocalPlayer.Character:GetAttributeChangedSignal("State"):Connect(updateEmoteStatus)
        end
        LocalPlayer.CharacterAdded:Connect(function(char)
            if stateConnection then stateConnection:Disconnect() end
            stateConnection = char:GetAttributeChangedSignal("State"):Connect(updateEmoteStatus)
            updateEmoteStatus()
        end)

        handle = task.spawn(reviveLoop)
    end

    local function stop()
        enabled = false
        if handle then task.cancel(handle) handle = nil end
        if stateConnection then stateConnection:Disconnect() stateConnection = nil end
        isCurrentlyEmoting = false
    end

    return {
        Start = start,
        Stop = stop,
        SetDelay = function(d) loopDelay = d end,
    }
end)()

InstantReviveToggle:OnChanged(function(state)
    if state then
        InstantReviveModule.SetDelay(getgenv().InstantReviveDelay)
        InstantReviveModule.Start()
    else
        InstantReviveModule.Stop()
    end
end)

ReviveDelaySlider:OnChanged(function(value)
    getgenv().InstantReviveDelay = value
    InstantReviveModule.SetDelay(value)
end)
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
AutoCarryToggle = MiscTab:AddToggle("AutoCarryToggle", {
    Title = "Auto Carry",
    Default = false
})

CarryGUIToggle = MiscTab:AddToggle("CarryGUIToggle", {
    Title = "Carry GUI Button",
    Default = false
})

CarryButtonSizeInput = MiscTab:AddInput("CarryButtonSizeInput", {
    Title = "Carry Button Size",
    Default = "200",
    Placeholder = "Enter size (150-400)",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local size = tonumber(Value)
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local newWidth = math.max(150, math.min(size, 400))
                    local newHeight = math.max(60, math.min(size * 0.4, 160))
                    button.Size = UDim2.new(0, newWidth, 0, newHeight)
                end
            end
        end
    end
})

CarryKeybind = MiscTab:AddKeybind("CarryKeybind", {
    Title = "Auto Carry Keybind",
    Mode = "Toggle",
    Default = "F3",
    ChangedCallback = function(New)
        Options.AutoCarryToggle:SetValue(not Options.AutoCarryToggle.Value)
    end
})

local AutoCarryConnection = nil
local featureStates = featureStates or {}
local player = game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local function createGradientButton(parent, position, size, text)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    gradient.Rotation = 45
    gradient.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 30
    label.Font = Enum.Font.GothamMedium
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Active = false
    clicker.Selectable = false
    clicker.Parent = button

    return button, clicker, stroke
end

local function startAutoCarry()
    if AutoCarryConnection then return end
    
    AutoCarryConnection = RunService.Heartbeat:Connect(function()
        if not featureStates.AutoCarry then 
            return 
        end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (hrp.Position - other.Character.HumanoidRootPart.Position).Magnitude
                    if dist <= 20 then
                        local args = { "Carry", [3] = other.Name }
                        pcall(function()
                            game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Character"):WaitForChild("Interact"):FireServer(unpack(args))
                        end)
                        task.wait(0.01)
                    end
                end
            end
        end
    end)
end

local function stopAutoCarry()
    if AutoCarryConnection then
        AutoCarryConnection:Disconnect()
        AutoCarryConnection = nil
    end
end

local function toggleAutoCarryGUI()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AutoCarryButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 200
        if Options.CarryButtonSizeInput and Options.CarryButtonSizeInput.Value and tonumber(Options.CarryButtonSizeInput.Value) then
            buttonSize = tonumber(Options.CarryButtonSizeInput.Value)
        end
        
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, -btnHeight/2),
            UDim2.new(0, btnWidth, 0, btnHeight),
            "Auto Carry:Off"
        )
        
        local function updateButtonText()
            if btn and btn:FindFirstChild("TextLabel") then
                btn.TextLabel.Text = featureStates.AutoCarry and "Auto Carry:On" or "Auto Carry:Off"
            end
        end
        
        updateButtonText()
        
        clicker.MouseButton1Click:Connect(function()
            featureStates.AutoCarry = not featureStates.AutoCarry
            updateButtonText()
            
            if featureStates.AutoCarry then
                startAutoCarry()
            else
                stopAutoCarry()
            end
        end)
        
        AutoCarryToggle:OnChanged(function(state)
            featureStates.AutoCarry = state
            updateButtonText()
            
            if state then
                startAutoCarry()
            else
                stopAutoCarry()
            end
        end)
    end
end

AutoCarryToggle:OnChanged(function(state)
    featureStates.AutoCarry = state
    
    if state then
        startAutoCarry()
    else
        stopAutoCarry()
    end
end)

CarryGUIToggle:OnChanged(function(state)
    if state then
        toggleAutoCarryGUI()
    else
        local CoreGui = game:GetService("CoreGui")
        local existingScreenGui = CoreGui:FindFirstChild("AutoCarryButtonGUI")
        if existingScreenGui then
            existingScreenGui:Destroy()
        end
    end
end)
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
AutoDrinkToggle = MiscTab:AddToggle("AutoDrinkToggle", {
    Title = "Auto Drink Cola",
    Default = false
})

DrinkDelayInput = MiscTab:AddInput("DrinkDelayInput", {
    Title = "Drink Delay (seconds)",
    Default = "0.5",
    Placeholder = "Delay between drinks",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local delay = tonumber(Value)
            if delay > 0 then
                featureStates.DrinkDelay = delay
            end
        end
    end
})

local AutoDrinkConnection = nil
local featureStates = featureStates or {}
local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")

featureStates.DrinkDelay = 0.5

local function startAutoDrink()
    if AutoDrinkConnection then return end
    
    AutoDrinkConnection = task.spawn(function()
        while featureStates.AutoDrink do
            local ohTable1 = {
                ["Forced"] = true,
                ["Key"] = "Cola",
                ["Down"] = true
            }
            
            pcall(function()
                player.PlayerScripts.Events.temporary_events.UseKeybind:Fire(ohTable1)
            end)
            
            task.wait(featureStates.DrinkDelay)
        end
        AutoDrinkConnection = nil
    end)
end

local function stopAutoDrink()
    if AutoDrinkConnection then
        task.cancel(AutoDrinkConnection)
        AutoDrinkConnection = nil
    end
end

player.CharacterRemoving:Connect(function()
    if featureStates.AutoDrink then
        stopAutoDrink()
    end
end)

player.CharacterAdded:Connect(function()
    if featureStates.AutoDrink then
        task.wait(1)
        startAutoDrink()
    end
end)

AutoDrinkToggle:OnChanged(function(state)
    featureStates.AutoDrink = state
    
    if state then
        startAutoDrink()
    else
        stopAutoDrink()
    end
end)

featureStates.AutoDrink = false
featureStates.AutoCarry = false
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})
math.randomseed(tick())

local emoteInputs = {}
for i = 1, 12 do
    emoteInputs[i] = MiscTab:AddInput("EmoteInput" .. i, {
        Title = "Emote " .. i,
        Default = "",
        Placeholder = "Emote Name Here",
        Finished = false,
        Callback = function(Value)
            featureStates["Emote" .. i] = Value
        end
    })
end

local emoteGui = nil
local emoteGuiButton = nil
local emoteGuiVisible = false
local player = game:GetService("Players").LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local featureStates = featureStates or {}
local isMobile = UserInputService.TouchEnabled
local emoteKeybindValue = "" 

local function makeDraggable(frame)
    frame.Active = true
    frame.Draggable = true
    
    local dragging = false
    local dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            frame.BackgroundTransparency = 0.6 
        end
    end)
    
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            frame.BackgroundTransparency = 0.7 
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
end

local function triggerRandomEmote()
    local validEmotes = {}
    for i = 1, 12 do
        local emoteName = featureStates["Emote" .. i]
        if emoteName and emoteName ~= "" then
            table.insert(validEmotes, emoteName)
        end
    end
    
    if #validEmotes > 0 then
        math.randomseed(tick() + #validEmotes)
        
        local ohTable1 = { ["Key"] = "Crouch", ["Down"] = true }
        pcall(function()
            player.PlayerScripts.Events.temporary_events.UseKeybind:Fire(ohTable1)
        end)
        local randomIndex = math.random(1, #validEmotes)
        local randomEmote = validEmotes[randomIndex]
        pcall(function()
            ReplicatedStorage.Events.Character.Emote:FireServer(randomEmote)
        end)
    end
end

local function createGradientButton(parent, position, size, text)
    local button = Instance.new("Frame")
    button.Name = "GradientBtn"
    button.BackgroundTransparency = 0.7
    button.Size = size
    button.Position = position
    button.Draggable = true
    button.Active = true
    button.Selectable = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    }
    gradient.Rotation = 45
    gradient.Parent = button

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(120, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = button

    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 16
    label.Font = Enum.Font.GothamMedium
    label.TextWrapped = true
    label.Parent = button

    local clicker = Instance.new("TextButton")
    clicker.Size = UDim2.new(1, 0, 1, 0)
    clicker.BackgroundTransparency = 1
    clicker.Text = ""
    clicker.ZIndex = 5
    clicker.Active = false
    clicker.Selectable = false
    clicker.Parent = button

    clicker.MouseEnter:Connect(function()
        stroke.Color = Color3.fromRGB(160, 0, 0)
    end)

    clicker.MouseLeave:Connect(function()
        stroke.Color = Color3.fromRGB(120, 0, 0)
    end)

    return button, clicker, stroke
end

local function createEmoteGui(yOffset)
    local emoteGuiOld = playerGui:FindFirstChild("EmoteGui")
    if emoteGuiOld then emoteGuiOld:Destroy() end
    
    emoteGui = Instance.new("ScreenGui")
    emoteGui.Name = "EmoteGui"
    emoteGui.IgnoreGuiInset = true
    emoteGui.ResetOnSpawn = false
    emoteGui.Enabled = emoteGuiVisible and isMobile
    emoteGui.Parent = playerGui
    
    local buttonText = "Emote Crouch " .. emoteKeybindValue
    
    local btn, clicker, stroke = createGradientButton(
        emoteGui,
        UDim2.new(0.5, -100, 0.12 + (yOffset or 0), -40),
        UDim2.new(0, 200, 0, 80),
        buttonText
    )
    
    makeDraggable(btn)
    
    clicker.MouseButton1Click:Connect(function()
        triggerRandomEmote()
    end)
    
    emoteGuiButton = btn
end

EmoteKeybind = MiscTab:AddKeybind("EmoteKeybind", {
    Title = "Emote Keybind",
    Mode = "Toggle",
    Default = "", 
    ChangedCallback = function(New)
        emoteKeybindValue = New
        if emoteGuiButton and emoteGuiButton:FindFirstChild("TextLabel") then
            emoteGuiButton.TextLabel.Text = "Emote Crouch\nClick or Press " .. New
        end
    end,
    Callback = function()
        triggerRandomEmote()
    end
})

EmoteGUIToggle = MiscTab:AddToggle("EmoteGUIToggle", {
    Title = "Emote Crouch",
    Description = "Click button or use keybind to trigger random emote. Only type emote name without space and inside your emote slot will work",
    Default = false,
    Callback = function(state)
        emoteGuiVisible = state
        if state then
            if isMobile and not emoteGui then
                createEmoteGui(0)
            elseif emoteGui then
                emoteGui.Enabled = isMobile
            end
        else
            if emoteGui then
                emoteGui:Destroy()
                emoteGui = nil
                emoteGuiButton = nil
            end
        end
    end
})

player.CharacterAdded:Connect(function()
    if emoteGuiVisible and isMobile and not emoteGui then
        createEmoteGui(0)
    end
end)
MiscTab:AddSection("Movement Modification")

local originalEmoteSpeeds = {}
local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
if itemsFolder then
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if emotesFolder then
        for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
            if emoteModule:IsA("ModuleScript") then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo then
                    originalEmoteSpeeds[emoteModule.Name] = emoteData.EmoteInfo.SpeedMult
                end
            end
        end
    end
end

local function applyEmoteSpeed(speedValue)
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local success, emoteData = pcall(require, emoteModule)
            if success and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult ~= 0 then
                emoteData.EmoteInfo.SpeedMult = speedValue
            end
        end
    end
end

local function restoreOriginalEmoteSpeeds()
    if not itemsFolder then return end
    local emotesFolder = itemsFolder:FindFirstChild("Emotes")
    if not emotesFolder then return end
    
    for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
        if emoteModule:IsA("ModuleScript") then
            local originalSpeed = originalEmoteSpeeds[emoteModule.Name]
            if originalSpeed then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo then
                    emoteData.EmoteInfo.SpeedMult = originalSpeed
                end
            end
        end
    end
end

local requiredFields = {
    Friction = true,
    AirStrafeAcceleration = true,
    JumpHeight = true,
    RunDeaccel = true,
    JumpSpeedMultiplier = true,
    JumpCap = true,
    SprintCap = true,
    WalkSpeedMultiplier = true,
    BhopEnabled = true,
    Speed = true,
    AirAcceleration = true,
    RunAccel = true,
    SprintAcceleration = true
}

local function getMatchingTables()
    local matched = {}
    for _, obj in pairs(getgc(true)) do
        if typeof(obj) == "table" then
            local ok = true
            for field in pairs(requiredFields) do
                if rawget(obj, field) == nil then
                    ok = false
                    break
                end
            end
            if ok then
                table.insert(matched, obj)
            end
        end
    end
    return matched
end

local function applySpeedMultiplier(speedMultiplier)
    local targets = getMatchingTables()
    for _, tableObj in ipairs(targets) do
        if tableObj and typeof(tableObj) == "table" then
            pcall(function()
                tableObj.WalkSpeedMultiplier = speedMultiplier
            end)
        end
    end
end

local player = game:GetService("Players").LocalPlayer

local function getPlayerObj()
    local gamePlayers = workspace.Game and workspace.Game.Players
    if not gamePlayers then return nil end
    return gamePlayers:FindFirstChild(player.Name)
end

local playerObj = nil
local connection = nil
local emotingSpeed = 1.5

local function setupConnection(obj)
    if connection then 
        connection:Disconnect() 
        connection = nil
    end
    playerObj = obj
    if not obj then return end
    
    local function onStateChanged()
        local state = obj:GetAttribute("State")
        local targetSpeed = (state == "Emoting") and emotingSpeed or 1.5
        applySpeedMultiplier(targetSpeed)
    end
    
    onStateChanged()
    connection = obj:GetAttributeChangedSignal("State"):Connect(onStateChanged)
end

local function resetMultiplierSpeed()
    emotingSpeed = 1.5
    applySpeedMultiplier(1.5)
end

EmoteSpeedModeDropdown = MiscTab:AddDropdown("EmoteSpeedModeDropdown", {
    Title = "Emote speed mode",
    Values = {"Nah", "Legit", "Multiplier speed"},
    Multi = false,
    Default = "Nah",
    Callback = function(Value)
        if Value == "Nah" then
            resetMultiplierSpeed()
            restoreOriginalEmoteSpeeds()
            if connection then 
                connection:Disconnect() 
                connection = nil
            end
        elseif Value == "Multiplier speed" then
            restoreOriginalEmoteSpeeds()
            setupConnection(getPlayerObj())
            task.spawn(function()
                while Options.EmoteSpeedModeDropdown and Options.EmoteSpeedModeDropdown.Value == "Multiplier speed" do
                    task.wait(2)
                    local current = getPlayerObj()
                    if current ~= playerObj then
                        setupConnection(current)
                    elseif playerObj then
                        local state = playerObj:GetAttribute("State")
                        local targetSpeed = (state == "Emoting") and emotingSpeed or 1.5
                        applySpeedMultiplier(targetSpeed)
                    end
                end
            end)
        elseif Value == "Legit" then
            resetMultiplierSpeed()
            if connection then 
                connection:Disconnect() 
                connection = nil
            end
            local speedValue = featureStates.EmoteSpeedValue or 2
            applyEmoteSpeed(speedValue)
        end
    end
})

EmoteSpeedInput = MiscTab:AddInput("EmoteSpeedInput", {
    Title = "Emote Speed Value",
    Default = "1500",
    Placeholder = "Enter speed value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            featureStates.EmoteSpeedValue = num
            local appliedValue = num / 1000
            
            if Options.EmoteSpeedModeDropdown and Options.EmoteSpeedModeDropdown.Value == "Legit" then
                applyEmoteSpeed(appliedValue)
            elseif Options.EmoteSpeedModeDropdown and Options.EmoteSpeedModeDropdown.Value == "Multiplier speed" then
                emotingSpeed = appliedValue
            end
        end
    end
})

ApplyUnwalkableButton = MiscTab:AddButton({
    Title = "Apply Speed to Unwalkable Emotes",
    Callback = function()
        if not itemsFolder then return end
        
        local emotesFolder = itemsFolder:FindFirstChild("Emotes")
        if not emotesFolder then return end
        
        local speedValue = featureStates.EmoteSpeedValue or 2
        
        for _, emoteModule in ipairs(emotesFolder:GetChildren()) do
            if emoteModule:IsA("ModuleScript") then
                local success, emoteData = pcall(require, emoteModule)
                if success and emoteData and emoteData.EmoteInfo and emoteData.EmoteInfo.SpeedMult == 0 then
                    emoteData.EmoteInfo.SpeedMult = speedValue
                end
            end
        end
    end
})

ResetEmoteSpeedButton = MiscTab:AddButton({
    Title = "Reset Emote Speed",
    Callback = function()
        Fluent:Notify({
            Title = "Emote Speed",
            Content = "Resetting emote speeds...",
            Duration = 3
        })
        restoreOriginalEmoteSpeeds()
        resetMultiplierSpeed()
    end
})

local infiniteSlideEnabled = false
local slideFrictionValue = -8
local movementTables = {}
local infiniteSlideHeartbeat = nil
local infiniteSlideCharacterConn = nil
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

local requiredKeys = {
    "Friction","AirStrafeAcceleration","JumpHeight","RunDeaccel",
    "JumpSpeedMultiplier","JumpCap","SprintCap","WalkSpeedMultiplier",
    "BhopEnabled","Speed","AirAcceleration","RunAccel","SprintAcceleration"
}

local function hasRequiredFields(tbl)
    if typeof(tbl) ~= "table" then return false end
    for _, key in ipairs(requiredKeys) do
        if rawget(tbl, key) == nil then return false end
    end
    return true
end

local function findMovementTables()
    movementTables = {}
    for _, obj in ipairs(getgc(true)) do
        if hasRequiredFields(obj) then
            table.insert(movementTables, obj)
        end
    end
    return #movementTables > 0
end

local function setSlideFriction(value)
    local appliedCount = 0
    for _, tbl in ipairs(movementTables) do
        pcall(function()
            tbl.Friction = value
            appliedCount = appliedCount + 1
        end)
    end
    if appliedCount == 0 then
        for _, obj in ipairs(getgc(true)) do
            if hasRequiredFields(obj) then
                pcall(function()
                    obj.Friction = value
                end)
            end
        end
    end
end

local function updatePlayerModel()
    local gameFolder = workspace:FindFirstChild("Game")
    if not gameFolder then return false end
    
    local playersFolder = gameFolder:FindFirstChild("Players")
    if not playersFolder then return false end
    
    local playerModel = playersFolder:FindFirstChild(player.Name)
    return playerModel
end

local function infiniteSlideHeartbeatFunc()
    if not infiniteSlideEnabled then return end
    
    local playerModel = updatePlayerModel()
    if not playerModel then return end
    
    local state = playerModel:GetAttribute("State")
    
    if state == "Slide" then
        pcall(function()
            playerModel:SetAttribute("State", "EmotingSlide")
        end)
    elseif state == "EmotingSlide" then
        setSlideFriction(slideFrictionValue)
    else
        setSlideFriction(5)
    end
end

local function onCharacterAddedSlide(character)
    if not infiniteSlideEnabled then return end
    
    for i = 1, 5 do
        task.wait(0.5)
        if updatePlayerModel() then
            break
        end
    end
    
    task.wait(0.5)
    findMovementTables()
end

local function setInfiniteSlide(enabled)
    infiniteSlideEnabled = enabled

    if enabled then
        findMovementTables()
        updatePlayerModel()
        
        if not infiniteSlideCharacterConn then
            infiniteSlideCharacterConn = player.CharacterAdded:Connect(onCharacterAddedSlide)
        end
        
        if player.Character then
            task.spawn(function()
                onCharacterAddedSlide(player.Character)
            end)
        end
        
        if infiniteSlideHeartbeat then infiniteSlideHeartbeat:Disconnect() end
        infiniteSlideHeartbeat = RunService.Heartbeat:Connect(infiniteSlideHeartbeatFunc)
        
    else
        if infiniteSlideHeartbeat then
            infiniteSlideHeartbeat:Disconnect()
            infiniteSlideHeartbeat = nil
        end
        
        if infiniteSlideCharacterConn then
            infiniteSlideCharacterConn:Disconnect()
            infiniteSlideCharacterConn = nil
        end
        
        setSlideFriction(5)
        movementTables = {}
    end
end

InfiniteSlideToggle = MiscTab:AddToggle("InfiniteSlideToggle", {
    Title = "Sprint Slide",
    Default = false,
    Callback = function(Value)
        setInfiniteSlide(Value)
    end
})

SlideFrictionInput = MiscTab:AddInput("SlideFrictionInput", {
    Title = "Slide Speed (Negative only)",
    Default = "-8",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            slideFrictionValue = num
            if infiniteSlideEnabled then
                setSlideFriction(slideFrictionValue)
            end
        end
    end
})
MiscTab:AddParagraph({
    Title = "",
    Content = ""
})

local gravityEnabled = false
local originalGravity = workspace.Gravity
local gravityValue = 10
local gravityHeartbeat = nil
local gravityKeybindValue = "G"

local function createGravityButton()
    local CoreGui = game:GetService("CoreGui")
    local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
    
    if existingScreenGui then
        existingScreenGui:Destroy()
    else
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GravityButtonGUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = CoreGui
        
        local buttonSize = 200
        local btnWidth = math.max(150, math.min(buttonSize, 400))
        local btnHeight = math.max(60, math.min(buttonSize * 0.4, 160))
        
        local btn, clicker, stroke = createGradientButton(
            screenGui,
            UDim2.new(0.5, -btnWidth/2, 0.5, 60),
            UDim2.new(0, btnWidth, 0, btnHeight),
            gravityEnabled and "Gravity:On" or "Gravity:Off"
        )
        
        clicker.MouseButton1Click:Connect(function()
            gravityEnabled = not gravityEnabled
            if btn:FindFirstChild("TextLabel") then
                btn.TextLabel.Text = gravityEnabled and "Gravity:On" or "Gravity:Off"
            end
            
            if gravityEnabled then
                workspace.Gravity = gravityValue
            else
                workspace.Gravity = originalGravity
            end
        end)
    end
end

local function toggleGravity()
    gravityEnabled = not gravityEnabled
    
    if gravityEnabled then
        workspace.Gravity = gravityValue
    else
        workspace.Gravity = originalGravity
    end
    
    if Options.GravityButtonToggle and Options.GravityButtonToggle.Value then
        createGravityButton()
    end
end

GravityToggle = MiscTab:AddToggle("GravityToggle", {
    Title = "Gravity",
    Default = false,
    Callback = function(Value)
        gravityEnabled = Value
        
        if Value then
            workspace.Gravity = gravityValue
        else
            workspace.Gravity = originalGravity
        end
    end
})

GravityButtonToggle = MiscTab:AddToggle("GravityButtonToggle", {
    Title = "Gravity Button GUI",
    Default = false,
    Callback = function(Value)
        if Value then
            createGravityButton()
        else
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
            if existingScreenGui then
                existingScreenGui:Destroy()
            end
        end
    end
})

GravityKeybind = MiscTab:AddKeybind("GravityKeybind", {
    Title = "Gravity Keybind",
    Mode = "Toggle",
    Default = "G",
    ChangedCallback = function(New)
        gravityKeybindValue = New
    end,
    Callback = function()
        toggleGravity()
    end
})

GravityAdjustmentInput = MiscTab:AddInput("GravityAdjustmentInput", {
    Title = "Gravity Adjustment",
    Default = "10",
    Placeholder = "Enter gravity value",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            gravityValue = num
            if gravityEnabled then
                workspace.Gravity = gravityValue
            end
        end
    end
})

originalGravity = workspace.Gravity

GravityToggle:OnChanged(function(state)
    if Options.GravityButtonToggle and Options.GravityButtonToggle.Value then
        local CoreGui = game:GetService("CoreGui")
        local screenGui = CoreGui:FindFirstChild("GravityButtonGUI")
        if screenGui then
            local button = screenGui:FindFirstChild("GradientBtn")
            if button and button:FindFirstChild("TextLabel") then
                button.TextLabel.Text = state and "Gravity:On" or "Gravity:Off"
            end
        end
    end
end)
GravityButtonSizeInput = MiscTab:AddInput("GravityButtonSizeInput", {
    Title = "Gravity Button Size",
    Default = "1",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        if Value and tonumber(Value) then
            local scale = tonumber(Value)
            scale = math.max(0.5, math.min(scale, 3.0))
            
            local CoreGui = game:GetService("CoreGui")
            local existingScreenGui = CoreGui:FindFirstChild("GravityButtonGUI")
            
            if existingScreenGui then
                local button = existingScreenGui:FindFirstChild("GradientBtn")
                if button then
                    local uiScale = button:FindFirstChild("UIScale") or Instance.new("UIScale")
                    uiScale.Scale = scale
                    uiScale.Parent = button
                end
            end
        end
    end
})
MiscTab:AddParagraph({
    Title = "Heads up: Turn off infinite slide when bhopping to get better trims blah blah blah",
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
loadstring(game:HttpGet('https://raw.githubusercontent.com/Pnsdgsa/Script-kids/refs/heads/main/Scripthub/Darahub/evade/TimerGUI-NoRepeat'))()
