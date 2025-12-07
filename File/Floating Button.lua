local Minimized = false
local Window
local FloatButton
local gui, button, topImage

local module = {}

local function downloadAudio()
    local audioUrl = "https://github.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/raw/refs/heads/main/File/audio/Bruh%20sound%20effect_256k.mp3"
    local request = http_request or (syn and syn.request) or request
    local success, response = pcall(function()
        return request({Url = audioUrl, Method = "GET"})
    end)
    
    if success and response and response.Body then
        writefile("bruh.mp3", response.Body)
        return true
    else
        warn("Failed to download audio")
        return false
    end
end

local function playAudio()
    if isfile("bruh.mp3") then
        local sound = Instance.new("Sound")
        sound.SoundId = getcustomasset("bruh.mp3")
        sound.Parent = game:GetService("SoundService")
        
        sound.Ended:Connect(function()
            sound:Destroy()
        end)
        
        local success, errorMsg = pcall(function()
            sound:Play()
        end)
        
        if not success then
            warn("Failed to play sound:", errorMsg)
            sound:Destroy()
        end
        return sound
    else
        warn("Audio file not found!")
        return nil
    end
end

local function ToggleMinimize()
    if Window then
        Window:Minimize()
        Minimized = true
    end
end

function module.init(fluentWindow)
    Window = fluentWindow
    
    downloadAudio()
    
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    gui = Instance.new("ScreenGui")
    gui.Name = "FloatingButtonGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    
    button = Instance.new("Frame")
    button.Name = "FloatingButton"
    button.Size = UDim2.new(0, 120, 0, 90)
    button.Position = UDim2.new(0.5, -75, 0.5, -75)
    button.BackgroundTransparency = 1
    button.Parent = gui
    
    topImage = Instance.new("ImageButton")
    topImage.Name = "TopAsset"
    topImage.Size = UDim2.new(0.7, 0, 0.7, 0)
    topImage.AnchorPoint = Vector2.new(0.5, 0.5)
    topImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    topImage.BackgroundTransparency = 1
    topImage.Image = "rbxassetid://108180785726591"
    topImage.ZIndex = 2
    topImage.Parent = button
    topImage.Draggable = true
    
    FloatButton = topImage
    
    FloatButton.MouseButton1Click:Connect(function()
        ToggleMinimize()
        playAudio()
    end)
    
    if Window then
        Window.MinimizeToggle = ToggleMinimize
    end
    
    local backgroundImage = Instance.new("ImageLabel")
    backgroundImage.Name = "SpinningBackground"
    backgroundImage.Size = UDim2.new(1, 0, 1, 0)
    backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
    backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    backgroundImage.BackgroundTransparency = 1
    backgroundImage.Image = "rbxassetid://88077369114691"
    backgroundImage.ZIndex = 1
    backgroundImage.Parent = topImage
    backgroundImage.Interactable = false
    
    local backgroundScale = Instance.new("UIScale")
    backgroundScale.Scale = 2
    backgroundScale.Parent = backgroundImage
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = topImage
    
    local UserInputService = game:GetService("UserInputService")
    local dragging = false
    local dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        button.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = button.Position
        end
    end)
    
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)
    
    local RunService = game:GetService("RunService")
    RunService.RenderStepped:Connect(function(deltaTime)
        backgroundImage.Rotation = (backgroundImage.Rotation + (100 * deltaTime)) % 360
    end)
    
    return module
end

function module.destroy()
    if gui then
        gui:Destroy()
        gui = nil
    end
    print("Floating button destroyed")
end

function module.getButton()
    return button
end

function module.isMinimized()
    return Minimized
end

function module.playSound()
    return playAudio()
end

return module
