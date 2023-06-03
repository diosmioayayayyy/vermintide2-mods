local mod = get_mod("SetPresence")

mod.SETTING_ID_PRESENCE_TEXT = "PRESENCE_TEXT"

mod.on_all_mods_loaded = function()
    Managers.account:update_presence()
end

mod.on_enabled = function(initial_call)
    Managers.account:update_presence()
end

mod.on_disabled = function(initial_call)
    Managers.account:update_presence()
end

mod:hook(AccountManager, "update_presence", function(func, self)
    local presence_text = mod:get(mod.SETTING_ID_PRESENCE_TEXT)
    if presence_text == nil then
        mod:warning("\nNo custom presence text specified.\nUsing default presence.\nUse /presence_set_text [TEXT] to specifiy presence text.")
        func(self)
    else
        -- Apply custom presence text.
        mod:info("Custom presence text is '" .. presence_text .. "'")
        Presence.set_presence("steam_display", "#presence_modded_custom")
        Presence.set_presence("custom_presence_string", presence_text)
    end
end)

mod:command("presence_set_text", "Set presence", function(...)
    -- Concatenate command parameters to presence text.
    local new_presence_text = nil
    for _, txt in pairs({...}) do
        if new_presence_text == nil then
            new_presence_text = txt
        else
            new_presence_text = new_presence_text .. " " .. txt
        end
    end

    -- Store new presence text.
    if new_presence_text ~= nil then
        mod:echo("New present text is '" .. new_presence_text .. "'")
        mod:set(mod.SETTING_ID_PRESENCE_TEXT, new_presence_text)
        Managers.account:update_presence()
    else
        mod:error("No presence text supplied")
    end
end)
