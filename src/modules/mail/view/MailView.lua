
MailView = class("MailView", BasicView)

function MailView:ctor(parent)
    MailView.super.ctor(self, parent)
end

function MailView:finalize()
    MailView.super.finalize(self)
end

function MailView:registerPanels()
    MailView.super.registerPanels(self)

    require("modules.mail.panel.MailPanel")
    self:registerPanel(MailPanel.NAME, MailPanel)
    
    require("modules.mail.panel.MailReportPanel")
    self:registerPanel(MailReportPanel.NAME, MailReportPanel)
    
    
    require("modules.mail.panel.MailActionPanel")
    self:registerPanel(MailActionPanel.NAME, MailActionPanel)
    
    require("modules.mail.panel.MailDetailPanel")
    self:registerPanel(MailDetailPanel.NAME, MailDetailPanel)

    require("modules.mail.panel.MailReportInfoPanel")
    self:registerPanel(MailReportInfoPanel.NAME, MailReportInfoPanel)
    
    require("modules.mail.panel.MailSelectFriendPanel")
    self:registerPanel(MailSelectFriendPanel.NAME, MailSelectFriendPanel)

    require("modules.mail.panel.MailCollectPanel")
    self:registerPanel(MailCollectPanel.NAME, MailCollectPanel)

    require("modules.mail.panel.MailAllPanel")
    self:registerPanel(MailAllPanel.NAME, MailAllPanel)

    require("modules.mail.panel.MailSpareTeamPanel")
    self:registerPanel(MailSpareTeamPanel.NAME, MailSpareTeamPanel)
end

function MailView:initView()
    local panel = self:getPanel(MailPanel.NAME)
    panel:show()
    
    panel = self:getPanel(MailActionPanel.NAME)
    panel:show()

    -- if self._firstOpen == nil then --登录的时候打开
    --     print("what the fuck??")
    --     print("what the fuck??")
    --     print("what the fuck??")
    --     print("what the fuck??")
    --     panel = self:getPanel(MailReportInfoPanel.NAME)
    --     panel:show()
    -- end
end

function MailView:onCloseView()
    -- if self._firstOpen == nil then
    --     print("close view fuck")
    --     self._firstOpen = true
    --     local panel = self:getPanel(MailReportInfoPanel.NAME)
    --     panel:hide()
    -- end
end

function MailView:hideModuleHandler()
    self:dispatchEvent(MailEvent.HIDE_SELF_EVENT, {})
end

function MailView:onOpenModule(data)
    local panel = self:getPanel(MailPanel.NAME)
    panel:onOpenModule(data)
end

function MailView:onGetAllMailsResp(tb)
    self:onOpenModule(tb)
end

function MailView:getAllShortData()
    local mailProxy = self:getProxy(GameProxys.Mail)
    return mailProxy:getAllShortData()
end

function MailView:getAllDetailData()
    local mailProxy = self:getProxy(GameProxys.Mail)
    return mailProxy:getAllDetailData()
end
-- 1:系统，2：发件箱；3：邮件；4：报告  （查看邮件）根据不同type显示不同panel
function MailView:onReadMailResp(data)
    local panel
    if data.info.type == 3 or data.info.type == 2 then
        panel = self:getPanel(MailDetailPanel.NAME)
        --查看邮件，有个需要改label  data.info.type == 3的时候就要改
        panel:show(data.info.type)
        panel:setContentText(data.info.id)
    elseif data.info.type == 4 or data.info.type == 1 then
        panel = self:getPanel(MailReportInfoPanel.NAME)
        panel:show()
        panel:updateListData(data.info,self._closeModule)
    end
    self._closeModule = nil
    self:updateActionPanel()
end
-- 刷新接收发送
function MailView:onSendMailResp(data)
   local panel = self:getPanel(MailDetailPanel.NAME)
   panel:hide()
   panel = self:getPanel(MailPanel.NAME)
   panel:onSendResp()
end

function MailView:onDeleteMailResp(data)
    local panel = self:getPanel(MailDetailPanel.NAME)
    panel:hide()
    panel = self:getPanel(MailReportInfoPanel.NAME)
    panel:hide()
    self:updateActionPanel()
end

-- 查看后刷新列表
function MailView:updateActionPanel()
    local panel = self:getPanel(MailActionPanel.NAME)
    local type = panel:getCurrType()
    panel:updateCount() -- 刷新红点
    -- 如果是报告页面
    if type == 4 then
        self:getPanel(MailReportPanel.NAME):updateListData()
    end
    -- 不是报告，没展示不执行
    local allPanel = self:getPanel(MailAllPanel.NAME)
    allPanel:updateCurListView()
end



function MailView:onUpdateShieldMails(data)
    local panel = self:getPanel(MailActionPanel.NAME)
    panel:updateListData(data.infos)
end

function MailView:onWatchPlayerInfo(data)
    local panel = self:getPanel(MailDetailPanel.NAME)
    panel:onContactResp(data)
end

function MailView:setExtraAction(data)
    local panel 
    if data["type"] == "writeMail" then
        panel = self:getPanel(MailDetailPanel.NAME)
        panel:show()
        panel:onWriteBackHandler(data)
    elseif data["type"] == "mailInfos" then
        if data["report"] == nil then
            self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = data["mailId"]})
        else
            print("别的地方打开战报")
            panel = self:getPanel(MailReportInfoPanel.NAME)
            panel:show()
            self.isShow = true
            panel:updateListData(data["report"],true)
        end
        self._closeModule = true
    elseif data["type"] == "shares" then
        print("别的地方打开战报")
        self.isShow = true
        self._closeModule = true
        panel = self:getPanel(MailReportInfoPanel.NAME)
        panel:show()
        ----ceshi
        local tmp = {} --1世界 2 军团
        tmp.index = data.index
        ----ceshi
        panel:updateListData(data["info"],self._closeModule,tmp)
    end
end
-- 领取附件回调
function MailView:onGetSysRewardResp(curMailId)
    local panel = self:getPanel(MailReportInfoPanel.NAME)
    panel:onGetSysRewardResp()
    local mailProxy = self:getProxy(GameProxys.Mail)
    mailProxy:setOneMailGotReward(curMailId) -- 修改数据， == 1
    -- 刷新系统邮件
    local mailAllPanel = self:getPanel(MailAllPanel.NAME)
    mailAllPanel:updateListView03()
    -- 刷新红点
    self:updateActionPanel()
end

-- 一键领取附件
function MailView:onGetAllItemMailsResp()
    -- 刷新系统邮件
    local mailAllPanel = self:getPanel(MailAllPanel.NAME)
    mailAllPanel:updateListView03()
    -- 刷新红点
    self:updateActionPanel()
end


function MailView:onLaterPersonResp(data)
    local panel = self:getPanel(MailSelectFriendPanel.NAME)
    if panel:isVisible() == true then
        panel:onLaterPersonResp(data)
    end
end