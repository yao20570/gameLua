
LotteryEquipModule = class("LotteryEquipModule", BasicModule)

function LotteryEquipModule:ctor()
    LotteryEquipModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    self:initRequire()
end

function LotteryEquipModule:initRequire()
    require("modules.lotteryEquip.event.LotteryEquipEvent")
    require("modules.lotteryEquip.view.LotteryEquipView")
end

function LotteryEquipModule:finalize()
    LotteryEquipModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function LotteryEquipModule:initModule()
    LotteryEquipModule.super.initModule(self)
    self._firstOpen = true
    self._view = LotteryEquipView.new(self.parent)
--    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_4)
    self:addEventHandler()
end

function LotteryEquipModule:addEventHandler()
    self._view:addEventListener(LotteryEquipEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(LotteryEquipEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.Lottery,AppEvent.PROXY_LOTTERY_INFOS_CHANGE, self, self.onGetLotteryInfoResp)
    self:addProxyEventListener(GameProxys.Lottery,AppEvent.PROXY_BUY_LOTTERY, self, self.onChooseResp)

    self._view:addEventListener(LotteryEquipEvent.OPEN_EQUIP_MODULE, self, self.onLookEquipHandler)
end

function LotteryEquipModule:removeEventHander()
    self._view:removeEventListener(LotteryEquipEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(LotteryEquipEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.Lottery,AppEvent.PROXY_LOTTERY_INFOS_CHANGE, self, self.onGetLotteryInfoResp)
    self:removeProxyEventListener(GameProxys.Lottery,AppEvent.PROXY_BUY_LOTTERY, self, self.onChooseResp)

    self._view:removeEventListener(LotteryEquipEvent.OPEN_EQUIP_MODULE, self, self.onLookEquipHandler)
end

function LotteryEquipModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function LotteryEquipModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function LotteryEquipModule:onOpenModule()
    LotteryEquipModule.super.onOpenModule(self)
    self:refreshInfos()
end

function LotteryEquipModule:refreshInfos()
    --self:sendServerMessage(AppEvent.NET_M15, AppEvent.NET_M15_C150000, {})
    self:onGetLotteryInfoResp()
    self:onGetRoleInfo()
end

function LotteryEquipModule:onGetLotteryInfoResp()
    --if data.rs == 0 then
        --print("onGetLotteryInfoResp")
        self._view:onGetLotteryInfoResp(self._firstOpen)
        self._firstOpen = false
   --end
end

function LotteryEquipModule:onGetRoleInfo()
    local proxy = self:getProxy(GameProxys.Role)
    local gold = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)
    self._view:onUpdateGold(StringUtils:formatNumberByK(gold))
end

function LotteryEquipModule:onChooseReqHandler(data)
    self:sendServerMessage(AppEvent.NET_M15, AppEvent.NET_M15_C150001, data)
end

function LotteryEquipModule:onChooseResp(data)
    if data.rs == 0 then
        self._view:onChooseResp(data)
    end
end

function LotteryEquipModule:onLookEquipHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.EquipModule})
end