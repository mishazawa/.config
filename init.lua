hs.loadSpoon("Cherry")
spoon.Cherry:bindHotkeys()

function find_window_under_cursor () 
  local position = hs.geometry.new(hs.mouse.absolutePosition())
  local screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(),
    function(w) return screen == w:screen() and position:inside(w:frame()) end)
end

local cancelCmdClick = hs.eventtap.new({ hs.eventtap.event.types.leftMouseDown }, function (e)
  local mods = hs.eventtap.checkKeyboardModifiers()
  
  if mods["alt"] then
    local window = find_window_under_cursor()
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

cancelCmdClick:start()
hs.alert.show("Config loaded")