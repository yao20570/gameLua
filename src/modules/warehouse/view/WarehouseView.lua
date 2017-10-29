
WarehouseView = class("WarehouseView", BasicView)

function WarehouseView:ctor(parent)
    WarehouseView.super.ctor(self, parent)
end

function WarehouseView:finalize()
    WarehouseView.super.finalize(self)
end

function WarehouseView:registerPanels()
    WarehouseView.super.registerPanels(self)

    require("modules.warehouse.panel.WarehousePanel")
    self:registerPanel(WarehousePanel.NAME, WarehousePanel)

end

function WarehouseView:initView()
    local panel = self:getPanel(WarehousePanel.NAME)
    panel:show()
end

function WarehouseView:hideModuleHandler()
    self:dispatchEvent(WarehouseEvent.HIDE_SELF_EVENT, {})
end

function WarehouseView:onWarehouseListInfo()
	-- body
	local panel = self:getPanel(WarehousePanel.NAME)
	panel:onWarehouseListInfo()

end

function WarehouseView:onItemReq(data)
	-- body
	self:dispatchEvent(WarehouseEvent.Item_Use_Req,data)
end

function WarehouseView:onItemBufferUpdate()
    -- body
    local panel = self:getPanel(WarehousePanel.NAME)
    if panel:isVisible() then
        panel:onItemBufferUpdate()
    end
end


