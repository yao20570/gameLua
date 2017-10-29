-- /**
--  * @Author:    
--  * @DateTime:    0000-00-00 00:00:00
--  * @Description: 
--  */
MailCollectPanel = class("MailCollectPanel", BasicPanel)
MailCollectPanel.NAME = "MailCollectPanel"

function MailCollectPanel:ctor(view, panelName)
    MailCollectPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function MailCollectPanel:finalize()
    MailCollectPanel.super.finalize(self)
end

function MailCollectPanel:initPanel()
	MailCollectPanel.super.initPanel(self)
    self._mailActionPanel = self:getPanel(MailActionPanel.NAME)
    self._listview = self:getChildByName("bgListView")
    self._mailProxy = self:getProxy(GameProxys.Mail)
    self._worldProxy= self:getProxy(GameProxys.World)
end

function MailCollectPanel:registerEvents()
	MailCollectPanel.super.registerEvents(self)
end

-- 自适应
function MailCollectPanel:doLayout()
	local panel = self:getPanel(MailActionPanel.NAME)
    local downWidget = panel:getDownPanel()
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveListView(self._listview,downWidget,tabsPanel)
end

function MailCollectPanel:onShowHandler()
    

    self:updateCollectListView()
end

-- 列表刷新
function MailCollectPanel:updateCollectListView()
    local collectData = self._mailProxy:getCollectData()

    self:renderListView(self._listview, collectData, self, self.registerCollectItem)
    self._mailActionPanel:setBeingDelectMail(collectData)
end
-- 刷新列表MailShortInfo
-- type = 6;//邮件类型1:系统，2：发件箱；3：邮件；4：报告
function MailCollectPanel:registerCollectItem(item, data, index)
    -- 分为两类，报告和非报告
    local mailImg   = item:getChildByName("mailImg")
    local reportImg = item:getChildByName("reportImg")
    mailImg:setVisible(false)
    reportImg:setVisible(false)
    if data.type == 4 then
        reportImg:setVisible(true)
        -- 设置报告
        self:setReportMailItemShow(item, data)
    else
        mailImg:setVisible(true)
        self:setMailItemShow(item, data)
    end
end

------
-- 普通邮件item属性
function MailCollectPanel:setMailItemShow(item, data)
    if item == nil then
		return
	end
	item:setVisible(true)
	item.data = data -- 邮件数据
	local Image_6 = item:getChildByName("mailImg")
	local name = Image_6:getChildByName("name")
    local statusLab = Image_6:getChildByName("statusLab")
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
    if data.extracted == 1 then
        statusLab:setVisible(true)
        statusLab:setString(TextWords:getTextWord(1231))
        statusLab:setColor(cc.c3b(0, 255, 0))
    elseif data.extracted == 0 then
        statusLab:setVisible(true)
        statusLab:setString(TextWords:getTextWord(1230))
        statusLab:setColor(cc.c3b(255, 0, 0))
    else 
        statusLab:setVisible(false)
    end
	name:setString(item.data.name)
	title:setString(item.data.title)
	local timeStr = TimeUtils:setTimestampToString(item.data.createTime)
	time:setString(timeStr)
    self:addItemEvent(item)
end

-- 邮件类型1:系统，2：发件箱；3：邮件；4：报告
function MailCollectPanel:addItemEvent(item)
--	if item.addEvent == true then
--		return
--	end
--	item.addEvent = true
    local data = item.data
    if data.type == 3 then -- 3：邮件
        self:addTouchEventListener(item,self.onReadMailReq)
    elseif data.type == 2 then -- 2：发件箱
        self:addTouchEventListener(item,self.onReadMailReq02)
    elseif data.type == 1 then -- 1:系统
        self:addTouchEventListener(item,self.onReadMailReq03)
	end

end
-- 3：邮件
function MailCollectPanel:onReadMailReq(sender)
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

-- 2：发件箱
function MailCollectPanel:onReadMailReq02(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailDetailPanel.NAME)
		panel:show()
		panel:setContentText(sender.data.id)
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
    
end
-- 1:系统
function MailCollectPanel:onReadMailReq03(sender)
	local listData = self.view:getAllDetailData()
	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailReportInfoPanel.NAME)
		panel:show()
		panel:updateListData(listData[sender.data.id])
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
    
end

---------------------------------------------------------------------------------------------
function MailCollectPanel:setReportMailItemShow(item, data)
	if item == nil then
		return
	end
	item:setVisible(true)
	item.data = data
	local Image_6 = item:getChildByName("reportImg") -- 【改】===========

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
            -- 非采集
            name:setString(self:getTextWord(1235))
            if itemData.targetType == 1 then --  targetType 1玩家 2玩家占领的资源点 3纯资源点 4 乱军喽啰
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
            end
        else
            -- 采集
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
        -- 主题
        name:setString(self:getTextWord(3504))
        nameTxt:setString(itemData.name)
        typeTxt:setString(self:getTextWord(1237))
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

    -- 主题文本位置修正
    NodeUtils:fixTwoNodePos(name, nameTxt, 2)
    NodeUtils:fixTwoNodePos(nameTxt, typeTxt, 2)
    NodeUtils:fixTwoNodePos(typeTxt, defendResNameTxt, 2)
    -- 设置颜色
    self:setColorByTypeState(itemData.typeState, fightStateTxt)
    
    local timeStr = TimeUtils:setTimestampToString(itemData.createTime)
	time:setString(timeStr)

    -- 添加响应事件
	self:addItemEventReport(item) --【改】===============

end


function MailCollectPanel:addItemEventReport(item)
	self:addTouchEventListener(item,self.onReadMailReqReport)
end

function MailCollectPanel:onReadMailReqReport(sender)
	local listData = self.view:getAllDetailData()
	print("============",self.view.isShow)

	if listData[sender.data.id] ~= nil then
		local panel = self:getPanel(MailReportInfoPanel.NAME)
		panel:show()
		panel:updateListData(listData[sender.data.id]) -- 等于 MailDetalInfo 结构体
	else
		self:dispatchEvent(MailEvent.READ_MAIL_REQ,{id = sender.data.id})
	end
end

------
-- 战况颜色设置
-- @param  args [obj] 参数
-- @return nil
function MailCollectPanel:setColorByTypeState(typeState, strTxt)
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

