local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemDefinitions")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")
mod:dofile("scripts/mods/TwitchRedeems/Utils/Amount")

if not INCLUDE_GUARDS.REDEEM_UNIT then
  INCLUDE_GUARDS.REDEEM_UNIT = true

  RedeemUnit = class(RedeemUnit)

  RedeemUnit.init = function(self, other)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = ""
    self.imgui_window.key = self

    self.data = {
      name = "New Unit",
      desc = "",
      breed_name = "skaven_clan_rat",
      breed_index = 1,
      amount = Amount:new(),
      max_health_modifier = 1.0,
      taggable = false,
    }

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        if key == "amount" then
          self.data.amount = Amount:new(value)
        else
          self.data[key] = other[key]
        end
      end
    end
  end

  RedeemUnit.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  RedeemUnit.serialize = function(self)
    local data = {}
    data.name = self.data.name
    data.desc = self.data.desc
    data.breed_name = self.data.breed_name
    data.breed_index = self.data.breed_index
    data.amount = self.data.amount:serialize()
    data.max_health_modifier = self.data.max_health_modifier
    data.taggable = self.data.taggable
    return data
  end

  RedeemUnit.render_ui = function(self)
    self.imgui_window.title = self.data.name
    local window_open = self.imgui_window:begin_window()
    if window_open then
      self.data.name = Imgui.input_text("Name##" .. tostring(self), self.data.name)

      self.data.breed_index = Imgui.combo("Breed", self.data.breed_index, GuiDropdownBaseBreedsLocalized, 10) -- TODO add custom breeds
      self.data.breed_name = GuiDropdownBaseBreeds[self.data.breed_index]

      self.data.taggable = Imgui.checkbox("Taggable##" .. tostring(self), self.data.taggable)

      self.data.amount:render_ui()

      self.data.max_health_modifier = Imgui.input_float("Max Health Modifier", self.data.max_health_modifier, "%.2f")

      self.imgui_window:end_window()
    end
    return window_open
  end

  RedeemUnit.create_spawn_list_entry = function(self)
    local entry = {}
    entry.breed = table.clone(Breeds[self.data.breed_name])
    entry.breed.is_twitch_redeem = true
    entry.amount = self.data.amount
    entry.max_health_modifier = self.data.max_health_modifier
    entry.is_taggable = self.data.taggable
    entry.has_purple_eyes = true
    entry.optional_data = {}
    entry.optional_data.max_health_modifier = self.data.max_health_modifier

    -- Apply purple eyes.
    entry.optional_data.spawned_func = function(unit, breed, optional_data) -- TODO
      local buff_system = Managers.state.entity:system("buff_system")

      if buff_system.network_manager == nil then -- TODO DEBUG
        mod:error("buff_system.network_manager == nil")
        mod:dump(buff_system, "buff_system", 2)
      end

      buff_system:add_buff(unit, "twitch_redeem_buff_eye_glow", unit)
    end

    -- Unit taggable.
    if self.data.taggable then
      add_spawn_func(entry.optional_data, function (unit) 
        local buff_system = Managers.state.entity:system("buff_system")
        buff_system:add_buff(unit, "twitch_redeem_buff_pingable", unit)
      end)
    end

    local side = Managers.state.side:get_side_from_name("dark_pact")
    entry.optional_data.side_id = side.side_id

    return entry
  end
end

-- TODO CRASHES
-- Queue got fucked up: when skipping timers



-- twitch_redeem_buff_eye_glow buff: <<Script Error>>scripts/entity_system/systems/buff/buff_system.lua:263: attempt to index local 'network_manager' (a nil value)<</Script Error>>
-- Check if buff_system get created and destroyed a lot.




-- ui_renderer: Script Error]: scripts/ui/ui_renderer.lua:353: Must provide parent scenegraph id when building multiple depth passes. 
--[[
  <Lua Script.Callstack>
  [0] =[C]: in function callstack
  [1] @scripts/mods/vmf/modules/core/safe_calls.lua:16:in function <scripts/mods/vmf/modules/core/safe_calls.lua:12>
  [2] =[C]: in function Color
  [3] @scripts/ui/ui_renderer.lua:1141: in function draw_text
  [4] @scripts/ui/ui_passes.lua:1931: in function draw
  [5] @scripts/ui/ui_renderer.lua:615: in function hook_chain
  [6] @scripts/mods/vmf/modules/core/hooks.lua:180: in function draw_widget
  [7] @scripts/mods/TwitchRedeems/Gui/twitch_redeem_ui.lua:115: in function _draw
  [8] @scripts/mods/TwitchRedeems/Gui/twitch_redeem_ui.lua:94: in function update
  [9] @scripts/mods/TwitchRedeems/TwitchRedeems_hooks.lua:265:in function <scripts/mods/TwitchRedeems/TwitchRedeems_hooks.lua:255>
  [10] =[C]: in function xpcall
  [11] @scripts/mods/vmf/modules/core/safe_calls.lua:63: in function safe_call_nr
  [12] @scripts/mods/vmf/modules/core/hooks.lua:165:in function <scripts/mods/vmf/modules/core/hooks.lua:163>
  [13] @scripts/mods/vmf/modules/core/hooks.lua:184: in function update
  [14] @scripts/ui/views/ingame_ui.lua:668: in function hook_chain
  [15] @scripts/mods/vmf/modules/core/hooks.lua:180: in function update
  [16] @scripts/managers/ui/ui_manager.lua:119: in function update
  [17] @scripts/game_state/state_ingame.lua:672:in function <scripts/game_state/state_ingame.lua:670>
  [18] =[C]: in function update_animations_with_callback
  [19] @foundation/scripts/util/script_world.lua:361: in function update
  [20] @foundation/scripts/managers/world/world_manager.lua:102: in function update
  [21] @scripts/boot.lua:906: in function game_update
  [22] @scripts/boot.lua:628:in function <scripts/boot.lua:619>
</Lua Script.Callstack>
<Lua Script.Locals>
  [1] error_message = "scripts/ui/ui_renderer.lua:1141: bad argument #4 to \'Color\' (number expected, got nil)"
  [3] self = table: 000000000DA736F0; text = "MAILASDQWE"; font_material = "materials/fonts/gw_body"; font_size = 26; font_name = "hell_shark"; position = Vector3(1205, 787.723, 970); color = table: 00000000106D2F50; retained_id = nil; color_override = nil; ui_position = Vector3(1606.67, 1050.3, 970); use_color_override = nil; use_var_args = false; return_value = nil; render_settings = table: 000000000DEBEA70; alpha_multiplier = 0.062497388571500778
  [4] ui_renderer = table: 000000000DA736F0; pass_data = table: 00000000106356A0; ui_scenegraph = table: 000000000DEBEAE0; pass_definition = table: 000000000317E8F0; ui_style = table: 000000001066F710; ui_content = table: 000000001066D7C0; position = Vector3(1205, 781, 970); size = Vector3(240, 24, 0); input_service = table: 000000000DA73DB0; dt = 0.012499477714300156; retained_ids = nil; new_retained_ids = nil; text = "MAILASDQWE"; original_text = "MAILASDQWE"; default_font_size = 20; font_material = "materials/fonts/gw_body"; font_size = 26; font_name = "hell_shark"; font_height = 28.14600071310997; font_min = -11.573333581288654; font_max = 25.048666636149086; text_width = 122.47949981689453; _ = 15.268500208854675; origin = Vector3(0, -4.16, -4.16); offset = Vector3(0, 6.72262, 0); new_position = Vector3(1205, 787.723, 970); retained_id = nil
  [5] self = table: 000000000DA736F0; widget = table: 0000000010675040; ui_animations = table: 0000000010675070; UIPasses = table: 00000000030CA640; UISceneGraph_get_size_scaled = [function]; ui_scenegraph = table: 000000000DEBEAE0; input_service = table: 000000000DA73DB0; dt = 0.012499477714300156; scenegraph_id = "vote_text_rect_a"; world_pos = table: 000000000DEBFDB0; offset = table: 0000000010635910; pos_x = 1207; pos_y = 781; pos_z = 968; widget_content = table: 000000001066D7C0; widget_style = table: 000000001066D7F0; size = Vector3(240, 24, 0); widget_visible = true; input_manager = table: 000000000AC632A0; widget_element = table: 0000000010675B00; widget_dirty = nil; passes = table: 00000000031A8BC0; pass_datas = table: 0000000010635F90; i = 1; pass = table: 000000000317E8F0; pass_type = "text"; visible = true; pass_content = table: 000000001066D7C0; pass_style = table: 000000001066F710; ui_pass = table: 000000000312FCF0; pass_data = table: 00000000106356A0; pass_size = Vector3(240, 24, 0); pass_pos_x = 1205; pass_pos_y = 781; pass_pos_z = 970
  [6] hook_chain = [function]
  [7] self = table: 000000000DEBEA10; dt = 0.012499477714300156; t = nil; ui_renderer = table: 000000000DA736F0; ui_scenegraph = table: 000000000DEBEAE0; input_service = table: 000000000DA73DB0; render_settings = table: 000000000DEBEA70; ui = "twitch_redemption"; _ = "vote_text_a"; widget = table: 0000000010675040
  [8] self = table: 000000000DEBEA10; dt = 0.012499477714300156; t = nil; timer_expired = false
  [9] self = table: 000000000DA74190; dt = 0.012499477714300156; t = 545.86346737295389
  [11] mod = table: 0000000002F6B580; error_prefix_data = "(safe_hook)"; func = [function]
  [13] hook_chain = [function]; num_values = 0; values = table: 000000000FD8D960; safe_hooks = table: 00000000009DA530; i = 4
  [14] self = table: 000000000DA72F10; dt = 0.012499477714300156; t = 545.86346737295389; disable_ingame_ui = false; end_of_level_ui = nil; views = table: 000000000DEC5080; is_in_inn = nil; input_service = table: 000000000DA73DB0; ingame_hud = table: 000000000DA74190; transition_manager = table: 0000000004D34C20; end_screen = table: 00000000097C1AF0
  [15] hook_chain = [function]
  [16] self = table: 0000000000A49260; ingame_ui = table: 000000000DA72F10; t = 545.86346737295389; dt = 0.012499477714300156; disable_ingame_ui = false; level_end_view_wrapper = nil; level_end_view = nil
  [19] world = [World]; dt = 0.012499477714300156; anim_callback = [function]; scene_callback = [function]
  [20] self = table: 0000000005830970; dt = 0.012499477714300156; t = 531.58683473430574; _ = 1; world = [World]
  [21] self = table: 0000000000012D80; real_world_dt = 0.012499477714300156; Managers = \n\tui\n\ttwitch\n\tpopup\n\ttoken\n\ttransition\n\tmusic\n\ttime\n\tfree_flight\n\tirc\n\ttelemetry_events\n\teac\n\tmatchmaking\n\tlight_fx\n\tsimple_popu...; dt = 0.012499477714300156; t = 531.58683473430574
  [22] dt = 0.012499477714300156
</Lua Script.Locals>
<Lua Script.Self>
  [3] gui_retained = [Gui]; video_players = table: 000000000DA73790; wwise_world = [WwiseWorld]; vmf_data = table: 000000000DA73920; input_service = table: 000000000DA73DB0; scenegraph_queue = table: 000000000DA73760; render_settings = table: 000000000DEBEA70; dt = 0.012499477714300156; world = [World]; ui_scenegraph = table: 000000000DEBEAE0; gui = [Gui]; 
  [5] gui_retained = [Gui]; video_players = table: 000000000DA73790; wwise_world = [WwiseWorld]; vmf_data = table: 000000000DA73920; input_service = table: 000000000DA73DB0; scenegraph_queue = table: 000000000DA73760; render_settings = table: 000000000DEBEA70; dt = 0.012499477714300156; world = [World]; ui_scenegraph = table: 000000000DEBEAE0; gui = [Gui]; 
  [7] active = true; _timer = table: 000000000DEBEA40; _world_manager = table: 0000000005830970; wwise_world = [WwiseWorld]; _widgets = table: 000000001066D1E0; _fade_in = true; _input_manager = table: 000000000AC632A0; _ui_renderer = table: 000000000DA736F0; _active_redeem = table: 000000001066CE70; _ui_scenegraph = table: 000000000DEBEAE0; _ui = "twitch_redemption"; _render_settings = table: 000000000DEBEA70; 
  [8] active = true; _timer = table: 000000000DEBEA40; _world_manager = table: 0000000005830970; wwise_world = [WwiseWorld]; _widgets = table: 000000001066D1E0; _fade_in = true; _input_manager = table: 000000000AC632A0; _ui_renderer = table: 000000000DA736F0; _active_redeem = table: 000000001066CE70; _ui_scenegraph = table: 000000000DEBEAE0; _ui = "twitch_redemption"; _render_settings = table: 000000000DEBEA70; 
  [9] _definitions = table: 000000000DA77C60; _hud_scale_multiplier = 1; _components_array = table: 000000000DA77DC0; _parent = table: 000000000DA72F10; _twitch_redeems_ui = table: 000000000DEBEA10; _components = table: 000000000DA77D90; _current_group_name = "alive"; _tobii_clean_ui_is_enabled = false; _ingame_ui_context = table: 000000000DA72EE0; _scale_modified = false; _had_tobii = false; _components_hud_scale_lookup = table: 000000000DA77C30; _crosshair_position_y = 540; _currently_visible_components = table: 000000000DA74220; _update_post_visibility = false; _peer_id = "11000010156840c"; _is_own_player_dead = false; _clean_ui = table: 000000000DA74320; _player = table: 000000000C1346B0; _components_array_id_lookup = table: 000000000DA77DF0; _component_list = table: 000000000DA77D60; _crosshair_position_x = 1290; 
  [14] popups_by_name = table: 000000000DEC5050; fps = 0; world_manager = table: 0000000005830970; ingame_hud = table: 000000000DA74190; is_server = true; last_resolution_x = 3440; top_world = [World]; ui_renderer = table: 000000000DA736F0; telemetry_time_view_enter = 0; input_manager = table: 000000000AC632A0; profile_synchronizer = table: 0000000005B71E60; blocked_transitions = table: 00000000088475A0; cutscene_system = table: 0000000003210B60; text_popup_ui = table: 00000000097DBA70; local_player_id = 1; unlock_manager = table: 0000000001466A30; last_resolution_y = 1440; popup_handler = table: 00000000097DB930; ui_top_renderer = table: 000000000DA73B10; peer_id = "11000010156840c"; _profile_requester = table: 000000000304FB40; camera_manager = table: 000000000C4DEA30; ingame_ui_context = table: 000000000DA72EE0; views = table: 000000000DEC5080; wwise_world = [WwiseWorld]; _fps_cooldown = 0; mean_dt = 0; world = [World]; _disable_ingame_ui = false; _player = table: 000000000C1346B0; hotkey_mapping = table: 00000000088463E0; weave_onboarding = table: 00000000097C2B90; end_screen = table: 00000000097C1AF0; network_event_delegate = table: 000000000D469EA0; 
  [16] _ingame_ui = table: 000000000DA72F10; _ui_enabled = true; _ui_update_initialized = true; _ingame_ui_context = table: 000000000DA72EE0; 
  [20] locked = true; _scene_update_callbacks = table: 0000000005832C70; _worlds = table: 0000000005830E70; _update_queue = table: 000000000ABE29E0; _disabled_worlds = table: 00000000058317C0; _wwise_worlds = table: 0000000005834B60; _queued_worlds_to_release = table: 0000000005834AB0; _anim_update_callbacks = table: 00000000058312C0; 
  [21] startup_package_handles = table: 000000000009F460; is_controlled_exit = false; startup_state = "ready"; startup_packages = table: 000000000009F3F0; flow_return_table = table: 000000000009B200; _machine = table: 000000000323CA50; has_booted = true; loading_context = table: 000000000C2A57C0; startup_timer = 13.263261269778013; bar_timer = 0; disable_loading_bar = true; 
</Lua Script.Self>

21:52:05.861 [Lua] [MOD][TwitchRedeems][ERROR] (safe_hook): scripts/ui/ui_renderer.lua:1141: bad argument #4 to 'Color' (number expected, got nil)
21:52:06.325 <<Lua Error>>scripts/ui/ui_renderer.lua:353: Must provide parent scenegraph id when building multiple depth passes.<</Lua Error>>
<<Callstack>>
{00007ff6976b0000, 011ec000, 6479bea4, f13d12bc-ddc0-4f8d-9de8-f63107de0c4f, 00000001, D:\a\w\vt2-stingray\vt2\release\Q2_2023_04_24\engine\win64_dx12\release\vermintide2_dx12.pdb}
{00007ff988210000, 001f8000, 6349a4f2, 68ca2e8c-069f-7fef-6492-0b3e81722672, 00000001, ntdll.pdb}
{00007ff986f10000, 000bf000, 068524ca, 3be92541-2988-30a6-8fa6-03ea9e6c1dcb, 00000001, kernel32.pdb}
--]]




-- exploding corpses: [Script Error]: scripts/network/unit_spawner.lua:454: Game object owned by someone else