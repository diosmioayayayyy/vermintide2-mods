local mod = get_mod("TwitchRedeems")

mod:dofile("scripts/mods/TwitchRedeems/Gui/ImguiWindow")
mod:dofile("scripts/mods/TwitchRedeems/Redeem/RedeemUnit")

if not INCLUDE_GUARDS.BREED_EDITOR then
  INCLUDE_GUARDS.BREED_EDITOR = true

  local save_filename = "twitch_redeem_breeds"

  local function create_redeem_breeds_gui_dropdown_list()
    local gui_dropdown_list = {}

    for _, redeem_breed in pairs(mod.redeem_breeds) do
      table.insert(gui_dropdown_list, redeem_breed.data.name)
    end

    return gui_dropdown_list
  end

  BreedEditor = class(BreedEditor)

  BreedEditor.init = function(self)
    self.imgui_window = ImguiWindow:new()
    self.imgui_window.title = "Breed Editor"
    self.imgui_window.key = self

    self.gui_dropdown_redeem_breed = {}
    self.gui_dropdown_redeem_breed_index = nil
    self.redeem_breed = nil

    self:load_settings()
  end

  BreedEditor.toggle_gui_window = function(self)
    self.imgui_window.show_window = not self.imgui_window.show_window
  end

  BreedEditor.save_settings = function(self)
    local data_to_save = {}
    for _, redeem_breed in ipairs(mod.redeem_breeds) do
      table.insert(data_to_save, redeem_breed.data)
    end
    Managers.save:auto_save(save_filename, data_to_save, nil, true)
  end

  BreedEditor.cb_load_twitch_redeem_breeds_from_file_done = function(self, result)
    mod.redeem_breeds = {}
    if result.data then
      for key, raw_redeem_breed in pairs(result.data) do
        mod.redeem_breeds[key] = RedeemUnit:new(raw_redeem_breed)
      end
    else
      mod:info("BreedEditor: Could not load data from file '" .. save_filename .. "'")
    end

    self.gui_dropdown_redeem_breed = create_redeem_breeds_gui_dropdown_list() -- TODO code dedup
    self.gui_dropdown_redeem_breed_index = math.min(1, #self.gui_dropdown_redeem_breed)
  end

  BreedEditor.load_settings = function(self)
    Managers.save:auto_load(save_filename, callback(self, "cb_load_twitch_redeem_breeds_from_file_done"), false)
  end

  BreedEditor.render_ui = function(self)
    local window_open = self.imgui_window:begin_window()
    if window_open then
      if Imgui.button("   New Breed    ") then
        table.insert(mod.redeem_breeds, RedeemUnit:new())
        table.sort(mod.redeem_breeds, function(a, b) return a.data.name < b.data.name end)
        self.gui_dropdown_redeem_breed = create_redeem_breeds_gui_dropdown_list()     -- TODO code dedup
        self.gui_dropdown_redeem_breed_index = #self.gui_dropdown_redeem_breed
      end

      if self.gui_dropdown_redeem_breed_index and self.gui_dropdown_redeem_breed_index > 0 then
        self.redeem_breed = mod.redeem_breeds[self.gui_dropdown_redeem_breed_index]
      else
        self.redeem_breed = nil
      end

      Imgui.same_line()

      if self.redeem_breed and Imgui.button("  Clear Breeds  ") then
        mod.redeem_breeds = {}
        self.gui_dropdown_redeem_breed = create_redeem_breeds_gui_dropdown_list()     -- TODO code dedup
        self.gui_dropdown_redeem_breed_index = math.min(self.gui_dropdown_redeem_breed_index,
          #self.gui_dropdown_redeem_breed)
      end

      Imgui.separator()

      if Imgui.button("  Save Breeds   ") then
        self:save_settings()
      end

      Imgui.same_line()

      if Imgui.button("  Load Breeds   ") then
        self:load_settings()
      end

      Imgui.same_line()

      if self.redeem_breed and Imgui.button("  Delete Breed  ") then
        table.remove(mod.redeem_breeds, self.gui_dropdown_redeem_breed_index)
        self.gui_dropdown_redeem_breed = create_redeem_breeds_gui_dropdown_list()     -- TODO code dedup
        self.gui_dropdown_redeem_breed_index = math.min(self.gui_dropdown_redeem_breed_index,
          #self.gui_dropdown_redeem_breed)
      end

      if self.redeem_breed then
        Imgui.separator()

        self.gui_dropdown_redeem_breed_index = Imgui.combo("Redeem Breed", self.gui_dropdown_redeem_breed_index,
          self.gui_dropdown_redeem_breed, 5)

        Imgui.separator()

        if self.redeem_breed then
          local prev_name = self.redeem_breed.data.name
          self.redeem_breed.data.name = Imgui.input_text("Name", self.redeem_breed.data.name)
          if prev_name ~= self.redeem_breed.data.name then
            self.gui_dropdown_redeem_breed = create_redeem_breeds_gui_dropdown_list() -- TODO
          end
          self.redeem_breed.data.breed_index = Imgui.combo("Base Breed", self.redeem_breed.data.breed_index, GuiDropdownBaseBreedsLocalized, 5)
          self.redeem_breed.data.breed_name = GuiDropdownBaseBreeds[self.redeem_breed.data.breed_index] -- Breeds[GuiDropdownBaseBreeds[self.redeem_breed.data.breed_index]]
        end

        Imgui.separator()
        Imgui.text("Properties")
        -- TODO
      end

      self.imgui_window:end_window()
    end
    return window_open
  end
end
