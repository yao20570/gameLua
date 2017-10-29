
TeamModule = class("TeamModule", BasicModule)

function TeamModule:ctor()
    TeamModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    self._sendServerData = {}
    self._isFirstOpen = true
    self._level = 0
    self:initRequire()
end

function TeamModule:initRequire()
    require("modules.team.event.TeamEvent")
    require("modules.team.view.TeamView")
end

function TeamModule:finalize()
    TeamModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
    self._soliderAttr = nil
end

function TeamModule:initModule()
    TeamModule.super.initModule(self)
    self._view = TeamView.new(self.parent)
    self._soldierProxy = self:getProxy(GameProxys.Soldier)
    self:addEventHandler()
    -- local proxy = self:getProxy(GameProxys.Soldier)
    -- proxy:setMapFightAddEquip()
end

function TeamModule:addEventHandler()
    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_TEAM_OTHER_INFO, self, self.updateAllEquips)
    self._view:addEventListener(TeamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(TeamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:addProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_INFO, self, self.onGetSoliderList)
    self:addProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_MOFIDY, self, self.onGetSoliderList)
    self:addProxyEventListener(GameProxys.Soldier, AppEvent.BAD_SOLDIER_LIST_UPDATE, self, self.badSoldierListUpdate)
    
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)
    
    self._view:addEventListener(TeamEvent.GOFIGHT_REQ, self, self.onGoFightHandler)
    self._view:addEventListener(TeamEvent.KEEP_TEAM_REQ, self, self.onKeepTeamHandler)
    self._view:addEventListener(TeamEvent.REPAIRELIST_REQ, self, self.onRepaireListReq)
    self._view:addEventListener(TeamEvent.REPAIRE_REQ, self, self.onRepaireReq)
    self._view:addEventListener(TeamEvent.OPEN_EQUIPMODULE, self, self.onOpenEquipModule)
    self:addEventListener(AppEvent.NET_M4,AppEvent.NET_M4_C40002, self, self.onAllRepaireListResp)
--    self:addEventListener(AppEvent.NET_M6,AppEvent.NET_M6_C60002, self, self.onBeforeFightResp)
    self._view:addEventListener(TeamEvent.OPEN_PARTS_MODULE, self, self.onOpenPartsHandler)
    self._view:addEventListener(TeamEvent.SLEEP_REQ, self, self.onSleepReqHandler)
    self:addEventListener(AppEvent.NET_M6,AppEvent.NET_M6_C60005, self, self.onSleepRespHandle)

    self:addEventListener(AppEvent.NET_M4,AppEvent.NET_M4_C40001, self, self.onListenCountResp)
    self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20200, self, self.onTipsUpdateHandle)

    -- self:addEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80003, self, self.onGetAllWorkResp)
    --self:addEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80004, self, self.onAddSpeedResp)
    self:addProxyEventListener(GameProxys.Soldier, AppEvent.TASK_TEAM_INFO_UPDATE, self, self.onGetAllWorkResp)
    self:addEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80001, self, self.onAttackPosResp)

    self._view:addEventListener(TeamEvent.GET_ALLWORK_REQ, self, self.onGetWorkReqHandler)
    self._view:addEventListener(TeamEvent.ADDSPEED_REQ, self, self.onAddSpeedReqHandler)
    self._view:addEventListener(TeamEvent.BUY_ENERGY_REQ, self, self.buyEnergtReq)
    self._view:addEventListener(TeamEvent.BUYTIMES_REQ, self, self.buyChallengeTimes)
    -- self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20013, self, self.buyEnergtResp)
    self:addEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60004, self, self.onBuyTimesResp)

    self:addEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20011, self, self.updaeEnergyNeedMoney)  --只给挂机界面准备的

    self:addEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80012, self, self.onGetRunTimeResp)
    self:addEventListener(AppEvent.NET_M27, AppEvent.NET_M27_C270001, self, self.onBeforeFightResp)

    self:addProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)

    self._view:addEventListener(TeamEvent.OPEN_COUNSEMODULE, self, self.onOpenCounseHandler)
end

function TeamModule:removeEventHander()
    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_TEAM_OTHER_INFO, self, self.updateAllEquips)
    self._view:removeEventListener(TeamEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(TeamEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_INFO, self, self.onGetSoliderList)
    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_SOLIDER_MOFIDY, self, self.onGetSoliderList)
    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.BAD_SOLDIER_LIST_UPDATE, self, self.badSoldierListUpdate)    
    
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self._view:removeEventListener(TeamEvent.GOFIGHT_REQ, self, self.onGoFightHandler)
    self._view:removeEventListener(TeamEvent.KEEP_TEAM_REQ, self, self.onKeepTeamHandler)
    self._view:removeEventListener(TeamEvent.REPAIRELIST_REQ, self, self.onRepaireListReq)
    self._view:removeEventListener(TeamEvent.REPAIRE_REQ, self, self.onRepaireReq)
    self._view:removeEventListener(TeamEvent.OPEN_EQUIPMODULE, self, self.onOpenEquipModule)
    self:removeEventListener(AppEvent.NET_M4,AppEvent.NET_M4_C40002, self, self.onAllRepaireListResp)
--    self:removeEventListener(AppEvent.NET_M6,AppEvent.NET_M6_C60002, self, self.onBeforeFightResp)
    self._view:removeEventListener(TeamEvent.OPEN_PARTS_MODULE, self, self.onOpenPartsHandler)
    self._view:removeEventListener(TeamEvent.SLEEP_REQ, self, self.onSleepReqHandler)
    self:removeEventListener(AppEvent.NET_M6,AppEvent.NET_M6_C60005, self, self.onSleepRespHandle)

    self:removeEventListener(AppEvent.NET_M4,AppEvent.NET_M4_C40001, self, self.onListenCountResp)
    self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20200, self, self.onTipsUpdateHandle)

    -- self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80003, self, self.onGetAllWorkResp)
    --self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80004, self, self.onAddSpeedResp)
    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.TASK_TEAM_INFO_UPDATE, self, self.onGetAllWorkResp)
    self:removeEventListener(AppEvent.NET_M8,AppEvent.NET_M8_C80001, self, self.onAttackPosResp)

    self._view:removeEventListener(TeamEvent.GET_ALLWORK_REQ, self, self.onGetWorkReqHandler)
    self._view:removeEventListener(TeamEvent.ADDSPEED_REQ, self, self.onAddSpeedReqHandler)
    self._view:removeEventListener(TeamEvent.BUY_ENERGY_REQ, self, self.buyEnergtReq)
    self._view:removeEventListener(TeamEvent.BUYTIMES_REQ, self, self.buyChallengeTimes)
    -- self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20013, self, self.buyEnergtResp)
    self:removeEventListener(AppEvent.NET_M6, AppEvent.NET_M6_C60004, self, self.onBuyTimesResp)

    self:removeEventListener(AppEvent.NET_M2,AppEvent.NET_M2_C20011, self, self.updaeEnergyNeedMoney)

    self:removeEventListener(AppEvent.NET_M8, AppEvent.NET_M8_C80012, self, self.onGetRunTimeResp)
    self:removeEventListener(AppEvent.NET_M27, AppEvent.NET_M27_C270001, self, self.onBeforeFightResp)

    self:removeProxyEventListener(GameProxys.Consigliere, AppEvent.PROXY_CONSUGOREQ, self, self.onConsuGoReq)

    self._view:removeEventListener(TeamEvent.OPEN_COUNSEMODULE, self, self.onOpenCounseHandler)
end

function TeamModule:onHideSelfHandler()
    local mailProxy = self:getProxy(GameProxys.Mail)
    local isHaveMail = mailProxy:getCurrentState()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
    if isHaveMail then
        local moduleName = ModuleName.MailModule
        self:onShowOtherHandler(moduleName)
    end
end

function TeamModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName,srcModule = self.name})
end

function TeamModule:onOpenModule(extraMsg)
    TeamModule.super.onOpenModule(self)
    
    local proxy = self:getProxy(GameProxys.Soldier)
    proxy:setMaxFighAndWeight()
    
    local forxy = self:getProxy(GameProxys.Dungeon)
    local data
    local showType = 2 
    local isShowOtherCity, otherCityStr, isNeedBody, subBattleType, isPlayerRes
    self._worldAttackData = nil
    self._soldierProxy:setWorldAttackData(self._worldAttackData)
    if extraMsg == "fight" or extraMsg == "sleep" or extraMsg == "limitExp" then  --从关卡界面跳转过来
        showType = 8   --副本
        self.showActionType = ModuleShowType.NONE
        data = nil
        if extraMsg == "sleep" then  --挂机
            showType = 5 
        end
        if forxy:getExploreStatus() == true then
            forxy:setExploreStatus(nil)    --从历练跳转过来
            isNeedBody = true  --消耗体力
        end
        if extraMsg == "limitExp" then
            isNeedBody = true
        end
    elseif extraMsg ~= nil and extraMsg.type == "world" then --从世界界面跳转过来的
        self.showActionType = ModuleShowType.NONE
        data = nil
        isShowOtherCity = true
        subBattleType = extraMsg.subBattleType
        showType = 0
        otherCityStr = extraMsg.otherCityStr
        isPlayerRes = rawget(extraMsg, "isPlayerRes")
        self._worldAttackData = extraMsg
        self._soldierProxy:setWorldAttackData(self._worldAttackData)
        self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80012, {x = extraMsg.tileX,y = extraMsg.tileY})
    elseif extraMsg ~= nil and extraMsg.type == "rebels" then --从世界界面的叛军界面跳转过来
        self.showActionType = ModuleShowType.NONE
        showType = 14
    elseif extraMsg == "workTarget" then
        showType = 1
        self.showActionType = ModuleShowType.NONE
        data = nil
    elseif extraMsg ~= nil and extraMsg.type == "attackTown" then --- 16=郡城盟战pvp, 17=郡城盟战pve
        self.showActionType = ModuleShowType.NONE
        data = nil
        isShowOtherCity = true
        if extraMsg.legionName == "" then
            showType = 17
        else
            showType = 16
        end
        otherCityStr = extraMsg.otherCityStr
        self._worldAttackData = extraMsg
        self._soldierProxy:setWorldAttackData(self._worldAttackData)
        self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80012, {x = extraMsg.tileX,y = extraMsg.tileY})
    elseif extraMsg ~= nil and extraMsg.type == "attackEmperorCity" then -- 皇城战出战
        self.showActionType = ModuleShowType.NONE
        data = nil
        isShowOtherCity = true

        showType = 18 -- todocity区分类型
        --showType = 19

        otherCityStr = extraMsg.otherCityStr
        self._worldAttackData = extraMsg
        self._soldierProxy:setWorldAttackData(self._worldAttackData)
    else
        self.showActionType = ModuleShowType.LEFT
        data = proxy:onGetTeamInfo()
        data = data[2].members   --
        data = proxy:setSolderCount(data) --
        showType = 2
    end
    if extraMsg == "workTarget" then
        self._view:setFirstPanelShow(true)
        --self._view:setJumpToWorkPanel(true)
        self._view:setShowMyCityStatus(true)
    else
        --self._view:setJumpToWorkPanel(nil)
        self._view:setFirstPanelShow()



        self._view:updateTeamSet(data, showType, subBattleType, otherCityStr, isNeedBody, isPlayerRes) --
    end
    self:onGetRoleInfo()
    self._view:onListenCountResp()
    self:onGetAllWorkResp()
    -- self:sendServerMessage(AppEvent.NET_M4, AppEvent.NET_M4_C40001, {})
    -- self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80003, {})
end
--刷新队伍里面的装备的小红点
function TeamModule:updateAllEquips()
    self._view:onTipsUpdateHandle()  
end

function TeamModule:onGetSoliderList()  --获取到的所有佣兵列表
    -- local proxy = self:getProxy(GameProxys.Soldier)
    -- self._view:updateSoliderList(proxy:getTotalSoldierList())
end

function TeamModule:onGetRoleInfo()
    local proxy = self:getProxy(GameProxys.Role)
    local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级
    --if self._level ~= level then
        self._level = level
        self._view:updateLevel(level)  --指挥官等级的改变，导致开放的坑位数目发生改变
    --end
    self._view:updateMaxFightSoldierCount()  --每个槽位的出战佣兵上线的改变
    self._view:updateCurrJewel()
end

function TeamModule:onGoFightHandler(data)  --出战
    if self._worldAttackData ~= nil then --世界战斗
        -- 出战队伍的上限判断
        if self._soldierProxy:getTroopCount() == self._soldierProxy:getMarchCount() then
            self._soldierProxy:showSysMessage(self:getTextWord(7073)) -- #4223 在proxy中有此方法
        else
            self._view:onJumpToWorkPanel()
            local sendData = {}
            sendData.team = data.infos
            sendData.x = self._worldAttackData.tileX
            sendData.y = self._worldAttackData.tileY
            sendData.force = self._worldAttackData.force or 0
            self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80001, sendData)
            self._view:setShowMyCityStatus(1)
            return
        end
    end
    self._sendServerData = data

    if data.type == GameConfig.battleType.legion then  --军团副本：已在军团副本模块询问过了
        --print("军团副本-出战-不用再次询问--直接请求50000")
        -- self:onGoFight()
        -- local battleProxy = self:getProxy(GameProxys.Battle)
        -- battleProxy:startBattleReq(self._sendServerData)

        local sendData = {}
        sendData.id = data.id
        self:sendServerMessage(AppEvent.NET_M27, AppEvent.NET_M27_C270001, sendData)
        return
    end

    local serverData = {}
    serverData.battleType = data.type
    serverData.evendId = data.id
    if serverData.battleType ~= nil then
        self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60002, serverData)
    end
    --print("出战前询问 battleType,evendId", serverData.battleType, serverData.evendId)
    
end

function TeamModule:onAttackPosResp(data)
    --if data.rs == 0 then
        --self._view:onJumpToWorkPanel()
    --end
end

-- 询问完，请求出战
function TeamModule:onGoFight()
    -- body
    local battleProxy = self:getProxy(GameProxys.Battle)
    battleProxy:startBattleReq(self._sendServerData)
    self:onHideSelfHandler()     
end

function TeamModule:onBeforeFightResp(data)
    if data.rs == 0 then
        self:onGoFight()
    end
end

function TeamModule:onKeepTeamHandler(data) --阵型的保存
    --self:sendServerMessage(AppEvent.NET_M7, AppEvent.NET_M7_C70001, data)
    local proxy = self:getProxy(GameProxys.Soldier)
    proxy:onTriggerNet70001Req(data)
end

function TeamModule:onAllRepaireListResp(data) --战损佣兵的列表
    local proxy = self:getProxy(GameProxys.Soldier)
    
    if data.rs == 0 then
        proxy:onBadSolidersListResp(data)
        self._view:onAllRepaireList()
    end
end

function TeamModule:onRepaireListReq()
end

function TeamModule:onRepaireReq(data)
    self:sendServerMessage(AppEvent.NET_M4, AppEvent.NET_M4_C40002, data)
end

function TeamModule:onOpenEquipModule()
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.DungeonModule})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.PartsModule})
    --self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.EquipModule,srcModule = self.name})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.EquipModule})
end

function TeamModule:onOpenPartsHandler()

    local buildingProxy = self:getProxy(GameProxys.Building)
    local isOpen = buildingProxy:isBuildingModuelOpen(ModuleName.PartsModule)
    if isOpen == false then
        return
    end
    
--    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_1)
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.DungeonModule})
    --self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.PartsModule,srcModule = self.name})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.PartsModule})
end

function TeamModule:onSleepReqHandler(data)
    self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60005, data)
end

function TeamModule:onSleepRespHandle(data)
    if data.rs == 0 then
        local proxy = self:getProxy(GameProxys.Soldier)  --及时刷新佣兵信息
        proxy:updateSoldiersList(data.soldierInfo)
        self._view:onSleepRespHandle(data)
    else
        self._view:onSleepRespHandle()
    end
    -- if data.rs == -6 then  --次数不足，购买
    --     self:buyChallengeTimes(1)
    -- end
    --elseif data.rs == -5 then   --军令不足
        -- local function callFunc()
            -- self:dispatchEvent(DungeonEvent.BUY_ENERGY,{})
            -- self:buyEnergtReq()
        -- end
        -- local proxy = self:getProxy(GameProxys.Role)
        -- -- local curPrice = proxy:getEnergyNeedMoney()
        -- local content = string.format(self:getTextWord(507), self.price)
        -- self:showMessageBox(content,callFunc)
    --end
end

function TeamModule:onListenCountResp(data)
    if data.rs == 0 then
        self._view:onListenCountResp()
    end
end

function TeamModule:onTipsUpdateHandle()
    self._view:onTipsUpdateHandle()
end

function TeamModule:onGetWorkReqHandler()
     self:onGetAllWorkResp()
    --self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80003, {})
end

function TeamModule:onAddSpeedReqHandler(data)
    self:sendServerMessage(AppEvent.NET_M8, AppEvent.NET_M8_C80004, data)
end

function TeamModule:onGetAllWorkResp()
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local data = soldierProxy:getSelfTaskTeamInfo()
    self._view:onGetAllWorkResp(data)
end

function TeamModule:buyEnergtReq()
    -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20013, {})
end

function TeamModule:buyEnergtResp(data)
    if data.rs > 0 then
        -- self.price = data.price
        -- self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20011, {})
    end
end

function TeamModule:buyChallengeTimes(type)
    local data = {}
    data.type = type
    local forxy = self:getProxy(GameProxys.Dungeon)
    local _,dungeoId = forxy:getCurrType()
    data.dungeoId = dungeoId
    self:sendServerMessage(AppEvent.NET_M6, AppEvent.NET_M6_C60004, data)
end

function TeamModule:onBuyTimesResp(data)
    if data.rs == 0 then   --1:返回购买需要的元宝数目,2:购买次数成功的返回
        self._view:onBuyTimesResp(data)
    end
end

function TeamModule:badSoldierListUpdate()
    self._view:badSoldierListUpdate()
end

function TeamModule:updaeEnergyNeedMoney(data)
    if data.rs == 0 then
        self._view:updaeEnergyNeedMoney()
    end
end

function TeamModule:onGetRunTimeResp(data)
    --print("&&&&&&&&&&&   %d",data.rs)
    if data.rs == 0 then
        --print("onGetRunTimeResp^^^^^^   %d",data.time)
        self._view:onGetRunTimeResp(data)
    end
end

function TeamModule:onConsuGoReq(data)
    self._view:onConsuGoReq(data)
end

function TeamModule:onOpenCounseHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end