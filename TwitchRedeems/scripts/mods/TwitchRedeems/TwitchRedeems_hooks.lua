local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/RedeemFunctions")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")

local function fulfill_redeem(redemption)
  local redeem_index = mod.redeem_lookup[string.lower(redemption.title)]
  if redeem_index ~= nil then
    local redeem = mod.redeems[redeem_index]
    redeem:redeem()
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
            mod:echo(msg)
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

mod:hook_safe(HordeSpawner, "execute_vector_blob_horde", function(self, extra_data, side_id, fallback)
  if extra_data.twitch_redeem_horde == true then
    mod:info("Twitch Redeem Vector Blob Horde is spawning")
    add_twitch_redeems_eye_glow_buff_to_horde(self.hordes) -- TODO NOT WORKING. optional_data is not used in vector blob hordes
  end
end)

mod:hook_safe(HordeSpawner, "execute_ambush_horde", function(self, extra_data, side_id, fallback, override_epicenter_pos, optional_data)
  if extra_data.twitch_redeem_horde == true then
    mod:info("Twitch Redeem Ambush Horde is spawning")
    add_twitch_redeems_eye_glow_buff_to_horde(self.hordes)
  end
end)
