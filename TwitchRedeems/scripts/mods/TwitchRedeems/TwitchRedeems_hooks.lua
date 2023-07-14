local mod = get_mod("TwitchRedeems")

local function fulfill_redeem(redemption)
  local redeem_index = mod.redeem_lookup[string.lower(redemption.title)]
  if redeem_index ~= nil then
    local redeem = mod.redeems[redeem_index]
    if redeem ~= nil then
      -- Hordes.
      for _, horde in ipairs(redeem.data.hordes) do
        mod:dump(horde, "horde", 3) -- TODO
      end
      -- Mutators.
      for _, mutator in ipairs(redeem.data.mutators) do
        mod:dump(mutator, "mutator", 3) -- TODO
      end
      -- Buffs.
      for _, buff in ipairs(redeem.data.buffs) do
        mod:dump(buff, "buff", 3) -- TODO
      end
    end
  end
end

-- This hook processes the redeems and applies them.
mod:hook_safe(TwitchManager, "update", function(self, dt, t)
    local is_server = Managers.state.network and Managers.state.network.is_server
    if is_server and mod.redeems_enabled and Managers.state.entity ~= nil then

        -- Setup buff which lets the enemy eyes glow purple.
        local buff_system = Managers.state.entity:system("buff_system")
        local optional_data = {}
        optional_data.spawned_func = function (unit, breed, optional_data)
            buff_system:add_buff(unit, "twitch_redeem_buff_eye_glow", unit)
        end

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

        -- TODO move to update
        -- if success then
        --   local msg = string.format("%s redeemed %s", data.user, data.title)
        --   if data.user_input ~= "" then
        --     msg = msg .. string.format("\n '%s'", data.user_input)
        --   end
        --   mod:echo(msg)
        -- else
        --   mod:error("Failed parsing redeem")
        -- end

        -- -- We process both user and global queue. 
        -- -- This makes sure all redeems are handled even when mode was switched.

        -- -- Process queues.
        -- for user_name, redeem_queue in pairs(mod.user_redeem_queues) do
        --     if redeem_queue ~= nil then
        --         redeem_queue:update(dt)
        --         mod.process_redeem_queue(redeem_queue, optional_data)

        --         if redeem_queue:empty() and not redeem_queue:is_on_cooldown() then
        --             users_to_remove:push_back(user_name)
        --         end
        --     end
        -- end

        -- while users_to_remove:size() > 0 do
        --     local user_name = users_to_remove:pop_first()
        --     mod.user_redeem_queues[user_name] = nil
        -- end

        -- -- Process global queue.
        -- mod.global_redeem_queue:update(dt)
        -- mod.process_redeem_queue(mod.global_redeem_queue, optional_data)
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


-- TODO del
--mod.test = nil

-- mod:hook_safe(OptionsView, "init", function(self, ingame_ui_context)
--     mod:echo("HOOKED")
--     mod.test = self
-- end)

-- mod:hook_safe(OptionsView, "update", function(self, dt)
--     mod:echo("HOOKED OptionsView update")
-- end)

-- mod:hook_safe(StateTitleScreenMainMenu, "update", function(self, dt, t)
--     mod:echo("HOOKED StateTitleScreenMainMenu")
-- end)

-- local function assigned(a, b)
-- 	if a == nil then
-- 		return b
-- 	else
-- 		return a
-- 	end
-- end

-- mod:hook(OptionsView, "cb_twitch_vote_time_saved_value", function(func, self, widget)
--     mod:echo("PLS HELP")
-- 	if not assigned(self.changed_user_settings.twitch_vote_time, Application.user_setting("twitch_vote_time")) then
-- 		local value = DefaultUserSettings.get("user_settings", "twitch_vote_time")
-- 	end

-- 	local options_values = widget.content.options_values
-- 	local selected_option = 1

-- 	for i = 1, #options_values, 1 do
-- 		if value == options_values[i] then
-- 			selected_option = i

-- 			break
-- 		end
-- 	end

-- 	widget.content.current_selection = selected_option
--     mod:echo(tostring(widget.content.current_selection))
-- end)
