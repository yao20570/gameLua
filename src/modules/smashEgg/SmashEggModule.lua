-- /**
--  * @Author: fwx   
--  * @DateTime:  2016.12.07
--  * @Description:  限时活动：金鸡砸蛋
--  */
SmashEggModule = class("SmashEggModule", BasicModule)

function SmashEggModule:ctor()
    SmashEggModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT

    self:initRequire()
end

function SmashEggModule:initRequire()
    require("modules.smashEgg.event.SmashEggEvent")
    require("modules.smashEgg.view.SmashEggView")
end

function SmashEggModule:finalize()
    SmashEggModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function SmashEggModule:initModule()
    SmashEggModule.super.initModule(self)
    self._view = SmashEggView.new(self.parent)

    self:addEventHandler()
end

function SmashEggModule:addEventHandler()
    self._view:addEventListener(SmashEggEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(SmashEggEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW_SMASHEGG, self, self.onSmashEggResp)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW_TIMEOVER, self, self.updateValue)
    self:addProxyEventListener(GameProxys.Role,AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateValue)
end

function SmashEggModule:removeEventHander()
    self._view:removeEventListener(SmashEggEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(SmashEggEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW_SMASHEGG, self, self.onSmashEggResp)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_UPDATE_ACTVIEW_TIMEOVER, self, self.updateValue)
    self:removeProxyEventListener(GameProxys.Role,AppEvent.PROXY_UPDATE_BUFF_NUM, self, self.updateValue)
end

function SmashEggModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function SmashEggModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function SmashEggModule:onOpenModule(extraMsg)
    SmashEggModule.super.onOpenModule(self)
end

--累计属性变化后
function SmashEggModule:updateValue()
    self._view:updateValue()
end

--砸蛋回来
function SmashEggModule:onSmashEggResp( rewardList )
    self._view:onSmashEggResp( rewardList )
    self._view:updateValue()
end