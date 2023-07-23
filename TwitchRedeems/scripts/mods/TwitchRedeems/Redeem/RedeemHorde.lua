local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemUnit")

if not INCLUDE_GUARDS.REDEEM_HORDE then
  INCLUDE_GUARDS.REDEEM_HORDE = true

  RedeemHorde = class(RedeemHorde)

  RedeemHorde.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      name = "New Horde",
      units = {},
      spawn_type = SpawnType.HORDE,
      spawn_pos = SpawnPosition.RANDOM,
    }

    self.redeem = {}

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "units" then
          for key, raw_unit in pairs(value) do
            self.data.units[key] = RedeemUnit:new(raw_unit)
          end
        else
          self.data[key] = other[key]
        end
      end
    end

    -- Gui variables.
    self.selected_unit = nil
  end

  RedeemHorde.serialize = function(self)
    local data = {}
    data.name = self.data.name
    data.spawn_type = self.data.spawn_type
    data.spawn_pos = self.data.spawn_pos
    data.units = {}
    for key, unit in pairs(self.data.units) do
      data.units[key] = unit:serialize()
    end
    return data
  end

  RedeemHorde.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  RedeemHorde.new_unit = function(self)
    local unit = RedeemUnit:new()
    table.insert(self.data.units, unit)
    return unit
  end

  RedeemHorde.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.name       = Imgui.input_text("Name##" .. tostring(self), self.data.name)
      self.data.spawn_type = Imgui.combo("Spawn Type", self.data.spawn_type, GuiDropdownSpawnType, 3)
      self.data.spawn_pos  = Imgui.combo("Spawn Position", self.data.spawn_pos, GuiDropdownSpawnPosition, 3)

      Imgui.separator()
      Imgui.text("Units")
      Imgui.same_line()
      if Imgui.button("+##" .. tostring(self)) then
        self:new_unit()
      end

      local unit_to_delete = nil
      for key, unit in pairs(self.data.units) do
        if Imgui.button(unit.data.name .. "##" .. key) then
          unit:toggle_gui_window()
          mod.selected_unit = key
        end

        Imgui.same_line()
        if Imgui.button("[x]##" .. key) then
          unit_to_delete = key
        end
      end

      -- Delete horde.
      if unit_to_delete then
        table.remove(self.data.units, unit_to_delete)
      end

      self.imgui_window:end_window()
    end

    for _, unit in ipairs(self.data.units) do
      if unit:render_ui() then window_open = true end
    end

    return window_open
  end

  RedeemHorde.prepare = function(self)
    self.redeem = {}
    self.redeem.side_id = Managers.state.side:get_side_from_name("dark_pact").side_id
    self.redeem.spawn_type = self.data.spawn_type
    self.redeem.spawn_pos  = self.data.spawn_pos
    self.redeem.spawn_list = {}

    for _, unit in pairs(self.data.units) do
      local spawn_list_entry = unit:create_spawn_list_entry()
      table.insert(self.redeem.spawn_list, spawn_list_entry)
    end
  end

  RedeemHorde.spawn = function(self)
    mod:info("Spawning Twitch Redeem horde '" .. self.data.name .. "'")
    if self.redeem.spawn_type == SpawnType.HIDDEN then
      spawn_redeem_hidden(self.redeem)
    elseif self.redeem.spawn_type == SpawnType.HORDE then
      spawn_custom_redeem_horde(self.redeem)
    elseif self.redeem.spawn_type == SpawnType.ONE then
      spawn_redeem_one(self.redeem)
    end
  end
end
