local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiUtils")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")

if not INCLUDE_GUARDS.IMGUI_WINDOW then
  INCLUDE_GUARDS.IMGUI_WINDOW = true

  ImguiWindow = class(ImguiWindow)

  ImguiWindow.init = function(self, key)
    self.title = "New self"
    self.key = key -- TODO DEL ?

    -- Gui variables.
    self.show_window = false
    self.window_position = nil
    self.window_is_restrained = false
    self.window_restrained_mouse_position = Vector3Box(0, 0, 0)
    self.window_restrained_direction = Vector3Box(0, 0, 0)
  end

  ImguiWindow.restrain_window = function(self)
    local restrain_direction = function(restrain_dir, restrained_pos, mouse_pos)
      if restrain_dir < 0 then
        if mouse_pos > restrained_pos then
          restrain_dir = 0
        end
      elseif restrain_dir > 0 then
        if mouse_pos < restrained_pos then
          restrain_dir = 0
        end
      end
      return restrain_dir
    end

    local mouse_position = get_mouse_cursor_position()
    self.window_restrained_direction.x = restrain_direction(self.window_restrained_direction.x,
      self.window_restrained_mouse_position.x, mouse_position.x)
    self.window_restrained_direction.y = restrain_direction(self.window_restrained_direction.y,
      self.window_restrained_mouse_position.y, mouse_position.y)

    -- In case window is not dragged anymore simply remove restrain.
    if Mouse.button(Mouse.button_id("left")) == 0 then
      self.window_restrained_direction.x = 0
      self.window_restrained_direction.y = 0
    end
  end

  ImguiWindow.begin_window = function(self)
    local window_opened = false
    if self.show_window then
      -- Check if window still needs to be restrained in a certain direction.
      if is_mouse_inside_app_window() then
        self:restrain_window()
      end

      -- Set window position if we have to constrain it.
      if Vector3.any(self.window_restrained_direction) or not is_mouse_inside_app_window() then
        Imgui.set_next_window_pos(self.window_position.x, self.window_position.y)
      else
        self.window_is_restrained = false
      end

      if Imgui.begin_window(self.title .. "###" .. tostring(self), "always_auto_resize") then
        self.show_window = false
      end
      window_opened = true
    end

    return window_opened
  end

  ImguiWindow.end_window = function(self)
    -- Close window on right click.
    if Imgui.is_window_hovered() and Mouse.pressed(Mouse.button_id("right")) then
      self.show_window = false
    end

    local aw, ah = Application.resolution()
    local ax, ay = Window.position()
    local ix, iy = Imgui.get_window_pos()
    local iw, ih = Imgui.get_window_size()

    local imgui_rect = Rectangle:new(ix, iy, iw, ih)
    local safety_border = 75 -- In pixel
    local app_rect = Rectangle:new(ax + safety_border, ay + safety_border, aw - 2 * safety_border, ah - 2 * safety_border)

    if not app_rect:contains_rect(imgui_rect) then
      imgui_rect:restrain(app_rect)
    end

    self.window_position = Vector3Box(imgui_rect.x, imgui_rect.y, 0)

    -- Window got restrained, position does not match anymore.
    if (ix ~= imgui_rect.x or iy ~= imgui_rect.y) then
      -- If it's not already restrained then store the direction and position where it got restrained.
      if not self.window_is_restrained then
        self.window_restrained_mouse_position = Vector3Box(get_mouse_cursor_position())

        local ix, iy = Imgui.get_window_pos()
        self.window_restrained_direction.x = sign(ix - self.window_position.x)
        self.window_restrained_direction.y = sign(iy - self.window_position.y)
      end
      self.window_is_restrained = true
    end

    Imgui.end_window()
  end
end
