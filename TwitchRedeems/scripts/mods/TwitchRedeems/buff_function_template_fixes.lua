local mod = get_mod("TwitchRedeems")

-- Exact copy of local functions from 'buff_function_template.lua'.
local function is_local(unit)
	local player = Managers.player:owner(unit)

	return player and not player.remote
end

local function is_bot(unit)
	local player = Managers.player:owner(unit)

	return player and player.bot_player
end

local function is_server()
	return Managers.state.network.is_server
end

local function is_husk(unit)
	local player = Managers.player:owner(unit)
	local is_husk = player and (player.remote or player.bot_player) or false

	return is_husk
end


function apply_buff_function_template_fixes()
  if not BuffFunctionTemplates then
    mod:error("BuffFunctionTemplates are nil")
    return
  end

  mod:info("Applying buff function template fixes")

  -- Fixed "rpc_create_explosion" missing parameters.
  BuffFunctionTemplates.functions["update_twitch_pulsating_waves"] = function (unit, buff, params, world)
    if is_server() and Unit.alive(unit) then
      local t = params.t

      if buff.next_pulse_t < t then
        local damage_source = "grenade_frag_01"
        local explosion_template = ExplosionTemplates.twitch_pulse_explosion
        local explosion_position = POSITION_LOOKUP[unit]

        DamageUtils.create_explosion(world, unit, explosion_position, Quaternion.identity(), explosion_template, 1, damage_source, true, false, unit, false)

        local attacker_unit_id = Managers.state.unit_storage:go_id(unit)
        local explosion_template_id = NetworkLookup.explosion_templates[explosion_template.name]
        local damage_source_id = NetworkLookup.damage_sources[damage_source]

        Managers.state.network.network_transmit:send_rpc_clients("rpc_create_explosion", attacker_unit_id, false, explosion_position, Quaternion.identity(), explosion_template_id, 1, damage_source_id, 0, false, attacker_unit_id)

        buff.next_pulse_t = t + 2
      end
    end
  end
end
