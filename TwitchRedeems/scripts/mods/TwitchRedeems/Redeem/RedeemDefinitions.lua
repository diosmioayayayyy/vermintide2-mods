local mod = get_mod("TwitchRedeems")

SpawnType = {
    HORDE = 1,
    HIDDEN = 2,
    ONE = 3,
 }

 SpawnPosition = {
    FRONT = 1,
    BACK = 2,
    RANDOM = 3,
 }

 GuiDropdownBreeds = {}
 GuiDropdownBreedsLocalized = {}

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

for breed_name, data in pairs(Breeds) do
   if not table.contains(breed_backlist, breed_name) then
      table.insert(GuiDropdownBreeds, breed_name)
   end
end

table.sort(GuiDropdownBreeds, function(a, b) return a < b end)

for _, breed_name in pairs(GuiDropdownBreeds) do
   table.insert(GuiDropdownBreedsLocalized, Localize(breed_name))
end

mod:dump(GuiDropdownBreedsLocalized, "GuiDropdownBreedsLocalized", 0)