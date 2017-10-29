
DungeonModule = class("DungeonModule", BasicModule)
function DungeonModule:ctor()
    DungeonModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self._view = nil
    self._loginData = nil
    self._type = 1 --类型，1是征战，2是探险
    
    self.showActionType = ModuleShowType.Animation
    self._serverDataMap = {}
    self:initRequire()
end

function DungeonModule:initRequire()
    require("modules.dungeon.event.DungeonEvent")
    require("modules.dungeon.view.DungeonView")
    LocalDBManager:setValueForKey(GameConfig.isAutoBattle, "no")
end

function DungeonModule:finalize()
    DungeonModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function DungeonModule:initModule()
    DungeonModule.super.initModule(self)
    self._view = DungeonView.new(self.parent)

    self:addEventHandler()
end

function DungeonModule:closeall()
    -- print("111-------------------------------------------------")
    -- self:onHideSelfHandler()
    -- self:onHideModule()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName ="RegionModule"})
    -- -- GameBaseState:closeModule({moduleName ="RegionModule"})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
    -- ModuleJumpManager:jump()
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {"RegionModule"})
-- GameBaseState:closeModuleToMain("RegionModule",self.name)
end

function DungeonModule:addEventHandler()
    self._view:addEventListener(DungeonEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(DungeonEvent.CLOSE_ALL_EVENT, self, self.closeall)
    self._view:addEventListener(DungeonEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60001, self, self.ondungeonInfoResp)
    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_INFOS, self, self.ondungeonInfoResp)
    
    self._view:addEventListener(DungeonEvent.OPEN_TEAMMODULE, self, self.onOpenTeamModule) --暂时
    --self:addEventListener(AppEvent.NET_M5, AppEvent.NET_M5_C50001, self, self.onFightOverResp)
    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_FIGHT_OVER, self, self.onFightOverResp)

    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_COLSE_EVENT, self, self.onCloseEvent)

    --self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60003, self, self.onGetBoxRewardResp)
    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_BOXREWARD, self, self.onGetBoxRewardResp)
    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_RESET_DATA, self, self.onResetData)

    self:addProxyEventListener(GameProxys.TeamDetail, AppEvent.PROXY_TILI_UPDATE, self, self.onUpdateTili)

    --self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60004, self, self.onBuyTimesResp)
    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_BUY_TIMES, self, self.onBuyTimesResp)

    self._view:addEventListener(DungeonEvent.GET_REWARD_REQ, self, self.onGetBoxRewardReq)


    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_REWARD_RESP, self, self.onGetRewadInfo)

    self._view:addEventListener(DungeonEvent.BUYTIMES_REQ, self, self.onBuyTimesReq)

    self._view:addEventListener(DungeonEvent.NEW_GOFIGHT, self, self.onNewGoFightReq)

    --self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60104, self, self.onFirstPassResp)
    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_FIRST_PASS, self, self.onFirstPassResp)

    self._view:addEventListener(DungeonEvent.BUY_ENERGY, self, self.onSendCanBuyEnergy)

    -- self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20013, self, self.onCanBuyEnergyResp)
    -- self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20011, self, self.onBuyEnergyResp)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    --self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetNewGift)
    self:addProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_NEWGIFT, self, self.onGetNewGift)
end

function DungeonModule:removeEventHander()
    self._view:removeEventListener(DungeonEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(DungeonEvent.CLOSE_ALL_EVENT, self, self.closeall)
    self._view:removeEventListener(DungeonEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60001, self, self.ondungeonInfoResp)
    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_INFOS, self, self.ondungeonInfoResp)
    
    self._view:removeEventListener(DungeonEvent.OPEN_TEAMMODULE, self, self.onOpenTeamModule) --暂时
    --self:removeEventListener(AppEvent.NET_M5, AppEvent.NET_M5_C50001, self, self.onFightOverResp)
    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_FIGHT_OVER, self, self.onFightOverResp)

    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_COLSE_EVENT, self, self.onCloseEvent)

    --self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60003, self, self.onGetBoxRewardResp)
    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_BOXREWARD, self, self.onGetBoxRewardResp)
    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_RESET_DATA, self, self.onResetData)

    self:removeProxyEventListener(GameProxys.TeamDetail, AppEvent.PROXY_TILI_UPDATE, self, self.onUpdateTili)

    --self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60004, self, self.onBuyTimesResp)
    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_BUY_TIMES, self, self.onBuyTimesResp)

    self._view:removeEventListener(DungeonEvent.GET_REWARD_REQ, self, self.onGetBoxRewardReq)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_REWARD_RESP, self, self.onGetRewadInfo)
    self._view:removeEventListener(DungeonEvent.BUYTIMES_REQ, self, self.onBuyTimesReq)

    self._view:removeEventListener(DungeonEvent.NEW_GOFIGHT, self, self.onNewGoFightReq)
    --self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60104, self, self.onFirstPassResp)
    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_FIRST_PASS, self, self.onFirstPassResp)

    self._view:removeEventListener(DungeonEvent.BUY_ENERGY, self, self.onSendCanBuyEnergy)

    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20013, self, self.onCanBuyEnergyResp)

    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20011, self, self.onBuyEnergyResp)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)


    --self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetNewGift)
    self:removeProxyEventListener(GameProxys.Dungeon, AppEvent.PROXY_DUNGEON_GET_NEWGIFT, self, self.onGetNewGift)
end

function DungeonModule:onHideSelfHandler()
    self._info = nil
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function DungeonModule:onShowOtherHandler(moduleName)
    self:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function DungeonModule:onUpdateTili(count)
    self._view:onUpdateTili(count)
end

function DungeonModule:ondungeonInfoResp(data)
    if data.rs == 0 then
        -- local forxy = self:getProxy(GameProxys.Dungeon)
        -- self._serverDataMap[self._dungeonId] = data

        local forxy = self:getProxy(GameProxys.Dungeon)
        forxy:updateOnedungeonInfoById(self._dungeonId,data)
        self._view:onDungeonInfoResp(data,self._type,self._info)
    end
end

function DungeonModule:onOpenTeamModule(sender)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.TeamModule})
    local proxy = self:getProxy(GameProxys.Dungeon)
    proxy:setCurrCityType(sender.data.id)
    local data = {}
    data["moduleName"] = ModuleName.TeamModule
    if sender.type == 1 then
        data["extraMsg"] = "fight"  --战斗
    elseif sender.type == 2 then 
        data["extraMsg"] = "sleep"  --挂机
    end
    --local forxy = self:getProxy(GameProxys.Dungeon)
    local type,id = proxy:getCurrType()
    if type == 2 then  --历练
        proxy:setExploreStatus(true)  --历练需要使用体力消耗
    end
    --self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_1)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function DungeonModule:onOpenModule(extraMsg)
    DungeonModule.super.onOpenModule(self)
    local forxy = self:getProxy(GameProxys.Dungeon)
    local _type,id = forxy:getCurrType()

    local soldierProxy = self:getProxy(GameProxys.Soldier)
    soldierProxy:setMaxFighAndWeight()
    self._type = _type
    self._dungeonId = id
    self._view:onBuyTimes(_type,forxy:getExploreIndex())
    --self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60001, {id = id})

    

    local isUpdateBgImg = false
    if extraMsg == nil then
    else
        if type(extraMsg) == type({}) and extraMsg.info ~= nil then
            self._info = extraMsg.info
            --这里要确保有信息过来
            isUpdateBgImg = true
            self._view:updateBgImg(extraMsg.info.bgicon)
        end
    end
    if not isUpdateBgImg then
        local info = nil
        if _type == 1 then
            info = ConfigDataManager:getConfigById(ConfigData.ChapterConfig, id)
        else
            info = ConfigDataManager:getConfigById(ConfigData.AdventureConfig, id)
        end
        self._view:updateBgImg(info.bgicon)
    end

    
    local onedungeonInfo = forxy:getDungeonById(self._dungeonId)
    if onedungeonInfo == nil then
        --self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60001, {id = id})
        forxy:onTriggerNet60001Req({id = id})
    else
        self._view:onDungeonInfoResp(onedungeonInfo,self._type,self._info)
    end

    -- if self._serverDataMap[self._dungeonId] == nil then
    --     self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60001, {id = id})
    -- else
    --     self._view:ondungeonInfoResp(self._serverDataMap[self._dungeonId],self._type,self._info)
    -- end
    AudioManager:playDungeonMusic()
end

function DungeonModule:onHideModule()
    DungeonModule.super.onHideModule(self)
    
    if self:isModuleShow(ModuleName.MainSceneModule) then
        AudioManager:playSceneMusic()
    elseif self:isModuleShow(ModuleName.MainSceneModule) then
        AudioManager:playWorldMusic()
    end
    
end

function DungeonModule:onFightOverResp(data)
    self._view:hideCityPanle()
end

function DungeonModule:onGetBoxRewardResp(data)
    if data.rs == 0 then
        self._view:getBoxRewardResp(data)
        -- if self._serverDataMap[self._dungeonId] ~= nil then
        --     local _data = self._serverDataMap[self._dungeonId]
        --     _data.boxes = data.boxes
        -- end
        local forxy = self:getProxy(GameProxys.Dungeon)
        local onedungeonInfo = forxy:getDungeonById(self._dungeonId)
        onedungeonInfo.boxes = data.boxes
    end
end

function DungeonModule:onGetBoxRewardReq(data)
    --self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60003, data)
    local forxy = self:getProxy(GameProxys.Dungeon)
    forxy:onTriggerNet60003Req(data)
end

function DungeonModule:onGetRewadInfo(data)
    self:showSysMessage(data)
end

function DungeonModule:onResetData(data)
    self._view:onResetData(data)
end

function DungeonModule:onBuyTimesResp(data)
    local isShow = self:isModuleShow("TeamModule")    --防止team模块冲突    
    if isShow ~= true then
        self._view:onBuyTimesResp(data)
    end
end

function DungeonModule:onBuyTimesReq(type)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.TeamModule})
    local data = {}
    data.type = type
    data.dungeoId = self._dungeonId
    --self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60004, data)
    local forxy = self:getProxy(GameProxys.Dungeon)
    forxy:onTriggerNet60004Req(data)
end

function DungeonModule:onNewGoFightReq(data)
    local battleProxy = self:getProxy(GameProxys.Battle)
    battleProxy:startBattleReq(data)
end

function DungeonModule:onFirstPassResp(data)
    if data.rs == 0 then
        self._view:onFirstPassResp()
    end
end

function DungeonModule:onSendCanBuyEnergy(data)
    if data == DungeonEventType.CAN_BUY_ENERGY then
        -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20013, {})
    elseif data == DungeonEventType.BUY_ENERGY then
        -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20011, {})
    end
end

function DungeonModule:onCanBuyEnergyResp(data)
    -- if data.rs >= 0 then
    --     self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20011, {})
    -- end
    if data.rs == 0 then
        local price = data.price
        self._view:isShowRechargeUI(price)
    end
end


function DungeonModule:onBuyEnergyResp(data)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(541))
        -- self._view:updateData()
    end
end

function DungeonModule:onGetRoleInfo()
    self._view:updateData()
end

function DungeonModule:onGetNewGift(data)
    if data.rs == 0 then
        self._view:onGetNewGift()
    end
end

function DungeonModule:onCloseEvent()
    print("55555555565656565")
    local panel = self._view:getPanel(DungeonCityPanel.NAME)
    panel:hide()
    local panel = self._view:getPanel(DungeonMapPanel.NAME)
    panel:setCanJump(true)
    self:onHideSelfHandler()
end