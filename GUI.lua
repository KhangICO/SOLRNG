--// GUI HUB REAL
local gui = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
gui.Name = "UltimateHubUI"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 500, 0, 320)
main.Position = UDim2.new(0.25,0,0.25,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.Active = true
main.Draggable = true

-- SIDEBAR
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0,120,1,0)
sidebar.BackgroundColor3 = Color3.fromRGB(25,25,25)

-- CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-120,1,0)
content.Position = UDim2.new(0,120,0,0)
content.BackgroundTransparency = 1

-- TITLE
local title = Instance.new("TextLabel", sidebar)
title.Size = UDim2.new(1,0,0,40)
title.Text = "🥚 HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

-- TAB SYSTEM
local tabs = {}
function createTab(name)
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(35,35,35)
    btn.TextColor3 = Color3.new(1,1,1)

    local frame = Instance.new("Frame", content)
    frame.Size = UDim2.new(1,0,1,0)
    frame.Visible = false
    frame.BackgroundTransparency = 1
    
    tabs[name] = frame

    btn.MouseButton1Click:Connect(function()
        for _,f in pairs(tabs) do f.Visible = false end
        frame.Visible = true
    end)

    return frame
end

-- CREATE TABS
local mainTab = createTab("Main")
local eggTab = createTab("Eggs")
local statTab = createTab("Stats")
local setTab = createTab("Settings")

tabs["Main"].Visible = true

-- ================= MAIN TAB =================
local function makeToggle(parent,text,posY,callback)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.8,0,0,40)
    btn.Position = UDim2.new(0.1,0,0,posY)
    btn.Text = text.." OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.TextColor3 = Color3.new(1,1,1)

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." "..(state and "ON" or "OFF")
        callback(state)
    end)
end

makeToggle(mainTab,"Auto Egg",20,function(v) getgenv().AutoEgg = v end)
makeToggle(mainTab,"Auto Hop",80,function(v) getgenv().AutoHop = v end)

-- ================= EGG TAB =================
local scroll = Instance.new("ScrollingFrame", eggTab)
scroll.Size = UDim2.new(1,0,1,0)
scroll.CanvasSize = UDim2.new(0,0,0,800)

local layout = Instance.new("UIListLayout", scroll)

function addEggUI(name)
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

for name,_ in pairs(EggList) do
    addEggUI(name)
end

-- ================= STATS TAB =================
local statLabel = Instance.new("TextLabel", statTab)
statLabel.Size = UDim2.new(1,0,1,0)
statLabel.TextColor3 = Color3.new(1,1,1)
statLabel.BackgroundTransparency = 1
statLabel.TextScaled = true

RunService.Heartbeat:Connect(function()
    local t = (tick()-StartTime)/3600
    local rate = math.floor(Collected/(t>0 and t or 1))
    statLabel.Text = "🥚 "..Collected.."\n⚡ "..rate.."/h"
end)

-- ================= SETTINGS TAB =================
makeToggle(setTab,"ESP",20,function(v) getgenv().ShowESP = v end)

makeToggle(setTab,"External Script",80,function(v)
    getgenv().LoadExternal = v
    if v then
        getgenv().AutoEgg = false
        loadstring(game:HttpGet("https://raw.githubusercontent.com/KhangICO/SOLRNG/refs/heads/main/3667.lua"))()
    end
end)
