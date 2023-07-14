RedeemQueue = class(RedeemQueue)

function RedeemQueue:init()
  self._queue = GrowQueue:new()
end

function RedeemQueue:pop()
    return self._queue:pop_first()
end

function RedeemQueue:push(element)
    element = self._queue:push_back(element)
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
