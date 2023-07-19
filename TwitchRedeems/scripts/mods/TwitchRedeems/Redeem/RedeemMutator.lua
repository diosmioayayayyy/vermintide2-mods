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
      mutator_type = MutatorType.DARKNESS,
      name = GuiDropdownMutators[MutatorType.DARKNESS],
      duration = Amount:new(nil, 30, 30),
    }

    self.redeem = {}

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "duration" then
          self.data.duration = Amount:new(value)
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
    data.mutator_type = self.data.mutator_type
    data.duration = self.data.duration:serialize()
    return data
  end

  RedeemMutator.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.mutator_type = Imgui.combo("Breed", self.data.mutator_type, GuiDropdownMutators, 10)
      self.data.name = GuiDropdownMutators[self.data.mutator_type]
      self.data.duration:render_ui("Duration")

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemMutator.prepare = function(self)
  end

  RedeemMutator.apply = function(self)
    local mutator_handler = Managers.state.game_mode._mutator_handler
    local mutator_name = MutatorName[self.data.mutator_type]
    local duration = self.data.duration:get()

    if not mutator_handler:has_activated_mutator(mutator_name) then
      mutator_handler:initialize_mutators({
        mutator_name
      })
      mutator_handler:activate_mutator(mutator_name, duration)
    else
      mod:info("Mutator already active '" .. mutator_name .. "'")
    end
  end
  
  -- TODO display active mutators
 
  -- TODO add deactivate all mutators redeem
end
