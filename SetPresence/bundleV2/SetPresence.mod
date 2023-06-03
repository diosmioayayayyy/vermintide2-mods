return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`SetPresence` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("SetPresence", {
			mod_script       = "scripts/mods/SetPresence/SetPresence",
			mod_data         = "scripts/mods/SetPresence/SetPresence_data",
			mod_localization = "scripts/mods/SetPresence/SetPresence_localization",
		})
	end,
	packages = {
		"resource_packages/SetPresence/SetPresence",
	},
}
