getgenv().CurrentServerPing = 0

spawn(function()
    while task.wait() do      
      getgenv().CurrentServerPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
    end
end)
