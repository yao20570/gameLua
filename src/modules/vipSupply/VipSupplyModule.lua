
VipSupplyModule = class("VipSupplyModule", BasicModule)

function VipSupplyModule:ctor()
    VipSupplyModule .super.ctor(self)

    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_TOP_LAYER
    self._view = nil
    self._loginData = nil
    self.isFullScreen = false

    self:initRequire()
end

function VipSupplyModule:initRequire()
    require("modules.vipSupply.event.VipSupplyEvent")
    require("modules.vipSupply.view.VipSupplyView")
end

function VipSupplyModule:finalize()
    VipSupplyModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function VipSupplyModule:initModule()
    VipSupplyModule.super.initModule(self)
    self._view = VipSupplyView.new(self.parent)

    self:addEventHandler()
end

function VipSupplyModule:addEventHandler()
    self._view:addEventListener(VipSupplyEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(VipSupplyEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLYVIEW, self, self.onUpdateVipSupply)
    self:addProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLY_RECEIVE, self, self.onReveive)
    
    self:addProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLY_TIMECOMPLEC, self, self.onTimeComplete)
end

function VipSupplyModule:removeEventHander()
    self._view:removeEventListener(VipSupplyEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(VipSupplyEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLYVIEW, self, self.onUpdateVipSupply)
    self:removeProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLY_RECEIVE, self, self.onReveive)
    
    self:removeProxyEventListener(GameProxys.VipSupply, AppEvent.PROXY_UPDATE_VIPSUPPLY_TIMECOMPLEC, self, self.onTimeComplete)
end

function VipSupplyModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function VipSupplyModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end


function VipSupplyModule:onUpdateVipSupply(data)
    if data.rs==0 then
        self._view:updateVipSupply()
    end
end

function VipSupplyModule:onReveive(data)
    if data.rs==0 then
        self:showSysMessage( self:getTextWord( 1118 ) )
        --self._view:onReveive( data.receiveDay ) --
    end
end

function VipSupplyModule:onTimeComplete()
    self._view:onTimeComplete()
end