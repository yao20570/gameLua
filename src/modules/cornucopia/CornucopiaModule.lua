-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
CornucopiaModule = class("CornucopiaModule", BasicModule)

function CornucopiaModule:ctor()
    CornucopiaModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function CornucopiaModule:initRequire()
    require("modules.cornucopia.event.CornucopiaEvent")
    require("modules.cornucopia.view.CornucopiaView")
end

function CornucopiaModule:finalize()
    CornucopiaModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function CornucopiaModule:initModule()
    CornucopiaModule.super.initModule(self)
    self._view = CornucopiaView.new(self.parent)

    self:addEventHandler()
end

function CornucopiaModule:addEventHandler()
    self._view:addEventListener(CornucopiaEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(CornucopiaEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Activity,AppEvent.PROXY_CORNUCOPIA_UPDATE,self,self.activityInfoUpdate)
end

function CornucopiaModule:removeEventHander()
    self._view:removeEventListener(CornucopiaEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(CornucopiaEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Activity,AppEvent.PROXY_CORNUCOPIA_UPDATE,self,self.activityInfoUpdate)
end

function CornucopiaModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function CornucopiaModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function CornucopiaModule:onOpenModule(extraMsg, isPerLoad)
    if extraMsg and type(extraMsg) == "table" then
        if extraMsg.activityId then
            self.activityId = extraMsg.activityId
            self._view:setCurrentActivityId(self.activityId)
        end
    end
end

function CornucopiaModule:activityInfoUpdate()
    self._view:activityInfoUpdate()
end 