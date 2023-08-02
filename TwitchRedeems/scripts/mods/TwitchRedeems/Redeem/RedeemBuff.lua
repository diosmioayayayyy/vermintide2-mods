local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")

-- see buff_templates.lua

if not INCLUDE_GUARDS.REDEEM_BUFF then
  INCLUDE_GUARDS.REDEEM_BUFF = true

  RedeemBuff = class(RedeemBuff)

  RedeemBuff.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      name = "New Buff",
      buff_index = 1,
      buff_name = GuiDropdownBuffs[BuffType.SPEED],
      apply_to_all = true,
    }

    self.buff_template = nil
    self.buff_id  = nil
    self.redeem = {}

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "buff_template" then
          self.buff_template = table.clone(value)
        else
          self.data[key] = other[key]
        end
      end
    end
  end

  RedeemBuff.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  RedeemBuff.serialize = function(self)
    local data = {}
    data.name = self.data.name
    data.buff_name = self.data.buff_name
    data.buff_index = self.data.buff_index
    data.apply_to_all = self.data.apply_to_all
    if self.buff_template then
      data.buff_template = table.clone(self.buff_template)
    end
    return data
  end

  RedeemBuff.render_ui = function(self)
    self.imgui_window.title = self.data.buff_name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.name = Imgui.input_text("Name##" .. tostring(self), self.data.name)
      local prev_buff_index = self.data.buff_index
      self.data.buff_index = Imgui.combo("Buff##" .. tostring(self), self.data.buff_index, GuiDropdownBuffs, 10)
      self.data.apply_to_all = Imgui.checkbox("Apply to all##" .. tostring(self), self.data.apply_to_all)
      self.data.buff_name = GuiDropdownBuffs[self.data.buff_index]

      if self.buff_template == nil or prev_buff_index ~= self.data.buff_index then
        self.buff_template = table.clone(BuffTemplates[BuffName[self.data.buff_index]])
        self.buff_id = nil
      end

      if self.buff_template ~= nil then
        for _, buff in ipairs(self.buff_template.buffs) do
          Imgui.text(string.format("Buff: '%s'", buff.name))
          for key, setting in pairs(buff) do
            if type(setting) == "number" then
              buff[key] = Imgui.input_float(key .. "##" .. tostring(buff), setting)
            end
          end
        end
      end

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemBuff.prepare = function(self)
  end

  RedeemBuff.apply = function(self, user_input)
    local buff_system = Managers.state.entity:system("buff_system")

    -- Create buff template.
    local buff_name = BuffName[self.data.buff_index]
    local oneshot_buff_template = table.clone(self.buff_template)

    if self.buff_id == nil then
      self.buff_id = buff_system:get_oneshot_buff_id()
    end

    local oneshot_buff_name = buff_system:add_oneshot_buff(buff_name, self.buff_id, oneshot_buff_template)

    -- Apply buff.
    if oneshot_buff_name ~= nil then
      mod:info("Applying buff '" .. oneshot_buff_name .. "'")
      local players = Managers.player:human_and_bot_players()

      if self.data.apply_to_all == true then
        -- Apply to all players.
        for _, player in pairs(players) do
          local unit = player.player_unit

          if Unit.alive(unit) then
            local server_controlled = false
            buff_system:add_buff(unit, oneshot_buff_name, unit, server_controlled)
          end
        end
      else
        local applied = false
        local lower_user_input = string.lower(user_input)

        -- Parse for player name.
        for _, player in pairs(players) do
          local player_name = player:name()
          local unit = player.player_unit

          if string.find(string.lower(player_name), lower_user_input) ~= nil then
            if Unit.alive(unit) then
              local server_controlled = false
              buff_system:add_buff(unit, oneshot_buff_name, unit, server_controlled)
              break
            end
            applied = true
          end
        end

        -- Apply to random player.
        if not applied then
          local random_player_index = math.random(1, table.size(players))

          local i = 0
          for _, player in pairs(players) do
            if i == random_player_index then
              local unit = player.player_unit
              if Unit.alive(unit) then
                local server_controlled = false
                buff_system:add_buff(unit, oneshot_buff_name, unit, server_controlled)
              end
              break
            end
            i = i + 1
          end
        end
      end
    end
  end
end


-- -----------------------------------------------
-- [Script Error]: scripts/network_lookup/network_lookup.lua:2359: [NetworkLookup.lua] Table buff_templates does not contain key: 2500
-- -----------------------------------------------