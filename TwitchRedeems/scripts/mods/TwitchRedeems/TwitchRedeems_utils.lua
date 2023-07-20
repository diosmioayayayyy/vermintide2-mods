local mod = get_mod("TwitchRedeems")

 -- TODO move to Utils folder

if not INCLUDE_GUARDS.TWITCH_REDEEMS_UTILS then
  INCLUDE_GUARDS.TWITCH_REDEEMS_UTILS = true

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

  Rectangle.contains_rect = function(self, other)
    return (other.x + other.width) <= (self.x + self.width)
        and (other.x) >= (self.x)
        and (other.y) >= (self.y)
        and (other.y + other.height) <= (self.y + self.height)
  end

  Rectangle.contains_point = function(self, point)
    return (point.x) <= (self.x + self.width)
        and (point.x) >= (self.x)
        and (point.y) >= (self.y)
        and (point.y) <= (self.y + self.height)
  end

  Rectangle.restrain = function(self, largerRect)
    self.x = math.max(self.x, largerRect.x)
    self.y = math.max(self.y, largerRect.y)

    local maxX = largerRect.x + largerRect.width - self.width
    local maxY = largerRect.y + largerRect.height - self.height

    self.x = math.min(self.x, maxX)
    self.y = math.min(self.y, maxY)
  end

  Vector3.any = function(v)
    return v.x ~= 0 or v.y ~= 0 or v.z ~= 0
  end

  Vector3.all = function(v)
    return v.x ~= 0 and v.y ~= 0 and v.z ~= 0
  end

  function sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
  end

  function to_hex_color(red, green, blue)
    local function toHex(value)
      value = math.floor(value * 255)
      return string.format("%02X", value)
    end

    local redHex = toHex(red)
    local greenHex = toHex(green)
    local blueHex = toHex(blue)

    return "#" .. redHex .. greenHex .. blueHex
  end

  function to_rgb_color(hex_str, alpha)
    -- Remove the '#' symbol if present
    hex_str = string.gsub(hex_str, "#", "")

    -- Check if the hexadecimal value is valid
    if #hex_str ~= 6 then
        mod:error("Invalid hexadecimal color format: " .. hex_str)
    end

    -- Convert the hexadecimal color to RGB values
    local red = tonumber(hex_str:sub(1, 2), 16)
    local green = tonumber(hex_str:sub(3, 4), 16)
    local blue = tonumber(hex_str:sub(5, 6), 16)

    return {alpha and alpha or 255, red, green, blue}
  end

  function breed_name_valid(breed_name)
    local breed = Breeds[breed_name]
    return breed ~= nil
  end

  function add_spawn_func(optional_data, spawn_func)
    optional_data = optional_data or {}

    if optional_data.spawned_func then
      local previous_spawned_func = optional_data.spawned_func

      optional_data.spawned_func = function(unit, breed, optional_data)
        previous_spawned_func(unit, breed, optional_data)
        spawn_func(unit, breed, optional_data)
      end
    else
      optional_data.spawned_func = spawn_func
    end
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
  HordeSpawner.execute_twitch_redeem_horde = function(self, spawn_list, only_ahead, side_id, optional_data)
    local settings = CurrentHordeSettings.vector_blob
    local roll = math.random()
    local spawn_horde_ahead = only_ahead or roll <= settings.main_path_chance_spawning_ahead

    print("wants to spawn " .. ((spawn_horde_ahead and "ahead") or "behind") .. " within distance: ",
      settings.main_path_dist_from_players)

    local success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead,
      settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

    if not success then
      success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(not spawn_horde_ahead,
        settings.main_path_dist_from_players, settings.raw_dist_from_players, side_id)

      if not success then
        local roll = math.random()
        local spawn_horde_ahead = roll <= settings.main_path_chance_spawning_ahead
        local distance_bonus = 20
        success, blob_pos, to_player_dir = self:get_pos_ahead_or_behind_players_on_mainpath(spawn_horde_ahead,
          settings.main_path_dist_from_players + distance_bonus, settings.raw_dist_from_players, side_id)
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

          conflict_director:spawn_queued_unit(breed, Vector3Box(spawn_pos), QuaternionBox(rot), "hidden_spawn", nil,
            "horde_hidden", optional_data, nil)

          group_size = group_size + 1

          break
        end
      end
    end

    print("custom blob horde has started")
  end
end
