-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
WorldHelpModule = class("WorldHelpModule", BasicModule)

function WorldHelpModule:ctor()
    WorldHelpModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL

    self.uiLayerName =ModuleLayer.UI_3_LAYER --������������ò㼶

    self.isFullScreen = false --���������,�ͱ�ʾ��һ��UI,�����Ͳ��ᵼ��ģ��رյ�ʱ��,������ȫ������

    
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function WorldHelpModule:initRequire()
    require("modules.worldHelp.event.WorldHelpEvent")
    require("modules.worldHelp.view.WorldHelpView")
end

function WorldHelpModule:finalize()
    WorldHelpModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function WorldHelpModule:initModule()
    WorldHelpModule.super.initModule(self)
    self._view = WorldHelpView.new(self.parent)

    self:addEventHandler()
end

function WorldHelpModule:addEventHandler()
    self._view:addEventListener(WorldHelpEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(WorldHelpEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function WorldHelpModule:removeEventHander()
    self._view:removeEventListener(WorldHelpEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(WorldHelpEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function WorldHelpModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function WorldHelpModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function WorldHelpModule:onOpenModule(extraMsg)
    WorldHelpModule.super.onOpenModule(self)
    self._view:initView()
end