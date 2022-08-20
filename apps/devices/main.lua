local component = require("component")
local menuLib = require("menu")
local scene = require("scene")

local app = {}
local alive = true

function app.error(text)
    scene.setTitle("Ошибка")
    local menu = menuLib.create()
    menu.add(text)
    menu.add("Назад", app.devices)
    scene.setCurrent(menu)
    scene.repaint()
end

function app.expand(address, type)
    local device = component.proxy(address)
    if device == nil then app.error(string.format("Компонент %s не найден", address)) return end

    scene.setTitle(string.format("Документация %s (%s)", address, type))

    local menu = menuLib.create()

    for field, doc in pairs(device) do
        menu.add(string.format("[%s] %s", field, doc))
    end

    menu.add("")
    menu.add("Назад", app.devices)

    scene.setCurrent(menu)
    scene.repaint()
end

function app.devices()
    scene.setTitle("Устройства")
    local menu = menuLib.create()

    for address, type in pairs(component.list()) do
        menu.add(string.format("%s (%s)", address, type), function() app.expand(address, type) end)
    end

    menu.add("")
    menu.add("Выход", function() alive = false end)
    scene.setCurrent(menu)
    scene.repaint()
end

app.devices()
while alive do scene.handleEvents() end
scene.clear()