--------created by zhangfan in 2016-08-12
--------群雄涿鹿战场模块
WarlordsFieldModule = class("WarlordsFieldModule", BasicModule)

function WarlordsFieldModule:ctor()
    WarlordsFieldModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function WarlordsFieldModule:initRequire()
    require("modules.warlordsField.event.WarlordsFieldEvent")
    require("modules.warlordsField.view.WarlordsFieldView")
end

function WarlordsFieldModule:finalize()
    WarlordsFieldModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function WarlordsFieldModule:initModule()
    WarlordsFieldModule.super.initModule(self)
    self._view = WarlordsFieldView.new(self.parent)
    self:addEventHandler()
end

function WarlordsFieldModule:addEventHandler()
    self._view:addEventListener(WarlordsFieldEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(WarlordsFieldEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_FIGHTREPORTS_CHANGE, self, self.onFightInfosChange)

    self:addProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSCOMBAT, self, self.onComBatProgress)
end

function WarlordsFieldModule:removeEventHander()
    self._view:removeEventListener(WarlordsFieldEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(WarlordsFieldEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_FIGHTREPORTS_CHANGE, self, self.onFightInfosChange)

    self:removeProxyEventListener(GameProxys.BattleActivity, AppEvent.PROXY_WARLORDSCOMBAT, self, self.onComBatProgress)
end

function WarlordsFieldModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function WarlordsFieldModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function WarlordsFieldModule:onFightInfosChange()
    self._view:onFightInfosChange()
end

function WarlordsFieldModule:onOpenModule(extraMsg)
    WarlordsFieldModule.super.onOpenModule(self)
    self._view:onOpenModule()
end

function WarlordsFieldModule:onComBatProgress()
    self._view:onComBatProgress()
end