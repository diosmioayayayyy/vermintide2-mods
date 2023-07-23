local mod = get_mod("TwitchRedeems")

mod:info("Initializing MutatorHandler extension")

-- Register oneshot mutator RPC.
mod:network_register("create-oneshot-mutator", function(peer_id, mutator_name, mutator_name_oneshot, oneshot_settings)
  Managers.state.event:trigger("create_oneshot_mutator", mutator_name, mutator_name_oneshot, oneshot_settings)
end)

mod:hook_safe(MutatorHandler, "init",
  function(self, mutators, is_server, has_local_client, world, network_event_delegate, network_transmit)
    Managers.state.event:register(self, "create_oneshot_mutator", "event_create_oneshot_mutator")
  end)

-- MutatorHandler extensions.
MutatorHandler.event_create_oneshot_mutator = function(self, mutator_name, mutator_name_oneshot, oneshot_settings)
  mod:info("Creating oneshot mutator: " .. mutator_name)

  -- Create oneshot mutator template.
  local template_oneshot = table.clone(MutatorTemplates[mutator_name])
  template_oneshot.oneshot_settings = oneshot_settings
  MutatorTemplates[mutator_name_oneshot] = template_oneshot

  -- Register network lookup.
  local index_oneshot = 1500 -- TODO idgen
  NetworkLookup.mutator_templates[index_oneshot] = mutator_name_oneshot
  NetworkLookup.mutator_templates[mutator_name_oneshot] = index_oneshot
end

MutatorHandler.activate_mutator_one_shot = function(self, mutator_name, oneshot_settings, optional_duration, optional_flag)
  if self._is_server then
    local mutator_context = self._mutator_context
    local active_mutators = self._active_mutators
    local data = self._mutators[mutator_name]

    -- Prepare oneshot mutator name and send RPC event.
    local mutator_name_oneshot = mutator_name .. "_" .. tostring(oneshot_settings.uid)
    mod:network_send("create-oneshot-mutator", "all", mutator_name, mutator_name_oneshot, oneshot_settings)

    if not self:has_activated_mutator(mutator_name_oneshot) then
      self:initialize_mutators({ mutator_name_oneshot })
      self:_activate_mutator(mutator_name_oneshot, active_mutators, mutator_context, data, optional_duration)
    end
  end
end
