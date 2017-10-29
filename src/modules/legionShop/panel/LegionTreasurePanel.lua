
LegionTreasurePanel = class("LegionTreasurePanel", BasicPanel)
LegionTreasurePanel.NAME = "LegionTreasurePanel"

function LegionTreasurePanel:ctor(view, panelName)
    LegionTreasurePanel.super.ctor(self, view, panelName)
    self.myContribute = 0
    self.info = {}
    
    self:setUseNewPanelBg(true)
end

function LegionTreasurePanel:finalize()
    LegionTreasurePanel.super.finalize(self)
end

function LegionTreasurePanel:initPanel()
	LegionTreasurePanel.super.initPanel(self)
end

function LegionTreasurePanel:registerEvents()
	LegionTreasurePanel.super.registerEvents(self)
	self.listView = self:getChildByName("ListView")
	self._topPanel = self:getChildByName("topPanel")
	self.myContributeTxt = self._topPanel:getChildByName("Label")

    local item = self.listView:getItem(0)
    item:setVisible(false)
end

function LegionTreasurePanel:doLayout()
	local tabsPanel = self:getTabsPanel()
    NodeUtils:adaptiveTopPanelAndListView(self._topPanel, self.listView, GlobalConfig.downHeight, tabsPanel)

 --   for k,item in pairs(self.listView) do
 --   local label1 = item:getChildByName("Label_1")
	--local label3 = item:getChildByName("Label_3")
	--local label4 = item:getChildByName("Label_4")
 --   local label5 = item:getChildByName("Label_5")
 --   NodeUtils:alignNodeL2R(label1,label5)
 --   NodeUtils:alignNodeL2R(label5,label3)
 --   NodeUtils:alignNodeL2R(label3,label4)
 --   end

end

function LegionTreasurePanel:onShowHandler(data)

	self:updateMyContribute()
	
	if self:isModuleRunAction() then
		return
	end
	
    if self.listView then
        self.listView:jumpToTop()
    end
	self:onUpdatePanel()
end

function LegionTreasurePanel:onAfterActionHandler()
	self:onShowHandler()
end

function LegionTreasurePanel:onUpdatePanel()
	local legionProxy = self:getProxy(GameProxys.Legion)
	local info,contribute  = legionProxy:getShopList(2)
	if info == nil then
		logger:info("shop info == nil  >> is error !")
		return
	end

	self:updateMyContribute()
	self.info = info
	self:renderListView(self.listView, info, self, self.renderItemPanel, 6)
end

function LegionTreasurePanel:updateMyContribute()
	local legionProxy = self:getProxy(GameProxys.Legion)
	local info,contribute,legionlv  = legionProxy:getShopList(2)
	self.myContribute = contribute
	self.legionLv = legionlv
	self.myContributeTxt:setString(contribute)
end

function LegionTreasurePanel:renderItemPanel(item,itemInfo,index)
	if itemInfo == nil or item == nil then
		return
	end

	item:setVisible(true)
	local container = item:getChildByName("container")
	local exchangeBtn = item:getChildByName("Button")
	local contributTxt = item:getChildByName("contribut")
	local label_00 = item:getChildByName("Label_00")
	local contributBg = item:getChildByName("Image_10")
	local label1 = item:getChildByName("Label_1")
	local label2 = item:getChildByName("Label_2")
	local label3 = item:getChildByName("Label_3")
	local label4 = item:getChildByName("Label_4")
    local label5 = item:getChildByName("Label_5")
	exchangeBtn.info = itemInfo
	self:addTouchEventListener(exchangeBtn ,self.touchExchangeBtn)
	contributTxt:setString(itemInfo.contributeneed)
	local info = ConfigDataManager:getConfigByPowerAndID(itemInfo.type,itemInfo.typeID)
	local treasureInfo = ConfigDataManager:getConfigData(ConfigData.LegionRandShopConfig)
	label1:setString(info.name.."*"..itemInfo.num)
    label1:setFontSize(24)
	local xxxx = label1:getContentSize()
	local eneen = label1:getPosition()
	label5:setPositionX(eneen+xxxx.width)

    local size5 = label5:getContentSize()
    local position5 = label5:getPosition()
    label3:setPositionX(position5 + size5.width)
	label3:setString(itemInfo.todayNum)

	local x4 = label3:getContentSize()
	local enenX4 = label3:getPosition()
	label4:setPositionX(enenX4+x4.width)
	label4:setString("/"..itemInfo.legexchamax..")")
	local descStr = info.info or info.desc
	descStr = descStr or ""
	label2:setString(descStr)
	if itemInfo.isCanExchange == false then
		exchangeBtn:setVisible(false)
		contributBg:setVisible(false)
		contributTxt:setVisible(false)
		label_00:setVisible(false)
	else
		exchangeBtn:setVisible(true)
		contributBg:setVisible(true)
		if itemInfo.contributeneed > self.myContribute then
			NodeUtils:setEnable(exchangeBtn,false)
		elseif itemInfo.todayNum >= itemInfo.legexchamax then
			NodeUtils:setEnable(exchangeBtn,false)
		else
			NodeUtils:setEnable(exchangeBtn,true)
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

function LegionTreasurePanel:touchExchangeBtn(sender)
	local data = {id=sender.info.ID, opt=1, type=1}
	self:dispatchEvent(LegionShopEvent.SHOW_SHOP_INFO_EVENT_REQ,data) --兑换
end