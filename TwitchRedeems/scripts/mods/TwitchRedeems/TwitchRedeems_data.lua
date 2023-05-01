local mod = get_mod("TwitchRedeems")

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
			{
				setting_id      = "initial_downtime_id",
				type            = "numeric",
				default_value   = 60,
				range           = {0, 600},
				unit_text       = "unit_seconds_id", -- optional
				decimals_number = 0                  -- optional
			},
			{
				setting_id      = "default_downtime_id",
				type            = "numeric",
				default_value   = 5,
				range           = {0, 600},
				unit_text       = "unit_seconds_id", -- optional
				decimals_number = 0                  -- optional
			},
			{
				setting_id      = "default_vote_time_id",
				type            = "numeric",
				default_value   = 60,
				range           = {0, 600},
				unit_text       = "unit_seconds_id", -- optional
				decimals_number = 0                  -- optional
			},
			{
				setting_id      = "spawn_amount_multiplier_id",
				type            = "numeric",
				default_value   = 100,
				range           = {100, 1000},
				unit_text       = "unit_percentage_id", -- optional
				decimals_number = 0                  -- optional
			},
		}
	  }
}
