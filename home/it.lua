local messageLib = require("message")
local scene = require("scene")
local apps = require("apps")
local config = require("config")
local computer = require("computer")
local fs = require("filesystem")
local os = require("os")

local it = {}

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
    scene.menu(title, function(menu)
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
        apps.edit(appItem.path, false)
        it.mainMenu()
    end)
end

function it.redit()
    it.appsList("Редактировать программу с нуля", function(appItem)
        scene.clear()
        apps.edit(appItem.path, true)
        it.mainMenu()
    end)
end

function it.lua()
    scene.clear()
    os.execute("lua")
    it.mainMenu()
end

function it.update()
    scene.menu("Обновление", function(menu)
        menu.add("Назад", it.mainMenu)
        menu.add("Обновить", function() scene.clear() os.execute("pastebin run Xtws70Dp") end)
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
    scene.menu("IT Менеджер", function(menu)
        menu.add("Запустить программу", it.apps)
        menu.add("Редактировать программу", it.edit)
        menu.add("Редактировать программу с нуля", it.redit)
        --menu.add("Удалить программу", it.delete)
        menu.add("")
        menu.add("Настройка автозапуска", it.autorun)
        menu.add("В консоль", it.exitToShell)
        menu.add("Lua", it.lua)
        menu.add("Обновить", it.update)
        menu.add("")
        menu.add("Перезагрузить", it.reboot)
        menu.add("Выключить", it.shutdown)
    end)
end

it.mainMenu()
while true do scene.handleEvents() end
