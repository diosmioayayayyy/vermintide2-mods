local mod = get_mod("TwitchRedeems")

local mutator_template =  {
  description = "twitch_redeems_gravity_mutator_desc",
  display_name = "twitch_redeems_gravity_mutator_name",
  icon = "mutator_icon_powerful_elites",
  --gravity = {0,0,5},
  server_start_function = function(context, data)
    local PhysicsWorld = stingray.PhysicsWorld
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    PhysicsWorld.set_gravity(physics_world, Vector3(0, 0, 1))
  end,
  client_start_function = function (context, data)
    local PhysicsWorld = stingray.PhysicsWorld
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    PhysicsWorld.set_gravity(physics_world, Vector3(0, 0, 1))
	end,
  server_stop_function = function(context, data, is_destroy)
    local PhysicsWorld = stingray.PhysicsWorld
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    PhysicsWorld.set_gravity(physics_world, Vector3(0, 0, -9.82))
  end,
  client_stop_function = function(context, data, is_destroy)
    local PhysicsWorld = stingray.PhysicsWorld
    local world = Managers.world:world("level_world")
    local physics_world = World.get_data(world, "physics_world")
    PhysicsWorld.set_gravity(physics_world, Vector3(0, 0, -9.82))
  end
}

mod.add_mutator_template("twitch_redeems_gravity_mutator", mutator_template, 1101)