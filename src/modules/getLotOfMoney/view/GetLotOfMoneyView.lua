
GetLotOfMoneyView = class("GetLotOfMoneyView", BasicView)

function GetLotOfMoneyView:ctor(parent)
    GetLotOfMoneyView.super.ctor(self, parent)
end

function GetLotOfMoneyView:finalize()
    GetLotOfMoneyView.super.finalize(self)
end

function GetLotOfMoneyView:registerPanels()
    GetLotOfMoneyView.super.registerPanels(self)

    require("modules.getLotOfMoney.panel.GetLotOfMoneyPanel")
    self:registerPanel(GetLotOfMoneyPanel.NAME, GetLotOfMoneyPanel)

    require("modules.getLotOfMoney.panel.GetLotOfMoneyLotteryPanel") --博彩界面
    self:registerPanel(GetLotOfMoneyLotteryPanel.NAME,GetLotOfMoneyLotteryPanel)

    require("modules.getLotOfMoney.panel.GetLotOfMoneyExchangePanel") --兑换界面
    self:registerPanel(GetLotOfMoneyExchangePanel.NAME,GetLotOfMoneyExchangePanel)
end

function GetLotOfMoneyView:initView()
    local panel = self:getPanel(GetLotOfMoneyPanel.NAME)
    panel:show()
    -- local panel_ex = self:getPanel(LotteryPanel.NAME)
    -- panel_ex:show()
end

function GetLotOfMoneyView:onShowView(extraMsg, isInit, isAutoUpdate)
	GetLotOfMoneyView.super.onShowView(self, extraMsg, isInit, true)
end

function GetLotOfMoneyView:setCurrentActivityId(activityId)
    local panel = self:getPanel(GetLotOfMoneyPanel.NAME)
    panel:setCurrentActivityId(activityId)
end

function GetLotOfMoneyView:onItemUpdate()
    local panel = self:getPanel(GetLotOfMoneyPanel.NAME)
    panel:updateMoney()
end

function GetLotOfMoneyView:activityInfoUpdate()
    local panel = self:getPanel(GetLotOfMoneyPanel.NAME)
    panel:activityInfoUpdate()
end 