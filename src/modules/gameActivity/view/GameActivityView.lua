
GameActivityView = class("GameActivityView", BasicView)

function GameActivityView:ctor(parent)
    GameActivityView.super.ctor(self, parent)
end

function GameActivityView:finalize()
    GameActivityView.super.finalize(self)
end

function GameActivityView:registerPanels()
    GameActivityView.super.registerPanels(self)

    require("modules.gameActivity.panel.GameActivityPanel")
    self:registerPanel(GameActivityPanel.NAME, GameActivityPanel)

    require("modules.gameActivity.panel.ActivityTwoPanel")
    self:registerPanel(ActivityTwoPanel.NAME, ActivityTwoPanel)

    require("modules.gameActivity.panel.ActivityFourPanel")
    self:registerPanel(ActivityFourPanel.NAME, ActivityFourPanel)

    require("modules.gameActivity.panel.ActivityOnePanel")
    self:registerPanel(ActivityOnePanel.NAME, ActivityOnePanel)

    require("modules.gameActivity.panel.ActivityThreePanel")
    self:registerPanel(ActivityThreePanel.NAME, ActivityThreePanel)

    require("modules.gameActivity.panel.ActivityFivePanel")
    self:registerPanel(ActivityFivePanel.NAME, ActivityFivePanel)

    require("modules.gameActivity.panel.ActivitySixPanel")
    self:registerPanel(ActivitySixPanel.NAME,ActivitySixPanel)
end

function GameActivityView:initView()
end

function GameActivityView:onShowView(msg, isInit, isAutoUpdate)
    GameActivityView.super.onShowView(self, msg, isInit, false)
    local panel = self:getPanel(GameActivityPanel.NAME)
    panel:show(msg)
end

function GameActivityView:onUpdateOnceData(data)
    local panel = self:getPanel(GameActivityPanel.NAME)
    panel:onUpdateOnceData(data)
end

function GameActivityView:onUpdateAllData(data)
    local panel = self:getPanel(GameActivityPanel.NAME)
    panel:onUpdateAllData()
end
function GameActivityView:onOpenSDKWeekCard(data)
    local panel = self:getPanel(GameActivityPanel.NAME)
    panel:onOpenSDKWeekCard(data)
end
function GameActivityView:onWeekCardUpdate(data)
    local panel = self:getPanel(GameActivityPanel.NAME)
    panel:onWeekCardUpdate(data)
end


