local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")

if not INCLUDE_GUARDS.REDEEM_BUFF then
  INCLUDE_GUARDS.REDEEM_BUFF = true

  RedeemBuff = class(RedeemBuff)

  RedeemBuff.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      buff_index = 1,
      name = GuiDropdownBuffs[BuffType.SPEED],
      duration = Amount:new(nil, 30, 30),
    }

    self.buff = nil
    self.redeem = {}

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "duration" then
          self.data.duration = Amount:new(value)
        elseif key == "buff" then
          self.buff = create_twitch_redeems_buff(BuffTypeLookup[self.data.buff_index], value)
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
    data.buff_index = self.data.buff_index
    data.duration = self.data.duration:serialize()
    if self.buff then
      data.buff = self.buff:serialize()
    end
    return data
  end

  RedeemBuff.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.buff_index = Imgui.combo("Buff##" .. tostring(self), self.data.buff_index, GuiDropdownBuffs, 10)
      self.data.name = GuiDropdownBuffs[self.data.buff_index]
      self.data.duration:render_ui("Duration")

      if self.buff == nil or BuffTypeLookup[self.data.buff_index] ~= self.buff.buff_type then
        self.buff = create_twitch_redeems_buff(BuffTypeLookup[self.data.buff_index], nil)
      end

      if self.buff ~= nil then
        self.buff:render_ui()
      end

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemBuff.prepare = function(self)
  end

  RedeemBuff.apply = function(self)
    local buff_system = Managers.state.entity:system("buff_system")
    local buff_name = BuffName[self.data.buff_index]
    local duration = self.data.duration:get()

    if self.buff == nil then
      -- Vanilla buffs.
      -- if not buff_handler:has_activated_buff(buff_name) then
      --   buff_handler:initialize_buffs({
      --     buff_name
      --   })
      --   buff_handler:activate_buff(buff_name, duration)
      -- else
      --   mod:info("buff already active '" .. buff_name .. "'")
      -- end
    else
      -- OneShot buffs.
      -- if not buff_handler:has_activated_buff(buff_name) then
      --   local oneshot_settings = {}
      --   oneshot_settings.uid = tostring(self)
      --   oneshot_settings.data = table.clone(self.buff.settings)
      --   buff_handler:activate_buff_one_shot(buff_name, oneshot_settings, duration)
      -- else
      --   mod:info("buff already active '" .. buff_name .. "'")
      -- end
    end
  end
end
