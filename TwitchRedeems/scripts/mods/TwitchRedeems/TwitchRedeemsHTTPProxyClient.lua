local mod = get_mod("TwitchRedeems")

TwitchRedeemsHTTPProxyClient = class(TwitchRedeemsHTTPProxyClient)

local REQ_NEXT_REDEEM = "/pop-redeem"
local REQ_MAP_START = "/map_start"
local REQ_MAP_END = "/map_start"
local REQ_KEEP_ENTER = "/keep_enter"
local REQ_REDEEMS = "/redeems"
--local REQ_PLAYER_JOINED = "/game_client"
--local REQ_PLAYER_LEFT = "/game_client"

local Requests = {}
Requests.get = function(url, headers, callback)
    Managers.curl:get(url, headers, function(success, response_code, headers, data, userdata)
        local response = {
            success=success,
            status_code=response_code,
            headers=headers,
            data=data,
        }
        callback(response)
    end)
end

Requests.post = function(url, headers, body, callback)
    Managers.curl:post(url, body, headers, function(success, response_code, headers, data, userdata)
        local response = {
            success=success,
            status_code=response_code,
            headers=headers,
            data=data,
        }
        callback(response)
    end)
end

Requests.put = function(url, headers, body, callback)
    Managers.curl:post(url, body, headers, function(success, response_code, headers, data, userdata)
        local response = {
            success=success,
            status_code=response_code,
            headers=headers,
            data=data,
        }
        callback(response)
    end)
end

Requests.delete = function(url, headers, body, callback)
    Managers.curl:delete(url, body, headers, function(success, response_code, headers, data, userdata)
        local response = {
            success=success,
            status_code=response_code,
            headers=headers,
            data=data,
        }
        callback(response)
    end)
end

Requests.patch = function(url, headers, body, callback)
    Managers.curl:patch(url, body, headers, function(success, response_code, headers, data, userdata)
        local response = {
            success=success,
            status_code=response_code,
            headers=headers,
            data=data,
        }
        callback(response)
    end)
end

TwitchRedeemsHTTPProxyClient.init = function (self, protocol, host, port)
    self.protocol = protocol or "http"
    self.host = host or "localhost"
    self.port = port or 8000
    self.url = string.format("%s://%s:%s", self.protocol, self.host, self.port)
end

TwitchRedeemsHTTPProxyClient.request_next_reedem = function (self)
    Requests.get(self.url .. REQ_NEXT_REDEEM, {}, function(response)
        if response.success then
            mod:echo(tostring(response.status_code))
            mod:echo(tostring(response.headers))
            mod:echo(tostring(response.data))
        else
            mod:error("HTTP Request failed")
        end
    end)
end

TwitchRedeemsHTTPProxyClient.request_map_start = function (self)
    Requests.post(self.url .. REQ_MAP_START, {}, cjson.encode({}), function(response)
        if response.success then
            mod:echo(tostring(response.status_code))
            mod:echo(tostring(response.headers))
            mod:echo(tostring(response.data))
        else
            mod:error("HTTP Request failed")
        end
    end)
end

TwitchRedeemsHTTPProxyClient.request_map_end = function (self)
    Requests.post(self.url .. REQ_MAP_END, {}, cjson.encode({}), function(response)
        if response.success then
            mod:echo(tostring(response.status_code))
            mod:echo(tostring(response.headers))
            mod:echo(tostring(response.data))
        else
            mod:error("HTTP Request failed")
        end
    end)
end


TwitchRedeemsHTTPProxyClient.request_create_redeems = function (self, redeems)
    Requests.post(self.url .. REQ_REDEEMS, {}, cjson.encode(redeems), function(response)
        if response.success then
            mod:echo(tostring(response.status_code))
            mod:echo(tostring(response.headers))
            mod:echo(tostring(response.data))
        else
            mod:error("HTTP Request failed")
        end
    end)
end

TwitchRedeemsHTTPProxyClient.request_delete_redeems = function (self)
    Requests.delete(self.url .. REQ_REDEEMS, {}, cjson.encode({}), function(response)
        if response.success then
            mod:echo(tostring(response.status_code))
            mod:echo(tostring(response.headers))
            mod:echo(tostring(response.data))
        else
            mod:error("HTTP Request failed")
        end
    end)
end

TwitchRedeemsHTTPProxyClient.request_update_redeems = function (self, body)
    Requests.patch(self.url .. REQ_REDEEMS, {}, cjson.encode(body), function(response)
        if response.success then
            mod:echo(tostring(response.status_code))
            mod:echo(tostring(response.headers))
            mod:echo(tostring(response.data))
        else
            mod:error("HTTP Request failed")
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