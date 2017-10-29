
LegionTaskView = class("LegionTaskView", BasicView)

function LegionTaskView:ctor(parent)
    LegionTaskView.super.ctor(self, parent)
end

function LegionTaskView:finalize()
    LegionTaskView.super.finalize(self)
end

function LegionTaskView:registerPanels()
    LegionTaskView.super.registerPanels(self)

    require("modules.legionTask.panel.LegionTaskPanel")
    self:registerPanel(LegionTaskPanel.NAME, LegionTaskPanel)
    require("modules.legionTask.panel.LegionTaskListPanel")
    self:registerPanel(LegionTaskListPanel.NAME, LegionTaskListPanel)
    require("modules.legionTask.panel.LegionTaskPerformancePanel")
    self:registerPanel(LegionTaskPerformancePanel.NAME, LegionTaskPerformancePanel)
end

function LegionTaskView:hideModuleHandler()
    self:dispatchEvent(LegionTaskEvent.HIDE_SELF_EVENT, {})
end

function LegionTaskView:onShowView(extraMsg, isInit, isAutoUpdate)
    LegionTaskView.super.onShowView(self, extraMsg, isInit, true)
end 

function LegionTaskView:initView()
    local panel = self:getPanel(LegionTaskPanel.NAME)
    panel:show()
end

function LegionTaskView:updateLegionTaskInfo()
    local panel = self:getPanel(LegionTaskPanel.NAME)
    panel:updateLegionTaskInfo()
end 