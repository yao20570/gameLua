
MailProxy = class("MailProxy", BasicProxy)

function MailProxy:ctor()
    MailProxy.super.ctor(self)
    self.proxyName = GameProxys.Mail
    self.mailInfo = {}
    self.isMail = false

    self._allMailList = {}
    self._allMailList.shortInfos = {}
    self._allMailList.detailInfos = {}
    self._collectData = {} -- 收藏邮件表
end


function MailProxy:resetAttr()
    self.mailInfo = {}
    self.isMail = false

    self._allMailList = {}
    self._allMailList.shortInfos = {}
    self._allMailList.detailInfos = {} -- 查看邮件的细节
    self._collectData = {} -- 收藏邮件表
end

------------网络数据请求与同步-------------
function MailProxy:onTriggerNet160000Req(data) -- 废弃，改由M2.20000下发
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160000, data)
end

function MailProxy:onTriggerNet160001Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160001, data)
end

function MailProxy:onTriggerNet160002Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160002, data)
end

function MailProxy:onTriggerNet160003Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160003, data)
end

function MailProxy:onTriggerNet160004Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160004, data)
end

function MailProxy:onTriggerNet160005Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160005, data)
end

function MailProxy:onTriggerNet160006Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160006, data)
end
-- 收藏邮件
function MailProxy:onTriggerNet160008Req(data)
    -- 收藏限制
    if table.size(self._collectData) == 50 then
        self:showSysMessage(TextWords:getTextWord(1248))
    else
        if self:isIdInCollectData(data.id) == false then
            self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160008, data)
        end
    end
end
-- 取消收藏
function MailProxy:onTriggerNet160009Req(data)
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160009, data)
end

function MailProxy:initSyncData(data)
    MailProxy.super.initSyncData(self, data)
	local tempData = {}
    tempData.mails = data.mails
    tempData.rs = 0
    self:onTriggerNet160000Resp(tempData)

    self._collectData = data.collectMails -- 收藏邮件列表
    --local count = table.size( self._collectData)
end
-- 存储数据
function MailProxy:onTriggerNet160000Resp(data)
    local tb = self:onDictData(self._allMailList.shortInfos,data.mails)
    self:sendNotification(AppEvent.PROXY_MAIL_INFO, tb)
    self:updateRedPoint()
end

function MailProxy:onTriggerNet160001Resp(data)  --查看邮件
    self._allMailList.detailInfos[data.info.id] = data.info 
    -- 将查看的信息存储并修改状态
    for k,v in pairs(self._allMailList.shortInfos) do
        if v.id == data.info.id then
            v.state = 1
            break
        end
    end
    -- 回调
    self:sendNotification(AppEvent.PROXY_MAIL_CHECKINFO, data)
    self:updateRedPoint()
end

function MailProxy:onTriggerNet160002Resp(data)  --新邮件通知
	self:sendNotification(AppEvent.PROXY_MAIL_NEWMAIL, data)
    self:updateRedPoint()
end

--发送邮件
function MailProxy:onTriggerNet160003Resp(data)
    for _,v in pairs(data.info) do
        self._allMailList.shortInfos[v.id] = v
   end
	self:sendNotification(AppEvent.PROXY_MAIL_SENDMAIL, data)
    self:updateRedPoint()
end

--删除邮件，发送MailEvent.DELETE_MAIL_REQ
function MailProxy:onTriggerNet160004Resp(data)
    for _,v in pairs(data.idlist) do
        self._allMailList.shortInfos[v] = nil
        if self._allMailList.detailInfos[v] ~= nil then
            self._allMailList.detailInfos[v] = nil
        end
    end

	self:sendNotification(AppEvent.PROXY_MAIL_REMOVEMAIL, data)
    self:updateRedPoint()
end

function MailProxy:onTriggerNet160005Resp(data)
	self:sendNotification(AppEvent.PROXY_MAIL_RUNBATTLE, data)
    self:updateRedPoint()
end
-- 领取邮件的附件
function MailProxy:onTriggerNet160006Resp(data)
	self:sendNotification(AppEvent.PROXY_MAIL_PICKUP_MAIL, data)
    self:updateRedPoint()
end

-- 添加一个新邮件，例如侦查，作战之后服务端下发
function MailProxy:onTriggerNet160007Resp(data)
    if data.rs == 0 then
        local tb = self:onDictData(self._allMailList.shortInfos, data.mails)
        self:sendNotification(AppEvent.PROXY_MAIL_INFO, tb)
        self:updateRedPoint()
    end
end

-- 收藏邮件数据返回
function MailProxy:onTriggerNet160008Resp(data)
    
--    self._collectData[data.mail.id] = data.mail
    table.insert(self._collectData, data.mail)
    -- 收藏成功之后，修改普通邮件数据
    local collectId = data.mail.collectId -- 对应普通邮件的id
    -- 修改普通邮件的 collectId, 做链接
    self._allMailList.shortInfos[collectId].collectId = data.mail.id
    -- 刷新收藏邮件列表
    self:sendNotification(AppEvent.PROXY_MAIL_UPDATE_COLLECT, {})
    -- 飘字
    self:showSysMessage(TextWords:getTextWord(1239))
end

-- 取消收藏数据返回
function MailProxy:onTriggerNet160009Resp(data)
    local collectIdTable = data.collectId -- 收藏原本id
    local normalIdTable  = data.normalId  -- 普通原本id

    for key, value in pairs (collectIdTable) do
        local collectId = value -- 收藏原本id
        local normalId  = normalIdTable[key]  -- 普通原本id

        -- 修改普通邮件的链接id 为 0， 表示未收藏， 
        -- 在普通总表里找到，改变链接id为0， 没有则不操作
        for k , v in pairs( self._allMailList.shortInfos) do
            if k == normalId then
                self._allMailList.shortInfos[normalId].collectId = StringUtils:int32ToFixed64(0)
                break
            end
        end
        --print("成功进行了取消")
        --self._collectData[collectId] = nil
        -- 从收藏邮件表里删除
        for k, v in pairs(self._collectData) do
            if v.id == collectId then
                table.remove(self._collectData, k)
                --print("从收藏数据表删除成功")
                break
            end
        end
    end


    -- 取消收藏
    self:sendNotification(AppEvent.PROXY_MAIL_REMOVE_COLLECT, data)
end

function MailProxy:onTriggerNet160010Resp(data)
    if data.rs == 0 then 
        self:showSysMessage(TextWords:getTextWord(5054))
    end
end

-- 所有邮件信息，包括报告和普通收发
function MailProxy:getAllShortData()
    return self._allMailList.shortInfos
end

function MailProxy:getMailShortDataById(mailId)
    return self._allMailList.shortInfos[mailId]
end

function MailProxy:getAllDetailData()
    return self._allMailList.detailInfos -- 加[]返回 MailDetalInfo info = 2;这个信息
end

-- 领取了邮件附件，由MailView:onGetSysRewardResp(curMailId) 调用
function MailProxy:setOneMailGotReward(mailId)
    if self._allMailList.shortInfos[mailId] then
        self._allMailList.shortInfos[mailId].extracted = 1
    end
end

-- 收藏了该邮件
--function 


-- 接收数据
function MailProxy:onDictData(selfTab,newTab)
    --local tb = {0,0,0,0}
    for _,v in pairs(newTab) do
        if v.mailType ~= 4 then
            selfTab[v.id] = v
        end
    end
    local _tb = self:getTb() -- 红点表
    return _tb
end

function MailProxy:setCurrentState(isHave)
	self.isMail = isHave
end

function MailProxy:getCurrentState()
	local tmpState = self.isMail
	self:setCurrentState(false)
	return tmpState
end

------
-- 红点子项初始化数据
--[1]-- 系统
--[2]-- 发送
--[3]-- 接受
--[4]-- 报告
function MailProxy:getTb()
    local _tb = {0,0,0,0}
    
    for k,v in pairs(self._allMailList.shortInfos) do
        if v.state == 0 then
            _tb[v.type] = _tb[v.type] + 1
        end
        -- 系统邮件未领取也算一个红点
        if v.state == 1 and v.type == 1 then
            if  v.extracted == 0 then
                _tb[v.type] = _tb[v.type] + 1
            end
        end
    end
    return _tb
end

--小红点更新
function MailProxy:updateRedPoint()
    local redPointProxy = self:getProxy(GameProxys.RedPoint)
    redPointProxy:checkMailRedPoint() 
end

-- 获取收藏邮件表数据
function MailProxy:getCollectData()
    return self._collectData
end

-- 获取当前查看的邮件的shortdata
function MailProxy:getReadMailDependData(id)
    local dependData = nil 
    if self:isIdInCollectData(id) then
        dependData = self:getCollectDataItem(id)
    else
        dependData = self._allMailList.shortInfos[id]
    end

    return dependData
end


-- 获取是否在收藏里面点击,true则为在收藏里点击
function MailProxy:getIsInCollect(id)

    return self:isIdInCollectData(id)
end


-- 判断是否在收藏里， 是否在收藏跳转
function MailProxy:isIdInCollectData(id)
    local state = false
    for k, v in pairs(self._collectData) do
        if v.id == id then
            state = true
            break
        end
    end
    return state
end

-- 获取收藏数据item
function MailProxy:getCollectDataItem(id)
    for k, v in pairs(self._collectData) do
        if v.id == id then
            return v
        end
    end
end



----------------------------------相关的一键操作消息号start
------
-- 一件领取邮件附件
function MailProxy:onTriggerNet160011Req(data)
    self._getAllId = data.mailIds
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160011, data)
end


------
-- 将邮件状态设置为已阅
function MailProxy:onTriggerNet160012Req(data)
    self._readAllId = data.mailIds
    self:syncNetReq(AppEvent.NET_M16, AppEvent.NET_M16_C160012, data)
end


------
-- 一件领取邮件附件
function MailProxy:onTriggerNet160011Resp(data)
    if data.rs ~= 0 then
        -- return 
    end

    if self._getAllId == nil or #self._getAllId == 0 then
        return
    end
    -- 未成功领取的邮件列表
    local unGetData = data.mailIds

    for k, v in pairs(self._getAllId) do
        local state = false
        for i, id in pairs(unGetData) do
            if id == v then
                state = true
                break
            end
        end
        
        if state == false then -- 领取成功，改变状态
            self:setOneMailGotReward(v)
            if self._allMailList.shortInfos[v] then
                self._allMailList.shortInfos[v].state = 1
            end
        end
    end
    -- 回调
    self:sendNotification(AppEvent.PROXY_MAIL_GET_ALL, data)
    self:updateRedPoint()
end


------
-- 将邮件状态设置为已阅
function MailProxy:onTriggerNet160012Resp(data)
    if data.rs ~= 0 then
        return 
    end

    if self._readAllId == nil or #self._readAllId == 0 then
        return
    end


    for k, v in pairs(self._readAllId) do
        if self._allMailList.shortInfos[v] then
            self._allMailList.shortInfos[v].state = 1
        end
    end
    -- 回调
    self:sendNotification(AppEvent.PROXY_MAIL_READ_ALL, data)
    self:updateRedPoint()
    self._readAllId = {} -- 还原
end