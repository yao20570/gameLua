
MsgCenter = class("MsgCenter")

function MsgCenter:ctor()
    self._listeners = {}
end

function MsgCenter:finalize()
    self._listeners = {}
end

function MsgCenter:reset()
    self._listeners = {}
end

function MsgCenter:addEventListener(mainevent, subevent, object, fun)

    if mainevent == nil or subevent == nil then
        logger:error("cMsgCenter:addEventListener, mainevent or subevent is null!" .. debug.traceback())
        return
    end

    if self._listeners[mainevent] == nil then
        self._listeners[mainevent] = {}
    end
    if self._listeners[mainevent][subevent] == nil then
        self._listeners[mainevent][subevent] = {}
    end
    local listeners = self._listeners[mainevent][subevent]

    for key,value in pairs(listeners) do
        if value.object == object then
            if value.fun == fun then
                return false
            end
        end
    end

    local listener = {}
    listener.object = object
    listener.fun    = fun
    table.insert(listeners, listener)
    return true
end

function MsgCenter:removeEventListener(mainevent, subevent, object, fun)

    if mainevent == nil or subevent == nil then
        logger:error("MsgCenter:removeEventListener, mainevent or subevent is null!")
        return
    end

    if self._listeners[mainevent] == nil or
        self._listeners[mainevent][subevent] == nil then
        return false
    end
    local listeners = self._listeners[mainevent][subevent]

    for key,value in pairs(listeners) do
        if value.object == object then
            if value.fun == fun then
                table.remove(listeners, key)
                return true
            end
        end
    end

    return false
end

function MsgCenter:sendNotification(mainevent, subevent, data)
    if mainevent == nil or subevent == nil then
        logger:error("MsgCenter:sendNotification, mainevent or subevent is null!" .. debug.traceback())
        return
    end

--    local socket = require("socket")
--    local s = socket.gettime() 

    if self._listeners[mainevent] ~= nil and
        self._listeners[mainevent][subevent] ~= nil then

        local listeners = self._listeners[mainevent][subevent]

        for key, listener in pairs(listeners) do
            --print("MsgCenter:sendNotification mainevent:%s, subevent:%s ==> callback()", mainevent, subevent)
            local object    = listener.object
            local fun       = listener.fun
            fun(object, data)
        end
    end


--    local dt = os.clock() - s
--    if dt > 0.005 then
--        print("超过5毫秒的信息处理 ====>time:%f, mainevent:%s, subevent:%s", socket.gettime() - s, mainevent, subevent)
--        print("超过5毫秒的信息处理 ====>" .. debug.traceback())
--    end
end

--7738 【真外网】主城界面的兵营建筑等级显示不正确。 已修复
--这个是为了多个统一消息
function MsgCenter:delaySendNotification(mainevent, subevent, data)    
    if data == nil or next(data) == nil then  
        -- 如果只是发送消息更新，只更新最后一次
        self._delayListeners = self._delayListeners or {}
        self._delayListeners[mainevent] = self._delayListeners[mainevent] or {}    
        self._delayListeners[mainevent][subevent] = subevent

        TimerManager:addOnce(1, self.delaySend, self)
    else
        self:sendNotification(mainevent, subevent, data)
    end
end

function MsgCenter:delaySend()
    if self._delayListeners == nil then
        return
    end

    for mainevent, subevents in pairs(self._delayListeners) do
        for _, subevent in pairs(subevents) do
            self:sendNotification(mainevent, subevent, nil)
        end
    end
    self._delayListeners = nil
end