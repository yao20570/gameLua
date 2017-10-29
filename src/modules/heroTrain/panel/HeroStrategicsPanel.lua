--
-- Author: zlf
-- Date: 2016年8月31日19:39:10
-- 英雄兵法主界面


HeroStrategicsPanel = class("HeroStrategicsPanel", BasicPanel)
HeroStrategicsPanel.NAME = "HeroStrategicsPanel"

function HeroStrategicsPanel:ctor(view, panelName)
	HeroStrategicsPanel.super.ctor(self, view, panelName)
    
    self:setUseNewPanelBg(true)
end

function HeroStrategicsPanel:initPanel()
	HeroStrategicsPanel.super.initPanel(self)
	self.proxy = self:getProxy(GameProxys.Hero)

    --//null
   
	self.numLab = self:getChildByName("topPanel/nameLab")
	self.lvLab = self:getChildByName("topPanel/lvLab")
	self.listView = self:getChildByName("ListView_19")
	self.heroImg = self:getChildByName("topPanel/heroImg")
	self.imgHeroHeadKuang = self:getChildByName("topPanel/imgKuang")

	self.stars = {}
	for i=1,5 do
		self.stars[i] = self:getChildByName("topPanel/Panel_7/starImg"..i)
	end
end

function HeroStrategicsPanel:doLayout()
	local tabsPanel = self:getTabsPanel()
	local topPanel = self:getChildByName("topPanel")
	NodeUtils:adaptiveTopPanelAndListView(topPanel, nil, nil, tabsPanel)

	NodeUtils:adaptiveListView(self.listView, GlobalConfig.downHeight, topPanel, 0)
end

function HeroStrategicsPanel:finalize()
    HeroStrategicsPanel.super.finalize(self)
end

function HeroStrategicsPanel:registerEvents()
end

function HeroStrategicsPanel:onShowHandler()
	self:initView()
end

function HeroStrategicsPanel:initView()
	local data = self.view:readCurData()
	self.curHeroId = data.heroDbId
	data = self.proxy:getInfoById(data.heroDbId)
	local heroData = ConfigDataManager:getConfigById(ConfigData.HeroConfig, data.heroId)

	local path = string.format("images/heroIcon/%d.png",data.heroId)
	TextureManager:updateImageView(self.heroImg, path)

	-- self.heroPos = self.heroPoss or cc.p(self.heroImg:getPosition())

	-- local offsetsPos = StringUtils:jsonDecode(heroData.pokedexPos)
	-- self.heroImg:setPosition(self.heroPos.x + offsetsPos[1] * 0.65, self.heroPos.y + offsetsPos[2] * 0.65)


	-- self.heroImg:setScale(0.65)
	local starUrl = "images/newGui1/IconStarMini.png"
	local drakUrl = "images/newGui1/IconStarMiniBg.png"
	ComponentUtils:renderStar(self.stars, data.heroStar, starUrl, drakUrl, heroData.starmax)
	-- ComponentUtils:adjustStarPos(162, self.stars, heroData.starmax)
	local color = ColorUtils:getColorByQuality(heroData.color) or cc.c3b(255,255,255)
	self.numLab:setColor(color)
	self.numLab:setString(heroData.name)

	self.lvLab:setString(" Lv."..data.heroLv)

    --//null
    --------------------------------------------------------------
    local numLab=self:getChildByName("topPanel/nameLab")
    local lvLab=self:getChildByName("topPanel/lvLab")
    NodeUtils:alignNodeL2R(numLab, lvLab)

    --------------------------------------------------------------

	path = string.format("images/newGui1/IconPinZhi%d.png",heroData.color)
	TextureManager:updateImageView(self.imgHeroHeadKuang, path)

	self.strategicsInfo = {}
	for k,v in pairs(data.strategicsInfo) do
		self.strategicsInfo[v.strategicsId] = v.strategicsLv
	end

	local strategicsData = ConfigDataManager:getConfigData(ConfigData.StrategicsConfig)
	local showData = {}
	local Strategics = StringUtils:jsonDecode(heroData.Strategics)
	for k,v in pairs(Strategics) do
		table.insert(showData, strategicsData[v])
	end

	self:renderListView(self.listView, showData, self, self.renderItem,nil,nil,GlobalConfig.listViewRowSpace)
end

function HeroStrategicsPanel:renderItem(item, data)
	-- local descLab = item:getChildByName("descLab")
	local labName = item:getChildByName("labName")
	local labLv = item:getChildByName("labLv")
	local infoLab = item:getChildByName("infoLab")
	local iconImg = item:getChildByName("iconImg")
	local lockImg = iconImg:getChildByName("lockImg")
	local maxLvImg = item:getChildByName("maxLvImg")
	-- local lvUpBtn = item:getChildByName("lvUpBtn")
	-- lvUpBtn:setTitleText("升级")
	

	local roleProxy = self:getProxy(GameProxys.Role)

	-- descLab:setVisible(false)
	-- if descLab.richLab == nil then
	-- 	descLab.richLab = ComponentUtils:createRichLabel("", nil, nil, 2)
	-- 	descLab.richLab:setPosition(cc.p(descLab:getPosition()))
	-- 	descLab:getParent():addChild(descLab.richLab)
	-- end
	local text = nil

	local ID = data.ID
	local level = self.strategicsInfo[ID]

	-- lvUpBtn:setBright(level ~= nil)
 --    lvUpBtn:setTouchEnabled(level ~= nil)
    -- NodeUtils:setEnable(lvUpBtn, level ~= nil)
    -- lvUpBtn:setVisible(true)
    item:setTouchEnabled(false)

	maxLvImg:setVisible(level ~= nil and level >= data.lvmax)

	-- infoLab:setColor(cc.c3b(0, 255, 0))
	local starConfig = ConfigDataManager:getInfoFindByTwoKey(ConfigData.StrategicsLvConfig, "StrategicsID", ID, "lv", level or 1)

	local comNum = roleProxy:getRoleAttrValue(PlayerPowerDefine.POWER_command)
	local infoString = StringUtils:getSymmetricStr(starConfig.info, "%b##", comNum)

	infoLab:setString(infoString)
	item.data = data
	local otherString
	if level ~= nil then
		-- otherString = {"     Lv."..level, 18, ColorUtils.commonColor.BiaoTi}--#FFE0BE27
		labLv:setString("  Lv."..level)
		labLv:setColor(ColorUtils.commonColor.c3bBiaoTi)
		self:addTouchEventListener(item, self.showLevelUpPanel)
	else
		-- lvUpBtn:setTitleText("未开启")
		-- otherString = {"     "..data.open, 18, ColorUtils.commonColor.Red}
		labLv:setString(data.open)
		labLv:setColor(ColorUtils.commonColor.c3bRed)
	end
	-- text = {{{data.name, 24}, otherString}}
	-- descLab.richLab:setString(text)
	labName:setString(data.name)
	NodeUtils:alignNodeL2R( labName,labLv )


	local url = level == nil and "images/newGui1/IconLock.png" or string.format("images/heroWarcraft/%d.png", ID)
	TextureManager:updateImageView(lockImg, url)

	
end

function HeroStrategicsPanel:showLevelUpPanel(sender)
	local heroData = self.proxy:getInfoById(self.curHeroId)
	local maxLv = sender.data.lvmax
	local level = self.strategicsInfo[sender.data.ID]
	local showData = {}
	showData.heroData = heroData
	showData.bfData = sender.data

	local name = HeroStrategicsUpPanel.NAME
	if level ~= nil then
		--满级
		if level >= maxLv then
			name = HeroStrategicsCheckPanel.NAME
		end
	else
		name = HeroStrategicsCheckPanel.NAME
	end
	local panel = self:getPanel(name)
	panel:show(showData)
end

function HeroStrategicsPanel:onUpdateView()
	local ID = self.view:readCurData().heroDbId
	local data = self.proxy:getInfoById(ID)
	self.view:saveCurData(data)
	local panel = self:getPanel(HeroStrategicsUpPanel.NAME)
	panel:updateView()
	self:initView()
end

function HeroStrategicsPanel:closeInfoPanel()
	-- local panel = self:getPanel(HeroStrategicsUpPanel.NAME)
	-- panel:hide()
end