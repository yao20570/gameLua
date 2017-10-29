
EventDispatcher = class("EventDispatcher")
function EventDispatcher:ctor()
    self._listeners = {}
end

function EventDispatcher:finalize()
    self._listeners = nil
end

function EventDispatcher:addEventListener(event, object, fun)

    if self._listeners[event] == nil then
        self._listeners[event] = Vector.new()
    end

    local bFind = false
    self._listeners[event]:foreach(
        function(idx, listener)
            if listener.object == object then
                if listener.fun == fun then
                    bFind = true
                    return false
                end
            end
        end
    )

    if bFind == true then
        logger:warn("EventDispatcher:addEventListener, the listener is exist!!")
        return false
    end

    local listener = {}
    listener.object = object
    listener.fun    = fun

    self._listeners[event]:push_back(listener)

    return true
end

function EventDispatcher:removeEventListener(event, object, fun)
    if self._listeners[event] == nil then
        return false
    end

    local bFind = false
    self._listeners[event]:foreach(
        function(idx, listener)
            if listener.object == object then
                if listener.fun == fun then
                    self._listeners[event]:erase(idx)
                    bFind = true
                    return false
                end
            end
        end
    )
    return bFind
end

function EventDispatcher:dispatchEvent(event, data)

    if self._listeners[event] == nil then
        return
    end

    self._listeners[event]:foreach(
        function(idx, listener)
            local object    = listener.object
            local fun       = listener.fun
            if fun ~= nil then
                fun(object, data)
            end
        end
    )
end