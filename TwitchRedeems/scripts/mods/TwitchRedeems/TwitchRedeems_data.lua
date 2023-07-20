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
            {
              setting_id  = "twitch_redemption_ui_offset",
              type        = "group",
              sub_widgets = {
                {
                  setting_id = "twitch_redemption_ui_offset_x",
                  type = "numeric",
                  default_value = 0,
                  range = {-5000, 5000},
                },
                {
                  setting_id = "twitch_redemption_ui_offset_y",
                  type = "numeric",
                  default_value = 0,
                  range = {-5000, 5000},
                },
              }
            }
        }
      }
}
