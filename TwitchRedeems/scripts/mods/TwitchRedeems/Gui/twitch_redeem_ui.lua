local mod = get_mod("TwitchRedeems")
local definitions = mod:dofile("scripts/mods/TwitchRedeems/Gui/twitch_redeem_ui_definitions")
local scenegraph_definition = definitions.scenegraph_definition
local definition_settings = definitions.settings
local vote_texts_definition = definitions.vote_texts

mod:echo("REDEEM UI")
--mod:dump(definitions, "definitions", 1)

-- local DEBUG_VOTE_UI = false
-- local RESULT_TIMER = 3
local INIT_AUDIO_COUNTDOWN_AT = 5
TwitchRedeemUI = class(TwitchRedeemUI)

TwitchRedeemUI.init = function (self, ingame_ui_context)
  mod:echo("INIT TwitchRedeemUI")
	--self._parent = parent
	self._ui_renderer = ingame_ui_context.ui_renderer
	self._ingame_ui = ingame_ui_context.ingame_ui
	self._input_manager = ingame_ui_context.input_manager
	self._world_manager = ingame_ui_context.world_manager
	self.active = false
	self._active_redeem = nil
	self._vote_activated = false
	self._votes = {}
	self._ui_animations = {}
	self._animation_callbacks = {}
	self._render_settings = {
		alpha_multiplier = 1
	}
	self._last_played_countdown_sfx = INIT_AUDIO_COUNTDOWN_AT + 1
	local world = self._world_manager:world("level_world")
	self.wwise_world = Managers.world:wwise_world(world)

	self:_create_elements()
	Managers.state.event:register(self, "twitch_redeem_ui", "event_twitch_redeem_ui")

  mod:dump(definitions, "definitions", 5)
  mod:echo("TwitchRedeemUI.init")
end

TwitchRedeemUI.event_twitch_redeem_ui = function (self, redeem)
	if not redeem then
		return
	end

  self:start_twitch_redeem_event(redeem)
end

TwitchRedeemUI.start_twitch_redeem_event = function (self, redeem)
	self.active = true
	self._active_redeem = table.clone(redeem)
	self:show_ui("twitch_redemption")
  -- TODO works till here
end

TwitchRedeemUI._create_elements = function (self)
	local scenegraph_definition = definitions.scenegraph_definition
	self._ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
	self._widgets = {}
	-- self._vote_count = {
	-- 	0,
	-- 	0,
	-- 	0,
	-- 	0,
	-- 	0
	-- }
	-- self._vote_icon_count = 0
	-- self._vote_widget = nil

	UIRenderer.clear_scenegraph_queue(self._ui_renderer)
  mod:echo("TwitchRedeemUI._create_elements")
end

local customizer_data = {
	root_scenegraph_id = "pivot",
	label = "Twitch",
	registry_key = "twitch",
	drag_scenegraph_id = "pivot_dragger"
}

TwitchRedeemUI.update = function (self, dt, t)
	HudCustomizer.run(self._ui_renderer, self._ui_scenegraph, customizer_data)

	if not self.active then
		return
	end

	self:_update_transition(dt)
	self:_draw(dt, t)

	-- self:_update_active_redeem(dt, t) -- TODO do we need this?

	local ui = self._ui

  if ui == "twitch_redemption" then
    self:_update_twitch_redemption(dt)
  end
end

TwitchRedeemUI._draw = function (self, dt, t)
  --mod:echo("DRAW")
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

TwitchRedeemUI.destroy = function (self)
  Managers.state.event:unregister("twitch_redeem_ui", self)
end

TwitchRedeemUI._update_transition = function (self, dt)
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

TwitchRedeemUI.show_ui = function (self, ui)
	self._next_ui = ui

	if self._ui then
		self._fade_out = true
	else
		self:_show_next_ui()
	end
end

TwitchRedeemUI.hide_ui = function (self)
	self._fade_out = true
end

TwitchRedeemUI._show_next_ui = function (self)
	local ui = self._next_ui

	if ui == "twitch_redemption" then
		self:_show_twitch_redemption()
	end

	self._ui = ui
	self._fade_in = true
	self._next_ui = nil
end

TwitchRedeemUI._show_twitch_redemption = function (self)
  	local active_vote = self._active_redeem

  	if not active_vote then
  		return
  	end

  	self._widgets = {}
  	local widgets = definitions.widgets.standard_vote -- TODO

    mod:echo("init widgets")

  	for widget_name, widget_data in pairs(widgets) do
  		self._widgets[widget_name] = UIWidget.init(widget_data)
  	end

    mod:dump(self._widgets, "WWWW", 1)
    -- TODO

    -- Redeem Title
    -- Twitch User
    -- User Input

    local timer_widget = self._widgets.timer

    if not timer_widget then
    	table.dump(self._widgets, "### TWITCH REDEEM UI CRASH INFO ###", 3)
    	return
    end

    self._widgets.timer.content.text = self._active_redeem.title
    self._widgets.text_redeemed_by.content.text = "redeemed by"
    
    --self._widgets.vote_text_a.content.localize = false --self._active_redeem.user
    self._widgets.vote_text_a.content.text = self._active_redeem.user

    mod:dump(self._widgets.background, "self._widgets.background", 10)

    self._widgets.vote_text_a.style.text.text_color = { 255, 0, 255, 255 }

    -- timer_widget.content.text = self._active_redeem.title
    -- self._widgets.vote_text_a = self._active_redeem.user
  	-- local vote_template_a = active_vote.vote_template_a
  	-- local vote_template_b = active_vote.vote_template_b
  	-- local vote_icon_a_widget = self._widgets.vote_icon_a
  	-- local texture_a = vote_template_a.texture_id
  	-- local use_frame_texture_a = true
  	-- vote_icon_a_widget.content.texture_id = texture_a
  	-- local vote_icon_b_widget = self._widgets.vote_icon_b
  	-- local texture_b = vote_template_b.texture_id
  	-- local use_frame_texture_b = true
  	-- vote_icon_b_widget.content.texture_id = texture_b
  	-- self._widgets.vote_icon_rect_a.content.visible = use_frame_texture_a
  	-- self._widgets.vote_icon_rect_b.content.visible = use_frame_texture_b
  	-- local vote_text_a_widget = self._widgets.vote_text_a
  	-- vote_text_a_widget.content.text = vote_template_a.text
  	-- local vote_text_b_widget = self._widgets.vote_text_b
  	-- vote_text_b_widget.content.text = vote_template_b.text

  	self:_play_standard_vote_start() -- TODO
  end

TwitchRedeemUI._update_twitch_redemption = function (self, dt)
	local active_vote = self._active_redeem

	if not active_vote then
		return
	end

	-- local timer = active_vote.timer
	-- local time_left = math.abs(math.ceil(timer))
	-- local timer_widget = self._widgets.timer

	-- if not timer_widget then
	-- 	table.dump(self._widgets, "### TWITCH VOTE UI CRASH INFO ###", 3)

	-- 	return
	-- end

	-- timer_widget.content.text = time_left

	-- self:_play_timer_sfx(time_left)

	-- local vote_percentages = active_vote.vote_percentages
	-- local vote_percentage_a = vote_percentages[1]
	-- local vote_percentage_b = vote_percentages[2]
	-- local result_a_bar_default_size = scenegraph_definition.result_a_bar.size
	-- local result_a_bar_size = self._ui_scenegraph.result_a_bar.size
	-- result_a_bar_size[1] = math.ceil(result_a_bar_default_size[1] * vote_percentage_a)
	-- local result_b_bar_default_size = scenegraph_definition.result_b_bar.size
	-- local result_b_bar_size = self._ui_scenegraph.result_b_bar.size
	-- result_b_bar_size[1] = math.ceil(result_b_bar_default_size[1] * vote_percentage_b)
	-- self._widgets.result_bar_a_eyes.content.visible = vote_percentage_b <= vote_percentage_a
	-- self._widgets.result_bar_b_eyes.content.visible = vote_percentage_a <= vote_percentage_b
end

TwitchRedeemUI._play_standard_vote_start = function (self)
	WwiseWorld.trigger_event(self.wwise_world, "Play_twitch_vote_standard_buff_start")
end
