MailDetailPanel = class("MailDetailPanel", BasicPanel)
MailDetailPanel.NAME = "MailDetailPanel"

function MailDetailPanel:ctor(view, panelName)
    MailDetailPanel.super.ctor(self, view, panelName,true)
    
    self:setUseNewPanelBg(true)
end

function MailDetailPanel:finalize()
	if self._watchPlayInfoPanel ~= nil then
		self._watchPlayInfoPanel:finalize()
	end
	self._watchPlayInfoPanel = nil
    MailDetailPanel.super.finalize(self)
end

function MailDetailPanel:initPanel()
    self:setBgType(ModulePanelBgType.NONE)
    MailDetailPanel.super.initPanel(self)
    self:setTitle(true,"youjian",true)
    self._friendProxy = self:getProxy(GameProxys.Friend)
    self._mailProxy   = self:getProxy(GameProxys.Mail)
    local namePanel = self:getChildByName("top_Panel/Image_7/namePanel")
    local titlePanel = self:getChildByName("top_Panel/Image_7/titlePanel")
    local contentPanel = self:getChildByName("top_Panel/Image_7/contentPanel")
    self._receiveTitle = self:getChildByName("top_Panel/Image_7/Label_8")
    self._time = self:getChildByName("top_Panel/Image_7/time")
    self._contentTxt = self:getChildByName("top_Panel/Image_7/contentTxt")
    
    self._nameEditBox = ComponentUtils:addEditeBox(namePanel, 100,"",nil,false)
    --第五个参数为true屏蔽敏感字
    self._titleEditBox = ComponentUtils:addEditeBox(titlePanel, 8,self:getTextWord(1233),nil,true)
    local function callback()
        self:setContentToLabel()
    end
    self._contentEditBox = ComponentUtils:addEditeBox(contentPanel, 800,"",callback)
    self:registerEvent()
    self:setNewbgImg3(self:getChildByName("down_Panel"),false)
end

function MailDetailPanel:registerEvent()
	self._deleteBtn = self:getChildByName("down_Panel/deleteBtn")
	self._contactBtn = self:getChildByName("down_Panel/contactBtn")
	self._wBackBtn = self:getChildByName("down_Panel/wBackBtn")
	self._exitBtn = self:getChildByName("down_Panel/exitBtn")
	self._sendBtn = self:getChildByName("down_Panel/sendBtn")

	self._addBtn = self:getChildByName("top_Panel/Image_7/addBtn")
	self._clickPanel = self:getChildByName("top_Panel/Image_7/clickPanel")
	self._attackBtn = self:getChildByName("top_Panel/Image_7/attackBtn")
    self._attackBtn:setVisible(false)
	self._collectBtn = self:getChildByName("top_Panel/collectBtn")
    self._collectCancleBtn = self:getChildByName("top_Panel/collectCancleBtn")

    self._careTipTxt = self:getChildByName("down_Panel/careTipTxt") -- 诈骗提示文本
	self:addTouchEventListener(self._deleteBtn,self.onDeleteMailHandle)
	self:addTouchEventListener(self._exitBtn,self.onClosePanelHandler)
	self:addTouchEventListener(self._sendBtn,self.onSendMaillHandler)
	self:addTouchEventListener(self._wBackBtn,self.onWriteBackHandler)

	self:addTouchEventListener(self._addBtn,self.onAddFriendsHandler)--添加联系人按钮
	self:addTouchEventListener(self._contactBtn,self.onContactBtnHandler)
	self:addTouchEventListener(self._clickPanel,self.onClickPanelHandler)

	self:addTouchEventListener(self._attackBtn,self.onAttackHandler)
    self:addTouchEventListener(self._collectBtn, self.onCollectThisMailHandler) -- 点击收藏
    self:addTouchEventListener(self._collectCancleBtn, self.onCollectCancleThisMailHandler) -- 点击取消收藏

end

function MailDetailPanel:doLayout()
    NodeUtils:adaptiveUpPanel(self:getChildByName("top_Panel"), nil, GlobalConfig.tabsHeight)
end

function MailDetailPanel:onAttackHandler(sender)
end

function MailDetailPanel:setContentToLabel()
    if self._contentTxt then
	   local text = self._contentEditBox:getText()
	   --self._contentTxt:setString(StringUtils:getStringAddBackEnter(text,28))
       self._contentTxt:setString(text)
	end
end

function MailDetailPanel:onClickPanelHandler(sender)
	self._contentEditBox:openKeyboard()
end

function MailDetailPanel:onContactBtnHandler(sender)
	self:dispatchEvent(MailEvent.PEOPLE_INFO_REQ,{playerId = sender.dataId})
end
-- 点击收藏普通邮件
function MailDetailPanel:onCollectThisMailHandler(sender)
    local data = {}
    data.id = sender.id
    self._mailProxy:onTriggerNet160008Req(data)
end

function MailDetailPanel:onContactResp(data)
	if self._watchPlayInfoPanel == nil then
	   self._watchPlayInfoPanel = UIWatchPlayerInfo.new(self:getParent(), self, false)
	end
	self._watchPlayInfoPanel:setMialShield(true) 
	self._watchPlayInfoPanel:showAllInfo(data)
end

--添加联系人按钮
function MailDetailPanel:onAddFriendsHandler(sender) 
 	sender.nameEditBox = self._nameEditBox
 	local panel = self:getPanel(MailSelectFriendPanel.NAME)
 	panel:show(sender)
end

function MailDetailPanel:onExterWriteMail(name)
	self:setContentText()
	self._nameEditBox:setText(name)
end

function MailDetailPanel:onWriteBackHandler(sender)
	local roleProxy = self:getProxy(GameProxys.Role)
    local lv = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_level)
    if lv < GlobalConfig.chatMinLv then
        self:showSysMessage(string.format(TextWords:getTextWord(1238), GlobalConfig.chatMinLv))
        return
    end

	self:setContentText()
	if sender.name ~= nil then
		self._nameEditBox:setText(sender.name)
	end

	local parent = self._nameEditBox:getParent()
	if sender.isCloseModule ~= nil then
		self._closeModule = true
		parent:setTouchEnabled(false)
	else
		parent:setTouchEnabled(true)
	end

	local Label_8_1 = self:getChildByName("top_Panel/Image_7/Label_8_1")
	if sender.teamUnion == true then   --军团写邮件
		Label_8_1:setVisible(true)
		self._addBtn:setVisible(false)
		self._nameEditBox:setVisible(false)
		--self._addBtn:setEnabled(false)
		NodeUtils:setEnable(self._addBtn, false)

	else
		Label_8_1:setVisible(false)
		self._addBtn:setVisible(true)
		self._nameEditBox:setVisible(true)
		--self._addBtn:setEnabled(true)
		NodeUtils:setEnable(self._addBtn, true)
	end
end

function MailDetailPanel:onSendMaillHandler(sender)
	local size,charSize = StringUtils:getStringSize(self._titleEditBox:getText())

	--输入的标题只含中文
	if size ~= charSize then 
		if size > 8 then 
			self:showSysMessage(self:getTextWord(1232))
			return
		end
	end

	local data = {}
	data.name = {}
	local nameStr = self._nameEditBox:getText()
	local titleStr = self._titleEditBox:getText()
	if nameStr == "" then
		self:showSysMessage(self:getTextWord(1203))
		return
	elseif titleStr == "" then
		self:showSysMessage(self:getTextWord(1259))
		return
	else
		for _,v in pairs(StringUtils:splitString(nameStr, ";")) do
			table.insert(data.name,v)
		end
	end
	local content = self._contentTxt:getString()
	if content == "" then
		self:showSysMessage(self:getTextWord(1204)) -- [[内容不能为空]]
		return
	end
    
    -- 全空格内容视为空
    local str01, spaceCount01 = string.gsub(titleStr, " ", " ")
    local str02, spaceCount02 = string.gsub(content, " ", " ")
    if spaceCount01 == string.len(titleStr) then
        self:showSysMessage(self:getTextWord(1259)) 
        --print(spaceCount01)
        return
    end

    if spaceCount02 == string.len(content) then
        self:showSysMessage(self:getTextWord(1204)) 
        --print(spaceCount02)
        return
    end
    
    

	data.title = self._titleEditBox:getText()
	data.context = content
	self:dispatchEvent(MailEvent.SEND_MAIL_REQ,data)
    self:showSysMessage(self:getTextWord(1260)) -- [[邮件发送成功]]
	self:onClosePanelHandler() -- 关闭
end

function MailDetailPanel:onClosePanelHandler()
    self:hide()
    self._attackBtn:setVisible(false)
    local Label_8_1 = self:getChildByName("top_Panel/Image_7/Label_8_1")
    Label_8_1:setVisible(false)
	--self._addBtn:setVisible(true)
    self._nameEditBox:setVisible(true)
    if self._closeModule ~= nil then
    	self._closeModule = nil
    	self.view:hideModuleHandler()
    else
    	local mailPanel = self:getPanel(MailPanel.NAME)
		mailPanel:show()
		local tables = mailPanel:getCurrentTable()
		local currentPanelName = tables:getCurPanelName()
		local currentPanel = self:getPanel(currentPanelName)
		currentPanel:show()
		local mailActionPanel = self:getPanel(MailActionPanel.NAME)
		mailActionPanel:show()
    end
end
-- 删除按钮，收藏删除和普通删除
function MailDetailPanel:onDeleteMailHandle(sender)
	local data = {}
    
    local state = self._mailProxy:getIsInCollect(sender.id)
    if state then
        local id   = {}
        data.id = id
        table.insert(id, sender.id)
        self._mailProxy:onTriggerNet160009Req(data) -- 在收藏中删除
    else
        data.idlist = {}
        table.insert(data.idlist, sender.id)
        self:dispatchEvent(MailEvent.DELETE_MAIL_REQ,data) -- 普通删除
    end
end

function MailDetailPanel:clearAllText()
	self._nameEditBox:setText("")
	self._titleEditBox:setText("")
	self._contentEditBox:setText("")
	self._contentTxt:setString("")
end

function MailDetailPanel:setTextStatus(isEnable)
	local textMap = {self._nameEditBox,self._titleEditBox,self._contentEditBox}
	for _,v in pairs(textMap) do
		local parent = v:getParent()
		parent:setTouchEnabled(isEnable)
	end
	self._clickPanel:setTouchEnabled(isEnable)
end

function MailDetailPanel:setContentText(id)
	--self:show()
    self._id = id 
    local currData = nil 
	if id == nil then  --写信
		self:clearAllText()
		self:setBtnStatus(true,false)
		self:setTextStatus(true)
        -- 写信界面，隐藏
        self._collectBtn:setVisible(false)
        self._collectCancleBtn:setVisible(false)
        -- 写信界面，变为收件人
        self._receiveTitle:setString(self:getTextWord(200018)) -- "收件人:"
	else
		local listData = self.view:getAllDetailData()
	    currData = listData[id]
		self._nameEditBox:setText(currData.name)
		self._titleEditBox:setText(currData.title)
		--self._contentTxt:setString(StringUtils:getStringAddBackEnter(currData.context,28))
        self._contentTxt:setString(currData.context)
		local timeStr = TimeUtils:setTimestampToString(currData.createTime)
		self._time:setString(timeStr)
		self._deleteBtn.id = id 
        self._collectBtn.id = id -- -- 邮件收藏按钮 绑定数据，这个id可能是收藏id也可能是普通id
		self:setBtnStatus(false,true)
		self:setTextStatus(false)
		if currData.type == 1 then 
			self._receiveTitle:setString(self:getTextWord(200017)) -- "发件人:"
		elseif currData.type == 2 then
			self._receiveTitle:setString(self:getTextWord(200018)) -- "收件人:"
		elseif currData.type == 3 then
			self._receiveTitle:setString(self:getTextWord(200017))
		end

		if currData.senderType == 1 then  --玩家
			self._wBackBtn.name = currData.name
			--self._wBackBtn:setEnabled(true)
			NodeUtils:setEnable(self._wBackBtn, true)
		else
			--self._wBackBtn:setEnabled(false)
			NodeUtils:setEnable(self._wBackBtn, false)
		end
		--if rawget(currData,"playerId") ~= nil then
			self._contactBtn.data = currData
		--end
		if rawget(currData,"helpX") ~= nil then
			self._attackBtn:setVisible(true)
		else
			self._attackBtn:setVisible(false)
		end
        self:onIsShowContactBtn(currData)

        -- 收藏相关逻辑
        self:showCollectDetail()
	end

    -- 诈骗提示语句
    self._careTipTxt:setVisible(false)
    -- 阅读
    if id ~= nil and currData ~= nil then
        if currData.type ~= 2 then
            self:setCareTipTxt(self._contentTxt:getString())
            self:setCareTipTxt(self._titleEditBox:getText())
        end
    end
end

function MailDetailPanel:setBtnStatus(isShow,noshow)
	self._addBtn:setVisible(isShow)
	NodeUtils:setEnable(self._addBtn, isShow)
	self._exitBtn:setVisible(isShow)
	self._sendBtn:setVisible(isShow)
	self._deleteBtn:setVisible(noshow)
	self._contactBtn:setVisible(noshow)
	self._wBackBtn:setVisible(noshow)
	self._time:setVisible(noshow)
end

function MailDetailPanel:onIsShowContactBtn(currData)
    local status = false
	if currData.senderType == 1 then
		if rawget(currData,"friendId") ~= nil and StringUtils:isFixed64Zero(currData.friendId) ~= true then
			self._contactBtn.dataId = currData.friendId
            status = true
		else
		    if rawget(currData,"playerId") ~= nil and StringUtils:isFixed64Zero(currData.playerId) ~= true then
                self._contactBtn.dataId = currData.playerId
                status = true
		    end
		end
	else
		if rawget(currData,"playerId") ~= nil and StringUtils:isFixed64Zero(currData.playerId) == true then
			self._contactBtn.dataId = currData.playerId
            status = true
		else
		    if rawget(currData,"friendId") ~= nil and StringUtils:isFixed64Zero(currData.friendId) ~= true then
                self._contactBtn.dataId = currData.friendId
                status = true
		    end
		end
	end
    NodeUtils:setEnable(self._contactBtn, status)
end


-- 收藏相关逻辑
function MailDetailPanel:showCollectDetail()
    local dependData = self._mailProxy:getReadMailDependData(self._id)
    local isInCollect = self._mailProxy:getIsInCollect(self._id)
    if StringUtils:isFixed64Zero(dependData.collectId) then -- 为0说明未收藏，非0为链接id
        self._collectBtn:setVisible(true)
        self._collectCancleBtn:setVisible(false)
    else
        self._collectBtn:setVisible(false)
        self._collectCancleBtn:setVisible(true)
    end
    if isInCollect then
        self._collectBtn:setVisible(false)
        self._collectCancleBtn:setVisible(true)
    end
end


-- 点击取消收藏
function MailDetailPanel:onCollectCancleThisMailHandler()
    local dependData = self._mailProxy:getReadMailDependData(self._id)
    local isInCollect = self._mailProxy:getIsInCollect(self._id)
    local collectId = dependData.collectId -- 链接id 
    local selfId    = dependData.id -- 本身id

--    local data = {}
--    -- 如果从本身邮件取消就是发链接id，如果是从收藏邮件就是发收藏邮件的本身id
--    if isInCollect then
--        data.id = id
--        print("收藏内部邮件取消")
--    else
--        data.id = collectId
--        print("外部邮件取消")
--    end
--    self._mailProxy:onTriggerNet160009Req(data)

    local data = {}
    -- 如果从外部邮件取消就是发链接id，如果是从收藏邮件就是发收藏邮件的本身id
    local id   = {}
    data.id = id
    if isInCollect then
        table.insert(id, selfId)
        print("收藏内部邮件取消")
    else
        table.insert(id, collectId)
        print("外部邮件取消")
    end
    
    self._mailProxy:onTriggerNet160009Req(data)
end

-- 按钮显示反转
function MailDetailPanel:refreshBtnState()
    self._collectBtn:setVisible(not self._collectBtn:isVisible())
    self._collectCancleBtn:setVisible(not self._collectCancleBtn:isVisible())

end

-- 提示诈骗信息文本
function MailDetailPanel:setCareTipTxt(content)

    local config = ConfigDataManager:getConfigData(ConfigData.EmailSensitiveConfig)
    for key, value in pairs(config) do
        if string.find(content, value.sensitive) then
            self._careTipTxt:setVisible(true)
            self._careTipTxt:setString(self:getTextWord(1262))
            -- self._careTipTxt:setColor(ColorUtils.wordOrangeColor)
            break
        end
    end
    
end