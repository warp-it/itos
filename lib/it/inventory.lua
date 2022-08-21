local component = require("component")

local inventory = {
    types = { "chest", "crystal", "iron", "gold", "diamond" },
}

function inventory.list()
    local result = {}

    for _, type in ipairs(inventory.types) do
        for address, _ in component.list(type) do
            result[address] = component.proxy(address)
        end
    end

    return result
end

function inventory.sides()
    return { "DOWN", "UP", "NORTH", "SOUTH", "WEST", "EAST", "UNKNOWN" }
end

function inventory.dummy()
    return {
        label = "[Не выбрано]"
    }
end

function inventory.dummySide()
    return "UNKNOWN"
end



return inventory