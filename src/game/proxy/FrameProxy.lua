FrameProxy = class("FrameProxy", BasicProxy)

--message FrameInfo{   //玩家头像框
--  optional int32 frameId =1;//头像框id
--	optional int32 use      =2;//未使用，1使用
--}

function FrameProxy:ctor()
    FrameProxy.super.ctor(self)
    self.proxyName = GameProxys.Frame

    self._frameInfos = {}
    
end


function FrameProxy:initSyncData(data) --2万协议

    local frameInfos = data.frameInfos -- //称号信息
    self:setDataWithConfig(frameInfos)
end

-- 获取称号配置表,以ID为key
function FrameProxy:getFrameConfigData()
    local configData = ConfigDataManager:getConfigData( ConfigData.HeadFrameConfig)
    for key, info in pairs( configData) do
        -- 添加默认新字段
        info.time = 0
        info.use  = 0
    end

    return configData
end

-- 根据配置表组合总表
function FrameProxy:setDataWithConfig(frameInfos)
    self._frameInfos = self:getFrameConfigData() -- 配置表的初始状态
    for k, v in pairs(frameInfos) do
        self._frameInfos[v.frameId].use = v.use
        self._frameInfos[v.frameId].time = v.time
        local key = self:getKey(v.frameId)
        self:pushRemainTime(key, v.time, AppEvent.NET_M2_C20806, v.frameId, self.timeEndCall)
    end
end

------
-- M20805{	//选择头像框
function FrameProxy:onTriggerNet20805Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20805, data)
end

function FrameProxy:onTriggerNet20805Resp(data)
    if data.rs ~= 0 then
        return 
    end

    -- 使用了新头像框，则要清除已使用的旧框
    if data.use == 1 then
        for k,v in pairs(self._frameInfos) do
            if v.use == 1 then
                self._frameInfos[k].use = 0
            end
        end
    end

    self._frameInfos[data.frameId].use = data.use
    -- 刷新回调
    self:sendNotification(AppEvent.PROXY_FRAME_CHANGE, {})
end

------
-- M20806{  //服务端主动推送，称号更新
function FrameProxy:onTriggerNet20806Resp(data)
    if data.rs ~= 0 then
        return 
    end
    local frameInfos = data.frameInfos
    self:setDataWithConfig(frameInfos)
    -- 回调给界面做刷新
    self:sendNotification(AppEvent.PROXY_FRAME_ADD_GOT, {})
end


function FrameProxy:getFrameInfos()
    return self._frameInfos
end


function FrameProxy:getKey(id)
    return "frame_proxy_"..id
end


function FrameProxy:timeEndCall(params)
    local key = self:getKey(params[1])
    local frameId = params[1] -- 传入的id
    self._frameInfos[frameId].time = 0
    self._frameInfos[frameId].use  = 0

    -- 回调给界面做刷新
    self:sendNotification(AppEvent.PROXY_FRAME_CHANGE, {})
end

function FrameProxy:getMyUsingFremeId()
    local id = 0
    for i, info in pairs(self._frameInfos) do
        if info.use == 1 then
            id = i 
        end
    end
    return id
end




