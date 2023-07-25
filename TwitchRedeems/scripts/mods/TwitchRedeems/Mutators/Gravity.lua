local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")

local mutator_template = {
  description = "twitch_redeems_gravity_mutator_desc",
  display_name = "twitch_redeems_gravity_mutator_name",
  icon = "mutator_icon_powerful_elites",
  server_start_function = function(context, data)
    -- local PhysicsWorld = stingray.PhysicsWorld
    -- local world = Managers.world:world("level_world")
    -- local physics_world = World.get_data(world, "physics_world")
    -- mod:dump(data, "GRAVITY DATA", 5) -- TODO DEL)
    -- local oneshot_settings = data.template.oneshot_settings
    -- mod:dump(oneshot_settings, "oneshot_settings", 5) -- TODO DEL)
    -- local gravity = Vector3(oneshot_settings.data.gravity[1], oneshot_settings.data.gravity[2], oneshot_settings.data.gravity[3])
    -- PhysicsWorld.set_gravity(physics_world, gravity)
  end,
  client_start_function = function (context, data)
    -- Client functions are also called on server.
    local PhysicsWorld = stingray.PhysicsWorld
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    local oneshot_settings = data.template.oneshot_settings
    local gravity = Vector3(oneshot_settings.data.gravity[1], oneshot_settings.data.gravity[2], oneshot_settings.data.gravity[3])
    PhysicsWorld.set_gravity(physics_world, gravity)
	end,
  server_stop_function = function(context, data, is_destroy)
    -- local PhysicsWorld = stingray.PhysicsWorld
    -- local world = Managers.world:world("level_world")
    -- local physics_world = World.get_data(world, "physics_world")
    -- PhysicsWorld.set_gravity(physics_world, Vector3(0, 0, -9.82))
  end,
  client_stop_function = function(context, data, is_destroy)
    local PhysicsWorld = stingray.PhysicsWorld
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    PhysicsWorld.set_gravity(physics_world, Vector3(0, 0, -9.82))
  end
}

mod.add_mutator_template("twitch_redeems_gravity_mutator", mutator_template, 1101)

MutatorGravity = class(MutatorGravity)

MutatorGravity.init = function(self, other)
  self.mutator_type = MutatorType.GRAVITY
  self.settings = {}
  self.settings.gravity = {0, 0, -9.87}

  if other and type(other) == 'table' then
    self.settings = other.settings
  end
end

MutatorGravity.serialize = function(self)
  local data = {}
  data.settings = self.settings
  return data
end

MutatorGravity.render_ui = function(self)
  self.settings.gravity[1], self.settings.gravity[2], self.settings.gravity[3] = Imgui.drag_float_3("Gravity", self.settings.gravity[1], self.settings.gravity[2], self.settings.gravity[3])
end