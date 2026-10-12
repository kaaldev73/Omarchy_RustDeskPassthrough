-- Loaded into Hyprland by the Omarchy service. No configuration files are edited.
return function(token)
  assert(type(hl.get_active_window) == "function"
    and type(hl.define_submap) == "function"
    and type(hl.get_current_submap) == "function",
    "RustDesk passthrough requires Hyprland's Lua API (tested on 0.56.2)")

  local KEY = "omarchy_rustdesk_passthrough"
  local SUBMAP = "rustdesk-fullscreen"
  local previous = _G[KEY]
  if previous then previous.stop() end

  local state = {token = token, stopped = false, subscriptions = {}}
  _G[KEY] = state

  local function reconcile()
    if state.stopped then return end
    local w = hl.get_active_window()
    local remote = w and w.mapped and w.class == "rustdesk"
      and w.title:find("Remote Desktop", 1, true) ~= nil
      and (w.fullscreen & 2) ~= 0
    local current = hl.get_current_submap()
    if remote and (current == "" or current == "reset") then
      hl.dispatch(hl.dsp.submap(SUBMAP))
    elseif not remote and current == SUBMAP then
      hl.dispatch(hl.dsp.submap("reset"))
    end
  end

  function state.stop()
    if state.stopped then return end
    state.stopped = true
    if state.pending then state.pending:set_enabled(false) end
    for _, subscription in ipairs(state.subscriptions) do subscription:remove() end
    -- The exit binding is left in place. In Hyprland 0.56.2, removing a
    -- submap binding by its handle also removes the global binding on the
    -- same keys, which would take away the normal Super+F. The binding only
    -- exists inside the submap, and that is never entered once stopped.
    if hl.get_current_submap() == SUBMAP then
      hl.dispatch(hl.dsp.submap("reset"))
    end
    if _G[KEY] == state then _G[KEY] = nil end
  end

  -- An expired one-shot timer cannot be rearmed in Hyprland 0.56.2.
  local function schedule()
    if state.stopped then return end
    if state.pending then state.pending:set_enabled(false) end
    state.pending = hl.timer(reconcile, {timeout = 10, type = "oneshot"})
  end

  local ok, err = pcall(function()
    -- Defined once per Hyprland config load, since it is no longer removed
    -- on stop. A reload discards this flag together with every binding.
    if not _G[KEY .. "_bound"] then
      hl.define_submap(SUBMAP, function()
        hl.bind("SUPER + F",
          hl.dsp.window.fullscreen({mode = "fullscreen"}),
          {description = "Exit RustDesk fullscreen and restore local shortcuts"})
      end)
      _G[KEY .. "_bound"] = true
    end
    for _, event in ipairs({"window.active", "window.fullscreen", "window.close",
      "window.title", "window.class", "workspace.active"}) do
      table.insert(state.subscriptions, hl.on(event, schedule))
    end
    schedule()
  end)
  if not ok then state.stop(); error(err) end
end
