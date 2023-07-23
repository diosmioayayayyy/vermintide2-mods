local mod = get_mod("TwitchRedeems")
mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeemsHTTPProxyClient")

RedeemConfiguration = class(RedeemConfiguration)

RedeemConfiguration.init = function(self)
  self.imgui_window = ImguiWindow:new()
  self.imgui_window.title = "Redeem Configuration"
  self.imgui_window.key = self
end

RedeemConfiguration.is_window_open = function(self)
  return self.imgui_window.show_window
end

RedeemConfiguration.save_settings = function(self)
  -- TODO save redeems here
end

RedeemConfiguration.load_settings = function(self)
  mod.load_twitch_redeems_from_file()
end

RedeemConfiguration.toggle_gui_window = function(self)
  self.imgui_window.show_window = not self.imgui_window.show_window
end

RedeemConfiguration.render_ui = function(self)
  local window_open = self.imgui_window:begin_window()   -- TODO code dedup
  if window_open then
    -- TODO WT clean up cursor and mouse code
    local w, h = Application.resolution()
    local mouse_position = Vector3(0, h, 0) -
    Vector3.multiply_elements(Mouse.axis(Mouse.axis_id("cursor")), Vector3(-1, 1, 0))

    local app_window_x, app_window_y = Window.position()

    -- if Imgui.button("Add Redeem Config") then
    --   Imgui.open_popup("register_point_popup")
    -- end

    -- Imgui.same_line()

    -- if Imgui.button("Delete Redeem Config") then
    --   Imgui.open_popup("register_point_popup")
    -- end

    Imgui.text("General")

    if Imgui.button("TEST") then
      -- TODO
      -- local PhysicsWorld = stingray.PhysicsWorld
      -- local world = Managers.world:world("level_world")
      -- local physics_world = World.get_data(world, "physics_world")
      -- PhysicsWorld.set_gravity(physics_world, Vector3(0,0,5))
      local mutator_handler = Managers.state.game_mode._mutator_handler
      mod:echo("DEACTIVATING MUTATORS")
      mod:dump(mutator_handler._mutators, "mutator_handler._mutators", 1)
      mutator_handler:deactivate_mutators(false)
      mutator_handler._mutators = {}
      --self._mutators still active
      --mod.spawn_horde = true
    end

    Imgui.separator()

    if Imgui.button("     Twitch     ") then
      mod.settings_twitch:toggle_gui_window()
    end

    Imgui.same_line()

    if Imgui.button("    Settings    ") then
      mod.settings_redeems:toggle_gui_window()
    end

    if Imgui.button("  Breed Editor  ") then
      mod.breed_editor:toggle_gui_window()
    end

    Imgui.separator()

    Imgui.text("Redeems")
    Imgui.separator()

    -- Create new redeem.
    if Imgui.button("   New Redeem   ") then
      local new_redeem = Redeem:new()
      table.insert(mod.redeems, new_redeem)
    end

    Imgui.same_line()

    if Imgui.button("  Clear Redeems ") then
      Imgui.open_popup("popup_delete_redeems")
    end

    if Imgui.button("  Save Redeems  ") then
      Imgui.open_popup("popup_save_redeems")
    end

    Imgui.same_line()

    if Imgui.button("  Load Redeems  ") then
      Imgui.open_popup("popup_load_redeems")
    end

    Imgui.separator()

    -- TODO do we keep that?
    -- if Imgui.button("Sort by name") then
    --     table.sort(mod.redeems, function(a, b) return a.data.name < b.data.name end)
    -- end

    -- Render redeem list.
    --Imgui.text("")

    local item_cursor_table = {}
    for key, redeem in pairs(mod.redeems) do
      local _, y = Imgui.get_cursor_screen_pos()
      local cursor_y = y - app_window_y

      table.insert(item_cursor_table, cursor_y)
      local test = string.format("%-29s", redeem.data.name)
      if Imgui.button(test .. "##" .. key) then
        redeem:toggle_gui_window()
      end

      if (Imgui.is_item_hovered()) then
        Imgui.same_line()
        if (not mod.drag_key and Mouse.button(Mouse.button_index("left")) == 1) then
          mod.drag_key = key
          Imgui.same_line()
        end
      end

      Imgui.same_line()

      if Imgui.button("[x]##" .. key) then
        Imgui.open_popup("popup_delete_redeem")
        mod.redeem_key_to_delete = key         -- TODO not mod.
      end
    end

    Imgui.separator()

    Imgui.text("Twitch")
    Imgui.separator()
    -- if Imgui.button("Pool Redeem") then
    --     mod.http_proxy_client:request_next_reedem()
    -- end

    -- if Imgui.button("Map Start") then
    --     mod.http_proxy_client:request_map_start()
    -- end

    -- if Imgui.button("Map End") then
    --     mod.http_proxy_client:request_map_end()
    -- end

    if Imgui.button(" Update Redeems ") then
      mod.setup_twitch_redeems()
    end

    Imgui.same_line()
    if Imgui.button(" Delete Redeems ") then
      mod.http_proxy_client:request_delete_redeems()
    end

    -- if Imgui.button("Enable Redeems") then
    --     mod.http_proxy_client:request_update_redeems({ is_enabled=true })
    -- end
    -- Imgui.same_line()
    -- if Imgui.button("Disable Redeems") then
    --     mod.http_proxy_client:request_update_redeems({ is_enabled=false })
    -- end
    -- if Imgui.button("Pause Redeems") then
    --     mod.http_proxy_client:request_update_redeems({ is_paused=true })
    -- end
    -- Imgui.same_line()
    -- if Imgui.button("Unpause Redeems") then
    --     mod.http_proxy_client:request_update_redeems({ is_paused=false })
    -- end

    Imgui.separator()

    -- Drag redeem.
    -- TODO this stuff should be a reusable class...
    if mod.drag_key then
      for i = 1, #item_cursor_table do
        local min = item_cursor_table[i]
        local max = item_cursor_table[i + 1]
        if mouse_position.y > min and (max == nil or mouse_position.y < max) then
          local swap = mod.redeems[i]
          mod.redeems[i] = mod.redeems[mod.drag_key]
          mod.redeems[mod.drag_key] = swap
          mod.drag_key = i
          break
        end
      end
    end

    -- Reset drag key when button is released.
    if (Mouse.button(Mouse.button_index("left")) == 0) then
      mod.drag_key = nil
    end

    -- Redeem delete popup.
    if Imgui.begin_popup("popup_delete_redeem") then
      Imgui.text("Do you really want to delete the redeem '" .. mod.redeems[mod.redeem_key_to_delete].data.name .. "'?")

      if Imgui.button("Delete") then
        Imgui.close_current_popup()
        table.remove(mod.redeems, mod.redeem_key_to_delete)
      end

      Imgui.same_line()
      if Imgui.button("Cancel") then
        Imgui.close_current_popup()
      end

      if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) then
        Imgui.close_current_popup()
      end

      Imgui.end_popup()
    end

    -- Popups.
    if Imgui.begin_popup("popup_delete_redeems") then
      Imgui.text("Do you really want to delete all redeems?")

      if Imgui.button("Delete") then
        Imgui.close_current_popup()
        mod.redeems = {}
      end

      Imgui.same_line()
      if Imgui.button("Cancel") then
        Imgui.close_current_popup()
      end

      if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) then
        Imgui.close_current_popup()
      end
      Imgui.end_popup()
    end

    if Imgui.begin_popup("popup_save_redeems") then
      Imgui.text("Do you really want to save the redeems?")

      if Imgui.button("Save") then
        Imgui.close_current_popup()
        mod.store_twitch_redeems_to_file()
      end

      Imgui.same_line()
      if Imgui.button("Cancel") then
        Imgui.close_current_popup()
      end

      if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) then
        Imgui.close_current_popup()
      end
      Imgui.end_popup()
    end

    if Imgui.begin_popup("popup_load_redeems") then
      Imgui.text("Do you really want to load the redeems?")

      if Imgui.button("Load") then
        Imgui.close_current_popup()
        mod.load_twitch_redeems_from_file()
      end

      Imgui.same_line()
      if Imgui.button("Cancel") then
        Imgui.close_current_popup()
      end

      if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) then
        Imgui.close_current_popup()
      end
      Imgui.end_popup()
    end

    self.imgui_window:end_window()
  end
  return window_open
end
