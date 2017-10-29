
arenaShopFightPanel = class("arenaShopFightPanel", BasicPanel)
arenaShopFightPanel.NAME = "arenaShopFightPanel"

function arenaShopFightPanel:ctor(view, panelName)
    arenaShopFightPanel.super.ctor(self, view, panelName)
    self._showFunMap = {}

    self:setUseNewPanelBg(true)
end

function arenaShopFightPanel:finalize()
    arenaShopFightPanel.super.finalize(self)
    self._showFunMap = {}
end

function arenaShopFightPanel:initPanel()
	arenaShopFightPanel.super.initPanel(self)
    
	self._listview = self:getChildByName("ListView_2")

    -- local tabsPanel = self:getTabsPanel()
    -- local tabsPanel = GlobalConfig.tabsMaxHeight
    


	local configData = ConfigDataManager:getConfigData("ArenaShopConfig")
	local data = {}
	for _,v in pairs(configData) do
		if v.page == 1 then
			table.insert(data,v)
		end
	end
	self:renderListView(self._listview, data, self, self.registerItemEvents)
end

function arenaShopFightPanel:doLayout()
	local panel = self:getPanel(arenaShopPanel.NAME)
	panel:doLayout()

    local tabsPanel = panel:getTopPanel()

    NodeUtils:adaptiveListView(self._listview,GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)

end

function arenaShopFightPanel:registerItemEvents(item,data,index)
	local name = item:getChildByName("name")
	local num = item:getChildByName("num")
	local info1 = item:getChildByName("info1")
	local iconImg = item:getChildByName("iconImg")
	local getBtn = item:getChildByName("getBtn")
	getBtn.id = data.ID
	getBtn.scoreprice = data.scoreprice

	local config = ConfigDataManager:getConfigByPowerAndID(data.type,data.typeID)
	name:setString(config.name)
	num:setString(data.scoreprice)
	info1:setString((config.info or ""))
	
	local iconData = {}
    iconData.power = data.type
    iconData.typeid = data.typeID
    iconData.num = 0
    local icon = iconImg.icon
    if icon == nil then
        icon = UIIcon.new(iconImg, iconData)
        iconImg.icon = icon
    else
        icon:updateData(iconData)
	end
	self:onCallGetBtn(getBtn)
end

function arenaShopFightPanel:onCallGetBtn(btn)
	if btn.isAdd == true then
		return
	end
	btn.isAdd = true
	self:addTouchEventListener(btn,self.onGetBtnTouch)
end

function arenaShopFightPanel:onGetBtnTouch(sender)
	self:dispatchEvent(ArenaShopEvent.CALL_BUY_REQ,{id = sender.id})
end

function arenaShopFightPanel:updateRoleInfo()
	local proxy = self:getProxy(GameProxys.Role)
	local count = proxy:getRoleAttrValue(PlayerPowerDefine.POWER_arenaGrade)
	local index = 0
	while( (self._listview:getItem(index)) ~= nil ) do
		local item = self._listview:getItem(index)
		local getBtn = item:getChildByName("getBtn")
		if getBtn.scoreprice <= count then
			NodeUtils:setEnable(getBtn, true)
		else
			NodeUtils:setEnable(getBtn, false)
		end
		index = index + 1
	end
end


function arenaShopFightPanel:onShowHandler()
    for key,v in pairs(self._showFunMap) do
        local fun = self[key]
        fun(self,v)
    end
    self._showFunMap = {}
end

function arenaShopFightPanel:getShowFunMapOpenFun()
    return self._showFunMap
end
