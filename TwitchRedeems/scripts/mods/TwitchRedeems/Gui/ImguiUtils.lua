local mod = get_mod("TwitchRedeems")

if not INCLUDE_GUARDS.IMGUI_UTILS then
  INCLUDE_GUARDS.IMGUI_UTILS = true

  if ShowCursorStack.cursor_active() then
    ShowCursorStack.pop() -- fixes stuck cursor on mod reload.
  end

  function enable_gui_control()
    local input_manager = Managers.input
    local input_service_name = "twitch_redeem_view"
    input_manager:block_device_except_service(input_service_name, "keyboard")
    input_manager:block_device_except_service(input_service_name, "mouse")
    input_manager:block_device_except_service(input_service_name, "gamepad")
    ShowCursorStack.push()
    Imgui.open_imgui()
    Imgui.enable_imgui_input_system(Imgui.KEYBOARD)
    Imgui.enable_imgui_input_system(Imgui.MOUSE)
    --Window.set_mouse_focus(false)r1.
  end

  function disable_gui_control()
    local input_manager = Managers.input
    input_manager:device_unblock_all_services("keyboard")
    input_manager:device_unblock_all_services("mouse")
    input_manager:device_unblock_all_services("gamepad")
    ShowCursorStack.pop()
    Window.set_mouse_focus(true)
    Imgui.disable_imgui_input_system(Imgui.KEYBOARD)
    Imgui.disable_imgui_input_system(Imgui.MOUSE)
    Imgui.close_imgui()
  end

  function constrain_imgui_window_to_app_window()
    local aw, ah = Application.resolution()
    local ax, ay = Window.position()
    local ix, iy = Imgui.get_window_pos()
    local iw, ih = Imgui.get_window_size()

    local imgui_rect = Rectangle:new(ix, iy, iw, ih)
    local safety_border = 100 -- Pixel
    local app_rect = Rectangle:new(ax + safety_border, ay + safety_border, aw - 2 * safety_border, ah - 2 * safety_border)

    if not app_rect:contains_rect(imgui_rect) then
      imgui_rect:restrain(app_rect)
    end

    local got_restrained = (ix ~= imgui_rect.x or iy ~= imgui_rect.y)
    return Vector3Box(imgui_rect.x, imgui_rect.y, 0), got_restrained -- TODO make Vector3
  end

  function get_mouse_cursor_position()
    -- TODO screen or window coord?
    local _, h = Application.resolution()
    return Vector3(0, h, 0) - Vector3.multiply_elements(Mouse.axis(Mouse.axis_id("cursor")), Vector3(-1, 1, 0))
  end

  function is_mouse_inside_app_window()
    local aw, ah = Application.resolution()
    local app_rect = Rectangle:new(0, 0, aw, ah)
    return app_rect:contains_point(Mouse.axis(Mouse.axis_id("cursor")))
  end
end
