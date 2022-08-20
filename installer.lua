local component = require("component")
local term = require("term")
local os = require("os")
local filesystem = require("filesystem")
local inet = require("internet")
local computer = require("computer")

if computer.getArchitecture() ~= "Lua 5.3" then
    print("Обнаружена устаревшая архитектура процессора")
    print("Установщик поменяет архитектуру на Lua 5.3")
    print("Нажмите enter и запустите скрипт снова после перезагрузки")
    computer.setArchitecture("Lua 5.3")
end

local filesystems = {}
for address, _ in component.list("filesystem") do table.insert(filesystems, component.proxy(address)) end

print("Выберите диск для установки:")
for i, fs in ipairs(filesystems) do print(string.format("%d - %s (%s)", i, fs.address, fs.getLabel())) end
print("")

local selection = tonumber(term.read())
local fs = filesystems[selection]
if fs == nil then print("Неправильный номер диска") os.exit() end

local function write(file, content)
    local handle = fs.open(file, "w")
    handle:write(content)
    handle:close()
end

local function request(url)
    local result = ""
    for chunk in inet.request(url) do
        result = result .. chunk
    end
    return result
end

local function git(file)
    return request("https://raw.githubusercontent.com/warp-it/itos/main/"..file)
end

local function processList(address, callback)
    local list = git(address)
    for line in list:gmatch("[^\r\n]+") do callback(line) end
end

print("Запись системы на диск "..fs.address)
print("Форматирование диска..")

local listFiles = fs.list("/")
if listFiles ~= nil then for i = 1, #listFiles do fs.remove(listFiles[i]) end end

processList("folders", function(line)
    print("Создание директории "..line)
    fs.makeDirectory(line)
end)

processList("files", function(line)
    print("Запись файла "..line)
    write(line, git(line))
end)

computer.shutdown(true)
