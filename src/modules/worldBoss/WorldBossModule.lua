
WorldBossModule = class("WorldBossModule", BasicModule)

function WorldBossModule:ctor()
    WorldBossModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.Animation

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function WorldBossModule:initRequire()
    require("modules.worldBoss.event.WorldBossEvent")
    require("modules.worldBoss.view.WorldBossView")
end

function WorldBossModule:finalize()
    WorldBossModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function WorldBossModule:initModule()
    WorldBossModule.super.initModule(self)
    self._view = WorldBossView.new(self.parent)
    self._systemProxy = self:getProxy(GameProxys.System)
    self._soldierProxy = self:getProxy(GameProxys.Soldier)
    self:addEventHandler()
end

function WorldBossModule:addEventHandler()
    self._view:addEventListener(WorldBossEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(WorldBossEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_AUTOBATTLE, self, self.updateAutoBattleState)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_INSPIREVIEW, self, self.updateInspireView)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_BOSSINFO, self, self.updateBossInfo)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_SHOW_VIEW, self, self.showView)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_RANKVIEW, self, self.updateRankView)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_SHOW_MYATTACK, self, self.showMyAttack)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_SET_TEAM, self, self.setTeamIcon)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_BOSS_DIED, self, self.bossDied)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_CANCEL_COLDDOWN, self, self.cancelColdDown)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_ACTIVITY_END, self, self.activityEnd)
end

function WorldBossModule:removeEventHander()
    self._view:removeEventListener(WorldBossEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(WorldBossEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_AUTOBATTLE, self, self.updateAutoBattleState)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_INSPIREVIEW, self, self.updateInspireView)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_BOSSINFO, self, self.updateBossInfo)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_SHOW_VIEW, self, self.showView)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_UPDATE_RANKVIEW, self, self.updateRankView)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_SHOW_MYATTACK, self, self.showMyAttack)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_SET_TEAM, self, self.setTeamIcon)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_BOSS_DIED, self, self.bossDied)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_CANCEL_COLDDOWN, self, self.cancelColdDown)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WORLDBOSS_ACTIVITY_END, self, self.activityEnd)
end

function WorldBossModule:onHideSelfHandler()
    self._systemProxy:onTriggerNet30105Req({type = 1,scene = GlobalConfig.Scene[1]})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function WorldBossModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function WorldBossModule:onOpenModule(extraMsg)
    self.super.onOpenModule(self)
    self._soldierProxy:setMaxFighAndWeight()
    self._systemProxy:onTriggerNet30105Req({type = 0,scene = GlobalConfig.Scene[1]})
    if rawget(extraMsg, "activityId") == nil then
        local proxy = self:getProxy(GameProxys.BattleActivity)
        extraMsg = proxy:getCurBattleData(ActivityDefine.SERVER_ACTION_WORLD_BOSS)
    end

    self._view:saveCurActivityData(extraMsg)
    self.activityId = extraMsg.activityId
end

function WorldBossModule:updateAutoBattleState(data)
    self._view:updateAutoBattleState(data)
end

function WorldBossModule:updateInspireView()
    self._view:updateInspireView()
end

function WorldBossModule:updateBossInfo(data)
    self._view:updateBossInfo(data)
end

function WorldBossModule:showView(isNoOpen)
    self._view:showView(isNoOpen)
end

function WorldBossModule:sendRankInfoReq() 
    local proxy = self:getProxy(GameProxys.BattleActivity)
    local activityData = proxy:getBossInfoById(self.activityId)
    proxy:onTriggerNet320006Req({monsterId = activityData.monsterId})
end

function WorldBossModule:onHideModule()
    local worldBossPanel = self:getPanel(WorldBossPanel.NAME)
    worldBossPanel:hideModuleHandler()
end

function WorldBossModule:updateRankView(data)
    self._view:updateRankView(data)
end

function WorldBossModule:showMyAttack(data)
    self._view:showMyAttack(data)
end

function WorldBossModule:setTeamIcon(data)
    self._view:setTeamIcon(data)
end

function WorldBossModule:bossDied(data)
    self._view:bossDied(data)
end

function WorldBossModule:cancelColdDown()
    self._view:cancelColdDown()
end

function WorldBossModule:activityEnd()
    self._view:activityEnd()
end