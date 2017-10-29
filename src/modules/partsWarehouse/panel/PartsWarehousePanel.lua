PartsWarehousePanel = class("PartsWarehousePanel", BasicPanel)
PartsWarehousePanel.NAME = "PartsWarehousePanel"

function PartsWarehousePanel:ctor(view, panelName)
    PartsWarehousePanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function PartsWarehousePanel:finalize()
    PartsWarehousePanel.super.finalize(self)
end

function PartsWarehousePanel:initPanel()
	PartsWarehousePanel.super.initPanel(self)
	self:addTabControl()
end

function PartsWarehousePanel:addTabControl()
    self._tabControl = UITabControl.new(self)
    self._tabControl:addTabPanel(PWPartsPanel.NAME, self:getTextWord(8201))
    self._tabControl:addTabPanel(PWPiecePanel.NAME, self:getTextWord(8202))
    self._tabControl:addTabPanel(PWMaterialPanel.NAME, self:getTextWord(8203))
    self._tabControl:addTabPanel(PWExchangePanel.NAME, self:getTextWord(8238))
    self._tabControl:setTabSelectByName(PWPartsPanel.NAME)
    -- self:setTitle(true, self:getTextWord(8204))
    self:setTitle(true, "partsWarehouse", true)

    
end

--发送关闭系统消息
function PartsWarehousePanel:onClosePanelHandler()
    if self.view._close then
        return
    end
    self.view._close = true
    self.view:dispatchEvent(PartsWarehouseEvent.HIDE_SELF_EVENT)
end

