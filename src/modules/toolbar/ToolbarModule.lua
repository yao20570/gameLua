
ToolbarModule = class("ToolbarModule", BasicModule)

function ToolbarModule:ctor()
    ToolbarModule .super.ctor(self)
    
    self.isFullScreen = false
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_2_LAYER
    self.isLayoutNode = false
    self._view = nil
    self._loginData = nil
    self.teamInfoList = {}
    self:initRequire()
end

function ToolbarModule:initRequire()
    require("modules.toolbar.event.ToolbarEvent")
    require("modules.toolbar.view.ToolbarView")
    require "modules.chat.rich.RichTextMgr"
end

function ToolbarModule:finalize()
    ToolbarModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ToolbarModule:initModule()
    ToolbarModule.super.initModule(self)
    self._view = ToolbarView.new(self.parent)
    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_1)

    self:addEventHandler()
--    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20200, {})
end

function ToolbarModule:addEventHandler()
    self._view:addEventListener(ToolbarEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ToolbarEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
--    self._view:addEventListener(ToolbarEvent.BUY_VIP_INFO_REQ, self, self.buyVipBuildingEeq)
    self._view:addEventListener(ToolbarEvent.BUY_VIP_INFO_SURE, self, self.buyVipBuildingSure)
    self._view:addEventListener(ToolbarEvent.SET_DEFEND_TEAM, self, self.setDefendTeam)
    self._view:addEventListener(ToolbarEvent.SET_GO_HOME_TEAM, self, self.setGoHomeTeam)
    self._view:addEventListener(ToolbarEvent.BEATTACTED_REQ, self, self.beAttactedReq)
    self._view:addEventListener(ToolbarEvent.TEAM_INFO_REQ, self, self.teamInfoReq)

    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)
    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onGetPrivateChatinfoResp)
    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_UPDATE, self, self.buildingUpdateHandler)
    self:addProxyEventListener(GameProxys.Building, AppEvent.BUILDING_ISCANBUYBUILDING, self, self.isCanBuyVipBuilding)
    self:addProxyEventListener(GameProxys.Building, AppEvent.BUILDING_SUCCESS_UPDATE, self, self.buySuccess) ---DSFAAS
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onRoleInfoUpdateResp) ---临时建筑
    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_BUY_FIELD, self, self.buyVipBuildingReq)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_POWER, self, self.updateRolePowerHandler)

    self:addProxyEventListener(GameProxys.Chat, AppEvent.CLEAR_TOOLBAR_CMD, self, self.onClearCmd)



    --self:addEventListener(AppEvent.NET_M16, AppEvent.NET_M16_C160002, self, self.onNewMailsResp)
    -- self:addEventListener(AppEvent.NET_M19, AppEvent.NET_M19_C190004, self, self.onTaskNumResp)
    self:addProxyEventListener(GameProxys.RedPoint, AppEvent.PROXY_REDPOINT_UPDATE, self, self.onUpdateTipsResp)

    self:addEventListener(AppEvent.NET_CHATNOTICE,AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)

    self:addEventListener(AppEvent.GUIDE_NOTICE,AppEvent.ACTIVITE_SHOW_BTN,self,self.onUpdateBtnPanel)
    self:addEventListener(AppEvent.GUIDE_NOTICE,AppEvent.TOOLBAR_SHOW_BTN,self,self.onUpdateBtnList)
    self:addEventListener(AppEvent.STATE_EVENT,AppEvent.QUEUEBTN_STATE_EVENT,self,self.onHideQueueBtn)

    self:addProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE, self, self.updateSeason)--更新季节
    self:addProxyEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE_WORLDLEVEL, self, self.updateWorldLevel)--更新世界等级
    
    self:addEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)--完成加载资源之后的事件
    
    self:addEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, self, self.onShowAllModule)
    self:addProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_EXIT_INFO, self, self.onLegionExit)
    self:addProxyEventListener(GameProxys.Task, AppEvent.PROXY_TASK_INFO_UPDATE, self, self.updateTaskInfo)
    self:addProxyEventListener(GameProxys.Role,AppEvent.PROXY_OPENSERVERGIFT_INFO_UPDATE, self, self.updateOpenSeverInfo)

    self:addProxyEventListener(GameProxys.Item,AppEvent.PROXY_BAG_OPENMAP, self, self.showMapModule)

    self:addProxyEventListener(GameProxys.Soldier, AppEvent.TASK_TEAM_INFO_UPDATE, self, self.onupdateTeamInfoResp)
    self:addProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_TEAM_BEATTACTION, self, self.onupdateBeAttacked)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LEGION_GIFT, self, self.onUpdateLegionGift)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_LIMIT, self, self.onUpdateLimitBtn)
    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_BATTLE_ACTIVITY_UPDATE, self, self.onUpdateLimitBtn)

    self:addEventListener(AppEvent.UPDATE_COUNT, AppEvent.SET_PGK_NUM, self,self.onUpdatePkgNum)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_COUNT, self, self.onUpdatePkgNum)

    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetGuideRewardResp)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSWORLD, self, self.onUpdateWarlordsStats) --330100

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_OPENWARLORDS, self, self.onOpenwarlords)

    self:addProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLY_POINT, self, self.updateVipSupplyPoint ) --vip特供红点推送

     self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE, self, self.updateWeekCardShowAndRedPoint ) --周卡数据更新
    --抢红包信息更新
    self:addProxyEventListener(GameProxys.RedBag, AppEvent.PROXY_UPDATE_REDBAGINFOS, self, self.updateToolbarRedBag)
    --打开红包弹窗
    self:addProxyEventListener(GameProxys.RedBag, AppEvent.PROXY_REDBAGI_OPEN, self, self.openRedBag)  
    --MainScenePanel通知ToolbarPanel建筑按钮提示免费加速特效
    self:addProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDFREE_TOOLBARTIP, self, self.buildFreeTip)  
    self:addProxyEventListener(GameProxys.RealName, AppEvent.PROXY_REALNAME_UPDATE, self, self.onRealNameBtnVisible)
    
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_QUEPANEL_HIDE, self, self.onHideQueuePanel)

    self:addProxyEventListener(GameProxys.Chat,AppEvent.PROXY_GET_CHAT_INFO_BARRAGE,self,self.updateChatBarrage)

    self:addEventListener(AppEvent.UNLOCK,AppEvent.UNLCOK_EVENT,self,self.testMsg)
    self:addEventListener(AppEvent.UNLOCK_BEGIN,AppEvent.UNLOCK_BEGIN_EVENT,self,self.unLock)
    
    self:addProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_READ_REPORT_ACT, self, self.updateWorlordImpRedPoint) -- 皇位战个人战报变更
end

function ToolbarModule:removeEventHander()
    self._view:removeEventListener(ToolbarEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ToolbarEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
--    self._view:removeEventListener(ToolbarEvent.BUY_VIP_INFO_REQ, self, self.buyVipBuildingEeq)
    self._view:removeEventListener(ToolbarEvent.BUY_VIP_INFO_SURE, self, self.buyVipBuildingSure)
    self._view:removeEventListener(ToolbarEvent.SET_DEFEND_TEAM, self, self.setDefendTeam)
    self._view:removeEventListener(ToolbarEvent.SET_GO_HOME_TEAM, self, self.setGoHomeTeam)
    self._view:removeEventListener(ToolbarEvent.BEATTACTED_REQ, self, self.beAttactedReq)
    self._view:removeEventListener(ToolbarEvent.TEAM_INFO_REQ, self, self.teamInfoReq)

    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_CHAT_INFO, self, self.onGetChatInfoResp)
    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_CHAT_RESP, self, self.onGetPrivateChatinfoResp)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_UPDATE, self, self.buildingUpdateHandler)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.BUILDING_ISCANBUYBUILDING, self, self.isCanBuyVipBuilding)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.BUILDING_SUCCESS_UPDATE, self, self.buySuccess)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onRoleInfoUpdateResp)
    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDING_BUY_FIELD, self, self.buyVipBuildingReq)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSWORLD, self, self.onUpdateWarlordsStats)

    self:removeProxyEventListener(GameProxys.Chat, AppEvent.CLEAR_TOOLBAR_CMD, self, self.onClearCmd)
    
    --self:removeEventListener(AppEvent.NET_M16, AppEvent.NET_M16_C160002, self, self.onNewMailsResp)
    -- self:removeEventListener(AppEvent.NET_M19, AppEvent.NET_M19_C190004, self, self.onTaskNumResp)
    self:removeProxyEventListener(GameProxys.RedPoint, AppEvent.PROXY_REDPOINT_UPDATE, self, self.onUpdateTipsResp)
    

    self:removeEventListener(AppEvent.NET_CHATNOTICE,AppEvent.CHAT_NOSEE_UPDATE,self,self.updateNoSeeChatNum)

    self:removeEventListener(AppEvent.GUIDE_NOTICE, AppEvent.ACTIVITE_SHOW_BTN, self,self.onUpdateBtnPanel)
    self:removeEventListener(AppEvent.GUIDE_NOTICE, AppEvent.TOOLBAR_SHOW_BTN, self,self.onUpdateBtnList)

    self:removeEventListener(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, self, self.onShowAllModule)
    self:removeProxyEventListener(GameProxys.Legion, AppEvent.PROXY_LEGION_EXIT_INFO, self, self.onLegionExit)
    self:removeProxyEventListener(GameProxys.Task, AppEvent.PROXY_TASK_INFO_UPDATE, self, self.updateTaskInfo)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_OPENSERVERGIFT_INFO_UPDATE, self, self.updateOpenSeverInfo)

    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_OPENMAP, self, self.showMapModule)

    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.TASK_TEAM_INFO_UPDATE, self, self.onupdateTeamInfoResp)
    self:removeProxyEventListener(GameProxys.Soldier, AppEvent.PROXY_TEAM_BEATTACTION, self, self.onupdateBeAttacked)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_LEGION_GIFT, self, self.onUpdateLegionGift)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_POWER, self, self.updateRolePowerHandler)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_LIMIT, self, self.onUpdateLimitBtn)
    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_BATTLE_ACTIVITY_UPDATE, self, self.onUpdateLimitBtn)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_COUNT, self, self.onUpdatePkgNum)
    self:removeEventListener(AppEvent.UPDATE_COUNT, AppEvent.SET_PGK_NUM, self,self.onUpdatePkgNum)
    self:removeEventListener(AppEvent.STATE_EVENT,AppEvent.QUEUEBTN_STATE_EVENT,self,self.onHideQueueBtn)

    self:removeEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE, self, self.updateSeason)--更新季节
    self:removeEventListener(GameProxys.Seasons, AppEvent.PROXY_SEASONS_UPDATE_WORLDLEVEL, self, self.updateWorldLevel)--更新世界等级

    self:removeEventListener(AppEvent.SCENE_EVENT, AppEvent.SCENE_ENTER_EVENT, self, self.onEnterScene)--完成加载资源之后的事件

    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20301, self, self.onGetGuideRewardResp)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_OPENWARLORDS, self, self.onOpenwarlords)

    self:removeProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLY_POINT, self, self.updateVipSupplyPoint ) --vip特供红点推送

    self:removeProxyEventListener(GameProxys.RedBag, AppEvent.PROXY_UPDATE_REDBAGINFOS, self, self.updateToolbarRedBag) 
    self:removeProxyEventListener(GameProxys.RedBag, AppEvent.PROXY_REDBAGI_OPEN, self, self.openRedBag)  

    self:removeProxyEventListener(GameProxys.Building, AppEvent.PROXY_BUILDFREE_TOOLBARTIP, self, self.buildFreeTip)  
    self:removeProxyEventListener(GameProxys.RealName, AppEvent.PROXY_REALNAME_UPDATE, self, self.onRealNameBtnVisible)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_QUEPANEL_HIDE, self, self.onHideQueuePanel)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_ACTIVITY_WEEKCARD_UPDATE, self, self.updateWeekCardShowAndRedPoint )

    self:removeProxyEventListener(GameProxys.Chat,AppEvent.PROXY_GET_CHAT_INFO_BARRAGE,self,self.updateChatBarrage)

    self:removeEventListener(AppEvent.UNLOCK,AppEvent.UNLCOK_EVENT,self,self.testMsg)
    self:removeEventListener(AppEvent.UNLOCK_BEGIN,AppEvent.UNLOCK_BEGIN_EVENT,self,self.unLock)

    self:removeProxyEventListener(GameProxys.EmperorCity, AppEvent.PROXY_EMPEROR_CITY_READ_REPORT_ACT, self, self.updateWorlordImpRedPoint) -- -- 皇位战个人战报变更
end

function ToolbarModule:onOpenModule()
    ToolbarModule.super.onOpenModule(self)
    if self._firstOpen == nil then
        self._firstOpen = true
        -- self:sendServerMessage(AppEvent.NET_M2,AppEvent.NET_M2_C20015, {dayNum=0})
        self:sendServerMessage(AppEvent.NET_M16, AppEvent.NET_M16_C160002, {})

        self:onupdateTeamInfoResp()
        self:onupdateBeAttacked()
        self._view:isShowRankItem()
        self:onUpdateWarlordsStats()  --百团大战的图标状态
        self:updateTaskInfo() --更新任务快捷栏
        self:onRealNameBtnVisible() --更新实名认证按钮
    end
end

--小助手新手引导到活动模块，通知按钮面板显示全部按钮
function ToolbarModule:onUpdateBtnPanel()
    self._view:onUpdateBtnPanel()
end

--小助手新手引导，通知底部按钮列表显示
function ToolbarModule:onUpdateBtnList(data)
    self._view:onUpdateBtnList(data)
end

function ToolbarModule:onGetChatInfoResp(data)
    self._view:onGetChatInfoResp(data)
end


function ToolbarModule:onHideQueueBtn(isShow)
    self._view:onHideQueueBtn(isShow)
end

function ToolbarModule:onGetPrivateChatinfoResp(data)
    self._view:onGetPrivateChatInfoResp(data)
end

-- 建筑更新通知
function ToolbarModule:buildingUpdateHandler(data)
    self._view:updateBuildingInfo()
end

-- 角色更新通知
function ToolbarModule:onRoleInfoUpdateResp(updatePowerList)    
    local proxy = self:getProxy(GameProxys.RedPoint)
    proxy:checkDungeonRedPoint()
    self._view:onRoleInfoUpdateResp(updatePowerList)
end

function ToolbarModule:updateTaskInfo()
    self._view:updateTaskInfo()
end

function ToolbarModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ToolbarModule:onShowAllModule(data)
    local moduleName = data.moduleName
    if moduleName == ModuleName.MapModule then
        if data.hasOpen ~= true then
            self:showMapModule()
        end
    elseif moduleName == ModuleName.MainSceneModule then
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MapModule})
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LegionSceneModule})
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LegionModule})
        local roleProxy = self:getProxy(GameProxys.Role)
        local name = roleProxy:getRoleName()   --新手阶段         
        if name == "" or GameConfig.isNewPlayer == true then
            self._view:setCurSceneState(moduleName, true)
        else
            self._view:setCurSceneState(moduleName, true)
        end
    elseif moduleName == ModuleName.LegionSceneModule then
        if data.hasOpen ~= true then
            self:showLegionSceneModule()
        end
    end
end

function ToolbarModule:onShowOtherHandler(data)
    if data.moduleName == ModuleName.MapModule then  --tudo：下载分包结束的时候再关闭MainSceneModule模块，不然下载的时候会变黑一段时间
        data.beforeCall = function ()
            self:showMapModule()
        end
        data.hasOpen = true
    elseif data.moduleName == ModuleName.LegionSceneModule then
        data.beforeCall = function ()
            self:showLegionSceneModule()
        end
        data.hasOpen = true
    end
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
    TimerManager:addOnce(500, function()
        NodeUtils:removeSwallow()
    end, self)
end

function ToolbarModule:showMapModule()
--    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MainSceneModule})
--    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LegionSceneModule})
--    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.LegionModule})
    self._view:setCurSceneState(ModuleName.MapModule)
end

function ToolbarModule:showLegionSceneModule()
--    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MainSceneModule})
--    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MapModule})
    self._view:setCurSceneState(ModuleName.LegionSceneModule)
end

function ToolbarModule:onNewMailsResp(data)
    self._view:onNewMailsResp(data)
end

-- 任务红点：可领取数量
function ToolbarModule:onTaskNumResp(data)
    self._view:onTaskNumResp(data)
end

---弹出购买建筑位框
function ToolbarModule:buyVipBuildingReq(data)
    --客户端自己算出 是否能够购买
    local buildingProxy = self:getProxy(GameProxys.Building)
    local needGold = buildingProxy:askBuyBuildSize()

    if needGold >= 30 then--or needGold == 3 then
        self:isCanBuyVipBuilding(needGold)
    elseif needGold == 2 then
        self:showSysMessage(TextWords:getTextWord(304))
    elseif needGold == 1 then
        self:showSysMessage(TextWords:getTextWord(8305))
    else --元宝不足
        self:isCanBuyVipBuilding(needGold)
        -- local data = {}
        -- data.gold = 3
        -- self._view:onShowRechargeUI()
        --self:isCanBuyVipBuilding(needGold)    
    end

    -- self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100009,{})
end
function ToolbarModule:isCanBuyVipBuilding(data)
    self._view:isCanBuyVipBuilding(data)
end
----100010 购买
function ToolbarModule:buyVipBuildingSure(data)
    -- self:sendServerMessage(AppEvent.NET_M10, AppEvent.NET_M10_C100010,{})

    --购买VIP购买建筑位
    local buildingProxy = self:getProxy(GameProxys.Building)
    buildingProxy:onTriggerNet280011Req({})

end
function ToolbarModule:buySuccess(data)
    self._view:buySuccess(data)
end

function ToolbarModule:onUpdateTipsResp()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    local data = redPointProxy:getRedPointInfos()
    self._view:onUpdateTipsResp(data)
end

function ToolbarModule:updateNoSeeChatNum(data)  --刷新未读聊天信息
    self._view:updateNoSeeChatNum(data)
end

-- 退出军团
function ToolbarModule:onLegionExit()
    -- body
    print("···退出军团 toolbar")
    self:onShowOtherHandler({moduleName = ModuleName.MainSceneModule})
end

function ToolbarModule:updateOpenSeverInfo(data)
    self._view:updateOpenSeverInfo(data)
end

function ToolbarModule:onupdateTeamInfoResp()
    local soldierProxy = self:getProxy(GameProxys.Soldier)
    local data = soldierProxy:getTaskTeamInfo()

    self._view:updateQueuePanel()
end

function ToolbarModule:onupdateBeAttacked(data)
    if data == nil then
        local soldierProxy = self:getProxy(GameProxys.Soldier)
        data = soldierProxy:getAttactionData()
    end
    self._view:onupdateBeAttacked(data)

    self._view:playWarning()
end

function ToolbarModule:setDefendTeam(data)
    self:sendServerMessage(AppEvent.NET_M8,AppEvent.NET_M8_C80014, data)
end

function ToolbarModule:setGoHomeTeam(data)
    self:sendServerMessage(AppEvent.NET_M8,AppEvent.NET_M8_C80004, data)
end

function ToolbarModule:beAttactedReq(data)
    self:sendServerMessage(AppEvent.NET_M8,AppEvent.NET_M8_C80007, data)
end

function ToolbarModule:teamInfoReq(data)

    self:onupdateTeamInfoResp()
end

-- 军团好礼按钮更新
function ToolbarModule:onUpdateLegionGift(data)
    -- body
    self._view:onUpdateLegionGift(data)
end

function ToolbarModule:onUpdateLimitBtn(param)
    self._view:onUpdateLimitBtn(param)
end

function ToolbarModule:onUpdatePkgNum(num)
    self._view:onUpdatePkgNum(num)
end

function ToolbarModule:onGetGuideRewardResp(data)
    if data.rs == 0 then
        GameConfig.isNewPlayer = false
        if self:isModuleShow(ModuleName.MainSceneModule) then --主城模块显示才还原
            self._view:onEndGuide()
        end
    end
end

function ToolbarModule:onUpdateWarlordsStats()
    self._view:onUpdateWarlordsStats()
end

function ToolbarModule:onOpenwarlords()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.WarlordsModule})
end


function ToolbarModule:hideMainBtn(state)
    -- 拖动为true
    local toolbarPanel = self:getPanel(ToolbarPanel.NAME)
    toolbarPanel:isShowToolBtn(state)
end

------
-- 刷新繁荣
function ToolbarModule:updateRolePowerHandler(data)
    

end

--更新vip特供图标
function ToolbarModule:updateVipSupplyPoint( data )
    if data.rs==0 then
        self._view:updateVipSupplyPoint()
    end
end
--更新周卡入口
function ToolbarModule:updateWeekCardShowAndRedPoint( data )
    self._view:updateWeekCardShowAndRedPoint()
end

function ToolbarModule:updateToolbarRedBag()
    self._view:updateToolbarRedBag()
end

function ToolbarModule:openRedBag(data)
    self._view:openRedBag(data)
end

function ToolbarModule:onClearCmd()
    self._view:onClearCmd()
end

function ToolbarModule:buildFreeTip(isCanFreeBuild)
    self._view:buildFreeTip(isCanFreeBuild)
end

function ToolbarModule:onRealNameBtnVisible()
    self._view:onRealNameBtnVisible()
end

function ToolbarModule:onHideQueuePanel()
    self._view:onHideQueuePanel()
end

function ToolbarModule:updateSeason()
    --[[ios sdk 切换账号]]
    if self._view then
        self._view:updateSeason()
    end
end

function ToolbarModule:updateWorldLevel()
    --[[ios sdk 切换账号]]
    if self._view then
        self._view:updateWorldLevel()
    end
end

function ToolbarModule:onEnterScene()
    self._view:onEnterScene()
end

function ToolbarModule:updateChatBarrage(data)
    if #data == 0 then
    return 
    end
    self._view:updateChatBarrage(data)
end


function ToolbarModule:testMsg(data)
    --print("弹起")
    --TimerManager:addOnce(5000,self._view:updateUnlockEnd(data),self)
    self._view:updateUnlockEnd(data)
end


function ToolbarModule:unLock(data)
    
    self._view:updateUnlockBegin(data)
end

-- 皇位战个人战报变更
function ToolbarModule:updateWorlordImpRedPoint()
    local panel = self:getPanel(ToolbarPanel.NAME)
    panel:updateWorlordImpRedPoint()
end
