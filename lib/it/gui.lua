local themes = require("themes")
local component = require("component")
local text = require("text")
local gpu = component.gpu

local gui = {
    theme = themes.default
}

function gui.setTheme(theme)
    gui.theme = theme
end

function gui.updateResolution()
    local width, height = gpu.getResolution()
    gui.width = width
    gui.height = height
end

function gui.textDraw(x, y, width, height, content)
    local theme = gui.theme

    gpu.setBackground(theme.background)
    gpu.setForeground(theme.foreground)
    for line in text.wrappedLines(content, width, width) do
        gpu.set(x, y, line)
        y = y + 1
    end
end

function gui.listDraw(x, y, width, height, items, activeIndex)
    local theme = gui.theme

    local half = math.floor(height / 2)
    local count = #items
    local from = math.max(1, activeIndex - half)
    local to = math.min(count, from + height - 1)
    local lastLine = y + height

    for i = from, to do
        gui.listItemDraw(x, y, width, 1, items[i], activeIndex == i)
        y = y + 1
    end

    gpu.setBackground(theme.background)
    gpu.fill(x, y, width, lastLine - y, " ")
end

function gui.listItemDraw(x, y, width, height, item, isActive)
    local theme = gui.theme

    if isActive then
        gpu.setBackground(theme.list_active_foreground)
        gpu.setForeground(theme.list_active_background)
    else
        gpu.setBackground(theme.list_inactive_background)
        gpu.setForeground(theme.list_inactive_background)
    end
    gpu.set(x, y, "◖")
    gpu.set(x + width - 1, y, "◗")

    if isActive then
        gpu.setBackground(theme.list_active_background)
        gpu.setForeground(theme.list_active_foreground)
    else
        gpu.setBackground(theme.list_inactive_background)
        gpu.setForeground(theme.list_inactive_foreground)
    end
    gpu.fill(x + 1, y, width - 2, height, " ")


    gpu.set(x + 2, y, item.title)
end

function gui.windowDraw(title)
    local theme = gui.theme

    gpu.setBackground(theme.background)
    gpu.fill(1, 1, gui.width, gui.height, " ")

    gpu.setBackground(theme.title_background)
    gpu.setForeground(theme.title_foreground)
    gpu.fill(1, 1, gui.width, 1, " ")
    gpu.set(2, 1, title)
end

return gui