-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
GetLotOfMoneyModule = class("GetLotOfMoneyModule", BasicModule)

function GetLotOfMoneyModule:ctor()
    GetLotOfMoneyModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil

    self.activityId = nil

    self:initRequire()
end

function GetLotOfMoneyModule:initRequire()
    require("modules.getLotOfMoney.event.GetLotOfMoneyEvent")
    require("modules.getLotOfMoney.view.GetLotOfMoneyView")
end

function GetLotOfMoneyModule:finalize()
    GetLotOfMoneyModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function GetLotOfMoneyModule:initModule()
    GetLotOfMoneyModule.super.initModule(self)
    self._view = GetLotOfMoneyView.new(self.parent)

    self:addEventHandler()
end

function GetLotOfMoneyModule:addEventHandler()
    self._view:addEventListener(GetLotOfMoneyEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(GetLotOfMoneyEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdate)
    self:addProxyEventListener(GameProxys.Activity,AppEvent.PROXY_GETLOTOFMONEY_UPDATE,self,self.activityInfoUpdate)
end

function GetLotOfMoneyModule:removeEventHander()
    self._view:removeEventListener(GetLotOfMoneyEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(GetLotOfMoneyEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdate)
    self:removeProxyEventListener(GameProxys.Activity,AppEvent.PROXY_GETLOTOFMONEY_UPDATE,self,self.activityInfoUpdate)
end

function GetLotOfMoneyModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function GetLotOfMoneyModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function GetLotOfMoneyModule:onOpenModule(extraMsg, isPerLoad)
    if extraMsg and type(extraMsg) == "table" then
        if extraMsg.activityId then
            self.activityId = extraMsg.activityId
            self._view:setCurrentActivityId(self.activityId)
        end
    end
end

function GetLotOfMoneyModule:onItemUpdate()
    self._view:onItemUpdate()
end

function GetLotOfMoneyModule:activityInfoUpdate()
    self._view:activityInfoUpdate()
end 