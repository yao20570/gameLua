
MailPanel = class("MailPanel", BasicPanel)
MailPanel.NAME = "MailPanel"
--[3],true) -- 接受
--[2],true) -- 发送
--[4],true) -- 报告
--[1],true) -- 系统
function MailPanel:ctor(view, panelName)
    MailPanel.super.ctor(self, view, panelName, true)
    
    self:setUseNewPanelBg(true)
end

function MailPanel:finalize()
    MailPanel.super.finalize(self)
end

function MailPanel:initPanel()
	MailPanel.super.initPanel(self)
    self._mailAllPanel = self:getPanel(MailAllPanel.NAME)
    self._mailReportPanel = self:getPanel(MailReportPanel.NAME)
    self:addTabControl()
end

function MailPanel:addTabControl()
    self._tabControl = UITabControl.new(self, self.tabCallBack)
    self._tabControl:addTabPanel(MailReportPanel.NAME, self:getTextWord(1221))

    -- 总邮件
    self._tabControl:addTabPanel(MailAllPanel.NAME, self:getTextWord(1219))

    -- 邮件总收藏
    self._tabControl:addTabPanel(MailCollectPanel.NAME, self:getTextWord(1103))
    self._tabControl:setTabSelectByName(MailReportPanel.NAME)

    self:setTitle(true,"youjian",true)
    self:setBgType(ModulePanelBgType.NONE)
end

function MailPanel:onClosePanelHandler()
    self.view:hideModuleHandler()
end
-- 邮件主
function MailPanel:onOpenModule(data)
    self.actionPanel = self:getPanel(MailActionPanel.NAME) -- 底下按钮条
    self._target = nil
    print(data[3],data[2],data[4],data[1])
    self:updateTab2Count(data[3] + data[2] + data[1])
    self:update3Count(data[3],true) -- 接受
    self:update2Count(data[2],true) -- 发送
    self:update4Count(data[4],true) -- 报告
    self:update1Count(data[1],true) -- 系统
    if self._target == nil then
        self._tabControl:changeTabSelectByName(MailReportPanel.NAME)
    end
end

-- 接收邮件
function MailPanel:update3Count(data,flag)
    local panelType = 3 -- 接收邮件类型为3
    if data > 0 then
        --- 
        self._mailAllPanel:updateRedDot(panelType, true, data)
        ---
        self._target = true
        if flag == true then
            self._tabControl:changeTabSelectByName(MailAllPanel.NAME) -- 显示则切换至总邮件
            self._mailAllPanel:updateCurListView()
            self.actionPanel:updateCount(panelType)
        end
    else
        self._mailAllPanel:updateRedDot(panelType, false, 0)
    end
end

-- 发送邮件
function MailPanel:update2Count(data,flag)
    local panelType = 2 -- 发送邮件类型为2
    if data > 0 then
        --- 
        self._mailAllPanel:updateRedDot(panelType, true, data)
        ---
        if self._target == nil then
            self._target = true
            if flag == true then
                self._tabControl:changeTabSelectByName(MailAllPanel.NAME) -- 显示则切换至总邮件
                self._mailAllPanel:updateCurListView()
                self.actionPanel:updateCount(panelType)
            end 
        end
    else
        self._mailAllPanel:updateRedDot(panelType, false, 0)
    end
end

-- 系统邮件
function MailPanel:update1Count(data,flag)
    local panelType = 1 -- 系统邮件类型为1
    if data > 0 then
        --- 
        self._mailAllPanel:updateRedDot(panelType, true, data)
        ---
        if self._target == nil then
            self._target = true
            if flag == true then
                self._tabControl:changeTabSelectByName(MailAllPanel.NAME) -- 显示则切换至总邮件
                self._mailAllPanel:updateCurListView()
                self.actionPanel:updateCount(panelType)
            end
        end
    else
        self._mailAllPanel:updateRedDot(panelType, false, 0)
    end
end


-- 报告红点
function MailPanel:update4Count(data,flag)
    local reportItemIndex = 1 -- 标签1
    if data > 0 then
        self._tabControl:setItemCount(1,true,data)
        self._mailReportPanel:updateRedDot()
        if self._target == nil then
            self._target = true
            if flag == true then
                self._tabControl:setTabSelectByName(MailReportPanel.NAME)
                local panel = self:getPanel(MailReportPanel.NAME)
                print("~~~~~~~~~", self.view.isShow)
                panel:updateListData()
                self.actionPanel:updateCount(panel._type) -- 村数据
            end
        end
    else
        self._tabControl:setItemCount(1,false,0)
        self._mailReportPanel:updateRedDot()
    end
end


-- 接收发送邮件
function MailPanel:onSendResp()
    self._tabControl:setTabSelectByName(MailAllPanel.NAME)
    local panel = self:getPanel(MailAllPanel.NAME)
    if panel:isVisible() then
        panel:onShowHandler()
    end
end

function MailPanel:getCurrentTable()
    return self._tabControl
end

------
-- 刷新第二个标签的红点
function MailPanel:updateTab2Count(count)
    if count == 0 then
        self._tabControl:setItemCount(2,false,count)
    else
        self._tabControl:setItemCount(2,true,count)
    end
end

------
-- 执行切换后的回调函数
function MailPanel:tabCallBack(panelName)
    --print("页面切换成功"..panelName)
    local actionPanel = self:getPanel(MailActionPanel.NAME)
    actionPanel:setReadCount()


    return true
end

function MailPanel:tabChangeMainPanelEvent()
    MailPanel.super.tabChangeMainPanelEvent(self) -- link

    local curPanelName = self._tabControl:getCurPanelName()
    local mailActionPanel = self:getPanel(MailActionPanel.NAME)
    if curPanelName ~= MailAllPanel.NAME then-- 4-战法
        mailActionPanel:setGetAllBtnVisible(false)
    end
end
