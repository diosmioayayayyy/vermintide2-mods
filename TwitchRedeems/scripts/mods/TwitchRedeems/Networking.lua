local mod = get_mod("TwitchRedeems")

if not INCLUDE_GUARDS.NETWORKING then
  INCLUDE_GUARDS.NETWORKING = true

  mod:network_register("new-redemption", function(peer_id, redemption)
    Managers.state.event:trigger("twitch_redeem_ui", redemption)
  end)

  -- mod:network_register("send-custom-breeds", function(peer_id, custom_breeds)
  --   mod:info("Receiving custom breeds from " .. tostring(peer_id))
  --   mod:dump(custom_breeds, "custom_breeds", 2)
  -- end)

  -- mod:network_register("send-custom-mutators", function(peer_id, custom_mutators)
  --   mod:info("Receiving custom mutators from " .. tostring(peer_id))
  --   mod:dump(custom_mutators, "custom_mutators", 2)
  -- end)

  -- mod:network_register("send-custom-buffs", function(peer_id, custom_buffs)
  --   mod:info("Receiving custom mutators from " .. tostring(peer_id))
  --   mod:dump(custom_buffs, "custom_mutators", 2)
  -- end)

  -- mod:network_register("send-client_redeems", function(peer_id, client_redeems)
  --   mod:info("Receiving client redeems from " .. tostring(peer_id))
  --   mod:dump(client_redeems, "client_redeems", 2)
  -- end)
end