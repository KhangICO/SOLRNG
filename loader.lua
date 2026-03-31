--// MAIN LOADER

local BASE = "https://raw.githubusercontent.com/KhangICO/SOLRNG/main/modules/"

local ModulesList = {
    "config",
    "autofarm",
    "esp",
    "stats",
    "ui"
}

local Modules = {}
getgenv().Modules = Modules

local function fetch(name)
    local url = BASE .. name .. ".lua"
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    
    if ok then
        return res
    else
        warn("Retry:", name)
        task.wait(1)
        return fetch(name)
    end
end

for _,name in ipairs(ModulesList) do
    local code = fetch(name)
    local success, module = pcall(function()
        return loadstring(code)()
    end)
    
    if success and module then
        Modules[name] = module
        print("Loaded:", name)
    end
end

-- AUTO START
if Modules.autofarm then Modules.autofarm.start() end
if Modules.ui then Modules.ui.start() end
