
PartsModule = class("PartsModule", BasicModule)

function PartsModule:ctor()
    PartsModule .super.ctor(self)
    
    self._view = nil
    self._loginData = nil
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self:initRequire()
end

function PartsModule:initRequire()
    require("modules.parts.event.PartsEvent")
    require("modules.parts.view.PartsView")
end

function PartsModule:finalize()
    PartsModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function PartsModule:initModule()
    PartsModule.super.initModule(self)
    self._view = PartsView.new(self.parent)
    
    --获取配件和碎片信息请求
    --self:partsAndPieceInfosReq()
--    self:setLocalZOrder(ModuleLayer.UI_Z_ORDER_2)
    self:addEventHandler()
end

-- function PartsModule:partsAndPieceInfosReq()
--     local partsProxy = self:getProxy(GameProxys.Parts)
--     local data = {}
--     partsProxy:ordnanceInfosReq(data) --请求配件数据
--     partsProxy:pieceInfosReq(data)  --请求碎片数据
-- end 

function PartsModule:addEventHandler()
    self._view:addEventListener(PartsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(PartsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(PartsEvent.PARTS_EVENT_UPDATE_RAD, self, self.gengxinRad)
    self:addProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_EQUIP_PARTS, self, self.onEquipPartsRes)
    --self:addProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_PAGEVIEW, self, self.onUpdatePageView)
    self:addProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_WHNUM, self, self.onUpdateWarehouseNum)
    --self:addProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_PAGEENABLE, self, self.onUpdatePageEnable)
    self:addProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_PARTSENABLE, self, self.onUpdatePartsEnable)
    
    self:addProxyEventListener(GameProxys.Parts,AppEvent.PARTS_NUM_ADD_UPDATE, self, self.updateOnInit)  -- 获得军械/分解军械
    self:addProxyEventListener(GameProxys.Parts,AppEvent.PARTS_EQUIP_IN_HOUSE, self, self.updateOnInit)  -- 仓库穿戴回调

end

function PartsModule:removeEventHander()
    self._view:removeEventListener(PartsEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(PartsEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(PartsEvent.PARTS_EVENT_UPDATE_RAD, self, self.gengxinRad)
    self:removeProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_EQUIP_PARTS, self, self.onEquipPartsRes)
    --self:removeProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_PAGEVIEW, self, self.onUpdatePageView)
    self:removeProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_WHNUM, self, self.onUpdateWarehouseNum)
    --self:removeProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_PAGEENABLE, self, self.onUpdatePageEnable)
    self:removeProxyEventListener(GameProxys.Parts,PartsEvent.PARTS_EVENT_UPDATE_PARTSENABLE, self, self.onUpdatePartsEnable)
    self:removeProxyEventListener(GameProxys.Parts,AppEvent.PARTS_NUM_ADD_UPDATE, self, self.updateOnInit)  -- 获得军械/分解军械
    self:removeProxyEventListener(GameProxys.Parts,AppEvent.PARTS_EQUIP_IN_HOUSE, self, self.updateOnInit)  -- 仓库穿戴回调

end

function PartsModule:gengxinRad()
    self:sendNotification(AppEvent.UPDATE_RAD, AppEvent.UP_RAD_COUNT)
end

function PartsModule:onHideSelfHandler()
    local panel = self:getPanel(PartsMainPanel.NAME)
    
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})

end

function PartsModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

-- 接收到服务端数据，更新当前页面
function PartsModule:onEquipPartsRes(data)
    -- TODO，强化、改造、进阶、只有在位置上的才回调更新
    local data = data
    local mainPanel = self._view:getPanel(PartsMainPanel.NAME)
    mainPanel:updatePageShowHadler(data)
end 

function PartsModule:onUpdatePageView(data)
    local mainPanel = self._view:getPanel(PartsMainPanel.NAME)
    mainPanel:updatePageView(data)
end 

function PartsModule:onUpdateWarehouseNum(data)
    local mainPanel = self._view:getPanel(PartsMainPanel.NAME)
    mainPanel:updateWarehouseNum(data)
end 
function PartsModule:onUpdatePageEnable(data)
    local mainPanel = self._view:getPanel(PartsMainPanel.NAME)
    --mainPanel:updateAdjacentEnableCount(data)
end 
function PartsModule:onUpdatePartsEnable(data)
    local mainPanel = self._view:getPanel(PartsMainPanel.NAME)
    ---mainPanel:updatePageShowHadler()
end 

------
-- 增加/减少军械数量
function PartsModule:updateOnInit()
    local mainPanel = self._view:getPanel(PartsMainPanel.NAME)
    mainPanel:onInitAllPage()
end