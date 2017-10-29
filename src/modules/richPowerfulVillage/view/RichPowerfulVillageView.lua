
RichPowerfulVillageView = class("RichPowerfulVillageView", BasicView)

function RichPowerfulVillageView:ctor(parent)
    RichPowerfulVillageView.super.ctor(self, parent)
end

function RichPowerfulVillageView:finalize()
    RichPowerfulVillageView.super.finalize(self)
end

function RichPowerfulVillageView:registerPanels()
    RichPowerfulVillageView.super.registerPanels(self)

    require("modules.richPowerfulVillage.panel.RichPowerfulVillagePanel")
    self:registerPanel(RichPowerfulVillagePanel.NAME, RichPowerfulVillagePanel)

    require("modules.richPowerfulVillage.panel.OpenningPanel")
    self:registerPanel(OpenningPanel.NAME, OpenningPanel)

    require("modules.richPowerfulVillage.panel.ExchangePanel")
    self:registerPanel(ExchangePanel.NAME, ExchangePanel)

    require("modules.richPowerfulVillage.panel.BuyPanel")
    self:registerPanel(BuyPanel.NAME, BuyPanel)
    
end

function RichPowerfulVillageView:initView()
    local panel = self:getPanel(RichPowerfulVillagePanel.NAME)
    panel:show()
end

function RichPowerfulVillageView:onItemUpdate()
	local panel = self:getPanel(RichPowerfulVillagePanel.NAME)
    panel:onItemUpdate()
end

function RichPowerfulVillageView:startOrChangeResp(param)
	local panel = self:getPanel(RichPowerfulVillagePanel.NAME)
    panel:startOrChangeResp(param)
end

function RichPowerfulVillageView:confirmResultResp(param)
	local panel = self:getPanel(RichPowerfulVillagePanel.NAME)
    panel:confirmResultResp(param)
end 

function RichPowerfulVillageView:exchangeItemResp(param)
	local panel = self:getPanel(RichPowerfulVillagePanel.NAME)
    panel:exchangeItemResp(param)
end

function RichPowerfulVillageView:onUpdateRoleInfo()
	local panel = self:getPanel(RichPowerfulVillagePanel.NAME)
	panel:onUpdateGold()
end  

