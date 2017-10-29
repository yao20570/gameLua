
PullBarActivityView = class("PullBarActivityView", BasicView)

function PullBarActivityView:ctor(parent)
    PullBarActivityView.super.ctor(self, parent)
end

function PullBarActivityView:finalize()
    PullBarActivityView.super.finalize(self)
end

function PullBarActivityView:registerPanels()
    PullBarActivityView.super.registerPanels(self)

    require("modules.pullBarActivity.panel.PullBarActivityPanel")
    self:registerPanel(PullBarActivityPanel.NAME, PullBarActivityPanel)

    require("modules.pullBarActivity.panel.PullBarInfo")
    self:registerPanel(PullBarInfo.NAME, PullBarInfo)

    require("modules.pullBarActivity.panel.PullBarRewardPanel")
    self:registerPanel(PullBarRewardPanel.NAME, PullBarRewardPanel)
end

function PullBarActivityView:initView()
    -- local panel = self:getPanel(PullBarActivityPanel.NAME)
    -- panel:show()
end

function PullBarActivityView:updateLabaInfo(data)

	local panel = self:getPanel(PullBarActivityPanel.NAME)
    if data == nil then
        panel:fail()
        return
    end
    panel:updateInfo(data)
end

function PullBarActivityView:onShowView(extraMsg, isInit, isAutoUpdate)
    PullBarActivityView.super.onShowView(self,extraMsg, isInit, false)
    local panel = self:getPanel(PullBarActivityPanel.NAME)
    panel:show()
end