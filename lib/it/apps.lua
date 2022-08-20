local json = require("json")
local fs = require("filesystem")
local os = require("os")

local apps = {
}

local basePath = "/apps/"

function apps.info(appFolder)
    local infoPath = basePath..appFolder.."info.json"
    if not fs.exists(infoPath) then return nil end

    local infoFile = io.open(infoPath, "r")
    local content = infoFile:read("*a")
    infoFile:close()

    local success, result = pcall(json.decode, content)
    if success then return result else return nil end
end

function apps.list()
    local items = {}
    for appPath in fs.list(basePath) do
        local item = apps.info(appPath)
        if item ~= nil then
            item.path = appPath
            table.insert(items, item)
        end
    end

    return items
end

function apps.run(appFolder)
    local path = basePath..appFolder.."main.lua"
    if fs.exists(path) then os.execute(path) end
end

function apps.edit(appFolder)
    local path = basePath..appFolder.."main.lua"
    if fs.exists(path) then os.execute("edit "..path) end
end

return apps