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
    term.read()
    computer.setArchitecture("Lua 5.3")
end

local filesystems = {}
local count = 0
local firstFilesystem = nil
for address, _ in component.list("filesystem") do
    local proxy = component.proxy(address)

    if proxy.getLabel() ~= "tmpfs" and proxy.getLabel() ~= "openos" then
        firstFilesystem = proxy
        table.insert(filesystems, proxy)
        count = count + 1
    end
end

local fs = firstFilesystem

if count < 1 then
    print("Отсутствует диск для установки (метка не tmpfs и не openos)")
    os.exit()
elseif count > 1 then
    print("Выберите диск для установки:")
    for i, item in ipairs(filesystems) do print(string.format("%d - %s (%s)", i, item.address, item.getLabel())) end
    print("")

    local selection = tonumber(term.read())
    fs = filesystems[selection]
    if fs == nil then print("Неправильный номер диска") os.exit() end
    print("")
end

local function write(file, content)
    local handle = fs.open("/"..file, "w")
    fs.write(handle, content)
    fs.close(handle)
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
fs.setLabel("itos")

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
