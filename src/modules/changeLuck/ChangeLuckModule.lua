-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: ÕÐ²Æ×ªÔË
--  */
ChangeLuckModule = class("ChangeLuckModule", BasicModule)

function ChangeLuckModule:ctor()
    ChangeLuckModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER

    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function ChangeLuckModule:initRequire()
    require("modules.changeLuck.event.ChangeLuckEvent")
    require("modules.changeLuck.view.ChangeLuckView")
end

function ChangeLuckModule:finalize()
    ChangeLuckModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ChangeLuckModule:initModule()
    ChangeLuckModule.super.initModule(self)
    self._view = ChangeLuckView.new(self.parent)

    self:addEventHandler()
end

function ChangeLuckModule:addEventHandler()
    self._view:addEventListener(ChangeLuckEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ChangeLuckEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self:addProxyEventListener(GameProxys.LuckTurntable, AppEvent.PROXY_UPDATE_CHANGE_LUCK_INFO, self, self.updateUI)
end

function ChangeLuckModule:removeEventHander()
    self._view:removeEventListener(ChangeLuckEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ChangeLuckEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.LuckTurntable, AppEvent.PROXY_UPDATE_CHANGE_LUCK_INFO, self, self.updateUI)
end

function ChangeLuckModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ChangeLuckModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ChangeLuckModule:updateUI(awardId)
    self._view:updateUI(awardId)
end