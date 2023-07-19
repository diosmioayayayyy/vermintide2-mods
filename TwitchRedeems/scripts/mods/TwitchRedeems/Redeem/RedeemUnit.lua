local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")
mod:dofile("scripts/mods/TwitchRedeems/Utils/Amount")

if not INCLUDE_GUARDS.REDEEM_UNIT then
  INCLUDE_GUARDS.REDEEM_UNIT = true

  RedeemUnit = class(RedeemUnit)

  RedeemUnit.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      name = "New Unit",
      desc = "",
      breed_name = "skaven_clan_rat",
      breed_index = 1,
      amount = Amount:new(),
      max_health_modifier = 1.0,
      taggable = false,
    }

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "amount" then
          self.data.amount = Amount:new(value)
        else
          self.data[key] = other[key]
        end
      end
    end
  end

  RedeemUnit.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  RedeemUnit.serialize = function(self)
    local data = {}
    data.name = self.data.name
    data.desc = self.data.desc
    data.breed_name = self.data.breed_name
    data.breed_index = self.data.breed_index
    data.amount = self.data.amount:serialize()
    data.max_health_modifier = self.data.max_health_modifier
    data.taggable = self.taggable
    return data
  end

  RedeemUnit.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.name = Imgui.input_text("Name##" .. tostring(self), self.data.name)

      self.data.breed_index = Imgui.combo("Breed", self.data.breed_index, GuiDropdownBaseBreedsLocalized, 10) -- TODO add custom breeds
      self.data.breed_name = GuiDropdownBaseBreeds[self.data.breed_index]

      self.data.amount:render_ui()

      self.data.max_health_modifier = Imgui.input_float("Max Health Modifier", self.data.max_health_modifier, "%.2f")

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemUnit.create_spawn_list_entry = function(self)
    local buff_system = Managers.state.entity:system("buff_system")

    local entry = {}
    entry.breed = table.clone(Breeds[self.data.breed_name])
    entry.breed.is_twitch_redeem = true
    entry.amount = self.data.amount
    entry.max_health_modifier = self.data.max_health_modifier
    entry.optional_data = {}
    entry.optional_data.max_health_modifier = self.data.max_health_modifier

    -- Apply purple eyes.
    entry.optional_data.spawned_func = function(unit, breed, optional_data)
      buff_system:add_buff(unit, "twitch_redeem_buff_eye_glow", unit)
    end

    if self.taggable then
      add_spawn_func(entry.optional_data, function (unit) buff_system:add_buff(unit, "twitch_redeem_buff_pingable", unit) end)
    end

    local side = Managers.state.side:get_side_from_name("dark_pact")
    entry.optional_data.side_id = side.side_id

    return entry
  end
end
