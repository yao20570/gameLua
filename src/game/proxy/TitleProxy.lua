TitleProxy = class("TitleProxy", BasicProxy)

--message TitleInfo{   //玩家称号
--  optional int32 id =1;      //称号id
--	optional int32 time =2;   //结束时间错
--	optional int32 use =3;//未使用，1使用
--}

function TitleProxy:ctor()
    TitleProxy.super.ctor(self)
    self.proxyName = GameProxys.Title
    self._titleInfos = {}
    self._titleConfig = {}
    self._titleConfig = self:getTitleConfigData() -- 配置表
end


function TitleProxy:initSyncData(data) --2万协议
    local titleInfos = data.titleInfos -- //称号信息

    self._titleInfos = self:setDataWithConfig(titleInfos)
end


------
-- M20802 称号选择
function TitleProxy:onTriggerNet20802Req(changeId)
    -- 选择的id
    local data = {}
--    data.useIds = {}
--    table.insert(data.useIds, changeId)
    data.id = changeId
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20802, data)
end

------
-- M20802 称号选择
-- 客户端自己做数据更新处理
function TitleProxy:onTriggerNet20802Resp(data)
    self._titleInfos[data.id].use = data.use
    -- 回调给界面做刷新
    self:sendNotification(AppEvent.PROXY_TITLE_CHANGE, {})
end

------
-- M20800{  //服务端主动推送，称号更新
-- 只有称号获得时才下发, 全部的称号列表
function TitleProxy:onTriggerNet20800Resp(data)
    local titleInfos = data.titleInfos -- //称号信息

    self._titleInfos = self:setDataWithConfig(titleInfos)
    -- 回调给界面做刷新
    self:sendNotification(AppEvent.PROXY_TITLE_ADD_GOT, {})
end



--------------------------------------------------------------------------
-- 获取称号信息
function TitleProxy:getTitleInfos()
    
    return self._titleInfos 

end


-- 获取称号配置表,以ID为key
function TitleProxy:getTitleConfigData()
    local titleTable = {}
    local configData = ConfigDataManager:getConfigData( ConfigData.TitleConfig)
    for key, info in pairs( configData) do
        local t = {}
        t.id      = info.id     
        t.type    = info.type   
        t.title   = info.title  
        t.titleLv = info.titleLv

        titleTable[info.ID] = t
    end

    return titleTable
end

-- 根据配置表组合总表
function TitleProxy:setDataWithConfig(titleInfos)
    local allTable = {}
    for ID, configInfo in pairs(self._titleConfig) do
        local t = {}
        t.id   = ID
        t.time = 0
        t.use  = 0
        allTable[ID] = t
    end
         
    for k, v in pairs(titleInfos) do
        local t = {}
        t.id   = v.id  
        t.time = v.time -- - os.time()  -- 改为了剩余倒计时
        t.use  = v.use
        allTable[v.id] = t
        local key = self:getKey(v.id)
        self:pushRemainTime(key, t.time, 390000, v.id, self.timeEndCall);
    end

    return allTable
end

-- 获取当前使用称号列表
function TitleProxy:getMyUsingTitle()
    local temp = {}
    for k, v in pairs(self._titleInfos) do
        if v.use == 1 then
            table.insert(temp, v.id)
        end
    end
    return temp
end

function TitleProxy:getKey(id)
    return "title_proxy_"..id
end

function TitleProxy:timeEndCall(params)
    local key = self:getKey(params[1])
    self._remainTimeMap[key] = nil
    local id = params[1] -- 传入的id
    self._titleInfos[id].time = 0
    self._titleInfos[id].use  = 0
    -- 回调给界面做刷新
    self:sendNotification(AppEvent.PROXY_TITLE_CHANGE, {})
end