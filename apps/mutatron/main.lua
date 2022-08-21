local scene = require("scene")
local inventory = require("inventory")
local json = require("json")

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
            menu.add(chest.label, function() onSelect(chest) end)
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

function app.buttonSelectInventory(menu, code, title)
    local value = app.config[code]

    menu.add(string.format("%s - %s (%s)", value.label, code, title), function()
        app.selectInventory(title, function(selection)
            app.config[code] = selection
            app.saveConfig()
            app.reset()
        end, function()
            app.reset()
        end)
    end)
end

function app.buttonSelectSide(menu, code, title)
    local value = app.config[code]

    menu.add(string.format("%s - %s (%s)", value, code, title), function()
        app.selectSide(title, function(selection)
            app.config[code] = selection
            app.saveConfig()
            app.reset()
        end, function()
            app.reset()
        end)
    end)
end

function app.reset()
    scene.menu("Настройка", function(menu)
        menu.add("Назад", app.main)
        menu.add("")
        app.buttonSelectInventory(menu, "sample", "Сундук образца")
        app.buttonSelectInventory(menu, "input", "Сундук входа каменных")
        app.buttonSelectInventory(menu, "output", "Сундук выхода мутированных")
        app.buttonSelectInventory(menu, "reverse", "Сундук обратного хода в пасеку")
        app.buttonSelectInventory(menu, "decision", "Сундук принятия решений (центр)")
        menu.add("")
        app.buttonSelectSide(menu, "side_input_to_decision", "От сундука входа к сундуку принятия решений")
        app.buttonSelectSide(menu, "side_decision_to_reverse", "От сундука принятия решений к сундуку обратного хода")
        app.buttonSelectSide(menu, "side_decision_to_output", "От сундука принятия решений к сундуку выхода")
    end)
end

function app.loop(state)
    local items = state.decision.all()

    for slot, item in pairs(items) do
        scene.setTitle(string.format("%d - %s", slot, json.encode(item)))
    end
end

function app.run()
    local isRunning = true

    scene.menu("Приступаем к мутациям", function(menu)
        menu.add("Остановить", function()
            isRunning = false
        end)
    end)

    local state = {
        mutating = false,
        decision = inventory.makeProxy(app.config.decision),
    }

    while isRunning do
        app.loop(state)
        scene.handleEvents()
        os.sleep(1)
    end

    app.main()
end

function app.main()
    scene.menu("Мутатор", function(menu)
        menu.add("Запуск", app.run)
        menu.add("Настройка", app.reset)
        menu.add("Выход", function() scene.clear() os.exit() end)
    end)
end

app.loadConfig()
app.main()
while alive do scene.handleEvents() end
scene.clear()