local mod = get_mod("TwitchRedeems")

-- TODO Timer name already taken xdd

if not INCLUDE_GUARDS.Timer2 then
  INCLUDE_GUARDS.Timer2 = true

  Timer2 = class(Timer2)

  Timer2.init = function(self, duration)
    self.duration = duration
    self._timer = 0
    self._expired = true
  end

  Timer2.start = function(self)
    self._timer = 0
    self:reset()
  end

  Timer2.update = function(self, dt)
    if not self._expired then
      self._timer = self._timer + dt

      if self._timer >= self.duration then
        self._expired = true
        return true
      end
    end
    return false
  end

  Timer2.reset = function(self)
    self._timer = 0
    self._expired = false
  end
end