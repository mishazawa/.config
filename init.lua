local log = hs.logger.new('Missha', 'info')
local FLOATING_SPACE = 2

local function getSpaceNames()
  local spacesByDisplay = hs.spaces.allSpaces()
  local result = {}
  for display, spaces in pairs(spacesByDisplay) do
    for i, sid in ipairs(spaces) do
      result[sid] = "Desktop " .. i
    end
  end
  return result
end

function findWindowUnderCursor () 
  local position = hs.geometry.new(hs.mouse.absolutePosition())
  local screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(),
    function(w) return screen == w:screen() and position:inside(w:frame()) end)
end

function reloadAutoRaise()
  local appName = "AutoRaise"
  local appPath = "/Applications/AutoRaise.app"
  local appArgs = [[--args -pollMillis 50 -delay 1 -scale 2.5 -altTaskSwitcher false -ignoreSpaceChanged false -disableKey control -mouseDelta 100.0]]

  local app = hs.application.get(appName)
  if app then
    app:kill()
  end

  hs.timer.doAfter(0.5, function()
    local cmd = string.format("open -n %s %s", appPath, appArgs)
    hs.execute(cmd, true)
    log.i("AutoRaise reloaded.")
  end)
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

local spaceNames = getSpaceNames()

spacesWatcher = hs.spaces.watcher.new(function()
    local spaceID = hs.spaces.focusedSpace()
    local name = spaceNames[spaceID] or ("Space " .. tostring(spaceID))

    if name == "Desktop 2" then
        hs.execute("aerospace enable off", true)
        log.i("Aerospace disabled on " .. name)
    else
        hs.execute("aerospace enable on", true)
        log.i("Aerospace enabled on " .. name)
    end
end)




hs.hotkey.bind({"cmd", "alt", "ctrl"}, "R", function()
  cancelCmdClick:stop()
  hs.reload()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "P", function () 
  local profile, status = hs.execute("karabiner_cli --show-current-profile-name", true)
  if profile == "Krita\n" then 
    hs.execute("karabiner_cli --select-profile 'Rebelle'", true)
    hs.notify.new({title="Macropad", informativeText="Rebelle"}):send()
  else
    hs.execute("karabiner_cli --select-profile 'Krita'", true)
    hs.notify.new({title="Macropad", informativeText="Krita"}):send()
  end
end)


hs.hotkey.bind({"shift", "alt"}, "return", function()
    hs.execute("open -n /Applications/kitty.app", true)
end)

hs.hotkey.bind({"shift", "alt"}, "delete", function()
    hs.execute("aerospace enable toggle", true)
end)




local function initConfig()
  reloadAutoRaise()
  cancelCmdClick:start()
  hs.alert.show("Config loaded")
end

-- Run startup tasks
initConfig()
