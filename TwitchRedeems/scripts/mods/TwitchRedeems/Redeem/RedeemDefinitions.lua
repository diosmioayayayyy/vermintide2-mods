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

  BuffType = {
    SPEED = 1,
    STRENGTH = 2,
    COOLDOWN_REDUCTION = 2,
    HEALTH_REGEN = 3,
    GRIM_HEALTH_DEBUFF = 4,
    POWER_BOOST_DISMEMBER = 5,
    BLIGHTREAPER_CURSE = 6,
    CHANGE_DODGE_SPEED = 7,
    CHANGE_DODGE_DISTANCE = 8,
    SURVIVAL_ALE = 9,
    SUPER_JUMP = 10,
    INVISIBILITY = 11,
    CRITS = 12,
    INFINITE_BOMBS = 13,
    INVINCIBILITY = 14,
    PULSATING_WAVES = 15,
  }

  BuffName = {
    "twitch_speed_boost",
    "twitch_damage_boost",
    "twitch_cooldown_reduction_boost",
    "twitch_health_regen",
    "twitch_grimoire_health_debuff",
    "twitch_power_boost_dismember",
    "blightreaper_curse",
    "change_dodge_speed",
    "change_dodge_distance",
    "bardin_survival_ale_buff",
    "super_jump",
    "twitch_vote_buff_invisibility",
    "twitch_vote_buff_critical_strikes",
    "twitch_vote_buff_infinite_bombs",
    "twitch_vote_buff_invincibility",
    "twitch_vote_buff_pulsating_waves",
  }

  GuiDropdownBuffs = {
    "Speed",
    "Strength",
    "Cooldown Reduction",

    "Health Regen",
    "Grimoire Health Debuff",
    "Power Boost Dismember",
    "Blightreaper Curse",
    "Change Dodge Speed",
    "Change Dodge Distance",
    "Survival Ale Buff",
    "Super Jump",
    "Invisibility",
    "Critical Strikes",
    "Infinite Bombs",
    "Invincibility",
    "Pulsating Waves",
  }

  MutatorType = {
    COMRADESHIP = 1,
    DARKNESS = 2,
    LIGHTNING = 3,
    TICKING_BOMB = 4,
    TWINS = 5,
    SLAYER_CURSE = 6,
    BLOODLUST = 7,
    ACT_ON_INSTINCT = 8,
    CHASING_SPIRITS = 9,
    WEAPONS_ABLAZE = 10,

  --   LIFE = 20,
  --   METAL = 21,
  --   HEAVENS = 22,
  --   LIGHT = 23,
  --   SHADOW = 24,
  --   FIRE = 25,
  --   DEATH = 26,
  --   BEASTS = 27,

    CORPSE_EXPLOSION = 40,
    POWERFUL_ELITES = 41,
    HIGH_INTENSITY = 42,
    SHARED_HEALTH_POOL = 43,

    GEHEIMNISNACHT = 70,

    GRAVITY = 100,
    GAMESPEED = 101,
  }

  MutatorName = {
    "leash",
    "twitch_darkness",
    "lightning_strike",
    "ticking_bomb",
    "splitting_enemies",
    "slayer_curse",
    "bloodlust",
    "realism",
    "chasing_spirits",
    "flames",

    -- "life",
    -- "metal",
    -- "heavens",
    -- "light",
    -- "shadow",
    -- "fire",
    -- "death",
    -- "beasts",

    "corpse_explosion",
    "powerful_elites",
    "high_intensity",
    "shared_health_pool",

    "geheimnisnacht_2021_hard_mode",

    "twitch_redeems_gravity_mutator",
    "twitch_redeems_gamespeed_mutator",
  }

  MutatorTypeLookup = {
    MutatorType.COMRADESHIP,
    MutatorType.DARKNESS,
    MutatorType.LIGHTNING,
    MutatorType.TICKING_BOMB,
    MutatorType.TWINS,
    MutatorType.SLAYER_CURSE,
    MutatorType.BLOODLUST,
    MutatorType.ACT_ON_INSTINCT,
    MutatorType.CHASING_SPIRITS,
    MutatorType.WEAPONS_ABLAZE,

  --   MutatorType.LIFE = 20,
  --   MutatorType.METAL = 21,
  --   MutatorType.HEAVENS = 22,
  --   MutatorType.LIGHT = 23,
  --   MutatorType.SHADOW = 24,
  --   MutatorType.FIRE = 25,
  --   MutatorType.DEATH = 26,
  --   MutatorType.BEASTS = 27,

    MutatorType.CORPSE_EXPLOSION,
    MutatorType.POWERFUL_ELITES,
    MutatorType.HIGH_INTENSITY,
    MutatorType.SHARED_HEALTH_POOL,

    MutatorType.GEHEIMNISNACHT,

    MutatorType.GRAVITY,
    MutatorType.GAMESPEED,
  }

  GuiDropdownMutators = {
    "Curse of Comradeship",
    "Darkness",
    "Lightning",
    "Ticking Bomb",
    "Twins",
    "Mark of Khorne",
    "Curse of Tainted Blood",
    "Act on Instinct",
    "Chasing Spirit",
    "Weapons Ablaze",

    -- "life",
    -- "metal",
    -- "heavens",
    -- "light",
    -- "shadow",
    -- "fire",
    -- "death",
    -- "beasts",

    "Explosive Corpses",
    "Powerful Elites",
    "High Intensity",
    "Shared Health Pool",

    "Geheimnisnacht",

    "Gravity",
    "Gamespeed",
  }

  EventType = {
    HORDE = 1,
    HORDE_BLOB = 2,
    AMBUSH = 3,
    RANDOM_HORDE = 4,
  }

  GuiDropdownEvents = {
    "Horde",
    "Horde Blob",
    "Ambush",
    "Random Horde"
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
