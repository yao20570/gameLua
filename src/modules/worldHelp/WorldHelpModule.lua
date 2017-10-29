-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
WorldHelpModule = class("WorldHelpModule", BasicModule)

function WorldHelpModule:ctor()
    WorldHelpModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL

    self.uiLayerName =ModuleLayer.UI_3_LAYER --设置这个能设置层级

    self.isFullScreen = false --设置了这个,就表示是一个UI,这样就不会导致模块关闭的时候,主场景全部隐藏

    
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