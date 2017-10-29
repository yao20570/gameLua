
LegionAdviceHonourPanel = class("LegionAdviceHonourPanel", BasicPanel)
LegionAdviceHonourPanel.NAME = "LegionAdviceHonourPanel"

function LegionAdviceHonourPanel:ctor(view, panelName)
    LegionAdviceHonourPanel.super.ctor(self, view, panelName)
    
end

function LegionAdviceHonourPanel:finalize()
    LegionAdviceHonourPanel.super.finalize(self)
end

function LegionAdviceHonourPanel:initPanel()
	LegionAdviceHonourPanel.super.initPanel(self)

    local topPanel = self:getChildByName("btbg/titlePanel")
	self.listView = self:getChildByName("btbg/ListView")
	self.listView:setPositionY(topPanel:getPositionY()-self.listView:getContentSize().height)
	self.bottombg = self:getChildByName("btbg/bottombg")
	self.bottombg:setPositionY(self.listView:getPositionY())
	
    local Image_21 = self:getChildByName("btbg/Image_22")
    Image_21:setPositionY(self.bottombg:getPositionY())

    local dy=topPanel:getPositionY()-self.bottombg:getPositionY()
    Image_21:setContentSize(560,dy+10)
	local item = self.listView:getItem(0)
	item:setVisible(false)


end

function LegionAdviceHonourPanel:doLayout()
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

function LegionAdviceHonourPanel:registerEvents()
	LegionAdviceHonourPanel.super.registerEvents(self)
end


function LegionAdviceHonourPanel:onAfterActionHandler()
    self:onShowHandler()
end


function LegionAdviceHonourPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    if self.listView then
        self.listView:jumpToTop()
    end

	self:updateHonourInfo()
end


------
-- 
function LegionAdviceHonourPanel:updateHonourInfo()
    local legionProxy = self:getProxy(GameProxys.Legion)
    local info = legionProxy:getHonourInfo() -- 获取荣耀信息
    if #info <= 0 then
		self.listView:setVisible(false)
	 	return 
	else
		self.listView:setVisible(true)
	end

    self:renderListView(self.listView, info, self, self.renderItemPanel, 10,nil,0)
end

function LegionAdviceHonourPanel:renderItemPanel(item, itemInfo, index)
    item:setVisible(true)
    local label = {}
    for i=1, 8 do
		label[i] = item:getChildByName("Label_"..i)
		label[i]:setString("")
        label[i]:setColor( cc.c3b(156, 114, 76)) -- 初始化颜色
	end
    -- 奖励文本字体缩小
    label[4]:setFontSize(16)


    local timeStr = TimeUtils:setTimestampToString(itemInfo.time or 0)
	label[8]:setString(timeStr)

    local honorType       = itemInfo.honorType       -- 1群雄逐鹿奖励 ，2盟战奖励
    local occupyTownNum   = itemInfo.occupyTownNum   -- 盟战 占领郡城的个数
    local meleeBattleRank = itemInfo.meleeBattleRank -- 群雄逐鹿 排名
    local itemNameAndNum  = itemInfo.itemNameAndNum  -- 分配奖励的物品名字以及数量
    
    if honorType == 1 then
        label[1]:setString(self:getTextWord(3519))
        label[2]:setString(meleeBattleRank)
        label[3]:setString(self:getTextWord(3520))
        label[4]:setString(itemNameAndNum)
        label[5]:setString(self:getTextWord(3521))
         
        label[2]:setColor( ColorUtils.wordYellowColor01 ) -- 暗绿
        label[4]:setColor( ColorUtils.wordYellowColor01 ) -- 暗绿

    elseif honorType == 2 then
        label[1]:setString(self:getTextWord(3522))
        label[2]:setString(occupyTownNum)
        label[3]:setString(self:getTextWord(3523))
        label[4]:setString(itemNameAndNum)
        label[5]:setString(self:getTextWord(3521)) -- "(发放到福利所)"

        label[2]:setColor( ColorUtils.wordYellowColor01 )
        label[4]:setColor( ColorUtils.wordYellowColor01 )
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

    -- 颜色TODO
    local cardBgImg = item:getChildByName("cardBgImg")
    cardBgImg:setVisible(index%2 == 0)
    local cardBgImg1 = item:getChildByName("cardBgImg1")
    cardBgImg1:setVisible((index+1)%2 == 0)
end

