local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemUnit")

if not INCLUDE_GUARDS.REDEEM_HORDE then
  INCLUDE_GUARDS.REDEEM_HORDE = true

  RedeemHorde = class(RedeemHorde)

  RedeemHorde.init = function(self, other)
    self.data = {
      name = "New Horde",
      units = {},
      spawn_type = SpawnType.HORDE,
      spawn_pos = SpawnPosition.RANDOM,
    }

    if other then
      for key, value in pairs(other) do
        self.data[key] = other[key]
      end
    end

    -- Gui variables.
    self.selected_unit = nil
  end

  RedeemHorde.render_ui = function(self)
    local redeem_unit_to_delete = nil

    for key, redeem_unit in pairs(self.data.units) do
      if Imgui.button(redeem_unit.name .. "##" .. key) then
        mod.selected_unit = key
      end

      Imgui.same_line()
      if Imgui.button("[x]##" .. key) then
        redeem_unit_to_delete = key
      end
    end

    -- Delete horde.
    if redeem_unit_to_delete then
      table.remove(self.data.units, redeem_unit_to_delete)
    end
  end
end
