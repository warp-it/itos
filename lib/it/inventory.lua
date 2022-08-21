local component = require("component")

local inventory = {
    types = { "chest", "crystal", "iron", "gold", "diamond" },
}

function inventory.list()
    local result = {}

    for _, type in ipairs(inventory.types) do
        for address, _ in component.list(type) do
            result[address] = {
                label = string.format("%s (%s)", address, type),
                address = address,
                proxy = function() return component.proxy(address) end,
            }
        end
    end

    return result
end

function inventory.sides()
    return { "DOWN", "UP", "NORTH", "SOUTH", "WEST", "EAST", "UNKNOWN" }
end

function inventory.dummy()
    return {
        label = "[Не выбрано]",
        address = "",
        proxy = function() return nil end,
    }
end

function inventory.dummySide()
    return "UNKNOWN"
end



return inventory