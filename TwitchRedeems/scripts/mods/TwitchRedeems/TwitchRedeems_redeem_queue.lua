RedeemQueue = class(RedeemQueue)

function RedeemQueue:init()
  self._queue = GrowQueue:new()
  self._timer = nil
  self._cooldown = 5.0
end

function RedeemQueue:update(dt)
    if self._timer ~= nil then
        self._timer = self._timer + dt

        if self._timer > self._cooldown then
            self._timer = nil
        end
    end
end

function RedeemQueue:pop()
    local element = nil
    if not self:is_on_cooldown() then
        element = self._queue:pop_first()
        self._timer = 0.0
    end
    return element
end

function RedeemQueue:push(element)
    element = self._queue:push_back(element)
end

function RedeemQueue:set_cooldown(time)
    self._cooldown = time
end

function RedeemQueue:is_on_cooldown()
    return self._timer ~= nil
end

function RedeemQueue:size()
    return self._queue:size()
end

function RedeemQueue:empty()
    return self._queue:size() == 0
end

function RedeemQueue:clear()
    while self._queue:size() > 0 do
        self._queue:pop_first()
    end
end
