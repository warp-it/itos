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

function apps.listInner(proxy, base, items)
    for appPath in fs.list(base) do
        appPath = base..appPath

        local item = apps.info(appPath)
        if item ~= nil then
            item.path = appPath
            item.proxy = proxy
            table.insert(items, item)
        end
    end
end

function apps.list()
    local items = {}
    local mainFileSystem, _ = fs.get("/")

    apps.listInner(mainFileSystem, "/"..basePath, items)

    -- External apps
    for mount in fs.list(mountsPath) do
        local subSystem, _ = fs.get(mountsPath..mount)

        if subSystem.address ~= mainFileSystem.address then
            apps.listInner(subSystem, mountsPath..mount..basePath, items)
        end
    end

    return items
end

function apps.run(appFolder)
    local path = appFolder.."main.lua"
    if fs.exists(path) then os.execute("crash /home/error.log "..path) end
end

function apps.edit(appFolder, deleteBeforeEdit)
    local path = appFolder.."main.lua"
    if fs.exists(path) then
        if deleteBeforeEdit then os.execute("rm "..path) end
        os.execute("edit "..path)
    end
end

return apps