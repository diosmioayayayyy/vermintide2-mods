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

  mod:dump(self, "TwitchRedeemUI self", 1)
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


-- TwitchRedeemUI._create_vote_icon = function (self, vote_index)
-- 	if self._ui_animations.animate_in or table.size(self._widgets) >= 50 or not self._vote_widget then
-- 		return
-- 	end

-- 	local scenegraph_definition = definitions.scenegraph_definition
-- 	local base_name = "vote_icon_" .. self._vote_icon_count
-- 	local content = self._vote_widget.content
-- 	local style = self._vote_widget.style
-- 	local icon = content:icon_texture_func(style, vote_index)
-- 	local offset = content:icon_offset_func(style, vote_index)
-- 	scenegraph_definition[base_name] = {
-- 		parent = "vote_icon",
-- 		position = {
-- 			offset,
-- 			0,
-- 			0
-- 		}
-- 	}
-- 	self._widgets[base_name] = UIWidget.init(UIWidgets.create_simple_texture(icon, base_name))
-- 	local widget = self._widgets[base_name]
-- 	self._ui_animations[base_name .. "_offset_y"] = UIAnimation.init(UIAnimation.function_by_time_with_offset, widget.style.texture_id.offset, 2, 0, Math.random(100, 200), 3, math.random(0, 10), math.easeOutCubic)
-- 	self._ui_animations[base_name .. "_offset_x"] = UIAnimation.init(UIAnimation.function_by_time_with_offset, widget.style.texture_id.offset, 1, 0, 1, 3, math.random(0, 10), altered_sin)
-- 	self._ui_animations[base_name .. "_color"] = UIAnimation.init(UIAnimation.function_by_time_with_offset, widget.style.texture_id.color, 1, 255, 0, 3.2, math.random(0, 10), math.ease_exp)
-- 	self._animation_callbacks[base_name .. "_color"] = callback(self, "cb_destroy_vote_icon", base_name)
-- 	self._vote_icon_count = self._vote_icon_count + 1
-- 	self._ui_scenegraph = UISceneGraph.init_scenegraph(scenegraph_definition)
-- end

-- TwitchRedeemUI.cb_destroy_vote_icon = function (self, vote_icon_name)
-- 	self._widgets[vote_icon_name] = nil
-- end

-- TwitchRedeemUI._update_active_redeem = function (self, dt, t)
-- 	if not self._active_redeem or self._active_redeem.completed then
-- 		return
-- 	end

-- 	local vote_key = self._active_redeem.vote_key
-- 	local vote_data = Managers.twitch:get_vote_data(vote_key)

-- 	if not vote_data then
-- 		Application.error("[TwitchRedeemUI] There is no vote data for key (" .. vote_key .. ")")

-- 		self._active_redeem = nil
-- 		self._vote_widget = nil

-- 		table.remove(self._votes, 1)

-- 		return
-- 	end

-- 	local options = vote_data.options
-- 	self._vote_count = self._vote_count or {
-- 		0,
-- 		0,
-- 		0,
-- 		0,
-- 		0
-- 	}
-- 	local a_diff = options[1] - self._vote_count[1]
-- 	local b_diff = options[2] - self._vote_count[2]
-- 	local c_diff = options[3] - self._vote_count[3]
-- 	local d_diff = options[4] - self._vote_count[4]
-- 	local e_diff = options[5] - self._vote_count[5]

-- 	if a_diff > 0 then
-- 		for i = 1, a_diff do
-- 			self:_create_vote_icon(1)
-- 		end
-- 	end

-- 	if b_diff > 0 then
-- 		for i = 1, b_diff do
-- 			self:_create_vote_icon(2)
-- 		end
-- 	end

-- 	if c_diff > 0 then
-- 		for i = 1, c_diff do
-- 			self:_create_vote_icon(3)
-- 		end
-- 	end

-- 	if d_diff > 0 then
-- 		for i = 1, d_diff do
-- 			self:_create_vote_icon(4)
-- 		end
-- 	end

-- 	if e_diff > 0 then
-- 		for i = 1, e_diff do
-- 			self:_create_vote_icon(5)
-- 		end
-- 	end

-- 	local total_amount = 0

-- 	for i = 1, 5 do
-- 		self._vote_count[i] = options[i]
-- 		total_amount = total_amount + options[i]
-- 	end

-- 	local percentages = {}

-- 	for i = 1, 5 do
-- 		percentages[i] = total_amount > 0 and options[i] / total_amount or 0
-- 	end

-- 	self._active_redeem.vote_percentages = self._active_redeem.vote_percentages or {
-- 		0,
-- 		0,
-- 		0,
-- 		0,
-- 		0
-- 	}

-- 	for i = 1, 5 do
-- 		self._active_redeem.vote_percentages[i] = math.lerp(self._active_redeem.vote_percentages[i] or 0, percentages[i], dt * 2)
-- 	end

-- 	if DEBUG_VOTE_UI then
-- 		Debug.text("                                " .. self._vote_count[1])
-- 		Debug.text("                                " .. self._vote_count[2])
-- 		Debug.text("                                " .. self._vote_count[3])
-- 		Debug.text("                                " .. self._vote_count[4])
-- 		Debug.text("                                " .. self._vote_count[5])
-- 	end

-- 	self._active_redeem.timer = vote_data.timer
-- 	self._active_redeem.options = options
-- 	self._vote_activated = vote_data.activated
-- end

-- TwitchRedeemUI._update_result = function (self, dt)
-- 	self._result_timer = self._result_timer - dt

-- 	if self._result_timer > 0 then
-- 		return
-- 	end

-- 	self:hide_ui()
-- end


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

-- TwitchRedeemUI._play_winning_sfx = function (self, cost)
-- 	if cost == nil then
-- 		return
-- 	end

-- 	if cost <= 0 then
-- 		WwiseWorld.trigger_event(self.wwise_world, "Play_twitch_vote_end")
-- 	else
-- 		WwiseWorld.trigger_event(self.wwise_world, "Play_twitch_vote_evil_won")
-- 	end
-- end

-- TwitchRedeemUI._play_timer_sfx = function (self, time_left)
-- 	if time_left <= INIT_AUDIO_COUNTDOWN_AT and time_left ~= self._last_played_countdown_sfx then
-- 		WwiseWorld.trigger_event(self.wwise_world, "Play_twitch_count")

-- 		self._last_played_countdown_sfx = time_left
-- 	end
-- end

-- TwitchRedeemUI._play_multiple_vote_start = function (self)
-- 	WwiseWorld.trigger_event(self.wwise_world, "Play_twitch_vote_multiple_start")
-- end

TwitchRedeemUI._play_standard_vote_start = function (self)
	WwiseWorld.trigger_event(self.wwise_world, "Play_twitch_vote_standard_buff_start")
end
