local mod = get_mod("TwitchRedeems")

print("UJAF")

return {
	name = "TwitchRedeems",
	description = mod:localize("mod_description"),
	is_togglable = true,
	options = {
		widgets = {
			{
				setting_id      = "global_redeem_cooldown_duration",
				type            = "numeric",
				default_value   = 5,
				range           = {0, 600},
				unit_text       = "unit_seconds_id", -- optional
				decimals_number = 0                  -- optional
			},
			{
				setting_id      = "user_redeem_cooldown_duration",
				type            = "numeric",
				default_value   = 5,
				range           = {0, 600},
				unit_text       = "unit_seconds_id", -- optional
				decimals_number = 0                  -- optional
			},
			{
				setting_id      = "user_redeem_cooldown",
				type            = "checkbox",
				default_value   = true,
			},
		}
	  }
}
