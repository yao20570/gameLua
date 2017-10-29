
BagModule = class("BagModule", BasicModule)
function BagModule:ctor()
    BagModule.super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.isFullScreen = true
    
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self:initRequire()
end
function BagModule:initRequire()
    require("modules.bag.event.BagEvent")
    require("modules.bag.view.BagView")
end
function BagModule:finalize()
    BagModule.super.finalize(self)
    logger:info("-------销毁-背包模块---------")
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end
function BagModule:initModule()
    BagModule.super.initModule(self)
    logger:info("-------初始化-背包模块-------")
    BagModule.super.initModule(self)
    self._view = BagView.new(self.parent)
    self:addEventHandler()
end
function BagModule:addEventHandler()
    self._view:addEventListener(BagEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(BagEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    
    self._view:addEventListener(BagEvent.ITEM_USE, self, self.onItemUseReq)
    self._view:addEventListener(BagEvent.SURFACEGOODSUSE_REQ, self, self.onSurfaceReq)
    self._view:addEventListener(BagEvent.CHANGEPOINTGOODSUSE_REQ, self, self.onChagePointReq)
    self._view:addEventListener(BagEvent.LEGIONCONTRIBUTEGOODSUSE_REQ, self, self.useLegionContributeReq)
    
    --点击item使用相关
    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdate)
    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_UPDATE,self,self.onItemUse)
    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_SURFACEGOODSUSE,self,self.onSurfaceResp) --外观道具回应
    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_CHANGEPOINT,self,self.onGetChangePointResp) --随机迁城
    self:addProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_CHANGEPOINT,self,self.useLegionContributeResp) --随机迁城
end

function BagModule:removeEventHander()
    self._view:removeEventListener(BagEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(BagEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
   
    self._view:removeEventListener(BagEvent.ITEM_USE, self, self.onItemUseReq)
    self._view:removeEventListener(BagEvent.SURFACEGOODSUSE_REQ, self, self.onSurfaceReq)
    self._view:removeEventListener(BagEvent.CHANGEPOINTGOODSUSE_REQ, self, self.onChagePointReq)
    self._view:removeEventListener(BagEvent.LEGIONCONTRIBUTEGOODSUSE_REQ, self, self.useLegionContributeReq)
    
    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_ITEMINFO_UPDATE, self, self.onItemUpdate)
    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_UPDATE,self,self.onItemUse)
    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_SURFACEGOODSUSE,self,self.onSurfaceResp)
    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_CHANGEPOINT,self,self.onGetChangePointResp)
    self:removeProxyEventListener(GameProxys.Item, AppEvent.PROXY_BAG_CHANGEPOINT,self,self.useLegionContributeResp)
end

function BagModule:onOpenModule()
    BagModule.super.onOpenModule(self)
end


function BagModule:onItemUpdate()
   self._view:onItemUpdate()
end

function BagModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function BagModule:onShowOtherHandler(data)
    if data.moduleName == ModuleName.MapModule then
        self:sendNotification(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, 
            {tileX = data.extraMsg.tileX, tileY = data.extraMsg.tileY})
    end
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function BagModule:onItemUse(data)
    if data.rs == 0 then
        self._view:onGetUseResp(data)
    end
end

function BagModule:onItemUseReq(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:onTriggerNet90001Req(data)
end
function BagModule:onSurfaceReq(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:onTriggerNet90001Req(data)
end
function BagModule:onSurfaceResp(data)
    self._view:useSurfaceGoods(data)
end
function BagModule:onChagePointReq(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:onTriggerNet80011Req(data)
end
function BagModule:onGetChangePointResp(sender)
    if sender.rs == -2 then return end
    local data = {}
    data.moduleName = ModuleName.MapModule
    data.extraMsg = {}
    data.extraMsg.tileX = sender.x
    data.extraMsg.tileY = sender.y
    -- self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = ModuleName.MainSceneModule})
    -- self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_CLOSE_EVENT,{moduleName = ModuleName.LegionModule})
    -- self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_CLOSE_EVENT,{moduleName = ModuleName.LegionSceneModule})
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:sendNotification(AppEvent.PROXY_BAG_OPENMAP, data)
    self:onShowOtherHandler(data)
    self:onHideSelfHandler()
end

function BagModule:useLegionContributeReq(data)
    local itemProxy = self:getProxy(GameProxys.Item)
    itemProxy:onTriggerNet90007Req(data)
end

function BagModule:useLegionContributeResp(data)
    if data.rs == 0 then
        self:showSysMessage(self:getTextWord(4026))
    end
end