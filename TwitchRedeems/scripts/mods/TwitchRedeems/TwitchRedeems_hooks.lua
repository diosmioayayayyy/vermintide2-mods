local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/RedeemFunctions")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")

local function fulfill_redeem(redemption)
  local redeem_index = mod.redeem_lookup[string.lower(redemption.title)]
  if redeem_index ~= nil then
    local redeem = mod.redeems[redeem_index]
    redeem:redeem(redemption.user_input)
  end
end

-- This hook processes the redeems and applies them.
mod:hook_safe(TwitchManager, "update", function(self, dt, t)
    local is_server = Managers.state.network and Managers.state.network.is_server
    if is_server and mod.redeems_enabled and Managers.state.entity ~= nil then
        -- Process redeems.
        if mod.redeem_queue ~= nil and mod.redeem_queue:size() > 0 then
          local redeem = mod.redeem_queue:pop()
          if redeem then
            local msg = string.format("%s redeemed %s", redeem.user, redeem.title)
            if redeem.user_input ~= "" then
              msg = msg .. string.format("\n '%s'", redeem.user_input)
            end
            --mod:chat_broadcast(msg)
            mod:network_send("new-redemption", "all", redeem)
            mod:info("Spawning Redeem '" .. redeem.title .. "'")
            mod:dump(redeem, "redeem to spawn", 2) --TODO DEBUG
            fulfill_redeem(redeem)
          end
        end
    end
end)

-- Do not freeze modified breeds. Else the game will reuse those breeds for normal enemies and everything gets messy.
mod:hook(BreedFreezer, "try_mark_unit_for_freeze", function(func, self, breed, unit)
    if breed.is_twitch_redeem == true then
        return false
    end
    return func(self, breed, unit)
end)

-- Do not unfreeze modified breeds. Else the game might just reuse a normal breed instead.
mod:hook(BreedFreezer, "try_unfreeze_breed", function(func, self, breed, data)
    if breed.is_twitch_redeem == true then
        return nil
    end
    return func(self, breed, data)
end)

-- mod:hook_safe(Boot, "game_update", function(self, real_world_dt)
--   --mod:echo("UPPPDAA")
--   -- boot.lua 707
-- end)www

-- Twitch Redeems horde spawns.
local function add_twitch_redeems_eye_glow_buff_to_horde(hordes)
  local buff_system = Managers.state.entity:system("buff_system")
  local horde_id = #hordes
  hordes[horde_id].optional_data = hordes[horde_id].optional_data or {}
  add_spawn_func(hordes[horde_id].optional_data, function (unit) buff_system:add_buff(unit, "twitch_redeem_buff_eye_glow", unit) end)
end

mod:hook_safe(HordeSpawner, "execute_vector_horde", function(self, extra_data, side_id, fallback)
  if extra_data.twitch_redeem_horde == true then
    mod:info("Twitch Redeem Vector Horde is spawning")
    add_twitch_redeems_eye_glow_buff_to_horde(self.hordes)
  end
end)

-- NOT WORKING. optional_data is not used in vector blob hordes => full function hook necessary, see further down below.
-- mod:hook_safe(HordeSpawner, "execute_vector_blob_horde", function(self, extra_data, side_id, fallback)
--   if extra_data.twitch_redeem_horde == true then
--     mod:info("Twitch Redeem Vector Blob Horde is spawning")
--     add_twitch_redeems_eye_glow_buff_to_horde(self.hordes) 
--   end
-- end)

mod:hook_safe(HordeSpawner, "execute_ambush_horde", function(self, extra_data, side_id, fallback, override_epicenter_pos, optional_data)
  if extra_data.twitch_redeem_horde == true then
    mod:info("Twitch Redeem Ambush Horde is spawning")
    add_twitch_redeems_eye_glow_buff_to_horde(self.hordes)
  end
end)


-- Health extension fixes: This extension is behaving weird, freezed units with max_health_modifier will keep their max health when unfreezed...
mod:hook_safe(GenericHealthExtension, "reset", function(self)
  self.is_invincible = false
end)

mod:hook_safe(GenericHealthExtension, "init", function(self, extension_init_context, unit, extension_init_data)
end)


-- Add purple glowing eyes for twitch redeem horde. Rest of the function is the same.
mod:hook(HordeSpawner, "execute_vector_blob_horde", function(func, self, extra_data, side_id, fallback)
	local settings = CurrentHordeSettings.vector_blob
	local roll = math.random()
	local spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead

	print("wants to spawn " .. (spawn_horde_ahead and "ahead" or "behind") .. " within distance: ", settings.main_path_dist_from_players)

	local success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

	if not success then
		print("\tcould not, tries to spawn" .. (not spawn_horde_ahead and "ahead" or "behind"))

		success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(not spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

		if not success then
			local roll = math.random()
			local spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead
			local distance_bonus = 20
			success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players + distance_bonus, settings.raw_dist_from_players, side_id)
		end
	end

	if not blob_pos then
		print("\no spawn position found at all, failing horde")

		return
	end

	local composition_type = nil
	local optional_wave_composition = extra_data and extra_data.optional_wave_composition

	if optional_wave_composition then
		local chosen_wave_composition = HordeWaveCompositions[optional_wave_composition]
		composition_type = chosen_wave_composition[math.random(#chosen_wave_composition)]
	else
		composition_type = extra_data and extra_data.override_composition_type or CurrentHordeSettings.vector_composition or "medium"
	end

	assert(composition_type, "Vector Blob Horde missing composition_type")

	local composition = CurrentHordeSettings.compositions_pacing[composition_type]
	local spawn_list, num_to_spawn = nil

	if extra_data and extra_data.spawn_list then
		num_to_spawn = #extra_data.spawn_list
		spawn_list = extra_data.spawn_list
	else
		spawn_list, num_to_spawn = self:compose_blob_horde_spawn_list(composition_type)
	end

	local group_id = Managers.state.entity:system("ai_group_system"):generate_group_id()
	local group_template = {
		template = "horde",
		id = group_id,
		size = num_to_spawn,
		sneaky = spawn_horde_ahead,
		group_data = extra_data
	}
	local t = Managers.time:time("game")
	local sound_settings = composition.sound_settings
	local horde = {
		horde_type = "vector_blob",
		spawned = 0,
		num_to_spawn = num_to_spawn,
		epicenter_pos = Vector3Box(blob_pos),
		start_time = t + settings.start_delay,
		group_template = group_template,
		sound_settings = sound_settings,
		group_id = group_id
	}

	print("horde crated with id", group_id, "of type ", horde.horde_type)

	local num_columns = 6
	local group_size = 0
	local rot = Quaternion.look(Vector3(to_player_dir.x, to_player_dir.y, 1))
	local max_attempts = 8
	local conflict_director = self.conflict_director
	local nav_world = conflict_director.nav_world

  local buff_system = Managers.state.entity:system("buff_system") -- Twitch Redeems

	for i = 1, num_to_spawn do
		local spawn_pos = nil

		for j = 1, max_attempts do
			local offset = nil

			if j == 1 then
				offset = Vector3(-num_columns / 2 + i % num_columns, -num_columns / 2 + math.floor(i / num_columns), 0)
			else
				offset = Vector3(4 * math.random() - 2, 4 * math.random() - 2, 0)
			end

			spawn_pos = LocomotionUtils.pos_on_mesh(nav_world, blob_pos + offset * 2)

			if spawn_pos then
				local breed = Breeds[spawn_list[i]]
				local optional_data = {
					side_id = side_id
				}

         -- Twitch Redeems
				if extra_data.twitch_redeem_horde then
            optional_data.spawned_func = function(unit, breed, optional_data)
              buff_system:add_buff(unit, "twitch_redeem_buff_eye_glow", unit)
            end
        end

				conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos), QuaternionBox(rot), "hidden_spawn", nil, "horde_hidden", optional_data, group_template)

				group_size = group_size + 1

				break
			end
		end
	end

	conflict_director:add_horde(group_size)

	horde.spawned = group_size

	print("managed to spawn " .. tostring(group_size) .. "/" .. tostring(num_to_spawn) .. " horde enemies")

	local conflict_director = self.conflict_director

	if script_data.debug_player_intensity then
		conflict_director.pacing:annotate_graph("(B)Horde:" .. group_size .. "/" .. num_to_spawn, "lime")
	end

	local horde_wave = extra_data and extra_data.horde_wave

	if horde_wave == "multi_first_wave" or horde_wave == "single" then
		local stinger_name = sound_settings.stinger_sound_event or "enemy_horde_stinger"

		self:play_sound(stinger_name, horde.epicenter_pos:unbox())
	end

	local hordes = self.hordes
	local id = #hordes + 1
	hordes[id] = horde
	self.last_paced_horde_type = "vector_blob"
	self.num_paced_hordes = self.num_paced_hordes + 1

	print("vector blob horde has started")
end)

-- UI hooks.
mod:hook_safe(IngameHud, "init", function(self, parent, ingame_ui_context)
  self._twitch_redeems_ui = TwitchRedeemUI:new(parent, ingame_ui_context)
end)

mod:hook_safe(IngameHud, "update", function(self, dt , t)
  if self._twitch_redeems_ui then
    if mod.twitch_redemption_ui_settings_dirty then
      self._twitch_redeems_ui:update_ui_settings()
      mod.twitch_redemption_ui_settings_dirty = false
    end

    self._twitch_redeems_ui:update(dt)
  end
end)
