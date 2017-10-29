-- /**
--  * @Author:	  zhangfan
--  * @DateTime:	2016-05-04
--  * @Description: 竞技场数据代理
--  */

ArenaProxy = class("ArenaProxy", BasicProxy)

function ArenaProxy:ctor()
    ArenaProxy.super.ctor(self)
    self.proxyName = GameProxys.Arena
    self._isSetSquire = false
    self._playIdMap = {}
    self._allMailsList = {}  --全服list
    self._perMailsList = {}  --个人list
    self._mailDetailInfoMap = {} --邮件详细
    self._perDeleteIdList = {} --被删除的邮件
end

function ArenaProxy:resetCountSyncData()
    self:resetBattleCount()
end

function ArenaProxy:resetAttr()
    self._playIdMap = {}
    self._allMailsList = {}
    self._perMailsList = {}
    self._mailDetailInfoMap = {}
    self._perDeleteIdList = {}
end

function ArenaProxy:registerNetEvents()

end

------
-- 初始化个人挑战信息，判断感叹号要用
function ArenaProxy:initSyncData(data)
    self._allArenaInfos = data.areaInfo
    local money = self._allArenaInfos.money -- 判断是否为空
    if money == 0 then
        self._allArenaInfos = nil
    end
end

function ArenaProxy:afterInitSyncData(data)
    self:resetAttr()
    ArenaProxy.super.initSyncData(self, data)
    if self:onSetSoliders() == true then   --只有设置了竞技场阵型才会发
        self._isSetSquire = true
        self:onTriggerNet200000Req()
        TimerManager:addOnce(500,self.onTriggerNet200100Req,self)
    end
end

function ArenaProxy:onGetIsSquire()
    return self._isSetSquire
end

function ArenaProxy:onSetSoliders()
    local forxy = self:getProxy(GameProxys.Soldier)
    local data = forxy:onGetTeamInfo()
    data = data[3].members
    for _,v in pairs(data) do
        if v.num ~= 0 then
            return true
        end
    end
    return false
end

function ArenaProxy:onTriggerNet200000Req()
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200000, {})
end

function ArenaProxy:onTriggerNet200000Resp(data)
    -- data里面包含areaInfo结构体
    data = data.areaInfo
    if data.rs == 0 then
        self._isSetSquire = true
        self:pushRemainTime("ArenaProxy_RemainTime",data.remainTime)
        self._allArenaInfos = data
        self:pushRemainTime("ArenaProxy_nextRefreshTime",data.nextRefreshTime)
        self:sendNotification(AppEvent.PROXY_ARENA_ALLINFOS,data)
        self:sendNotification(AppEvent.PROXY_ARENA_REFRESHTIME,{})
    end
end

function ArenaProxy:getAllInfos()
    return self._allArenaInfos
end


function ArenaProxy:onTriggerNet200001Req(data)
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200001, data)
end

function ArenaProxy:onTriggerNet200001Resp(data)
    if data.rs == 0 then
        local battleProxy = self:getProxy(GameProxys.Battle)
        battleProxy:startBattleReq({type = 3})
    elseif data.rs == -8 then
        self:onTriggerNet200000Req({})
    end
end

function ArenaProxy:onTriggerNet200003Req(data)
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200003, data)
end

function ArenaProxy:onTriggerNet200003Resp(data)
    if data.rs == 0 then
        self._allArenaInfos.challengetimes = data.challengetimes    --购买了挑战次数   服务器无需再推200000协议(优化)
        self._allArenaInfos.money = data.money
        self:sendNotification(AppEvent.PROXY_ARENA_ALLINFOS,self._allArenaInfos)
    end
end

function ArenaProxy:resetBattleCount()
    if self._allArenaInfos then
        self._allArenaInfos.challengetimes = 5
        self._allArenaInfos.buytimes = 0
        self:sendNotification(AppEvent.PROXY_ARENA_ALLINFOS,self._allArenaInfos)
    end
end

function ArenaProxy:onTriggerNet200005Req(data)
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200005, data)
end

function ArenaProxy:onTriggerNet200005Resp(data)
    if data.rs == 0 then
        self._allArenaInfos.lastReward = 2  --表示已领取奖励   服务器无需再推200000协议(优化)
        self:sendNotification(AppEvent.PROXY_ARENA_GETREWARD,{})
    end
end

function ArenaProxy:onTriggerNet200006Req(data)
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200006, data)
end

function ArenaProxy:onTriggerNet200006Resp(data)
    if data.rs == 0 then
        self._allArenaInfos.remainTime = 0   --消除了冷却时间  服务器无需再推200000协议(优化)
        self:pushRemainTime("ArenaProxy_RemainTime",0)
        self:sendNotification(AppEvent.PROXY_ARENA_ALLINFOS,self._allArenaInfos)
    end
end

-- function ArenaProxy:onTriggerNet70001Req(data)
--     self:syncNetReq(AppEvent.NET_M7, AppEvent.NET_M7_C70001, data)
-- end

function ArenaProxy:onTriggerNet140001Req(data)
    if self._playIdMap[data.playerId] == nil then
        self:syncNetReq(AppEvent.NET_M14, AppEvent.NET_M14_C140001, data)
    else
        self:sendNotification(AppEvent.PROXY_GET_CHATPERSON_INFO,self._playIdMap[data.playerId])
    end
end

function ArenaProxy:onSetPlayId(playId,data)
    self._playIdMap[playId] = data
end

--------------------------竞技场战报-----------------------
function ArenaProxy:onTriggerNet200100Req(data)
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200100, {})
end

function ArenaProxy:onTriggerNet200100Resp(data)
    -- self._allMailsList = data.allInfos
    self._perMailsList = data.perInfos
    local lenght = table.size(self._perMailsList)
    if lenght > 20 then
        while table.size(self._perMailsList) > 20 do 
            table.remove(self._perMailsList, #self._perMailsList)
        end
    end
    
    local info = {}
    info.allInfos = data.allInfos
    self:onTriggerNet200105Resp(info)
    self._mailDetailInfoMap = {}

    table.sort( self._allMailsList, function (a,b) return a.time > b.time end)
    table.sort( self._perMailsList, function (a,b) return a.time > b.time end)
end

function ArenaProxy:onTriggerNet200101Req(data)  --阅读邮件
    if self._mailDetailInfoMap[data.id] == nil then  --未读的邮件
        self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200101, data)
    else
        self:sendNotification(AppEvent.PROXY_ARENA_READMAIL,self._mailDetailInfoMap[data.id])
    end
end

function ArenaProxy:onTriggerNet200101Resp(data)
    if data.rs == 0 then
        self._mailDetailInfoMap[data.infos.id] = data.infos
        self:sendNotification(AppEvent.PROXY_ARENA_READMAIL,data.infos)
    end
end

function ArenaProxy:onSetMailIsRead(type,id)
    if type == 3 then --全服
        for _,v in pairs(self._allMailsList) do
            if v.id == id then
                if v.isRead == 2 then
                    v.isRead = 1 --已读
                    return true
                end
            end
        end
    else
        for _,v in pairs(self._perMailsList) do
            if v.id == id then
                if v.isRead == 2 then
                    v.isRead = 1 --已读
                    return true
                end
            end
        end
    end
end

function ArenaProxy:onTriggerNet200102Req(data)  --删除邮件
    if data.isAll == true then  --全部删除
        self._isDleteAll = true
        local cloneMap = clone(data.id)
        data = {}
        data.id = cloneMap
    end
    for _,v in pairs(data.id) do
        self._perDeleteIdList[v] = v
    end
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200102, data)
end

function ArenaProxy:onTriggerNet200102Resp(data)  --个人邮件才能删除
    if data.rs == 0 then
        for _,v in pairs(self._perDeleteIdList) do
            self._mailDetailInfoMap[v] = nil
        end

        if self._isDleteAll == true then
            self._perMailsList = {}
        else
            for f,fv in pairs(self._perDeleteIdList) do
                for c,cv in pairs(self._perMailsList) do
                    if fv == cv.id then
                        cv.type = "delete"
                        break
                    end
                end
            end
            local cloneList = {}
            local index = 1
            for k,v in pairs(self._perMailsList) do
                if v.type ~= "delete" then
                    cloneList[index] = v
                    index = index + 1
                end
            end
            self._perMailsList = cloneList
        end

        self:sendNotification(AppEvent.PROXY_ARENA_PERMAILS_UPDATE,{})
        self._perDeleteIdList = {}
        self._isDleteAll = nil
    end
end

function ArenaProxy:onTriggerNet200104Req() 
    --self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200102, {})
end

function ArenaProxy:onTriggerNet200104Resp(data) --个人战报的更新  每次竞技场战斗之后推送(优化)
    table.insert(self._perMailsList, 1, data.perInfos)
    local lenght = table.size(self._perMailsList)
    if lenght > 20 then
        while table.size(self._perMailsList) > 20 do 
            table.remove(self._perMailsList, #self._perMailsList)
        end
    end
end

function ArenaProxy:onTriggerNet200105Req(data) --每次打开模块请求一次
    self:syncNetReq(AppEvent.NET_M20, AppEvent.NET_M20_C200105, {})
end

function ArenaProxy:onTriggerNet200105Resp(data)
    local index = table.size(data.allInfos)
    if index == 0 then
        return
    end
    table.sort( data.allInfos, function (a,b) return a.time > b.time end)
    if index > 20 then
        self._allMailsList = data.allInfos
    else
        for i=1,#data.allInfos do
            table.insert(self._allMailsList, 1, data.allInfos[i])
        end
    end
    local lenght = table.size(self._allMailsList)
    if lenght > 20 then
        while table.size(self._allMailsList) > 20 do 
            table.remove(self._allMailsList, #self._allMailsList)
        end
    end
end

function ArenaProxy:onTriggerNet160005Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
end

function ArenaProxy:onGetAllMailsMap()
    return self._allMailsList
end

function ArenaProxy:onGetPerMailsMap()
    return self._perMailsList
end


------
-- 返回挑战次数
function ArenaProxy:getChallengeTimes()
    local times = self._allArenaInfos.challengetimes
    return times
end

------
-- 返回是否有奖励领取状态
function ArenaProxy:getRewardState()
    local lastReward = self._allArenaInfos.lastReward
    return lastReward
end

------
-- 判断挑战次数和奖励，有的话返回true
function ArenaProxy:havaTimesOrReward()
    -- 等级不够 列表为空
    if self._allArenaInfos == nil then
        return false
    end
    -- 等级够了，没有设置阵型
    if self:onSetSoliders() == false then   --只有设置了竞技场阵型才会发
        return false
    end

    -- 等级够且设置好了阵型
    local state = nil 
    if self:getChallengeTimes() ~= 0 then
        state = true
    else
        if self:getRewardState() == 1 then -- 等于1时表示可领取
            state = true
        else
            state = false
        end
    end
    return state
end
