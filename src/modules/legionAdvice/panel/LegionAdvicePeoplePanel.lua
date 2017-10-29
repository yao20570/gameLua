
LegionAdvicePeoplePanel = class("LegionAdvicePeoplePanel", BasicPanel)
LegionAdvicePeoplePanel.NAME = "LegionAdvicePeoplePanel"

function LegionAdvicePeoplePanel:ctor(view, panelName)
    LegionAdvicePeoplePanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionAdvicePeoplePanel:finalize()
    LegionAdvicePeoplePanel.super.finalize(self)
end

function LegionAdvicePeoplePanel:initPanel()
	LegionAdvicePeoplePanel.super.initPanel(self)
	local topPanel = self:getChildByName("btbg/titlePanel")
	self.listView = self:getChildByName("btbg/ListView")
	self.listView:setPositionY(topPanel:getPositionY()-self.listView:getContentSize().height)
	self.bottombg=self:getChildByName("btbg/bottombg")
	self.bottombg:setPositionY(self.listView:getPositionY())
	local Image_21=self:getChildByName("btbg/Image_22")
    Image_21:setPositionY(self.bottombg:getPositionY())
    
    local dy=topPanel:getPositionY()-self.bottombg:getPositionY()
    Image_21:setContentSize(560,dy+10)
	local item = self.listView:getItem(0)
	item:setVisible(false)
end

function LegionAdvicePeoplePanel:doLayout()
	local topPanel = self:getChildByName("btbg/titlePanel")
	local tabsPanel = self:getTabsPanel()
	NodeUtils:adaptiveTopPanelAndListView(topPanel,self.listView,GlobalConfig.downHeight,tabsPanel)

	self.listView = self:getChildByName("btbg/ListView")
	self.listView:setPositionY(topPanel:getPositionY()-self.listView:getContentSize().height)
	self.bottombg=self:getChildByName("btbg/bottombg")
	self.bottombg:setPositionY(self.listView:getPositionY())
	local Image_21=self:getChildByName("btbg/Image_22")
    Image_21:setPositionY(self.bottombg:getPositionY())
    
    local dy=topPanel:getPositionY()-self.bottombg:getPositionY()
    Image_21:setContentSize(560,dy+10)
end

function LegionAdvicePeoplePanel:registerEvents()
	LegionAdvicePeoplePanel.super.registerEvents(self)
end

function LegionAdvicePeoplePanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionAdvicePeoplePanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    if self.listView then
        self.listView:jumpToTop()
    end
	-- self.listView:removeAllItems()
	self:updateAdviceInfo()
end

function LegionAdvicePeoplePanel:updateAdviceInfo()

	if self:isModuleRunAction() then
        return
    end

	local legionProxy = self:getProxy(GameProxys.Legion)
	local info = legionProxy:getPeopleInfo()
	if #info <= 0 then
		self.listView:setVisible(false)
	 	return 
	else
		self.listView:setVisible(true)
	end
	self:renderListView(self.listView, info, self, self.renderItemPanel, 10,nil,0)
end

function LegionAdvicePeoplePanel:renderItemPanel(item, itemInfo, index)
	item:setVisible(true)
    local imgTouch = item:getChildByName("imgTouch") 
	local label = {}
	for i=1,8 do
		label[i] = item:getChildByName("Label_"..i)
		label[i]:setString("")
	end

    -- 初始颜色
    label[2]:setColor(ColorUtils.wordYellowColor03) -- 描述颜色
    label[4]:setColor(ColorUtils.wordYellowColor03) -- 描述颜色
    label[6]:setColor(ColorUtils.wordYellowColor03) -- 描述颜色

	local timeStr = TimeUtils:setTimestampToString(itemInfo.time or 0)
	label[8]:setString(timeStr)
	if itemInfo.smalltype == 1 then
		label[1]:setString(itemInfo.info1.name)
		label[2]:setString(self:getTextWord(3507))  --消灭了试炼中心的:
		local config = ConfigDataManager:getConfigById(ConfigData.LegionEventConfig, itemInfo.dungoeId)
		if config ~= nil then
			label[3]:setString(config.name)
		end
	elseif itemInfo.smalltype == 2 then
		label[1]:setString(self:getTextWord(3508)) --军团长从战事福利中分配了物品:
		label[3]:setString("######")
		label[4]:setString(self:getTextWord(3509))
		label[5]:setString(itemInfo.info1.name)
		label[6]:setString(self:getTextWord(3510))
	elseif itemInfo.smalltype == 3 then
		label[1]:setString(itemInfo.info1.name)
		label[2]:setString(self:getTextWord(3511))
	elseif itemInfo.smalltype == 4 then
		label[1]:setString(itemInfo.info1.name)
		label[2]:setString(self:getTextWord(3512))
	elseif itemInfo.smalltype == 5 then
		label[1]:setString(itemInfo.info1.name)
		label[2]:setString(self:getTextWord(3513))
		label[3]:setString(itemInfo.info2.name)
		label[4]:setString(self:getTextWord(3514))
	elseif itemInfo.smalltype == 6 then
		label[1]:setString(itemInfo.info2.name)
		label[2]:setString(self:getTextWord(3515))
		label[3]:setString(itemInfo.info1.name)
		label[4]:setString(self:getTextWord(3516))
	elseif itemInfo.smalltype == 7 then
		label[1]:setString(itemInfo.info1.name)
		label[2]:setString(self:getTextWord(3517))
		label[3]:setString(itemInfo.job)
	elseif itemInfo.smalltype == 8 then
		label[1]:setString(itemInfo.buildup)
	elseif itemInfo.smalltype == 9 then
		label[1]:setString( itemInfo.info2.name )
		label[2]:setString( self:getTextWord(3518) )
		label[3]:setString( itemInfo.itemNameAndNum )
		label[4]:setString( self:getTextWord(3509)..itemInfo.info1.name )

        label[4]:setColor(ColorUtils.wordNameColor) -- 白色
	end

	if itemInfo.smalltype == 9 then
		label[3]:setColor( ColorUtils.wordYellowColor01 ) -- 标题橙色
	else
		label[3]:setColor( cc.c3b(255,255,255) )
	end

	for i=2,4 do
		local xxxx = label[i-1]:getContentSize()
		local eneen = label[i-1]:getPosition()
		label[i]:setPositionX(eneen+xxxx.width)
	end
	for i=6,7 do
		local xxxx = label[i-1]:getContentSize()
		local eneen = label[i-1]:getPosition()
		label[i]:setPositionX(eneen+xxxx.width)
	end
    -- cardbg显示设置
    local cardBgImg = item:getChildByName("cardBgImg")
    cardBgImg:setVisible(index%2 == 0)
    local cardBgImg1 = item:getChildByName("cardBgImg1")
    cardBgImg1:setVisible((index+1)%2 == 0)

    local function TouchBegin(sender)
        imgTouch:setVisible(true)
    end
    local function TouchCancel(sender)
        imgTouch:setVisible(false)
    end
    local function TouchEnded(sender)
        imgTouch:setVisible(false)
    end
    self:addTouchEventListener(item, TouchEnded,TouchBegin)
    item.cancelCallback = TouchCancel
    imgTouch:setVisible(false)
end
