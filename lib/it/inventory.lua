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



return inventory