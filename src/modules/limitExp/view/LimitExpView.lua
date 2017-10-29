
LimitExpView = class("LimitExpView", BasicView)

function LimitExpView:ctor(parent)
    LimitExpView.super.ctor(self, parent)
end

function LimitExpView:finalize()
    LimitExpView.super.finalize(self)
end

function LimitExpView:registerPanels()
    LimitExpView.super.registerPanels(self)

    require("modules.limitExp.panel.LimitExpPanel")
    self:registerPanel(LimitExpPanel.NAME, LimitExpPanel)

    require("modules.limitExp.panel.limitExpCityPanel")
    self:registerPanel(limitExpCityPanel.NAME, limitExpCityPanel)

    require("modules.limitExp.panel.LimitExpRankPanel")
    self:registerPanel(LimitExpRankPanel.NAME, LimitExpRankPanel)

    require("modules.limitExp.panel.LimitExpReplayPanel")
    self:registerPanel(LimitExpReplayPanel.NAME, LimitExpReplayPanel)

    require("modules.limitExp.panel.LimitExpRewardPanel")
    self:registerPanel(LimitExpRewardPanel.NAME, LimitExpRewardPanel)

    require("modules.limitExp.panel.LimitExpSweepRewardPanel")
    self:registerPanel(LimitExpSweepRewardPanel.NAME, LimitExpSweepRewardPanel)
end

function LimitExpView:initView()
    local panel = self:getPanel(LimitExpPanel.NAME)
    panel:show()
end

function LimitExpView:onLimitInfosResp(data, flag)
    local panel = self:getPanel(LimitExpPanel.NAME)
    if panel:isVisible() then
        panel:onLimitInfosResp(data, flag)
    end
end

-- function LimitExpView:onFlushLimitInfosResp(data)
-- 	local panel = self:getPanel(LimitExpPanel.NAME)
--     if panel:isVisible() then
--         panel:onFlushLimitInfosResp(data)
--     end
-- end


function LimitExpView:updateNoSeeChatNum(num)
    local panel = self:getPanel(LimitExpPanel.NAME)
    if panel:isVisible() == true then
        panel:updateNoSeeChatNum(num)
    end
end

function LimitExpView:onStopRewardResp(data)
    local panel = self:getPanel(LimitExpPanel.NAME)
    panel:onStopRewardResp(data)
end

function LimitExpView:onSetMask()
    local panel = self:getPanel(LimitExpPanel.NAME)
    local layout = panel:getChildByName("mask")
    if layout ~= nil then
        layout:setVisible(false)
    end
end

function LimitExpView:onFightingResp()
    local panel = self:getPanel(LimitExpPanel.NAME)
    if panel:isVisible() then
        panel:onFightingResp()
    end
end

function LimitExpView:hideModuleHandler()
    self:dispatchEvent(LimitExpEvent.HIDE_SELF_EVENT)
end


function LimitExpView:onShowSweepRewardResp(data)
    local panel = self:getPanel(LimitExpSweepRewardPanel.NAME)
    panel:show(data)
end