local gui = require("gui")

local messageLib = {
}

function messageLib.create(text, closeCallback)
    local message = {
        text = text
    }

    message.setText = function(newText)
        message.text = newText
    end
    message.repaint = function()
        gui.textDraw(2, 3, gui.width - 3, gui.height - 3, message.text)
    end
    message.key_down = function(address, char, code, playerName)
        if closeCallback ~= nil then closeCallback() end
    end

    return message
end

return messageLib