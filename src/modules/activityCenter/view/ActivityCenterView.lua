
ActivityCenterView = class("ActivityCenterView", BasicView)

function ActivityCenterView:ctor(parent)
    ActivityCenterView.super.ctor(self, parent)
end

function ActivityCenterView:finalize()
    ActivityCenterView.super.finalize(self)
end

function ActivityCenterView:registerPanels()
    ActivityCenterView.super.registerPanels(self)

    require("modules.activityCenter.panel.ActivityCenterPanel")
    self:registerPanel(ActivityCenterPanel.NAME, ActivityCenterPanel)

    require("modules.activityCenter.panel.ActivityFirstPanel")
    self:registerPanel(ActivityFirstPanel.NAME, ActivityFirstPanel)

    require("modules.activityCenter.panel.ActivitySecondPanel")
    self:registerPanel(ActivitySecondPanel.NAME, ActivitySecondPanel)
end

function ActivityCenterView:updateBlurSprite()
    local panel = self:getPanel(ActivityCenterPanel.NAME)
    panel:updateBlurSprite()
end

function ActivityCenterView:initView()
    local panel = self:getPanel(ActivityCenterPanel.NAME)
    panel:show()
end

function ActivityCenterView:onShowView(extraMsg, isInit, isAutoUpdate)
	ActivityCenterView.super.onShowView(self, extraMsg, isInit, isAutoUpdate)
	local panel = self:getPanel(ActivityCenterPanel.NAME)
    panel:show()
end

function ActivityCenterView:updateActCount(param)
    -- 这个可能会导致灯笼的增删
    local panel = self:getPanel(ActivityCenterPanel.NAME)
    panel:updateDenglongUI()

    local panel = self:getPanel(ActivityFirstPanel.NAME)
    panel:updateInfo(param)
end

function ActivityCenterView:newBattleActivity()
    local panel = self:getPanel(ActivitySecondPanel.NAME)
    if panel:isVisible() and panel:isInitUI() then
        panel:onShowHandler()
    end
end

function ActivityCenterView:updateRedPoint()
    local panel = self:getPanel(ActivityCenterPanel.NAME)
    panel:updateRedPoint()
    panel = self:getPanel(ActivityFirstPanel.NAME)
    panel:updateInfo()
    panel = self:getPanel(ActivitySecondPanel.NAME)
    panel:updateInfo()
end

function ActivityCenterView:onOpenwarlords()
    local panel = self:getPanel(ActivitySecondPanel.NAME)
    panel:onOpenwarlords()
end