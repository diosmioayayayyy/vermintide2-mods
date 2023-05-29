local mod = get_mod("TwitchRedeems")

local function merge(dst, src)
    for k, v in pairs(src) do
        dst[k] = v
    end
    return dst
end

function table.random_elem(tb)
    local keys = {}
    for k in pairs(tb) do table.insert(keys, k) end
    return tb[keys[math.random(#keys)]]
end

function breed_name_valid(breed_name)
	local breed = Breeds[breed_name]
	return breed ~= nil
end

function mod.add_buff_template(buff_name, buff_data, extra_data, override_index)
    if BuffTemplates[buff_name] == nil then
        local new_buff = {
            buffs = {
                merge({ name = buff_name }, buff_data),
            },
        }
        if extra_data then
            new_buff = merge(new_buff, extra_data)
        end

        BuffTemplates[buff_name] = new_buff
        local index = override_index or #NetworkLookup.buff_templates + 1
        
        if not table.contains(NetworkLookup.buff_templates, index) then
            NetworkLookup.buff_templates[index] = buff_name
            NetworkLookup.buff_templates[buff_name] = index
            --mod:echo("Buff template: '" .. buff_name .. "' at index " .. index .. " was added")
        else
            mod:error("Buff template: '" .. buff_name .. "' at index " .. index .. " already exists!")
        end
    end
end

-- Basically a copy of 'HordeSpawner.execute_custom_horde', but with 'optional_data' as parameter to apply buffs to spawning enemies.
HordeSpawner.execute_twitch_redeem_horde = function (self, spawn_list, only_ahead, side_id, optional_data)
	local settings = CurrentHordeSettings.vector_blob
	local roll = math.random()
	local spawn_horde_ahead = only_ahead or roll <= settings.main_path_chance_spawning_ahead

	print("wants to spawn " .. ((spawn_horde_ahead and "ahead") or "behind") .. " within distance: ", settings.main_path_dist_from_players)

	local success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

	if not success then
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

	local num_to_spawn = #spawn_list
	local num_columns = 6
	local group_size = 0
	local rot = Quaternion.look(Vector3(to_player_dir.x, to_player_dir.y, 1))
	local max_attempts = 8
	local conflict_director = self.conflict_director
	local nav_world = conflict_director.nav_world

	for i = 1, num_to_spawn, 1 do
		local spawn_pos = nil

		for j = 1, max_attempts, 1 do
			local offset = nil

			if j == 1 then
				offset = Vector3(-num_columns / 2 + i % num_columns, -num_columns / 2 + math.floor(i / num_columns), 0)
			else
				offset = Vector3(4 * math.random() - 2, 4 * math.random() - 2, 0)
			end

			spawn_pos = LocomotionUtils.pos_on_mesh(nav_world, blob_pos + offset * 2)

			if spawn_pos then
				local breed = spawn_list[i]

                local optional_data = optional_data or {}
                optional_data.side_id = side_id

				conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos), QuaternionBox(rot), "hidden_spawn", nil, "horde_hidden", optional_data, nil)

				group_size = group_size + 1

				break
			end
		end
	end

	print("custom blob horde has started")
end