-- Run from repository root: lua tests/runtime_test.lua
local install = dofile("runtime.lua")
local current, window, defining = "", nil, ""
local bindings, timers, events = {}, {}, {}
hl = {
  get_active_window = function() return window end,
  get_current_submap = function() return current end,
  dsp = {
    submap = function(name) return {kind = "submap", name = name} end,
    window = {fullscreen = function(opts) return {kind = "fullscreen", opts = opts} end},
  },
  dispatch = function(d)
    if d.kind == "submap" then current = d.name == "reset" and "" or d.name end
    if d.kind == "fullscreen" then window.fullscreen = window.fullscreen == 2 and 0 or 2 end
  end,
  define_submap = function(name, callback) defining = name; callback(); defining = "" end,
  bind = function(key, dispatcher)
    local b = {key = key, dispatcher = dispatcher, submap = defining, removed = false}
    function b:remove() self.removed = true end
    table.insert(bindings, b)
    return b
  end,
  timer = function(callback)
    local t = {callback = callback, enabled = true}
    function t:set_enabled(value) self.enabled = value end
    table.insert(timers, t)
    return t
  end,
  on = function(event, callback)
    local e = {callback = callback, removed = false}
    function e:remove() self.removed = true end
    events[event] = events[event] or {}
    table.insert(events[event], e)
    return e
  end,
}
local function flush()
  for _, t in ipairs(timers) do
    if t.enabled then t.enabled = false; t.callback() end
  end
end
local function emit(event)
  for _, e in ipairs(events[event] or {}) do if not e.removed then e.callback() end end
  flush()
end
local function expect(label, value)
  assert(current == value, label .. ": got " .. current)
  print("PASS: " .. label)
end
local function remote(fs)
  return {class = "rustdesk", title = "Example - Remote Desktop - RustDesk", mapped = true, fullscreen = fs}
end
install("first")
flush()
expect("no focused window", "")
window = remote(0); emit("window.active"); expect("windowed remote", "")
window.fullscreen = 2; emit("window.fullscreen"); expect("fullscreen remote", "rustdesk-fullscreen")
assert(#bindings == 1 and bindings[1].key == "SUPER + F")
hl.dispatch(bindings[1].dispatcher); emit("window.fullscreen"); expect("exit key dispatcher", "")
window.fullscreen = 2; emit("window.fullscreen")
window = nil; emit("window.close"); expect("close remote", "")
window = remote(2); emit("window.active")
window.class = "other"; emit("window.class"); expect("other fullscreen app", "")
window = remote(2); window.title = "RustDesk"; emit("window.title"); expect("home window excluded", "")
window = remote(1); emit("window.fullscreen"); expect("maximized excluded", "")
current = "resize"; window = remote(2); emit("window.active"); expect("unrelated submap preserved", "resize")
current = ""; emit("window.active")
local old = _G.omarchy_rustdesk_passthrough
install("second"); flush()
assert(old.stopped and bindings[1].removed and not bindings[2].removed)
old.stop(); expect("old cleanup cannot stop replacement", "rustdesk-fullscreen")
_G.omarchy_rustdesk_passthrough.stop(); flush()
expect("disable resets shortcuts", "")
assert(_G.omarchy_rustdesk_passthrough == nil and bindings[2].removed)
window = remote(2); emit("window.fullscreen"); expect("disabled callbacks inactive", "")
install("third"); flush(); expect("enable again", "rustdesk-fullscreen")
_G.omarchy_rustdesk_passthrough.stop()
print("All runtime tests passed.")
