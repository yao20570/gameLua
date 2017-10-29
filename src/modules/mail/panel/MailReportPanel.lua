MailReportPanel = class("MailReportPanel", BasicPanel)
MailReportPanel.NAME = "MailReportPanel"


MailReportPanel.TAB_COUNT = 3 -- 按钮个数

function MailReportPanel:ctor(view, panelName)
    MailReportPanel.super.ctor(self, view, panelName)
    self._type = 4 -- 标识， 表示报告
    
    self:setUseNewPanelBg(true)
end

function MailReportPanel:finalize()
    MailReportPanel.super.finalize(self)
end

function MailReportPanel:initPanel()
    MailReportPanel.super.initPanel(self)
    self._mailProxy = self:getProxy(GameProxys.Mail)
    self._worldProxy= self:getProxy(GameProxys.World)

    self._listview = self:getChildByName("bgListView")
    self._reportTabPanel = self:getChildByName("reportTabPanel")
    self._mailActionPanel = self:getPanel(MailActionPanel.NAME)
    for i = 1, MailReportPanel.TAB_COUNT do
        local tabBtn = self._reportTabPanel:getChildByName( string.format("tabBtn_%d",i))
        tabBtn.index = i
        self:addTouchEventListener(tabBtn, self.onTouchTabBtn)
    end
end

function MailReportPanel:doLayout()
	local panel = self:getPanel(MailActionPanel.NAME)
    local downWidget = panel:getDownPanel()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._reportTabPanel, self._listview, downWidget,tabsPanel, 0)
end


function MailReportPanel:onTabChangeEvent(tabControl)
    local panel = self:getPanel(MailActionPanel.NAME)
    local downWidget = panel:getDownPanel()
    MailReportPanel.super.onTabChangeEvent(self, tabControl, downWidget)
end

function MailReportPanel:onShowHandler()
    if self._listview then
        self._listview:jumpToTop()
    end
    -- 刷新界面
	local panel = self:getPanel(MailActionPanel.NAME)
	panel:updateCount(self._type) -- type == 4 通知，为报告

    -- 初始化第一页
    local tabBtn01 = self._reportTabPanel:getChildByName( string.format("tabBtn_%d",1))
    local tabBtn02 = self._reportTabPanel:getChildByName( string.format("tabBtn_%d",2))
    local tabBtn03 = self._reportTabPanel:getChildByName( string.format("tabBtn_%d",3))
    if self._index == nil or self._index == 1 then
        self:onTouchTabBtn(tabBtn01) -- 默认显示第一个
    elseif self._index == 2 then
        self:onTouchTabBtn(tabBtn02)
    elseif self._index == 3 then   
        self:onTouchTabBtn(tabBtn03)
    end

end


------
-- 网络回调函数
function MailReportPanel:updateListData()
    if self._index == nil then
        self._index = 1 
    end

    local mailType = self:getMailTypeByBtnIndex(self._index)

    local reportData =  self:getReportDataByMailType(mailType)

    self:renderListView(self._listview, reportData, self, self.registerItemEvents)
    self._mailActionPanel:setBeingDelectMail(reportData)
end

function MailReportPanel:registerItemEvents(item,data,index)
	if item == nil then
		return
	end
	item:setVisible(true)
	item.data = data
	local Image_6 = item:getChildByName("Image_6")
	
    local name = Image_6:getChildByName("name")
	local time = Image_6:getChildByName("time")
	local bg = Image_6:getChildByName("bg")
	local openImg = Image_6:getChildByName("openImg")
	local closeImg = Image_6:getChildByName("closeImg")
    local fightStateTxt = Image_6:getChildByName("fightStateTxt") -- 战况
    local nameTxt = Image_6:getChildByName("nameTxt") -- 名称
    local typeTxt = Image_6:getChildByName("typeTxt") -- 的XX
    local failImg = Image_6:getChildByName("failImg") -- 失败图
    local victoryImg = Image_6:getChildByName("victoryImg") -- 胜利图
    local defendResNameTxt = Image_6:getChildByName("defendResNameTxt")
    failImg:setVisible(false)
    victoryImg:setVisible(false)
    -- 初始化
    name:setColor(cc.c3b(255, 230, 170))
    nameTxt:setString("")
    nameTxt:setColor(cc.c3b(255, 255, 255))
    typeTxt:setString("")
    defendResNameTxt:setString("")
    defendResNameTxt:setColor(cc.c3b(255, 255, 255))
    -- 设置已读未读
	if data.state == 0 then
		closeImg:setVisible(true)
		openImg:setVisible(false)
	else
		closeImg:setVisible(false)
		openImg:setVisible(true)
	end
    
    --------- 1 战斗出击；2、战斗防守;3、侦查
    local itemData = item.data   -- MailShortInfo结构体
    local resultStr = ""
    -- 文字显示
    if itemData.mailType == 1 then -- 进攻，出战格式： 进攻{玩家名称}的主城/进攻｛矿点名称｝/进攻｛玩家名称｝的｛矿点名称｝
        -- 战况出战
        if itemData.typeState == 0 then -- 胜利
            resultStr = TextWords:getTextWord(1215)
            victoryImg:setVisible(true)
        elseif itemData.typeState == 1 then -- 失败
            resultStr = TextWords:getTextWord(1216)
            failImg:setVisible(true)
        elseif itemData.typeState == 3 then -- 采集成功
            resultStr = TextWords:getTextWord(1249)
        end
        fightStateTxt:setString(resultStr)
        -- 主题 进攻{名称}的主城、进攻{资源名称}
        if itemData.typeState ~= 3 then 
            -- 非采集的进攻主题
            name:setString(self:getTextWord(1235))
            if itemData.targetType == 1 then --  targetType 1玩家 2玩家占领的资源点 3纯资源点 4 乱军喽啰 5 盟战
                nameTxt:setString(itemData.name) 
                typeTxt:setString(self:getTextWord(1236))
            elseif itemData.targetType == 2 then
                nameTxt:setString(itemData.defendName )
                typeTxt:setString(self:getTextWord(1240)) -- [[的]]
                defendResNameTxt:setString(itemData.name)
                local loyaltyCount = itemData.loyaltyCount
                defendResNameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
            elseif itemData.targetType == 3 then 
                nameTxt:setString(itemData.name)
                local loyaltyCount = itemData.loyaltyCount
                nameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
            elseif itemData.targetType == 4 then -- 格式： 喽啰Lv
                nameTxt:setString("Lv."..itemData.level .. itemData.name ) 
                --typeTxt:setString("Lv."..itemData.level) 
            elseif itemData.targetType == 5 then -- 郡城5打人，6打怪
                name:setString(itemData.name)
                name:setColor(ColorUtils.wordGreenColor)
                nameTxt:setString(self:getTextWord(471027)) -- "盟战"
            end
        else
            -- 采集主题
            name:setString(self:getTextWord(1250)) -- "从"
            nameTxt:setString(itemData.name)
            local loyaltyCount = itemData.loyaltyCount
            nameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
            typeTxt:setString(self:getTextWord(1251)) -- "采集回来"
        end
    elseif itemData.mailType == 2 then -- 防守
        -- 战况防守
        if itemData.typeState == 0 then -- 胜利
            victoryImg:setVisible(true)
            resultStr = TextWords:getTextWord(1213)
        else
            failImg:setVisible(true)
            resultStr = TextWords:getTextWord(1214)
        end
        fightStateTxt:setString(resultStr)
        -- 防守主题
        if itemData.targetType == 5 then -- 郡城类型
            name:setString(itemData.name)
            name:setColor(ColorUtils.wordGreenColor)
            nameTxt:setString(self:getTextWord(471027)) -- "盟战"
        else
            name:setString(self:getTextWord(3504))
            nameTxt:setString(itemData.name)
            typeTxt:setString(self:getTextWord(1237))
        end

    elseif itemData.mailType == 3 then -- 侦查格式：查看{玩家名称}{玩家等级} / 查看｛玩家名称｝的｛矿点名称｝/查看{矿点名称}
        -- 战况
        resultStr = TextWords:getTextWord(1234)
        fightStateTxt:setString(resultStr)
        -- 主题
        name:setString(self:getTextWord(1210))
        if itemData.targetType == 1 then --  targetType 1玩家 2玩家占领的资源点 3纯资源点
            nameTxt:setString(itemData.name.. "Lv."..itemData.level) 
        elseif itemData.targetType == 2 then
            nameTxt:setString(itemData.defendName )
            typeTxt:setString(self:getTextWord(1240)) -- 的
            defendResNameTxt:setString(itemData.name)
            local loyaltyCount = itemData.loyaltyCount
            defendResNameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
        elseif itemData.targetType == 3 then
            nameTxt:setString(itemData.name)
            local loyaltyCount = itemData.loyaltyCount
            nameTxt:setColor(self._worldProxy:getColorValueByLoyalty(loyaltyCount))
        end

    end


    NodeUtils:alignNodeL2R(name, nameTxt,typeTxt, defendResNameTxt, 2)


    -- 设置颜色
    self:setColorByTypeState(itemData.typeState, fightStateTxt)
    
    local timeStr = TimeUtils:setTimestampToString(itemData.createTime)
	time:setString(timeStr)

    -- 添加响应事件---------------
	self:addItemEvent(item)
end


function MailReportPanel:addItemEvent(item)
	if item.addEvent == true then
		return
	end
	item.addEvent = true
	self:addTouchEventListener(item,self.onReadMailReq)
end



function MailReportPanel:onReadMailReq(sender)
	local listData = self.view:getAllDetailData()
	print("============",self.view.isShow)

	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailReportInfoPanel.NAME)
		panel:show()
		panel:updateListData(listData[sender.data.id]) -- 参数等于 MailDetalInfo 结构体
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
end

------
-- tab响应函数
-- @param  args [obj] 参数
-- @return nil
function MailReportPanel:onTouchTabBtn(sender)
    -- 按钮标识
    self._index = sender.index -- 按钮标识
    self:setTabBtnState( self._index)

    local mailType = self:getMailTypeByBtnIndex(self._index)

    local reportData =  self:getReportDataByMailType(mailType)

    self:renderListView(self._listview, reportData, self, self.registerItemEvents)
    self._mailActionPanel:setBeingDelectMail(reportData)
end

------
-- 根据按钮的index获取mailType字段
function MailReportPanel:getMailTypeByBtnIndex(index)
    local mailType = index
    return mailType
end

------
-- 标签切换选中显示
function MailReportPanel:setTabBtnState(index)
    for i = 1 , MailReportPanel.TAB_COUNT do
        local btn = self._reportTabPanel:getChildByName( string.format("tabBtn_%d",i))
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

------
-- 根据mailType获取数据//1:攻击;2:被攻击;3:侦查
-- @param  args [obj] 参数
-- @return nil
function MailReportPanel:getReportDataByMailType(mailType)
    local listData = self.view:getAllShortData()
	local data = {}
	for _,v in pairs(listData) do
        if v ~= nil and v.type == self._type then
        	if v.mailType == mailType then
        		table.insert(data,v)
        	end
--            if mailType == 1 and v.mailType == 5  then -- 如果是进攻报告，额外包含郡城战报
--                table.insert(data,v)
--            end
		end
	end
    
	table.sort(data, function (a,b) return (a.createTime > b.createTime) end)
    return data
end 


------
-- 战况颜色设置
-- @param  args [obj] 参数
-- @return nil
function MailReportPanel:setColorByTypeState(typeState, strTxt)
    if typeState == 0 then -- 胜利
        strTxt:setColor(ColorUtils.wordGreenColor)
    elseif typeState == 1 then -- 失败
        strTxt:setColor(ColorUtils.wordRedColor)
    elseif typeState == 2 then -- 侦查
        strTxt:setColor(ColorUtils.wordGreenColor)
    elseif typeState == 3 then -- 采集成功
        strTxt:setColor(ColorUtils.wordGreenColor)
    end
end

-- 更新标签的红点， 调用点：function MailPanel:update4Count(data,flag)
function MailReportPanel:updateRedDot()
    for i = 1, MailReportPanel.TAB_COUNT do
        self:updateRedDotByIndex(i)
    end
end

function MailReportPanel:updateRedDotByIndex(index)
    local mailType = self:getMailTypeByBtnIndex(index)
    local reportData =  self:getReportDataByMailType(mailType)
    local notRead = 0
    for k, v in pairs(reportData) do
        if v.state == 0 then
            notRead = notRead + 1
        end
    end
    self:setTabDot(index, notRead)
end

function MailReportPanel:setTabDot(index, notRead)
    local tabBtn = self._reportTabPanel:getChildByName("tabBtn_".. index)
    local redDot = tabBtn:getChildByName("redDot")
    local num    = redDot:getChildByName("num")
    redDot:setVisible( notRead ~= 0 )
    num:setString(notRead)
end