local mod = get_mod("TwitchRedeems")

return {
    name = "TwitchRedeems",
    description = mod:localize("mod_description"),
    is_togglable = true,
    options = {
        widgets = {
            {
                setting_id      = "KEYBIND_TOGGLE_TWITCH_REDEEM_CONFIG_GUI",
                type            = "keybind",
                default_value   = {},
                keybind_global  = true,
                keybind_trigger = "pressed",
                keybind_type    = "function_call",
                function_name   = "toggle_twitch_redeems_configuration_gui",
            },
            {
                setting_id      = "KEYBIND_TOGGLE_TWITCH_GUI",
                type            = "keybind",
                default_value   = {},
                keybind_global  = true,
                keybind_trigger = "pressed",
                keybind_type    = "function_call",
                function_name   = "toggle_twitch_gui",
            },
        }
      }
}
