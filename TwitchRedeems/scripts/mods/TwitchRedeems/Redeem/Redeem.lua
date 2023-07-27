local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/RedeemFunctions")
mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemEvent")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemHorde")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemMutator")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemUnit")

if not INCLUDE_GUARDS.REDEEM then
  INCLUDE_GUARDS.REDEEM = true

  -- Lua imgui
  -- https://github.dev/Aussiemon/Vermintide-2-Source-Code/blob/f972faa439fa02ff3e8ac3da449ee3ccf0bde43a/scripts/imgui/imgui.lua#L434

  Redeem = class(Redeem)

  Redeem.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      key                  = "",
      name                 = "New Redeem",
      desc                 = "",
      user_input           = false,
      cost                 = 1,
      background_color     = { 1, 1, 1 },
      skip_queue_timer     = false,
      override_queue_timer = false,
      queue_timer_duration = 5,
      hordes               = {},
      mutators             = {},
      buffs                = {},
      events               = {},
    }

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "hordes" then
          for key, raw_horde in pairs(value) do
            local horde = RedeemHorde:new(raw_horde)
            self.data.hordes[key] = horde
          end
        elseif key == "mutators" then
          for key, raw_mutator in pairs(value) do
            local mutator = RedeemMutator:new(raw_mutator)
            self.data.mutators[key] = mutator
          end
        elseif key == "buffs" then
          for key, raw_buff in pairs(value) do
            local buff = RedeemBuff:new(raw_buff)
            self.data.buffs[key] = buff
          end
        elseif key == "events" then
          for key, raw_event in pairs(value) do
            local event = RedeemEvent:new(raw_event)
            self.data.events[key] = event
          end
        else
          self.data[key] = other[key]
        end
      end
    end

    -- Gui variables.
    self.selected_horde = nil
    self.selected_mutator = nil
    self.selected_buff = nil
    self.selected_event = nil
  end

  Redeem.serialize = function(self)
    local data = {}
    data.key = self.data.key
    data.name = self.data.name
    data.desc = self.data.desc
    data.user_input = self.data.user_input
    data.cost = self.data.cost
    data.background_color = self.data.background_color
    data.skip_queue_timer = self.data.skip_queue_timer
    data.override_queue_timer = self.data.override_queue_timer
    data.queue_timer_duration = self.data.queue_timer_duration
    data.hordes = {}
    for key, horde in pairs(self.data.hordes) do
      data.hordes[key] = horde:serialize()
    end
    data.mutators = {}
    for key, mutator in pairs(self.data.mutators) do
      data.mutators[key] = mutator:serialize()
    end
    data.buffs = {}
    for key, buff in pairs(self.data.buffs) do
      data.buffs[key] = buff:serialize()
    end
    data.events = {}
    for key, event in pairs(self.data.events) do
      data.events[key] = event:serialize()
    end
    return data
  end

  Redeem.num_hordes = function(self)
    return table.size(self.hordes)
  end

  Redeem.has_hordes = function(self)
    return self:num_hordes() > 0
  end

  Redeem.insert_horde = function(self, horde)
    table.insert(self.hordes, horde)
  end

  Redeem.new_horde = function(self)
    local horde = RedeemHorde:new()
    table.insert(self.data.hordes, horde)
    return horde
  end

  Redeem.new_mutator = function(self)
    local mutator = RedeemMutator:new()
    table.insert(self.data.mutators, mutator)
    return mutator
  end

  Redeem.new_buff = function(self)
    local buff = RedeemBuff:new()
    table.insert(self.data.buffs, buff)
    return buff
  end

  Redeem.new_event = function(self)
    local event = RedeemEvent:new()
    table.insert(self.data.events, event)
    return event
  end

  Redeem.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  Redeem.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      -- ----------------------------------------------------
      self.data.name = Imgui.input_text("Name##" .. tostring(self), self.data.name)

      Imgui.same_line()
      if Imgui.button("Redeem##" .. tostring(self)) then
        local redemption = {
          title = self.data.name,
          user = "TestRedeem",
          user_input = "[TEST]"
        }
        mod.redeem_queue:push(redemption)
      end

      -- ----------------------------------------------------
      Imgui.separator()
      Imgui.text("Twitch Settings")

      self.data.user_input = Imgui.checkbox("User Input##" .. tostring(self), self.data.user_input)
      self.data.cost = Imgui.input_int("Cost##" .. tostring(self), self.data.cost)
      self.data.background_color[1], self.data.background_color[2], self.data.background_color[3] = Imgui.color_edit_3(
        "Color##" .. tostring(self), self.data.background_color[1], self.data.background_color[2],
        self.data.background_color[3])

      Imgui.separator()
      Imgui.text("Queue Settings")

      self.data.skip_queue_timer = Imgui.checkbox("Skip Queue Timer##" .. tostring(self), self.data.skip_queue_timer)

      if not self.data.skip_queue_timer then
        Imgui.same_line()
        self.data.override_queue_timer = Imgui.checkbox("Override Queue Timer##" .. tostring(self),
          self.data.override_queue_timer)

        if self.data.override_queue_timer then
          self.data.queue_timer_duration = Imgui.input_int("Duration##global" .. tostring(self),
            self.data.queue_timer_duration)
          self.data.queue_timer_duration = math.max(self.data.queue_timer_duration, 0)
        end
      end

      -- ----------------------------------------------------
      Imgui.separator()
      Imgui.text("Hordes")
      Imgui.same_line()
      if Imgui.button("+##Horde" .. tostring(self)) then
        self:new_horde()
      end

      local horde_to_delete = nil
      for key, horde in pairs(self.data.hordes) do
        if Imgui.button(horde.data.name .. "##" .. key) then
          horde:toggle_gui_window()
          mod.selected_horde = key
        end

        Imgui.same_line()
        if Imgui.button("[x]##Horde" .. key) then
          horde_to_delete = key
        end
      end

      -- ----------------------------------------------------
      Imgui.separator()
      Imgui.text("Mutators")
      Imgui.same_line()
      if Imgui.button("+##Mutator" .. tostring(self)) then
        self:new_mutator()
      end

      local mutator_to_delete = nil
      for key, mutator in pairs(self.data.mutators) do
        if Imgui.button(mutator.data.name .. "##" .. key) then
          mutator:toggle_gui_window()
          mod.selected_mutator = key
        end

        Imgui.same_line()
        if Imgui.button("[x]##Mutator" .. key) then
          mutator_to_delete = key
        end
      end

      -- ----------------------------------------------------
      Imgui.separator()
      Imgui.text("Buffs")
      Imgui.same_line()
      if Imgui.button("+##Buff" .. tostring(self)) then
        self:new_buff()
      end

      local buff_to_delete = nil
      for key, buff in pairs(self.data.buffs) do
        if Imgui.button(buff.data.name .. "##" .. key) then
          buff:toggle_gui_window()
          mod.selected_buff = key
        end

        Imgui.same_line()
        if Imgui.button("[x]##Buff" .. key) then
          buff_to_delete = key
        end
      end

      -- ----------------------------------------------------
      Imgui.separator() 
      Imgui.text("Events")
      Imgui.same_line()
      if Imgui.button("+##Event" .. tostring(self)) then
        self:new_event()
      end

      local event_to_delete = nil
      for key, event in pairs(self.data.events) do
        if Imgui.button(event.data.name .. "##" .. key) then
          event:toggle_gui_window()
          mod.selected_event = key
        end

        Imgui.same_line()
        if Imgui.button("[x]##Event" .. key) then
          event_to_delete = key
        end
      end

      -- ----------------------------------------------------

      -- Delete horde.
      if horde_to_delete then
        table.remove(self.data.hordes, horde_to_delete)
      end

      -- Delete mutator.
      if mutator_to_delete then
        table.remove(self.data.mutators, mutator_to_delete)
      end

      -- Delete buff.
      if buff_to_delete then
        table.remove(self.data.buffs, buff_to_delete)
      end

      -- Delete event.
      if event_to_delete then
        table.remove(self.data.events, event_to_delete)
      end

      self.imgui_window:end_window()
    end

    for _, horde in ipairs(self.data.hordes) do
      if horde:render_ui() then window_open = true end
    end

    for _, mutator in ipairs(self.data.mutators) do
      if mutator:render_ui() then window_open = true end
    end

    for _, buff in ipairs(self.data.buffs) do
      if buff:render_ui() then window_open = true end
    end

    for _, event in ipairs(self.data.events) do
      if event:render_ui() then window_open = true end
    end

    return window_open
  end

  Redeem.prepare = function(self)
    for _, horde in ipairs(self.data.hordes) do
      horde:prepare()
    end

    for _, mutator in ipairs(self.data.mutators) do
      mutator:prepare()
    end

    for _, buff in ipairs(self.data.buffs) do
      buff:prepare()
    end

    for _, event in ipairs(self.data.events) do
      event:prepare()
    end
  end

  Redeem.redeem = function(self)
    for _, horde in ipairs(self.data.hordes) do
      horde:spawn()
    end

    for _, mutator in ipairs(self.data.mutators) do
      mutator:apply()
    end

    for _, buff in ipairs(self.data.buffs) do
      buff:apply()
    end

    for _, event in ipairs(self.data.events) do
      event:apply()
    end
  end
end
