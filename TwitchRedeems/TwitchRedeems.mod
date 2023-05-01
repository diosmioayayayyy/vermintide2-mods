return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`TwitchRedeems` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("TwitchRedeems", {
			mod_script       = "scripts/mods/TwitchRedeems/TwitchRedeems",
			mod_data         = "scripts/mods/TwitchRedeems/TwitchRedeems_data",
			mod_localization = "scripts/mods/TwitchRedeems/TwitchRedeems_localization",
		})
	end,
	packages = {
		"resource_packages/TwitchRedeems/TwitchRedeems",
	},
}
