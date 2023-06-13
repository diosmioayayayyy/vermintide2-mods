local mod = get_mod("TwitchRedeems")
mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")

SettingsRedeems = class(SettingsRedeems)

SettingsRedeems.init = function (self)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = "Redeem Settings"
    self.imgui_window.key = self

    self:load_settings()
end

SettingsRedeems.save_settings = function (self)
    mod:set(mod.SETTING_ID_REDEEM_GLOBAL_COOLDOWN, self.global_cooldown)
    mod:set(mod.SETTING_ID_REDEEM_GLOBAL_COOLDOWN_DURATION, self.global_cooldown_duration)
    mod:set(mod.SETTING_ID_REDEEM_USER_COOLDOWN, self.user_cooldown)
    mod:set(mod.SETTING_ID_REDEEM_USER_COOLDOWN_DURATION, self.user_cooldown_duration)
end

SettingsRedeems.load_settings = function (self)
    self.global_cooldown = mod:get(mod.SETTING_ID_REDEEM_GLOBAL_COOLDOWN) or false
    self.global_cooldown_duration = mod:get(mod.SETTING_ID_REDEEM_GLOBAL_COOLDOWN_DURATION) or 5
    self.user_cooldown = mod:get(mod.SETTING_ID_REDEEM_USER_COOLDOWN) or false
    self.user_cooldown_duration = mod:get(mod.SETTING_ID_REDEEM_USER_COOLDOWN_DURATION) or 5
end

SettingsRedeems.toggle_gui_window = function (self)
    self.imgui_window.show_window = not self.imgui_window.show_window
end

SettingsRedeems.render_ui = function (self)
    local window_open = self.imgui_window:begin_window()
    if window_open then
        self.global_cooldown = Imgui.checkbox("Global Cooldown", self.global_cooldown)
        self.global_cooldown_duration = Imgui.input_int("Global Cooldown Duration", self.global_cooldown_duration)
        self.user_cooldown = Imgui.checkbox("User Cooldown", self.user_cooldown)
        self.user_cooldown_duration = Imgui.input_int("User Cooldown Duration", self.user_cooldown_duration)

        if Imgui.button("Save##" .. tostring(self)) then
            self:save_settings()
        end

        Imgui.same_line()

        if Imgui.button("Load##" .. tostring(self)) then
            self:load_settings()
        end

        self.imgui_window:end_window()
    end
    return window_open
end