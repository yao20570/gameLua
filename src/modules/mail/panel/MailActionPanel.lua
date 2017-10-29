MailActionPanel = class("MailActionPanel", BasicPanel)
MailActionPanel.NAME = "MailActionPanel"

--查看，写
function MailActionPanel:ctor(view, panelName)
    MailActionPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MailActionPanel:finalize()
    MailActionPanel.super.finalize(self)
end

function MailActionPanel:initPanel()
    MailActionPanel.super.initPanel(self)
    self._mailProxy = self:getProxy(GameProxys.Mail)
    self._collectPanel = self:getPanel(MailCollectPanel.NAME)
    self._currType = 2
    self._allIds = {} -- 待删除的邮件列表
    self:registerEvent()
end

function MailActionPanel:registerEvent()
	self._downPanel = self:getChildByName("downPanel")
	self._bgPanel = self:getChildByName("bgPanel")
	local badGuyPanel = self:getChildByName("badGuyPanel")
	self._downPanel:setVisible(true)
	self._bgPanel:setVisible(false)
	badGuyPanel:setVisible(false)
	
	local littleBtn = self._downPanel:getChildByName("littleBtn")
	local writeBtn = self._downPanel:getChildByName("writeBtn")
	local badBtn = self._downPanel:getChildByName("badBtn")
	-- local closeBtn = self:getChildByName("closeBtn")
    self._getAllBtn = self._downPanel:getChildByName("getAllBtn")
    self._readAllBtn = self._downPanel:getChildByName("readAllBtn")


	self:addTouchEventListener(littleBtn,self.onDeleteMailHandle)
	self:addTouchEventListener(writeBtn,self.onWriteMailHandle)
	self:addTouchEventListener(badBtn,self.onAllBadMailsHandle)

    self:addTouchEventListener(self._getAllBtn,  self.getALLMailReward)
    self:addTouchEventListener(self._readAllBtn, self.readCurMailList)
    self._getAllBtn:setVisible(false)
end

function MailActionPanel:getDownPanel()
	-- body
	return self._downPanel
end

function MailActionPanel:onCloseBadPanelHandle(sender)
	self:setBadPanelStatus(false)
end

function MailActionPanel:setBadPanelStatus(status)
	self._bgPanel:setVisible(status)
	-- self._mainPanel:setVisible(status)
	self._secLvBg:setVisible(status)
end

-- 点击屏蔽列表按钮
function MailActionPanel:onAllBadMailsHandle(sender)
	local data = {}
	data.type = 0
	self:dispatchEvent(MailEvent.SHIELD_MAIL_REQ,data)
	
	-- self:setBadPanelStatus(true)
	if self._secLvBg == nil then
		self:createOrUpdateBadGuyPanel()
	end
end

function MailActionPanel:createOrUpdateBadGuyPanel()
	-- body
	--[[
	new一个二级背景,将全部子节点clone到二级背景下，
	再删除旧的全部子节点    
	]]
	--begin-------------------------------------------------------------------
	local extra = {}
	extra["closeBtnType"] = 1
	extra["callBack"] = self.onCloseBadPanelHandle
	extra["obj"] = self

	local secLvBg = UISecLvPanelBg.new(self:getPanelRoot(), self, extra)
	secLvBg:setContentHeight(660)
	secLvBg:setTitle(self:getTextWord(916))
	self._secLvBg = secLvBg
    self._secLvCloseBtn = self._secLvBg:getCloseBtn()
    
	local oldPanel = self:getChildByName("badGuyPanel")
	local mainPanel = secLvBg:getMainPanel()
	local panel = oldPanel:clone()
	panel:setName("panel")
	secLvBg:setLocalZOrder(100)
	panel:setLocalZOrder(100)
	mainPanel:addChild(panel)
	oldPanel:setVisible(false)
	oldPanel:removeFromParent()

	self._mainPanel = mainPanel:getChildByName("panel")
	self._mainPanel:setVisible(true)
end

function MailActionPanel:updateListData(data)
	self:setBadPanelStatus(true)
	local countLab = self._mainPanel:getChildByName("count")
	countLab:setString(#data.."/30")
	local listview = self._mainPanel:getChildByName("ListView_16")
	self:renderListView(listview, data, self, self.registerBadItemEvents)
end

function MailActionPanel:registerBadItemEvents(item,data,index)
	if item == nil then
		return
	end
	item:setVisible(true)
	-- local Image_21 = item:getChildByName("Image_21")
	-- TextureManager:updateImageView(Image_21, "images/guiScale9/Frame_item_bg.png")
	local name = item:getChildByName("name")
	local lv = item:getChildByName("lv")
	local person = item:getChildByName("person")
	local yichuBtn = item:getChildByName("yichuBtn")

	name:setString(data.name)
	lv:setString("Lv."..data.level)

	local size = name:getContentSize()
	lv:setPositionX(name:getPositionX() + size.width + 8)

	local headInfo = {}
    headInfo.icon = data.iconId
    headInfo.pendant = data.iconId
    headInfo.preName1 = "headIcon"
    headInfo.preName2 = nil
    headInfo.isCreatPendant = false
    headInfo.playerId = rawget(data, "playerId")
    local head = person.head
    if head == nil then
        head = UIHeadImg.new(person,headInfo,self)
        person.head = head
    else
        head:updateData(headInfo)
    end     
    --head:setHeadSquare(headInfo.icon)
	yichuBtn.data = data
	self:addTouchEventListener(yichuBtn,self.onYichuReq)
end

function MailActionPanel:addYichuHandle(yichuBtn)
	if yichuBtn.isAddEvent == true then
		return
	end
	yichuBtn.isAddEvent = true
	self:addTouchEventListener(yichuBtn,self.onYichuReq)
end

function MailActionPanel:onYichuReq(sender)
	local data = {}
	data.type = 0
	data.playerId = sender.data.playerId
	self:dispatchEvent(MailEvent.DELETE_SHIELD_REQ,data)
end

function MailActionPanel:onWriteMailHandle(sender)
	
	local roleProxy = self:getProxy(GameProxys.Role)
    local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if lv < GlobalConfig.chatMinLv then
        self:showSysMessage(string.format(TextWords:getTextWord(1238), GlobalConfig.chatMinLv))
        return
    end

	local mailPanel = self:getPanel(MailPanel.NAME)
	local tables = mailPanel:getCurrentTable()
	local currentPanelName = tables:getCurPanelName()
	local currentPanel = self:getPanel(currentPanelName)
	currentPanel:hide()
	mailPanel:hide()
	self:hide()
	local panel = self:getPanel(MailDetailPanel.NAME)
	panel:show()
	panel:setContentText()
end

function MailActionPanel:onDeleteMailHandle(sender)
	if #self._allIds == 0 then
		self:showSysMessage(self:getTextWord(1201)) -- 没有可删除的邮件了
		return
	end
	local function okcallbk()
        self:onRealDeleteMailReq()
    end
    self:showMessageBox(self:getTextWord(1205),okcallbk) 
end

-- 邮件批量删除
function MailActionPanel:onRealDeleteMailReq()
	local data = {}
	
    if self._collectPanel:isVisible() then
        data.id = self._allIds
        self._mailProxy:onTriggerNet160009Req(data)
    else
        data.idlist = self._allIds
        self:dispatchEvent(MailEvent.DELETE_MAIL_REQ,data)
    end
	
end


-- //邮件类型1:系统，2：发件箱；3：邮件；4：报告
function MailActionPanel:updateCount(type)
	if type ~= nil then
		self._currType = type
	end
	local listData = self.view:getAllShortData()
	local total = 0
	local notRead = 0
    local allMailCount = 0
	for _,v in pairs(listData) do
		if v ~= nil and v.type == self._currType then
			total = total + 1
			if v.state == 0 then
				notRead = notRead + 1
			end
            -- 系统邮件未领取也算一个红点
            if v.state == 1 and v.type == 1 then
                if v.extracted == 0 then
                    notRead = notRead + 1
                end
            end
		end

        -- 计算allMail红点，type ~= 4 不为报告的总红点
        if v ~= nil and v.type ~= 4 then
            if v.state == 0 then
				allMailCount = allMailCount + 1
			end
            -- 系统邮件未领取也算一个红点
            if v.state == 1 and v.type == 1 then
                if v.extracted == 0 then
                    allMailCount = allMailCount + 1
                end
            end
        end
	end
    -- 未读已读
	local totalLb = self._downPanel:getChildByName("total")
	local notReadLb = self._downPanel:getChildByName("notRead")
	totalLb:setString(total)
	notReadLb:setString(notRead)

	local panel = self:getPanel(MailPanel.NAME)
    panel["update"..self._currType.."Count"](panel, notRead)
    -- 刷新第二个标签的红点
    panel:updateTab2Count(allMailCount)


end

function MailActionPanel:getCurrType()
	return self._currType
end

function MailActionPanel:setCurrType(curType)
    self._currType = curType
end

-- 待删除的邮件
-- 小类邮件listView渲染时传入
function MailActionPanel:setBeingDelectMail(data)
    self._allIds = {}
    for k, v in pairs(data) do
        --print("extracted:".. v.extracted)
        if v.extracted ~= 0 then-- 未领取附件不批量删除
            table.insert(self._allIds, v.id)
        end
    end

    -- 已读与未读
    self:setTypeNumNoRead(data) 

    -- 设置一键操作所需数据
    self._curListViewData = data
    logger:info("赋值成功，self._curListViewData")
      
end

------
-- 获取当前邮件列表的数据
function MailActionPanel:getCurListViewData()
    return self._curListViewData
end


-- 设置未读数量
function MailActionPanel:setReadCount()
    


end

-------
-- 设置已读与未读，待删除
function MailActionPanel:setTypeNumNoRead(data)
    local total = 0
	local notRead = 0
    for _,v in pairs(data) do
	    total = total + 1
	    if v.state == 0 then
		    notRead = notRead + 1
	    end
    end
    -- 未读已读
	local totalLb = self._downPanel:getChildByName("total")
	local notReadLb = self._downPanel:getChildByName("notRead")
	totalLb:setString(total)
	notReadLb:setString(notRead)
end


------
-- 一件领取邮件附件
function MailActionPanel:getALLMailReward(sender)
    -- 
    local data = {}
    data.mailIds = {}
    local curData = self:getCurListViewData()
    for i, info in pairs(curData) do
        if info.extracted == 0 then  -- 未提取邮件才加入
            table.insert(data.mailIds, info.id)
        end
    end
    
    self._mailProxy:onTriggerNet160011Req(data)
end

------
-- 将邮件状态设置为已阅
function MailActionPanel:readCurMailList(sender)
    --
    local data = {}
    data.mailIds = {}
    local curData = self:getCurListViewData()
    for i, info in pairs(curData) do
        if info.state == 0 then  -- 未读状态才加入
            table.insert(data.mailIds, info.id)
        end
    end

    logger:info("成功阅读邮件："..#data.mailIds)
    self._mailProxy:onTriggerNet160012Req(data)
end


function MailActionPanel:setGetAllBtnVisible(state)
    self._getAllBtn:setVisible(state)
end