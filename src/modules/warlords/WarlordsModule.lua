--------created by zhangfan in 2016-08-11
--------群雄涿鹿报名模块
WarlordsModule = class("WarlordsModule", BasicModule)

function WarlordsModule:ctor()
    WarlordsModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function WarlordsModule:initRequire()
    require("modules.warlords.event.WarlordsEvent")
    require("modules.warlords.view.WarlordsView")
end

function WarlordsModule:finalize()
    WarlordsModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function WarlordsModule:initModule()
    WarlordsModule.super.initModule(self)
    self._view = WarlordsView.new(self.parent)
    self._soldierProxy = self:getProxy(GameProxys.Soldier)
    self._battleActivityProxy = self:getProxy(GameProxys.BattleActivity)
    self._systemProxy = self:getProxy(GameProxys.System)
    self:addEventHandler()
end

function WarlordsModule:addEventHandler()
    self._view:addEventListener(WarlordsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(WarlordsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSSIGN_OPEN, self, self.onWarlordsOpen)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_GETLEGIONLISTS, self, self.onGetlegionsList)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_GETMYLEGIONLISTS, self, self.onGetMylegionsList)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_GETFIGHTINFOS, self, self.onGetFightInfos)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_SETSIGNSUCCEED, self, self.onSetSignHandle)

    --self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSFAILED, self, self.onWarlordsFailedHandle)
end

function WarlordsModule:removeEventHander()
    self._view:removeEventListener(WarlordsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(WarlordsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSSIGN_OPEN, self, self.onWarlordsOpen)
    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_GETLEGIONLISTS, self, self.onGetlegionsList)
    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_GETMYLEGIONLISTS, self, self.onGetMylegionsList)
    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_GETFIGHTINFOS, self, self.onGetFightInfos)
    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_SETSIGNSUCCEED, self, self.onSetSignHandle)
    --self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSFAILED, self, self.onWarlordsFailedHandle)
end

function WarlordsModule:onHideSelfHandler()
    self._systemProxy:onTriggerNet30105Req({type = 1,scene = GlobalConfig.Scene[2]})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function WarlordsModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function WarlordsModule:onOpenModule(extraMsg)
    WarlordsModule.super.onOpenModule(self)
    self._soldierProxy:setMaxFighAndWeight()   --计算最大战力

    --self._battleActivityProxy:onTriggerNet330000Req({activityId = extraMsg.activityId})
    self._systemProxy:onTriggerNet30105Req({type = 0,scene = GlobalConfig.Scene[2]})
end

function WarlordsModule:onWarlordsOpen()
    self._view:onWarlordsOpen()
end

function WarlordsModule:onGetlegionsList()
    self._view:onGetlegionsList()
end

function WarlordsModule:onGetMylegionsList()
    self._view:onGetMylegionsList()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.WarlordsFieldModule})
end

function WarlordsModule:onGetFightInfos()
    self._view:onGetFightInfos()
end

function WarlordsModule:onSetSignHandle()
     self._view:onSetSignHandle()
end

function WarlordsModule:onHideModule()
    self._battleActivityProxy:onRemoveFun()
end

function WarlordsModule:onWarlordsFailedHandle()
    self._view:onWarlordsFailedHandle()
end