
EquipModule = class("EquipModule", BasicModule)

function EquipModule:ctor()
    EquipModule .super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    --self._isFirstOpen = true
    self:initRequire()
end

function EquipModule:initRequire()
    require("modules.equip.event.EquipEvent")
    require("modules.equip.view.EquipView")
end

function EquipModule:finalize()
    EquipModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function EquipModule:initModule()
    EquipModule.super.initModule(self)
    self._view = EquipView.new(self.parent)
    self._equipProxy = self:getProxy(GameProxys.Equip)
    self:addEventHandler()
end

function EquipModule:addEventHandler()
    self._view:addEventListener(EquipEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(EquipEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:addProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_All_EQUIPS, self, self.onUpdateAllEquips)
    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_ALL_HERO, self, self.onUpdateAllhero)

    self._view:addEventListener(EquipEvent.POS_EXCHANGE_REQ, self, self.onPosExchangeHandler)

    self._view:addEventListener(EquipEvent.UP_EQUIP_REQ, self, self.onUpEquipReqHandler)
    self:addEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130001, self, self.onUpEquipResp)

    self._view:addEventListener(EquipEvent.WEAR_EQUIP_REQ, self, self.onWearReqHandler)
    self:addEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130002, self, self.onWearEquipResp)

    self._view:addEventListener(EquipEvent.PUTOFF_EQUIP_REQ, self, self.onExitEquipReqHandler)
    self:addEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130003, self, self.onExitEquipResp)

    self._view:addEventListener(EquipEvent.EQUIP_SALE_REQ, self, self.onEquipSaleReqHandler)
    self:addEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130005, self, self.onEquipSaleResp)

    self._view:addEventListener(EquipEvent.BIG_HOUSE_REQ, self, self.onEquipBigReqHandler)
    self:addEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130007, self, self.onEquipBigResp)

    self._view:addEventListener(EquipEvent.GOTO_INSTANCE, self, self.onGotoInstanceHandler)

    self._view:addEventListener(EquipEvent.GOTO_LOTTERY_MODULE, self, self.onGotoLotterHandler)
    self._view:addEventListener(EquipEvent.GENGXIN_RAD_COUNT, self, self.gengxinRad)
    self._view:addEventListener(EquipEvent.CHANGGE_HERO, self, self.changgeHero)
    self._view:addEventListener(EquipEvent.LV_UP_HERO, self, self.lvUpHero)

    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_EQUIP_MAINVIEW, self, self.updateView)

    self:addProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_TOUCH_STATE, self, self.updateTouchState)

end

function EquipModule:removeEventHander()
    self._view:removeEventListener(EquipEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(EquipEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)

    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_GET_ROLE_INFO, self, self.onGetRoleInfo)
    self:removeProxyEventListener(GameProxys.Role, AppEvent.PROXY_UPDATE_ROLE_INFO, self, self.onGetRoleInfo)

    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_All_EQUIPS, self, self.onUpdateAllEquips)
    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_ALL_HERO, self, self.onUpdateAllhero)

    self._view:removeEventListener(EquipEvent.UP_EQUIP_REQ, self, self.onUpEquipReqHandler)
    self:removeEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130001, self, self.onUpEquipResp)

    self._view:removeEventListener(EquipEvent.POS_EXCHANGE_REQ, self, self.onPosExchangeHandler)
    self:removeEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130002, self, self.onWearEquipResp)

    self._view:removeEventListener(EquipEvent.PUTOFF_EQUIP_REQ, self, self.onExitEquipReqHandler)
    self:removeEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130003, self, self.onExitEquipResp)

    self._view:removeEventListener(EquipEvent.EQUIP_SALE_REQ, self, self.onEquipSaleReqHandler)
    self:removeEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130005, self, self.onEquipSaleResp)

    self._view:removeEventListener(EquipEvent.BIG_HOUSE_REQ, self, self.onEquipBigReqHandler)
    self:removeEventListener(AppEvent.NET_M13, AppEvent.NET_M13_C130007, self, self.onEquipBigResp)

    self._view:removeEventListener(EquipEvent.GOTO_INSTANCE, self, self.onGotoInstanceHandler)

    self._view:removeEventListener(EquipEvent.GOTO_LOTTERY_MODULE, self, self.onGotoLotterHandler)
    self._view:removeEventListener(EquipEvent.GENGXIN_RAD_COUNT, self, self.gengxinRad)
    self._view:removeEventListener(EquipEvent.CHANGGE_HERO, self, self.changgeHero)
    self._view:removeEventListener(EquipEvent.LV_UP_HERO, self, self.lvUpHero)

    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_EQUIP_MAINVIEW, self, self.updateView)

    self:removeProxyEventListener(GameProxys.Equip, AppEvent.PROXY_UPDATE_TOUCH_STATE, self, self.updateTouchState)

end

function EquipModule:updateTouchState()
    self._view:updateTouchState()
end

function EquipModule:updateView()
    self._view:updateView()
end

function EquipModule:onOpenModule()
    EquipModule.super.onOpenModule(self)
    --self:onGetRoleInfo(true)
end

function EquipModule:onUpdateAllEquips()
    self._view:onUpdateAllEquips(self._currWearType)
    self._currWearType = nil
    self._equipProxy:onUpdateFightByEquip()
end

function EquipModule:onUpdateAllhero()
    self._view:onUpdateAllhero()
end

function EquipModule:gengxinRad()
    self:sendNotification(AppEvent.UPDATE_RAD, AppEvent.UP_RAD_COUNT)
end

function EquipModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
    --local proxy = self:getProxy(GameProxys.Soldier)
    --proxy:setMapFightAddEquip()
end

function EquipModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName})
end

function EquipModule:onGetRoleInfo(flag)
    -- local proxy = self:getProxy(GameProxys.Role)
    -- local level = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)  --指挥官等级
    -- --if self._level ~= level then
    --     --self._level = level
    --     self._view:updateLevel({level = level,flag = flag})  --指挥官等级的改变，导致开放的坑位数目发生改变
    --end
end

function EquipModule:onPosExchangeHandler(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130006, data)
end

function EquipModule:onWearReqHandler(data)
    self._currWearType = data.type  --1一次穿一个  2一键穿戴
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130002, data)
end

function EquipModule:onWearEquipResp(data)
    --self._equipProxy:updateAllEquips(data.equipinfos)
    --self._equipProxy:onUpdateFightByEquip()
    if data.rs == 0 then
        self._view:wearResp(self._currWearType)
    end
end

function EquipModule:onExitEquipReqHandler(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130003, data)
end

function EquipModule:onExitEquipResp(data)
    --self._equipProxy:updateAllEquips(data.equipinfos)
    if data.rs == 0 then
        self._view:exitWearResp()
    end
    --self._equipProxy:onUpdateFightByEquip()
end

function EquipModule:onEquipSaleReqHandler(data)
    self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130005, data)
end

function EquipModule:onEquipSaleResp(data)
    self._equipProxy:onSoldierMofidyResp(data)
    if data.rs == 0 then
        self._view:equipSaleResp()
    end
end

function EquipModule:onUpEquipReqHandler(data)
	self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130001, data)
end

function EquipModule:onUpEquipResp(data)
	--self._equipProxy:updateAllEquips(data.equipinfos)
	if data.rs == 0 then
        self._view:onUpEquipResp(data)
        self:showSysMessage(self:getTextWord(754)) --升级成功 飘字
    end
    --self._equipProxy:onUpdateFightByEquip()
end

function EquipModule:onEquipBigReqHandler()
	self:sendServerMessage(AppEvent.NET_M13, AppEvent.NET_M13_C130007, {})
end

function EquipModule:onEquipBigResp(data)
	if data.rs == 0 then
		self._view:onIncreaseResp(data.count)
	end
end

function EquipModule:onGotoInstanceHandler()
    self:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.TeamModule})
    local data = {}
    data.moduleName = ModuleName.InstanceModule
    data.extraMsg = 2
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function EquipModule:onGotoLotterHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = ModuleName.LotteryEquipModule})
end

function EquipModule:changgeHero(data)
    self:sendServerMessage(AppEvent.NET_M29, AppEvent.NET_M29_C290001, data)
end

function EquipModule:lvUpHero(data)
    self:sendServerMessage(AppEvent.NET_M29, AppEvent.NET_M29_C290003, data)
end