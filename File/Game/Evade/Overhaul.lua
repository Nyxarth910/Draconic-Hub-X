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
local FloatingButton = loadstring(game:HttpGet("https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Floating%20Button.lua",true))()

FloatingButton.init(Window)
