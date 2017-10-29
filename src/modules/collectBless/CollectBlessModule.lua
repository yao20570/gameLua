-- /**
--  * @Author:   fwx
--  * @DateTime: 2016.12.12
--  * @Description:  集福
--  */
CollectBlessModule = class("CollectBlessModule", BasicModule)

function CollectBlessModule:ctor()
    CollectBlessModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self:initRequire()
end

function CollectBlessModule:initRequire()
    require("modules.collectBless.event.CollectBlessEvent")
    require("modules.collectBless.view.CollectBlessView")
end

function CollectBlessModule:finalize()
    CollectBlessModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function CollectBlessModule:initModule()
    CollectBlessModule.super.initModule(self)
    self._view = CollectBlessView.new(self.parent)

    self:addEventHandler()
end

function CollectBlessModule:addEventHandler()
    self._view:addEventListener(CollectBlessEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(CollectBlessEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --背包数量变化
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onBagNumChang)
end

function CollectBlessModule:removeEventHander()
    self._view:removeEventListener(CollectBlessEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(CollectBlessEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    --背包数量变化
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.onBagNumChang)
end

function CollectBlessModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function CollectBlessModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function CollectBlessModule:onOpenModule(extraMsg)
    CollectBlessModule.super.onOpenModule(self)
end

function CollectBlessModule:onBagNumChang()
    self._view:updateList()
end