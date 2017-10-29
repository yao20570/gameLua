-- 主线任务
MainTaskPanel = class("MainTaskPanel", BasicPanel)
MainTaskPanel.NAME = "MainTaskPanel"


function MainTaskPanel:ctor(view, panelName)
    MainTaskPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MainTaskPanel:finalize()
    MainTaskPanel.super.finalize(self)
end

function MainTaskPanel:initPanel()
	MainTaskPanel.super.initPanel(self)
    
    self._mainTask = 1           --主线任务
    self._extensionTask = 2      --支线任务

    self._conf = ConfigDataManager:getConfigData(ConfigData.MainMissionConfig)
    self._taskProxy = self:getProxy(GameProxys.Task)
end

function MainTaskPanel:registerEvents()
    self._uilistview    = self:getChildByName("ListView_1")  -- 支线的listView
    self._mainTaskPanel = self:getChildByName("mainTaskPanel") -- 主线层
    self._uilistview    :setVisible(false)
    self._mainTaskPanel :setVisible(false)

end

function MainTaskPanel:doLayout()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView( self._mainTaskPanel, self._uilistview, GlobalConfig.downHeight, tabsPanel, 0)
end

function MainTaskPanel:onAfterActionHandler()
    self._uilistview    :setVisible(true)
    self._mainTaskPanel :setVisible(true)
    self:onShowHandler()
end

function MainTaskPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end

    local tabData,titleData = self:getTaskData()
    self._tabData   = tabData   -- 任务数据
    self._titleData = titleData -- 标题显示数据

    -- 没有任务数据OR全部任务已完成,什么都不显示
    if tabData == nil or #tabData == 0 or self._curTaskTypeState == 99 then
        self:finishAllTask()
        return
    end

    -- 设置主线任务
    self:setMainTaskPanel(self._tabData)

    -- 设置支线任务
    self:renderExtensionTask(self._tabData)
end

-- 没有主线任务了
function MainTaskPanel:finishMainTask()
    local titlePanel01 = self._mainTaskPanel:getChildByName("titlePanel01") -- 主线
    local titlePanel02 = self._mainTaskPanel:getChildByName("titlePanel02") -- 支线
    local labTitle = titlePanel01:getChildByName("labTitle")
    labTitle:setString(self:getTextWord(1341))
    titlePanel01:setVisible(true)
    titlePanel02:setVisible(false)

    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView( titlePanel01, self._uilistview, GlobalConfig.downHeight, tabsPanel, 0)
end

-- 没有任务了OR全部任务已完成,什么都不显示
function MainTaskPanel:finishAllTask()
    local titlePanel01 = self._mainTaskPanel:getChildByName("titlePanel01") -- 主线
    local titlePanel02 = self._mainTaskPanel:getChildByName("titlePanel02") -- 支线
    local itemPanel = self._mainTaskPanel:getChildByName("itemPanel")
    titlePanel01:setVisible(false)
    titlePanel02:setVisible(false)
    itemPanel:setVisible(false)
    self._uilistview:setVisible(false)
end

-- 获取数据
function MainTaskPanel:getTaskData()
    local tabData,titleData = self._taskProxy:getMainTaskList2() --真实数据
    self._curTaskTypeState = self:getCurTaskTypeState(tabData) -- 获取当前任务类型状态

    return tabData,titleData
end

-- 获取当前任务类型状态，0都有，1只有主线，2只有支线，99沒有任务
function MainTaskPanel:getCurTaskTypeState(tabData) 
    local stateType = 0
    if tabData == nil or #tabData == 0 then
        stateType = 99
    elseif #tabData == 1 then
        stateType = tabData[1][1].tasktype
    end
    return stateType
end


-- 设置主线任务
function MainTaskPanel:setMainTaskPanel(tabData)
    local titlePanel01 = self._mainTaskPanel:getChildByName("titlePanel01") -- 主线
    local titlePanel02 = self._mainTaskPanel:getChildByName("titlePanel02") -- 支线

    if self._curTaskTypeState == 1 then
        titlePanel02:setVisible(false)
    else
        titlePanel02:setVisible(true)
    end

    -- 数据
    local info = nil 
    if self._curTaskTypeState ~= 2 then
        info = tabData[self._mainTask][self._mainTask]
    end

    local itemPanel = self._mainTaskPanel:getChildByName("itemPanel")
    -- 渲染
    if info ~= nil then
        self:onRenderItem(itemPanel, info)
        itemPanel:setVisible(true)
    else
        itemPanel:setVisible(false)        
        -- 没有任务数据，隐藏分类标题
        self:finishMainTask()
    end
end


-- 设置支线任务
function MainTaskPanel:renderExtensionTask(tabData)
    local listData = {} 

    if self._curTaskTypeState == 0 then
        listData = tabData[self._extensionTask]
    elseif self._curTaskTypeState == 2 then
        listData = tabData[1]
    end

    self:renderListView( self._uilistview, listData, self, self.onRenderItem, nil, nil, 6)
end


function MainTaskPanel:onRenderItem(itempanel, info)
	-- body
	itempanel:setVisible(true)
    
    local name = itempanel:getChildByName("name")
    local process = itempanel:getChildByName("process")
    local processL = itempanel:getChildByName("processL")
    local processR = itempanel:getChildByName("processR")
    local tipBtn = itempanel:getChildByName("tipBtn")
    local goBtn = itempanel:getChildByName("goBtn")
    local rewardBtn = itempanel:getChildByName("rewardBtn")

    local conf = self._conf[info.typeId]
    local iconInfo = {}
    iconInfo.power = GamePowerConfig.Other
    iconInfo.typeid = conf.icon
    iconInfo.num = 0

    local icon = itempanel.icon
    if icon == nil then
        local iconImg = itempanel:getChildByName("icon")
        icon = UIIcon.new(iconImg,iconInfo,false)        
        itempanel.icon = icon
    else
        icon:updateData(iconInfo)
    end
    icon:setTouchEnabled(false)


    name:setString(conf.name)

    local size = name:getContentSize()
    local x = name:getPositionX()
    tipBtn:setPositionX(x + size.width + 20)

    local curNum = tonumber(info.num)
    local maxNum = conf.finishcond2
    local color = nil
    if curNum >= maxNum then
        curNum = maxNum
        color = ColorUtils.wordColorDark03
    else
        color = ColorUtils.wordColorDark04
    end
    process:setColor(color)


    local processStr = ""
    local stype = conf.stype
    if stype == 10 or stype == 46 or stype == 47 or stype == 38 or stype == 5 or stype == 41 or stype == 68 then  --任务小类 显示格式 进度：未完成/已完成
        local str = ""
        if curNum < maxNum then
            str = self:getTextWord(1329)
        else
            str = self:getTextWord(1330)
        end
        process:setString(str)
        processR:setString("")

    else  --显示格式（进度：xx/xx）
        processStr = string.format(self:getTextWord(1315), curNum, maxNum) -- " 进度：%d/%d"
        process:setString(curNum)
        processR:setString("/"..maxNum)

        local posx = process:getPositionX()
        local size = process:getContentSize()
        local x = posx + size.width
        processR:setPositionX(x)
    end

    -- 前往与领取按钮状态设置
    if info.state == 0 then
        rewardBtn:setVisible(false)
        goBtn:setVisible(true)
        goBtn:setTitleText(self:getTextWord(1307))
        info.jumpmodule = conf.jumpmodule
        info.reaches = conf.reaches
        info.guideID = conf.guideID
        info.conf = conf
        goBtn.info = info
        self:addTouchEventListener(goBtn,self.onGoBtn)
    elseif info.state == 1 then
        goBtn:setVisible(false)
        rewardBtn:setVisible(true)
        rewardBtn:setTitleText(self:getTextWord(1318))
        rewardBtn.info = info
        self:addTouchEventListener(rewardBtn,self.onRewardBtn, nil, nil, 800)
        self["rewardBtn" .. 1] = rewardBtn --新手引导。直接写死 第一次 第一个可领取
    end
    
    tipBtn.info = info
    tipBtn.conf = conf
    self:addTouchEventListener(tipBtn,self.onTipBtn)

    itempanel.info = info
    itempanel.conf = conf
    self:addTouchEventListener(itempanel,self.onTipBtn)
end

---------------------------------------------------------------------
--button touch event 前往按钮
function MainTaskPanel:onGoBtn(sender)
    local info = sender.info
    local conf = info.conf
    local taskProxy = self:getProxy(GameProxys.Task)
    if conf.guideID then
        -- print("前往引导 guideID="..conf.guideID)

        -- 关闭任务模块
        self:dispatchEvent(TaskEvent.SHOW_OTHER_EVENT, { moduleName = ModuleName.MainSceneModule } )
        self:dispatchEvent(TaskEvent.SHOW_OTHER_EVENT, { moduleName = ModuleName.RoleInfoModule } )
        self:dispatchEvent(TaskEvent.HIDE_SELF_EVENT, {})

        if conf.guideID == 105 then --引导特殊的副本任务，设置引导关卡信息
            taskProxy:setGuideDungeonInfo(conf.finishcond1)
        end
        
        GuideManager:trigger(conf.guideID, true)

    elseif conf.jumpmodule then
        -- print("前往 conf.jumpmodule="..conf.jumpmodule)
        taskProxy:setBarrackRecruitGuide(info)

        local moduleName = info.jumpmodule
        local panelName = info.reaches    
        ModuleJumpManager:jump(moduleName, panelName)
        
        -- 关闭任务模块
        self:dispatchEvent(TaskEvent.HIDE_SELF_EVENT, {})
    else
        self:showSysMessage(self:getTextWord(1336))
    end

end

function MainTaskPanel:onRewardBtn(sender)
    -- body
    local info = sender.info
    local data = {}
    data.tableType = info.tableType
    data.typeId = info.typeId
    self._taskProxy:onTriggerNet190001Req(data)

end

function MainTaskPanel:onTipBtn(sender)
    -- body
    local info = sender.info
    info.conf = sender.conf
    info.type = 0
    info.TASKTYPE = 0
    self.view:openTipView(info)
end

function MainTaskPanel:onUpdateTaskInfoResp(data)
    -- body
end


