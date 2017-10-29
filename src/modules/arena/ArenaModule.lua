
ArenaModule = class("ArenaModule", BasicModule)

function ArenaModule:ctor()
    ArenaModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self.isFullScreen = true
    
    self._view = nil
    self._loginData = nil
    self._level = 0
    self:initRequire()
end

function ArenaModule:initRequire()
    require("modules.arena.event.ArenaEvent")
    require("modules.arena.view.ArenaView")
end

function ArenaModule:finalize()
    ArenaModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ArenaModule:initModule()
    ArenaModule.super.initModule(self)
    self._view = ArenaView.new(self.parent)
    --local proxy = self:getProxy(GameProxys.Soldier)
    --proxy:setMapFightAddEquip()
    self:addEventHandler()
end

function ArenaModule:addEventHandler()
    self._view:addEventListener(ArenaEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ArenaEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self._view:addEventListener(ArenaEvent.OPEN_PARTS_MODULE, self, self.onOpenPartsHandler)
    self._view:addEventListener(ArenaEvent.OPEN_EQUIPMODULE, self, self.onOpenEquipModule)

    self._view:addEventListener(ArenaEvent.KEEP_TEAM_REQ, self, self.onKeepTeamHandler)

    self._view:addEventListener(ArenaEvent.GET_REWRED_REQ, self, self.onGetRewHandler)
    --self._view:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200005, self, self.onGetRewResp)
    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_GETREWARD, self, self.onGetRewResp)

    self._view:addEventListener(ArenaEvent.BUY_COUNT_REQ, self, self.onBuyCountHandler)
    --self._view:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200003, self, self.onBuyCountResp)

    self._view:addEventListener(ArenaEvent.FIGHT_REQ, self, self.onFightReqHandler)
    --self:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200001, self, self.onFightResp)

    self._view:addEventListener(ArenaEvent.BUY_COLDTIME_REQ, self, self.onBuyColdTimeHandler)
    --self:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200006, self, self.onBuyColdTimeResp)
    
    --self:addEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200000, self, self.onGetAllInfosResp)
    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_ALLINFOS, self, self.onGetAllInfosResp)

    self._view:addEventListener(ArenaEvent.OPEN_ARENASHOP, self, self.onOpenShopHandler)

    self._view:addEventListener(ArenaEvent.PERSON_INFO_REQ, self, self.onGetPersonInfoReq)

    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)

    
    self:addEventListener(AppEvent.UPDATE_RAD, AppEvent.UP_RAD_COUNT, self,self.onUpdateRed)

    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_REFRESHTIME, self, self.onRefreshNextTime)
    self:addProxyEventListener(GameProxys.Arena, AppEvent.PROXY_UPDATE_All_EQUIPS, self, self.onUpdateAllEquips)

    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)

    self._view:addEventListener(ArenaEvent.OPEN_COUNSEMODULE, self, self.onOpenCounseHandler)
end

function ArenaModule:removeEventHander()
    self._view:removeEventListener(ArenaEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ArenaEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self._view:removeEventListener(ArenaEvent.OPEN_PARTS_MODULE, self, self.onOpenPartsHandler)
    self._view:removeEventListener(ArenaEvent.OPEN_EQUIPMODULE, self, self.onOpenEquipModule)

    self._view:removeEventListener(ArenaEvent.KEEP_TEAM_REQ, self, self.onKeepTeamHandler)

    self._view:removeEventListener(ArenaEvent.GET_REWRED_REQ, self, self.onGetRewHandler)
    --self._view:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200005, self, self.onGetRewResp)
    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_GETREWARD, self, self.onGetRewResp)

    self._view:removeEventListener(ArenaEvent.BUY_COUNT_REQ, self, self.onBuyCountHandler)
    --self._view:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200003, self, self.onBuyCountResp)

    self._view:removeEventListener(ArenaEvent.FIGHT_REQ, self, self.onFightReqHandler)
    --self:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200001, self, self.onFightResp)

    self._view:removeEventListener(ArenaEvent.BUY_COLDTIME_REQ, self, self.onBuyColdTimeHandler)
    --self:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200006, self, self.onBuyColdTimeResp)

    --self:removeEventListener(AppEvent.NET_M20, AppEvent.NET_M20_C200000, self, self.onGetAllInfosResp)
    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_ALLINFOS, self, self.onGetAllInfosResp)

    self._view:removeEventListener(ArenaEvent.OPEN_ARENASHOP, self, self.onOpenShopHandler)

    self._view:removeEventListener(ArenaEvent.PERSON_INFO_REQ, self, self.onGetPersonInfoReq)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHATPERSON_INFO, self, self.onChatPersonInfoResp)

    self:removeEventListener(AppEvent.UPDATE_RAD, AppEvent.UP_RAD_COUNT, self,self.onUpdateRed)

    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_ARENA_REFRESHTIME, self, self.onRefreshNextTime)
    self:removeProxyEventListener(GameProxys.Arena, AppEvent.PROXY_UPDATE_All_EQUIPS, self, self.onUpdateAllEquips)

    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)

    self._view:removeEventListener(ArenaEvent.OPEN_COUNSEMODULE, self, self.onOpenCounseHandler)
end

function ArenaModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ArenaModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ArenaModule:onUpdateRed()
    self._view:onUpdateRed()
end

function ArenaModule:onOpenModule(extraMsg)
    ArenaModule.super.onOpenModule(self)
    
    local proxy = self:getProxy(GameProxys.Soldier)
    proxy:setMaxFighAndWeight()
    
    local proxy = self:getProxy(GameProxys.Arena)
    --if self:onSetSoliders() == true then  --判断是否有设置了阵型
    if proxy:onGetIsSquire() == true then
        proxy:onTriggerNet200000Req({})
        self._view:setOpenModule(true)
        -- self:onGetAllInfosResp(proxy:getAllInfos())
        -- self:onRefreshNextTime()
        --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200000, {})
    else
        self._view:setOpenModule(false,true)
    end
    --(extraMsg ~= nil and extraMsg.panelName == "ArenaPanel")
    self:onGetRoleInfo()
    self._view:onUpdateAllEquips()
end

-- function ArenaModule:onSetSoliders()
--     local forxy = self:getProxy(GameProxys.Dungeon)
--     local data = forxy:onGetTeamInfo()
--     data = data[3].members
--     for _,v in pairs(data) do
--         if v.num ~= 0 then
--             return true
--         end
--     end
--     return false
-- end

function ArenaModule:onGetAllInfosResp(data)
    if data.rs == 0 then
        self._view:setOpenModule(true)
        self._view:onGetAllInfosResp(data)
    end
end

function ArenaModule:onGetRoleInfo()
    local proxy = self:getProxy(GameProxys.Role)
    local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级
    if self._level ~= level then
        self._level = level
        self._view:updateLevel(level)  --指挥官等级的改变，导致开放的坑位数目发生改变
    end
    self._view:updateMaxFightSoldierCount()  --每个槽位的出战佣兵上线的改变
end

function ArenaModule:onOpenEquipModule()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.EquipModule})
end

function ArenaModule:onOpenPartsHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.PartsModule})
end

function ArenaModule:onKeepTeamHandler(data) --阵型的保存
    --self:sendServerMessage(AppEvent.NET_M7, AppEvent.NET_M7_C70001, data)
    local proxy = self:getProxy(GameProxys.Soldier)
    proxy:onTriggerNet70001Req(data)
end

function ArenaModule:onGetRewHandler()
    --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200005, {})
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet200005Req({})
end

function ArenaModule:onGetRewResp(data)
    -- if data.rs == 0 then
    self._view:onGetRewResp()
    -- end
end

function ArenaModule:onBuyCountHandler()
    --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200003, {})
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet200003Req({})
end

-- function ArenaModule:onBuyCountResp(data)
--     if data.rs == 0 then
--         self._view:onBuyCountResp(data)
--         self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200000, {})
--     end
-- end

function ArenaModule:onFightReqHandler(data)
    --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200001, data)
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet200001Req(data)
end

function ArenaModule:onBuyColdTimeHandler()
    --self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200006, {})
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet200006Req({})
end

function ArenaModule:onFightResp(data)
    if data.rs == 0 then
        local battleProxy = self:getProxy(GameProxys.Battle)
        battleProxy:startBattleReq({type = 3})
--        self:sendServerMessage(AppEvent.NET_M5, AppEvent.NET_M5_C50000, {type = 3})
    end
end

-- function ArenaModule:onBuyColdTimeResp(data)
--     if data.rs == 0 then
--         self:sendServerMessage(AppEvent.NET_M20, AppEvent.NET_M20_C200000, {})
--     end
-- end

function ArenaModule:onOpenShopHandler()
    local data = {}
    data.moduleName = ModuleName.ArenaShopModule
    data.srcModule = self.name
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function ArenaModule:onGetPersonInfoReq(data)
    --self:sendServerMessage(AppEvent.NET_M14, AppEvent.NET_M14_C140001, data)
    self._currplayId = data.playerId
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet140001Req(data)
end

function ArenaModule:onChatPersonInfoResp(data)
    if data.rs == 0 then
        local proxy = self:getProxy(GameProxys.Arena)
        proxy:onSetPlayId(self._currplayId,data)
        self._view:onChatPersonInfoResp(data)
    end
end

function ArenaModule:onGetAllArenaInfos()
    local proxy = self:getProxy(GameProxys.Arena)
    proxy:onTriggerNet200000Req()
end

function ArenaModule:onRefreshNextTime()
    local proxy = self:getProxy(GameProxys.Arena)
    local time = proxy:getRemainTime("ArenaProxy_nextRefreshTime")
    if time <= 0 then
        self:onGetAllArenaInfos()
    else
        if time <= 3600 * 3 then
            TimerManager:addOnce(time * 1000, self.onGetAllArenaInfos, self)
        end
    end
end

function ArenaModule:onHideModule()
    TimerManager:remove(self.onGetAllArenaInfos, self)
end

function ArenaModule:onUpdateAllEquips()
    self._view:onUpdateAllEquips()
end

function ArenaModule:onConsuGoReq(data)
    self._view:onConsuGoReq(data)
end

function ArenaModule:onOpenCounseHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end