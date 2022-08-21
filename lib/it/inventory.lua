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
    }
end

function inventory.dummySide()
    return "UNKNOWN"
end

function inventory.makeProxy(from)
    local proxy = component.proxy(from.address)

    return {
        ---@param direction string
        ---@param fromSlot number?
        ---@param maxAmount number?
        ---@param toSlot number?
        push = function(direction, fromSlot, maxAmount, toSlot)
            return proxy.pushItem(direction, fromSlot, maxAmount, toSlot)
        end,

        ---@param direction string
        ---@param fromSlot number?
        ---@param maxAmount number?
        ---@param toSlot number?
        pull = function(direction, fromSlot, maxAmount, toSlot)
            return proxy.pullItem(direction, fromSlot, maxAmount, toSlot)
        end,

        ---@return table
        all = function() return proxy.getAllStacks() end,

        ---@return number
        size = function() return proxy.getInventorySize() end
    }
end


return inventory