local mod = get_mod("TwitchRedeems")

local Vector2Box = stingray.Vector2Box

mod:dofile("scripts/mods/TwitchRedeems/Redeem/Redeem")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")
mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiUtils")
--mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")

--TwitchRedeemsUI = class(TwitchRedeemsUI)
--
--TwitchRedeemsUI.init = function (self)
--end
--
--TwitchRedeemsUI.render_ui = function (self)
--end

mod.show_redeem_configurator_ui = false
mod.redeem_key_to_delete = nil

mod.test = false -- TODO HUH
mod.drag_key = nil

-- local function get_mouse_position()
--     local aw, ah = Application.resolution()
--     return Mouse.axis(Mouse.axis_id("cursor"))
--     return Vector3.min(Vector3.max(Vector3(0, 0, 0), cursor_position), Vector3(aw, ah, 0))
--     -- Vector3.min(Vector3.max(velocity, vel_min_v3), vel_max_v3)
-- end

mod.render_ui = function(dt)
    -- Render windows.
    local any_window_open = false
    if mod.redeem_configuration:render_ui() then any_window_open = true end
    if mod.settings_twitch:render_ui()      then any_window_open = true end
    if mod.settings_redeems:render_ui()     then any_window_open = true end

    -- Hide windows if config window is not open.
    if mod.redeem_configuration:is_window_open() then
        if mod.breed_editor:render_ui() then any_window_open = true end

        for _, redeem in ipairs(mod.redeems) do
            if redeem:render_ui() then any_window_open = true end
        end
    end

    -- Enable/Disable gui control.
    if any_window_open and not mod.gui_control then
        enable_gui_control()
        Managers.chat:enable_gui(false)
        mod.gui_control = true
    elseif not any_window_open and mod.gui_control then
        disable_gui_control()
        Managers.chat:enable_gui(true)
        mod.gui_control = false
    end
end
