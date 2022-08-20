local json = require("json")
local fs = require("filesystem")

local config = {
    data = {}
}

local configFileName = "/home/config.json"

function config.regenerate()
    config.data = {
        theme = "default",
        autorun = "",
    }
    config.save()
end

function config.load()
    if not fs.exists(configFileName) then config.regenerate() return end

    local configFile = io.open(configFileName, "r")
    local content = configFile:read("*a")
    configFile:close()

    local success, result = pcall(json.decode, content)
    if success then config.data = result else config.regenerate() end
end

function config.save()
    local configFile = io.open(configFileName, "w")
    configFile:write(json.encode(config.data))
    configFile:close()
end

config.load()
return config