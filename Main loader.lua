

local PlaceScripts = {
    [10324346056] = { 
        name = "Big Team", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    },
    [9872472334] = { 
        name = "Evade", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    },
    [96537472072550] = { 
        name = "Legacy Evade", 
        url = "https://raw.githubusercontent.com/Pnsdgsa/Script-kids/refs/heads/main/Scripthub/Darahub/Evade%20Legacy/DaraHub-Evade-Legacy" 
    },
    [10662542523] = { 
        name = "Casual", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    },
    [10324347967] = { 
        name = "Social Space", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    },
    [121271605799901] = { 
        name = "Player Nextbots", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    },
    [10808838353] = { 
        name = "VC Only", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    },
    [11353528705] = { 
        name = "Pro", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    },
    [99214917572799] = { 
        name = "Custom Servers", 
        url = "https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/File/Game/Evade/Overhaul.lua" 
    }, 
    }

local UniversalScript = {
    name = "Universal Script",
    url = ""
}

local currentGameId = game.PlaceId
local selectedScript = PlaceScripts[currentGameId]

if selectedScript then
    if selectedScript.url == "UNSUPPORTED" then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Error - Game Not Supported",
            Text = selectedScript.name .. " is currently unsupported. Please check back later.",
            Duration = 5
        })
    else
        local success, result = pcall(function()
            return loadstring(game:HttpGet(selectedScript.url))()
        end)
        if not success then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "",
                Text = "" .. selectedScript.name .. " script: " .. tostring(result),
                Duration = 5
            })
        end
    end
else
    local success, result = pcall(function()
        return loadstring(game:HttpGet(UniversalScript.url))()
    end)
    if not success then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "",
            Text = "" .. tostring(result),
            Duration = 5
        })
    end
end

local queueonteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (DaraHub and DaraHub.queue_on_teleport)

if queueonteleport then
 
    queueonteleport("https://raw.githubusercontent.com/010101010101010111/010101010101010111-010101010101010111-1001100101100101001001101010101010101101001010101010101101010/refs/heads/main/Main%20loader.lua'))()")
 
end
