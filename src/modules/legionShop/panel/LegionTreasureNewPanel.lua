
LegionTreasureNewPanel = class("LegionTreasureNewPanel", BasicPanel)
LegionTreasureNewPanel.NAME = "LegionTreasureNewPanel"

function LegionTreasureNewPanel:ctor(view, panelName)
    LegionTreasureNewPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function LegionTreasureNewPanel:finalize()
    LegionTreasureNewPanel.super.finalize(self)
end

function LegionTreasureNewPanel:initPanel()
	LegionTreasureNewPanel.super.initPanel(self)

	self.listView = self:getChildByName("ListView")
	self._topPanel = self:getChildByName("topPanel")
    
    
    local item = self.listView:getItem(0)
    item:setVisible(false)
end

function LegionTreasureNewPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._topPanel, self.listView, GlobalConfig.downHeight, tabsPanel)
end

function LegionTreasureNewPanel:registerEvents()
	LegionTreasureNewPanel.super.registerEvents(self)
	self.myContributeTxt = self._topPanel:getChildByName("Label")
end

function LegionTreasureNewPanel:onShowHandler()

	self:updateMyContribute()

	if self:isModuleRunAction() then
		return
	end

    if self.listView then
        self.listView:jumpToTop()
    end
	self:onUpdatePanel()
end

function LegionTreasureNewPanel:onAfterActionHandler()
	self:onShowHandler()
end

function LegionTreasureNewPanel:onUpdatePanel()

    if self:isModuleRunAction() then
		return
	end

	local legionProxy = self:getProxy(GameProxys.Legion)
	local info,contribute,legionlv  = legionProxy:getShopList(1)
	if info == nil then return end

	self:updateMyContribute()
	-- self.info = info
	self.info = {}
	for k,v in pairs(info) do
		if v.consumeType == 2 then
			table.insert(self.info,v)
		end 
	end
	self:renderListView(self.listView, self.info, self, self.renderItemPanel, GlobalConfig.listViewRowSpace)
end

function LegionTreasureNewPanel:updateMyContribute()
	local legionProxy = self:getProxy(GameProxys.Legion)
	local info,contribute,legionlv  = legionProxy:getShopList(1)
	local mysalary = legionProxy:getMysalary()
	self.myContribute = mysalary
	self.legionLv = legionlv
	self.myContributeTxt:setString(mysalary)
end

function LegionTreasureNewPanel:renderItemPanel(item,itemInfo,index)
	item:setVisible(true)
	local container = item:getChildByName("container")
	local exchangeBtn = item:getChildByName("Button")
	local contributTxt = item:getChildByName("contribut")
	local label_00 = item:getChildByName("Label_00")
	local contributBg = item:getChildByName("Image_10")
	local label1 = item:getChildByName("Label_1")
	local label2 = item:getChildByName("Label_2")

	local label3 = item:getChildByName("Label_3")
	local label40 = item:getChildByName("Label_4_0")--左括号
	local label4 = item:getChildByName("Label_4")--右括号
	
	exchangeBtn.info = itemInfo
	self:addTouchEventListener(exchangeBtn ,self.touchExchangeBtn)

	contributTxt:setString(itemInfo.contributeneed)
	local info = ConfigDataManager:getConfigByPowerAndID(itemInfo.type,itemInfo.typeID)
	label1:setString(info.name.."*"..itemInfo.num)
	
	-------today
	local xxxx = label1:getContentSize()
	local eneen = label1:getPosition()
	-- label3:setPositionX(eneen+xxxx.width)
	label3:setString(itemInfo.todayNum)
	local x4 = label3:getContentSize()
	local enenX4 = label3:getPosition()
	-- label4:setPositionX(enenX4+x4.width)
	label4:setString("/"..itemInfo.exchangemax..")")

	NodeUtils:alignNodeL2R(label1,label40,label3,label4)

	local descStr = info.info or info.desc
	descStr = descStr or ""

	label2:setString(descStr)

    if label2.srcColor == nil then
        label2.srcColor = label2:getColor()
    end

    local str = string.format(self:getTextWord(3308),itemInfo.legionlv)
    local enterStr = StringUtils:getStringAddBackEnter(str, 14)
	label2:setString(enterStr)

	if itemInfo.isCanExchange == false then
		-- 什么条件未开放  ？？
		exchangeBtn:setVisible(false)
		contributBg:setVisible(false)
		contributTxt:setVisible(false)
		label_00:setVisible(false)
		label2:setColor(ColorUtils:getColorByQuality(6))
	
	else
		-- 应该是可以兑换
		if itemInfo.contributeneed > self.myContribute then
			NodeUtils:setEnable(exchangeBtn,false)
		elseif itemInfo.todayNum >= itemInfo.exchangemax then
			NodeUtils:setEnable(exchangeBtn,false)
		else
			NodeUtils:setEnable(exchangeBtn,true)
		end

		---------能兑换的情况下还要判断军团等级是否足够
		if itemInfo.legionlv > self.legionLv then 
			-- 军团等级不足未开放
			exchangeBtn:setVisible(false)
			contributBg:setVisible(false)
			contributTxt:setVisible(false)
			label_00:setVisible(false)
			label2:setColor(ColorUtils:getColorByQuality(6))
		else
			contributBg:setVisible(true)
	        contributTxt:setVisible(true)
	        label_00:setVisible(true)
			exchangeBtn:setVisible(true)
	        label2:setColor(label2.srcColor)
		end
	end

	local data = {}
	data.power = itemInfo.type
	data.typeid = itemInfo.typeID
	data.num = itemInfo.num
	local icon = container.icon
 	if icon == nil then
 		icon = UIIcon.new(container, data, true, self)
 		container.icon = icon
 	else
 		icon:updateData(data)
 	end

end

function LegionTreasureNewPanel:touchExchangeBtn(sender)
	if sender.info.type == GamePowerConfig.Hero then
		local heroProxy = self:getProxy(GameProxys.Hero)
		local heroNum = heroProxy:getAllHeroNum()
		if heroNum >= GameConfig.Hero.MaxNum then
			local function okcallbk()
				ModuleJumpManager:jump(ModuleName.HeroHallModule)
			end
			local str = self:getTextWord(290063)
			self:showMessageBox(str,okcallbk)
			return
		end
	end
	local data = {id=sender.info.ID, opt=1, type=0}
	self:dispatchEvent(LegionShopEvent.SHOW_SHOP_INFO_EVENT_REQ,data) --请求面板
end