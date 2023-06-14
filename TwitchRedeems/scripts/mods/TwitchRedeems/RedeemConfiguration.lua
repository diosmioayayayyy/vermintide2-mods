local mod = get_mod("TwitchRedeems")
mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")

RedeemConfiguration = class(RedeemConfiguration)

RedeemConfiguration.init = function (self)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = "Redeem Configuration"
    self.imgui_window.key = self

    self:load_settings()
end

RedeemConfiguration.is_window_open = function (self)
    return self.imgui_window.show_window
end

RedeemConfiguration.save_settings = function (self)
    -- TODO save redeems here
end

RedeemConfiguration.load_settings = function (self)
    -- TODO load redeems here
end

RedeemConfiguration.toggle_gui_window = function (self)
    self.imgui_window.show_window = not self.imgui_window.show_window
end

-- TODO JUST A TEST
RedeemConfiguration._cb_redeem = function (self, success, return_code, headers, data, userdata)
    mod:echo("XDDBABY i got a message")
    mod:echo(tostring(success))
    mod:echo(tostring(return_code))
end

RedeemConfiguration.render_ui = function (self)
    local window_open = self.imgui_window:begin_window() -- TODO code dedup
    if window_open then
        -- TODO WT clean up cursor and mouse code
        local w, h = Application.resolution()
        local mouse_position = Vector3(0, h, 0) - Vector3.multiply_elements(Mouse.axis(Mouse.axis_id("cursor")), Vector3(-1, 1, 0))

        local app_window_x, app_window_y = Window.position()
        --Imgui.text("WINDOW POS: " .. app_window_x .. " " .. app_window_y) -- TODO DEL

        --local imgui_window_x, imgui_window_y = Imgui.get_window_pos()
        --Imgui.text("ImguiWindowpos: " .. imgui_window_x .. " " .. imgui_window_y) -- TODO DEL

        --local test = { 1,2,3,4,5,6,7,8,2,3,4,2,4,5,4,3,3} -- TODO DEL
        --mod.index = mod.index or 1
        --mod.index = Imgui.combo("Path", mod.index, test, 10)


        if Imgui.button("Add Redeem Config") then
            Imgui.open_popup("register_point_popup")
        end

        Imgui.same_line()

        if Imgui.button("Delete Redeem Config") then
            Imgui.open_popup("register_point_popup")
        end

        Imgui.separator()

        if Imgui.button("Twitch") then
            mod.settings_twitch:toggle_gui_window()
        end

        Imgui.same_line()

        if Imgui.button("Settings") then
            mod.settings_redeems:toggle_gui_window()
        end

        Imgui.same_line()

        if Imgui.button("Breed Editor") then
            mod.breed_editor:toggle_gui_window()
        end

        Imgui.separator()

        -- Create new redeem.
        if Imgui.button("New Redeem") then
            local new_redeem = Redeem:new()
            table.insert(mod.redeems, new_redeem)
            mod:dump(mod.redeems, "mod.redeems", 1)
        end

        Imgui.same_line()

        if Imgui.button("Clear Redeems") then
            Imgui.open_popup("popup_delete_redeems")
        end

        if Imgui.button("Save Redeems") then
            mod.store_twitch_redeems_to_file()
        end

        Imgui.same_line()

        if Imgui.button("Load Redeems") then
            mod.load_twitch_redeems_from_file()
        end

        Imgui.separator()

        -- TODO do we keep that?
        -- if Imgui.button("Sort by name") then
        --     table.sort(mod.redeems, function(a, b) return a.data.name < b.data.name end)
        -- end

        -- Render redeem list.
        Imgui.text("Redeems:")

        local item_cursor_table = {}
        for key, redeem in pairs(mod.redeems) do

            local _, y = Imgui.get_cursor_screen_pos()
            local cursor_y = y - app_window_y

            table.insert(item_cursor_table, cursor_y)

            if Imgui.button(redeem.data.name .. "##" .. key) then
                redeem:toggle_gui_window()
            end

            if (Imgui.is_item_hovered()) then
                Imgui.same_line()
                if (not mod.drag_key and Mouse.button(Mouse.button_index("left")) == 1) then
                    mod.drag_key = key
                    Imgui.same_line()
                end
            end

            Imgui.same_line()

            if Imgui.button("[x]##" .. key) then
                Imgui.open_popup("popup_delete_redeem")
                mod.redeem_key_to_delete = key -- TODO not mod.
            end
        end

        if Imgui.button("Pool Redeem") then
            local api_url = "http://localhost:8000/pop-redeem"
            local url = api_url
            Managers.curl:get(url, {}, function(success, response_code, headers, data, userdata)
                if data == "Unkown request" then
                    mod:error("Pop Redeem: Unkown request")
                else
                    local dataJson = cjson.decode(data)
                    mod:echo(dataJson.name)
                    mod:dump(dataJson, "dataJson", 1)
                end
            end)
        end

        if Imgui.button("Map Start") then
            local api_url = "http://localhost:8000/map_start"
            local url = api_url
            Managers.curl:get(url, {}, function(success, response_code, headers, data, userdata)
            print(data)
            end)
        end

        if Imgui.button("Map End") then
            local api_url = "http://localhost:8000/map_end"
            local url = api_url
            Managers.curl:get(url, {}, function(success, response_code, headers, data, userdata)
            print(data)
            end)
        end

        if Imgui.button("Create Redeems") then
            local api_url = "http://localhost:8000/redeems?action=create"
            local url = api_url

            local l = {}
            local r = {}
            r = { title="TEST1", cost="1" }
            table.insert(l, r)
            r = { title="TEST2", cost="1" }
            table.insert(l, r)
            r = { title="TEST3", cost="1" }
            table.insert(l, r)
            local json_payload = cjson.encode(l)

            Managers.curl:post(url, json_payload, {}, function(success, response_code, headers, data, userdata)
                print(data)
            end)
        end

        if Imgui.button("Delete Redeems") then
            local api_url = "http://localhost:8000/redeems?action=delete"
            local url = api_url
            Managers.curl:delete(url, nil, nil, function(success, response_code, headers, data, userdata)
                print(data)
            end)
        end

        Imgui.separator()

        -- Drag redeem.
        -- TODO this stuff should be a reusable class...
        if mod.drag_key then
            for i = 1, #item_cursor_table do
                local min = item_cursor_table[i]
                local max = item_cursor_table[i + 1]
                if mouse_position.y > min and (max == nil or mouse_position.y < max) then
                    local swap = mod.redeems[i]
                    mod.redeems[i] = mod.redeems[mod.drag_key]
                    mod.redeems[mod.drag_key] = swap
                    mod.drag_key = i
                    break
                end
            end
        end

        -- Reset drag key when button is released.
        if (Mouse.button(Mouse.button_index("left")) == 0) then
            mod.drag_key = nil
        end

        -- Redeem delete popup.
        if Imgui.begin_popup("popup_delete_redeem") then

            mod:echo(mod.redeem_key_to_delete)
            mod:dump(mod.redeems, "mod.redeems", 1)

            Imgui.text("Do you really want to delete the redeem '" .. mod.redeems[mod.redeem_key_to_delete].data.name .. "'?")

            if Imgui.button("Delete") then
                Imgui.close_current_popup()
                table.remove(mod.redeems, mod.redeem_key_to_delete)
            end

            Imgui.same_line()
            if Imgui.button("Cancel") then
                Imgui.close_current_popup()
            end

            if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) then
                Imgui.close_current_popup()
            end

            Imgui.end_popup()
        end

        if Imgui.begin_popup("popup_delete_redeems") then
            Imgui.text("Do you really want to delete all redeems?")

            if Imgui.button("Delete") then
                Imgui.close_current_popup()
                mod.redeems = {}
            end

            Imgui.same_line()
            if Imgui.button("Cancel") then
                Imgui.close_current_popup()
            end

            if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) then
                Imgui.close_current_popup()
            end
            Imgui.end_popup()
        end

                -- TODO WT create redeem list array and call somewhere else
                -- -- Render redeem windows.
                -- for key, redeem in pairs(mod.redeems) do
                --     if redeem.show_window then
                --         if is_mouse_inside_app_window() then
                --             -- TODO refactor
                --             if redeem.window_restrained_direction.x < 0 then
                --                 if mouse_position.x > redeem.window_restrained_mouse_position.x then
                --                     redeem.window_restrained_direction.x = 0
                --                 end
                --             elseif redeem.window_restrained_direction.x > 0 then
                --                 if mouse_position.x < redeem.window_restrained_mouse_position.x then
                --                     redeem.window_restrained_direction.x = 0
                --                 end
                --             end

                --             if redeem.window_restrained_direction.y < 0 then
                --                 if mouse_position.y > redeem.window_restrained_mouse_position.y then
                --                     redeem.window_restrained_direction.y = 0
                --                 end
                --             elseif redeem.window_restrained_direction.y > 0 then
                --                 if mouse_position.y < redeem.window_restrained_mouse_position.y then
                --                     redeem.window_restrained_direction.y = 0
                --                 end
                --             end
                --         end

                --         if redeem.window_restrained_direction.x ~= 0 or redeem.window_restrained_direction.y ~= 0 or not is_mouse_inside_app_window() then
                --             Imgui.set_next_window_pos(redeem.window_position.x, redeem.window_position.y)
                --         else
                --             redeem.window_is_restrained = false
                --         end

                --         local close_window = Imgui.begin_window(redeem.name .. "###" .. key, "always_auto_resize")

                --         redeem:render_ui()

                --         -- Close window on right click.
                --         if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) or close_window then
                --             redeem.show_window = false
                --         end

                --         local restrained
                --         redeem.window_position, restrained = constrain_imgui_window_to_app_window()
                --         if restrained then
                --             if not redeem.window_is_restrained then
                --                 redeem.window_restrained_mouse_position = Vector3Box(mouse_position)

                --                 local ix, iy = Imgui.get_window_pos()
                --                 redeem.window_restrained_direction.x = sign(ix - redeem.window_position.x)
                --                 redeem.window_restrained_direction.y = sign(iy - redeem.window_position.y)
                --             end
                --             redeem.window_is_restrained = true
                --         end

                --         Imgui.end_window()
                --     end
                -- end

        self.imgui_window:end_window()
    end
    return window_open
end