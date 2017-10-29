
TaskModule = class("TaskModule", BasicModule)

function TaskModule:ctor()
    TaskModule .super.ctor(self)
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName =ModuleLayer.UI_3_LAYER
    self.showActionType = ModuleShowType.LEFT
    self._view = nil
    self._loginData = nil
    
    self:initRequire()
end

function TaskModule:initRequire()
    require("modules.task.event.TaskEvent")
    require("modules.task.view.TaskView")
end

function TaskModule:finalize()
    TaskModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function TaskModule:initModule()
    TaskModule.super.initModule(self)
    self._view = TaskView.new(self.parent)
    self._taskProxy = self:getProxy(GameProxys.Task)
    self:addEventHandler()
end

function TaskModule:addEventHandler()
    self._view:addEventListener(TaskEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(TaskEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:addProxyEventListener(GameProxys.Task, AppEvent.PROXY_TASK_INFO_UPDATE, self, self.onUpdateTaskInfoResp)
    self:addEventListener(AppEvent.NET_M19, AppEvent.NET_M19_C190004, self, self.exploitHasget)
end

function TaskModule:removeEventHander()
    self._view:removeEventListener(TaskEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(TaskEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self:removeProxyEventListener(GameProxys.Task, AppEvent.PROXY_TASK_INFO_UPDATE, self, self.onUpdateTaskInfoResp)
    self:removeEventListener(AppEvent.NET_M19, AppEvent.NET_M19_C190004, self, self.exploitHasget)
end

function TaskModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
end

function TaskModule:onShowOtherHandler(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

-- 每次从onShowOtherHandler过来都走这条
function TaskModule:onOpenModule()
    TaskModule.super.onOpenModule(self)
    self._view:setFirstPanelShow()
    self._view:onUpdateCount()
end

-------------------------------------------------------------------------------
--msg resp
function TaskModule:onUpdateTaskInfoResp(data)
    -- body
    self._view:onUpdateTaskInfoResp(data)
end

function TaskModule:exploitHasget(data)
    --返回-3代表领取过，刷一下界面
   if data.rs == 0 or data.rs == -3 then
        local taskProxy = self:getProxy(GameProxys.Task)
        taskProxy:addExploitHasget(data.id)
        self._view:exploitHasget()
   end
end