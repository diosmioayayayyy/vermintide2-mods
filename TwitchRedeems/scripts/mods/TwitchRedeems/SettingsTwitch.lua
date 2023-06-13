local mod = get_mod("TwitchRedeems")
mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")

local Managers = Managers

SettingsTwitch = class(SettingsTwitch)

SettingsTwitch.init = function (self)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = "Twitch Settings"
    self.imgui_window.key = self

    self:load_settings()
end

SettingsTwitch.save_settings = function (self)
    mod:set(mod.SETTING_ID_TWITCH_REDEEM_USER, self.bot_account)
    mod:set(mod.SETTING_ID_TWITCH_CHANNEL_NAME, self.channel_account)
    mod:set(mod.SETTING_ID_TWITCH_CUSTOM_VOTE_TIMES, self.custom_vote_times)
    mod:set(mod.SETTING_ID_TWITCH_INITIAL_VOTE_DOWNTIME, self.initial_vote_downtime)
    mod:set(mod.SETTING_ID_TWITCH_VOTE_DOWNTIME, self.time_between_votes)
    mod:set(mod.SETTING_ID_TWITCH_VOTE_TIME, self.vote_time)
end

SettingsTwitch.load_settings = function (self)
    self.bot_account      = mod:get(mod.SETTING_ID_TWITCH_REDEEM_USER)  or ""
    self.channel_account  = mod:get(mod.SETTING_ID_TWITCH_CHANNEL_NAME) or ""

    self.custom_vote_times      = mod:get(mod.SETTING_ID_TWITCH_CUSTOM_VOTE_TIMES) or false
    self.initial_vote_downtime  = mod:get(mod.SETTING_ID_TWITCH_INITIAL_VOTE_DOWNTIME) or TwitchSettings.initial_downtime
    self.time_between_votes     = mod:get(mod.SETTING_ID_TWITCH_VOTE_DOWNTIME)         or Application.user_setting("twitch_time_between_votes")
    self.vote_time              = mod:get(mod.SETTING_ID_TWITCH_VOTE_TIME)             or Application.user_setting("twitch_vote_time")
end

SettingsTwitch.toggle_gui_window = function (self)
    self.imgui_window.show_window = not self.imgui_window.show_window
end

SettingsTwitch.render_ui = function (self)
    local window_open = self.imgui_window:begin_window()
    if window_open then

        self.bot_account = Imgui.input_text("Bot Account", self.bot_account)
        self.channel_account = Imgui.input_text("Channel Account", self.channel_account)

        Imgui.separator()

        if self.channel_account == "" then
            Imgui.text("No twitch channel name specified!")
        elseif Managers.twitch:is_connecting() then
            Imgui.text("Connecting...")
        else
            if Managers.twitch:is_connected() then
                if Imgui.button("Disconnect") then
                    Managers.twitch:disconnect()
                end

                Imgui.same_line()

                if Managers.twitch:is_activated() or Managers.twitch._twitch_game_mode then
                    if Imgui.button("Disable Votes##" .. tostring(self)) then
                        Managers.twitch:deactivate_twitch_game_mode()
                    end
                else
                    if Imgui.button("Enable Votes##" .. tostring(self)) then
                        local game_mode_key = Managers.state.game_mode:game_mode_key()
                        if game_mode_key == "inn" then game_mode_key = "adventure" end
                        Managers.twitch:activate_twitch_game_mode(Managers.state.game_mode.network_event_delegate, game_mode_key)
                        mod:echo(game_mode_key)
                    end
                end
            else
                if Imgui.button("Connect") then
                    Managers.twitch:connect(self.channel_account, callback(mod, "cb_connection_error_callback"), callback(mod, "cb_connection_success_callback"))
                    mod:info("Connecting to Twitch Channel: " .. self.channel_account)
                end
            end
        end

        Imgui.separator()

        Imgui.text(string.format("Current Vote Timings: %d/%d/%d", TwitchSettings.initial_downtime, TwitchSettings.default_vote_time, TwitchSettings.default_downtime))

        -- Custom vote times.
        local settings_changed = false
        local custom_vote_times_prev = self.custom_vote_times
        self.custom_vote_times = Imgui.checkbox("Custom Vote Times##".. tostring(self), self.custom_vote_times)
        if self.custom_vote_times then
            self.initial_vote_downtime = math.max(Imgui.input_int("Initial Vote Downtime", self.initial_vote_downtime), 0)
            self.time_between_votes    = math.max(Imgui.input_int("Time Between Votes", self.time_between_votes), 0)
            self.vote_time             = math.max(Imgui.input_int("Vote Time", self.vote_time), 0)

            if TwitchSettings.initial_downtime ~= self.initial_vote_downtime then settings_changed = true end
            if TwitchSettings.default_downtime ~= self.time_between_votes then settings_changed = true end
            if TwitchSettings.default_vote_time ~= self.vote_time then settings_changed = true end

            TwitchSettings.initial_downtime  = self.initial_vote_downtime
            TwitchSettings.default_downtime  = self.time_between_votes
            TwitchSettings.default_vote_time = self.vote_time
        else
            -- Fall back to vanilla game timings.
            if custom_vote_times_prev ~= self.custom_vote_times then
                TwitchSettings.initial_downtime  = 60 -- Hardcoded in 'twitch_settings.lua'

                -- Other settings must be loaded from ui widgets.
                local gameplay_settings_widgets = Managers.ui._ingame_ui_context.ingame_ui.views.options_view.settings_lists.gameplay_settings.widgets
                for _, widget in ipairs(gameplay_settings_widgets) do
                    if widget.name and widget.name == "cb_twitch_vote_time" then
                        TwitchSettings.default_vote_time = widget.content.options_values[widget.content.current_selection]
                    end
                    if widget.name and widget.name == "cb_twitch_time_between_votes" then
                        TwitchSettings.default_downtime = widget.content.options_values[widget.content.current_selection]
                    end
                end
                settings_changed = true
            end
        end

        if settings_changed then
            Application.set_user_setting("twitch_time_between_votes", TwitchSettings.default_downtime)
            Application.set_user_setting("twitch_vote_time", TwitchSettings.default_vote_time)
        end

        Imgui.separator()

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
