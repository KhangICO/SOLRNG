--// ULTIMATE LOADER

local BASE = "https://raw.githubusercontent.com/KhangICO/SOLRNG/main/modules/"
local FILES = {"Config","Core","Esp","Auto Collect","ui"}

local Cache = {}
local Modules = {}
getgenv().Modules = Modules

local function fetch(name)
    if Cache[name] then return Cache[name] end
    
    local url = BASE..name..".lua"
    
    local ok,res = pcall(function()
        return game:HttpGet(url)
    end)
    
    if ok then
        Cache[name] = res
        return res
    else
        warn("Retry:",name)
        task.wait(1)
        return fetch(name)
    end
end

for _,name in ipairs(FILES) do
    local code = fetch(name)
    local success,module = pcall(function()
        return loadstring(code)()
    end)
    
    if success and module then
        Modules[name] = module
    end
end

-- START
Modules.core.init()
Modules.ui.start()
Modules.autofarm.start()
