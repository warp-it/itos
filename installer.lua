local component = require("component")
local term = require("term")
local os = require("os")
local filesystem = require("filesystem")
local inet = require("internet")

local filesystems = {}
for address, _ in component.list("filesystem") do table.insert(filesystems, component.proxy(address)) end

print("Выберите диск для установки:")
for i, fs in ipairs(filesystems) do print(string.format("%d - %s (%s)", i, fs.address, fs.getLabel())) end
print("")

local selection = tonumber(term.read())
local fs = filesystems[selection]
if fs == nil then print("Неправильный номер диска") os.exit() end

filesystem.mount(fs, "/mnt/itos")

local function write(file, content)
    local handle = fs.open(file)
    handle:write(content)
    handle:close()
end

local function get(url)
    local result = ""
    for chunk in inet.request(url) do
        result = result .. chunk
    end
    return result
end

local files = get("https://raw.githubusercontent.com/warp-it/itos/main/files")

for line in files:gmatch("[^\r\n]+") do

end
