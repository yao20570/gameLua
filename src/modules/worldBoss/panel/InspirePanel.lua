--
-- Author: zlf
-- Date: 2016年8月16日10:39:47
-- 鼓舞界面
InspirePanel = class("InspirePanel", BasicPanel)
InspirePanel.NAME = "InspirePanel"

function InspirePanel:ctor(view, panelName)
    InspirePanel.super.ctor(self, view, panelName, 610)
end

function InspirePanel:finalize()
    InspirePanel.super.finalize(self)
end

function InspirePanel:initPanel()
	InspirePanel.super.initPanel(self)
    self:setTitle(true, self:getTextWord(280100))
    self:setLocalZOrder(PanelLayer.UI_Z_ORDER_1)

    self._listView = self:getChildByName("ListView_2")
    local item = self._listView:getItem(0)
    self._listView:setItemModel(item)
    item:setVisible(false)

    self.proxy = self:getProxy(GameProxys.BattleActivity)
	self.configData = ConfigDataManager:getConfigData(ConfigData.InspireConfig)
end

function InspirePanel:onShowHandler()
	self.curData = self.view:getCurActivityData()
	local inspireData = self.proxy:getInspireDataById(self.curData.activityId)

	local infos = {}
	for k,v in pairs(inspireData) do
		local data = ConfigDataManager:getConfigById(ConfigData.InspireConfig,k)
		table.insert(infos,data)
	end

	self:renderListView(self._listView, infos, self, self.renderItem)
end

function InspirePanel:onClosePanelHandler()
	self:hide()
end

function InspirePanel:renderItem(item, data)
	--local Image_3 = item:getChildByName("Image_3")
	--TextureManager:updateImageView(Image_3, "images/guiScale9/Frame_item_bg.png")
	local img = item:getChildByName("iconImg")
	local iconImg = img:getChildByName("icon")
	local infoLab = item:getChildByName("infoLab")
	local descLab = item:getChildByName("descLab")
	local lvUpBtn = item:getChildByName("lvUpBtn")

	local level = self.proxy:getInspireLevelByType(self.curData.activityId, data.ID)
	infoLab:setString(data.name .. " Lv." .. level)
	local url = string.format("images/otherIcon/%d.png", data.icon)
	TextureManager:updateImageView(iconImg, url)

	descLab:setString(data.info)

	lvUpBtn.data = data
	self:addTouchEventListener(lvUpBtn, self.sendLevelUpReq)
end

function InspirePanel:sendLevelUpReq(sender)
	self.currentID = sender.data.ID
	local level = self.proxy:getInspireLevelByType(self.curData.activityId, sender.data.ID)
	if level >= sender.data.maxlv then
		self:showSysMessage(TextWords:getTextWord(280101))
		return
	end
	local needCoin = self.configData[sender.data.ID].goldneed * (level + 1)
	local roleProxy = self:getProxy(GameProxys.Role)
    local coin = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_gold)

    local function callback()
    	if needCoin <= coin then
	    	self.proxy:onTriggerNet320002Req({typeId = sender.data.ID})
	    else
	    	if self.uiChargePanel == nil then
	    		self.uiChargePanel = UIRecharge.new(parent, self)
	    	else
	    		self.uiChargePanel:show()
	    	end
	    end
    end
    local content = string.format(TextWords:getTextWord(280102), needCoin)
    self:showMessageBox(content, callback)
end

function InspirePanel:updateView()
	self:showSysMessage(TextWords:getTextWord(280103))
	self.proxy:setInspireData(self.curData.activityId)
	self:onShowHandler()
	-- self:renderListView(self._listView, self.configData, self, self.renderItem)
end