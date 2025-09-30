local log = hs.logger.new('Missha', 'info')

function findWindowUnderCursor () 
  local position = hs.geometry.new(hs.mouse.absolutePosition())
  local screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(),
    function(w) return screen == w:screen() and position:inside(w:frame()) end)
end

local function relaunchApp(appName, appPath, appArgs)
  local app = hs.application.get(appName)
  if app then
    app:kill()
    log.i("Restarting " .. appName .. "...")
  end

  hs.timer.doAfter(0.5, function()
    local cmd = string.format("open -n %s %s", appPath, appArgs or "")
    hs.execute(cmd, true)
    log.i(appName .. " relaunched")
  end)
end

function reloadAutoRaise()
  local appName = "AutoRaise"
  local appPath = "/Applications/AutoRaise.app"
  local appArgs = [[--args -pollMillis 50 -delay 1 -scale 2.5 -altTaskSwitcher false -ignoreSpaceChanged false -disableKey control -mouseDelta 100.0]]
  relaunchApp(appName, appPath, appArgs)
end


function reloadSignal()
  local appName = "Signal"
  local appPath = "/Applications/Signal.app"
  local appArgs = [[--args --use-tray-icon]]
  relaunchApp(appName, appPath, appArgs)
end

local cancelCmdClick = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function (e)
  local mods = hs.eventtap.checkKeyboardModifiers()
  
  if mods["alt"] then
    local window = findWindowUnderCursor()
    -- if no window under cursor then skip
    if not window then return end
    -- if the same window then skip
    if hs.window.focusedWindow() == window then return end
    -- finally focus window
    window:focus()
   end
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  cancelCmdClick:stop()
  hs.reload()
end)

hs.hotkey.bind({"shift", "alt"}, "return", function()
    hs.execute("open -n /Applications/kitty.app", true)
end)

hs.hotkey.bind({"shift", "alt"}, "delete", function()
    hs.execute("aerospace enable toggle", true)
end)

local function initConfig()
  reloadAutoRaise()
  reloadSignal()
  cancelCmdClick:start()
  hs.alert.show("Config loaded")
end

-- Run startup tasks
initConfig()
