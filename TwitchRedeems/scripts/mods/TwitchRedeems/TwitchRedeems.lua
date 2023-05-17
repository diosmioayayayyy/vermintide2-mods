local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_templates")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_redeem_queue")

local in_modded_realm = script_data["eac-untrusted"]
local Managers = Managers
local TwitchRedeemTemplates = TwitchRedeemTemplates

-- Enemies spawned with Twitch redeems will have purple glowing eyes.
mod.add_buff_template("twitch_redeem_buff_eye_glow",
{
    remove_buff_func = "belakor_cultists_remove_eye_glow",
    name = "belakor_cultists_buff_eye_glow",
    apply_buff_func = "belakor_cultists_apply_eye_glow"
}, nil, 1900)

-- Load purple eye material.
Managers.package:load("resource_packages/levels/dlcs/morris/belakor_common", "global")

mod.redeem_twitch_user_name = nil
mod.redeems_enabled = false

mod.global_redeem_queue = RedeemQueue:new()
mod.user_redeem_queues = {}

mod.SETTING_ID_TWITCH_REDEEM_USER = "TWITCH_REDEEM_USER"

local function cb_twitch_chat_message(key, message_type, user_name, message, parameter)
    local is_redeem_bot = (string.lower(user_name) == string.lower(mod.redeem_twitch_user_name))
    if mod.redeems_enabled and is_redeem_bot then
        -- Returns the text between two ":" and ";"
        local redeem_key = string.match(message, ':([^:]+)')
        local redeem_user = string.match(message, '-([^-]+)')
        local redeem_param = string.match(message, '|([^|]+)')

        -- If we get a valid redeem key we add it to the redeem queue which will be handled later on.
        if redeem_key ~= nil then
            local redeem = {}
            redeem.key = string.lower(redeem_key)
            redeem.param = redeem_param
            redeem.user = redeem_user

            if mod.user_redeem_cooldown then
                if mod.user_redeem_queues[redeem.user] == nil then
                    mod.user_redeem_queues[redeem.user] = RedeemQueue:new()
                    mod.user_redeem_queues[redeem.user]:set_cooldown(mod.user_cooldown_duration)
                end
                mod.user_redeem_queues[redeem.user]:push(redeem)
            else
                mod.global_redeem_queue:push(redeem)
            end

            --mod.redeem_queue:push_back(redeem)
            print("Added to queue: " .. user_name .. " : " .. message)
        end
    end
end

local function cmd_connect_to_twitch_chat()
    mod.enable_redeems(not mod.redeems_enabled)
end

local function cmd_enable_twitch_votes()
    -- TODO check if connect to any channel
    Managers.twitch:activate_twitch_game_mode(Managers.state.game_mode.network_event_delegate, "adventure")
end

local function cmd_disable_twitch_votes()
    Managers.twitch:deactivate_twitch_game_mode()
end

local function cmd_twitch_name(new_twitch_name)
    mod.redeem_twitch_user_name = mod:get(mod.SETTING_ID_TWITCH_REDEEM_USER)

    if new_twitch_name == nil then    
        mod:echo("Current twitch name: " .. mod.redeem_twitch_user_name)
    else
        mod.redeem_twitch_user_name = new_twitch_name
        mod:set(mod.SETTING_ID_TWITCH_REDEEM_USER, new_twitch_name)
        mod:echo("Twitch redeem name set to '" .. mod.redeem_twitch_user_name .. "'")
    end
end

local function cmd_trigger_twitch_redeem(redeem_key)
    print(table.random_elem(TwitchRedeemTemplates))
    local user = "TestUser"
    local msg = "this is a test xdd"
    local key = nil

    if redeem_key ~= nil then
        local lookup_key = TwitchRedeemTemplatesLookup[redeem_key]
        if lookup_key then
            key = TwitchRedeemTemplates[lookup_key].key
        else
            mod:error("invalid redeem key '" .. redeem_key .. "'")
        end
    else
        key = table.random_elem(TwitchRedeemTemplates).key
    end

    if key ~= nil then
        local redeem_str = string.format("-%s- redeemed :%s: | %s |", user, key, msg)
        cb_twitch_chat_message(nil, nil, mod.redeem_twitch_user_name, redeem_str)
    end
end

if in_modded_realm then
    mod:command("twitch_redeems", "Toogle twitch redeems", cmd_connect_to_twitch_chat)
    mod:command("twitch_votes_start", "Enable twitch votes", cmd_enable_twitch_votes)
    mod:command("twitch_votes_end", "Disable twitch votes", cmd_disable_twitch_votes)
    mod:command("twitch_redeem_trigger", "Trigger twitch redeem", cmd_trigger_twitch_redeem)
end

mod:command("twitch_redeem_name", "Get/set twitch redeem bot name", cmd_twitch_name)

mod.on_all_mods_loaded = function(status, state_name)
    -- Load settings.
    mod.apply_settings()
    mod.redeem_twitch_user_name = mod:get(mod.SETTING_ID_TWITCH_REDEEM_USER)

    if mod.redeem_twitch_user_name == nil then
        mod:warning("No twitch redeem user specified. Use command '/twitch_redeem_name [NAME]' to specify the twitch account.")
    else
        mod:echo("Twitch redeem name is '" .. mod.redeem_twitch_user_name .. "'")
    end

    local is_server = Managers.state.network and Managers.state.network.is_server
    if is_server then
        local is_in_inn_level = Managers.level_transition_handler:in_hub_level()
        mod.enable_redeems(not is_in_inn_level)
    end
end

mod.apply_settings = function()
    mod.user_redeem_cooldown = mod:get("user_redeem_cooldown")
    mod.user_cooldown_duration = mod:get("user_redeem_cooldown_duration")
    mod.global_cooldown_duration = mod:get("global_redeem_cooldown_duration")

    for _, redeem_queue in pairs(mod.user_redeem_queues) do
        redeem_queue:set_cooldown(mod.user_cooldown_duration)
    end

    mod.global_redeem_queue:set_cooldown(mod.global_cooldown_duration)
end

mod.on_setting_changed = function()
    mod.apply_settings()
end

mod.enable_redeems = function(enable)
    local is_server = Managers.state.network and Managers.state.network.is_server
    if is_server and mod.redeems_enabled ~= enable then
        mod.redeems_enabled = enable
        mod:echo("Twitch redeems are " .. (enable and "ON" or "OFF"))
        mod.reset_redeem_queues()

        if enable then
            Managers.irc:register_message_callback("TwitchChat", Irc.CHANNEL_MSG, callback(cb_twitch_chat_message))
            mod:echo("Connected to twitch chat")
        else
            Managers.irc:unregister_message_callback("TwitchChat")
            mod:echo("Disconnected from twitch chat")
        end
    end
end

mod.reset_redeem_queues = function()
    mod.user_redeem_queues = {}
    mod.global_redeem_queue = RedeemQueue:new()
    mod.global_redeem_queue:set_cooldown(mod.global_cooldown_duration)
end

mod.on_game_state_changed = function(status, state_name)
    local is_server = Managers.state.network and Managers.state.network.is_server

    if is_server then
        local is_in_inn_level = Managers.level_transition_handler:in_hub_level()

        if status == "exit" then
            mod.enable_redeems(false)
        elseif status == "enter" and not is_in_inn_level then
            mod.enable_redeems(true)
        end 
    end
end

local function process_redeem_queue(redeem_queue, optional_data)
    if redeem_queue ~= nil and redeem_queue:size() > 0 and not redeem_queue:is_on_cooldown() then
        local redeem = redeem_queue:pop()

        local lookup_key = TwitchRedeemTemplatesLookup[redeem.key]
        local redeem_template = TwitchRedeemTemplates[lookup_key]
        local is_server = Managers.state.network and Managers.state.network.is_server

        if lookup_key ~= nil then
            if redeem_template ~= nil then
                redeem_template.on_success(is_server, optional_data, redeem.param)
                -- TODO return boolean for success and add back to queue to try again later

                local msg = redeem.user .. " redeemed " .. redeem_template.text
                if redeem.param then
                    msg = msg .. '\n "'.. redeem.param .. '"'
                end
                mod:chat_broadcast(msg)

                --mod:echo("Queue size: " .. tostring(redeem_queue:size()))
            else
                mod:error("unknown redeem key '" .. redeem.key .."' with lookup key '" .. lookup_key .. "'")
            end
        else
            mod:error("redeem key not found")
        end
    end
end

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
                process_redeem_queue(redeem_queue, optional_data)

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
        process_redeem_queue(mod.global_redeem_queue, optional_data)
    end
end)
