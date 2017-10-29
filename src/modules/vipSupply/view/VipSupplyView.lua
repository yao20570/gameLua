
VipSupplyView = class("VipSupplyView", BasicView)

function VipSupplyView:ctor(parent)
    VipSupplyView.super.ctor(self, parent)
end

function VipSupplyView:finalize()
    VipSupplyView.super.finalize(self)
end

function VipSupplyView:registerPanels()
    VipSupplyView.super.registerPanels(self)

    require("modules.vipSupply.panel.VipSupplyPanel")
    self:registerPanel(VipSupplyPanel.NAME, VipSupplyPanel)
end

function VipSupplyView:initView()
    
end

function VipSupplyView:onShowView(extraMsg, isInit, isAutoUpdate)
	VipSupplyView.super.onShowView(self, extraMsg, isInit, isAutoUpdate)
	local panel = self:getPanel(VipSupplyPanel.NAME)
    panel:show()
end

function VipSupplyView:updateVipSupply()
	local panel = self:getPanel(VipSupplyPanel.NAME)
    panel:renderPanel()
end

function VipSupplyView:onTimeComplete()
	local panel = self:getPanel(VipSupplyPanel.NAME)
    if panel:isVisible() then
    	self:showSysMessage( self:getTextWord(249992) )
        panel:hide()

    end
end