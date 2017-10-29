
LegionAdviceArmyPanel = class("LegionAdviceArmyPanel", BasicPanel)
LegionAdviceArmyPanel.NAME = "LegionAdviceArmyPanel"

function LegionAdviceArmyPanel:ctor(view, panelName)
    LegionAdviceArmyPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionAdviceArmyPanel:finalize()
    LegionAdviceArmyPanel.super.finalize(self)
end

function LegionAdviceArmyPanel:initPanel()
	LegionAdviceArmyPanel.super.initPanel(self)

    local topPanel = self:getChildByName("btbg/titlePanel")
    self.listView = self:getChildByName("btbg/ListView")
    self.listView:setPositionY(topPanel:getPositionY()-self.listView:getContentSize().height)
    self.bottombg=self:getChildByName("btbg/bottombg")
    self.bottombg:setPositionY(self.listView:getPositionY())
    local Image_21=self:getChildByName("btbg/Image_21")
    Image_21:setPositionY(self.bottombg:getPositionY())
    
    local dy=topPanel:getPositionY()-self.bottombg:getPositionY()
    Image_21:setContentSize(560,dy+10)
    local item = self.listView:getItem(0)
    item:setVisible(false)
end

function LegionAdviceArmyPanel:doLayout()
    local topPanel = self:getChildByName("btbg/titlePanel")
    local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(topPanel,self.listView,GlobalConfig.downHeight,tabsPanel)
    -- local topPanel = self:getChildByName("btbg/titlePanel")
    self.listView = self:getChildByName("btbg/ListView")
    self.listView:setPositionY(topPanel:getPositionY()-self.listView:getContentSize().height)
    self.bottombg=self:getChildByName("btbg/bottombg")
    self.bottombg:setPositionY(self.listView:getPositionY())
    local Image_21=self:getChildByName("btbg/Image_21")
    Image_21:setPositionY(self.bottombg:getPositionY())
    
    local dy=topPanel:getPositionY()-self.bottombg:getPositionY()
    Image_21:setContentSize(560,dy+10)
end

function LegionAdviceArmyPanel:registerEvents()
    LegionAdviceArmyPanel.super.registerEvents(self)
end

function LegionAdviceArmyPanel:onAfterActionHandler()
    self:onShowHandler()
end

function LegionAdviceArmyPanel:onShowHandler()
    if self:isModuleRunAction() then
        return
    end
    
    if self.listView then
        self.listView:jumpToTop()
    end

    self:updateAdviceInfo()
end


function LegionAdviceArmyPanel:updateAdviceInfo()

    if self:isModuleRunAction() then
        return
    end

	local legionProxy = self:getProxy(GameProxys.Legion)
	local info = legionProxy:getAdviceInfo()
	if #info <= 0 then
		self.listView:setVisible(false)
	 	return
	else
		self.listView:setVisible(true)
	end
	self:renderListView(self.listView, info, self, self.renderItemPanel, 10,nil,0)
end

function LegionAdviceArmyPanel:renderItemPanel(item, itemInfo, index)
    item:setVisible(true)
    local timeTxt = item:getChildByName("timeTxt")  -- 时间文本
    local infoTxt = item:getChildByName("infoTxt")  -- 时间文本
    local imgTouch = item:getChildByName("imgTouch") 
    -- 设置时间
    timeTxt:setString(TimeUtils:setTimestampToString(itemInfo.time or 0))
    -- 创建富文本
    local richInfoLab01 = item.richInfoLab01
    if richInfoLab01 == nil then
        richInfoLab01 = ComponentUtils:createRichLabel( "" , nil , nil, 2 )
        richInfoLab01:setPosition(richInfoLab01:getPositionX(), richInfoLab01:getPositionY() + 12)
        infoTxt:addChild(richInfoLab01)
        item.richInfoLab01 = richInfoLab01
    end
    local richInfoLab02 = item.richInfoLab02
    if richInfoLab02 == nil then
        richInfoLab02 = ComponentUtils:createRichLabel( "" , nil , nil, 2 )
        richInfoLab02:setPosition(richInfoLab01:getPositionX(), richInfoLab01:getPositionY() - 25)
        infoTxt:addChild(richInfoLab02)
        item.richInfoLab02 = richInfoLab02
    end

    -- 组合文本
    -- 遭到
    local str1 = self:getTextWord(3504) 
    -- 攻击，被抢夺了
    local str2 = self:getTextWord(732)..","..self:getTextWord(3506)
    -- 攻击，防守胜利
    local str3 = self:getTextWord(732)..","..self:getTextWord(3505)
    -- 资源
    local str4 = self:getTextWord(500)
    local iName = itemInfo.info1.name -- 我方名字
    local hName = itemInfo.info2.name -- 敌方名字
    local legionName = string.format ("(%s)", itemInfo.info2.legionName )-- 军团名
    local lostNum =  StringUtils:formatNumberByK3(itemInfo.loseNum)      -- 损失的数量
    local lostString = lostNum .. str4
    
    if legionName == "()" then
        legionName = ""  --敌人没有军团，则不显示
    end

    local memo01 = {{
            {iName, 18, ColorUtils.commonColor.White},
            {str1, 18, ColorUtils.commonColor.MiaoShu},
            {hName, 18, ColorUtils.commonColor.White},
            {legionName, 18, ColorUtils.commonColor.Red},
        }}
    richInfoLab01:setString(memo01)
    -- 成功或失败
    if itemInfo.result == 1 then
        local memo02 = {{
            {str3, 18, ColorUtils.commonColor.MiaoShu}
        }}
        richInfoLab02:setString(memo02)
    else
        local memo02 = {{
            {str2, 18, ColorUtils.commonColor.MiaoShu},
            {lostString, 18, ColorUtils.commonColor.MiaoShu},
        }}
        richInfoLab02:setString(memo02)
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
