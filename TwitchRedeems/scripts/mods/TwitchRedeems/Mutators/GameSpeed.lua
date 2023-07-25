local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")

local mutator_template = {
  description = "twitch_redeems_gamespeed_mutator_desc",
  display_name = "twitch_redeems_gamespeed_mutator_name",
  icon = "mutator_icon_powerful_elites",
  server_start_function = function(context, data)
  end,
  client_start_function = function (context, data)
    local oneshot_settings = data.template.oneshot_settings
    mod.global_time_scale = oneshot_settings.data.speed_multiplier
	end,
  server_stop_function = function(context, data, is_destroy)
  end,
  client_stop_function = function(context, data, is_destroy)
    mod.global_time_scale = 1.0
  end
}

mod.add_mutator_template("twitch_redeems_gamespeed_mutator", mutator_template, 1102)

mod.global_time_scale = 1.0

mod:hook(TimeManager, "scaled_delta_time", function(func, self, dt)
  -- TODO make options wich dt's to change, like only simulation
  return math.max(dt * self._global_time_scale  * mod.global_time_scale, 1e-06)
end)

MutatorGameSpeed = class(MutatorGameSpeed)

MutatorGameSpeed.init = function(self, other)
  self.mutator_type = MutatorType.GAMESPEED
  self.settings = {}
  self.settings.speed_multiplier = 1.0

  if other and type(other) == 'table' then
    self.settings = other.settings
  end
end

MutatorGameSpeed.serialize = function(self)
  local data = {}
  data.settings = self.settings
  return data
end

MutatorGameSpeed.render_ui = function(self)
  self.settings.speed_multiplier = Imgui.drag_float("Speed Multiplier", self.settings.speed_multiplier)
end