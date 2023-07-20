local mod = get_mod("TwitchRedeems")

INCLUDE_GUARDS = {}

mod:dofile("scripts/mods/TwitchRedeems/BreedEditor")
mod:dofile("scripts/mods/TwitchRedeems/RedeemConfiguration")
mod:dofile("scripts/mods/TwitchRedeems/Networking")
mod:dofile("scripts/mods/TwitchRedeems/SettingsRedeems")
mod:dofile("scripts/mods/TwitchRedeems/SettingsTwitch")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_redeem_queue")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_templates")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_ui")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_utils")
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeemsHTTPProxyClient")
mod:dofile("scripts/mods/TwitchRedeems/Gui/twitch_redeem_ui")
require("scripts/mods/TwitchRedeems/TwitchRedeems_buffs")

local in_modded_realm = script_data["eac-untrusted"]
local Managers = Managers
local TwitchRedeemTemplates = TwitchRedeemTemplates

-- Load purple eye material.
Managers.package:load("resource_packages/levels/dlcs/morris/belakor_common", "global")

mod.default_twitch_redeems_filename = "default_twitch_redeems"

mod.redeem_twitch_user_name = nil
mod.redeem_twitch_channel_name = nil
mod.redeems_enabled = false

mod.redeem_queue = RedeemQueue:new()

mod.redeems = {}
mod.redeem_lookup = {}
mod.redeem_breeds = {}

mod.redeem_configuration = RedeemConfiguration:new()
mod.breed_editor = BreedEditor:new()
mod.settings_twitch = SettingsTwitch:new()
mod.settings_redeems = SettingsRedeems:new()
mod.gui_control = false

mod.http_proxy_client = TwitchRedeemsHTTPProxyClient:new()

mod.twitch_redemption_ui_settings_dirty = false

-- Mod settings ids.
mod.SETTING_ID_TWITCH_REDEEM_USER = "TWITCH_REDEEM_USER"
mod.SETTING_ID_TWITCH_CHANNEL_NAME = "TWITCH_CHANNEL_NAME"
mod.SETTING_ID_TWITCH_CUSTOM_VOTE_TIMES = "TWITCH_CUSTOM_VOTE_TIMES"
mod.SETTING_ID_TWITCH_INITIAL_VOTE_DOWNTIME = "TWITCH_INITIAL_VOTE_DOWNTIME"
mod.SETTING_ID_TWITCH_VOTE_DOWNTIME = "TWITCH_VOTE_DOWNTIME"
mod.SETTING_ID_TWITCH_VOTE_TIME = "TWITCH_VOTE_TIME"
mod.SETTING_ID_REDEEM_GLOBAL_COOLDOWN = "GLOBAL_COOLDOWN"
mod.SETTING_ID_REDEEM_GLOBAL_COOLDOWN_DURATION = "GLOBAL_COOLDOWN_DURATION"
mod.SETTING_ID_REDEEM_USER_COOLDOWN = "USER_COOLDOWN"
mod.SETTING_ID_REDEEM_USER_COOLDOWN_DURATION = "USER_COOLDOWN_DURATION"

-- TODO DELETE
-- local function cb_twitch_chat_message(key, message_type, user_name, message, parameter)
--   local is_redeem_bot = (string.lower(user_name) == string.lower(mod.redeem_twitch_user_name))
--   mod:info(user_name .. message)
--   if mod.redeems_enabled and is_redeem_bot then
--     -- Returns the text between two ":" and ";"
--     local redeem_key = string.match(message, ':([^:]+)')
--     local redeem_user = string.match(message, '-([^-]+)')
--     local redeem_param = string.match(message, '|([^|]+)')

--     -- If we get a valid redeem key we add it to the redeem queue which will be handled later on.
--     if redeem_key ~= nil then
--       local redeem = {}
--       redeem.key = string.lower(redeem_key)
--       redeem.param = redeem_param
--       redeem.user = redeem_user

--       if mod.user_redeem_cooldown then
--         if mod.user_redeem_queues[redeem.user] == nil then
--           mod.user_redeem_queues[redeem.user] = RedeemQueue:new()
--           mod.user_redeem_queues[redeem.user]:set_cooldown(mod.user_cooldown_duration)
--         end
--         mod.user_redeem_queues[redeem.user]:push(redeem)
--       else
--         mod.global_redeem_queue:push(redeem)
--       end

--       --mod.redeem_queue:push_back(redeem)
--       print("Added to queue: " .. user_name .. " : " .. message)
--     end
--   end
-- end

UIManager.reload_twitch_redeem_ui = function (self)
  -- TODO should we keep that? was needed for setup of ui.
  if self._ingame_ui_context then
    self._twitch_redeems_ui = TwitchRedeemUI:new(self._ingame_ui_context)
  end
end

mod.cb_load_twitch_redeems_from_file_done = function(_, result)
  local data = result.data
  if data then
    for key, raw_redeem in pairs(data) do
      local redeem = Redeem:new(raw_redeem)
      mod.redeems[key] = redeem
    end
  else
    mod:warning("No twitch redeems settings found.")
  end
end

mod.load_twitch_redeems_from_file = function(filename)
  mod.redeems = {}
  filename = filename or mod.default_twitch_redeems_filename
  mod:echo("Loading Twitch Redeems from file:\n'" .. filename .. "'")
  Managers.save:auto_load(filename, callback(mod, "cb_load_twitch_redeems_from_file_done"), false)
end

mod.store_twitch_redeems_to_file = function(filename)
  filename = filename or mod.default_twitch_redeems_filename
  mod:echo("Writing Twitch Redeems to file:\n'" .. filename .. "'")

  local data_to_save = {}
  for _, redeem in ipairs(mod.redeems) do
    local data = redeem:serialize()
    table.insert(data_to_save, data)
  end

  Managers.save:auto_save(filename, data_to_save, nil, true)
end

mod.create_redeems_lookup_table = function()
  mod.redeem_lookup = {}
  for key, redeem in pairs(mod.redeems) do
      if redeem ~= nil then
        mod.redeem_lookup[string.lower(redeem.data.name)] = (type(key) == "string") and string.lower(key) or key
      end
  end
end

mod.on_enabled = function(initial_call)
end

mod.on_disabled = function(initial_call)
end

mod.on_unload = function(exit_game)
end

mod.on_all_mods_loaded = function(status, state_name)
  mod.apply_settings()
  mod.redeem_configuration:load_settings()
  mod.settings_twitch:load_settings()
  mod.settings_redeems:load_settings()
  mod.breed_editor:load_settings()
  mod.redeem_twitch_user_name = mod:get(mod.SETTING_ID_TWITCH_REDEEM_USER)
  mod.redeem_twitch_channel_name = mod:get(mod.SETTING_ID_TWITCH_CHANNEL_NAME)

  if mod.redeem_twitch_user_name == nil then
    mod:warning(
    "No twitch redeem user specified. Use command '/twitch_redeem_name [NAME]' to specify the twitch account.")
  else
    mod:echo("Twitch redeem name is '" .. mod.redeem_twitch_user_name .. "'")
  end

  if mod.redeem_twitch_channel_name == nil then
    mod:warning(
    "No twitch channel name specified. Use command '/twitch_channel_name [NAME]' to specify the twitch channel.")
  else
    mod:echo("Twitch channel name is '" .. mod.redeem_twitch_channel_name .. "'")
  end

  local is_server = Managers.state.network and Managers.state.network.is_server
  if is_server then
    local is_in_inn_level = Managers.level_transition_handler:in_hub_level()
    mod.enable_redeems(not is_in_inn_level)
  end

  Managers.ui:reload_ingame_ui(false) -- TODO DEL
end

mod.apply_settings = function()
end

mod.on_setting_changed = function(setting_id)
  mod.apply_settings()
  mod.twitch_redemption_ui_settings_dirty = true
end

mod.on_game_state_changed = function(status, state_name)
  local is_server = Managers.state.network and Managers.state.network.is_server

  if is_server then
    local is_in_inn_level = Managers.level_transition_handler:in_hub_level()

    if status == "exit" then
      mod.enable_redeems(false)
      mod.http_proxy_client:request_map_end()
    elseif status == "enter" and not is_in_inn_level then
      mod.enable_redeems(true)
      mod.http_proxy_client:request_map_start()
    end
  end
end

mod.update = function(dt)
  mod.render_ui(dt)
  mod.http_proxy_client:update(dt)
end

-- Toggle Redeem Configurator Gui.
mod.toggle_twitch_redeems_configuration_gui = function()
  mod.redeem_configuration:toggle_gui_window()
end

-- Toggle Twitch Gui.
mod.toggle_twitch_gui = function()
  mod.settings_twitch:toggle_gui_window()
end

mod.enable_redeems = function(enable)
  local is_server = Managers.state.network and Managers.state.network.is_server
  if is_server and mod.redeems_enabled ~= enable then
    mod.redeems_enabled = enable
    mod:echo("Twitch redeems are " .. (enable and "ON" or "OFF"))
  end
end

mod.setup_twitch_redeems = function()
  local twitch_redeems = {}
  for _, redeem in ipairs(mod.redeems) do
    redeem:prepare()

    -- Prepare twitch redeem and add to list.
    local twitch_redeem = {
      title = redeem.data.name,
      cost = redeem.data.cost,
      prompt = redeem.data.desc,
      is_user_input_required = redeem.data.user_input,
      background_color = to_hex_color(redeem.data.background_color[1], redeem.data.background_color[2], redeem.data.background_color[3]),
      additional_setings = {
        skip_queue_timer = redeem.data.skip_queue_timer,
        override_queue_timer = redeem.data.override_queue_timer,
        queue_timer_duration = redeem.data.queue_timer_duration,
      }
    }
    table.insert(twitch_redeems, twitch_redeem)
  end

  if next(twitch_redeems) ~= nil then
    mod.http_proxy_client:request_create_redeems(twitch_redeems)
  end

  mod.create_redeems_lookup_table()
end

-- Load hooks.
mod:dofile("scripts/mods/TwitchRedeems/TwitchRedeems_hooks")
