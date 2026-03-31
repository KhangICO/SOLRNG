--// SETTINGS
getgenv().AutoEgg = false
getgenv().ShowESP = true

--// SERVICES
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

--// ================= DATA =================
local EggList = {}
local SelectedEggs = {}
local Collected = 0
local StartTime = tick()

--// ================= AUTO DETECT EGG =================
function scanEggs()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildWhichIsA("ProximityPrompt") then
            if string.find(v.Name:lower(),"egg") then
                EggList[v.Name] = true
            end
        end
    end
end

scanEggs()

--// ================= GUI =================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "EggAdvancedHub"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,350)
frame.Position = UDim2.new(0.3,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🥚 ADVANCED EGG HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

local extBtn = Instance.new("TextButton", frame)
extBtn.Size = UDim2.new(1,0,0,40)
extBtn.Position = UDim2.new(0,0,0,210)
extBtn.Text = "External Script: OFF"
extBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)

extBtn.MouseButton1Click:Connect(function()
    getgenv().LoadExternal = not getgenv().LoadExternal
    
    extBtn.Text = "External Script: "..(getgenv().LoadExternal and "ON" or "OFF")
    
    if getgenv().LoadExternal then
        loadExternalScript()
    end
end)

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,0,0,200)
scroll.Position = UDim2.new(0,0,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,500)

local layout = Instance.new("UIListLayout", scroll)

-- CREATE CHECKBOX
function createToggle(name)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = "[ ] "..name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)
    
    SelectedEggs[name] = false
    
    btn.MouseButton1Click:Connect(function()
        SelectedEggs[name] = not SelectedEggs[name]
        btn.Text = (SelectedEggs[name] and "[✔] " or "[ ] ")..name
    end)
end

-- LOAD GUI LIST
for name,_ in pairs(EggList) do
    createToggle(name)
end

-- AUTO REFRESH (detect egg mới)
task.spawn(function()
    while true do
        task.wait(10)
        scanEggs()
    end
end)

-- BUTTON AUTO
local autoBtn = Instance.new("TextButton", frame)
autoBtn.Size = UDim2.new(1,0,0,40)
autoBtn.Position = UDim2.new(0,0,0,250)
autoBtn.Text = "Auto: OFF"
autoBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)

autoBtn.MouseButton1Click:Connect(function()
    getgenv().AutoEgg = not getgenv().AutoEgg
    autoBtn.Text = "Auto: "..(getgenv().AutoEgg and "ON" or "OFF")
end)

-- STATS
local stats = Instance.new("TextLabel", frame)
stats.Size = UDim2.new(1,0,0,40)
stats.Position = UDim2.new(0,0,0,300)
stats.BackgroundTransparency = 1
stats.TextColor3 = Color3.new(1,1,1)
stats.TextScaled = true

--// ================= FIND =================
function getEgg()
    local closest, dist = nil, math.huge
    
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildWhichIsA("ProximityPrompt") then
            
            if SelectedEggs[v.Name] then
                local d = (hrp.Position - v.Position).Magnitude
                
                if d < dist then
                    dist = d
                    closest = v
                end
            end
        end
    end
    
    return closest
end

--// ================= MOVE =================
function move(target)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(hrp.Position, target.Position)
    
    if path.Status == Enum.PathStatus.Success then
        for _,wp in ipairs(path:GetWaypoints()) do
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(2)
        end
    end
end

--// ================= ESP =================
function esp(obj)
    if not getgenv().ShowESP then return end
    if obj:FindFirstChild("ESP") then return end
    
    local bill = Instance.new("BillboardGui", obj)
    bill.Size = UDim2.new(0,160,0,50)
    bill.AlwaysOnTop = true
    
    local txt = Instance.new("TextLabel", bill)
    txt.Size = UDim2.new(1,0,1,0)
    txt.BackgroundTransparency = 1
    txt.TextScaled = true
    
    RunService.RenderStepped:Connect(function()
        if obj and obj.Parent then
            local dist = math.floor((hrp.Position - obj.Position).Magnitude)
            txt.Text = obj.Name.." | "..dist
        end
    end)
end

--// ================= STATS UPDATE =================
RunService.Heartbeat:Connect(function()
    local time = (tick() - StartTime) / 3600
    local rate = math.floor(Collected / (time > 0 and time or 1))
    
    stats.Text = "🥚 "..Collected.." | ⚡ "..rate.."/h"
end)

--// ================= MAIN =================
task.spawn(function()
    while true do
        task.wait(0.3)
        
        if getgenv().AutoEgg then
            local egg = getEgg()
            
            if egg then
                esp(egg)
                move(egg)
                
                local prompt = egg:FindFirstChildWhichIsA("ProximityPrompt")
                if prompt then
                    fireproximityprompt(prompt)
                    Collected += 1
                end
            end
        end
    end
end)
