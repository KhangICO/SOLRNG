--// SETTINGS
getgenv().AutoEgg = false
getgenv().ShowESP = true
getgenv().AutoHop = false
getgenv().LoadExternal = false

--// SERVICES
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

--// DATA
local EggList = {}
local SelectedEggs = {}
local Collected = 0
local StartTime = tick()

--// RARITY TABLE
local Rarity = {
    ["Dreamer Egg"] = "0.1%",
    ["Egg V2.0"] = "0.2%",
    ["Andromeda Egg"] = "0.3%",
    ["Angelic Egg"] = "0.5%",
    ["Royal Egg"] = "1%",
    ["Point Egg VI"] = "5%",
    ["Point Egg V"] = "10%",
}

--// HUMAN DELAY
function delayRandom(a,b)
    task.wait(math.random(a*100,b*100)/100)
end

--// SCAN EGGS
function scanEggs()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildWhichIsA("ProximityPrompt") then
            if v.Name:lower():find("egg") then
                EggList[v.Name] = true
            end
        end
    end
end
scanEggs()

--// GUI
local gui = Instance.new("ScreenGui", lp.PlayerGui)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,320,0,400)
frame.Position = UDim2.new(0.3,0,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🥚 ULTIMATE EGG HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

-- SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Size = UDim2.new(1,0,0,200)
scroll.Position = UDim2.new(0,0,0,40)
scroll.CanvasSize = UDim2.new(0,0,0,600)
local layout = Instance.new("UIListLayout", scroll)

-- TOGGLE EGG
function addEgg(name)
    if SelectedEggs[name] ~= nil then return end
    
    SelectedEggs[name] = false
    
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1,0,0,30)
    btn.Text = "[ ] "..name
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    
    btn.MouseButton1Click:Connect(function()
        SelectedEggs[name] = not SelectedEggs[name]
        btn.Text = (SelectedEggs[name] and "[✔] " or "[ ] ")..name
    end)
end

-- LOAD LIST
for name,_ in pairs(EggList) do
    addEgg(name)
end

-- AUTO UPDATE LIST
task.spawn(function()
    while true do
        task.wait(10)
        scanEggs()
        for name,_ in pairs(EggList) do
            addEgg(name)
        end
    end
end)

-- BUTTONS
function makeBtn(text,y,func)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,0,0,35)
    b.Position = UDim2.new(0,0,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(50,50,50)
    b.MouseButton1Click:Connect(func)
    return b
end

local autoBtn = makeBtn("Auto: OFF",250,function()
    getgenv().AutoEgg = not getgenv().AutoEgg
    autoBtn.Text = "Auto: "..(getgenv().AutoEgg and "ON" or "OFF")
end)

local hopBtn = makeBtn("AutoHop: OFF",290,function()
    getgenv().AutoHop = not getgenv().AutoHop
    hopBtn.Text = "AutoHop: "..(getgenv().AutoHop and "ON" or "OFF")
end)

local extBtn = makeBtn("External: OFF",330,function()
    getgenv().LoadExternal = not getgenv().LoadExternal
    extBtn.Text = "External: "..(getgenv().LoadExternal and "ON" or "OFF")
    
    if getgenv().LoadExternal then
        getgenv().AutoEgg = false
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KhangICO/SOLRNG/refs/heads/main/3667.lua"))()
    end
end)

-- STATS
local stats = Instance.new("TextLabel", frame)
stats.Size = UDim2.new(1,0,0,30)
stats.Position = UDim2.new(0,0,0,365)
stats.BackgroundTransparency = 1
stats.TextColor3 = Color3.new(1,1,1)

RunService.Heartbeat:Connect(function()
    local t = (tick()-StartTime)/3600
    local rate = math.floor(Collected/(t>0 and t or 1))
    stats.Text = "🥚 "..Collected.." | ⚡ "..rate.."/h"
end)

-- FIND
function getEgg()
    local best,dist=nil,math.huge
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v:FindFirstChildWhichIsA("ProximityPrompt") then
            if SelectedEggs[v.Name] then
                local d=(hrp.Position-v.Position).Magnitude
                if d<dist then dist=d best=v end
            end
        end
    end
    return best
end

-- MOVE
function move(target)
    local path=PathfindingService:CreatePath()
    path:ComputeAsync(hrp.Position,target.Position)
    if path.Status==Enum.PathStatus.Success then
        for _,wp in ipairs(path:GetWaypoints()) do
            hum:MoveTo(wp.Position)
            hum.MoveToFinished:Wait(2)
        end
    end
end

-- ESP
function esp(obj)
    if not getgenv().ShowESP then return end
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
            txt.Text=obj.Name.."\n"..d.." | "..(Rarity[obj.Name] or "?")
        end
    end)
end

-- AUTO RESET
local last=hrp.Position
local stuck=0
RunService.Heartbeat:Connect(function(dt)
    if not getgenv().AutoEgg then return end
    if (hrp.Position-last).Magnitude<1 then stuck+=dt else stuck=0 end
    last=hrp.Position
    if stuck>7 then hum.Health=0 stuck=0 end
end)

-- AUTO HOP
task.spawn(function()
    while true do
        task.wait(25+math.random(5))
        if getgenv().AutoEgg and getgenv().AutoHop then
            if not getEgg() then
                TeleportService:Teleport(game.PlaceId)
            end
        end
    end
end)

-- MAIN
task.spawn(function()
    while true do
        delayRandom(0.3,0.6)
        if getgenv().AutoEgg then
            local egg=getEgg()
            if egg then
                esp(egg)
                move(egg)
                local p=egg:FindFirstChildWhichIsA("ProximityPrompt")
                if p then
                    delayRandom(0.2,0.5)
                    fireproximityprompt(p)
                    Collected+=1
                end
            end
        end
    end
end)
