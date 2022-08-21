local component = require("component")
local scene = require("scene")

local app = {}
local alive = true

function app.error(text)
    scene.menu("Ошибка", function(menu)
        menu.add(text)
        menu.add("Назад", app.devices)
    end)
end

function app.expand(address, type)
    local device = component.proxy(address)
    if device == nil then app.error(string.format("Компонент %s не найден", address)) return end

    scene.menu(string.format("Документация %s (%s)", address, type), function(menu)
        for field, doc in pairs(device) do
            menu.add(string.format("[%s] %s", field, doc))
        end

        menu.add("")
        menu.add("Назад", app.devices)
    end)
end

function app.devices()
    scene.menu("Устройства", function(menu)
        for address, type in pairs(component.list()) do
            menu.add(string.format("%s (%s)", address, type), function() app.expand(address, type) end)
        end

        menu.add("")
        menu.add("Выход", function() alive = false end)
    end)
end

app.devices()
while alive do scene.handleEvents() end
scene.clear()