-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MilitaryModule = class("MilitaryModule", BasicModule)

function MilitaryModule:ctor()
    MilitaryModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function MilitaryModule:initRequire()
    require("modules.military.event.MilitaryEvent")
    require("modules.military.view.MilitaryView")
end

function MilitaryModule:finalize()
    MilitaryModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function MilitaryModule:initModule()
    MilitaryModule.super.initModule(self)
    self._view = MilitaryView.new(self.parent)

    self:addEventHandler()
end

function MilitaryModule:addEventHandler()
    self._view:addEventListener(MilitaryEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(MilitaryEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Military, AppEvent.PROXY_MILITARY_UPDATE, self, self.onUpdateProjecePanell)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onUpdateListView)
end

function MilitaryModule:removeEventHander()
    self._view:removeEventListener(MilitaryEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(MilitaryEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Military, AppEvent.PROXY_MILITARY_UPDATE, self, self.onUpdateProjecePanell)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onUpdateListView)
end

function MilitaryModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function MilitaryModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function MilitaryModule:onUpdateProjecePanell()
    self:getPanel(MilitaryProjectPanel.NAME):onUpdateProjecePanel()
end


function MilitaryModule:onUpdateListView()
    self:getPanel(MilitaryProjectPanel.NAME):onUpdateListView()
end
