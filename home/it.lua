local menuLib = require("menu")
local messageLib = require("message")
local scene = require("scene")
local apps = require("apps")
local config = require("config")
local computer = require("computer")
local net = require("net")
local fs = require("filesystem")

local it = {}

function it.menu(title, makeItems)
    scene.setTitle(title)
    local menu = menuLib.create()
    makeItems(menu)
    scene.setCurrent(menu)
    scene.repaint()
end

function it.message(title, text)
    scene.setTitle(title)
    local message = messageLib.create(text)
    scene.setCurrent(message)
    scene.repaint()
end

function it.error(text)
    it.message("Ошибка", text)
end

function it.apps()
    it.menu("Запустить программу", function(menu)
        menu.add("Назад", it.mainMenu)

        local appItems = apps.list()
        for _, appItem in ipairs(appItems) do
            menu.add(appItem.name, function()
                apps.run(appItem.path)
                it.mainMenu()
            end)
        end
    end)
end

function it.edit()
    it.menu("Редактировать программу", function(menu)
        menu.add("Назад", it.mainMenu)

        local appItems = apps.list()
        for _, appItem in ipairs(appItems) do
            menu.add(appItem.name, function()
                apps.edit(appItem.path)
                it.mainMenu()
            end)
        end
    end)
end

function it.setAutorun(value)
    config.data.autorun = value
    config.save()
end

function it.autorun()
    it.menu("Настройка автозапуска", function(menu)
        menu.add("Назад", it.mainMenu)
        menu.add("Выключить автозапуск", function() it.setAutorun("") it.mainMenu() end)

        local appItems = apps.list()
        for _, appItem in ipairs(appItems) do
            menu.add(appItem.name, function()
                it.setAutorun(appItem.path)
                it.mainMenu()
            end)
        end
    end)
end

function it.exitToShell()
    scene.clear()
    os.exit()
end

function it.doSetup(basePath, appItem)
    local result = net.json("apps", {
        command = "files",
        code = appItem.code
    })
    if not result.success then
        it.error(result.message)
        return
    end

    fs.makeDirectory(basePath)
    local files = result.message
    local max = #files
    local step = 1

    for _, file in ipairs(files) do
        local fileName = basePath..file.name
        local filePath = basePath..file.path

        local stepInfo = "["..step.." / "..max.."]"
        step = step + 1
        it.message("Установка "..appItem.name, stepInfo.."\nСкачивание "..fileName)

        fs.makeDirectory(filePath)

        local fileResult = net.json("apps", {
            command = "file",
            code = appItem.code,
            file = file.name
        })
        if not fileResult.success then
            it.error(fileResult.message)
            return
        end

        local handle = fs.open(fileName, "w")
        handle:write(fileResult.message)
        handle:close()
    end
end

function it.setup()
    it.menu("Скачать программу", function(menu)
        menu.add("Назад", it.mainMenu)

        local result = net.json("apps", {
            command = "apps"
        })
        if result.success == true then
            local appItems = result.message

            for _, appItem in ipairs(appItems) do
                local base = "/apps/"..appItem.code.."/"

                if not fs.exists(base) then
                    menu.add(appItem.name, function()
                        it.doSetup(base, appItem)
                        it.mainMenu()
                    end)
                end
            end
        else
            menu.add(result.message)
        end
    end)
end

function it.delete()
    it.menu("Удалить программу", function(menu)
        menu.add("Назад", it.mainMenu)

        local appItems = apps.list()
        for _, appItem in ipairs(appItems) do
            menu.add(appItem.name, function()
                fs.remove("/apps/"..appItem.path)
                it.mainMenu()
            end)
        end
    end)
end

function it.reboot() computer.shutdown(true) end
function it.shutdown() computer.shutdown(false) end

function it.mainMenu()
    it.menu("IT Менеджер", function(menu)
        menu.add("Запустить программу", it.apps)
        menu.add("Редактировать программу", it.edit)
        --menu.add("Скачать программу", it.setup)
        --menu.add("Удалить программу", it.delete)
        menu.add("")
        menu.add("Настройка автозапуска", it.autorun)
        menu.add("В консоль", it.exitToShell)
        menu.add("Перезагрузить", it.reboot)
        menu.add("Выключить", it.shutdown)
    end)
end

it.mainMenu()
while true do scene.handleEvents() end
