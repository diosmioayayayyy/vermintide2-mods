local mod = get_mod("TwitchRedeems")

if not INCLUDE_GUARDS.AMOUNT then
  INCLUDE_GUARDS.AMOUNT = true

  Amount = class(Amount)

  Amount.init = function(self, other, min, max)
    self.data = {
      min = min or 1,
      max = max or 1,
      random = false,
    }

    if other and type(other) == 'table' then
      for key, value in pairs(other) do
        self.data[key] = other[key]
      end
    end
  end

  Amount.serialize = function(self)
    local data = {}
    data.min = self.data.min
    data.max = self.data.max
    data.random = self.data.random
    return data
  end

  Amount.get = function(self)
    return self.data.random and math.random(self.data.min, self.data.max) or self.data.min
  end

  Amount.render_ui = function(self, text)
    text = text or "Amount"
    Imgui.text(text)
    Imgui.same_line()
    self.data.random = Imgui.checkbox("Random##" .. tostring(self), self.data.random)
    Imgui.same_line()
    if self.data.random then
      self.data.min = Imgui.input_int("Min##Amount" .. tostring(self), self.data.min)
      self.data.max = math.max(math.max(self.data.max, self.data.min), 0)
      Imgui.same_line()
      self.data.max = Imgui.input_int("Max##Amount" .. tostring(self), self.data.max)
      self.data.min = math.max(math.min(self.data.max, self.data.min), 0)
    else
      self.data.min = Imgui.input_int("##Amount" .. tostring(self), self.data.min)
    end
  end
end
