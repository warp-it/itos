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

function app.selectInventory(title, onSelect, onCancel)
    scene.menu(string.format("Выбор инвентаря (%s)", title), function(menu)
        menu.add("Назад", function() onCancel() end)
        menu.add("")

        for address, chest in pairs(inventory.list()) do
            menu.add(string.format("%s (%s)", address, chest.type), function() onSelect(chest) end)
        end
    end)
end

function app.selectSide(title, onSelect, onCancel)
    scene.menu(string.format("Выбор стороны (%s)", title), function(menu)
        menu.add("Назад", function() onCancel() end)
        menu.add("")

        for _, side in ipairs(inventory.sides()) do
            menu.add(string.format("%s", side), function() onSelect(side) end)
        end
    end)
end

function app.buttonSelect(menu, func, code, title)
    local value = app.config[code]

    menu.add(string.format("%s - %s (%s)", value.label, code, title), function()
        func(title, function(selection)
            app.config[code] = selection
        end, function()
            app.reset()
        end)
    end)
end

function app.reset()
    scene.menu("Настройка", function(menu)
        menu.add("Назад", app.main)
        menu.add("")
        app.buttonSelect(menu, app.selectInventory, "sample", "Сундук образца")
        app.buttonSelect(menu, app.selectInventory, "input", "Сундук входа каменных")
        app.buttonSelect(menu, app.selectInventory, "output", "Сундук выхода мутированных")
        app.buttonSelect(menu, app.selectInventory, "reverse", "Сундук обратного хода в пасеку")
        app.buttonSelect(menu, app.selectInventory, "decision", "Сундук принятия решений (центр)")
        menu.add("")
        app.buttonSelect(menu, app.selectSide, "side_input_to_decision", "От сундука входа к сундуку принятия решений")
        app.buttonSelect(menu, app.selectSide, "side_decision_to_reverse", "От сундука принятия решений к сундуку обратного хода")
        app.buttonSelect(menu, app.selectSide, "side_decision_to_output", "От сундука принятия решений к сундуку выхода")
    end)
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