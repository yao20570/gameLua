
ChargeShareModule = class("ChargeShareModule", BasicModule)

function ChargeShareModule:ctor()
    ChargeShareModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self.isFullScreen = true
    
    self:initRequire()
end

function ChargeShareModule:initRequire()
    require("modules.chargeShare.event.ChargeShareEvent")
    require("modules.chargeShare.view.ChargeShareView")
end

function ChargeShareModule:finalize()
    ChargeShareModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function ChargeShareModule:initModule()
    ChargeShareModule.super.initModule(self)
    self._view = ChargeShareView.new(self.parent)

    self:addEventHandler()
end

function ChargeShareModule:addEventHandler()
    self._view:addEventListener(ChargeShareEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(ChargeShareEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    -- self._view:addEventListener(ChargeShareEvent.GET_PKG_REWARD, self, self.sendGetRewardReq)

    self._view:addEventListener(ChargeShareEvent.UPDATE_PKG_NUM, self, self.updatePkgNum)

    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_PKG_INFO, self, self.onGetPkgInfo)
    self:addProxyEventListener(GameProxys.Activity, AppEvent.PROXY_GET_REWARD, self, self.onGetReward)
    -- self:addEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230006, self, self.onGetReward)
end

function ChargeShareModule:removeEventHander()
    self._view:removeEventListener(ChargeShareEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(ChargeShareEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    -- self._view:removeEventListener(ChargeShareEvent.GET_PKG_REWARD, self, self.sendGetRewardReq)
    -- AppEvent.PROXY_GET_REWARD
    self._view:removeEventListener(ChargeShareEvent.UPDATE_PKG_NUM, self, self.updatePkgNum)

    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_PKG_INFO, self, self.onGetPkgInfo)
    self:removeProxyEventListener(GameProxys.Activity, AppEvent.PROXY_GET_REWARD, self, self.onGetReward)


    -- self:removeEventListener(AppEvent.NET_M23, AppEvent.NET_M23_C230006, self, self.onGetReward)

end

function ChargeShareModule:updatePkgNum(data)
    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20200, {})
end

function ChargeShareModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function ChargeShareModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function ChargeShareModule:onGetPkgInfo(data)
    self._view:saveData(data)
end

function ChargeShareModule:sendGetRewardReq(data)
    local sendData = {}
    sendData["moduleId"] = AppEvent.NET_M23 --协议大类
    sendData["cmdId"]    = AppEvent.NET_M23_C230006 --子协议
    sendData["obj"]      = data --发送的数据
    self:sendNotification("net_event", "net_send_data", sendData)
end

function ChargeShareModule:onGetReward(data)
    if data.result == 0 then
        self._view:removeItem()
    end
end