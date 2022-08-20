local gui = require("gui")
local keyboard = require("keyboard")

local menuLib = {
}

function menuLib.create()
    local menu = {
        items = {},
        selectedIndex = 1,
    }

    menu.add = function(title, callback)
        menu.addItem({
            title = title,
            callback = callback,
        })
    end
    menu.addItem = function(item)
        table.insert(menu.items, item)
    end
    menu.execute = function()
        local item = menu.items[menu.selectedIndex]
        if item ~= nil and item.callback ~= nil then item.callback() end
    end
    menu.moveSelection = function(step)
        local tmp = menu.selectedIndex + step - 1
        local count = #menu.items

        if count == 1 then
            tmp = 0
        else
            if tmp >= 0 then
                tmp = math.fmod(tmp, count)
            else
                tmp = count - math.fmod(math.abs(tmp), count)
            end
        end

        menu.selectedIndex = tmp + 1
        menu.repaint()
    end
    menu.repaint = function()
        gui.listDraw(2, 3, gui.width - 3, gui.height - 3, menu.items, menu.selectedIndex)
    end
    menu.key_down = function(address, char, code, playerName)
        if (code == keyboard.keys.up) then menu.moveSelection(-1) end
        if (code == keyboard.keys.down) then menu.moveSelection(1) end
        if (code == keyboard.keys.enter) then menu.execute() end
    end

    return menu
end

return menuLib