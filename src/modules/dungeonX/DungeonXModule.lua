-- /**
--  * @Author:      fzw
--  * @DateTime:    2016-04-18 17:39:35
--  * @Description: 副本地图-水平方向滚动
--  */

DungeonXModule = class("DungeonXModule", BasicModule)

function DungeonXModule:ctor()
    DungeonXModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.Animation
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function DungeonXModule:initRequire()
    require("modules.dungeonX.event.DungeonXEvent")
    require("modules.dungeonX.view.DungeonXView")
end

function DungeonXModule:finalize()
    DungeonXModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function DungeonXModule:initModule()
    DungeonXModule.super.initModule(self)
    self._view = DungeonXView.new(self.parent)

    self:addEventHandler()
end

function DungeonXModule:closeall()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LegionCombatCenterModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LegionSceneModule})
end

function DungeonXModule:addEventHandler()
    self._view:addEventListener(DungeonXEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(DungeonXEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(DungeonXEvent.OPEN_TEAMMODULE, self, self.onOpenTeamModule) --暂时
    self._view:addEventListener(DungeonXEvent.ASKCHALLENGE_REQ, self, self.onAskChallengeReq) --挑战关卡询问
    self._view:addEventListener(DungeonXEvent.CLOSE_ALL_EVENT, self, self.closeall)

    self:addProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_BOX_UPDATE, self, self.onGetBoxUpdate)
    self:addProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_EVENT_UPDATE, self, self.onEventsUpdate)
    self:addProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_EVENT_ANSWER, self, self.onAskChallengeResp) --挑战关卡询问返回
    -- self:addEventListener(AppEvent.NET_M27, AppEvent.NET_M27_C270002, self, self.onAskChallengeResp)        --挑战关卡询问返回


end

function DungeonXModule:removeEventHander()
    self._view:removeEventListener(DungeonXEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(DungeonXEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(DungeonXEvent.OPEN_TEAMMODULE, self, self.onOpenTeamModule) --暂时
    self._view:removeEventListener(DungeonXEvent.ASKCHALLENGE_REQ, self, self.onAskChallengeReq) --挑战关卡询问
    
    self:removeProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_BOX_UPDATE, self, self.onGetBoxUpdate)
    self:removeProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_EVENT_UPDATE, self, self.onEventsUpdate)
    self:removeProxyEventListener(GameProxys.DungeonX, AppEvent.PROXY_DUNGEONX_EVENT_ANSWER, self, self.onAskChallengeResp) --挑战关卡询问返回
    -- self:removeEventListener(AppEvent.NET_M27, AppEvent.NET_M27_C270002, self, self.onAskChallengeResp)        --挑战关卡询问返回
end

function DungeonXModule:onHideSelfHandler()
    -- local proxy = self:getProxy(GameProxys.DungeonX)
    -- proxy:updateAskFlag(false)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function DungeonXModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
    self:onHideSelfHandler()
end

function DungeonXModule:onOpenModule(extraMsg)
    DungeonXModule.super.onOpenModule(self)
    logger:info("------DungeonXModule---------onOpenModule----------0")
    self._view:onUpdateMap()
    -- logger:info("------DungeonXModule---------onOpenModule----------1")
    

    local proxy = self:getProxy(GameProxys.DungeonX)
    local curChapterId = proxy:getCurChapterID()
    -- local data = proxy:getOneChapterEventsInfoByID(curChapterId)
    -- local allMapData = proxy:getAllDungeonData()
    -- self._view:onDungeonInfoResp(data,curChapterId,allMapData)
    self._curChapterId = curChapterId
    -- logger:info("------DungeonXModule---------onOpenModule----------2")

    -- 请求据点信息
    -- proxy:onTriggerNet270004Req({id = self._curChapterId})
end

-- 领取宝箱返回
function DungeonXModule:onGetBoxUpdate(data)
    -- body
    self._view:onGetBoxUpdate(data)
end

-- 据点信息更新
function DungeonXModule:onEventsUpdate()
    -- body
    -- if self:isVisible() ~= true then
    --     logger:info("模块没打开...-- 据点信息不用更新....")
    --     return
    -- end

    local proxy = self:getProxy(GameProxys.DungeonX)
    local curChapterId = proxy:getCurChapterID()
    local data = proxy:getOneChapterEventsInfoByID(curChapterId)
    local allMapData = proxy:getAllDungeonData()
    self._curChapterId = curChapterId
    self._view:onDungeonInfoResp(data,curChapterId,allMapData)
    -- logger:info("据点信息更新 DungeonXModule:onEventsUpdate()")
    -- self._view:onEventsUpdate()
end


-- 挑战关卡询问
function DungeonXModule:onAskChallengeReq(sender)
    -- body
    if sender ~= nil then
        -- print("DungeonXModule:onAskChallengeReq(data) id=",sender.data.id)
        self._sender = sender
        -- self:sendServerMessage(AppEvent.NET_M27, AppEvent.NET_M27_C270002, {id = sender.data.id})
        local proxy = self:getProxy(GameProxys.DungeonX)
        proxy:onTriggerNet270002Req({id = sender.data.id})
    end
end

-- 挑战关卡询问返回
function DungeonXModule:onAskChallengeResp(data)
    -- body
    -- print("DungeonXModule:onAskChallengeResp(data) id=",datFa)
    if self._sender ~= nil then
        self:onOpenTeamModule(self._sender)
        -- self._view:hideCityPanle()
    end
end

-- 点击挑战按钮
function DungeonXModule:onOpenTeamModule(sender)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.TeamModule})

    -- print("点击挑战按钮···sender.data.id, battleType, self._curChapterId",sender.data.id,GameConfig.battleType.legion, self._curChapterId)

    local proxy = self:getProxy(GameProxys.Dungeon)
    proxy:setCurrCityType(sender.data.id) --关卡id
    -- proxy:setCurrType(GameConfig.battleType.legion, self._curChapterId)  --type：1：征战界面 2：探险界面 6：军团副本。id:章节id
    proxy:setCurrType(self._curChapterId, GameConfig.battleType.legion)  --id=章节id。type=1：征战界面 2：探险界面 6：军团副本

    local data = {}
    data["moduleName"] = ModuleName.TeamModule
    data["extraMsg"] = "fight"  --战斗

    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end


