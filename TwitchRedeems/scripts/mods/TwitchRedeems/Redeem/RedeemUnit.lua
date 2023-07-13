local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
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
end
