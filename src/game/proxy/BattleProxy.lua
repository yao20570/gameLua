
BattleProxy = class("BattleProxy", BasicProxy)

function BattleProxy:ctor()
    BattleProxy.super.ctor(self)
    self.proxyName = GameProxys.Battle
    
    self._curBattleId = 0
    self._isAaccelerate = true
    self._firstAtkArr = {"前排先手", "后排先手", "上列先手", "中列先手", "下列先手"}
end


function BattleProxy:resetAttr()
    self._curBattleId = 0
    self._isAaccelerate = true
end


function BattleProxy:beforeInitSyncData()
    BattleProxy.super.beforeInitSyncData(self)
    for k,v in pairs(GameConfig.battleType) do
        if v == 2 then
            local config = ConfigDataManager:getConfigData(ConfigData.AdventureConfig)
            for _,info in pairs(config) do
                LocalDBManager:setValueForKey(GameConfig.isAutoBattle..v..info.type, "no")
            end
        else
            LocalDBManager:setValueForKey(GameConfig.isAutoBattle..v, "no")
        end
    end
end

function BattleProxy:initSyncData(data)
    
    --存放战斗数据，点击回放的时候拿数据播放战斗
    self._allBattleData = {}
end

---------------------

--开始战斗数据包返回
function BattleProxy:onTriggerNet50000Resp(data)
    self._notWatchBattleState = false --一次性
    if data.rc < 0 then
        self:resumeUIAnimation()
        --TODO 战斗异常时，需要还原处理
        return --战斗异常
    end
    
    if self._uiAnimation == nil then
        self:preUIAnimation() --服务器主动推送战斗包
    end
    self._allBattleData[data.battle.id] = data
    self._curBattleId = data.battle.id
    self._curBattleType = data.battle.type

    self._curBattleData = data.battle

    --世界BOSS的战斗，判断是否已经播放过了，不直接播放了
    --视图那边还没有去拿战斗数据，先缓存起来，
    --如果战斗包还没有到，就去拿战斗包的话，则直接播放战斗
    if self._curBattleType == GameConfig.battleType.world_boss 
        and self._hasWorldBossBattle == true then
        self._worldBattleData = data
    else
        local data2 = {}
        data2["moduleName"] = ModuleName.BattleModule
        data2["extraMsg"] = {battleData = data}
        self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data2)
        --打完之后，刷新同盟建设度
        if data.type == 6 then
            local name = self:getProxy(GameProxys.Role):getLegionName()
            --是否加入了同盟
            if name ~= "" then
                self:syncNetReq(AppEvent.NET_M22, AppEvent.NET_M22_C220007, {opt = 0})
            end
        end
    end
end

--获取当前的战斗数据
function BattleProxy:getCurBattleData()
    return self._curBattleData
end

function BattleProxy:getBattleDataById(id)
    return self._allBattleData[id]
end

function BattleProxy:startWorldBossAttack()
    self._hasWorldBossBattle = true
end

function BattleProxy:getWorldBossBattle()
    
    if self._worldBattleData ~= nil then
        local data2 = {}
        data2["moduleName"] = ModuleName.BattleModule
        data2["extraMsg"] = {battleData = self._worldBattleData}
        self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data2)
    end

    self._worldBattleData = nil --
    self._hasWorldBossBattle = false
end

--战斗结束数据包
function BattleProxy:onTriggerNet50001Resp(data)
    self:sendNotification(AppEvent.PROXY_BATTLE_END,data)
end

-------------------------
--请求战斗
--战斗请求
function BattleProxy:startBattleReq(data)
    self:preUIAnimation()
    local isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoBattle .. data.type)
    if data.type == 2 then
        local proxy = self:getProxy(GameProxys.Dungeon)
        local type ,dunId = proxy:getCurrType()
        local info = ConfigDataManager:getInfoFindByOneKey("AdventureConfig","ID",dunId)
        isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoBattle .. data.type .. info.type)
    end

    
    local saveTraffic = isAuto == "yes" and 1 or 0

    -- if data.type == 1 or data.type == 6 then 
    --     isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoBattle)
    -- elseif data.type == 2 then
    --     isAuto = LocalDBManager:getValueForKey(GameConfig.isAutoExperience)
    -- end
    -- if isAuto == "yes" then
    --     self._notWatchBattleState = true
    -- end
    -- print("请求战斗，是否自动战斗？", self._notWatchBattleState)
    -- if self._notWatchBattleState == true then
        data["saveTraffic"] = saveTraffic
    -- else
    --     data["saveTraffic"] = 0
    -- end
    -- if data.type == 3 then              --演武场不需要跳过战斗
    --     data["saveTraffic"] = 0
    -- end

    if data.type == 6 then
        -- 军团副本请求战斗 发270002
        local sendData = {}
        sendData.infos = data.infos
        sendData.id = data.id
        local str = LocalDBManager:getValueForKey(GameConfig.isAutoBattle..data.type)
        sendData.saveTraffic = saveTraffic
        logger:info("军团副本请求战斗 id=%d", data.id)
        local proxy = self:getProxy(GameProxys.DungeonX)
        proxy:onTriggerNet270002Req(sendData)        
        return
    end

    if data.type == 3 then  --据说演武场不带出战列表
        data.infos = {}
    end

    for k,v in pairs(data.infos) do
        if v.post == 9 then
            self.battleConsuId = v.typeid
        end
    end
    self:syncNetReq(AppEvent.NET_M5, AppEvent.NET_M5_C50000, data)
end

--请求战斗结束
function BattleProxy:onTriggerNet50001Req(data)
    self:syncNetReq(AppEvent.NET_M5, AppEvent.NET_M5_C50001, data)
end

function BattleProxy:getBattleConsuId()
    return self.battleConsuId
end

-----------
--设置是否不看战报状态
function BattleProxy:setIsAutoBattle(state)
    self._notWatchBattleState = state
end

function BattleProxy:getIsAutoBattle()
    return self._notWatchBattleState
end

function BattleProxy:getCurBattleId()
    return self._curBattleId
end

function BattleProxy:getCurBattleType()
    return self._curBattleType
end

function BattleProxy:isAaccelerate()
    return self._isAaccelerate
end

function BattleProxy:setAaccelerate(value)
    self._isAaccelerate = value
end

function BattleProxy:preUIAnimation()
    -- local layer = self:getCurGameLayer(GameLayer.uiTopLayer)
    -- local uiAnimation = UIAnimation.new(layer, "001", false)
    -- uiAnimation:play(nil, false)

    -- uiAnimation:pause()
    -- self._uiAnimation = uiAnimation

    -- self:createUIAnimation()
end

function BattleProxy:resumeUIAnimation()
    if self._uiAnimation == nil then
        print("特效不存在啦，，播放不了 了了了了")
        return
    end
    self._uiAnimation:resume()
    self._uiAnimation = nil
end

function BattleProxy:setCompleteCallback(callback)
    self._uiAnimation:setCompleteCallback(callback)
end


function BattleProxy:createUIAnimation(ccbiName, completeFunc, isPlayOnce, order)
    -- new ccbi
    ccbiName = ccbiName or "rgb-guochangyun2"
    completeFunc = completeFunc or nil
    isPlayOnce = isPlayOnce or true
    order = order or 9000

    -- local winSize = cc.Director:getInstance():getWinSize()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local layer = self:getCurGameLayer(GameLayer.uiTopLayer)

    -- UICCBLayer:ctor(ccbname, parent, owner, completeFunc, isPlayOnce)
    local uiAnimation = UICCBLayer.new(ccbiName, layer, nil, completeFunc, isPlayOnce)      
    self._uiAnimation = uiAnimation
    uiAnimation:setPosition(visibleSize.width/2,visibleSize.height/2)
    uiAnimation:setLocalZOrder(order)


    local function pauseCallback(  )
        -- body
        print("暂停播放特效啦啦啦 pauseCallback")
        uiAnimation:pause()
    end
    TimerManager:addOnce(400,pauseCallback,self)

end

function BattleProxy:getFirstAtkArr()
    return self._firstAtkArr
end

