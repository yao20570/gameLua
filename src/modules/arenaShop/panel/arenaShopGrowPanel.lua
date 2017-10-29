arenaShopGrowPanel = class("arenaShopGrowPanel", BasicPanel)
arenaShopGrowPanel.NAME = "arenaShopGrowPanel"

function arenaShopGrowPanel:ctor(view, panelName)
    arenaShopGrowPanel.super.ctor(self, view, panelName)
    self._showFunMap = {}
    self._isFirstOPen = nil

    self:setUseNewPanelBg(true)
end

function arenaShopGrowPanel:finalize()
    arenaShopGrowPanel.super.finalize(self)
    self._showFunMap = {}
end

function arenaShopGrowPanel:initPanel()
    arenaShopGrowPanel.super.initPanel(self)
    self._listview = self:getChildByName("ListView_2")

    -- local tabsPanel = self:getTabsPanel()
    -- local tabsPanel = GlobalConfig.tabsMaxHeight
    
	
	local configData = ConfigDataManager:getConfigData("ArenaShopConfig")
	local data = {}
	for _,v in pairs(configData) do
		if v.page == 3 then
			table.insert(data,v)
		end
	end
	self:renderListView(self._listview, data, self, self.registerItemEvents)
end

function arenaShopGrowPanel:doLayout()
	local panel = self:getPanel(arenaShopPanel.NAME)
    local tabsPanel = panel:getTopPanel()

    NodeUtils:adaptiveListView(self._listview,GlobalConfig.downHeight,tabsPanel,GlobalConfig.topTabsHeight)
end

function arenaShopGrowPanel:registerItemEvents(item,data,index)
	local name = item:getChildByName("name")
	local num = item:getChildByName("num")
	local info1 = item:getChildByName("info1")
	local iconImg = item:getChildByName("iconImg")
	local getBtn = item:getChildByName("getBtn")
	getBtn.id = data.ID
	getBtn.type = data.type
	getBtn.scoreprice = data.scoreprice

	local config = ConfigDataManager:getConfigByPowerAndID(data.type,data.typeID)
	name:setString(config.name)
	num:setString(data.scoreprice)
	local descLab = config.info or config.desc
	info1:setString((descLab or ""))
	
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

function arenaShopGrowPanel:onCallGetBtn(btn)
	if btn.isAdd == true then
		return
	end
	btn.isAdd = true
	self:addTouchEventListener(btn,self.onGetBtnTouch)
end

function arenaShopGrowPanel:onGetBtnTouch(sender)
	if sender.type == GamePowerConfig.Hero then
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
	self:dispatchEvent(ArenaShopEvent.CALL_BUY_REQ,{id = sender.id})
end

function arenaShopGrowPanel:updateRoleInfo()
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

function arenaShopGrowPanel:onShowHandler()
	if self._isFirstOPen == nil then
		self._isFirstOPen = true
		self:updateRoleInfo()
		self._showFunMap = {}
		return
	end
    for key,v in pairs(self._showFunMap) do
        local fun = self[key]
        fun(self,v)
    end
    self._showFunMap = {}
end

function arenaShopGrowPanel:getShowFunMapOpenFun()
    return self._showFunMap
end