local mod = get_mod("TwitchRedeems")

-- This hook processes the redeems and applies them.
mod:hook_safe(TwitchManager, "update", function(self, dt, t)
    local is_server = Managers.state.network and Managers.state.network.is_server
    if is_server and Managers.state.entity ~= nil then

        -- Setup buff which lets the enemy eyes glow purple.
        local buff_system = Managers.state.entity:system("buff_system")
        local optional_data = {}
        optional_data.spawned_func = function (unit, breed, optional_data)
            buff_system:add_buff(unit, "twitch_redeem_buff_eye_glow", unit)
        end

        -- User to remove. Used to clean up user redeem queues.
        local users_to_remove = GrowQueue:new()

        -- We process both user and global queue. 
        -- This makes sure all redeems are handled even when mode was switched.

        -- Process queues.
        for user_name, redeem_queue in pairs(mod.user_redeem_queues) do
            if redeem_queue ~= nil then
                redeem_queue:update(dt)
                mod.process_redeem_queue(redeem_queue, optional_data)

                if redeem_queue:empty() and not redeem_queue:is_on_cooldown() then
                    users_to_remove:push_back(user_name)
                end
            end
        end

        while users_to_remove:size() > 0 do
            local user_name = users_to_remove:pop_first()
            mod.user_redeem_queues[user_name] = nil
        end

        -- Process global queue.
        mod.global_redeem_queue:update(dt)
        mod.process_redeem_queue(mod.global_redeem_queue, optional_data)
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