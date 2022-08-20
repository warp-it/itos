local json = require("json")
local fs = require("filesystem")
local os = require("os")

local apps = {
}

local basePath = "apps/"
local mountsPath = "/mnt/"

function apps.info(appFolder)
    local infoPath = appFolder.."info.json"
    if not fs.exists(infoPath) then return nil end

    local infoFile = io.open(infoPath, "r")
    local content = infoFile:read("*a")
    infoFile:close()

    local success, result = pcall(json.decode, content)
    if success then return result else return nil end
end

function apps.listInner(base, items)
    for appPath in fs.list(base) do
        appPath = base..appPath

        local item = apps.info(appPath)
        if item ~= nil then
            item.path = appPath
            table.insert(items, item)
        end
    end
end

function apps.list()
    local items = {}

    apps.listInner("/"..basePath, items)

    -- External apps
    for mount in fs.list(mountsPath) do
        apps.listInner(mountsPath..mount..basePath, items)
    end

    return items
end

function apps.run(appFolder)
    local path = appFolder.."main.lua"
    if fs.exists(path) then os.execute(path) end
end

function apps.edit(appFolder)
    local path = appFolder.."main.lua"
    if fs.exists(path) then os.execute("edit "..path) end
end

return apps