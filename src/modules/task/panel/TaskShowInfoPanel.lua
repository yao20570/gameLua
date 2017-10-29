-- 战功任务弹窗描述
TaskShowInfoPanel = class("TaskShowInfoPanel",BasicPanel)
TaskShowInfoPanel.NAME = "TaskShowInfoPanel"

function TaskShowInfoPanel:ctor(view, panelName)
    TaskShowInfoPanel.super.ctor(self, view, panelName, 320)
    
    self:setUseNewPanelBg(true)
end

function TaskShowInfoPanel:initPanel()
    self.bgImg = self:getChildByName("mainPanel/bgImg")
    self.sureBtn = self:getChildByName("mainPanel/sureBtn")
    self.taskDiscribLab = self:getChildByName("mainPanel/taskDiscribLab")
    self.iconImg = self:getChildByName("mainPanel/iconImg")
    self.mainPanel = self:getChildByName("mainPanel")
    self:initEvent()
    self:setTitle(true, self:getTextWord(1342))
end

function TaskShowInfoPanel:initEvent()
    ComponentUtils:addTouchEventListener(self.sureBtn, self.onSureBtnTouch, nil, self)
end

function TaskShowInfoPanel:onSureBtnTouch()
    local info = self.info
    local moduleName = info.jumpmodule
    local panelName = info.reaches
    
    if moduleName == ModuleName.RegionModule then --跳转到战役，等战役打开了再关闭任务模块
        local data = {}
        data.moduleName = moduleName
        data["extraMsg"] = {}
        data["extraMsg"]["panelName"] = panelName
        self:dispatchEvent(TaskEvent.SHOW_OTHER_EVENT,data)
        self:hide()   
    else
        ModuleJumpManager:jump(moduleName, panelName)
        self:hide()
        self:dispatchEvent(TaskEvent.HIDE_SELF_EVENT, {})
    end

end



function TaskShowInfoPanel:updateInfos(info,finishTimes,iconInfo) 
    -- self.callfunc = callfunc
    self.info = info 
    self.taskDiscribLab:setString(info.info)
    local rickLabel = self.taskDiscribLab.rickLabel
    if rickLabel == nil then
        rickLabel = ComponentUtils:createRichLabel("", nil, nil, 2)
        self.taskDiscribLab:addChild(rickLabel)
        self.taskDiscribLab.rickLabel = rickLabel
        rickLabel:setPosition(0,-6)
    end

    local curColor = ColorUtils.wordGreenColor16
    if finishTimes < info.finishcond2 then
        curColor = ColorUtils.wordRedColor16
    end

    local fontsize = 20
    local info = {{{self:getTextWord(1337), fontsize,ColorUtils.wordColorDark1601},{finishTimes, fontsize, curColor}, {"/"..info.finishcond2, fontsize, ColorUtils.wordWhiteColor16}}}
    rickLabel:setString(info)
    local icon = self.iconImg.icon
    if icon == nil then
        icon = UIIcon.new(self.iconImg,iconInfo,false)
        self.iconImg.icon = icon 
    else
        icon:updateData(iconInfo)
    end

end
