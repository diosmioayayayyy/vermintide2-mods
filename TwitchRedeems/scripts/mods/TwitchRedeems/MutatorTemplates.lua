local mod = get_mod("TwitchRedeems")

mod:info("Processing mutator templates...")

-- List of mutators to inject to game.
mod.mutator_templates = {}

-- Inject modded mutators to mutator_settings. Kinda hacky but works.

mod:hook(_G, "local_require", function(func, path, ...)
  if (path == "scripts/settings/mutator_settings") then
    local templates = func(path)
    return table.merge(templates, mod.mutator_templates)
  end
  return func(path, ...)
end)

-- Load modded mutators.
mod:dofile("scripts/mods/TwitchRedeems/Mutators/GameSpeed")
mod:dofile("scripts/mods/TwitchRedeems/Mutators/Gravity")
-- Add new mutators here!

-- Process modded mutators.
mod:dofile("scripts/managers/game_mode/mutator_templates")


function create_twitch_redeems_mutator(mutator_type, other)
  local mutator = nil
  if mutator_type == MutatorType.GRAVITY then
    mutator = MutatorGravity:new(other)
  elseif mutator_type == MutatorType.GAMESPEED then
    mutator = MutatorGameSpeed:new(other)
  end
  return mutator
end