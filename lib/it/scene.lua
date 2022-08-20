local event = require("event")
local gui = require("gui")

local scene = {
    current = nil,
    title = "Menu",
}

function scene.setCurrent(current)
    scene.current = current
    scene.repaint()
end

function scene.setTitle(title)
    scene.title = title
end

function scene.repaint()
    gui.windowDraw(scene.title)
    if scene.current ~= nil then scene.current.repaint() end
end

function scene.clear()
    gui.clear()
end

local handlers = setmetatable(
        {},
        { __index = function() return function() end end }
)

function handlers.key_up(address, char, code, playerName)
    if scene.current.key_up ~= nil then
        scene.current.key_up(address, char, code, playerName)
    end
end

function handlers.key_down(address, char, code, playerName)
    if scene.current.key_down ~= nil then
        scene.current.key_down(address, char, code, playerName)
    end
end

function handlers.screen_resize(screenAddress, newWidth, newHeight)
    gui.updateResolution()
    if scene.current ~= nil then scene.current.repaint() end
end

function scene.handleEvent(eventId, ...)
    if (eventId) then handlers[eventId](...) end
end

function event.shouldInterrupt()
    return false
end

function scene.handleEvents()
    scene.handleEvent(event.pull())
end

gui.updateResolution()

return scene