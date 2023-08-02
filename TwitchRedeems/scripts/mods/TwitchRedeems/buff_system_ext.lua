local mod = get_mod("TwitchRedeems")

mod:info("Initializing BuffSystem extension")

-- Register oneshot mutator RPC.
mod:network_register("create-oneshot-buff",
  function(peer_id, buff_name, buff_name_oneshot, buff_id, oneshot_buff_template)
    Managers.state.event:trigger("event_create_oneshot_buff", buff_name, buff_name_oneshot, buff_id, oneshot_buff_template)
  end)

mod:hook_safe(BuffSystem, "init",
  function(self, entity_system_creation_context, system_name)
    Managers.state.event:register(self, "event_create_oneshot_buff", "create_oneshot_buff")
  end)

-- BuffSystem extensions.
BuffSystem.create_oneshot_buff = function(self, buff_name, buff_name_oneshot, buff_id, oneshot_buff_template)
  mod:info("Creating oneshot buff '" .. buff_name_oneshot .. "' with ID=" .. buff_id)

  -- Create oneshot buff template.
  --local template_oneshot = table.clone(BuffTemplates[buff_name]) -- we sent whole template
  BuffTemplates[buff_name_oneshot] = oneshot_buff_template

  -- Register network lookup.
  local index_oneshot = buff_id
  NetworkLookup.buff_templates[index_oneshot] = buff_name_oneshot
  NetworkLookup.buff_templates[buff_name_oneshot] = index_oneshot
end

BuffSystem.get_oneshot_buff_id = function(self)
  local BUFF_ID_START = 2500
  local buff_id = nil

  if self.buff_id_free_list == nil then
    self.buff_id_free_list = GrowQueue:new()
  end

  if self.next_free_buff_id == nil then
    self.next_free_buff_id = BUFF_ID_START
  end

  if self.buff_id_free_list:size() == 0 then
    buff_id = self.next_free_buff_id
    self.next_free_buff_id = self.next_free_buff_id + 1
  else
    buff_id = self.buff_id_free_list:pop_first()
  end

  mod:dump(self.buff_id_free_list.queue, "ONESHOT BUFF ID: buff_id_free_list", 1)

  return buff_id
end


BuffSystem.free_oneshot_buff_id = function(self, buff_name)
  local buff_id = NetworkLookup.buff_templates[buff_name]
  self.buff_id_free_list:push_back(buff_id)
  mod:dump(self.buff_id_free_list.queue, "ONESHOT BUFF ID: buff_id_free_list", 1)
end

BuffSystem.add_oneshot_buff = function(self, buff_name, buff_id, oneshot_buff_template)
  if self.is_server then
    local buff_name_oneshot = buff_name .. "_" .. tostring(oneshot_buff_template.uid)

    --local buff_id = self:get_oneshot_buff_id()
    mod:network_send("create-oneshot-buff", "all", buff_name, buff_name_oneshot, buff_id, oneshot_buff_template)

    -- if not self:has_activated_mutator(mutator_name_oneshot) then
    --   -- Prepare oneshot mutator name and send RPC event.
    --   local mutator_id = self:get_oneshot_mutator_id()
    --   mod:network_send("create-oneshot-mutator", "all", mutator_name, mutator_name_oneshot, mutator_id, oneshot_settings)

    --   self:initialize_mutators({ mutator_name_oneshot })
    --   self:_activate_mutator(mutator_name_oneshot, active_mutators, mutator_context, data, optional_duration)
    -- end
    return buff_name_oneshot
  end
  return nil
end