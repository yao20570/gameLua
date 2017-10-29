-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MailAllPanel = class("MailAllPanel", BasicPanel)
MailAllPanel.NAME = "MailAllPanel"
MailAllPanel.TAB_COUNT = 3 -- 按钮个数
function MailAllPanel:ctor(view, panelName)
    MailAllPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MailAllPanel:finalize()
    MailAllPanel.super.finalize(self)
end

function MailAllPanel:initPanel()
	MailAllPanel.super.initPanel(self)
    
    self._mailProxy = self:getProxy(GameProxys.Mail)
    -- 3个listView
    self._listview01 = self:getChildByName("bgListView1") -- 接收
    self._listview02 = self:getChildByName("bgListView2") -- 发送
    self._listview03 = self:getChildByName("bgListView3") -- 系统
    self._listViewTable = {}  -- listView的列表

    for i = 1, MailAllPanel.TAB_COUNT do
        local listView = self:getChildByName("bgListView".. i)
        self._listViewTable[i] = listView
    end


    self._allTabPanel = self:getChildByName("reportTabPanel")
    for i = 1, MailReportPanel.TAB_COUNT do
        local tabBtn = self._allTabPanel:getChildByName( string.format("tabBtn_%d",i))
        tabBtn.index = i
        self:addTouchEventListener(tabBtn, self.onTouchTabBtn)
    end
    -- 红点刷新
    self._mailActionPanel = self:getPanel(MailActionPanel.NAME)
    self._mailActionPanel:updateCount(3)
    self._mailActionPanel:updateCount(2)
    self._mailActionPanel:updateCount(1)
end

function MailAllPanel:registerEvents()
	MailAllPanel.super.registerEvents(self)
end

function MailAllPanel:doLayout()
	local panel = self:getPanel(MailActionPanel.NAME)
    local downWidget = panel:getDownPanel()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._allTabPanel, self._listview01, downWidget,tabsPanel, 0)
    NodeUtils:adaptiveTopPanelAndListView(self._allTabPanel, self._listview02, downWidget,tabsPanel, 0)
    NodeUtils:adaptiveTopPanelAndListView(self._allTabPanel, self._listview03, downWidget,tabsPanel, 0)
end

------
-- 开始显示
function MailAllPanel:onShowHandler()
    
    local tabBtn01 = self._allTabPanel:getChildByName( string.format("tabBtn_%d",1))
    if self._index == nil then
        self:onTouchTabBtn(tabBtn01) -- 默认显示第一个
    else
        self:updateShowListView(self._index) -- 刷新原来的listView
    end
end



------
-- tab响应函数
-- @param  args [obj] 参数
-- @return nil
function MailAllPanel:onTouchTabBtn(sender)
    -- 按钮标识
    self._index = sender.index -- 按钮标识
    self:setTabBtnState( self._index) -- 按钮显示状态
    -- 三个listView的显示
    for k, v in pairs(self._listViewTable) do
        if k == self._index then
            self._listViewTable[k]:setVisible(true)
        else
            self._listViewTable[k]:setVisible(false)
        end
    end

    -- 刷新显示的listView
    self:updateShowListView(self._index)

   
end

------
-- 标签切换选中显示
function MailAllPanel:setTabBtnState(index)
    for i = 1 , MailReportPanel.TAB_COUNT do
        local btn = self._allTabPanel:getChildByName( string.format("tabBtn_%d",i))
        if i == index then
            btn:loadTextures("images/newGui2/BtnTab_selected.png", "images/newGui2/BtnTab_normal.png", "", 1)
            btn:setTouchEnabled(false)
            btn:setTitleColor(ColorUtils.wordWhiteColor)
        else
            btn:loadTextures("images/newGui2/BtnTab_normal.png", "images/newGui2/BtnTab_selected.png", "", 1)
            btn:setTouchEnabled(true)
            btn:setTitleColor(ColorUtils.wordYellowColor03)
        end
    end
end

-- 刷新显示的listView
function MailAllPanel:updateShowListView(index)
    if index == 1 then
        self:updateListView01()
        self._mailActionPanel:setCurrType(3) 
    elseif index == 2 then
        self:updateListView02()
        self._mailActionPanel:setCurrType(2) 
    elseif index == 3 then
        self:updateListView03()
        self._mailActionPanel:setCurrType(1) 
    end

    -- 刷新一键领取按钮显示
    self:getPanel(MailActionPanel.NAME):setGetAllBtnVisible(self._index == 3)
end
--===============================01 begin ====================================
-----
-- 刷新list01，接收邮件
function MailAllPanel:updateListView01()
    print("11111111111")
    local mailType = 3  -- 区分是什么类型的
    local listData = self.view:getAllShortData()
	local data = {}
	for _,v in pairs(listData) do
		if v ~= nil and v.type == mailType then
			table.insert(data,v)
		end
	end

    table.sort(data, function (a,b) return (a.createTime > b.createTime) end)
    self:renderListView(self._listViewTable[self._index], data, self, self.registerItemEvents)
    self._mailActionPanel:setBeingDelectMail(data)
end


function MailAllPanel:registerItemEvents(item,data,index)
	if item == nil then
		return
	end
	item.data = data
	item:setVisible(true)
	local Image_6 = item:getChildByName("Image_6")
	local name = Image_6:getChildByName("name")
	local title = Image_6:getChildByName("title")
	local time = Image_6:getChildByName("time")
	local bg = Image_6:getChildByName("bg")
	local openImg = Image_6:getChildByName("openImg")
	local closeImg = Image_6:getChildByName("closeImg")
	if data.state == 0 then
		closeImg:setVisible(true)
		openImg:setVisible(false)
	else
		closeImg:setVisible(false)
		openImg:setVisible(true)
	end
    name:setString(item.data.name)
	title:setString(item.data.title)
	local timeStr = TimeUtils:setTimestampToString(item.data.createTime)
	time:setString(timeStr)
	self:addItemEvent(item)
end

function MailAllPanel:addItemEvent(item)
	if item.addEvent == true then
		return
	end
	item.addEvent = true
	self:addTouchEventListener(item,self.onReadMailReq)
end

function MailAllPanel:onReadMailReq(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailDetailPanel.NAME)
		--邮件tab查看邮件，需要改里面的一个label
		panel:show(3)
		panel:setContentText(sender.data.id)
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
    

end
--=========================================01 end=========================================

--=========================================02 begin=========================================
-----
-- 刷新list02，发送邮件
function MailAllPanel:updateListView02()
    print("22222222222222")
    local mailType = 2  -- 区分是什么类型的
	local listData = self.view:getAllShortData()
	local data = {}
	for _,v in pairs(listData) do
        if v ~= nil and v.type == mailType then
			table.insert(data,v)
		end
	end
	table.sort(data, function (a,b) return (a.createTime > b.createTime) end)
	self:renderListView(self._listViewTable[self._index], data, self, self.registerItemEvents02)
    self._mailActionPanel:setBeingDelectMail(data)
end

function MailAllPanel:registerItemEvents02(item,data,index)
	if item == nil then
		return
	end
	item:setVisible(true)
	item.data = data
	local Image_6 = item:getChildByName("Image_6")
	local name = Image_6:getChildByName("name")
	local title = Image_6:getChildByName("title")
	local time = Image_6:getChildByName("time")
	local bg = Image_6:getChildByName("bg")
	local openImg = Image_6:getChildByName("openImg")
	local closeImg = Image_6:getChildByName("closeImg")
	if data.state == 0 then
		closeImg:setVisible(true)
		openImg:setVisible(false)
	else
		closeImg:setVisible(false)
		openImg:setVisible(true)
	end
	name:setString(item.data.name)
	title:setString(item.data.title)
	local timeStr = TimeUtils:setTimestampToString(item.data.createTime)
	time:setString(timeStr)
	self:addItemEvent02(item)
end

function MailAllPanel:addItemEvent02(item)
	if item.addEvent == true then
		return
	end
	item.addEvent = true
	self:addTouchEventListener(item,self.onReadMailReq02)
end

function MailAllPanel:onReadMailReq02(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailDetailPanel.NAME)
		panel:show()
		panel:setContentText(sender.data.id)
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
    
end

--=========================================02 end=========================================

--=========================================03 begin=========================================

-----
-- 刷新list03，系统邮件
function MailAllPanel:updateListView03()
    print("3333333333333")
    local mailType = 1  -- 区分是什么类型的
    local listData = self.view:getAllShortData()
	local data = {}
	for _,v in pairs(listData) do
        if v ~= nil and v.type == mailType then
			table.insert(data,v)
		end
	end
	table.sort(data, function (a,b) return (a.createTime > b.createTime) end)
	self:renderListView(self._listViewTable[self._index], data, self, self.registerItemEvents03)
    self._mailActionPanel:setBeingDelectMail(data)
end

function MailAllPanel:registerItemEvents03(item,data,index)
	if item == nil then
		return
	end
	item:setVisible(true)
	item.data = data
	local Image_6 = item:getChildByName("Image_6")
	local name = Image_6:getChildByName("name")
    local imgResult = Image_6:getChildByName("imgResult")
	local title = Image_6:getChildByName("title")
	local time = Image_6:getChildByName("time")
	local bg = Image_6:getChildByName("bg")
	local openImg = Image_6:getChildByName("openImg")
	local closeImg = Image_6:getChildByName("closeImg")
    local Label_17 = Image_6:getChildByName("Label_17")
    Label_17:setVisible(false)
	if data.state == 0 then
		closeImg:setVisible(true)
		openImg:setVisible(false)
	else
		closeImg:setVisible(false)
		openImg:setVisible(true)
	end
    if data.extracted == 1 then
        TextureManager:updateImageView(imgResult, "images/mail/IconAlreadyReceived.png")
        Label_17:setString(TextWords:getTextWord(1231)) -- "（已领取）"
        Label_17:setColor(cc.c3b(255,255,255))
        Label_17:setVisible(true)
        imgResult:setVisible(true)
    elseif data.extracted == 0 then
        TextureManager:updateImageView(imgResult, "images/mail/IconUnreceived.png")
        Label_17:setString(TextWords:getTextWord(1230)) -- "（未领取）"
        Label_17:setColor(cc.c3b(0,255,0))
        Label_17:setVisible(true)
        imgResult:setVisible(true)
    else 
        imgResult:setVisible(false)
    end
	name:setString(item.data.name)
	title:setString(item.data.title)
	local timeStr = TimeUtils:setTimestampToString(item.data.createTime)
	time:setString(timeStr)
	self:addItemEvent03(item)
end

function MailAllPanel:addItemEvent03(item)
	if item.addEvent == true then
		return
	end
	item.addEvent = true
	self:addTouchEventListener(item,self.onReadMailReq03)
end

function MailAllPanel:onReadMailReq03(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailReportInfoPanel.NAME)
		panel:show()
		panel:updateListData(listData[sender.data.id])
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
end
--=========================================02 end=========================================
------
-- 更新红点
function MailAllPanel:updateRedDot(panelType, state, data)
    if panelType == 3 then -- 接收
        local tabBtn = self._allTabPanel:getChildByName("tabBtn_1")
        local redDot = tabBtn:getChildByName("redDot")
        local num    = redDot:getChildByName("num")
        redDot:setVisible(state)
        num:setString(data)
        -- MailAllPanel:updateShowListView(1) -- 刷新到指定页面
    elseif panelType == 2 then -- 发送
        local tabBtn = self._allTabPanel:getChildByName("tabBtn_2")
        local redDot = tabBtn:getChildByName("redDot")
        local num    = redDot:getChildByName("num")
        redDot:setVisible(state)
        num:setString(data)
    elseif panelType == 1 then -- 系统
        local tabBtn = self._allTabPanel:getChildByName("tabBtn_3")
        local redDot = tabBtn:getChildByName("redDot")
        local num    = redDot:getChildByName("num")
        redDot:setVisible(state)
        num:setString(data)
    end
end


------
-- 网络更新
function MailAllPanel:updateCurListView()
    self:updateShowListView(self._index)
    print("刷新"..self._index .."【】【】" )
end

-- 获取当前listView的标识
function MailAllPanel:getCurListIndex()
    return self._index
end
