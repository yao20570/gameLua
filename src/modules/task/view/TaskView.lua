
TaskView = class("TaskView", BasicView)

function TaskView:ctor(parent)
    TaskView.super.ctor(self, parent)
end

function TaskView:finalize()
    TaskView.super.finalize(self)
end

function TaskView:registerPanels()
    TaskView.super.registerPanels(self)

    require("modules.task.panel.TaskPanel")
    self:registerPanel(TaskPanel.NAME, TaskPanel)

    require("modules.task.panel.MainTaskPanel")
    self:registerPanel(MainTaskPanel.NAME, MainTaskPanel)

    -- require("modules.task.panel.DailyTaskPanel")
    -- self:registerPanel(DailyTaskPanel.NAME, DailyTaskPanel)

    -- require("modules.task.panel.ActiveTaskPanel")   
    -- self:registerPanel(ActiveTaskPanel.NAME, ActiveTaskPanel)

    require("modules.task.panel.TaskRewardPanel")   
    self:registerPanel(TaskRewardPanel.NAME, TaskRewardPanel)

    -- require("modules.task.panel.TaskRewardPreviewPanel")    
    -- self:registerPanel(TaskRewardPreviewPanel.NAME, TaskRewardPreviewPanel)

    require("modules.task.panel.TaskExploitPanel")	
    self:registerPanel(TaskExploitPanel.NAME, TaskExploitPanel)

    require("modules.task.panel.TaskShowInfoPanel")
    self:registerPanel(TaskShowInfoPanel.NAME, TaskShowInfoPanel)
    
    -- require("modules.task.panel.TaskShowGoodsPanel")
    -- self:registerPanel(TaskShowGoodsPanel.NAME, TaskShowGoodsPanel)

end

function TaskView:initView()
    local panel = self:getPanel(TaskPanel.NAME)
    panel:show()
end

function TaskView:setFirstPanelShow()
    local panel = self:getPanel(TaskPanel.NAME)
    panel:setFirstPanelShow()
end

function TaskView:openTipView(info)
    local panel = self:getPanel(TaskRewardPanel.NAME)
    panel:show(info)
end

function TaskView:openTipPreView()
    local panel = self:getPanel(TaskRewardPreviewPanel.NAME)
    panel:show()
end
---------------------------------------------------------------------
--dispatch event

function TaskView:hideModuleHandler()
    self:dispatchEvent(TaskEvent.HIDE_SELF_EVENT, {})
end

---------------------------------------------------------------------
--on event resp
function TaskView:onUpdateTaskInfoResp(data)
    -- body
    local panel = self:getPanel(TaskPanel.NAME)
    panel:onUpdateTaskInfoResp()
    panel:onUpdateCount()

    panel = self:getPanel(TaskExploitPanel.NAME)
    panel:refreshPanel()
end

--更新小红点
function TaskView:onUpdateCount()
    -- body
    local panel = self:getPanel(TaskPanel.NAME)
    panel:onUpdateCount()
end

--------------------------------------------------------------------
-- 重写onShowView(),用于每次打开panel都执行onShowHandler()
function TaskView:onShowView(extraMsg, isInit)
    TaskView.super.onShowView(self,extraMsg, isInit, true)
end

function TaskView:exploitHasget()
    local panel = self:getPanel(TaskExploitPanel.NAME)
    panel:refreshPanel()
    self:onUpdateCount()  
end
