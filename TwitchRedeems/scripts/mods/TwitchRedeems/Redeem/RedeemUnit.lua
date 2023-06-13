local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")

RedeemUnit = class(RedeemUnit)

RedeemUnit.init = function (self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
        name = "New Unit",
        desc = "",
        breed_name = "skaven_clan_rat",
        breed_index = 1,
    }

    if other then
        for key, value in pairs(other) do
            self.data[key] = other[key]
        end
    end
end

RedeemConfiguration.render_ui = function (self)
    local window_open = self.imgui_window:begin_window() -- TODO code dedup
    if window_open then

        self.imgui_window:end_window()
    end
    return window_open
end