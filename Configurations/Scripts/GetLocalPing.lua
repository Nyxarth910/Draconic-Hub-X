getgenv().CurrentLocalPing = 0

spawn(function()
    while task.wait() do      
      getgenv().CurrentLocalPing = game.Players.LocalPlayer:GetNetworkPing()
    end
end)
