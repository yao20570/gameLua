
TaskPanel = class("TaskPanel", BasicPanel)
TaskPanel.NAME = "TaskPanel"

function TaskPanel:ctor(view, panelName)
    TaskPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function TaskPanel:finalize()
    TaskPanel.super.finalize(self)
end

function TaskPanel:initPanel()
	TaskPanel.super.initPanel(self)
    self:addTabControl()
    self._isFirstToOpenTask = true
end

function TaskPanel:addTabControl()
    local tabControl = UITabControl.new(self,self.isUnlockExploit)
    tabControl:addTabPanel(MainTaskPanel.NAME, self:getTextWord(1301))
    -- tabControl:addTabPanel(DailyTaskPanel.NAME, self:getTextWord(1302)) --屏蔽日常任务
    tabControl:addTabPanel(TaskExploitPanel.NAME, self:getTextWord(13031))
    -- tabControl:setTabSelectByName(MainTaskPanel.NAME)

    self._tabControl = tabControl
    self:setTitle(true,"task",true)
    
	self:setBgType(ModulePanelBgType.NONE)

    self:updateTabName()
end


-- 切换标签判定，是否已开启战功
-- newPanelName : 切换到标签页
-- oldPanelName : 切换前标签页
function TaskPanel:isUnlockExploit(newPanelName,oldPanelName)
    -- print("切换判定 ***** newPanelName,oldPanelName",newPanelName,oldPanelName)

    if TaskExploitPanel.NAME == newPanelName then
        -- print("切换到标签页...0")
        local RoleProxy = self:getProxy(GameProxys.Role)
        local isLock = RoleProxy:isFunctionUnLock(10)
        if isLock == false then
            local panel = self:getPanel(TaskExploitPanel.NAME)
            if panel:isVisible() then
                panel:hide()
            end
        end
        return isLock
    end

    return true
end

function TaskPanel:resetTabSelectByName(name)
end

function TaskPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end

function TaskPanel:onUpdateTaskInfoResp()
    -- body
    local curPanelName = self._tabControl:getCurPanelName()
    local panel = self:getPanel(curPanelName)
    panel:onShowHandler()
    self:onUpdateCount()
end

function TaskPanel:setFirstPanelShow()
    -- local panel = self:getPanel(MainTaskPanel.NAME)
    -- self._tabControl:setTabSelectByName(MainTaskPanel.NAME)
    self:updateTabName()

    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkTaskRedPoint()
end


-- 更新小红点显示
function TaskPanel:onUpdateCount()
    local taskProxy = self:getProxy(GameProxys.Task)
    local tabData = {}
    local count = 0

    -- 标签页：主线/支线任务    
    -- tabData = taskProxy:getMainTaskList2() --主线任务数据
    -- for k,v in pairs(tabData) do
    --     if v.state == 1 then
    --         count = count + 1
    --     end
    --     self._tabControl:setItemCount(1,true,count)
    -- end
    count = taskProxy:getCont1()
    self._tabControl:setItemCount(1,true,count)

    -- 标签页：战功
    -- tabData = taskProxy:getDailyStatus() --日常任务状态
    count = taskProxy:getCont2()
    if not self.notFirstOpen  then
        self.notFirstOpen = true
    end
    if count < 0 then count = 0 end
    --战功任务未开启，不显示小红点
    local RoleProxy = self:getProxy(GameProxys.Role)
    local isUnLock = RoleProxy:isFunctionUnLock(10, false)
    if not isUnLock then
        count = 0
    end
    self._tabControl:setItemCount(2,true,count)


    -- 标签页：活跃任务
    -- local count = 0
    -- local state = taskProxy:getActiveState() --活跃任务领取状态
    -- local activeMaxID = taskProxy:getActiveMaxID() or 0

    -- if activeMaxID == 5 then --活跃奖励已领取完毕
    --     count = 0
    -- else
    --     if self._isFirstToOpenTask then
    --         count = 1       
    --         self._isFirstToOpenTask = false
    --     elseif state then
    --         count = 1
    --     end
    -- end

    -- self._tabControl:setItemCount(3,true,count)

end

-- 获取数据
function TaskPanel:getTaskData()
    local taskProxy = self:getProxy(GameProxys.Task)
    local tabData,_ = taskProxy:getMainTaskList2() --真实数据
    local curTaskTypeState = self:getCurTaskTypeState(tabData) -- 获取当前任务类型状态

    return tabData,curTaskTypeState
end

-- 获取当前任务类型状态，0都有，1只有主线，2只有支线
function TaskPanel:getCurTaskTypeState(tabData) 
    local stateType = 0
    if #tabData == 1 then
        stateType = tabData[1][1].tasktype 
    end
    return stateType
end

function TaskPanel:updateTabName()
    local tabData,curTaskTypeState = self:getTaskData()
    -- 没有任务数据，隐藏任务标签
    if tabData == nil or #tabData == 0 then
        self._tabControl:setTabVisibleByIndex(1,false)
        self._tabControl:setTabVisibleByIndex(2,true)
        self._tabControl:setTabSelectByName(TaskExploitPanel.NAME)
        self._tabControl:updateItemPosX()
        return
    end

    self._tabControl:setTabVisibleByIndex(1,true)
    self._tabControl:setTabVisibleByIndex(2,true)
    self._tabControl:setTabSelectByName(MainTaskPanel.NAME)
    self._tabControl:updateItemPosX()


    local tabName = 1301   --主线任务
    if curTaskTypeState == 2 then
        tabName = 1341     --支线任务
    end
    self._tabControl:updateTabName(MainTaskPanel.NAME, self:getTextWord(tabName))
end