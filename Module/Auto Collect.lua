local module = {}

local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local function getEgg()
    local cfg = getgenv().Modules.config
    
    local best,dist=nil,math.huge
    
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildWhichIsA("ProximityPrompt") then
            
            if cfg.SelectedEggs[v.Name] then
                local d=(hrp.Position-v.Position).Magnitude
                
                if d<dist then
                    dist=d
                    best=v
                end
            end
        end
    end
    
    return best
end

local function move(target)
    local path=PathfindingService:CreatePath()
    path:ComputeAsync(hrp.Position,target.Position)
    
    if path.Status==Enum.PathStatus.Success then
        for _,wp in ipairs(path:GetWaypoints()) do
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(2)
        end
    end
end

function module.start()
    task.spawn(function()
        while true do
            getgenv().Modules.core.delay()
            
            local cfg = getgenv().Modules.config
            
            if cfg.AutoEgg then
                local egg=getEgg()
                
                if egg then
                    move(egg)
                    
                    local p=egg:FindFirstChildWhichIsA("ProximityPrompt")
                    if p then
                        fireproximityprompt(p)
                        getgenv().Modules.stats.add()
                    end
                end
            end
        end
    end)
end

return module
