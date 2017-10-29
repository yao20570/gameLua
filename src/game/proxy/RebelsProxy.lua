-- /**
--  * @Author:      wzy
--  * @DateTime:    2016-12-1 16:14
--  * @Description: 叛军数据代理
--  */



RebelsProxy = class("RebelsProxy", BasicProxy)

-- 奖励状态
RebelsProxy.RewardStateNone = -1
RebelsProxy.RewardStateCanGet = 0
RebelsProxy.RewardStateHasGot = 1

-- 叛军类型
RebelsProxy.REBELS_TYPE_1 = 1
RebelsProxy.REBELS_TYPE_2 = 2
RebelsProxy.REBELS_TYPE_3 = 3

-- 排名类型
RebelsProxy.RANK_TYPE_PLAYER = 1
RebelsProxy.RANK_TYPE_LEGION = 2

-- 叛军状态
RebelsProxy.REBELS_STATE_ALIVE = 0
RebelsProxy.REBELS_STATE_DEAD = 1
RebelsProxy.REBELS_STATE_NOT_CREATE = 2

-- 排名奖励状态
RebelsProxy.RANK_REWARD_STATE_NOT = 0
RebelsProxy.RANK_REWARD_STATE_OK = 1

function printProto(data)

    local function decodeTable(tbl)
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                if (type(v[1]) == "string" and string.find(v[1], ".")) then
                    local ret = protobuf.decode(v[1], v[2])
                    if ret then
                        tbl[k] = ret
                    end
                end
                decodeTable(tbl[k])
            end
        end
    end

    decodeTable(data)

    parseProto(data)

end

function parseProto(data)
    local str = nil
    local tab = { }
    local keyTab = { }

    local function parseData(pName, data)
        for k, v in pairs(data) do
            local t = type(v)
            local item = nil
            if t == "table" then
                parseData(pName .. k .. ".", v)
            elseif t == "thread" then
                item = { pName .. k, " ============================> thread" }
            elseif t == "function" then
                item = { pName .. k, " ============================> function" }
            elseif t == "userdata" then
                item = { pName .. k, " ============================> userdata" }
            elseif t == "nil" then
                item = { pName .. k, " = nil" }
            elseif t == "boolean" then
                item = { pName .. k, " = " .. (v and "true" or "false") }
            else
                item = { pName .. k, " = " .. v }
            end

            if item ~= nil then
                tab[item[1]] = item[2]
                table.insert(keyTab, item[1])
            end

        end

    end

    parseData("", data)

    table.sort(keyTab)

    for k, v in pairs(keyTab) do
        print(v .. tab[v])
    end
end


function RebelsProxy:ctor()
    RebelsProxy.super.ctor(self)
    self.proxyName = GameProxys.Rebels


end

function RebelsProxy:resetAttr()

    self._isInActivity = false

    self._activityInfo = { }
    self._activityInfo.remainingTime = 0
    self._activityInfo.eliteinTime = 0
    self._activityInfo.headerTime = 0
    self._activityInfo.myRank = 0
    self._activityInfo.legionRank = 0
    self._activityInfo.canKill = 0
    self._activityInfo.playerRewardState = RebelsProxy.RewardStateNone
    self._activityInfo.legionRewardState = RebelsProxy.RewardStateNone

    self._activityInfo.preWeekInfo = { }


    self._activityInfo.playerKillInfo = { }
    self._activityInfo.legionKillInfo = { }

    self._rebelsTypeList = { }
    self._ranksList = { }
end

-- 初始化活动数据 M20000
function RebelsProxy:initSyncData(data)
    RebelsProxy.super.initSyncData(self, data)

    self.keyActivityRemainTime = "activityRemainTime"
    self.keyRebelsAppearRemainTime = { }
    self.keyRebelsAppearRemainTime[RebelsProxy.REBELS_TYPE_2] = "rebelsAppearRemainTime2"
    self.keyRebelsAppearRemainTime[RebelsProxy.REBELS_TYPE_3] = "rebelsAppearRemainTime3"

    -- 重置数据
    self:resetAttr()

    local activityInfo = { }
    activityInfo.rs = 0
    activityInfo.infos = data.serverActivityInfo
    self:onTriggerNet310000Resp(activityInfo)

    -- 排名奖励状态
    self._rankRewardRedPointState = rawget(data, "rebelArmyReward") or RebelsProxy.RANK_REWARD_STATE_NOT
    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })
end

function RebelsProxy:getActivityInfo()
    return self._activityInfo
end

-- 是否活动状态
function RebelsProxy:isInActivity()
    return self._isInActivity
end 

-- 排名奖励红点状态
function RebelsProxy:getRankRewardRedPointCount()
    if self._rankRewardRedPointState == RebelsProxy.RANK_REWARD_STATE_NOT then
        return 0
    end

    return 1
end

-- 能否参与叛军活动
function RebelsProxy:checkCanJoinRebelsActivity()

    local proxy = self:getProxy(GameProxys.Role)
    local isOpen = proxy:isFunctionUnLock(51)
   
    return isOpen
end

-- 获取活动剩余时间
function RebelsProxy:getActivityRemainTime()
    return self:getRemainTime(self.keyActivityRemainTime)
end

-- 设置活动倒计时
function RebelsProxy:setActivityRemainTime(remainTime)
    self:pushRemainTime(self.keyActivityRemainTime, remainTime)
end

-- 获取下一波叛军的出现剩余时间
function RebelsProxy:getNextRebelsTypeAndAppearRemainTime()
    local remainTime = 0
    local rebelsType = RebelsProxy.REBELS_TYPE_1
    for i = RebelsProxy.REBELS_TYPE_1, RebelsProxy.REBELS_TYPE_3 do
        rebelsType = i
        remainTime = self:getRebelsAppearRemainTime(i)
        if remainTime > 0 then
            break
        end
    end

    return rebelsType, remainTime
end

-- 获取叛军出现剩余时间
function RebelsProxy:getRebelsAppearRemainTime(rebelsType)
    return self:getRemainTime(self.keyRebelsAppearRemainTime[rebelsType])
end

-- 设置叛军出现剩余时间
function RebelsProxy:setRebelsAppearRemainTime(rebelsType, remainTime)
    self:pushRemainTime(self.keyRebelsAppearRemainTime[rebelsType], remainTime)
end

-- 获取军团名称
function RebelsProxy:getMyLegionName()
    local roleProxy = self:getProxy(GameProxys.Role)
    local legionName = roleProxy:getLegionName()
    if legionName == "" then
        legionName = TextWords:getTextWord(401204)
    end
    return legionName
end 

-- 上一周的排名信息
function RebelsProxy:getPreWeekInfo()
    return self._activityInfo.preWeekInfo
end

-- 获取叛军数量
function RebelsProxy:getMaxRebelsCountByType(rebelsType)
    local armyGoDesignCfg = ConfigDataManager:getConfigData("ArmyGoDesignConfig");
    local maxCount = armyGoDesignCfg[rebelsType].monsterNum
    return maxCount
end 

-- 玩家最大可击杀数量
function RebelsProxy:getMaxKill()
    return self._activityInfo.canKill or 0;
end

-- 当前活动全服叛军被击杀数量
function RebelsProxy:getAllKillNumByType(rebelsType)
    local rebelsList = self._rebelsTypeList[rebelsType]
    if rebelsList == nil then
        return 0
    end

    local num = 0
    for _, v in pairs(rebelsList) do
        if (v.state ~= RebelsProxy.REBELS_STATE_DEAD) then
            num = num + 1
        end
    end

    return num
end

-- 获取玩家当前击杀数量
function RebelsProxy:getPlayerTotalKillNum()
    local num = 0
    for _, v in pairs(self._activityInfo.playerKillInfo) do
        num = num + v.num
    end
    return num
end

function RebelsProxy:getPlayerKillNum(rebelsType)
    for _, v in pairs(self._activityInfo.playerKillInfo) do
        if v.type == rebelsType then
            return v.num
        end
    end

    return 0
end 

-- 获取击杀数量的富文本信息
function RebelsProxy:getRichTextInfoByKillInfo(killInfo)
    local temp = { }
    for i = RebelsProxy.REBELS_TYPE_1, RebelsProxy.REBELS_TYPE_3 do
        temp[i] = 0
    end

    for _, v in pairs(killInfo) do
        temp[v.type] = v.num
    end

    local str = { }
    for i = RebelsProxy.REBELS_TYPE_1, RebelsProxy.REBELS_TYPE_3 do
        if i ~= RebelsProxy.REBELS_TYPE_1 then
            table.insert(str, { " / ", ColorUtils.tipSize20, ColorUtils:getRichColorByQuality(RebelsProxy.REBELS_TYPE_1) })
        end
        -- 颜色从绿色开始
        table.insert(str, { temp[i], ColorUtils.tipSize20, ColorUtils:getRichColorByQuality(i + 1) })
    end

    return { str }
end

-- 获取自己击杀数量的富文本信息
function RebelsProxy:getRichTextInfoByPlayerKillInfo()
    return self:getRichTextInfoByKillInfo(self._activityInfo.playerKillInfo)
end

-- 获取军团击杀数量的富文本信息
function RebelsProxy:getRichTextInfoByLegionKillInfo()
    return self:getRichTextInfoByKillInfo(self._activityInfo.legionKillInfo)
end

-- 获取击杀分数
function RebelsProxy:getKillScoreByKillInfo(killInfo)
    local score = 0
    for _, v in pairs(killInfo) do
        local rebelsCfg = ConfigDataManager:getInfoFindByOneKey2(ConfigData.ArmyGoDesignConfig, "monsterType", v.type)
        score = score + v.num * rebelsCfg.monsterIntegral
    end
    return score
end

-- 获取自己的击杀分数
function RebelsProxy:getPlayerKillScore()
    return self:getKillScoreByKillInfo(self._activityInfo.playerKillInfo)
end

-- 获取军团的击杀分数
function RebelsProxy:getLegionKillScore()
    return self:getKillScoreByKillInfo(self._activityInfo.legionKillInfo)
end




-- 获取叛军列表
function RebelsProxy:getRebelsList(rebelsType)
    return self._rebelsTypeList[rebelsType] or { };
end

-- 活动结束释放叛军列表
function RebelsProxy:releseRebelsList()
    self._rebelsTypeList = nil
end

-- 通过rebelsType, serverId获取叛军
function RebelsProxy:getRebelsDataByServerId(rebelsType, serverId)
    if self:isInActivity() then
        local list = self:getRebelsList(rebelsType)
        for _, v in pairs(list) do
            if v.dbID == serverId then
                return r
            end
        end
    end

    return nil
end

function RebelsProxy:getRanksData(rankType)
    return self._ranksList[rankType] or { }
end

-- 返回所有段位奖励列表
function RebelsProxy:getRewardDataList(rankType)

    local rewardDataList = ConfigDataManager:getConfigData(ConfigData.ArmyGoActiveConfig)
    local rankId = nil

    -- 取第一条记录就可以
    if rankType == RebelsProxy.RANK_TYPE_PLAYER then
        rankId = rewardDataList[1].personRankingId
    else
        rankId = rewardDataList[1].legionRankingId
    end
    local rankingCfg = ConfigDataManager:getConfigById(ConfigData.CurrentRankingConfig, rankId)

    local rewardDataList = ConfigDataManager:getInfosFilterByOneKey(ConfigData.CRankingRewardConfig, "rankingreward", rankingCfg.rankingreward)
    return rewardDataList
end

-- 跳转到地图上
function RebelsProxy:goToTile(x, y)
    if self:isModuleShow(ModuleName.MapModule) then
        -- 地图已打开
        self:sendNotification(AppEvent.PROXY_REBELS_GO_TO_TILE, {x = x, y = y})        
    else
        -- 地图未打开
        local data = { }
        data.moduleName = ModuleName.MapModule
        data.extraMsg = { }
        data.extraMsg.tileX = x
        data.extraMsg.tileY = y
        self:sendNotification(AppEvent.PROXY_REBELS_OPEN_MAP_AND_JUMP_TO_TILE, data)
    end
end


function RebelsProxy:onTriggerNet310000Resp(data)
    for k, v in pairs(data.infos) do
        if v.type == 206 then
            if v.state == 1 then
                self._isInActivity = true
            else
                self._isInActivity = false
            end
        end
    end
end

-- 请求当前叛军活动的叛军列表
function RebelsProxy:onTriggerNet400000Req(data)
    self:syncNetReq(AppEvent.NET_M40, AppEvent.NET_M40_C400000, { })
end
function RebelsProxy:onTriggerNet400000Resp(data)

    -- printProto(data)

    if data.rs ~= 0 then
        return
    end
    
    if data.alreadyKill >= 0 then        
        self._activityInfo.alreadyKill = data.alreadyKill
    else    
        -- 小于0是服务端推送
        if self._activityInfo.alreadyKill == nil then
            -- self._activityInfo.alreadyKill为nil则没初始化
            self._activityInfo.alreadyKill = 0
        end
    end

    self._activityInfo.canKill = data.canKill
    self._activityInfo.remainingTime = data.endTime
    if data.eliteinTime < 0 then
        self._activityInfo.eliteinTime = 0
    else
        self._activityInfo.eliteinTime = data.eliteinTime
    end

    if data.headerTime < 0 then
        self._activityInfo.headerTime = 0
    else
        self._activityInfo.headerTime = data.headerTime
    end

    -- 活动剩余时间
    self:setActivityRemainTime(self._activityInfo.remainingTime)
    -- 头目出现剩余时间
    self:setRebelsAppearRemainTime(RebelsProxy.REBELS_TYPE_2, self._activityInfo.eliteinTime)
    -- 首领出现剩余时间
    self:setRebelsAppearRemainTime(RebelsProxy.REBELS_TYPE_3, self._activityInfo.headerTime)


    -- 叛军列表
    --[[
    local function compareFunc(a, b)
        return(a.state * 10000000 + a.time) <(b.state * 10000000 + b.time)
    end
    table.sort(data.rebelArmyMobinfos, compareFunc)
    table.sort(data.rebelArmyEliteinfos, compareFunc)
    table.sort(data.rebelArmyHeaderinfos, compareFunc)
    --]]
    self._rebelsTypeList = { }
    self._rebelsTypeList[RebelsProxy.REBELS_TYPE_1] = data.rebelArmyMobinfos
    self._rebelsTypeList[RebelsProxy.REBELS_TYPE_2] = data.rebelArmyEliteinfos
    self._rebelsTypeList[RebelsProxy.REBELS_TYPE_3] = data.rebelArmyHeaderinfos

    self:sendNotification(AppEvent.PROXY_REBELS_ACTIVITY_INFO, { })
end


-- 请求叛军活动当前周的信息
function RebelsProxy:onTriggerNet400001Req(data)
    self:syncNetReq(AppEvent.NET_M40, AppEvent.NET_M40_C400001, { })
end
function RebelsProxy:onTriggerNet400001Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._activityInfo.playerKillInfo = data.alreadyKillInfos
    self._activityInfo.legionKillInfo = data.legionAlreadyKillInfos
    self._activityInfo.myRank = data.myRank
    self._activityInfo.legionRank = data.legionRank


    -- 排名列表
    self._ranksList = { }
    self._ranksList[RebelsProxy.RANK_TYPE_PLAYER] = data.playerAankInfos
    self._ranksList[RebelsProxy.RANK_TYPE_LEGION] = data.legionAankInfos


    self:sendNotification(AppEvent.PROXY_REBELS_RANK_UPDATE, { })
end


-- 请求叛军活动上一周的信息
function RebelsProxy:onTriggerNet400002Req(data)
    self:syncNetReq(AppEvent.NET_M40, AppEvent.NET_M40_C400002, { })
end
function RebelsProxy:onTriggerNet400002Resp(data)
    if data.rs ~= 0 then
        return
    end

    self._activityInfo.preWeekInfo = data

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })
end


-- 请求领取奖励
function RebelsProxy:onTriggerNet400003Req(data)
    self:syncNetReq(AppEvent.NET_M40, AppEvent.NET_M40_C400003, data)
end
function RebelsProxy:onTriggerNet400003Resp(data)
    if data.rs ~= 0 then
        return
    end

    if data.type == RebelsProxy.RANK_TYPE_PLAYER then
        self._activityInfo.preWeekInfo.playerRewardState = RebelsProxy.RewardStateHasGot
    else
        self._activityInfo.preWeekInfo.legionRewardState = RebelsProxy.RewardStateHasGot
    end

    if self._activityInfo.preWeekInfo.playerRewardState == RewardStateCanGet 
        or self._activityInfo.preWeekInfo.legionRewardState == RewardStateCanGet then
        self._rankRewardRedPointState = RebelsProxy.RANK_REWARD_STATE_OK
    else
        self._rankRewardRedPointState = RebelsProxy.RANK_REWARD_STATE_NOT
    end

    local proxy = self:getProxy(GameProxys.BattleActivity)
	proxy:setActivityRedPoint()

    --logger:info("=========>400003 ret self._rankRewardRedPointState:%d", self._rankRewardRedPointState)

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })
end


function RebelsProxy:onTriggerNet400004Req(data)
    self:syncNetReq(AppEvent.NET_M40, AppEvent.NET_M40_C400004, { })
end
function RebelsProxy:onTriggerNet400004Resp(data)

    self._rankRewardRedPointState = RebelsProxy.RANK_REWARD_STATE_OK

    local proxy = self:getProxy(GameProxys.BattleActivity)
    proxy:setActivityRedPoint()

    self:delaySendNotification(AppEvent.PROXY_REDPOINT_UPDATE, { })


end