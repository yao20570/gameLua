
----[[
--基础数据代理类
--所有的业务逻辑都是基于数据驱动
--业务逻辑必须定义一个数据类
--只有该数据类有同步服务端数据的行为
--增、删、改、查
--业务逻辑不能污染该数据类，比如强制把配置数据复制到data里面去
--获取数据，只能通过相对应的接口
--数据层，不会调用相关的显示UI操作
-----]]

BasicProxy = class("BasicProxy")

function BasicProxy:ctor()
    self._msgCenter = nil
    self.proxyName = nil
    self._game = nil
    self._remainTimeMap = {} --保存相关定时器数据，用来处理定时器触发的同步
    
    self._netReqTimeMap = {} --保存网络请求时间，算出每个操作的网络延迟
end

function BasicProxy:getProxyName()
    return self.proxyName
end

function BasicProxy:finalize()
    self:unregisterNetEvents()
    self._msgCenter = nil
    self.proxyName = nil
    self._game = nil
    self._remainTimeMap = {}
end

function BasicProxy:resetAttr()
    self._remainTimeMap = {}  --重置剩余时间
end

function BasicProxy:setMsgCenter(msgCenter)
    self._msgCenter = msgCenter
end

function BasicProxy:setGame(game)
    self._game = game
end

function BasicProxy:getCurState()
    return self._game:getCurState()
end

function BasicProxy:getNetChannel()
    return self._game:getNetChannel()
end

--显示飘字
function BasicProxy:showSysMessage(content, color, font)
    local state = self._game:getCurState()
    state:showSysMessage(content, color, font)
end

function BasicProxy:showLoading()
    local state = self._game:getCurState()
    state:showLoading()
end

function BasicProxy:hideLoading()
    local state = self._game:getCurState()
    state:hideLoading()
end

--提示框
function BasicProxy:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent)
    local state = self._game:getCurState()
    return state:showMessageBox(content, okCallback, canCelcallback,okBtnName,canelBtnName, parent)
end

function BasicProxy:getCurGameLayer(layerName)
    local state = self._game:getCurState()
    return state:getLayer(layerName)
end

function BasicProxy:isLoginState()
    local state = self._game:getCurState()
    local loginState = self._game:getState(GameStates.Login)
    return state == loginState
end

function BasicProxy:getProxy(name)
    return self._game:getProxy(name)
end

function BasicProxy:isModuleShow(moduleName)
    local state = self._game:getCurState()
    return state:isModuleShow(moduleName)
end

------
-- 获取当前所显示的最新ModuleName, 全屏的模块较为精确
function BasicProxy:getCurShowModuleName()
    local state = self._game:getCurState()
    return state:getCurShowModuleName()
end

function BasicProxy:registerNetEvents()
end

function BasicProxy:unregisterNetEvents()
end

--TODO 每一个Proxy有自己事件监听器，这样子在派发事件时，就可以不用全局遍历消息中心
function BasicProxy:registerNetEvent(mainsevent, subevent, object, fun)
    self._msgCenter:addEventListener(mainsevent, subevent, object, fun)
end

function BasicProxy:unregisterNetEvent(mainsevent, subevent, object, fun)
    self._msgCenter:removeEventListener(mainsevent, subevent, object, fun)
end

function BasicProxy:sendRegisterNetEvent(mainsevent, subevent, data)
    self._msgCenter:sendNotification(mainsevent, subevent, data)
end

function BasicProxy:sendAppEvent(mainsevent, subevent, data)
    self._msgCenter:sendNotification(mainsevent, subevent, data)
end


function BasicProxy:addEventListener(subevent, object, fun)
    self._msgCenter:addEventListener("PROXY_EVENT", subevent, object, fun)
end

function BasicProxy:removeEventListener(subevent, object, fun)
    self._msgCenter:removeEventListener("PROXY_EVENT", subevent, object, fun)
end

function BasicProxy:sendNotification(subevent, data)
    self._msgCenter:sendNotification("PROXY_EVENT", subevent, data)
end

function BasicProxy:delaySendNotification(subevent, data)
    self._msgCenter:delaySendNotification("PROXY_EVENT", subevent, data)
end

--打开模块
function BasicProxy:showModule(moduleData)
    self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, moduleData)
end

function BasicProxy:sendServerMessage(moduleId, cmdId, obj)
--    local data = {}
--    data["moduleId"] = moduleId
--    data["cmdId"] = cmdId
--    data["obj"] = obj
--    self._msgCenter:sendNotification("net_event", "net_send_data", data)
    self:syncNetReq(moduleId, cmdId, obj)
end

--初始化完毕所有的数据前调用，
function BasicProxy:beforeInitSyncData()

end

--初始化同步数据
--相关数据放到m20000上
--同时重置计时器
function BasicProxy:initSyncData(data)
    self._remainTimeMap = {}  --重置剩余时间
end

--重连的时候，就把定时器重置了，因为重连后，会拿到20000，初始化数据
function BasicProxy:onReconnect()
    self._remainTimeMap = {}
end

--初始化完毕所有的数据后调用，
--用来进一步计算相关数据的逻辑，比如战力计算，减少在初始化数据时，
--各数据层的耦合，导致数据初始化先后顺序各种报错
function BasicProxy:afterInitSyncData()
end

--重置计数，目前凌晨4点重置游戏次数
--各功能点 调用
function BasicProxy:resetCountSyncData()

end

function BasicProxy:syncNetReq(mId, cmd, obj)
    local data = {}
    data.moduleId = mId
    data.cmdId = cmd
    data.obj = obj
    self:getNetChannel():onSend(data)
    
    self._netReqTimeMap[cmd] = os.clock()
    
end

--同步接收到的网络数据
--会具体映射到具体的操作方法
function BasicProxy:syncNetRecv(cmd, data)
    local triggerFunc = self["onTriggerNet" .. cmd .. "Resp"]
    if triggerFunc then
        triggerFunc(self, data)
        
        if self._netReqTimeMap[cmd] ~= nil then
            local delay = os.clock() - self._netReqTimeMap[cmd]
            logger:error("=====%d操作延迟:%f==========", cmd, (delay * 1000))
        end
    end
end

--初始化协议的入口
function BasicProxy:onTriggerNet20000Resp(data)
    self:beforeInitSyncData()

    self:initSyncData(data)
end

--key自定义的唯一key
--一个key只会对应一个唯一的定时对象
--加入该数据定义的相关倒计时
--倒计时为0时，回调completeCallback，同个时刻回调的是data的列表，业务逻辑需要处理具体的逻辑
--回到参数是data的列表，如果某个cmd的定时器过于多时，且定时时间一样，解决这种情况的多请求IO
--通过cmd来区分倒计时触发逻辑，一个cmd只能对应一个completeCallback
--每一个操作只会对应一个定时器逻辑
--当remainTime设置为0时，则将对应的定时器删除掉，只有同步到服务端发送过来的数据才会设置为0
function BasicProxy:pushRemainTime(key, remainTime, cmd, data, completeCallback)
    if self._remainTimeMap[key] == nil then
        self._remainTimeMap[key] = {}
    end

    if remainTime == 0 then
        self._remainTimeMap[key] = nil
    else
        self._remainTimeMap[key] = {remainTime = remainTime, cmd = cmd, data = data, callback = completeCallback, 
            insertTime = os.time()}
    end
    
end

--获取key对应的剩余时间
--UI层主动获取
--该剩余时间是通过时间差算出来的
function BasicProxy:getRemainTime(key)
    if self._remainTimeMap[key] == nil then
--        logger:error("========获取的定时器时间，竟然没有push内容===========")
        return 0
    end

    local obj = self._remainTimeMap[key]
    local curRemainTime = self:getCurRemainTimeByObj(obj)

    return curRemainTime
end

function BasicProxy:getCurRemainTimeByObj(obj)
    local remainTime = obj.remainTime
    local insertTime = obj.insertTime
    local curTime = os.time()
    local curRemainTime = remainTime - (curTime - insertTime)
    if curRemainTime < 0 then
        curRemainTime = 0
    end

    return curRemainTime
end

--每秒定时检测，检测对应的定时器是否倒计时结束了
--如果倒计时结束了，则执行同步操作
--同时标志改cmd状态为请求状态中，如果请求状态超过3秒，则重新请求操作
--设定一个最大尝试请求次数，如果超过则直接断线
function BasicProxy:update()
    local needSyncList = {}
    local curTime = os.time()
    local removeKey = {}
    for key, obj in pairs(self._remainTimeMap) do
        local curRemainTime = self:getCurRemainTimeByObj(obj)
        if curRemainTime <= 0 and obj.syncTime == nil  then
            obj.syncCount = 1
            if obj.cmd ~= nil then  --一些操作不需要回调同步，客户端直接删除对应的定时器
                if needSyncList[obj.cmd] == nil then
                    needSyncList[obj.cmd] = {}
                end
                table.insert(needSyncList[obj.cmd], obj)
            else
                table.insert(removeKey, key )
            end
        end

        if obj.syncTime ~= nil then
            if curTime - obj.syncTime >= 3 then --3秒了，还没有同步数据过来，再尝试请求一遍
                obj.syncCount = obj.syncCount + 1
                if needSyncList[obj.cmd] == nil then
                    needSyncList[obj.cmd] = {}
                end
                table.insert(needSyncList[obj.cmd], obj)
            end
        end

        if obj.syncCount ~= nil and obj.syncCount >= 10 then --已经请求过多同步了，直接断线
            if GameConfig.isConnected == true then
                logger:error("=========同步请求失败10次了==自动断线====:%d============", obj.cmd)
                GameConfig.lastHeartbeatTime = GameConfig.lastHeartbeatTime - 60 * 3 --直接断线了
            end
        end
    end
    
    for _, key in pairs(removeKey) do
    	self._remainTimeMap[key] = nil
    end
    
    if GameConfig.isConnected == true then  --没有网络连接，不回调，等重连
        for cmd, list in pairs(needSyncList) do
            local sendDataList = {}
            local callback 
            for _, obj in pairs(list) do
                obj.syncTime = os.time()
                callback = obj.callback
                table.insert(sendDataList, obj.data)
            end

            callback(self, sendDataList)
        end
    end

    -- for _, obj in pairs(needSyncList) do
    --     logger:info("===倒计时结束，请求同步=====mId:%d=====cmd:%d=========")
    --     obj.syncTime = os.time() --同步时间
    --     self:syncNetReq(obj.mId, obj.cmd, obj.data)
    -- end

end

function BasicProxy:errorCodeHandler(cmd, errorCode)
    local data = {}
    data.rs = errorCode
    self:getNetChannel():errorCodeHandler(cmd, data)
end


function BasicProxy:changeState(stateName)
    local data = {}
    data["stateName"] = stateName
    self._msgCenter:sendNotification(AppEvent.STATE_EVENT, AppEvent.STATE_CHANGE_EVENT, data)
end

function BasicProxy:setLocalData(key, value, isGloble)
    LocalDBManager:setValueForKey(key, value, isGloble)
end

function BasicProxy:getLocalData(key, isGloble)
    local ret = LocalDBManager:getValueForKey(key, isGloble)
    return ret
end

function BasicProxy:writeLog(mainEvent, labelEvent, infos)
--    framework.platform.AppUtils:onEventTCAgent(mainEvent, labelEvent, infos)
end

