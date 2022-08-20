local messageLib = require("message")
local menuLib = require("menu")
local event = require("event")
local scene = require("scene")
local apps = require("apps")
local config = require("config")
local computer = require("computer")

local autorun = {}
local doAutorun = false

local autorunPath = config.data.autorun
if autorunPath ~= nil and autorunPath ~= "" then
    doAutorun = true
end

function autorun.menu(title, makeItems)
    scene.setTitle(title)
    local menu = menuLib.create()
    makeItems(menu)
    scene.setCurrent(menu)
    scene.repaint()
end

function autorun.message(title, text)
    scene.setTitle(title)
    local message = messageLib.create(text)
    scene.setCurrent(message)
    scene.repaint()
end

function autorun.stop()
    doAutorun = false
    autorun.message("Автозапуск", "Остановлено, выходим..")
    scene.repaint()
end

function autorun.autorunWarning(timeout)
    autorun.message("Автозапуск "..autorunPath, "Нажмите любую клавишу, чтобы прервать\nОсталось "..timeout.." сек")
    scene.repaint()
    os.sleep(1)
end

local function checkKeyDown(address, char, code, playerName) autorun.stop() end
event.listen("key_down", checkKeyDown)

timeout = 5
while doAutorun and timeout > 0 do
    autorun.autorunWarning(timeout)
    timeout = timeout - 1
end
event.ignore("key_down", checkKeyDown)

if doAutorun then
    apps.run(autorunPath)
end

os.execute("/home/it")
