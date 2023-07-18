local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")

if not INCLUDE_GUARDS.REDEEM_EVENT then
  INCLUDE_GUARDS.REDEEM_EVENT = true

  RedeemEvent = class(RedeemEvent)

  RedeemEvent.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      event_type = EventType.HORDE,
      name = GuiDropdownEvents[EventType.HORDE],
    }

    self.redeem = {}

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        self.data[key] = other[key]
      end
    end
  end

  RedeemEvent.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  RedeemEvent.serialize = function(self)
    local data = {}
    data.name = self.data.name
    data.event_type = self.data.event_type
    return data
  end

  RedeemEvent.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.event_type = Imgui.combo("Event", self.data.event_type, GuiDropdownEvents, 10)
      self.data.name = GuiDropdownEvents[self.data.event_type]

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemEvent.prepare = function(self)
  end

  RedeemEvent.apply = function(self)
    local conflict_director = Managers.state.conflict
    local side_id = conflict_director.default_enemy_side_id
    local horde_settings = CurrentHordeSettings

    local horde_type = nil

    if self.data.event_type == EventType.HORDE then
      horde_type = "vector"

    elseif self.data.event_type == EventType.HORDE_BLOB then
      horde_type = "vector_blob"

    elseif self.data.event_type == EventType.AMBUSH then
      horde_type = "ambush"

    elseif self.data.event_type == EventType.RANDOM_HORDE then
      local random_table = {
        "vector",
        "vector_blob",
        "ambush"
      }
      horde_type = random_table[math.random(1, #random_table)]
    end

    if horde_type ~= nil then
      spawn_redeem_horde(horde_type)
    end
  end
end
