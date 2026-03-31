local module = {}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local hrp = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")

function module.apply(obj)
    local cfg = getgenv().Modules.config
    if not cfg.ShowESP then return end
    
    if obj:FindFirstChild("ESP") then return end
    
    local bill=Instance.new("BillboardGui",obj)
    bill.Size=UDim2.new(0,180,0,60)
    bill.AlwaysOnTop=true
    
    local txt=Instance.new("TextLabel",bill)
    txt.Size=UDim2.new(1,0,1,0)
    txt.BackgroundTransparency=1
    txt.TextScaled=true
    
    RunService.RenderStepped:Connect(function()
        if obj and obj.Parent then
            local d=math.floor((hrp.Position-obj.Position).Magnitude)
            txt.Text=obj.Name.." | "..d.." | "..(cfg.Rarity[obj.Name] or "?")
        end
    end)
end

return module
