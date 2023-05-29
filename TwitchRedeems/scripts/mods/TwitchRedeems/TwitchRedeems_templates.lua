local mod = get_mod("TwitchRedeems")

TwitchRedeemTemplates = {}

local monster_breads = {
    Breeds.skaven_rat_ogre,
    Breeds.skaven_stormfiend,
    Breeds.chaos_spawn,
    Breeds.chaos_troll,
    Breeds.beastmen_minotaur,
}

local special_breads = {
    Breeds.skaven_pack_master,
    Breeds.skaven_gutter_runner,
    Breeds.skaven_ratling_gunner,
    Breeds.skaven_warpfire_thrower,
    Breeds.skaven_poison_wind_globadier,
    Breeds.chaos_corruptor_sorcerer,
    Breeds.chaos_vortex_sorcerer,
}

local function get_random_monster_breed()
    local monster_breeds = {
        Breeds.skaven_rat_ogre,
        Breeds.skaven_stormfiend,
        Breeds.chaos_spawn,
        Breeds.chaos_troll,
        Breeds.beastmen_minotaur,
    }
    local i = math.random(#monster_breeds)
    return monster_breeds[i]
end

local function spawn_custom_horde(spawn_table, optional_data)
	local side = Managers.state.side:get_side_from_name("dark_pact")
	local side_id = side.side_id
	local spawn_list = {}

    for k, spawn in pairs(spawn_table) do
        for i = 1, spawn.amount, 1 do
            spawn_list[#spawn_list + 1] = spawn.breed
        end
    end

	local conflict_director = Managers.state.conflict
	local only_ahead = false
	local main_path_info = conflict_director.main_path_info

	if main_path_info.ahead_unit or main_path_info.behind_unit then
		conflict_director.horde_spawner:execute_twitch_redeem_horde(spawn_list, only_ahead, side_id, optional_data)
	end
end

local function spawn_hidden(breed, amount_of_enemies, optional_data)
	local conflict_director = Managers.state.conflict
	for i = 1, amount_of_enemies, 1 do
		local hidden_pos = conflict_director.specials_pacing:get_special_spawn_pos()
		conflict_director:spawn_one(breed, hidden_pos, nil, optional_data)
	end
end

local play_sound = function (stinger_name, pos)
    local conflict_director = Managers.state.conflict -- TODO is this right way to get world?
    local wwise_world = Managers.world:wwise_world(conflict_director._world)
    local wwise_playing_id, wwise_source_id = WwiseWorld.trigger_event(wwise_world, stinger_name)
	Managers.state.network.network_transmit:send_rpc_clients("rpc_server_audio_event", NetworkLookup.sound_events[stinger_name])
end

local function add_spawn_func(optional_data, spawn_func)
    optional_data = optional_data or {}

	if optional_data.spawned_func then
		local previous_spawned_func = optional_data.spawned_func

		optional_data.spawned_func = function (unit, breed, optional_data)
			previous_spawned_func(unit, breed, optional_data)
			spawn_func(unit, breed, optional_data)
		end
	else
		optional_data.spawned_func = spawn_func
	end
end

-- Apply custom breed configuration and returns cloned modified breed.
local function prepare_breed(breed, breed_data)
    local new_breed = table.clone(breed)

    for key, value in pairs(breed_data) do
        print(breed.name, key, value)
        new_breed[key] = value
    end

    new_breed.is_twitch_redeem = true

    return new_breed
end

local function default_spawn_function(spawn_list, optional_data)
    local buff_system = Managers.state.entity:system("buff_system")

    for k, spawn in pairs(spawn_list) do
        local breed = Breeds[spawn.breed]

        -- TODO MOVE THIS
        local on_spawn_func = function(unit)
            buff_system:add_buff(unit, "twitch_redeem_buff_pingable", unit)
        end

        if spawn.taggable == true then
            add_spawn_func(optional_data, on_spawn_func)
        end

        optional_data.max_health_modifier = spawn.max_health_modifier

        if spawn.breed_data ~= nil then
            breed = prepare_breed(breed, spawn.breed_data)
        end

        if spawn.spawn == "hidden" then
            spawn_hidden(breed, spawn.amount, optional_data)
        elseif spawn.spawn == "horde" then
            local spawns = {
                { breed = breed, amount = spawn.amount },
            }
            spawn_custom_horde(spawns, optional_data)
        elseif spawn.spawn == "one" then
            for i = 1, spawn.amount, 1 do
                Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            end
        end
    end
end

TwitchRedeemTemplates.twitch_redeem_test = {
    key = "test",
    text = "test",
    on_success = function(is_server, optional_data)
        if is_server then
-- https://github.dev/Aussiemon/Vermintide-2-JHF-Mods/blob/master/CreatureSpawner/scripts/mods/CreatureSpawner/CreatureSpawner.lua
-- c 275
            local spawn_list = {}
            spawn_list[0] = {
                amount = 1,
                breed = "skaven_slave", -- TODO make breed check function
                max_health_modifier = 1,
                spawn = "horde", -- "one"
                taggable = true,
                breed_data = {
                    stagger_immune = false,
                    size_variation_range = { 1.0, 1.3 },
                    walk_speed = 0.1,
                    run_speed = 10.0,
                }
            }

            default_spawn_function(spawn_list, optional_data)
        end
    end
}

-- Monsters

TwitchRedeemTemplates.twitch_redeem_monster = {
    key = "monster",
    text = "monster",
    on_success = function(is_server, optional_data, param)
        if is_server then
            local breed = get_random_monster_breed()

            if type(param) == "string" then
                local str = string.lower(param)

                if string.find(str, "trol") then
                    breed = Breeds.chaos_troll
                elseif string.find(str, "bile") then
                    breed = Breeds.skaven_rat_ogre

                elseif string.find(str, "ogr") then
                    breed = Breeds.skaven_rat_ogre
                elseif string.find(str, "org") then
                    breed = Breeds.skaven_rat_ogre
                elseif string.find(str, "rat") then
                    breed = Breeds.skaven_rat_ogre
                elseif string.find(str, "rog") then
                    breed = Breeds.skaven_rat_ogre
                elseif string.find(str, "frod") then
                    breed = Breeds.skaven_rat_ogre

                elseif string.find(str, "sp") then
                    breed = Breeds.chaos_spawn
                elseif string.find(str, "wn") then
                    breed = Breeds.chaos_spawn

                elseif string.find(str, "storm") then
                    breed = Breeds.skaven_stormfiend
                elseif string.find(str, "fiend") then
                    breed = Breeds.skaven_stormfiend
                elseif string.find(str, "friend") then
                    breed = Breeds.skaven_stormfiend

                elseif string.find(str, "min") then
                    breed = Breeds.beastmen_minotaur
                elseif string.find(str, "cow") then
                    breed = Breeds.beastmen_minotaur
                elseif string.find(str, "bea") then
                    breed = Breeds.beastmen_minotaur
                elseif string.find(str, "bul") then
                    breed = Breeds.beastmen_minotaur
                end
            end

            optional_data.max_health_modifier = 0.85

            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

local mod = get_mod("TwitchRedeems")

local function create_template_lookup(templates)
    local lookup_table = {}
    for key,template in pairs(templates) do
        if template ~= nil then
            lookup_table[string.lower(template.key)] = (type(key) == "string") and string.lower(key) or key
        end
    end
    return lookup_table
end

local TwitchRedeemTemplatesFromConfig = mod:get("redeems")

for _, redeem in pairs(TwitchRedeemTemplatesFromConfig) do
    redeem.on_success = function(is_server, optional_data)
        if is_server then
            default_spawn_function(redeem.spawn_list, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
end

table.append(TwitchRedeemTemplates, TwitchRedeemTemplatesFromConfig)

-- Loop through redeems and check for any configuration errors.
local invalid_redeems = {}
for k, redeem in pairs(TwitchRedeemTemplates) do
    if type(redeem.spawn_list) == "table" then
        for _, element in pairs(redeem.spawn_list) do
            if not breed_name_valid(element.breed) then
                mod:error("unknown breed name '" .. element.breed .. "' for redeem key '" .. redeem.key .. "'")
                table.insert(invalid_redeems, k)
                break
            end
        end
    end
end

if #invalid_redeems > 0 then
    mod:info("Removing invalid redeems...")
    mod:dump(invalid_redeems, "invalid_redeems", 1)
    for _, k in pairs(invalid_redeems) do
        TwitchRedeemTemplates[k] = nil
    end
end

-- Create inverse lookup table for redeems.
TwitchRedeemTemplatesLookup = create_template_lookup(TwitchRedeemTemplates)

--mod:dump(TwitchRedeemTemplates, "TwitchRedeemTemplates", 5)
--mod:dump(TwitchRedeemTemplatesLookup, "TwitchRedeemTemplatesLookup", 5)
