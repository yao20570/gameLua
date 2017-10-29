
MailModule = class("MailModule", BasicModule)

function MailModule:ctor()
    MailModule.super.ctor(self)
    
    self.moduleLevel = ModuleLevel.FREE_LEVEL
    self.uiLayerName = ModuleLayer.UI_3_LAYER
    
    self.showActionType = ModuleShowType.LEFT
    
    self._view = nil
    self._loginData = nil
    self._firstOpen = nil
    self._realOpen = false

    self:initRequire()
end

function MailModule:initRequire()
    require("modules.mail.event.MailEvent")
    require("modules.mail.view.MailView")
end

function MailModule:finalize()
    MailModule.super.finalize(self)
    self:removeEventHander()
    self._view:finalize()
    self._view = nil
end

function MailModule:initModule()
    MailModule.super.initModule(self)
    self._view = MailView.new(self.parent)

    self:addEventHandler()
end

function MailModule:addEventHandler()
    self._view:addEventListener(MailEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:addEventListener(MailEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:addEventListener(MailEvent.READ_MAIL_REQ, self, self.onReadMailReq)
    self._view:addEventListener(MailEvent.SEND_MAIL_REQ, self, self.onSendMailReq)
    self._view:addEventListener(MailEvent.DELETE_MAIL_REQ, self, self.onDeleteMailReq)
    self._view:addEventListener(MailEvent.SHIELD_MAIL_REQ, self, self.onGetShieldMailsReq)
    self._view:addEventListener(MailEvent.DELETE_SHIELD_REQ, self, self.onDeleteShieldMailsReq)
    self._view:addEventListener(MailEvent.PEOPLE_INFO_REQ, self, self.onGetPersonInfoReq)
    self._view:addEventListener(MailEvent.SHOWFT_AGAIN_REQ, self, self.onShowFtAgainReq)
    self._view:addEventListener(MailEvent.GET_SYSREWARD_REQ, self, self.onGetSysRewardReq)
    self._view:addEventListener(MailEvent.MAIL_FIGHT_REQ, self, self.onMailFightReq)
    self._view:addEventListener(MailEvent.GOTO_MAPPOS_REQ, self, self.onGoToMapReq)
    self._view:addEventListener(MailEvent.GET_LATERPERSON_REQ, self, self.onLaterPersonReq)
    self:addEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20400, self, self.onLaterPersonResp) --最近联系人

    self:addProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_PERSON_NOT_MAP, self, self.onChatPersonInfoResp)
    self:addProxyEventListener(GameProxys.Chat,AppEvent.PROXY_SELF_WRITEMAIL, self, self.onSelfWriteMail)
    self:addProxyEventListener(GameProxys.Chat,AppEvent.PROXY_SHIELDCHAT_INFO, self, self.onGetShieldMailsResp)
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_INFO, self, self.onGetAllMailListResp)
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_NEWMAIL, self, self.onNewMailsResp)
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_CHECKINFO, self, self.onReadMailResp) -- 查看邮件160001 回调
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_PICKUP_MAIL, self, self.onGetSysRewardResp)
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_SENDMAIL, self, self.onSendMailResp)
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_REMOVEMAIL, self, self.onDeleteMailResp)
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_UPDATE_COLLECT, self, self.onAddCollectResp) -- 添加收藏的回调
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_REMOVE_COLLECT, self, self.onCancleCollectResp) -- 取消收藏的回调
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_READ_ALL, self, self.onReadAllMailsResp) -- 一键阅读的回调
    self:addProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_GET_ALL, self, self.onGetAllItemMailsResp) -- 一键领取的回调

end

function MailModule:removeEventHander()
    self._view:removeEventListener(MailEvent.HIDE_SELF_EVENT, self, self.onHideSelfHandler)
    self._view:removeEventListener(MailEvent.SHOW_OTHER_EVENT, self, self.onShowOtherHandler)
    self._view:removeEventListener(MailEvent.READ_MAIL_REQ, self, self.onReadMailReq)
    self._view:removeEventListener(MailEvent.SEND_MAIL_REQ, self, self.onSendMailReq)
    self._view:removeEventListener(MailEvent.DELETE_MAIL_REQ, self, self.onDeleteMailReq)
    self._view:removeEventListener(MailEvent.SHIELD_MAIL_REQ, self, self.onGetShieldMailsReq)
    self._view:removeEventListener(MailEvent.DELETE_SHIELD_REQ, self, self.onDeleteShieldMailsReq)
    self._view:removeEventListener(MailEvent.PEOPLE_INFO_REQ, self, self.onGetPersonInfoReq)
    self._view:removeEventListener(MailEvent.SHOWFT_AGAIN_REQ, self, self.onShowFtAgainReq)
    self._view:removeEventListener(MailEvent.GET_SYSREWARD_REQ, self, self.onGetSysRewardReq)
    self._view:removeEventListener(MailEvent.MAIL_FIGHT_REQ, self, self.onMailFightReq)
    self._view:removeEventListener(MailEvent.GOTO_MAPPOS_REQ, self, self.onGoToMapReq)
    self._view:removeEventListener(MailEvent.GET_LATERPERSON_REQ, self, self.onLaterPersonReq)
    self:removeEventListener(AppEvent.NET_M2, AppEvent.NET_M2_C20400, self, self.onLaterPersonResp) --最近联系人

    self:removeProxyEventListener(GameProxys.Chat, AppEvent.PROXY_GET_PERSON_NOT_MAP, self, self.onChatPersonInfoResp)
    self:removeProxyEventListener(GameProxys.Chat,AppEvent.PROXY_SELF_WRITEMAIL, self, self.onSelfWriteMail)
    self:removeProxyEventListener(GameProxys.Chat,AppEvent.PROXY_SHIELDCHAT_INFO, self, self.onGetShieldMailsResp)
    self:removeProxyEventListener(GameProxys.Mail,AppEvent.PROXY_MAIL_INFO, self, self.onGetAllMailListResp)
    self:removeProxyEventListener(GameProxys.Mail,AppEvent.PROXY_MAIL_NEWMAIL, self, self.onNewMailsResp)
    self:removeProxyEventListener(GameProxys.Mail,AppEvent.PROXY_MAIL_CHECKINFO, self, self.onReadMailResp) -- 查看邮件160001 回调
    self:removeProxyEventListener(GameProxys.Mail,AppEvent.PROXY_MAIL_PICKUP_MAIL, self, self.onGetSysRewardResp)
    self:removeProxyEventListener(GameProxys.Mail,AppEvent.PROXY_MAIL_SENDMAIL, self, self.onSendMailResp)
    self:removeProxyEventListener(GameProxys.Mail,AppEvent.PROXY_MAIL_REMOVEMAIL, self, self.onDeleteMailResp)
    self:removeProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_UPDATE_COLLECT, self, self.onAddCollectResp)
    
    self:removeProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_REMOVE_COLLECT, self, self.onCancleCollectResp) -- 取消收藏的回调
    self:removeProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_READ_ALL, self, self.onReadAllMailsResp) -- 一键阅读的回调
    self:removeProxyEventListener(GameProxys.Mail, AppEvent.PROXY_MAIL_GET_ALL, self, self.onGetAllItemMailsResp) -- 一键领取的回调
end

function MailModule:onHideSelfHandler()
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = self.name})
    local data = {}    
    local mailProxy = self:getProxy(GameProxys.Mail)
    mailProxy:onTriggerNet160002Req(data)
end

function MailModule:onShowOtherHandler(moduleName)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, {moduleName = moduleName.name})
end

-- 其他模块跳转过来的onOpenModule中做处理，
-- 调用这个接口的可能是BasicModule的流程函数
function MailModule:onOpenModule(extraMsg)
    MailModule.super.onOpenModule(self)
    if extraMsg ~= nil then  --其他模块跳转过来
        self._view:setExtraAction(extraMsg) -- e:打开相应的panel
    end
    local mailProxy = self:getProxy(GameProxys.Mail)
    local tb = mailProxy:getTb() -- 红点列表
    self:onGetAllMailListResp(tb) -- reloding红点
    -- 是否有军团
    local roleProxy = self:getProxy(GameProxys.Role)
    if roleProxy:getLegionName() ~= "" then
        -- 请求军团成员信息
        local legionProxy = self:getProxy(GameProxys.Legion)
        legionProxy:onTriggerNet220200Req()
    end

end

function MailModule:onGetAllMailListResp(tb)
    local mailProxy = self:getProxy(GameProxys.Mail)
    self._view:onGetAllMailsResp(tb)
end

function MailModule:onReadMailReq(data)
    local mailProxy = self:getProxy(GameProxys.Mail)
    mailProxy:onTriggerNet160001Req(data)
end
-- 查看邮件160001 回调
function MailModule:onReadMailResp(data)
    if data.rs == 0 then
        self._view:onReadMailResp(data)
    end
end

function MailModule:onSendMailReq(data)
    local mailProxy = self:getProxy(GameProxys.Mail)
    mailProxy:onTriggerNet160003Req(data)
end

function MailModule:onSendMailResp(data)
    if data.rs == 0 then
        for _,v in pairs(data.notGetNameList) do
            self:showSysMessage("玩家".."'"..v.."'".."发送失败!")
        end
        self._view:onSendMailResp(data)
    end
end
-- 邮件删除
function MailModule:onDeleteMailReq(data)
    local mailProxy = self:getProxy(GameProxys.Mail)
    mailProxy:onTriggerNet160004Req(data)
end

function MailModule:onDeleteMailResp(data)
    if data.rs == 0 then
        self._view:onDeleteMailResp(data)
    end
end

function MailModule:onNewMailsResp(data)
    self:showSysMessage(self:getTextWord(1207)..data.num..self:getTextWord(1208))
    local sendData = {}
    local mailProxy = self:getProxy(GameProxys.Mail)
    mailProxy:onTriggerNet160000Req(sendData)
end

function MailModule:onGetShieldMailsReq(data)
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:onTriggerNet140006Req(data)
end

function MailModule:onGetShieldMailsResp(data)
    if data.rs == 0 and data.type == 0 then
        self._view:onUpdateShieldMails(data)
    end
end

function MailModule:onDeleteShieldMailsReq(data)
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:onTriggerNet140007Req(data)
end

function MailModule:onGetPersonInfoReq(data)
    local chatProxy = self:getProxy(GameProxys.Chat)
    chatProxy:onTriggerNet140001Req(data)
end

function MailModule:onChatPersonInfoResp(data)
    if data.rs == 0 then
        self._view:onWatchPlayerInfo(data)
    end
end

function MailModule:onShowFtAgainReq(data)
    local mailProxy = self:getProxy(GameProxys.Mail)
    mailProxy:onTriggerNet160005Req(data)
end

function MailModule:onGetSysRewardReq(data)
    local mailProxy = self:getProxy(GameProxys.Mail)
    self._curMailId = data.mailId
    mailProxy:onTriggerNet160006Req(data)
end

function MailModule:onGetSysRewardResp(data)
    if data.rs == 0 then
        self._view:onGetSysRewardResp(self._curMailId) -- 领取邮件内奖励
    end
end

function MailModule:onMailFightReq(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_OPEN_EVENT, data)
end

function MailModule:onGoToMapReq(data)
    self:sendNotification(AppEvent.MODULE_EVENT, AppEvent.MODULE_CLOSE_EVENT, {moduleName = "ChatModule"})
    self:sendNotification(AppEvent.M2M_MAIN_EVENT, AppEvent.WATCH_WORLD_TILE, {tileX = data.extraMsg.tileX,
        tileY = data.extraMsg.tileY})
    self:sendNotification(AppEvent.MODULE_EVENT,AppEvent.MODULE_OPEN_EVENT,data)
end

function MailModule:onSelfWriteMail(data)
    self._view:setExtraAction(data)
end

function MailModule:onLaterPersonResp(data)
    if data.rs == 0 then
        self._view:onLaterPersonResp(data.infos)
    end
end

function MailModule:onLaterPersonReq()
    self:sendServerMessage(AppEvent.NET_M2, AppEvent.NET_M2_C20400, {})
end

-- 刷新收藏列表160008
function MailModule:onAddCollectResp()
    -- 刷新列表
    local panel = self:getPanel(MailCollectPanel.NAME)
    panel:updateCollectListView()

    -- 刷新detail界面
    local detailPanel = self:getPanel(MailDetailPanel.NAME)
    if detailPanel:isVisible() then
        -- 刷新按钮
        detailPanel:refreshBtnState()
    end

    -- 刷新report界面
    local reportInfoPanel = self:getPanel(MailReportInfoPanel.NAME)
    if reportInfoPanel:isVisible() then
        -- 刷新按钮
        reportInfoPanel:refreshBtnState()
    end 
end

-- 取消收藏列表160009
function MailModule:onCancleCollectResp(data)
    -- 刷新列表
    local panel = self:getPanel(MailCollectPanel.NAME)
    panel:updateCollectListView()
    local mailProxy = self:getProxy(GameProxys.Mail)

    local collectPanel = self:getPanel(MailCollectPanel.NAME)
    local isInCollect = collectPanel:isVisible()
    if isInCollect then
        -- 关闭detail界面
        -- 在收藏界面取消，隐藏detail
        local detailPanel = self:getPanel(MailDetailPanel.NAME)
        if detailPanel:isVisible() then
            
            detailPanel:hide()
        end 
        -- 在收藏界面取消，隐藏report
        local reportInfoPanel = self:getPanel(MailReportInfoPanel.NAME)
        if reportInfoPanel:isVisible() then
            -- 刷新按钮
            reportInfoPanel:hide()
        end 
    else
        -- 刷新detail界面
        local detailPanel = self:getPanel(MailDetailPanel.NAME)
        if detailPanel:isVisible() then
            -- 不再收藏界面取消，刷新按钮
            detailPanel:refreshBtnState()
        end
        -- 刷新report界面
        local reportInfoPanel = self:getPanel(MailReportInfoPanel.NAME)
        if reportInfoPanel:isVisible() then
            -- 刷新按钮
            reportInfoPanel:refreshBtnState()
        end 
    end
end


------
-- 160012 一键阅读回调函数
function MailModule:onReadAllMailsResp()
    self._view:updateActionPanel()
end

------
-- 160011 一键领取回调函数
function MailModule:onGetAllItemMailsResp()
    self._view:onGetAllItemMailsResp()
end
