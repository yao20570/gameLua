RoleProxy = class("RoleProxy", BasicProxy)
RoleProxy.GUIDE_REWARD_TYPE = 58 -- 新手大礼包类型
function RoleProxy:ctor()
    RoleProxy.super.ctor(self)
    self.proxyName = GameProxys.Role
    self.openServerData = {}
    
    self._attrInfoMap = {}

    self.preid = 0
    self.isFirstEnterOpenServer = true
    self._maxEnergy = 20 --军令最大值
    self._maxCrusadeEnergy = GlobalConfig.maxCrusadeEnergy --讨伐令最大值

    self._energyNeedMoney = nil
    self._crusadeEnergyNeedMoney = nil
    self._reconnectState = false  --断线重连
    self:initResConf()

    self._serverOpenTime = 0
end

function RoleProxy:resetAttr()
    

    self._isInitInfo = false
    self._attrInfoMap = {}
    self.openServerData = {}
    if self.node then
        self.node:removeFromParent()
        self.node = nil
    end
end

function RoleProxy:isInitInfo()
    return self._isInitInfo
end

-- 若西域远征次数0 重置次数也是0 则返回0 
--没副本信息的时候，西域远征次数是这里拿的
function RoleProxy:getlimitExp()
    if self._fightCount == 0 and self._backCount == 0 then
        return 0
    end
    if self._fightCount == nil and self._backCount == nil then
        return 0
    end
    return 1
end

--刷新20000里面的西域远征的次数信息
function RoleProxy:setLimitExpData(fightCount, backCount)
    self._fightCount = fightCount
    self._backCount = backCount
end

-- 每日重置次数 待测
function RoleProxy:resetCountSyncData()
    if self._isInitInfo ~= true then --数据还没有初始化
        return
    end
    logger:info("每日重置 ··· RoleProxy:resetCountSyncData")
    
    self:setPrestigeState(0) --声望封赏重置

    self._energyNeedMoney = nil  --军令 讨伐令花费重置
    self._crusadeEnergyNeedMoney = nil

    --开服礼包重置
    local data = self.openServerData
    local config = ConfigDataManager:getConfigData(ConfigData.DayLandConfig)
    if data.allDay < #config then
        data.allDay = data.allDay + 1
        local addDay = data.allDay
        table.insert(data.canGet,addDay)
        self:initOpenServerData(data)
    elseif data.allDay == #config or data.allDay == -1 then
        data.type = 2
        if data.allDay == #config then
            self:sendAppEvent(AppEvent.MODULE_EVENT,AppEvent.MODULE_CLOSE_EVENT,{moduleName = ModuleName.OpenServerGiftModule})
        end
        data.allDay = 0
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:checkThirtyRedPoint()
    end

end


function RoleProxy:initSyncData(data) --2万协议
    RoleProxy.super.initSyncData(self, data)

    self._serverOpenTime =  data.openServerTime

    -- 播放队列重置
    EffectQueueManager:reconnectInit()

    self._isInitInfo = true
    
    self._m20000 = data

    local actorInfo = data.actorInfo
    self:setRoleAttrInfos(actorInfo.attrInfos)
    self._actorInfo = actorInfo

    --self._design = actorInfo.design or {}
    if data.chargeDoubleList then
        self:setChargeDoubleList(data.chargeDoubleList)
        self:sendNotification(AppEvent.PROXY_UPDATE_RECHARGE_INFO, {}) --推送已双倍充值的额度
    end

    if data.cityBattleReward then
        logger:info("城主战 小红点！~~~%d",data.cityBattleReward)
        local redPointProxy = self:getProxy(GameProxys.RedPoint)
        redPointProxy:updateCityBattleRedNum(data.cityBattleReward)
    end

    if actorInfo.fameState then
        self:setPrestigeState(actorInfo.fameState)
    end
    if actorInfo.engryprice then
        self:setEnergyNeedMoney(actorInfo.engryprice)
    end
    self:setCrusadeEnergyNeedMoney(actorInfo.crusadeEnergyPrice)
    if actorInfo.boomRefTime then
        -- actorInfo.boomRefTime = 60   --TODO 测试代码
        -- self:setRoleAttrValue(PlayerPowerDefine.POWER_boom, 40)  --TODO 测试代码 f4500

        self:setBoomRemainTime(actorInfo.boomRefTime)
    end
    if actorInfo.energyRefTime then
        -- actorInfo.energyRefTime = 40   --TODO 测试代码
        -- self:setRoleAttrValue(PlayerPowerDefine.POWER_energy, 18)  --TODO 测试代码 f4500
        self:setEnergyRemainTime(actorInfo.energyRefTime)
    end
    self:setCrusadeEnergyRemainTime(actorInfo.crusadeEnergyTime)
    if actorInfo.tanbaoFrees then
        local pubProxy = self:getProxy(GameProxys.Pub)
        pubProxy:setPubFreeData(actorInfo.tanbaoFrees[1],actorInfo.tanbaoFrees[2])
    end

    if rawget(actorInfo, "roleCreateTime") ~= nil then
        GameConfig.roleCreateTime = actorInfo.roleCreateTime
    end
    self.name = actorInfo.name
    self._worldTileX = actorInfo.worldTileX
    self._worldTileY = actorInfo.worldTileY

    self:setLegionLeaderWorldTilePos(actorInfo.legionLeaderX, actorInfo.legionLeaderY) --军团长的坐标

    self._playerId = actorInfo.playerId     -- 玩家ID
    self._iconId = actorInfo.iconId         -- 头像ID
    self._pendantId = actorInfo.pendantId   -- 挂件ID
    self._newGift = actorInfo.newGift       -- 是否领取过新手礼包：0未领取，1已领
    self._fightCount = actorInfo.fightCount -- 西域远征剩余挑战次数
    self._backCount = actorInfo.backCount

    self._legionName = actorInfo.legionName --军团名字
    self._legionLevel = actorInfo.legionLevel --军团等级
    self._legionId = actorInfo.legionId   --军团ID

    self:setCustomHeadStatus(actorInfo.customHeadStatus)
    self:setCustomHeadCoolTime(actorInfo.customCoolTime)

    
    -- if rawget(actorInfo, "worldSeedTypeId") ~= nil then --生成地图资源点
        -- self._worldSeedTypeId = actorInfo.worldSeedTypeId  --世界地图种子id
        -- local worldProxy = self:getProxy(GameProxys.World)
        -- worldProxy:createRandomData(actorInfo.worldSeedTypeId)
        -- worldProxy:createAllTiles(actorInfo.worldSeedTypeId)
    -- end


    local atom = StringUtils:fined64ToAtom(self._legionId) --TODO 容错，使用32位就行了
    self:setRoleAttrValue(PlayerPowerDefine.POWER_LegionId, atom.low)

    self:sendNotification(AppEvent.PROXY_LEGION_MAINSCENE_BUILDING_UPDATE, {})
    

    self:sendNotification(AppEvent.PROXY_GET_ROLE_INFO, data)
    
--    local partsProxy = self:getProxy(GameProxys.Parts)
--    if data.odInfos ~= nil then
--        partsProxy:onOrdnanceInfosResp(data)
--    end 
--    if data.odpInfos ~= nil then
--        partsProxy:_updatePieceInfos(data.odpInfos)
--    end
-- --60000  -------11111111111-----------
    -- if data.dungeonInfos ~= nil then
    --     local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    --    dungeonProxy:setDungeonListInfos(data.dungeonInfos)
    --  end

   --20000
   if data.soldierList ~= nil then
--        local soldierProxy = self:getProxy(GameProxys.Soldier)
--        local tempData = {}
--        tempData.soldierList = data.soldierList
--        tempData.rs = 0
--        soldierProxy:onRoleInfoResp(tempData)
   end
--130000
    if data.equipinfos ~= nil then
--        local equipProxy = self:getProxy(GameProxys.Equip)
--        local tempData = {}
--        tempData.equipinfos = data.equipinfos
--        tempData.rs = 0
--        equipProxy:onAllEquipsResp(tempData)
    end
--70000    ------------------11111111111111111111-------
    -- if data.info ~= nil then
    --     local dungeonProxy = self:getProxy(GameProxys.Dungeon)
    --     local tempData = {}
    --     tempData.info = data.info
    --     tempData.rs = 0
    --     dungeonProxy:onSetTeamResp1(tempData)
    -- end
-- --30100 ww
    if data.cacheInfos ~= nil then
--        local partsProxy = self:getProxy(GameProxys.Parts)
--        local tempData = {}
--        tempData.cacheInfos = data.cacheInfos
--        tempData.rs = 0
--        partsProxy:onPieceInfosResp(tempData)
    end
--190000   -----------------11111111111111-------------------
    -- if data.taskList ~= nil then
    --     local taskProxy = self:getProxy(GameProxys.Task)
    --     --taskProxy:onTaskInfoResp(data.taskList)
    --     taskProxy:onTriggerNet190000Resp(data.taskList)
    -- end
--120000
    -- if data.itemBuffInfo ~= nil then
    --     local skillProxy = self:getProxy(GameProxys.Skill)
    --     local tempData = {}
    --     tempData.itemBuffInfo = data.itemBuffInfo
    --     tempData.rs = 0
    --     skillProxy:onSkillListResp(tempData)
    -- end
--[[90003  高耦合暂不做修改
    if data.cacheInfos ~= nil then
        local partsProxy = self:getProxy(Parts)
        partsProxy:onPieceInfosResp(data.cacheInfos)
    end
]]
--80003
    --if data.list ~= nil then
    -- --    local soldierProxy = self:getProxy(GameProxys.Soldier)
    --     local tempData = {}
    --     tempData.list = data.list
    --     tempData.rs = 0
    --     soldierProxy:onUpdateTaskTeamInfoResp(tempData)
    -- end
--160000 -------------------111111111111--------
    -- if data.mails ~= nil then
    --     local RoleProxy = self:getProxy(GameProxys.Mail)
    --     local tempData = {}
    --     tempData.mails = data.mails
    --     tempData.rs = 0
    --     RoleProxy:onTriggerNet160000Resp(tempData)
    -- end
--230000
    -- if data.activitys ~= nil then
    --     local activityProxy = self:getProxy(GameProxys.Activity)
    --     local tempData = {}
    --     tempData.activitys = data.activitys
    --     tempData.rs = 0
    --     activityProxy:onTriggerNet230000Resp(tempData)
    -- end
-- -- --230002  
--     if data.limitActivitys ~= nil then
--         local activityProxy = self:getProxy(GameProxys.Activity)
--         local tempData = {}
--         tempData.activitys = data.limitActivitys   --因为与230000命名一样 所以还原回来
--         tempData.rs = 0
--         activityProxy:onGetLimitActivityInfoResp(tempData)
--     end
-- -- --260000--------------------11111111111111111111-------
--     if data.adviserinfo ~= nil then
--         local consigliereProxy = self:getProxy(GameProxys.Consigliere)
--         local tempData = {}
--         tempData.adviserinfo = data.adviserinfo
--         tempData.rs = 0
--         consigliereProxy:onTriggerNet260000Resp(tempData)
--     end
-- --260004-----------------1111111111111111111----------------
--     if data.costInfos ~= nil then
--         local consigliereProxy = self:getProxy(GameProxys.Consigliere)
--         local tempData = {}
--         tempData.costInfos = data.costInfos
--         tempData.rs = 0
--         consigliereProxy:onTriggerNet260004Resp(tempData)
--     end

----210000
    -- if data.rankinfos ~= nil then
    --     local rankProxy = self:getProxy(GameProxys.Rank)
    --     local tempData = {}
    --     tempData.rankListInfo = data.rankinfos
    --     tempData.rs = 0 
    --     rankProxy:onTriggerNet210000Resp(tempData)
    -- end

--20015
    if data.legionrewardinfo ~= nil then
        -- self:onTriggerNet20015Resp(data.legionrewardinfo)
        self:initOpenServerData(data.legionrewardinfo)
    end
--40001
--    if data.soldiers ~= nil then
--        local soldierProxy = self:getProxy(GameProxys.Soldier)
--        local tempData = {}
--        tempData.soldiers = data.soldiers
--        tempData.rs = 0
--        soldierProxy:onBadSolidersListResp(tempData)
--    end

--170000
   --  if data.friBleInfos ~= nil then
   --      local friendProxy = self:getProxy(GameProxys.Friend)
   --     -- local tempData = {}
   --     -- tempData.friendInfos = data.friBleInfos
   --     -- tempData.rs = 0
   --     friendProxy:onFriendListResp(data.friBleInfos)
   -- end

    local updatePowerList = {}
    --TODO添加value有变化的typeid
    self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, updatePowerList)
end
-------优化网络通讯
function RoleProxy:onTriggerNet20002Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20002, data)
end

function RoleProxy:onTriggerNet20007Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20007, data)
end

function RoleProxy:onTriggerNet20008Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20008, data)
end

function RoleProxy:onTriggerNet20009Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20009, data)
end

function RoleProxy:onTriggerNet20010Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20010, data)
end

function RoleProxy:onTriggerNet20011Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20011, data)
end

function RoleProxy:onTriggerNet20012Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20012, data)
end

function RoleProxy:onTriggerNet20013Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20013, data)
end

function RoleProxy:onTriggerNet20014Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20014, data)
end

function RoleProxy:onTriggerNet20015Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20015, data)
end

function RoleProxy:onTriggerNet20016Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20016, data)
end

function RoleProxy:onTriggerNet20017Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20017, data)
end

function RoleProxy:onTriggerNet20201Req(data)
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20201, data)
end

function RoleProxy:onTriggerNet140008Req(data)
    self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140008, data)
end

function RoleProxy:onTriggerNet90003Req(data)
    self:syncNetReq(AppEvent.NET_M9, AppEvent.NET_M9_C90003, data)
end

-- 手动升级请求
function RoleProxy:onTriggerNet20808Req()
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20808, {})
end

--相关属性更改
--第二个参数 资源自产 不需要飘窗
function RoleProxy:onTriggerNet20002Resp(data,isNotShowFly)-- onRoleInfoDifResp  --20007有跑到这边来的

    local isFightWeightUpdate = false
    local diffs = data.diffs
    local isUpdate = false
    local updatePowerList = {}
    if not isNotShowFly == true then
        -- 09.21 策划需求，屏蔽飘资源
        -- self:onAttrDifInfoFly(data)
    end
    -- 09.21 策划需求，屏蔽飘资源
    --ComponentUtils:showGetExpAction(self, data)
    
    for _, diff in pairs(diffs) do
        --做属性相关逻辑处理
        local oldValue = self:getRoleAttrValue(diff.typeid)
        if oldValue ~= diff.value then
            isUpdate = true
            table.insert(updatePowerList, diff.typeid)
            ComponentUtils:roleInfoDifEffect(self, diff)
            if diff.typeid == PlayerPowerDefine.POWER_command or 
                diff.typeid == PlayerPowerDefine.POWER_level or
                (diff.typeid >= SoldierDefine.POWER_hpMax and
                diff.typeid <= SoldierDefine.POWER_damder) then
                isFightWeightUpdate = true
            end
            
            self:setRoleAttrValue(diff.typeid, diff.value)
            if diff.typeid == PlayerPowerDefine.POWER_level then --等级改变，发送日志
                local actorInfo = self:getActorInfo()
                GameConfig.actorid = actorInfo.playerId
                GameConfig.actorName = actorInfo.name
                GameConfig.level = self:getRoleAttrValue(PlayerPowerDefine.POWER_level)
                local userMoney = self:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
                SDKManager:sendExtendDataRoleLevelUp(userMoney)

                --检测新功能开启
                local list = ConfigDataManager:getInfosFilterByTwoKey(
                      ConfigData.NewFunctionOpenConfig, "need", diff.value, "type", 1)
                if #list > 0 then
                    local function delayShowModule(data)
                        self:showModule({moduleName = ModuleName.UnlockModule, extraMsg = data})
                        -- 判断军师解锁
                        if data.openLevel == 26 and data.openType == 1 then
                            self:sendNotification(AppEvent.PROXY_OPEN_BUILD_CONSIGRE,{})
                        end
                        -- 判断点兵解锁，刷新红点
                        local norNeed = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig,5).need
                        local speNeed = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig,9).need
                        if data.openLevel == norNeed or data.openLevel == speNeed then
                            local redPointProxy = self:getProxy(GameProxys.RedPoint)
                            redPointProxy:checkFreeFindBoxRedPoint() 
                        end
                        -- 主界面的周卡入口开放
                        local weekCardNeed = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig,54).need
                        if data.openLevel == weekCardNeed then
                            local activityProxy = self:getProxy(GameProxys.Activity)
                            activityProxy:sendNotification(AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE)
                        end
                    end
                    EffectQueueManager:addEffect(EffectQueueType.UNLOCK, delayShowModule, {openType = 1, openLevel = diff.value})
                end
            end

            -- （繁荣/体力更新）是否创建定时器  add by fzw 
            if diff.typeid == PlayerPowerDefine.POWER_boom or diff.typeid == PlayerPowerDefine.POWER_energy or diff.typeid == PlayerPowerDefine.POWER_crusadeEnergy then
                self:updateRoleRemainTime(diff)
            end
            if diff.typeid == PlayerPowerDefine.POWER_legionLevel then
                self._legionLevel = diff.value
            end
        end
    end
    
    if isUpdate == true then
        local buildingProxy = self:getProxy(GameProxys.Building)
        buildingProxy:updateRoleInfo(updatePowerList)
    
        self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, updatePowerList)
    end
    
    if isFightWeightUpdate == true then
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        soldierProxy:soldierMaxFightChange()
    end
    self:sendNotification(AppEvent.POWER_VALUE_UPDATE, {})
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkTaskRedPoint()   
    redPointProxy:setSpringSquibRed() 
    redPointProxy:setCookingRed() 
end

------发送各种背包、道具、军械刷新, 奖励判断
function RoleProxy:onTriggerNet20007Resp(data)

    local gettype = data.gettype

    local config = ConfigDataManager:getConfigById(ConfigData.ShowControlConfig, gettype)

    local shieldID = {}
    if config ~= nil then
        shieldID = StringUtils:jsonDecode(config.shieldID)
    end
    local allShield = {}
    for k,v in pairs(shieldID) do
        allShield[v] = true
    end

    local showType = 3
    if config ~= nil then
        showType = config.showType or 3
    end

    logger:error("!!!!!!!!!onTriggerNet20007Resp!!!!!!!gettype:%d!!!showType:%d!!!", gettype, showType)

    if gettype == RoleProxy.GUIDE_REWARD_TYPE then
        AnimationFactory:playAnimationByName("GuideRewardEffect", {})
        showType = 0
    end

    if showType ~= 0 then  --不是0的，则有对应的动画 --构建数值
        local tempData = {}
        tempData.rewards = {} 
        local index = 1
        local info = data
        local function checkShield(powerId, param, key)
            if not allShield[powerId] then
                index = self:setDataRewardFly(param, tempData, index, powerId, key) --佣兵406
            end
        end
        checkShield(GamePowerConfig.Soldier, info.soldierList)
        checkShield(GamePowerConfig.Item, info.itemList)
        checkShield(GamePowerConfig.HeroTreasure, info.treasureInfos, "onlyOne")
        checkShield(GamePowerConfig.HeroTreasureFragment, info.treasurePieceInfos)
        checkShield(GamePowerConfig.OrdnanceFragment, info.odpInfos)
        checkShield(GamePowerConfig.General, info.equipinfos, "onlyOne")
        checkShield(GamePowerConfig.Hero, info.heros) -- -- 武将 #4300 飘窗只飘一本武经（实际不止得到一本）。 
        checkShield(GamePowerConfig.Ordnance, info.odInfos, "onlyOne")
        checkShield(GamePowerConfig.HeroFragment, info.heroPieceInfos) -- 412  --武将碎片
        checkShield(GamePowerConfig.Counsellor, info.adviserInfos, 1) --军师 405

        if rawget(info, "diffs") then
            checkShield(GamePowerConfig.Resource, info.diffs, "value")
        end

        if showType == 1 then --飘窗
            if index > 1 then
                AnimationFactory:playAnimationByName("BagFreshFly", tempData)
            end
        else
            local all = 0 
            for k,v in pairs(tempData.rewards) do
                if v.num <= 0 then
                    tempData.rewards[k] = nil -- 过滤num不科学的字节
                end
            end
            local rewardData = {} -- 真-奖励数据
            for k,v in pairs(tempData.rewards) do
                if not rewardData[v.typeid] then
                    rewardData[v.typeid] = {}
                end
                if not rewardData[v.typeid][v.power] then
                    rewardData[v.typeid][v.power] = v
                else
                    rewardData[v.typeid][v.power].num = rewardData[v.typeid][v.power].num + v.num
                end
                all = all + 1
            end
            if all ~= 0 then
                local result = {}
                for k,v in pairs(rewardData) do
                    for ka,va in pairs(v) do
                        table.insert(result, va)
                    end
                end

                if showType == 2 then  --弹窗
                    AnimationFactory:playAnimationByName("GetPropAnimation", result)
                elseif showType == 3 then  --特效
                    AnimationFactory:playAnimationByName("GetGoodsEffect", result)
                end
            end
        end
    end
    
   ------------------------------上面的全局动画处理-----------------------------------------------------------------

    if rawget(data, "diffs") then
        self:onTriggerNet20002Resp({diffs = data.diffs})  --playAnimationByName
    end
    local soldierList = data.soldierList
    local itemList = data.itemList
    local odpInfos = data.odpInfos
    local equipInfos = data.equipinfos
    local generals = data.generals
    local odInfos = data.odInfos
    local adviserInfos = data.adviserInfos
    local heros = data.heros
    local treasureInfos = data.treasureInfos
    local treasurePieceInfos = data.treasurePieceInfos
	local postInfos = data.postInfos    
    local heroPieceInfos = data.heroPieceInfos
    
    if #heroPieceInfos > 0 then
        local heroProxy = self:getProxy(GameProxys.Hero)
        heroProxy:updateHeroPieceInfos(heroPieceInfos)
    end    
    if #soldierList > 0 then
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        soldierProxy:updateSoldiersList(soldierList)
    end
    if #itemList > 0 then
        local itemProxy = self:getProxy(GameProxys.Item)
        itemProxy:updateItemInfos(itemList)
    end
    if #odInfos > 0 then
        local partsProxy = self:getProxy(GameProxys.Parts)
        partsProxy:updateOrdnanceInfos(odInfos)
    end
    
    if #equipInfos > 0 then
        local partsProxy = self:getProxy(GameProxys.Equip)
        partsProxy:updateAllEquips(equipInfos)
    end
    if generals and #generals > 0 then
        local equipProxy = self:getProxy(GameProxys.Equip)
        equipProxy:updateAllGenerals(generals)
    end 
    if #odpInfos > 0 then
        local partsProxy = self:getProxy(GameProxys.Parts)
        partsProxy:updatePieceInfos(odpInfos)
    end
    if adviserInfos and #adviserInfos > 0 then
        local consigProxy = self:getProxy(GameProxys.Consigliere)
        consigProxy:onNewInfoResp(adviserInfos)
    end

    if heros ~= nil and #heros > 0 then
        local heroProxy = self:getProxy(GameProxys.Hero)
        local isRefresh = true
        --获取到英雄，打开获取面板
        local heroIdList = {}
        for _, hero in pairs(heros) do
            if hero.heroId > 0 then
                --只重置一次table
                if isRefresh then
                    heroProxy:resetResolveData()
                end
                isRefresh = false
                local isResolve = heroProxy:isResolve(hero)
                local isExpCar = heroProxy:isExpCar(hero)
                if not isExpCar then
                    local heroData = heroProxy:getInfoById(hero.heroDbId)
                    if heroData == nil then


                        table.insert(heroIdList, hero)
                    end
                end
            end
        end
        if #heroIdList > 0 then
            local function delayShowModule(heroIdList)
                self:showModule({moduleName = ModuleName.HeroGetModule, extraMsg = heroIdList})
            end

            EffectQueueManager:addEffect(EffectQueueType.GET_HERO, delayShowModule, heroIdList)
            -- TimerManager:addOnce(40, delayShowModule, self, {moduleName = ModuleName.HeroGetModule, extraMsg = heroIdList})
        end

        heroProxy:updateHeroInfo(heros)


    end
    if postInfos and #postInfos > 0 then
        local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
        heroTreasureProxy:updatePostInfos(postInfos)
    end
    if treasureInfos and #treasureInfos > 0 then
        local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
        heroTreasureProxy:updateTreasureInfo(treasureInfos)
    end
    if treasurePieceInfos and #treasurePieceInfos > 0 then
        local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
        heroTreasureProxy:updateTreasurePieceInfo(treasurePieceInfos)
    end


    
    self:sendNotification(AppEvent.PROXY_UPDATE_BUFF_NUM, data)

    --//全局动画信息
    local skillProxy =self:getProxy(GameProxys.Skill)
    skillProxy:isLevelUpSkill()

end

function RoleProxy:onTriggerNet20008Resp(data)
    self:updateRoleName(data)
end

function RoleProxy:updateRoleName(data)
    if data.rs == 0 then
        self.name = data.name
        self._actorInfo.name = data.name
    end
    
    logger:info("更新名字 = %s",data.name)
    self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, data)
end


function RoleProxy:onTriggerNet20009Resp(data)
    logger:error("!20009已接受，已不做处理！")
end

-- 声望领取状态
function RoleProxy:onTriggerNet20010Resp(data)
    -- body
    if data.rs == 0 then
        if data.state == nil then
            -- self:setPrestigeState(1)
        else
            self:setPrestigeState(data.state)
        end
    end
end

--购买体力成功
function RoleProxy:onTriggerNet20011Resp(data)
    if data.rs == 0 then
        self:setEnergyNeedMoney(self._energyNeedMoney + 5)
        self:sendNotification(AppEvent.PROXY_BUYEVENT_UPDATE)
    end
end

--野外讨伐令购买
function RoleProxy:onTriggerNet20018Resp(data)
    if data.rs == 0 then
        self:setCrusadeEnergyNeedMoney(self._crusadeEnergyNeedMoney + 10)
        self:sendNotification(AppEvent.PROXY_BUYEVENT_UPDATE)
    end
end


function RoleProxy:onTriggerNet20012Resp(data)
    local iconId = data.iconId
    local pendantId = data.pendantId

    local roleProxy = self:getProxy(GameProxys.Role)
    if iconId ~= 0 then
         roleProxy:setHeadId(iconId)
    end
    if pendantId ~= 0 then
         roleProxy:setPendantId(pendantId)
    end
    
    
    self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_HEAD, data)
end

--缓存当前购买体力的价格
function RoleProxy:onTriggerNet20013Resp(data)
    money = data.price
    self:setEnergyNeedMoney(money)
end

function RoleProxy:onTriggerNet20014Resp(data)

    local function delayS()
        self._worldTileX = data.worldTileX
        self._worldTileY = data.worldTileY

        self:sendNotification(AppEvent.PROXY_BUILDING_MOVE, {x = data.worldTileX, y = data.worldTileY})
    end

    delayS()  --用来测试，网络延迟时，初始化角色时，有没有问题
--    TimerManager:addOnce(10000, delayS, self)

    -- self._worldTileX = data.worldTileX
    -- self._worldTileY = data.worldTileY

     -- self:sendNotification(AppEvent.PROXY_BUILDING_MOVE, {})
end

--//服务端主动推送，军团长的坐标
function RoleProxy:onTriggerNet20700Resp(data)
    self:setLegionLeaderWorldTilePos(data.legionLeaderX, data.legionLeaderY)
end

function RoleProxy:onTriggerNet20015Resp(data)  --开服礼包面板更新
    local rs = rawget(data, "rs")
    if rs and rs ~= 0 then
        return
    end
    for k,v in pairs(self.openServerData.canGet) do
        if v == data.dayNum then
            self.openServerData.canGet[k] = nil
        end
    end
    self:initOpenServerData(self.openServerData)
end

function RoleProxy:onTriggerNet20016Resp(data)  --每日登陆礼包
    self:sendNotification(AppEvent.PROXY_EVERYDAYLOGGIFT_INFO_UPDATE, data)
end

function RoleProxy:setTigerMachinePoint()
    self.openServerData.allDay = -1 
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkThirtyRedPoint()
end

function RoleProxy:initOpenServerData(data)
    local config = ConfigDataManager:getConfigData(ConfigData.DayLandConfig)
    self.openServerData = data
    local dayData = {}
    for k,v in pairs(data.canGet) do
        dayData[v] = true
    end

    local itemList  = {}
    local loginDay = data.allDay
    for i=1,#config do
        itemList[i] = {}
        local state = -1
        --已领
        if dayData[i] == nil and i <= loginDay then
            state = 0
        --未可领
        elseif dayData[i] == nil and i > loginDay then
            state = 1
        --可领
        elseif dayData[i] ~= nil then
            state = 2
        end
        itemList[i].state = state
    end
    self.openServerList = itemList
    self:sendNotification(AppEvent.PROXY_OPENSERVERGIFT_INFO_UPDATE)
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkThirtyRedPoint()
end

---声望领取飘字
function RoleProxy:onTriggerNet20017Resp(data)
    if data.rs == 0 then
        self.preid = data.preid
    end
end

--称号改变，服务端主动推送
function RoleProxy:onTriggerNet20800Resp(data)
--    logger:error("服务端推送新称号--->onTriggerNet20800Resp")
--    for i=1,#data.design do
--        local v = data.design[i]
--        logger:error("服务端推送新称号--->%d",v)
--    end
--    self._design = data.design
end

--推送已双倍充值的额度
function RoleProxy:onTriggerNet20807Resp(data)
    if data.rs == 0 then
        self._chargeDoubleList = data.chargeDoubleList
        self:sendNotification(AppEvent.PROXY_UPDATE_RECHARGE_INFO, {}) --推送已双倍充值的额度
    end
end

--更新军团名字
function RoleProxy:onTriggerNet20201Resp(data)
    self._legionName = data.name
    if data.name == "" then
        local legionHelpProxy = self:getProxy(GameProxys.LegionHelp)
        legionHelpProxy:deleteAllOtherHelpInfos()
    end
    self:sendNotification(AppEvent.PROXY_LEGION_UPDATE_MAINSCENE_TIP, {}) -- 军团更新，加入或退出
end

--公告
function RoleProxy:onTriggerNet140008Resp(data)
    if self._infoQueue == nil then
        self._infoQueue = Queue.new()
    end
    for _,oneOntice in pairs(data.info) do
        self._infoQueue:push(oneOntice)
    end
    
    local function callback()
        self._isShowNotice = false
        local oneOntice = self._infoQueue:pop()
        if oneOntice ~= nil then
            ComponentUtils:showNotice(self,oneOntice,callback)
            self._isShowNotice = true
        end
    end
    
    if self._isShowNotice ~= true then
        local oneOntice = self._infoQueue:pop()
        if oneOntice ~= nil then
            ComponentUtils:showNotice(self,oneOntice,callback)
            self._isShowNotice = true
        end
    end
    local chat = data.chatInfo
    if not chat then
        return
    end
    chat.isNotice = true
    local chatData = {}
    local chats = {}
    table.insert(chats, chat)
    chatData.chats = chats
    chatData.type = 1
    local chatProxy = self:getProxy(GameProxys.Chat)
    if chat.playerId == self:getPlayerId() then
        chatProxy:onTriggerNet140000Resp(chatData)
    end
end

-- --刷新增益信息
-- function RoleProxy:onTriggerNet90003Resp(data)
--     self._GainInfo = data
--     self:sendNotification(AppEvent.GAIN_INFO_UPDATE, data)
--     self.gainInfoUpdateTiem = os.time()
-- end


-------优化网络通讯

function RoleProxy:getActorInfo()
    return self._actorInfo
end

function RoleProxy:getM20000()
    return self._m20000
end

-- 缓存声望领取状态 0=未封赏 1=已封赏
function RoleProxy:setPrestigeState(state)
    self._prestigeState = state
end

-- 获取声望领取状态
function RoleProxy:getPrestigeState()
    return self._prestigeState
end

-- 获取军团名字
function RoleProxy:getLegionName()
    return self._legionName or ""
end

-- 获取军团等级
function RoleProxy:getLegionLevel()
    return self._legionLevel or 0
end

-- -- 获取通知设置
-- function RoleProxy:getNoticeSetting()
--     return self._noticeSetting
-- end

function RoleProxy:setRoleAttrInfos(attrInfos)
    self._attrInfoMap = {}
    for _, attrInfo in pairs(attrInfos) do
        self:setRoleAttrValue(attrInfo.typeid, attrInfo.value)
    end
    self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, {})
end

function RoleProxy:setRoleAttrValue(typeid, value)
    self._attrInfoMap[typeid] = value
    if typeid == getRoleAttrValue then  --如果属性值是活跃度 检测任务小红点是否需要刷新
        local taskProxy = self:getProxy(GameProxys.Task)
        taskProxy:updateRedPoint()
    end
end

function RoleProxy:getRoleAttrValue(typeid)
    if self._attrInfoMap == nil then
        return 0
    end
    return self._attrInfoMap[typeid] or 0
end

-- 缓存玩家头像
function RoleProxy:setHeadId(iconId)
    self._iconId = iconId
end
-- 缓存头像挂件
function RoleProxy:setPendantId(pendantId)
    self._pendantId = pendantId
end

-- -- 获取繁荣度的废墟状态
-- function RoleProxy:getBoomState()
--     -- body
--     -- a.     繁荣度上限*0.41 ＜ 600时，废墟取该值，当前繁荣度小于（繁荣度上限*0.41）为废墟状态
--     -- b.     繁荣度上限*0.41 ≥ 600时，废墟值取600，当前繁荣度小于600为废墟状态

--     local curBoom = self:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0--繁荣值（cur）
--     local maxBoom = self:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）

--     local isDestroy = false         --true=废墟,false=正常
--     local destroyBoom = 0           --废墟值
--     local tmpBoom = math.floor(maxBoom*0.41) --向下取整
--     if tmpBoom < 600 and curBoom < tmpBoom then
--         -- 废墟
--         isDestroy = true
--         destroyBoom = tmpBoom
--     elseif tmpBoom >= 600 and curBoom < 600 then
--         -- 废墟
--         isDestroy = true
--         destroyBoom = 600
--     end

--     return isDestroy,destroyBoom
-- end

-- 获取繁荣度的废墟状态
function RoleProxy:getBoomState()
    local curBoom = self:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0--繁荣值（cur）
    local maxBoom = self:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）
    local isDestroy,destroyBoom = self:calcBoomState(curBoom, maxBoom)
    return isDestroy,destroyBoom
end

-- 計算繁荣度的废墟状态
function RoleProxy:calcBoomState(curBoom, maxBoom)
    -- a.     繁荣度上限*0.41 ＜ 600时，废墟取该值，当前繁荣度小于（繁荣度上限*0.41）为废墟状态
    -- b.     繁荣度上限*0.41 ≥ 600时，废墟值取600，当前繁荣度小于600为废墟状态

    local isDestroy = false         --true=废墟,false=正常
    local destroyBoom = 0           --废墟值
    local tmpBoom = math.floor(maxBoom*0.41) --向下取整
    if tmpBoom < 600 and curBoom < tmpBoom then
        -- 废墟
        isDestroy = true
        destroyBoom = tmpBoom
    elseif tmpBoom >= 600 and curBoom < 600 then
        -- 废墟
        isDestroy = true
        destroyBoom = 600
    end

    return isDestroy,destroyBoom
end

-- 取繁荣倒计时(秒)
-- type=1 繁荣恢复到满所需的时间(默认)
-- type=2 繁荣恢复到正常所需的时间
-- type=3 繁荣从0恢复到满所需的总时间
-- type=4 繁荣从0恢复到正常所需的总时间
function RoleProxy:getBoomRemainTime(type) 
    -- body
    -- local systemProxy = self:getProxy(GameProxys.System)
    local remainTime = self:getRemainTimeByPower(PlayerPowerDefine.POWER_boom)


    local curBoom = self:getRoleAttrValue(PlayerPowerDefine.POWER_boom) or 0--繁荣值（cur）
    local maxBoom = self:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit) or 0--繁荣值（max）

    local type = type or 1 --type=1 恢复到满所需时间(默认)

    local boom = maxBoom - curBoom
    if boom > 1 then
        local isDestroy,destroyBoom = self:getBoomState()
        -- if isDestroy == true then
        --     -- remainTime = systemProxy:getRemainTime( SystemTimerConfig.DEFAULT_BOOM_RECOVER, 1, 0 )
        --     -- print("废墟计时器(4,1,0) remainTime = "..remainTime)

        --     remainTime = self:getRemainTimeByPower(PlayerPowerDefine.POWER_boom)
        -- else
        --     -- remainTime = systemProxy:getRemainTime( SystemTimerConfig.DEFAULT_BOOM_RECOVER, 0, 0 )
        --     -- print("正常计时器(4,0,0) remainTime = "..remainTime)

        --     remainTime = self:getRemainTimeByPower(PlayerPowerDefine.POWER_boom)
        -- end

        if isDestroy == false and type == 1 then
            -- 正常到满
            remainTime = remainTime + (boom - 1) * 60
        elseif isDestroy == true and type == 2 then
            -- 废墟到正常
            remainTime = remainTime + (destroyBoom - curBoom - 1) * (60 + 30)
        elseif type == 3 then
            -- 0到满总时间
            curBoom = 0
            remainTime = remainTime + (destroyBoom - curBoom - 0) * (60 + 30) + (maxBoom - destroyBoom) * 60
        elseif type == 4 then
            -- 0到正常总时间
            curBoom = 0
            remainTime = remainTime + (destroyBoom - curBoom - 0) * (60 + 30)
        else
            -- 当前到满（默认）
            remainTime = remainTime + (destroyBoom - curBoom - 1) * (60 + 30) + (maxBoom - destroyBoom) * 60
        end
    end
    return remainTime
end


--通过power获取对应的值
--资源 资源值
--道具 道具数量
function RoleProxy:getRolePowerValue(power, typeid)
    local value = 0
    if power == GamePowerConfig.Item then
        local itemProxy = self:getProxy(GameProxys.Item)
        value = itemProxy:getItemNumByType(typeid)
    elseif power == GamePowerConfig.Resource then
        value = self:getRoleAttrValue(typeid)
    elseif power == GamePowerConfig.Soldier then
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        value = soldierProxy:getSoldierCountById(typeid)
    elseif power == GamePowerConfig.Command then --获取司令部的等级
        local buildingProxy = self:getProxy(GameProxys.Building)
        value = buildingProxy:getCommandLv()
    elseif power == GamePowerConfig.OrdnanceFragment then --获取军械碎片数量
        local partsProxy = self:getProxy(GameProxys.Parts)
        value = partsProxy:getPieceNumByID(typeid)
    elseif power == GamePowerConfig.HeroTreasureFragment then --获取宝具碎片数量
        local heroTreasureProxy = self:getProxy(GameProxys.HeroTreasure)
        value = heroTreasureProxy:getPieceNumByID(typeid)
    elseif power == GamePowerConfig.HeroFragment then --获取武将碎片数量
        local heroProxy = self:getProxy(GameProxys.Hero)
        value = heroProxy:getHeroPieceNumByID(typeid)
    elseif power == GamePowerConfig.Hero then  -- 武将数量
        local heroProxy = self:getProxy(GameProxys.Hero)
        value = heroProxy:getHeroNumById(typeid)
    end
    return value
end

--获取角色信息
function RoleProxy:getRoleName()
    return self.name or ""
end

function RoleProxy:getPlayerId()
    return self._playerId or -1
end

-- 世界地图种子id
function RoleProxy:getWorldSeedTypeId()
    return self._worldSeedTypeId
end

-- 获取玩家头像
function RoleProxy:getHeadId()
    return self._iconId or 1
end

-- 获取头像挂件
function RoleProxy:getPendantId()
    return self._pendantId or 1
end

function RoleProxy:setEnergyNeedMoney(money)
    self._energyNeedMoney = money
end

-- 获取当前购买体力的价格
function RoleProxy:getEnergyNeedMoney()
    if self._energyNeedMoney == nil then
        self._energyNeedMoney = 5
    end
    return self._energyNeedMoney
end

-- 获取当前购买讨伐令的价格
function RoleProxy:setCrusadeEnergyNeedMoney(money)
    self._crusadeEnergyNeedMoney = money
end

-- 获取当前购买讨伐令的价格
function RoleProxy:getCrusadeEnergyNeedMoney()
    if self._crusadeEnergyNeedMoney == nil then
        self._crusadeEnergyNeedMoney = 10  --讨伐令默认10元宝
    end
    return self._crusadeEnergyNeedMoney
end

--弹出购买体力的弹窗
function RoleProxy:getBuyEnergyBox(panel,isShowMsgBox, buyEnergyPanel, noShowCommand)
    local price = self:getEnergyNeedMoney()
    local haveGold = self:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    -- 购买次数不足
    if price < 0 then
        self:showSysMessage(TextWords:getTextWord(562))
        return
    end

    local function callByEnergy()
        local data = {}
        if price > haveGold then
        -- 元宝不足 固定弹窗 UIRecharge
            data.money = price
            panel:isShowRechargeUI(data)
        else
            self:onTriggerNet20011Req(data)
        end
    end

    -- 
    if isShowMsgBox ~= nil then 
        callByEnergy() -- 直接完成购买
        return
    end

    local content = string.format(TextWords:getTextWord(507), price) -- 显示字段
    -- UI公用界面队列之中不显示command, 只要弹窗购买
    if noShowCommand then
        self:showMessageBox(content, callByEnergy)
        return
    end

    local showType = 1 
    if panel.uiCommand == nil then
        local uiCommand = UICommand.new(panel) 
        uiCommand:show(showType, content, callByEnergy)
        panel.uiCommand = uiCommand
    else
        panel.uiCommand:show(showType, content, callByEnergy)
    end

    if buyEnergyPanel ~= nil then
        buyEnergyPanel:hide() -- 隐藏UIBuyEnergy
    end
end

--弹窗购买讨伐令
function RoleProxy:getBuyCrusadeEnergyBox(panel,isShowMsgBox, buyEnergyPanel, noShowCommand)
    local price = self:getCrusadeEnergyNeedMoney()
    local haveGold = self:getRoleAttrValue(PlayerPowerDefine.POWER_gold) or 0
    -- 购买次数不足
    if price < 0 then
        self:showSysMessage(TextWords:getTextWord(564))
        return
    end

    local function callByEnergy()
        local data = {}
        if price > haveGold then
        -- 元宝不足 固定弹窗 UIRecharge
            data.money = price
            panel:isShowRechargeUI(data)
        else
            self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20018, data)
        end
    end

    -- 直接弹的时候isShowMsgBox == nil 
    if isShowMsgBox ~= nil then
        callByEnergy() -- 直接完成购买
        return
    end

    local content = string.format(TextWords:getTextWord(565), price)
    -- UI公用界面队列之中不显示command, 只要弹窗购买
    if noShowCommand then
        self:showMessageBox(content, callByEnergy)
        return
    end

    local showType = 2 
    if panel.uiCommand == nil then
        local uiCommand = UICommand.new(panel) 
        uiCommand:show(showType, content, callByEnergy)
        panel.uiCommand = uiCommand
    else
        panel.uiCommand:show(showType, content, callByEnergy)
    end
    if buyEnergyPanel ~= nil then
        buyEnergyPanel:hide() -- 隐藏UIBuyEnergy
    end
end


-- 根据头像获取玩家性别: 1=boy,2=girl
--默认置为1
function RoleProxy:getSexByHeadId()
    local sex = 1   
    if self._iconId ~= nil then
        local confData = ConfigDataManager:getConfigById(ConfigData.HeadPortraitConfig, self._iconId)
        if confData == nil then
            return sex
        end
        sex = confData.gender
        if sex == nil then
            sex = 1
        end
    end
    return sex
end

--是否有新手礼包
function RoleProxy:hasNewGift()
    return self._newGift == 0
end

function RoleProxy:getNewGift()
    self._newGift = 1
end

function RoleProxy:getWorldTilePos()
    return self._worldTileX, self._worldTileY
end

-- 计算世界地图两个节点的行军时间：秒
RoleProxy.MarchingType_World = 1 -- 世界行军
RoleProxy.MarchingType_Town = 2 -- 盟战行军
RoleProxy.MarchingType_Rebles = 3 -- 叛军行军
function RoleProxy:calcNeedTime(marchingType, beginTileX, beginTileY, targetTileX, targetTileY)
    local timeLimit = 60
    local timeEach = 12
     
    local marchingCfgData = ConfigDataManager:getConfigById(ConfigData.WorldMarchingConfig, marchingType)
    if marchingCfgData ~= nil then
        timeLimit = marchingCfgData.timeLimit
        timeEach = marchingCfgData.timeEach
    end
    
    local dst = math.sqrt(math.pow(beginTileX - targetTileX, 2) + math.pow(beginTileY - targetTileY, 2))
    local needTime = dst * timeEach + timeLimit
    
    -- 行军速度加成比
    local speedRate = self:getRoleAttrValue(PlayerPowerDefine.NOR_POWER_speedRate)    

    local addSpeedRate = 0
    if marchingType == RoleProxy.MarchingType_Rebles then        
        local seasonProxy = self:getProxy(GameProxys.Seasons)
        if seasonProxy:isWorldLevelOpen() then
            local worldLevelCfgData = seasonProxy:getWorldLevelConfigData()
            addSpeedRate = worldLevelCfgData.goSpeed
        end
    end

    needTime = math.ceil( math.floor(needTime) /(1 + (speedRate + addSpeedRate) / 10000))

    return needTime
end

function RoleProxy:getLegionLeaderWorldTilePos()
    return self._legionLeaderX, self._legionLeaderY
end

--设置军团长的世界坐标
function RoleProxy:setLegionLeaderWorldTilePos(x, y)
    self._legionLeaderX = x
    self._legionLeaderY = y
end

function RoleProxy:hasLegion()
    return self:getRoleAttrValue(PlayerPowerDefine.POWER_LegionId) > 0
end

--retrun  不飘module  返回真  飘module 返回假
function RoleProxy:isModuleShowFly(configName)
    configName = configName or ConfigData.NoFlyModuleConfig
   local noFlyData = ConfigDataManager:getConfigData(configName)
   for k,v in pairs(noFlyData) do
        if self:isModuleShow(v.module) then
            return true
        end 
   end
   return false
end

------
-- 模块是否在模块配置表中，是返回value数据
function RoleProxy:isInModuleConfig(moduleName)
    local configData = ConfigDataManager:getConfigData(ConfigData.ModuleControlConfig)
    -- local state = false
    local itemData = nil 
    for key, value in pairs(configData) do
        if value.module == moduleName then
            -- state = true
            itemData = value
            break
        end
    end
    return itemData
end

function RoleProxy:getLayer(name)
    return self:getCurGameLayer(GameLayer.popLayer)
end

function RoleProxy:getParent()
    return self:getCurGameLayer(GameLayer.popLayer)
end

function RoleProxy:isHasData(powerId, info)
    if powerId == GamePowerConfig.HeroTreasure then
        local htProxy = self:getProxy(GameProxys.HeroTreasure)
        return htProxy:isHasTreasure(info)
    end
    if powerId == GamePowerConfig.HeroTreasureFragment then
        local htProxy = self:getProxy(GameProxys.HeroTreasure)
        return  htProxy:isHasTreasureFragment(info)
    end
    if powerId == 409 then
        local heroProxy = self:getProxy(GameProxys.Hero)
        if not heroProxy:isExpCar(info) then
            return false
        end
    end
    local id = powerId == 409 and info.heroId or info.id
    local data = nil
    local isKeyValue = powerId == GamePowerConfig.Hero
    if powerId == GamePowerConfig.Hero then
        data = self:getProxy(GameProxys.Hero):getAllHeroData()
    else
        data = self:getProxy(GameProxys.Parts):getAllData()
    end
    if isKeyValue then
        return data[id] ~= nil
    else
        local rs = false
        for k,v in pairs(data) do
            if v.id == id then
                rs = true
                break
            end
        end
        return rs
    end
end

-- @param    变化的数据
-- @tempData 待加入的表格
-- @index    从1开始，
-- @powerId   
-- @key      是否唯一
function RoleProxy:setDataRewardFly(infos, tempData, index, powerId, numString)
    --if  _G.next(infos) then
        --return index
    --end
    numString = numString or "num"
    for _,info in pairs(infos) do
        --特殊处理英雄的信息没有typeid这个字段
        local typeid
        if powerId == GamePowerConfig.Hero then
            typeid = info.heroId
        elseif powerId == GamePowerConfig.Counsellor then
            typeid = info.typeId
        else
            typeid = info.typeid
        end

        local config = ConfigDataManager:getConfigByPowerAndID(powerId, typeid)
        if config ~= nil and config.showControl == 1 then -- config.showControl为1的时候才进reward
            if numString ~= "onlyOne" then
                if powerId == GamePowerConfig.Counsellor then
                    tempData.rewards[index] = {power = powerId, num = numString, typeid = typeid}
                else
                    local oldnum = self:getRolePowerValue(powerId, typeid)
                    tempData.rewards[index] = {power = powerId, num = info[numString] - oldnum,typeid = typeid}
                end
            else
                --军械或者武将先判断是否存在。存在就不飘
                local isShow = self:isHasData(powerId, info)
                local newNum = isShow and 0 or 1
                tempData.rewards[index] = {power = powerId, num = newNum, typeid = typeid}
            end
            index = index + 1 
        end
    end
    return index
end

function RoleProxy:getOpenServerData()
    return self.openServerData
end

function RoleProxy:getOpenServerList()
    return self.openServerList
end

function RoleProxy:getPreid()
    local preid = self.preid
    self.preid = 0
    return preid
end

-- function RoleProxy:getGainInfo()
--     local tempData = {}
--     tempData = clone(self._GainInfo)
--     --self._GainInfo = self._GainInfo or {rs = 0, itemBuffInfo = {}}
--     local nowTime = os.time()
--     if tempData.itemBuffInfo ~= nil then
--         for k,v in pairs(tempData.itemBuffInfo) do
--             v.time = v.time - (nowTime - self.gainInfoUpdateTiem)
--             if v.time < 0 then
--                 tempData.itemBuffInfo[k] = nil
--             end
--         end
--     end
--     return tempData
-- end

function RoleProxy:initResConf()
    -- body MapModule/RoleInfoModule/WarehouseModule等模块适用
    -- self._resConf = ConfigDataManager:getConfigData(ConfigData.ResourceConfig)
    self._powerDef = {
                        [1] = {cur = PlayerPowerDefine.POWER_tael, max = PlayerPowerDefine.POWER_tael_Capacity},        --银两
                        [2] = {cur = PlayerPowerDefine.POWER_iron, max = PlayerPowerDefine.POWER_iron_Capacity},        --铁锭
                        [3] = {cur = PlayerPowerDefine.POWER_stones, max = PlayerPowerDefine.POWER_stones_Capacity},    --石料
                        [4] = {cur = PlayerPowerDefine.POWER_wood, max = PlayerPowerDefine.POWER_wood_Capacity},        --木头
                        [5] = {cur = PlayerPowerDefine.POWER_food, max = PlayerPowerDefine.POWER_food_Capacity},        --粮食
                    }
end

------
-- 属性值转化字符串显示
function RoleProxy:attriToShowStr(id, value)
    local showStr = value
    local configInfo = ConfigDataManager:getConfigById(ConfigData.ResourceConfig, id)

    if configInfo.attributeType == 1 then
        showStr = value/100
    elseif configInfo.attributeType == 2 then
        showStr = value/100 .. "%"
    end

    return showStr
end


function RoleProxy:getResDataAndConf()
    --print("获取资源数据···MapInfoPanel:getResData()----------0")
    local data = {}
    -- local roleProxy = self:getProxy(GameProxys.Role)

    local cur,max,per,indexCur,indexMax = nil,nil,nil,nil,nil
    for i=1,#self._powerDef do
        indexCur = self._powerDef[i].cur
        indexMax = self._powerDef[i].max
        cur = self:getRoleAttrValue(indexCur) or 0 --当前拥有量
        max = self:getRoleAttrValue(indexMax) or 0 --容量
        data[indexCur] = cur --当前拥有量
        data[indexMax] = max --容量

        -- 计算资源百分比
        if cur >= max then
            per = 100
        else
            per = cur/max*100
        end
        data[indexCur..i] = per or 0

    end

    --print("获取资源数据···MapInfoPanel:getResData()----------1")
    return data,self._powerDef
end


------------------------------------------------------------------------------
-- 定时器
------------------------------------------------------------------------------
-- 来自20002的更新 是否需要创建倒计时
function RoleProxy:updateRoleRemainTime(diff)
    -- body
    local powerTab = {
                        PlayerPowerDefine.POWER_boom, 
                        PlayerPowerDefine.POWER_energy, 
                        PlayerPowerDefine.POWER_boomUpLimit,
                        PlayerPowerDefine.POWER_crusadeEnergy
                    }


    if diff.typeid == powerTab[1] then --繁荣从满到不满
        local remainTime = self:getRemainTimeByPower(powerTab[1])
        if remainTime == 0 then
            local maxValue = self:getRoleAttrValue(powerTab[3])

            -- 繁荣少1点满
            -- if diff.value == (maxValue-1) then
            --     self:onTriggerNet20500Req({}) --请求校验定时器
            -- end

            -- 繁荣不满
            if diff.value < maxValue then
                self:onTriggerNet20500Req({}) --请求校验定时器
            end

        end

    elseif diff.typeid == powerTab[2] and diff.value < self._maxEnergy then --军令不满
        local remainTime = self:getRemainTimeByPower(powerTab[2])
        if remainTime == 0 then
            self:onTriggerNet20501Req({}) --请求校验定时器
        end
    elseif diff.typeid == powerTab[4] and diff.value < self._maxCrusadeEnergy then --讨伐令不满
        local remainTime = self:getRemainTimeByPower(powerTab[4])
        if remainTime == 0 then
            self:onTriggerNet20502Req({}) --请求校验定时器
        end
    end

end

-- 更新繁荣定时器到定时器
function RoleProxy:setBoomRemainTime(remainTime)
    -- body
    -- local remainTime = 60 --TODO 测试代码
    -- self:setRoleAttrValue(PlayerPowerDefine.POWER_boom, 10)  --TODO 测试代码 f4500

    -- local systemProxy = self:getProxy(GameProxys.System)
    -- local remainTime = systemProxy:getRemainTime( SystemTimerConfig.DEFAULT_BOOM_RECOVER, 0, 0 ) --TODO 测试代码
    print("定时器···Boom remainTime", remainTime) --TODO 调试信息
    if remainTime >= 0 then
        self:updateRemainTime(PlayerPowerDefine.POWER_boom, remainTime, 20500)
    end
end

-- 更新体力定时器到定时器
function RoleProxy:setEnergyRemainTime(remainTime)
    -- body
    -- local remainTime = 10 --TODO 测试代码
    print("定时器···Energy remainTime", remainTime) --TODO 调试信息
    if remainTime >= 0 then
        self:updateRemainTime(PlayerPowerDefine.POWER_energy, remainTime, 20501)
    end
end

--更新讨伐令定时器
function RoleProxy:setCrusadeEnergyRemainTime(remainTime)
    if remainTime >= 0 then
        self:updateRemainTime(PlayerPowerDefine.POWER_crusadeEnergy, remainTime, AppEvent.NET_M2_C20502)
    end
end

-- 更新某个定时器 （来自20000/20500协议）
function RoleProxy:updateRemainTime(power, remainTime, cmd) --TODO power = PlayerPowerDefine.xxx
    -- body
    local key = self:getTimeKey(power)
    print("更新某个定时器 ···key,power,cmd", key, power, cmd) --TODO 调试信息

    local sendData = {}
    sendData.cmd = cmd
    sendData.power = power


    local cmdList = {}
    cmdList[20500] = {cmd = AppEvent.NET_M2_C20500, callFunc = self.CompleteCall20500}
    cmdList[20501] = {cmd = AppEvent.NET_M2_C20501, callFunc = self.CompleteCall20501}
    cmdList[20502] = {cmd = AppEvent.NET_M2_C20502, callFunc = self.CompleteCall20502}
    -- cmdList[20501] = AppEvent.NET_M2_C20501


    print("更新某个定时器···cmdList[cmd]", cmdList[cmd].cmd)

    -- self:pushRemainTime(key, remainTime, cmdList[cmd], sendData, self.remainTimeCompleteCall)
    self:pushRemainTime(key, remainTime, cmdList[cmd].cmd, sendData, cmdList[cmd].callFunc)
end

-- 定时器唯一标识KEY
function RoleProxy:getTimeKey(power)
    -- body
    local key = "key_role_"..power
    return key
end

-- -- 倒计时结束回调
-- function RoleProxy:remainTimeCompleteCall(sendDataList)
--     -- body

--     for _,sendData in pairs(sendDataList) do

--         -- 先更新对应的值
--         local power = sendData.power
--         local value = self:getRoleAttrValue(power)
--         local maxValue = nil

--         if power == PlayerPowerDefine.POWER_boom then --繁荣
--             maxValue = self:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit)
--             value = value + 1
--             if value > maxValue then
--                 value = maxValue
--             end
--             self:setRoleAttrValue(power, value)
            
--             -- 通知更新
--             self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_POWER, {power = power})

--         elseif power == PlayerPowerDefine.POWER_energy then --军令
--             maxValue = 20
--             value = value + 1
--             if value > maxValue then
--                 value = maxValue
--             end
--             self:setRoleAttrValue(power, value)

--             -- 通知更新
--             self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_POWER, {power = power})
--         end


--         -- 再执行回调
--         print("倒计时结束回调···sendData.cmd", sendData.cmd)
--         local triggerFunc = self["onTriggerNet" .. sendData.cmd .. "Req"]
--         if triggerFunc then
--             local data = {}
--             triggerFunc(self, data)
--             return
--         end

--     end
-- end


-- 倒计时结束回调
function RoleProxy:CompleteCall20501(sendDataList)
    -- body

    for _,sendData in pairs(sendDataList) do

        -- 先更新对应的值
        local power = sendData.power
        local value = self:getRoleAttrValue(power)
        local maxValue = nil

        if power == PlayerPowerDefine.POWER_energy then --军令
            local remainTime = self:getRemainTimeByPower(power)
            if remainTime == 0 then
                -- maxValue = self._maxEnergy
                -- value = value + 1
                -- if value > maxValue then
                --     value = maxValue
                -- end
                -- self:setRoleAttrValue(power, value)

                -- -- 通知更新
                -- self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_POWER, {power = power})

                -- 再执行回调
                print("倒计时结束回调CompleteCall20501···sendData.cmd", sendData.cmd)
                self:onTriggerNet20501Req({})
                return
            else
                return
            end
        end

    end
end


-- 倒计时结束回调
function RoleProxy:CompleteCall20502(sendDataList)
    self:onTriggerNet20502Req({})
end

-- 倒计时结束回调
function RoleProxy:CompleteCall20500(sendDataList)
    -- body

    for _,sendData in pairs(sendDataList) do

        -- 先更新对应的值
        local power = sendData.power
        local value = self:getRoleAttrValue(power)
        local maxValue = nil

        if power == PlayerPowerDefine.POWER_boom then --繁荣
            local remainTime = self:getRemainTimeByPower(power)
            if remainTime == 0 then
                -- maxValue = self:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit)
                -- value = value + 1
                -- if value > maxValue then
                --     value = maxValue
                -- end
                -- self:setRoleAttrValue(power, value)
                
                -- -- 通知更新
                -- self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_POWER, {power = power})

                -- 再执行回调
                print("倒计时结束回调CompleteCall20500···sendData.cmd", sendData.cmd)
                self:onTriggerNet20500Req({})
                return
            else
                return
            end
        end

    end
end


-- 定时器结束发请求
function RoleProxy:onTriggerNet20500Req(data)
    -- body
    logger:info("···onTriggerNet20500Req")
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20500, data)
end

-- 定时器结束发请求
function RoleProxy:onTriggerNet20501Req(data)
    -- body
    logger:info("···onTriggerNet20501Req")
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20501, data)
end

-- 讨伐令定时器结束发请求
function RoleProxy:onTriggerNet20502Req(data)
    -- body
    logger:info("···onTriggerNet20502Req")
    self:syncNetReq(AppEvent.NET_M2, AppEvent.NET_M2_C20502, data)
end

-- 获取倒计时（公共接口）
function RoleProxy:getRemainTimeByPower(power) --TODO power = PlayerPowerDefine.xxx
    -- body
    local key = self:getTimeKey(power)
    local remainTime = self:getRemainTime(key)
    return remainTime
end


function RoleProxy:onTriggerNet20500Resp(data)
    -- body
    if data.rs == 0 then
        if data.boomRefTime then
            if data.boomRefTime == -1 then
                -- 校验成功 暂时不做操作
                print("20500···校验成功 暂时不做操作")

                local value = self:getRoleAttrValue(PlayerPowerDefine.POWER_boom)
                local maxValue = self:getRoleAttrValue(PlayerPowerDefine.POWER_boomUpLimit)
                local isDestroy,destroyBoom = self:getBoomState()
                local remainTime = nil
                if value < maxValue then
                    if isDestroy then
                        remainTime = 60+30   --废墟
                    else
                        remainTime = 60      --正常
                    end
                else
                    remainTime = 0           --已满 置0清除定时器
                end
                print("20500...校验成功，更新定时器 remainTime",remainTime)
                self:setBoomRemainTime(remainTime)
            
            else
                -- 校验失败 更新定时器
                -- 在线繁荣度变化，更新定时器

                local value = self:getRoleAttrValue(PlayerPowerDefine.POWER_boom)
                -- value = value - 1
                -- if value < 0 then
                --     value = 0
                -- end
                -- print("20500...校验失败，更新定时器 data.boomRefTime value",data.boomRefTime,value)
                print("20500...校验失败，更新定时器 data.boomRefTime value",data.boomRefTime,value)
                -- self:setRoleAttrValue(PlayerPowerDefine.POWER_boom, value)
                

                self:setBoomRemainTime(data.boomRefTime)
            end
        end
    end
end

function RoleProxy:onTriggerNet20501Resp(data)
    -- body
    if data.rs == 0 then
        if data.energyRefTime then
            if data.energyRefTime == -1 then
                -- 校验成功 暂时不做操作
                print("20501···校验成功 暂时不做操作")

                local value = self:getRoleAttrValue(PlayerPowerDefine.POWER_energy)
                print("value===",value)
                local maxValue = self._maxEnergy
                local remainTime = nil
                if value < maxValue then
                    remainTime = 60*30   --未满
                else
                    remainTime = 0       --置0清除定时器
                end
                print("20500...校验成功，更新定时器 remainTime",remainTime)
                value = value + 1 <= maxValue and value + 1 or maxValue
                self:setRoleAttrValue(PlayerPowerDefine.POWER_energy, value)
                self:setEnergyRemainTime(remainTime)
                self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, {})
            else
                -- 校验失败 更新定时器
                -- 在线体力变化，更新定时器

                print("20501···校验失败 更新定时器")
                self:setEnergyRemainTime(data.energyRefTime)
            end
        end
    end
end

--讨伐令
function RoleProxy:onTriggerNet20502Resp(data)
    if data.rs == 0 then
        if data.energyRefTime == -1 then
                -- 校验成功 暂时不做操作
                print("20501···校验成功 暂时不做操作")

                local value = self:getRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy)
                print("value===",value)
                local maxValue = self._maxCrusadeEnergy
                local remainTime = nil
                if value < maxValue then
                    remainTime = 60*60   --未满
                else
                    remainTime = 0       --置0清除定时器
                end
                print("20500...校验成功，更新定时器 remainTime",remainTime)
                value = value + 1
                self:setRoleAttrValue(PlayerPowerDefine.POWER_crusadeEnergy, value)
                self:setCrusadeEnergyRemainTime(remainTime)
                self:sendNotification(AppEvent.PROXY_UPDATE_ROLE_INFO, {})
            else
                -- 校验失败 更新定时器
                -- 在线体力变化，更新定时器

                print("20501···校验失败 更新定时器")
                self:setCrusadeEnergyRemainTime(data.energyRefTime)
            end
    end
end

function RoleProxy:getFreeTime()
    local viplv = self:getRoleAttrValue(PlayerPowerDefine.POWER_vipLevel) or 0
    local config = ConfigDataManager:getInfoFindByOneKey(ConfigData.VipDataConfig, "level", viplv)
    local freeTime = config.freetimes
    return freeTime
end

------
-- 保存背包按钮的原始坐标
function RoleProxy:setBtnItem5Pos(x, y)
    self._bagItemPosX = x
    self._bagItemPosY = y
end

------
-- 获取背包按钮的原始坐标
function RoleProxy:getBagBtnPos()
    return self._bagItemPosX, self._bagItemPosY
end

------
-- 
function RoleProxy:setToolbarPanel(toolbarView)
    self._toolbarPanel = toolbarView
end

function RoleProxy:getToolbarPanel()
    return self._toolbarPanel
end


-----
-- 接入获取
function RoleProxy:showGetGoodsEffect(result)
    
--    if self._itemList == nil then
--        self._itemList = {}
--    end

--    local posX, posY 
--    local posState
--    local toolbarPanel = self:getToolbarPanel()
--    posX, posY = toolbarPanel:getBtnItem5Pos()
--    posState = true
----        if posX < toolbarPanel._btnListView:getPositionX() then
----            posX = toolbarPanel._btnListView:getPositionX()
----            posState = false
----        end
--   -- local result = {}
--   -- result[1] = {typeid = 4013, num = 2, power = 401}
--   -- result[2] = {typeid = 206, num = 25, power = 407}
--   -- result[3] = {typeid = 4012, num = 20, power = 401}
--   -- result[4] = {typeid = 4013, num = 2, power = 401}
--   -- result[5] = {typeid = 4013, num = 2, power = 401}
--   -- result[6] = {typeid = 4012, num = 20, power = 401}
--   -- result[7] = {typeid = 4013, num = 2, power = 401}
--   -- result[8] = {typeid = 4013, num = 2, power = 401}
--   -- result[9] = {typeid = 4013, num = 2, power = 401}
--   -- result[10] = {typeid = 4013, num = 2, power = 401}
--   -- result[11] = {typeid = 4013, num = 2, power = 401}
--   -- result[12] = {typeid = 4013, num = 2, power = 401}

--    if not self.node then
--        local layer = self:getLayer(GameLayer.popLayer)
--        self.node = cc.Node:create()
--        layer:addChild(self.node)
--    end

--     local function delayGetRewardAction(obj, result)
--        local uiGetProp = self.node.uiGetProp
--        uiGetProp = UIRewardWithAct.new(self.node, self, posState)
--        uiGetProp.actionQueue = self._showGetGoodsEffectQueue
--        uiGetProp:show(result, cc.p(posX, posY))
--    end

--    local function complete()
--        if #self._itemList > 0 then
--            self._showGetGoodsEffectQueue:push(self._itemList)
--            self._itemList = {}
--        end
--    end

--    if self._showGetGoodsEffectQueue == nil then
--        self._showGetGoodsEffectQueue = UIActionQueue.new(delayGetRewardAction, self, complete)
--    end

--    if self._showGetGoodsEffectQueue:isRunning() then  --特效还在播放，将数据缓存起来
--        table.addAll(self._itemList, result)
--    else
--        self._showGetGoodsEffectQueue:push(result) --直接运行了
--    end

    AnimationFactory:playAnimationByName("GetGoodsEffect", result)
    
--    EffectQueueManager:addEffect(EffectQueueType.GET_REWARD_BAG, delayGetRewardAction)
end


------
-- 
-- @param  moduleName [str] 模块名称
-- @return true飘/false不飘
function RoleProxy:getIsModuleIn(moduleName, configName)
    local noData = ConfigDataManager:getConfigData(configName)

    local state = true
    if #noData <= 0 then
        return state
    end
    for key, value in pairs(noData) do 
        if value.module == moduleName then
            state = false
            break
        end
    end
    return state
end

function RoleProxy:getIsCan(state)
    if state then
        return "执行"
    else
        return "禁止"
    end
end

-- 主公功能是否已开启，未开启默认会弹提示
-- id : 配表id / isShowMsg : 是否飘字  / customMsg : 自定义飘字内容
function RoleProxy:isFunctionUnLock(id,isShowMsg,customMsg)
    -- isShowMsg = isShowMsg or true
    if isShowMsg == nil then
        isShowMsg = true
    end
    local info = ConfigDataManager:getConfigById(ConfigData.NewFunctionOpenConfig,id)

    local CommandLv = self:getRolePowerValue(GamePowerConfig.Command, 1)
    local playerLv = self:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    
    if info.type == 1 then  --主公等级
        if info.need > playerLv then
            if isShowMsg then
--                if customMsg then
--                    self:showSysMessage(customMsg)
--                else
                    self:showSysMessage( info.opentips)
--                end
            end
            return false  --未开启
        end
    
    else  --官邸等级
        if info.need > CommandLv then
            if isShowMsg then
--                if customMsg then
--                    self:showSysMessage(customMsg)
--                else
                    self:showSysMessage( info.opentips)
--                end
            end
            return false  --未开启
        end
    end


    return true  --已开启
end

-- 获得玩家最大带兵数
function RoleProxy:maxCommandCount()
    local maxCommandCount = 0
    local baseCommand = self:getRoleAttrValue(PlayerPowerDefine.POWER_command)
    
    local consiglierProxy = self:getProxy(GameProxys.Consigliere)
    local posMaxCount = baseCommand + consiglierProxy:getMaxCommandAdvicer() -- 拥有的军师带兵量最多的

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local openNum = #soldierProxy:getTroopsOpenPosList()

    maxCommandCount = posMaxCount *openNum
    return maxCommandCount
end

--获得玩家的称号信息
function RoleProxy:getDesignInfo()
    return self._design or {}
end

-- 重连成功做标记，引导用到，用完重置
function RoleProxy:setReConnectState(state)
    self._reconnectState = state

    local lordCityProxy = self:getProxy(GameProxys.LordCity)
    lordCityProxy:setIsReconnect(state)
end

-- 获取是否断线重连
function RoleProxy:getReConnectState()
    return self._reconnectState
end

-- 隐藏queue panel
function RoleProxy:onHideQueuePanel()
    self:sendNotification(AppEvent.PROXY_QUEPANEL_HIDE,{})
end

function RoleProxy:setChargeDoubleList(list)
    self._chargeDoubleList = list
end
-- 是否显示首冲双倍
function RoleProxy:isDoubleByLimit(limit)
    if table.indexOf(self._chargeDoubleList, limit) >= 0 then
        return true
    end
    return false
end


-- 获取角色最高等级上限 初始化问题
function RoleProxy:getRoleMaxLevel()    
    local seasonProxy = self:getProxy(GameProxys.Seasons)
    local roleMaxLevel = seasonProxy:getWorldPlayerLevelLimit()
    -- TODO 四季系统上限等级影响
    return roleMaxLevel 
end

function RoleProxy:setLegionId(legionId)
    self._legionId = legionId
end

function RoleProxy:getLegionId(legionId)
    return self._legionId
end

function RoleProxy:getWorldTimeConfig(group)

    local  descTip = nil
    local id = group
    --//null 城战开启时间计算
    local dataTime = ConfigDataManager:getInfosFilterByOneKey(ConfigData.WorldTimeConfig,"group",id)
  
    --//null 当前的系统时间
    local sy =os.date("%Y", GameConfig.serverTime)                                                      --年
    local sm =os.date("%m", GameConfig.serverTime)                                                      --月
    local sd =os.date("%d", GameConfig.serverTime)                                                      --日
    local sx =ComponentUtils:Split(os.date("%X", GameConfig.serverTime), ":")[1]                        --小时 
    local weekDay = os.date("%w", serverTime)    
        
    --//开服时间
    local time = self._serverOpenTime
    local y =os.date("%Y", time)                                                                        --年
    local m =os.date("%m", time)                                                                        --月
    local d =os.date("%d", time)                                                                        --日
    local x =ComponentUtils:Split(os.date("%X",time), ":")[1]                                           --小时
    local serverDay = os.date("%w", time)                                                               --开服时间的星期 几
 --    logger:info("开服时间 "..y..m..d)  
    local t1 = os.date("%Y%m%d",time)
    local t2 = os.date("%Y%m%d",GameConfig.serverTime)
    day1 = {}
    day2 = {}
    day1.year,day1.month,day1.day = string.match(t1,"(%d%d%d%d)(%d%d)(%d%d)")
    day2.year,day2.month,day2.day = string.match(t2,"(%d%d%d%d)(%d%d)(%d%d)")
    numDay1 = os.time(day1)
    numDay2 = os.time(day2)

    local offsetDay =(numDay2-numDay1)/(3600*24)                                                        --开服时间相距当前的天数
 --   print("相差  "..(numDay2-numDay1)/(3600*24).." 天 距开服时间")


    local timeDiff = offsetDay                                                                          --当前时间间距 日
    local timeDiffHour = timeDiff*24 + sx-x                                                             --当前时间间距 小时
    local lowest = timeDiffHour                                                                         --最低时辰
    --print("时间间距  "..timeDiff.."   "..timeDiffHour)
    local smallDay = 100
    local smallHour = 5000
    for k, v  in pairs(dataTime) do
        local tablejson = StringUtils:jsonDecode(v.openTime1)
       -- print("k    v   "..k..tablejson[1])
        if tablejson[1] == 0 then                                                                       --不显示
            descTip = nil
            descTip =""
        elseif tablejson[1]== 1 then                                                                    --周显示
               local day = tablejson[2]*7+tablejson[3]-serverDay                                        --距离开服的 的天数
               --print("距离开活动的天数 "..day)
               if smallDay > day and day-timeDiff > 0 then
                    descTip = string.format(v.openDescribe,day-timeDiff)
                    smallDay = day
                    lowest = smallDay*24
 --                   print(descTip)
               end
        elseif tablejson[1]== 2  then                                                                   --小时显示

                local hour =tablejson[2]                                                                --距离开服的 小时数
               -- print("距离开活动的小时数  "..hour.."   "..lowest)
                if smallHour > hour  and  hour-timeDiffHour > 0 then
                    descTip = string.format(v.openDescribe,hour-timeDiffHour)
                    smallHour = hour
                    lowest = smallHour
   --                 print(descTip)
               end
        end
    end
    --print(" 最低的天 "..lowest)

    if descTip ==nil then
        descTip=""
    end
    return lowest,descTip
end

function RoleProxy:getWorldTimeConfigAll()
    local worldAc={}
    for i=1,6 do
        local activity={}
        activity.low,activity.desc =self:getWorldTimeConfig(i)
        if activity.desc~="" then
        table.insert(worldAc,activity)
        end
    end
    table.sort(worldAc,function(a,b)
                        return a.low < b.low
                        end
    )

--for k, v in pairs(worldAc) do
--	print(k .. "          worldAc  " .. v.low .. v.desc)
--end
    if worldAc[1] ==nil  then
    return nil
    else
    return worldAc[1].desc
    end

end

function RoleProxy:isShowCityWarBtns()
    local diffTime = GameConfig.serverTime - self._serverOpenTime
    local hours = math.floor(diffTime/3600) -- 开服到如今有多少时间
    local configTime = ConfigDataManager:getInfosFilterByOneKey(ConfigData.WorldTimeConfig,"group", 1)
    local showHours = StringUtils:jsonDecode(configTime[1].openTime1)[2]
    if hours >= showHours then
        return true
    else
        return false
    end
end



function RoleProxy:setCustomHeadStatus(status)

    if status == CustomHeadStatus.ONCE_OWN then
        CustomHeadManager:redownloadSelfCustomHead()
    end

    self._customHeadStatus = status
end

function RoleProxy:getCustomHeadStatus()
    return self._customHeadStatus
end

function RoleProxy:setCustomHeadCoolTime(remainTime)
    self._customHeadCoolTime = remainTime

    self:pushRemainTime("CustomHeadCoolTime", remainTime, AppEvent.M140200, {}, 
        self.upRemainTimeComplete)

    logger:error("~~~~~setCustomHeadCoolTime~~~:%d~~~~", remainTime)
end

function RoleProxy:upRemainTimeComplete()
end

function RoleProxy:getCustomHeadCoolTime()
    return self:getRemainTime("CustomHeadCoolTime")
end