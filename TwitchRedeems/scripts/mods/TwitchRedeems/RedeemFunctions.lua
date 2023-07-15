local mod = get_mod("TwitchRedeems")

if not INCLUDE_GUARDS.REDEEM_FUNCTIONS then
  INCLUDE_GUARDS.REDEEM_FUNCTIONS = true

  local function get_horde_spawn_position(horde_redeem)
    local conflict_director = Managers.state.conflict
    local settings = CurrentHordeSettings.vector_blob

    -- Decide where to spawn horde.
    local spawn_horde_ahead = true -- Default spawn in front.
    if horde_redeem.spawn_pos == SpawnPosition.BACK then
      spawn_horde_ahead = false
    elseif horde_redeem.spawn_pos == SpawnPosition.RANDOM then
      local roll = math.random()
      spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead
    end

    -- Try to get horde spawn position.
    local success, blob_pos, to_player_dir = conflict_director.horde_spawner:get_pos_ahead_or_behind_players_on_mainpath(
      spawn_horde_ahead, settings.main_path_dist_from_players, settings.raw_dist_from_players, horde_redeem.side_id)

    if not success then
      success, blob_pos, to_player_dir = conflict_director.horde_spawner:get_pos_ahead_or_behind_players_on_mainpath(
        not spawn_horde_ahead,
        settings.main_path_dist_from_players, settings.raw_dist_from_players, horde_redeem.side_id)

      if not success then
        local roll = math.random()
        local spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead
        local distance_bonus = 20
        success, blob_pos, to_player_dir = conflict_director.horde_spawner:get_pos_ahead_or_behind_players_on_mainpath(
          spawn_horde_ahead,
          settings.main_path_dist_from_players + distance_bonus, settings.raw_dist_from_players, horde_redeem.side_id)
      end
    end

    if not blob_pos then
      print("\no spawn position found at all, failing horde")
    end

    return success, blob_pos, to_player_dir
  end

  function spawn_redeem_horde(horde_redeem)
    -- Get horde spawn position.
    local success, blob_pos, to_player_dir = get_horde_spawn_position(horde_redeem)

    if not success then
      mod:debug("Failed get horde spawn position")
      return
    end

    -- Determine the number of units to spawn.
    local total_num_units = 0
    local num_units = {}

    for key, unit in ipairs(horde_redeem.spawn_list) do
      num_units[key] = unit.amount:get()
      total_num_units = total_num_units + num_units[key]
    end

    -- Spawn units.
    local num_columns = 6
    local max_attempts = 8
    local rot = Quaternion.look(Vector3(to_player_dir.x, to_player_dir.y, 1))

    local conflict_director = Managers.state.conflict
    local nav_world = conflict_director.nav_world

    local spawn_cnt = 0

    for key, unit in ipairs(horde_redeem.spawn_list) do
      local unit_count = num_units[key]

      for i = 1, unit_count, 1 do
        local spawn_pos = nil

        for j = 1, max_attempts, 1 do
          local offset = nil

          if j == 1 then
            offset = Vector3(-num_columns / 2 + spawn_cnt % num_columns, -num_columns / 2 + math.floor(spawn_cnt / num_columns), 0)
          else
            offset = Vector3(4 * math.random() - 2, 4 * math.random() - 2, 0)
          end

          spawn_pos = LocomotionUtils.pos_on_mesh(nav_world, blob_pos + offset * 2)

          if spawn_pos then
            conflict_director:spawn_queued_unit(unit.breed, Vector3Box(spawn_pos), QuaternionBox(rot), "hidden_spawn", nil, "horde_hidden", unit.optional_data, nil)
            break
          end
        end

        spawn_cnt = spawn_cnt + 1
      end
    end
  end

  function spawn_redeem_hidden(horde_redeem)
    local conflict_director = Managers.state.conflict

    for key, unit in ipairs(horde_redeem.spawn_list) do
      local amount = unit.amount:get()

      for i = 1, amount, 1 do
        local hidden_pos = conflict_director.specials_pacing:get_special_spawn_pos()
        conflict_director:spawn_one(unit.breed, hidden_pos, nil, unit.optional_data)
      end
    end
  end

  function spawn_redeem_one(horde_redeem)
    local conflict_director = Managers.state.conflict

    for key, unit in ipairs(horde_redeem.spawn_list) do
      local amount = unit.amount:get()

      for i = 1, amount, 1 do
        conflict_director:spawn_one(unit.breed, nil, nil, unit.ptional_data)
      end
    end
  end
end
