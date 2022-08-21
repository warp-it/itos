local component = require("component")
local menuLib = require("menu")
local scene = require("scene")
local inventory = require("inventory")

local app = {}
local alive = true

function app.selectInventory(onSelect, onCancel)
    scene.setTitle("Выбор инвентаря")
    local menu = menuLib.create()

    for address, chest in pairs(inventory.list()) do
        menu.add(string.format("%s (%s)", address, chest.type), function() onSelect(chest) end)
    end

    scene.setCurrent(menu)
    scene.repaint()
end

function app.main()
    scene.setTitle("Мутатор")

    app.selectInventory(function() end, function() end)
end

app.main()
while alive do scene.handleEvents() end
scene.clear()