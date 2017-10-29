
ChargeShareView = class("ChargeShareView", BasicView)

function ChargeShareView:ctor(parent)
    ChargeShareView.super.ctor(self, parent)
    self.chargeInfo = {}
end

function ChargeShareView:finalize()
    ChargeShareView.super.finalize(self)
end

function ChargeShareView:registerPanels()
    ChargeShareView.super.registerPanels(self)

    require("modules.chargeShare.panel.ChargeSharePanel")
    self:registerPanel(ChargeSharePanel.NAME, ChargeSharePanel)

    require("modules.chargeShare.panel.ActDescPanel")
    self:registerPanel(ActDescPanel.NAME, ActDescPanel)

    require("modules.chargeShare.panel.GetRewardPanel")
    self:registerPanel(GetRewardPanel.NAME, GetRewardPanel)
end

function ChargeShareView:initView()
    local panel = self:getPanel(ChargeSharePanel.NAME)
    panel:show()
end

function ChargeShareView:saveData(data)
    local panel = self:getPanel(GetRewardPanel.NAME)
    panel:initView(data)
    local mPanel = self:getPanel(ChargeSharePanel.NAME)
    mPanel:updateRad()
end

function ChargeShareView:removeItem()
   local panel = self:getPanel(GetRewardPanel.NAME)
   panel:removeItem() 
end

-- function ChargeShareView:onShowView(msg, isInit, isAutoUpdate)
--     ChargeShareView.super.onShowView(self, msg, isInit, false)

--     local panel = self:getPanel(ChargeSharePanel.NAME)
--     panel:show()
-- end