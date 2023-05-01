local mod = get_mod("TwitchRedeems")

TwitchRedeemTemplates = TwitchRedeemTemplates or {}

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

local function default_spawn_function(spawn_list, optional_data)
	local side = Managers.state.side:get_side_from_name("dark_pact")
	local side_id = side.side_id
	local spawn_list = {}
end

-- Specials

TwitchRedeemTemplates.twitch_redeem_hook_rat = {
    key = "hook rat",
    text = "hook rat",
    on_success = function(is_server, optional_data)
        if is_server then
            spawn_hidden(Breeds.skaven_pack_master, 1, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_gutter_runner = {
    key = "gutter runner",
    text = "gutter runner",
    on_success = function(is_server, optional_data)
        if is_server then
            spawn_hidden(Breeds.skaven_gutter_runner, 1, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_ratling_gunner = {
    key = "ratling gunner",
    text = "ratling gunner",
    on_success = function(is_server, optional_data)
        if is_server then
            spawn_hidden(Breeds.skaven_ratling_gunner, 1, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_warpfire_thrower = {
    key = "warpfire thrower",
    text = "warpfire thrower",
    on_success = function(is_server, optional_data)
        if is_server then
            spawn_hidden(Breeds.skaven_warpfire_thrower, 1, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

-- Elites

TwitchRedeemTemplates.twitch_redeem_green_rats = {
    key = "green rats",
    text = "a pack of green rats",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "skaven_plague_monk", amount = 5 },
            }
            spawn_custom_horde(spawns, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_chaos_warrior = {
    key = "chaos warriors",
    text = "a pack of chaos warriors",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "chaos_warrior", amount = 3 },
            }
            spawn_custom_horde(spawns, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_stormvermins = {
    key = "stormvermins",
    text = "a pack of stormvermins",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "skaven_storm_vermin", amount = 5 },
            }
            spawn_custom_horde(spawns, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_shielded_stormvermins = {
    key = "shielded stormvermins",
    text = "a pack of shielded stormvermins",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "skaven_storm_vermin_with_shield", amount = 7 },
            }
            spawn_custom_horde(spawns, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_beasty_boys = {
    key = "beasty boys",
    text = "some beasty boys",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "beastmen_bestigor", amount = 5 },
                { breed = "beastmen_standard_bearer", amount = 3 },
                --{ breed = "ethereal_skeleton_with_hammer", amount = 20 },
            }
            spawn_custom_horde(spawns, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_maulers = {
    key = "maulers",
    text = "get mauled",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "chaos_raider", amount = 10 },
            }
            spawn_custom_horde(spawns, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

-- Other

TwitchRedeemTemplates.twitch_redeem_loot_rat = {
    key = "loot rat",
    text = "loot rat",
    on_success = function(is_server, optional_data)
        if is_server then
            local breed = Breeds.skaven_loot_rat
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_shadow_lieutenant = {
    key = "shadow lieutenant",
    text = "shadow lieutenant",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "shadow_lieutenant", amount = 3 },
            }
            optional_data = {
                max_health_modifier = 3.0
            }
            spawn_custom_horde(spawns, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_beastmen_archers = {
    key = "beastmen archers",
    text = "an army of archers",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "beastmen_ungor_archer", amount = 25 },
            }
            spawn_custom_horde(spawns)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_bomb_rats = {
    key = "bomb rats",
    text = "some running ammo crates",
    on_success = function(is_server, optional_data)
        if is_server then
            local spawns = {
                { breed = "skaven_explosive_loot_rat", amount = 5 },
            }
            spawn_custom_horde(spawns)
            play_sound("enemy_grudge_cursed_enter")
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

TwitchRedeemTemplates.twitch_redeem_rat_ogre = {
    key = "rat ogre",
    text = "rat ogre",
    on_success = function(is_server, optional_data)
        if is_server then
            optional_data.max_health_modifier = 0.85
            local breed = Breeds.skaven_rat_ogre
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_skaven_stormfiend = {
    key = "stormfiend",
    text = "stormfiend",
    on_success = function(is_server, optional_data)
        if is_server then
            optional_data.max_health_modifier = 0.85
            local breed = Breeds.skaven_stormfiend
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_chaos_troll = {
    key = "chaos troll",
    text = "chaos troll",
    on_success = function(is_server, optional_data)
        if is_server then
            optional_data.max_health_modifier = 0.85
            local breed = Breeds.chaos_troll
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_chaos_spawn = {
    key = "chaos spawn",
    text = "chaos spawn",
    on_success = function(is_server, optional_data)
        if is_server then
            optional_data.max_health_modifier = 0.85
            local breed = Breeds.chaos_spawn
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

TwitchRedeemTemplates.twitch_redeem_beastmen_minotaur = {
    key = "minotaur",
    text = "big cow",
    on_success = function(is_server, optional_data)
        if is_server then
            optional_data.max_health_modifier = 0.85
            local breed = Breeds.beastmen_minotaur
            Managers.state.conflict:spawn_one(breed, nil, nil, optional_data)
            play_sound("enemy_grudge_cursed_enter")
        end
    end 
}

-- [beastmen_ungor_dummy]
-- [skaven_storm_vermin_commander]
-- [beastmen_ungor_archer]
-- [chaos_warrior]
-- [skaven_grey_seer]
-- [beastmen_ungor]
-- [beastmen_gor_dummy]
-- [chaos_marauder_with_shield]
-- [chaos_exalted_champion_warcamp]
-- [beastmen_bestigor_dummy]
-- [skaven_storm_vermin_with_shield]
-- [beastmen_gor]
-- [skaven_stormfiend_boss]
-- [chaos_corruptor_sorcerer]
-- [chaos_zombie]
-- [chaos_dummy_exalted_sorcerer_drachenfels]
-- [skaven_rat_ogre]
-- [chaos_tentacle_sorcerer]
-- [chaos_exalted_sorcerer]
-- [skaven_stormfiend]
-- [skaven_clan_rat]
-- [skaven_slave]
-- [chaos_fanatic]
-- [beastmen_minotaur]
-- [chaos_dummy_sorcerer]
-- [skaven_gutter_runner]
-- [chaos_plague_wave_spawner]
-- [skaven_storm_vermin_warlord]
-- [beastmen_bestigor]
-- [chaos_raider]
-- [skaven_dummy_clan_rat]
-- [skaven_explosive_loot_rat]
-- [chaos_dummy_troll]
-- [chaos_spawn_exalted_champion_norsca]
-- [skaven_pack_master]
-- [chaos_mutator_sorcerer]
-- [chaos_marauder_tutorial]
-- [chaos_exalted_champion_norsca]
-- [skaven_dummy_slave]
-- [skaven_clan_rat_with_shield]
-- [shadow_totem]
-- [critter_nurgling]
-- [shadow_lieutenant]
-- [beastmen_standard_bearer]
-- [skaven_storm_vermin]
-- [chaos_vortex_sorcerer]
-- [chaos_exalted_sorcerer_drachenfels]
-- [chaos_greed_pinata]
-- [chaos_spawn]
-- [chaos_troll]
-- [critter_rat]
-- [chaos_vortex]
-- [skaven_loot_rat]
-- [skaven_stormfiend_demo]
-- [skaven_clan_rat_tutorial]
-- [chaos_tentacle]
-- [chaos_berzerker]
-- [critter_pig]
-- [skaven_plague_monk]
-- [chaos_marauder]
-- [shadow_skull]
-- [chaos_plague_sorcerer]
-- [curse_mutator_sorcerer]
-- [beastmen_standard_bearer_crater]
-- [skaven_poison_wind_globadier]
-- [skaven_warpfire_thrower]
-- [skaven_storm_vermin_champion]
-- [skaven_ratling_gunner]
-- [chaos_raider_tutorial]

local mod = get_mod("TwitchRedeems")

local function create_template_lookup(templates)
    local lookup_table = {}
    for key,template in pairs(templates) do
        lookup_table[template.key] = key
    end
    return lookup_table
end



--TwitchRedeemTemplates2 = TwitchRedeemTemplates2 or {}
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

TwitchRedeemTemplatesLookup = create_template_lookup(TwitchRedeemTemplates)

mod:dump(TwitchRedeemTemplates, "TwitchRedeemTemplates", 5)