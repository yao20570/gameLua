----------
---UI 动画- Action---队列----
UIActionQueue = class("UIActionQueue")

function UIActionQueue:ctor(runcallback, obj, completeCallback)
    self._runcallback = runcallback
    self._completeCallback = completeCallback
    self._obj = obj
    
    self._queue = Queue.new()    
    
    self._isRunning = false
end


function UIActionQueue:push(data)
    if self._isRunning == true then
        self._queue:push(data)
    else
        self:run(data)
    end
end

function UIActionQueue:run(data)
    self._isRunning = true
    self._runcallback(self._obj, data)
end

function UIActionQueue:isRunning()
    return self._isRunning
end


function UIActionQueue:actionComplete()
    TimerManager:addOnce(30,self.delayNextAction,self)
end

function UIActionQueue:delayNextAction()
    self._isRunning = false

    if self._completeCallback ~= nil then
        self._completeCallback()
    end
    
    local data = self._queue:pop()
    if data ~= nil then
        self:run(data)
    end
end





