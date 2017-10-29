-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
LegionGiftModule = class("LegionGiftModule", BasicModule)

function LegionGiftModule:ctor()
    LegionGiftModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false
    
    self:initRequire()
end

function LegionGiftModule:initRequire()
    require("modules.legionGift.event.LegionGiftEvent")
    require("modules.legionGift.view.LegionGiftView")
end

function LegionGiftModule:finalize()
    LegionGiftModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LegionGiftModule:initModule()
    LegionGiftModule.super.initModule(self)
    self._view = LegionGiftView.new(self.parent)

    self:addEventHandler()
end

function LegionGiftModule:addEventHandler()
    self._view:addEventListener(LegionGiftEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LegionGiftEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function LegionGiftModule:removeEventHander()
    self._view:removeEventListener(LegionGiftEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LegionGiftEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
end

function LegionGiftModule:onHideSelfHandler()
    local function hideCallback()
        self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
        return ""
    end
    self:getPanel(LegionGiftPanel.NAME):hide(hideCallback, self)

    --self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})

end

function LegionGiftModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end