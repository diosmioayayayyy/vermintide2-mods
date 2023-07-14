local mod = get_mod("TwitchRedeems")

TwitchRedeemsHTTPProxyClient = class(TwitchRedeemsHTTPProxyClient)

local REQ_NEXT_REDEEM = "/pop-redeem"
local REQ_MAP_START = "/map_start"
local REQ_MAP_END = "/map_end"
local REQ_KEEP_ENTER = "/keep_enter"
local REQ_REDEEMS = "/redeems"
local REQ_PAUSE_REDEEMS = "/pause_redeems"
local REQ_UNPAUSE_REDEEMS = "/unpause_redeems"
--local REQ_PLAYER_JOINED = "/game_client"
--local REQ_PLAYER_LEFT = "/game_client"

local POLLING_INTERVAL = 1.0 -- [s]

local Requests = {}
Requests.get = function(url, headers, callback)
  Managers.curl:get(url, headers, function(success, response_code, headers, data, userdata)
    local response = {
      success = success,
      status_code = response_code,
      headers = headers,
      data = data,
    }
    callback(response)
  end)
end

Requests.post = function(url, headers, body, callback)
  Managers.curl:post(url, body, headers, function(success, response_code, headers, data, userdata)
    local response = {
      success = success,
      status_code = response_code,
      headers = headers,
      data = data,
    }
    callback(response)
  end)
end

Requests.put = function(url, headers, body, callback)
  Managers.curl:post(url, body, headers, function(success, response_code, headers, data, userdata)
    local response = {
      success = success,
      status_code = response_code,
      headers = headers,
      data = data,
    }
    callback(response)
  end)
end

Requests.delete = function(url, headers, body, callback)
  Managers.curl:delete(url, body, headers, function(success, response_code, headers, data, userdata)
    local response = {
      success = success,
      status_code = response_code,
      headers = headers,
      data = data,
    }
    callback(response)
  end)
end

Requests.patch = function(url, headers, body, callback)
  Managers.curl:patch(url, body, headers, function(success, response_code, headers, data, userdata)
    local response = {
      success = success,
      status_code = response_code,
      headers = headers,
      data = data,
    }
    callback(response)
  end)
end

TwitchRedeemsHTTPProxyClient.init = function(self, protocol, host, port)
  self.protocol = protocol or "http"
  self.host = host or "localhost"
  self.port = port or 8000
  self.url = string.format("%s://%s:%s", self.protocol, self.host, self.port)
  self.polling_timer = 0;
end

TwitchRedeemsHTTPProxyClient.update = function(self, dt)
  if self.polling_timer ~= nil then
    self.polling_timer = self.polling_timer + dt

    if self.polling_timer > POLLING_INTERVAL and 0 then
      if mod.redeems_enabled then
        -- TODO add remaining time to response to increase polling timer?
        self:request_next_reedem();
      end
      self.polling_timer = 0
    end
  end
end

TwitchRedeemsHTTPProxyClient.request_next_reedem = function(self)
  Requests.get(self.url .. REQ_NEXT_REDEEM, {}, function(response)
    if response.success then
      if response.status_code == 200 then
        local json_str = string.sub(response.data, 2, -2)
        json_str = string.gsub(json_str, "\\", "")
        local success, redemption = pcall(cjson.decode, json_str)
        if success then
          mod.redeem_queue:push(redemption) -- Add redeem to queue.
          mod:dump(mod.redeem_queue._queue, "QUEUE", 2)
        end
      end
    else
      mod:error("HTTP Request 'request_next_reedem' failed")
    end
  end)
end

TwitchRedeemsHTTPProxyClient.request_map_start = function(self)
  Requests.post(self.url .. REQ_MAP_START, {}, cjson.encode({}), function(response)
    if response.success then
      -- Nothing to do here.
    else
      mod:error("HTTP Request 'request_map_start' failed")
    end
  end)
end

TwitchRedeemsHTTPProxyClient.request_map_end = function(self)
  Requests.post(self.url .. REQ_MAP_END, {}, cjson.encode({}), function(response)
    if response.success then
      -- Nothing to do here.
    else
      mod:error("HTTP Request 'request_map_end' failed")
    end
  end)
end

TwitchRedeemsHTTPProxyClient.request_pause_redeems = function(self)
  Requests.post(self.url .. REQ_PAUSE_REDEEMS, {}, cjson.encode({}), function(response)
    if response.success then
      -- Nothing to do here.
    else
      mod:error("HTTP Request 'request_pause_redeems' failed")
    end
  end)
end

TwitchRedeemsHTTPProxyClient.request_unpause_redeems = function(self)
  Requests.post(self.url .. REQ_UNPAUSE_REDEEMS, {}, cjson.encode({}), function(response)
    if response.success then
      -- Nothing to do here.
    else
      mod:error("HTTP Request 'request_unpause_redeems' failed")
    end
  end)
end


TwitchRedeemsHTTPProxyClient.request_create_redeems = function(self, redeems)
  Requests.post(self.url .. REQ_REDEEMS, {}, cjson.encode(redeems), function(response)
    if response.success then
      mod:echo("Redeems were created.")
    else
      mod:error("HTTP Request 'request_create_redeems' failed")
    end
  end)
end

TwitchRedeemsHTTPProxyClient.request_delete_redeems = function(self)
  Requests.delete(self.url .. REQ_REDEEMS, {}, cjson.encode({}), function(response)
    if response.success then
      mod:echo("Redeems were deleted.")
    else
      mod:error("HTTP Request 'request_delete_redeems' failed")
    end
  end)
end

TwitchRedeemsHTTPProxyClient.request_update_redeems = function(self, body)
  Requests.patch(self.url .. REQ_REDEEMS, {}, cjson.encode(body), function(response)
    if response.success then
      mod:echo("Redeems were updated.")
    else
      mod:error("HTTP Request 'request_update_redeems' failed")
    end
  end)
end

-- if Imgui.button("Create Redeems") then
--     local api_url = "http://localhost:8000/redeems?action=create"
--     local url = api_url

--     local l = {}
--     local r = {}
--     r = { title="TEST1", cost="1" }
--     table.insert(l, r)
--     r = { title="TEST2", cost="1" }
--     table.insert(l, r)
--     r = { title="TEST3", cost="1" }
--     table.insert(l, r)
--     local json_payload = cjson.encode(l)

--     mod:pcall(function()
--         Managers.curl:post(url, json_payload, {}, function(success, response_code, headers, data, userdata)
--             print(data)
--         end)
--     end)
-- end

-- if Imgui.button("Delete Redeems") then
--     local api_url = "http://localhost:8000/redeems?action=delete"
--     local url = api_url
--     Managers.curl:delete(url, nil, nil, function(success, response_code, headers, data, userdata)
--         print(data)
--     end)
-- end
