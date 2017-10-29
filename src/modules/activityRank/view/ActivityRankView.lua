
ActivityRankView = class("ActivityRankView", BasicView)

function ActivityRankView:ctor(parent)
    ActivityRankView.super.ctor(self, parent)
end

function ActivityRankView:finalize()
    ActivityRankView.super.finalize(self)
end

function ActivityRankView:registerPanels()
    ActivityRankView.super.registerPanels(self)

    require("modules.activityRank.panel.ActivityRankPanel")
    self:registerPanel(ActivityRankPanel.NAME, ActivityRankPanel)

end

function ActivityRankView:initView()
    -- local panel = self:getPanel(ActivityRankPanel.NAME)
    -- panel:show()
end

function ActivityRankView:onShowView(msg, isInit, isAutoUpdate)
    ActivityRankView.super.onShowView(self, msg, isInit, false)

    local panel = self:getPanel(ActivityRankPanel.NAME)
    panel:show()
end

function ActivityRankView:updateView(data)
    local panel = self:getPanel(ActivityRankPanel.NAME)
    panel:updateView(data)
end

function ActivityRankView:onPlayerInfoResp(data)
    local panel = self:getPanel(ActivityRankPanel.NAME)
    panel:onPlayerInfoResp(data)
end