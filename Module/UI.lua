local module = {}

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

function module.start()
    local cfg = getgenv().Modules.config
    
    local gui = Instance.new("ScreenGui", lp.PlayerGui)
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,400,0,250)
    main.Position = UDim2.new(0.3,0,0.3,0)
    main.BackgroundColor3 = Color3.fromRGB(20,20,20)
    main.Active=true main.Draggable=true
    
    local auto = Instance.new("TextButton", main)
    auto.Size=UDim2.new(0,180,0,40)
    auto.Position=UDim2.new(0,10,0,10)
    auto.Text="Auto OFF"
    
    auto.MouseButton1Click:Connect(function()
        cfg.AutoEgg = not cfg.AutoEgg
        auto.Text="Auto "..(cfg.AutoEgg and "ON" or "OFF")
    end)
    
    local hop = Instance.new("TextButton", main)
    hop.Size=UDim2.new(0,180,0,40)
    hop.Position=UDim2.new(0,10,0,60)
    hop.Text="Hop OFF"
    
    hop.MouseButton1Click:Connect(function()
        cfg.AutoHop = not cfg.AutoHop
        hop.Text="Hop "..(cfg.AutoHop and "ON" or "OFF")
    end)
end

return module
