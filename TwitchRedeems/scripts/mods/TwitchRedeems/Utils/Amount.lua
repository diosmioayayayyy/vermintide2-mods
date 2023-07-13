local mod = get_mod("TwitchRedeems")

if not INCLUDE_GUARDS.AMOUNT then
  INCLUDE_GUARDS.AMOUNT = true

  Amount = class(Amount)
  Amount.init = function(self, other)
    self.min = 1
    self.max = 1
    self.random = false

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        self.data[key] = other[key]
      end
    end
  end

  Amount.serialize = function(self)
    local data = {}
    data.min = self.min
    data.max = self.max
    data.random = self.random
    return data
  end

  Amount.render_ui = function(self)
    Imgui.text("Amount")
    Imgui.same_line()
    self.random = Imgui.checkbox("Random##" .. tostring(self), self.random)
    Imgui.same_line()
    if self.random then
      self.min = Imgui.input_int("Min##Amount" .. tostring(self), self.min)
      self.max = math.max(math.max(self.max, self.min), 0)
      Imgui.same_line()
      self.max = Imgui.input_int("Max##Amount" .. tostring(self), self.max)
      self.min = math.max(math.min(self.max, self.min), 0)
    else
      self.min = Imgui.input_int("##Amount" .. tostring(self), self.min)
    end
  end
end
