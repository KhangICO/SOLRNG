local core = {}

function core.delay()
    task.wait(math.random(30,60)/100)
end

function core.safeCall(f)
    pcall(f)
end

function core.init()
    print("Core Loaded")
end

return core
