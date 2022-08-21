local menuLib = require("menu")
local messageLib = require("message")
local scene = require("scene")
local apps = require("apps")
local config = require("config")
local computer = require("computer")
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

function it.appsList(title, action, onBefore)
    it.menu(title, function(menu)
        menu.add("Назад", it.mainMenu)
        if onBefore ~= nil then onBefore(menu) end
        menu.add("")

        local appItems = apps.list()
        for _, appItem in ipairs(appItems) do
            local proxy = appItem.proxy
            local label = appItem.name
            if proxy ~= nil then label = string.format("%s (%s)", label, proxy.getLabel()) end

            menu.add(label, function()
                action(appItem)
            end)
        end
    end)
end

function it.apps()
    it.appsList("Запустить программу", function(appItem)
        apps.run(appItem.path)
        it.mainMenu()
    end)
end

function it.edit()
    it.appsList("Редактировать программу", function(appItem)
        scene.clear()
        apps.edit(appItem.path)
        it.mainMenu()
    end)
end

function it.setAutorun(value)
    config.data.autorun = value
    config.save()
end

function it.autorun()
    it.appsList("Настройка автозапуска", function(appItem)
        it.setAutorun(appItem.path)
        it.mainMenu()
    end, function(menu)
        menu.add("Выключить автозапуск", function() it.setAutorun("") it.mainMenu() end)
    end)
end

function it.exitToShell()
    scene.clear()
    os.exit()
end

function it.delete()
    it.appsList("Удалить программу", function(appItem)
        fs.remove("/apps/"..appItem.path)
        it.mainMenu()
    end)
end

function it.reboot() computer.shutdown(true) end
function it.shutdown() computer.shutdown(false) end

function it.mainMenu()
    it.menu("IT Менеджер", function(menu)
        menu.add("Запустить программу", it.apps)
        menu.add("Редактировать программу", it.edit)
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
