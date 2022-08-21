local scene = require("scene")
local inventory = require("inventory")

local function generateConfig()
    return {
        sample = inventory.dummy(),
        input = inventory.dummy(),
        output = inventory.dummy(),
        reverse = inventory.dummy(),
        decision = inventory.dummy(),
        side_input_to_decision = inventory.dummySide(),
        side_decision_to_reverse = inventory.dummySide(),
        side_decision_to_output = inventory.dummySide()
    }
end

local app = {
    config = generateConfig()
}
local alive = true

function app.loadConfig()
    local config = require("config")
    config.load()
    app.config = config.data.mutatron
    if app.config == nil then app.config = generateConfig() end
end

function app.saveConfig()
    local config = require("config")
    config.data.mutatron = app.config
    config.save()
end

function app.selectInventory(onSelect, onCancel)
    scene.menu("Выбор инвентаря", function(menu)
        menu.add("Назад", function() onCancel() end)
        menu.add("")

        for address, chest in pairs(inventory.list()) do
            menu.add(string.format("%s (%s)", address, chest.type), function() onSelect(chest) end)
        end
    end)
end

function app.reset()

end

function app.main()
    scene.menu("Мутатор", function(menu)
        menu.add("Запуск")
        menu.add("Настройка", app.reset)
        menu.add("Выход", function() scene.clear() os.exit() end)
    end)
end

app.main()
while alive do scene.handleEvents() end
scene.clear()