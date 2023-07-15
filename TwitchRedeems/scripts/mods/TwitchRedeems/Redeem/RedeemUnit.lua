local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")
mod:dofile("scripts/mods/TwitchRedeems/Utils/Amount")

if not INCLUDE_GUARDS.REDEEM_UNIT then
  INCLUDE_GUARDS.REDEEM_UNIT = true

  local BUFF_SYSTEM = Managers.state.entity:system("buff_system")

  local OPTIONAL_DATA = {}
  OPTIONAL_DATA.spawned_func = function(unit, breed, optional_data)
    BUFF_SYSTEM:add_buff(unit, "twitch_redeem_buff_eye_glow", unit)
  end

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
      max_health_modifier = Amount:new(),
      taggable = false,
    }

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "amount" then
          self.data.amount = Amount:new(value)
        elseif key == "max_health_modifier" then
          self.data.max_health_modifier = Amount:new(value)
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
    data.max_health_modifier = self.data.max_health_modifier:serialize()
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

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemUnit.create_spawn_list_entry = function(self)
    local entry = {}
    entry.breed = Breeds[self.data.breed_name]
    entry.amount = self.data.amount
    entry.max_health_modifier = self.data.max_health_modifier
    entry.optional_data = table.clone(OPTIONAL_DATA)

    if self.taggable then
      add_spawn_func(entry.optional_data, function (unit) BUFF_SYSTEM:add_buff(unit, "twitch_redeem_buff_pingable", unit) end)
    end

    local side = Managers.state.side:get_side_from_name("dark_pact")
    entry.optional_data.side_id = side.side_id

    return entry
  end
end
