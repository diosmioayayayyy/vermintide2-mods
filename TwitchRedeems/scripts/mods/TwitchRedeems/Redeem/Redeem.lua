local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemHorde")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemUnit")

if not INCLUDE_GUARDS.REDEEM then
  INCLUDE_GUARDS.REDEEM = true

  -- Lua imgui
  -- https://github.dev/Aussiemon/Vermintide-2-Source-Code/blob/f972faa439fa02ff3e8ac3da449ee3ccf0bde43a/scripts/imgui/imgui.lua#L434

  Redeem = class(Redeem)

  Redeem.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      key                               = "",
      name                              = "New Redeem",
      desc                              = "",
      hordes                            = {},
      mutators                          = {},
      ignore_global_cooldown            = false,
      ignore_user_cooldown              = false,
      override_global_cooldown          = false,
      override_global_cooldown_duration = 5,
      override_user_cooldown            = false,
      override_user_cooldown_duration   = 5,
    }

    -- self.key  = ""
    -- self.name = "New Redeem"
    -- self.desc = ""
    -- self.hordes = {}
    -- self.mutators = {}
    -- self.ignore_global_cooldown = false
    -- self.ignore_user_cooldown = false
    -- self.override_global_cooldown = false
    -- self.override_global_cooldown_duration = 5
    -- self.override_user_cooldown = false
    -- self.override_user_cooldown_duration = 5

    -- Create classes from raw data.
    -- Loaded classes from disk don't have any methods. 
    -- Therefore we have to create new objects and initialize them with the raw values.
    if other then
      for key, value in pairs(other) do
        if key == "hordes" then
          for key, raw_horde in pairs(value) do
            local horde = RedeemHorde:new(raw_horde)
            self.data.hordes[key] = horde
          end
        else
          self.data[key] = other[key]
        end
      end
    end

    -- Gui variables.
    self.selected_horde = nil -- TODO HMMMMM
  end

  Redeem.num_hordes = function(self)
    return table.size(self.hordes)
  end

  Redeem.has_hordes = function(self)
    return self:num_hordes() > 0
  end

  Redeem.insert_horde = function(self, horde)
    table.insert(self.hordes, horde)
  end

  Redeem.new_horde = function(self)
    local horde = RedeemHorde:new()
    table.insert(self.data.hordes, horde)
    return horde
  end

  Redeem.toggle_gui_window = function(self)
    -- TODO code dedup
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  Redeem.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.name = Imgui.input_text("Name##" .. tostring(self), self.data.name)

      if Imgui.button("Redeem##" .. tostring(self)) then
        -- TODO
      end

      Imgui.separator()

      self.data.ignore_global_cooldown = Imgui.checkbox("Ignore Global Cooldown##" .. tostring(self),
        self.data.ignore_global_cooldown)

      if not self.data.ignore_global_cooldown then
        Imgui.same_line()
        self.data.override_global_cooldown = Imgui.checkbox("Override##global" .. tostring(self),
          self.data.override_global_cooldown)
        if self.data.override_global_cooldown then
          self.data.override_global_cooldown_duration = Imgui.input_int("Global Cooldown Duration",
            self.data.override_global_cooldown_duration)
        end
      end

      self.data.ignore_user_cooldown = Imgui.checkbox("Ignore User Cooldown  ##" .. tostring(self),
        self.data.ignore_user_cooldown)

      if not self.data.ignore_user_cooldown then
        Imgui.same_line()
        self.data.override_user_cooldown = Imgui.checkbox("Override##User" .. tostring(self),
          self.data.override_user_cooldown)
        if self.data.override_user_cooldown_duration then
          self.data.override_user_cooldown_duration = Imgui.input_int("User Cooldown Duration",
            self.data.override_user_cooldown_duration)
        end
      end

      Imgui.separator()

      Imgui.text("Enemies")
      Imgui.same_line()
      if Imgui.button("+##AddHorde") then
        self:new_horde()
      end

      local horde_to_delete = nil
      for key, horde in pairs(self.data.hordes) do
        if Imgui.button(horde.data.name .. "##" .. key) then
          mod.selected_horde = key
        end

        horde:render_ui()

        Imgui.same_line()
        if Imgui.button("[x]##" .. key) then
          horde_to_delete = key
        end
      end

      Imgui.separator()

      Imgui.text("Mutators")

      Imgui.separator()

      Imgui.text("Buffs")

      -- Delete horde.
      if horde_to_delete then
        table.remove(self.data.hordes, horde_to_delete)
      end

      self.imgui_window:end_window()
    end
    return window_open
  end
end
