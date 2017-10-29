                                
PartsWarehouseView = class("PartsWarehouseView", BasicView)

function PartsWarehouseView:ctor(parent)
    PartsWarehouseView.super.ctor(self, parent)
end

function PartsWarehouseView:finalize()
    PartsWarehouseView.super.finalize(self)
end

function PartsWarehouseView:onShowView(extraMsg, isInit, isAutoUpdate)
    isInit = true
    isAutoUpdate = true
    PartsWarehouseView.super.onShowView(self,extraMsg, isInit,isAutoUpdate)
end

function PartsWarehouseView:registerPanels()
    PartsWarehouseView.super.registerPanels(self)

    require("modules.partsWarehouse.panel.PartsWarehousePanel")
    self:registerPanel(PartsWarehousePanel.NAME, PartsWarehousePanel)
    
    require("modules.partsWarehouse.panel.PWPartsPanel")
    self:registerPanel(PWPartsPanel.NAME, PWPartsPanel)

    require("modules.partsWarehouse.panel.PWPiecePanel")
    self:registerPanel(PWPiecePanel.NAME, PWPiecePanel)

    require("modules.partsWarehouse.panel.PWMaterialPanel")
    self:registerPanel(PWMaterialPanel.NAME, PWMaterialPanel)
    
    require("modules.partsWarehouse.panel.PWBatchSelectPanel")
    self:registerPanel(PWBatchSelectPanel.NAME, PWBatchSelectPanel)

    require("modules.partsWarehouse.panel.PWExchangePanel")
    self:registerPanel(PWExchangePanel.NAME, PWExchangePanel)
end

function PartsWarehouseView:initView()
    local panel = self:getPanel(PartsWarehousePanel.NAME)
    panel:show()
end
--

function PartsWarehouseView:onUpdateSparExchange(data)
    local panel = self:getPanel(PWExchangePanel.NAME)
    panel:updateSparExchangeView(data)
end
--更新
function PartsWarehouseView:updatePartsListView(data)
    local panel = self:getPanel(PWPartsPanel.NAME)
    panel:onShowHandler()
end 
function PartsWarehouseView:updatePieceListView(data)
    local panel = self:getPanel(PWPiecePanel.NAME)
    panel:updateListView(data)
end
function PartsWarehouseView:updateMaterialListView(data)
    local panel = self:getPanel(PWMaterialPanel.NAME)
    panel:updateListView(data)
end
--关闭系统
function PartsWarehouseView:onCloseView()
    PartsWarehouseView.super.onCloseView(self)
end
--打开系统