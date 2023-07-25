local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemUnit")

if not INCLUDE_GUARDS.REDEEM_MUTATOR then
  INCLUDE_GUARDS.REDEEM_MUTATOR = true

  RedeemMutator = class(RedeemMutator)

  RedeemMutator.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      mutator_index = 1,
      name = GuiDropdownMutators[MutatorType.DARKNESS],
      duration = Amount:new(nil, 30, 30),
    }

    self.mutator = nil
    self.redeem = {}

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "duration" then
          self.data.duration = Amount:new(value)
        elseif key == "mutator" then
          self.mutator = create_twitch_redeems_mutator(MutatorTypeLookup[self.data.mutator_index], value)
        else
          self.data[key] = other[key]
        end
      end
    end
  end

  RedeemMutator.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  RedeemMutator.serialize = function(self)
    local data = {}
    data.name = self.data.name
    data.mutator_index = self.data.mutator_index
    data.duration = self.data.duration:serialize()
    if self.mutator then
      data.mutator = self.mutator:serialize()
    end
    return data
  end

  RedeemMutator.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.mutator_index = Imgui.combo("Mutator##" .. tostring(self), self.data.mutator_index, GuiDropdownMutators, 10)
      self.data.name = GuiDropdownMutators[self.data.mutator_index]
      self.data.duration:render_ui("Duration")

      if self.mutator == nil or MutatorTypeLookup[self.data.mutator_index] ~= self.mutator.mutator_type then
        self.mutator = create_twitch_redeems_mutator(MutatorTypeLookup[self.data.mutator_index], nil)
      end

      if self.mutator ~= nil then
        self.mutator:render_ui()
      end

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemMutator.prepare = function(self)
  end

  RedeemMutator.apply = function(self)
    local mutator_handler = Managers.state.game_mode._mutator_handler
    local mutator_name = MutatorName[self.data.mutator_index]
    local duration = self.data.duration:get()

    if self.mutator == nil then
      -- Vanilla mutators.
      if not mutator_handler:has_activated_mutator(mutator_name) then
        mutator_handler:initialize_mutators({
          mutator_name
        })
        mutator_handler:activate_mutator(mutator_name, duration)
      else
        mod:info("Mutator already active '" .. mutator_name .. "'")
      end
    else
      -- OneShot mutators.
      if not mutator_handler:has_activated_mutator(mutator_name) then
        local oneshot_settings = {}
        oneshot_settings.uid = tostring(self)
        oneshot_settings.data = table.clone(self.mutator.settings)
        mutator_handler:activate_mutator_one_shot(mutator_name, oneshot_settings, duration)
      else
        mod:info("Mutator already active '" .. mutator_name .. "'")
      end
    end
  end

  -- TODO display active mutators

  -- TODO add deactivate all mutators redeem
end
