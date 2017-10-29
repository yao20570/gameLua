
CornucopiaView = class("CornucopiaView", BasicView)

function CornucopiaView:ctor(parent)
    CornucopiaView.super.ctor(self, parent)
end

function CornucopiaView:finalize()
    CornucopiaView.super.finalize(self)
end

function CornucopiaView:registerPanels()
    CornucopiaView.super.registerPanels(self)

    require("modules.cornucopia.panel.CornucopiaPanel")
    self:registerPanel(CornucopiaPanel.NAME, CornucopiaPanel)
end

function CornucopiaView:initView()
    local panel = self:getPanel(CornucopiaPanel.NAME)
    panel:show()
end

function CornucopiaView:setCurrentActivityId(activityId)
	local panel = self:getPanel(CornucopiaPanel.NAME)
    panel:setCurrentActivityId(activityId)
end

function CornucopiaView:activityInfoUpdate()
	local panel = self:getPanel(CornucopiaPanel.NAME)
	panel:activityInfoUpdate()
end

function CornucopiaView:onShowView(extraMsg, isInit, isAutoUpdate)
    CornucopiaView.super.onShowView(self, extraMsg, isInit, true)
end 