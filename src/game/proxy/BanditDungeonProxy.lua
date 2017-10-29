-- /**
--  * @Author:	  woko
--  * @DateTime:	2016-08-23 21:15:46
--  * @Description: 剿匪副本数据代理
--  */

BanditDungeonProxy = class("BanditDungeonProxy", BasicProxy)

function BanditDungeonProxy:ctor()
    BanditDungeonProxy.super.ctor(self)
    self.proxyName = GameProxys.BanditDungeon

    self._banditDungeonMap = {}

    self.isAllKill = false
end

function BanditDungeonProxy:resetAttr()
    self._banditDungeonMap = {}
end


--初始化剿匪副本数据
function BanditDungeonProxy:initSyncData(data)
    BanditDungeonProxy.super.initSyncData(self, data)
    local banditDungeonInfos = data.banditDungeonInfos

    for _, banditDungeonInfo in pairs(banditDungeonInfos) do
        local key = self:getBanditDungeonKey(banditDungeonInfo.x, banditDungeonInfo.y)
        self:updateBanditDungeon(banditDungeonInfo)
    end
    
end


--获取剿匪副本信息,通过世界坐标
function BanditDungeonProxy:getBanditDungeon(x, y)
    local key = self:getBanditDungeonKey(x, y)
    if self._banditDungeonMap[key] and self._banditDungeonMap[key].eventId <= 0 then
        return nil 
    end
    return self._banditDungeonMap[key]
end

--更新剿匪副本
function BanditDungeonProxy:updateBanditDungeon(banditDungeonInfo)

    ---先把旧的删除掉
    local oldKey = ""
    for _, bandit in pairs(self._banditDungeonMap) do
        if bandit.id == banditDungeonInfo.id then
            oldKey = self:getBanditDungeonKey(bandit.x, bandit.y)
            break
        end
    end
    self._banditDungeonMap[oldKey] = nil
    

    local key = self:getBanditDungeonKey(banditDungeonInfo.x, banditDungeonInfo.y)
    self._banditDungeonMap[key] = banditDungeonInfo

    local remainRestTime = banditDungeonInfo.remainRestTime
    if remainRestTime >= 0 then
        self:scheduRestBandit(banditDungeonInfo.id, remainRestTime)
    end
end


function BanditDungeonProxy:getBanditDungeonKey(x, y)
    return x .. y
end

function BanditDungeonProxy:getAllBandData()
    return self._banditDungeonMap
end

--休整倒计时
function BanditDungeonProxy:scheduRestBandit(id, remainRestTime)
    local scheduKey = self:getScheduKey(id)

    self:pushRemainTime(scheduKey, remainRestTime, AppEvent.NET_M34_C340000, {id = id}, self.onTriggerNet340000Req)
end

--获取剩余的休整时间
function BanditDungeonProxy:getRemainRestTime(id)
    local scheduKey = self:getScheduKey(id)
    return self:getRemainTime(scheduKey)
end

function BanditDungeonProxy:getScheduKey(id)
    return "banditRest" .. id
end

--获取一个剿匪副本的世界坐标
--主要用来引导的时候，直接跳转过去
function BanditDungeonProxy:getOneBanditPosition()
    local bandit = nil
    for _,v in pairs(self._banditDungeonMap) do
        bandit = v
        break
    end
    return bandit.x, bandit.y
end

----------------------net-------------------------
---------------------c --> s----------------------------
-----副本数据同步，休整时间结束后，才会请求
function BanditDungeonProxy:onTriggerNet340000Req(data)
    for _, reqData in pairs(data) do
        self:syncNetReq(AppEvent.NET_M34, AppEvent.NET_M34_C340000, {id = reqData.id})
    end
end

---------------------------请求剿匪副本战斗--------------
function BanditDungeonProxy:onTriggerNet340001Req(data)
    self:syncNetReq(AppEvent.NET_M34, AppEvent.NET_M34_C340001, data)
end


------------------s --> c-----------------------------------
--剿匪副本数据统本返回
function BanditDungeonProxy:onTriggerNet340000Resp(data)
    local rs = data.rs

    if rs == 0 then
        self:updateBanditDungeon(data.banditInfo)
    elseif rs == ErrorCodeDefine.M340000_2 then
        self:scheduRestBandit(data.id, data.remainRestTime)
    else
        self:scheduRestBandit(data.id, 0)    
    end

    self:sendNotification(AppEvent.PROXY_BANDIT_DUNGEON_UPDATE, {})
end

--剿匪副本战斗返回
function BanditDungeonProxy:onTriggerNet340001Resp(data)
    local rs = data.rs
    if rs == 0 then
        --isAllKill 0表示未杀死所有黄巾军  1表示杀死
        --print("data.isAllKill data.isAllKill",data.isAllKill)
        self:updateBanditDungeon(data.banditInfo)

        if data.isAllKill == 0 then
            self:setIsAllKill(false)
        else
            self:setIsAllKill(true)
            local openData = {}
            openData.moduleName = ModuleName.TellTheWorldModule
            openData.extraMsg = {eventId = 1,winnerInfo = nil,loserInfo = nil}
            self:sendAppEvent(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, openData)
        end 
        
        if self:getIsAllKill() then
            self._banditDungeonMap = {}
        end 
        
        self:sendNotification(AppEvent.PROXY_BANDIT_DUNGEON_UPDATE, "battle") 
    end
end

--是否击杀所有黄巾军
function BanditDungeonProxy:getIsAllKill()
    return self.isAllKill
end

function BanditDungeonProxy:setIsAllKill(bool)
    self.isAllKill = bool
end 

--更新所有的剿匪副本，当新号的时候，需要这样子处理
--由世界坐标点生成触发
function BanditDungeonProxy:onTriggerNet340002Resp(data)
    for _, banditDungeonInfo in pairs(data.infos) do
        local key = self:getBanditDungeonKey(banditDungeonInfo.x, banditDungeonInfo.y)
        self:updateBanditDungeon(banditDungeonInfo)
    end

    self:sendNotification(AppEvent.PROXY_BANDIT_DUNGEON_UPDATE, {})
end

----------------------------

--endregion
