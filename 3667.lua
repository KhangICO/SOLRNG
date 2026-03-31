--// SERVICES
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local UIS = game:GetService("UserInputService")

--// PLAYER
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

--// SETTINGS
local running = false
local minDelay = 8
local maxDelay = 12
local scanDistance = 200

local visited = {}

--// GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "ULTIMATE_EGG"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 260)
frame.Position = UDim2.new(0.5, -160, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "ULTIMATE AUTO EGG"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- TOGGLE
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(0,140,0,40)
toggle.Position = UDim2.new(0.5,-70,0,50)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(200,0,0)

toggle.MouseButton1Click:Connect(function()
    running = not running
    toggle.Text = running and "ON" or "OFF"
    toggle.BackgroundColor3 = running and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
end)

-- DELAY
local delayBtn = Instance.new("TextButton", frame)
delayBtn.Size = UDim2.new(0,260,0,30)
delayBtn.Position = UDim2.new(0.5,-130,0,100)
delayBtn.Text = "Delay: "..minDelay.."-"..maxDelay

delayBtn.MouseButton1Click:Connect(function()
    if minDelay == 8 then
        minDelay, maxDelay = 5, 8
    else
        minDelay, maxDelay = 8, 12
    end
    delayBtn.Text = "Delay: "..minDelay.."-"..maxDelay
end)

-- DISTANCE
local distBtn = Instance.new("TextButton", frame)
distBtn.Size = UDim2.new(0,260,0,30)
distBtn.Position = UDim2.new(0.5,-130,0,140)
distBtn.Text = "Distance: "..scanDistance

distBtn.MouseButton1Click:Connect(function()
    scanDistance = (scanDistance == 200) and 400 or 200
    distBtn.Text = "Distance: "..scanDistance
end)

-- RESET
local resetBtn = Instance.new("TextButton", frame)
resetBtn.Size = UDim2.new(0,260,0,30)
resetBtn.Position = UDim2.new(0.5,-130,0,180)
resetBtn.Text = "Reset Visited"

resetBtn.MouseButton1Click:Connect(function()
    visited = {}
end)

--// PATHFINDING
local function moveToTarget(targetPos)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentJumpHeight = 10,
        AgentMaxSlope = 45
    })
    
    path:ComputeAsync(hrp.Position, targetPos)
    
    if path.Status == Enum.PathStatus.Success then
        for _, waypoint in ipairs(path:GetWaypoints()) do
            humanoid:MoveTo(waypoint.Position)
            
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            
            local reached = humanoid.MoveToFinished:Wait(2)
            if not reached then break end
        end
    else
        humanoid:MoveTo(targetPos)
        humanoid.MoveToFinished:Wait(2)
    end
end

--// AUTO FARM
spawn(function()
    while true do
        if running then
            local found = false
            
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and string.find(v.Name:lower(), "egg") then
                    
                    local dist = (hrp.Position - v.Position).Magnitude
                    
                    if dist <= scanDistance and not visited[v] then
                        visited[v] = true
                        found = true
                        
                        -- MOVE (né vật cản)
                        moveToTarget(v.Position)
                        
                        task.wait(0.3)
                        
                        -- NHẶT
                        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt then
                            fireproximityprompt(prompt, 1)
                        end
                        
                        -- DELAY RANDOM
                        task.wait(math.random(minDelay, maxDelay))
                    end
                end
            end
            
            if not found then
                task.wait(1)
            end
        end
        task.wait(0.5)
    end
end)

-- AUTO RESET
spawn(function()
    while true do
        task.wait(60)
        visited = {}
    end
end)
