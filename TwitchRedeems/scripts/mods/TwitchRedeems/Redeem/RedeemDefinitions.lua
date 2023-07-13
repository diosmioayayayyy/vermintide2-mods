local mod = get_mod("TwitchRedeems")

if not INCLUDE_GUARDS.REDEEM_DEFINITIONS then
  INCLUDE_GUARDS.REDEEM_DEFINITIONS = true

  SpawnType = {
    HORDE = 1,
    HIDDEN = 2,
    ONE = 3,
  }

  GuiDropdownSpawnType = {
    "Horde", "Hidden", "One"
  }

  SpawnPosition = {
    FRONT = 1,
    BACK = 2,
    RANDOM = 3,
  }

  GuiDropdownSpawnPosition = {
    "Front", "Back", "Random"
  }

  local breed_backlist = {
    "beastmen_ungor_dummy",
    "skaven_storm_vermin_commander",
    "tower_homing_skull",
    "beastmen_gor_dummy",
    "beastmen_bestigor_dummy",
    "curse_mutator_sorcerer",
    "chaos_zombie",
    "chaos_dummy_exalted_sorcerer_drachenfels",
    "chaos_tentacle_sorcerer",
    "chaos_dummy_sorcerer",
    "chaos_plague_wave_spawner",
    "skaven_dummy_clan_rat",
    "chaos_dummy_troll",
    "chaos_spawn_exalted_champion_norsca",
    "skaven_dummy_slave",
    "shadow_totem",
    "shadow_skull",
    "beastmen_standard_bearer_crater",
    "skaven_storm_vermin_champion",
    "skaven_stormfiend_demo",
    "skaven_clan_rat_tutorial",
    "chaos_vortex",
    "chaos_plague_sorcerer",
    "chaos_marauder_tutorial",
    "chaos_tentacle",
    "chaos_raider_tutorial",
  }

  GuiDropdownBaseBreeds = {}
  GuiDropdownBaseBreedsLocalized = {}

  for breed_name, data in pairs(Breeds) do
    if not table.contains(breed_backlist, breed_name) then
      table.insert(GuiDropdownBaseBreeds, breed_name)
    end
  end

  table.sort(GuiDropdownBaseBreeds, function(a, b) return a < b end)

  for _, breed_name in pairs(GuiDropdownBaseBreeds) do
    table.insert(GuiDropdownBaseBreedsLocalized, Localize(breed_name))
  end
end
