local mod = get_mod("TwitchRedeems")

mod:info("Initializing MutatorHandler extension")

-- Register oneshot mutator RPC.
mod:network_register("create-oneshot-mutator",
  function(peer_id, mutator_name, mutator_name_oneshot, mutator_id, oneshot_settings)
    Managers.state.event:trigger("event_create_oneshot_mutator", mutator_name, mutator_name_oneshot, mutator_id, oneshot_settings)
  end)

mod:hook_safe(MutatorHandler, "init",
  function(self, mutators, is_server, has_local_client, world, network_event_delegate, network_transmit)
    Managers.state.event:register(self, "event_create_oneshot_mutator", "create_oneshot_mutator")
    Managers.state.event:register(self, "event_activate_oneshot_mutator_client", "rpc_activate_oneshot_mutator_client")
    Managers.state.event:register(self, "event_deactivate_oneshot_mutator_client", "rpc_deactivate_oneshot_mutator_client")
  end)

-- mod:hook_safe(MutatorHandler, "_deactivate_mutator",
--   function(self, name, active_mutators, mutator_context, is_destroy)
--     self:free_oneshot_mutator_id(name)
--   end)

-- RPC for mutator_id greater 128
mod:network_register("activate-oneshot-mutator-client",
  function(peer_id, mutator_id, activated_by_twitch)
    Managers.state.event:trigger("event_activate_oneshot_mutator_client", mutator_id, activated_by_twitch)
  end)

mod:network_register("deactivate-oneshot-mutator-client",
  function(peer_id, mutator_id)
    Managers.state.event:trigger("event_deactivate_oneshot_mutator_client", mutator_id)
  end)

MutatorHandler.rpc_activate_oneshot_mutator_client = function(self, mutator_id, activated_by_twitch)
  -- Copy of 'rpc_oneshot_mutator_client' to circumvent mutator_id bounds (max 128).
  fassert(not self._is_server, "Only call rpc_activate_mutator_client on clients.")

  local mutator_name = NetworkLookup.mutator_templates[mutator_id]
  local active_mutators = self._active_mutators
  local mutator_context = self._mutator_context
  local mutator_data = {
    template = MutatorTemplates[mutator_name],
    activated_by_twitch = activated_by_twitch
  }

  self:_activate_mutator(mutator_name, active_mutators, mutator_context, mutator_data)
end

MutatorHandler.rpc_deactivate_oneshot_mutator_client = function(self, mutator_id)
    -- Copy of 'rpc_oneshot_mutator_client' to circumvent mutator_id bounds (max 128).
  fassert(not self._is_server, "Only call rpc_deactivate_mutator_client on clients.")

  local mutator_name = NetworkLookup.mutator_templates[mutator_id]
  local active_mutators = self._active_mutators
  local mutator_context = self._mutator_context

  self:_deactivate_mutator(mutator_name, active_mutators, mutator_context)
end

mod:hook(MutatorHandler, "_activate_mutator", function(func, self, name, active_mutators, mutator_context, mutator_data, optional_duration)
  -- Almost full copy to circumvent mutator_id bounds (max 128).
	fassert(active_mutators[name] == nil, "Can't have multiple of same mutator running at the same time (%s)", name)

	if not MutatorTemplates[name] then
		mutator_print("No such template (%s)", name)
    mod:dump(MutatorTemplates, "MutatorTemplates", 0)
		return
	end

	mutator_print("Activating mutator '%s'", name)

	local template = MutatorTemplates[name]
	mutator_data = mutator_data or {
		template = template
	}

	if optional_duration then
		local t = Managers.time:time("game")
		mutator_data.deactivate_at_t = t + optional_duration
	end

	if self._is_server then
		local server_template = template.server

		if server_template.start_function then
			server_template.start_function(mutator_context, mutator_data)
		end
	end

	if self._has_local_client then
		local client_template = template.client

		if client_template.start_function then
			client_template.start_function(mutator_context, mutator_data)
		end
	end

	if template.register_rpcs then
		template.register_rpcs(mutator_context, mutator_data, self.network_event_delegate)
	end

	active_mutators[name] = mutator_data

	if self._is_server then
		local mutator_id = NetworkLookup.mutator_templates[name]
		local activated_by_twitch = not not mutator_data.activated_by_twitch

     -- This part differs from game logic.
    if mutator_id < 256 then
      self._network_transmit:send_rpc_clients("rpc_activate_mutator_client", mutator_id, activated_by_twitch)
    else
      mod:info("RPC: activate-oneshot-mutator-client")
      mod:network_send("activate-oneshot-mutator-client", "others", mutator_id, activated_by_twitch)
    end
	end
end)

mod:hook(MutatorHandler, "_deactivate_mutator", function(func, self, name, active_mutators, mutator_context, is_destroy)
  -- Almost full copy to circumvent mutator_id bounds (max 128).
	fassert(active_mutators[name], "Trying to deactivate mutator (%s) but it isn't active", name)
	mutator_print("Deactivating mutator '%s'", name)

	local template = MutatorTemplates[name]
	local mutator_data = active_mutators[name]

	if template.unregister_rpcs then
		template.unregister_rpcs(mutator_context, mutator_data)
	end

	if self._is_server then
		local server_template = template.server

		if server_template.stop_function then
			server_template.stop_function(mutator_context, mutator_data, is_destroy)
		end
	end

	if self._has_local_client then
		local client_template = template.client

		if client_template.stop_function then
			client_template.stop_function(mutator_context, mutator_data, is_destroy)
		end
	end

	active_mutators[name] = nil
	self._mutators[name] = nil

	if self._is_server and not is_destroy then
		local mutator_id = NetworkLookup.mutator_templates[name]

    -- This part differs from game logic.
    if mutator_id < 256 then
		  self._network_transmit:send_rpc_clients("rpc_deactivate_mutator_client", mutator_id)
    else
      mod:info("RPC: deactivate-oneshot-mutator-client")
      mod:network_send("deactivate-oneshot-mutator-client", "others", mutator_id)
      self:free_oneshot_mutator_id(name)
    end
	end
end)

-- MutatorHandler extensions.
MutatorHandler.create_oneshot_mutator = function(self, mutator_name, mutator_name_oneshot, mutator_id,
                                                       oneshot_settings)
  mod:info("Creating oneshot mutator '" .. mutator_name .. "' with ID=" .. mutator_id)

  -- Create oneshot mutator template.
  local template_oneshot = table.clone(MutatorTemplates[mutator_name])
  template_oneshot.oneshot_settings = oneshot_settings
  MutatorTemplates[mutator_name_oneshot] = template_oneshot

  -- Register network lookup.
  local index_oneshot = mutator_id
  NetworkLookup.mutator_templates[index_oneshot] = mutator_name_oneshot
  NetworkLookup.mutator_templates[mutator_name_oneshot] = index_oneshot
end

MutatorHandler.get_oneshot_mutator_id = function(self)
  local MUTATOR_ID_START = 2000
  local mutator_id = nil

  if self.mutator_id_free_list == nil then
    self.mutator_id_free_list = GrowQueue:new()
  end

  if self.next_free_mutator_id == nil then
    self.next_free_mutator_id = MUTATOR_ID_START
  end

  if self.mutator_id_free_list:size() == 0 then
    mutator_id = self.next_free_mutator_id
    self.next_free_mutator_id = self.next_free_mutator_id + 1
  else
    mutator_id = self.mutator_id_free_list:pop_first()
  end

  mod:dump(self.mutator_id_free_list.queue, "ONESHOT MUTATOR ID: mutator_id_free_list", 1)

  return mutator_id
end

MutatorHandler.free_oneshot_mutator_id = function(self, mutator_name)
  local mutator_id = NetworkLookup.mutator_templates[mutator_name]
  self.mutator_id_free_list:push_back(mutator_id)
  mod:dump(self.mutator_id_free_list.queue, "ONESHOT MUTATOR ID: mutator_id_free_list", 1)
end

MutatorHandler.activate_mutator_one_shot = function(self, mutator_name, oneshot_settings, optional_duration,
                                                    optional_flag)
  if self._is_server then
    local mutator_context = self._mutator_context
    local active_mutators = self._active_mutators
    local data = self._mutators[mutator_name]

    local mutator_name_oneshot = mutator_name .. "_" .. tostring(oneshot_settings.uid)

    if not self:has_activated_mutator(mutator_name_oneshot) then
      -- Prepare oneshot mutator name and send RPC event.
      local mutator_id = self:get_oneshot_mutator_id()
      mod:network_send("create-oneshot-mutator", "all", mutator_name, mutator_name_oneshot, mutator_id, oneshot_settings)

      self:initialize_mutators({ mutator_name_oneshot })
      self:_activate_mutator(mutator_name_oneshot, active_mutators, mutator_context, data, optional_duration)
    end
  end
end
