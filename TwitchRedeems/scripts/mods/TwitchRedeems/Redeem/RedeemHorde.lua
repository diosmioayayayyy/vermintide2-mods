local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemUnit")

RedeemHorde = class(RedeemHorde)

RedeemHorde.init = function (self)
    self.name = "New Horde"
    self.units = {}
    self.spawn_type = SpawnType.HORDE
    self.spawn_pos = SpawnPosition.RANDOM

    -- Gui variables.
    self.selected_unit = nil
end

RedeemHorde.render_ui = function (self)
    local redeem_unit_to_delete = nil
    for key, redeem_unit in pairs(self.units) do
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
        table.remove(self.units, redeem_unit_to_delete)
    end
end