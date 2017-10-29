--[[
城主战：攻城鼓舞弹窗
]]

LordCityBuffPanel = class("LordCityBuffPanel", BasicPanel)
LordCityBuffPanel.NAME = "LordCityBuffPanel"

function LordCityBuffPanel:ctor(view, panelName)
    LordCityBuffPanel.super.ctor(self, view, panelName, 620)

end

function LordCityBuffPanel:finalize()
    LordCityBuffPanel.super.finalize(self)
end

function LordCityBuffPanel:initPanel()
	LordCityBuffPanel.super.initPanel(self)
	self:setTitle(true,self:getTextWord(370033))
	self._lordCityProxy = self:getProxy(GameProxys.LordCity)
	self._config = ConfigDataManager:getConfigData(ConfigData.InspireConfig)
end

function LordCityBuffPanel:registerEvents()
	LordCityBuffPanel.super.registerEvents(self)
end

function LordCityBuffPanel:onClosePanelHandler()
	self:hide()
end

function LordCityBuffPanel:onShowHandler()
	self._cityId = self._lordCityProxy:getSelectCityId()
	local data = self._lordCityProxy:getBuffInfoMap()
	local listView = self:getChildByName("mainPanel/listView")
	self:renderListView(listView, data, self, self.renderItem)
end

-------------------------------------------------------------------------------
-- 数据更新
-------------------------------------------------------------------------------
function LordCityBuffPanel:onBuffMapUpdate()
	self:onShowHandler()
end

function LordCityBuffPanel:onBuffUpUpdate()
	if self._inspireId and self._touchItem then
		local data = self._lordCityProxy:getBuffInfoById(self._inspireId)
		if data then
			self:renderItem(self._touchItem, data)
		end
	end
end

-------------------------------------------------------------------------------
function LordCityBuffPanel:renderItem(itemPanel,info)
	if itemPanel == nil or info == nil then
		return
	end
	local config = self._config[info.id]


	local iconImg = itemPanel:getChildByName("iconImg")
	local itemName = itemPanel:getChildByName("itemName")
	local itemLevel = itemPanel:getChildByName("itemLevel")
	local itemInfo = itemPanel:getChildByName("itemInfo")
	local buffBtn = itemPanel:getChildByName("buffBtn")


	itemName:setString(config.name)
	itemInfo:setString(config.info)
	itemLevel:setString("Lv."..info.level)  --等级要加协议


	local data = {}
	data.power = GamePowerConfig.Other
	data.typeid = config.icon
	data.num = 0

	TextureManager:updateImageView(iconImg,"images/lordCity/none.png")
	local iconUI = iconImg.iconUI
	if iconUI == nil then
		iconUI = UIIcon.new(iconImg,data,false)
		iconImg.iconUI = iconUI
	end
	iconUI:updateData(data)


	NodeUtils:setEnable(buffBtn,true)
	if config.maxlv == info.level then  --已满级
		NodeUtils:setEnable(buffBtn,false)
		buffBtn:setTitleText(self:getTextWord(370048))
		return
	end
	buffBtn:setTitleText(self:getTextWord(370047))

	buffBtn.info = info
	buffBtn.config = config
	buffBtn.itemPanel = itemPanel
	if buffBtn.addEvent == nil then
		buffBtn.addEvent = true
		self:addTouchEventListener(buffBtn, self.onBuffBtnTouch)
		return
	end

end

-- 升级按钮
function LordCityBuffPanel:onBuffBtnTouch(sender)
	local cityHost = self._lordCityProxy:getCityHostById(self._cityId)
	if cityHost.cityState == 0 then  --休战中不能升级
		self:showSysMessage(self:getTextWord(370077))
		return
	end

	local function okCallback()
		self._touchItem = sender.itemPanel
		self._inspireId = sender.info.id
		local data = {inspireId = self._inspireId, cityId = self._cityId}
		self._lordCityProxy:onTriggerNet360013Req(data)		
	end
	local price = sender.config.goldneed
	local level = sender.info.level + 1
	price = price * level
	local str = string.format(self:getTextWord(370011),price)
	self:showMessageBox(str,okCallback)
end
