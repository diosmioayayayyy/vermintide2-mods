local mod = get_mod("TwitchRedeems")
local definitions = mod:dofile("scripts/mods/TwitchRedeems/Gui/twitch_redeem_ui_definitions")

mod:dofile("scripts/mods/TwitchRedeems/Utils/Timer")

TwitchRedeemUI = class(TwitchRedeemUI)

TwitchRedeemUI.init = function(self, ingame_ui_context)
  self._ui_renderer = ingame_ui_context.ui_renderer
  self._ingame_ui = ingame_ui_context.ingame_ui
  self._input_manager = ingame_ui_context.input_manager
  self._world_manager = ingame_ui_context.world_manager
  self.active = false
  self._active_redeem = nil
  self._timer = Timer2:new(3)
  self._render_settings = {
    alpha_multiplier = 1
  }
  local world = self._world_manager:world("level_world")
  self.wwise_world = Managers.world:wwise_world(world)

  self:_create_elements()
  Managers.state.event:register(self, "twitch_redeem_ui", "event_twitch_redeem_ui")
end

TwitchRedeemUI.update_ui_settings = function(self)
  if self._ui_scenegraph then
    --mod:dump(self._ui_scenegraph, "self._ui_scenegraph", 5) --TODO to lookup table stuff
    self._ui_scenegraph.base_area.position[1] = mod:get("twitch_redemption_ui_offset_x")
    self._ui_scenegraph.base_area.position[2] = mod:get("twitch_redemption_ui_offset_y")
    self._timer.duration = mod:get("twitch_redemption_ui_duration")
  end
end

TwitchRedeemUI.event_twitch_redeem_ui = function(self, redeem)
  if not redeem then
    return
  end

  self:start_twitch_redeem_event(redeem)
end

TwitchRedeemUI.start_twitch_redeem_event = function(self, redeem)
  self.active = true
  self._active_redeem = table.clone(redeem)
  self._timer:start()
  self:show_ui("twitch_redemption")
end

TwitchRedeemUI._create_elements = function(self)
  local scenegraph_definition = definitions.scenegraph_definition
  self._ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
  self:update_ui_settings()
  self._widgets = {}
  UIRenderer.clear_scenegraph_queue(self._ui_renderer)
end

local customizer_data = {
  root_scenegraph_id = "pivot",
  label = "Twitch",
  registry_key = "twitch",
  drag_scenegraph_id = "pivot_dragger"
}

TwitchRedeemUI.update = function(self, dt, t)
  HudCustomizer.run(self._ui_renderer, self._ui_scenegraph, customizer_data)

  local timer_expired = self._timer:update(dt)

  if timer_expired then
    self:hide_ui()
  end

  if not self.active then
    return
  end

  self:_update_transition(dt)
  self:_draw(dt, t)

  local ui = self._ui

  if ui == "twitch_redemption" then
    self:_update_twitch_redemption(dt)
  end
end

TwitchRedeemUI._draw = function(self, dt, t)
  local ui_renderer = self._ui_renderer
  local ui_scenegraph = self._ui_scenegraph
  local input_service = self._input_manager:get_service("ingame_menu")
  local render_settings = self._render_settings

  UIRenderer.begin_pass(ui_renderer, ui_scenegraph, input_service, dt, nil, render_settings)

  local ui = self._ui

  if ui then
    for _, widget in pairs(self._widgets) do
      UIRenderer.draw_widget(ui_renderer, widget)
    end
  end

  UIRenderer.end_pass(ui_renderer)
end

TwitchRedeemUI.destroy = function(self)
  Managers.state.event:unregister("twitch_redeem_ui", self)
end

TwitchRedeemUI._update_transition = function(self, dt)
  local fade_out = self._fade_out

  if fade_out then
    local fade_out_speed = 1
    local render_settings = self._render_settings
    local alpha_multiplier = math.clamp(render_settings.alpha_multiplier - dt * fade_out_speed, 0, 1)
    render_settings.alpha_multiplier = alpha_multiplier

    if alpha_multiplier == 0 then
      self._ui = nil
      self._fade_out = nil

      if self._next_ui then
        self:_show_next_ui()
      else
        self.active = false
      end
    end

    return
  end

  local fade_in = self._fade_in

  if fade_in then
    local fade_in_speed = 5
    local render_settings = self._render_settings
    local alpha_multiplier = math.clamp(render_settings.alpha_multiplier + dt * fade_in_speed, 0, 1)
    render_settings.alpha_multiplier = alpha_multiplier

    if alpha_multiplier == 1 then
      self._fade_in = nil
    end

    return
  end
end

TwitchRedeemUI.show_ui = function(self, ui)
  self._next_ui = ui

  if self._ui then
    self._fade_out = true
  else
    self:_show_next_ui()
  end
end

TwitchRedeemUI.hide_ui = function(self)
  self._fade_out = true
end

TwitchRedeemUI._show_next_ui = function(self)
  local ui = self._next_ui

  if ui == "twitch_redemption" then
    self:_show_twitch_redemption()
  end

  self._ui = ui
  self._fade_in = true
  self._next_ui = nil
end

TwitchRedeemUI._show_twitch_redemption = function(self)
  local active_vote = self._active_redeem

  if not active_vote then
    return
  end

  self._widgets = {}
  local widgets = definitions.widgets.standard_vote  -- TODO

  for widget_name, widget_data in pairs(widgets) do
    self._widgets[widget_name] = UIWidget.init(widget_data)
  end

  local timer_widget = self._widgets.timer

  if not timer_widget then
    table.dump(self._widgets, "### TWITCH REDEEM UI CRASH INFO ###", 3)
    return
  end

  timer_widget.content.text = self._active_redeem.title
  self._widgets.text_redeemed_by.content.text = "redeemed by"
  self._widgets.vote_text_a.content.text = self._active_redeem.user
  if self._active_redeem.user_color then
    self._widgets.vote_text_a.style.text.text_color = to_rgb_color(self._active_redeem.user_color)
  end

  self:_play_standard_vote_start()  -- TODO does this work?
end

TwitchRedeemUI._update_twitch_redemption = function(self, dt)
  local active_vote = self._active_redeem

  if not active_vote then
    return
  end
end

TwitchRedeemUI._play_standard_vote_start = function(self)
  WwiseWorld.trigger_event(self.wwise_world, "enemy_grudge_cursed_enter")
end
